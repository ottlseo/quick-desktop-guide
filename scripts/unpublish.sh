#!/usr/bin/env bash
# publish.sh 로 올린 가이드를 지운다 (버킷 비우기 + 스택 삭제).
#   ./scripts/unpublish.sh --name anycompany [--region us-east-1]
set -euo pipefail

NAME=""
REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"
REGION="${REGION:-us-east-1}"
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --region) REGION="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done
[ -n "$NAME" ] || { echo "usage: $0 --name <slug>" >&2; exit 1; }

STACK="${NAME}-quick-guide"
BUCKET="$(aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" --output text)"
aws s3 rm "s3://${BUCKET}" --recursive --region "$REGION" >/dev/null
echo "deleting ${STACK}... CloudFront 때문에 몇 분 걸립니다"
aws cloudformation delete-stack --region "$REGION" --stack-name "$STACK"
aws cloudformation wait stack-delete-complete --region "$REGION" --stack-name "$STACK"
echo "done"
