#!/usr/bin/env bash
# 가이드 폴더를 S3 + CloudFront 에 올린다. 처음이면 스택을 만들고, 다음부터는 파일만 다시 올린다.
#   ./scripts/publish.sh --name anycompany --dir out/anycompany [--region us-east-1]
set -euo pipefail
cd "$(dirname "$0")/.."

NAME=""
DIR=""
REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
REGION="${REGION:-us-east-1}"
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --dir) DIR="$2"; shift 2 ;;
    --region) REGION="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done
[ -n "$NAME" ] && [ -n "$DIR" ] || { echo "usage: $0 --name <slug> --dir <guide folder>" >&2; exit 1; }
[ -f "$DIR/index.html" ] || { echo "$DIR/index.html 이 없습니다" >&2; exit 1; }
if grep -q '{{' "$DIR/index.html"; then
  echo "경고: 채우지 않은 자리표시가 남아 있습니다:" >&2
  grep -n '{{' "$DIR/index.html" >&2
fi

STACK="${NAME}-quick-guide"
aws cloudformation deploy --region "$REGION" --template-file hosting/template.yaml \
  --stack-name "$STACK" --parameter-overrides Name="$NAME" --no-fail-on-empty-changeset

out() {
  aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
    --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" --output text
}
BUCKET="$(out BucketName)"
DIST="$(out DistributionId)"

aws s3 sync "$DIR" "s3://${BUCKET}" --delete --region "$REGION" --exclude ".DS_Store" --cache-control "no-cache" >/dev/null
aws cloudfront create-invalidation --distribution-id "$DIST" --paths "/*" >/dev/null
echo "published: $(out Url)"
