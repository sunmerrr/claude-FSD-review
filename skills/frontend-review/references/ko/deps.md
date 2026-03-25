# ⑧ 의존성/배포 안전성

새로 추가되거나 변경된 의존성의 안전성을 검증한다.

## 감지 대상

- `package.json`의 `dependencies`, `devDependencies` 변경
- lock 파일 (`yarn.lock`, `pnpm-lock.yaml`, `package-lock.json`) 변경
- 새로운 `import`/`require` 구문 (기존에 없던 패키지)

> `package.json` 또는 lock 파일 변경이 없고, 새 import도 없으면 ⊘ SKIP.

## 체크리스트

### 새 라이브러리 추가 시
- [ ] 유지보수 상태 확인 — 마지막 업데이트가 1년 이상 전이면 경고
- [ ] 주간 다운로드 수 — 극히 적으면 (< 1,000/주) 경고
- [ ] 기존 의존성과 기능 중복 여부 — 이미 있는 라이브러리로 해결 가능한가?
- [ ] 번들 사이즈 영향 — 대형 라이브러리 추가 시 (bundlephobia 기준) 경고
- [ ] 라이선스 호환성 — GPL 등 제한적 라이선스 여부

### 버전 업그레이드 시
- [ ] 메이저 버전 변경인가? → breaking change 확인 필요
- [ ] changelog / migration guide 확인 여부
- [ ] peer dependency 충돌 없는가?

### lock 파일
- [ ] lock 파일 변경이 의도된 것인가? (의존성 변경 없이 lock만 바뀌면 의심)
- [ ] lock 파일이 커밋에 포함되어 있는가?

## 판정 기준

| 이슈 | 심각도 |
|------|--------|
| 유지보수 중단된 라이브러리 추가 | ❌ FAIL |
| 기존 의존성과 기능 중복 | ⚠️ WARNING |
| 메이저 버전 업그레이드 (breaking change) | ⚠️ WARNING |
| 대형 번들 추가 (> 50KB gzipped) | ⚠️ WARNING |
| GPL 라이선스 | ⚠️ WARNING |
| 의도 불명확한 lock 파일 변경 | ⚠️ WARNING |
