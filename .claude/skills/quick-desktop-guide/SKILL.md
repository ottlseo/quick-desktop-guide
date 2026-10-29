---
name: quick-desktop-guide
description: 고객사별 Amazon Quick Desktop 실습 가이드 페이지를 만든다. guide/ 템플릿("AnyCompany를 위한 Quick Desktop 실습")을 복사해 고객 이름·로고를 넣고, 실습 1 시나리오를 고객사에 맞게 새로 쓰고, meeting-room-mcp 를 배포해 실습 3 MCP 설정을 채운 뒤 CloudFront 로 올린다. 트리거: "Quick Desktop 실습 가이드 만들어줘", "<고객>용 Quick 실습", "quick desktop guide", "실습 가이드 고객사 버전"
---

# 고객사별 Quick Desktop 실습 가이드 만들기

이 레포의 `guide/`는 "AnyCompany를 위한 Quick Desktop 실습" 템플릿이다. 고객사마다 복사해서 바꾼다.

## 참고할 파일

| 파일 | 용도 |
|---|---|
| `guide/index.html` | 템플릿. 복사해서 쓴다. `{{MCP_URL}}`, `{{ACCESS_TOKEN}}`, `{{ROOMS_PAGE_URL}}` 자리표시가 있다 |
| `examples/anycompany/index.html` | **완성 예시.** 가상 유통 회사 AnyCompany 용으로 실습 1을 새로 쓰고 실습 3을 채운 모습이다. 결과물이 어떤 모습이어야 하는지 먼저 이 파일을 열어 확인한다 (값은 가상) |
| https://github.com/ottlseo/meeting-room-mcp | 실습 3 회의실 MCP. CloudFormation 으로 배포하면 `mcp.json` 과 MCP 와 연결된 회의실 현황 페이지가 나온다. 사용법은 그 레포 README 를 따른다 |

| 실습 | 내용 | 고객사별로 |
|---|---|---|
| 1 | 스케줄 + 웹 검색 → Activity Feed (매일 아침 뉴스 브리핑) | **반드시 새로 쓴다** |
| 2 | 외식 프랜차이즈 광고 트렌드 PPT (수정 가능한 차트 4장) | 그대로 둔다 (영상이 이 프롬프트로 녹화돼 있다) |
| 3 | 회의실 예약 MCP 연결 (Remote › Paste JSON) | MCP 를 배포해 설정 JSON 과 현황 페이지 주소를 채운다 |
| 자유 | 기능 목록 + 웹 커넥터 연결 영상 | 그대로 둔다 |

## 0. 먼저 물어볼 것

시작 전에 아래를 사용자에게 확인한다. 모르는 값은 추측하지 말고 묻는다.

1. 고객사 표기 (철자, 대소문자, 띄어쓰기 그대로. 예: `AnyCompany` 를 `Anycompany` 로 쓰면 안 된다)
2. 고객사 홈페이지 또는 로고 파일 (없으면 템플릿의 AWS 로고 `assets/company-logo.png` 를 그대로 둔다)
3. 고객사가 하는 일 (실습 1 시나리오를 쓰려면 필요하다. 홈페이지에서 찾아봐도 된다)
4. 실습 3 회의실 MCP 를 배포할 AWS 계정·리전 (기본 `us-east-1`) 과 실습 날짜 (토큰이 24시간이라 당일 아침에 다시 발급해야 한다)
5. 가이드를 CloudFront 로 올릴지, HTML 파일로만 줄지

## 1. 복사

```bash
mkdir -p out && cp -R guide "out/<slug>"     # slug: 고객사 이름 소문자-하이픈 (예: anycompany)
```

이후 작업은 `out/<slug>/` 에서만 한다. `guide/` 템플릿은 고치지 않는다.

## 2. 고객 이름과 로고

- `AnyCompany` 를 전부 고객사 표기로 바꾼다 (`<title>`, 상단 메뉴, 히어로, 본문). 바꾼 뒤 `grep -c AnyCompany` 가 0 인지 확인한다.
- 조사를 이름의 마지막 소리에 맞춘다: 받침이 없으면 "를 위한", 있으면 "을 위한" (영문 이름은 읽는 소리 기준)
- 로고: 고객사 홈페이지의 로고 이미지를 받아 `assets/company-logo.png` 를 바꾼다 (참조는 상단 메뉴, 히어로 라벨 두 곳). 투명 배경, 정사각형에 가까운 마크가 좋다. 가로로 긴 워드마크면 마크 부분만 잘라 쓰고, 어렵다면 사용자에게 어떤 이미지를 쓸지 묻는다.
- 파비콘은 Quick 아이콘(`assets/quick-favicon.png`)을 그대로 둔다.

## 3. 실습 1: 고객사에 맞는 시나리오를 새로 쓴다 (필수)

템플릿의 기본 시나리오는 범용이다.

```text
매일 아침 9시에 어제 나온 AI·IT 업계 주요 뉴스 3개를 한 줄씩 요약하고 링크를 붙여 Activity Feed에 띄워줘.
```

고객사마다 **이 프롬프트를 그대로 쓰지 말고 새로 작성한다.** 제목(`<h2>`), 핵심 한 줄(`.point`), 프롬프트(`#p1`), 실습 흐름 마지막 단계를 함께 바꾼다. 바꾼 모습은 `examples/anycompany/index.html` 의 실습 1("유통·이커머스 업계 아침 브리핑")을 참고한다.

새로 쓸 때 지킬 것

- 구조는 그대로: **스케줄(시간) + 웹 검색 + Activity Feed**, 한 문장
- 결과를 출처로 바로 확인할 수 있는 주제를 고른다. 예: 고객사·계열사·업계 뉴스, 공시·보도자료, 경쟁사 신제품 소식, 업계 정책·규제 변경
- 지어낼 여지가 있는 주제는 피한다. 예: 곡·상품 추천, 차트 순위 해석, 출처 없는 수치 (실제로 "멜론 차트 기반 플레이리스트 추천"은 결과가 흔들려서 뺐다)
- "링크를 붙여줘", 기간("어제", "최근 7일"), 개수("3개")를 넣는다
- 참가자가 바로 이해하는 쉬운 주제일수록 좋다. 업무에 꼭 맞추느라 복잡하게 만들지 않는다
- 시나리오 후보 2~3개를 사용자에게 보여주고 고르게 한 뒤 반영한다

예시: 고객사가 큰 그룹의 계열사라면 `매일 아침 9시에 어제 나온 <그룹명> 관련 뉴스 3개를 한 줄씩 요약하고 링크를 붙여 Activity Feed에 띄워줘.` 처럼 그룹 뉴스로 좁히면 결과가 매일 충분히 나오고 참가자가 바로 확인할 수 있다.

## 4. 실습 2: 그대로 둔다

프롬프트와 영상(`quick-ppt-generate.mp4`, `quick-ppt-results.mp4`)이 짝이다. 사용자가 업종을 바꾸자고 하면 바꾸되, 영상과 프롬프트가 달라진다는 점을 알리고 다시 녹화할지 묻는다. 바꿀 때도 아래는 유지한다.

- "찾은 소식을 기준으로" 차트를 만들게 한다 (외부 통계를 찾게 하지 않는다)
- "수정가능한 형태로 ppt에 넣어줘", "한국어로 말해줘"
- 웹 이미지(로고, 프로모션 사진)를 PPT 에 넣게 하지 않는다. 잘 안 된다
- 메일 발송 단계는 넣지 않는다

## 5. 실습 3: 회의실 MCP 배포 후 채우기

회의실 MCP 는 별도 레포 https://github.com/ottlseo/meeting-room-mcp 를 쓴다. 배포하면 두 가지가 생긴다: 회의실 예약 MCP 서버(AgentCore Gateway + Lambda + DynamoDB)와, 그 MCP 와 같은 데이터를 보여주는 회의실 현황 페이지(CloudFront). 채워진 모습은 `examples/anycompany/index.html` 의 실습 3을 참고한다.

```bash
git clone https://github.com/ottlseo/meeting-room-mcp.git /tmp/meeting-room-mcp
cd /tmp/meeting-room-mcp && ./scripts/deploy.sh --prefix <slug>-room --region us-east-1
./scripts/test.sh
```

- 출력된 `mcp.json` 전체로 가이드의 `<pre id="p3">` 내용을 바꾼다 (`{{MCP_URL}}`, `{{ACCESS_TOKEN}}` 자리표시가 사라져야 한다). JSON 은 HTML 안에 들어가므로 `<`, `>` 가 있으면 이스케이프한다.
- 출력된 `room status page` 주소로 `{{ROOMS_PAGE_URL}}` 을 바꾼다.
- 토큰은 24시간 유효하다. 실습 당일 아침에 `./scripts/mcp-json.sh --stack <slug>-room-mcp` 로 다시 발급해 가이드에 다시 넣고 다시 올린다.
- 토큰이 들어간 가이드를 공개 주소에 올리는 것은 사용자가 명시적으로 허락했을 때만 한다. 자동 보안 검사가 막으면 사용자에게 상황을 설명하고 결정을 맡긴다.
- 회의실은 3층 8개, 4층 대회의실 2개, 5층 임원회의실 2개다. 예시 프롬프트("4층 대회의실")가 이 배치와 맞는지 확인한다.

## 6. 확인

- 남은 자리표시가 없어야 한다: `grep -n '{{' out/<slug>/index.html` 결과 0줄, `grep -c AnyCompany` 0
- em dash 기호(U+2014)를 쓰지 않는다: `python3 -c "print(open('out/<slug>/index.html').read().count(chr(0x2014)))"` 결과 0
- CSS 를 지우거나 고쳤다면 `<style>` 안 `{` 와 `}` 개수가 같은지 확인한다 (블록 일부만 지워서 카드 스타일이 통째로 깨진 적이 있다)
- Chrome headless 로 데스크톱(1360px)과 모바일(520px) 스크린샷을 찍어 깨진 곳이 없는지 본다
- 실습 3 예시 프롬프트 하나를 MCP 로 실제 호출해 보고, 현황 페이지에 예약이 뜨는지 본다

## 7. 올리기

CloudFront 로 올릴 때:

```bash
./scripts/publish.sh --name <slug> --dir out/<slug>          # 처음과 수정할 때 모두
./scripts/unpublish.sh --name <slug>                          # 실습이 끝난 뒤
```

실습이 끝나면 가이드와 회의실 MCP 를 모두 지운다 (`/tmp/meeting-room-mcp/scripts/destroy.sh --prefix <slug>-room`). 토큰이 가이드에 공개돼 있기 때문이다.

## 지켜야 할 것

- 해커톤이 아니라 실습이다. 심사 기준, 상품, 결과 제출, "실습 진행 순서" 같은 섹션을 넣지 않는다
- 문체는 담백하게, 과장·세일즈 표현을 쓰지 않는다
- MCP 추가는 파일 Import 가 아니라 **Remote › Paste JSON** 으로 안내한다 (영상도 이 방식이다)
- 영상 `mcp-connect-guide.mp4` 에는 녹화 당시 다른 고객사의 서버 이름이 보인다. 고객사 이름이 보여야 하는 자리라면 새로 녹화할지 사용자에게 묻는다
- 고객사 이름 철자는 사용자가 준 그대로 쓴다
