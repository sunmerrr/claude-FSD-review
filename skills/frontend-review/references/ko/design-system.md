# ④ 디자인 시스템 준수 여부 체크

디자인 시스템이 있는 프로젝트에서, 변경된 코드가 디자인 시스템을 올바르게 사용하는지 검증한다.

## 디자인 시스템 감지

아래 중 하나라도 존재하면 디자인 시스템 있음으로 판단:
- 디자인 토큰 파일: `tokens.ts`, `theme.ts`, `variables.css`, `design-tokens.*`
- UI 라이브러리 디렉토리: `shared/ui/`, `components/ui/`, `design-system/`
- 테마 설정: `tailwind.config.*`의 커스텀 테마, `styled-components` 테마

감지되지 않으면 ⊘ SKIP.

## 체크리스트

### 디자인 토큰 사용

- [ ] 하드코딩된 색상값 없는가? (`#fff`, `rgb(...)`, `hsl(...)` → 토큰 사용)
- [ ] 하드코딩된 폰트 사이즈 없는가? (`14px`, `1.2rem` → 토큰 사용)
- [ ] 하드코딩된 간격값 없는가? (`8px`, `16px` → 토큰 사용)
- [ ] 하드코딩된 border-radius 없는가? → 토큰 사용
- [ ] 하드코딩된 shadow 없는가? → 토큰 사용

> Tailwind 프로젝트: `tailwind.config`에 정의된 커스텀 값 사용 여부 체크. arbitrary value (`text-[14px]`)가 반복되면 경고.

### 컴포넌트 일관성

- [ ] 디자인 시스템에 이미 존재하는 컴포넌트를 직접 구현하지 않았는가?
  - 예: `shared/ui/Button`이 있는데 `<button className="...">` 직접 사용
- [ ] 디자인 시스템 컴포넌트의 variant/props를 올바르게 사용하는가?
- [ ] 커스텀 스타일 오버라이드가 과도하지 않은가? (오버라이드가 많으면 variant 추가 제안)

## 판정 기준

| 이슈 | 심각도 |
|------|--------|
| 하드코딩 색상/폰트/간격 (1~2개) | ⚠️ WARNING |
| 하드코딩 색상/폰트/간격 (3개+) | ❌ FAIL |
| 기존 컴포넌트 무시하고 직접 구현 | ❌ FAIL |
| 과도한 스타일 오버라이드 | ⚠️ WARNING |
| Tailwind arbitrary value 반복 (3회+) | ⚠️ WARNING |
