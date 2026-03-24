# ⑤ 웹 품질 리뷰 (접근성 + 성능 + SEO)

코드 레벨에서 자동 감지 가능한 항목만 체크한다. Lighthouse 실행이나 브라우저 테스트는 포함하지 않는다.

## 접근성 (A11y)

### 코드에서 감지 가능한 항목
- [ ] `<img>`에 `alt` 속성 누락
- [ ] 빈 버튼/링크 (`<button></button>`, `<a></a>`)
- [ ] `<a>` 태그에 `href` 누락
- [ ] 잘못된 ARIA 속성 사용 (`aria-*` 오타, 잘못된 role)
- [ ] heading 순서 건너뛰기 (`h1` → `h3`)
- [ ] `tabIndex` > 0 사용 (접근성 안티패턴)
- [ ] 폼 요소에 `label` 연결 누락
- [ ] 클릭 이벤트만 있고 키보드 이벤트 없는 비인터랙티브 요소

## 성능

### 코드에서 감지 가능한 항목
- [ ] LCP 후보 이미지에 `loading="lazy"` 사용 (뷰포트 내 이미지에 lazy는 안티패턴)
- [ ] 이미지에 `width`/`height` 또는 `aspect-ratio` 누락 (CLS 유발)
- [ ] 대형 라이브러리 barrel import (`import { x } from 'lodash'` → `import x from 'lodash/x'`)
- [ ] `useEffect` 내 불필요한 state 업데이트 (리렌더 유발)
- [ ] `useMemo`/`useCallback` 없이 자식에 객체/함수 전달 (매 렌더마다 새 참조)
- [ ] 동적 import 미사용 (큰 컴포넌트를 정적 import)
- [ ] `next/image` 대신 `<img>` 직접 사용 (Next.js 프로젝트)

## SEO (Next.js/SSR 프로젝트)

### 코드에서 감지 가능한 항목
- [ ] 페이지 컴포넌트에 `metadata` export 또는 `<Head>` 누락
- [ ] Open Graph / Twitter Card 메타 태그 누락
- [ ] `canonical` URL 미설정
- [ ] `next/image` 대신 `<img>` 사용 (alt 텍스트 누락 포함)
- [ ] CSR 전용 페이지에 `noindex` 미설정

> SSR/SSG 프레임워크가 아닌 SPA 프로젝트는 SEO 항목을 건너뛴다.

## 판정 기준

| 이슈 | 심각도 |
|------|--------|
| `alt` 누락, 빈 버튼/링크 | ❌ FAIL |
| ARIA 오류, heading 순서 | ❌ FAIL |
| 이미지 width/height 누락 | ⚠️ WARNING |
| barrel import | ⚠️ WARNING |
| lazy 이미지 오용 | ⚠️ WARNING |
| 메타데이터 누락 | ⚠️ WARNING |
| `<img>` 직접 사용 (Next.js) | ⚠️ WARNING |
