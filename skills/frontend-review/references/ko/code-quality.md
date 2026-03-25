# ③ 코드 품질 리뷰

변경된 파일을 읽고 AI가 판단한다.

## 일반 체크리스트

- [ ] 코드가 쉽게 이해되는가?
- [ ] 기존 패턴/기술과 일치하는가?
- [ ] DRY — 2번 이상 중복된 코드 없는가?
- [ ] 함수/클래스/컴포넌트 크기가 합리적인가?
- [ ] 이벤트 리스너가 teardown 시 제거되는가?
- [ ] 관심사 분리(SoC)가 지켜지는가?

## ES6+ 체크리스트

- [ ] `const` > `let` (var 금지)
- [ ] 구조 분해 할당 사용
- [ ] Promise/Async-Await + 적절한 rejection 처리

## React 체크리스트

> `package.json`에 `react`가 있을 때만 적용. React 프로젝트가 아니면 이 섹션을 건너뛴다.

- [ ] 컴포넌트 크기 합리적인가? (200~300줄 이하, JSX 50줄 이하)
- [ ] 상태 없는 로직은 함수형 컴포넌트 사용
- [ ] 루프 내 state 업데이트 없음
- [ ] render 내 로직 최소화

## React 안티패턴 감지

| 안티패턴 | 감지 방법 | 심각도 |
|---------|----------|--------|
| **Prop Drilling** | 3단계 이상 같은 prop이 전달되는 패턴 | ❌ FAIL |
| **직접 state 변경** | `state.value = x` 패턴 | ❌ FAIL |
| **과도한 state** | 파생 가능한 값을 state로 관리 | ❌ FAIL |
| **render 내 함수 재생성** | 이벤트 핸들러 인라인 정의 (자식에 전달 시) | ⚠️ WARNING |
| **useEffect 내 데이터 변환** | fetch + transform이 하나의 useEffect에 | ⚠️ WARNING |
| **파생 state 저장** | `fullName = first + last`를 useState로 | ❌ FAIL |
| **중복 로직 생성** | 이미 존재하는 유틸과 유사한 함수 | ⚠️ WARNING |

## CSS 체크리스트

- [ ] `!important` 사용 안 함
- [ ] 인라인 스타일 사용 안 함 (스타일 컴포넌트/CSS Modules 사용)
- [ ] 애니메이션은 `transform`/`opacity` 사용 (width/height/top/left 대신)

## 판정 기준

- ❌ FAIL 항목이 하나라도 있으면 이 단계는 FAIL
- ⚠️ WARNING만 있으면 PASS (경고 기록)
