# ② 아키텍처 리뷰 (Feature-Sliced Design)

FSD 아키텍처 준수 여부를 검증한다. FSD 구조가 아닌 프로젝트는 이 단계를 건너뛴다.

## FSD 감지

아래 디렉토리 중 3개 이상 존재하면 FSD 프로젝트로 판단:
- `app/`, `pages/`, `widgets/`, `features/`, `entities/`, `shared/`
- `src/app/`, `src/pages/`, `src/widgets/`, `src/features/`, `src/entities/`, `src/shared/`

## FSD 7개 레이어 (상위 → 하위)

```
app        ← 최상위: 라우팅, 프로바이더, 글로벌 설정
pages      ← 페이지 단위 조합
widgets    ← 자기 완결형 큰 기능 블록
features   ← 재사용 가능한 제품 기능
entities   ← 비즈니스 엔티티 (user, product)
shared     ← 최하위: 유틸, UI 킷, 타입
```

## 체크리스트

### 의존성 방향 (핵심)
- [ ] **상위 → 하위만 허용**: features는 entities, shared를 import 가능. entities는 features를 import 불가.
- [ ] **같은 레이어 간 import 금지**: features/A가 features/B를 직접 import하면 위반.

허용되는 의존성 방향:
```
app → pages → widgets → features → entities → shared
         ↘      ↘         ↘          ↘
          shared  shared    shared     shared
```

### public API 접근
- [ ] 슬라이스 내부 파일에 직접 접근하지 않는가? (`features/auth/model/store.ts` 대신 `features/auth`로 import)
- [ ] 각 슬라이스에 `index.ts` (barrel export)가 존재하는가?

### 비즈니스 로직 배치
- [ ] API 호출이 적절한 레이어에 있는가? (shared/api 또는 entities/*/api)
- [ ] UI 컴포넌트에 비즈니스 로직이 섞여있지 않은가?
- [ ] shared 레이어에 비즈니스 로직이 포함되어 있지 않은가?

## 판정 기준

| 이슈 | 심각도 |
|------|--------|
| 하위 → 상위 import (역방향) | ⚠️ WARNING (자동 수정 안 함, 문서에 경고) |
| 같은 레이어 간 직접 import | ⚠️ WARNING |
| public API 우회 접근 | ⚠️ WARNING |
| shared에 비즈니스 로직 | ⚠️ WARNING |

> 아키텍처 위반은 모두 WARNING으로 처리한다. 자동 수정하지 않고 review 문서에 경고로 남긴다.
