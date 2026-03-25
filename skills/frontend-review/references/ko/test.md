# ⑦ 테스트 리뷰

테스트를 실행하고, 테스트 코드의 품질도 리뷰한다.

## 테스트 실행

```bash
{pkg-manager} run test  # 또는 npx vitest run / npx jest
```

- 테스트 스크립트가 없거나 테스트 파일이 없으면 `⊘ SKIP (테스트 없음)` → 종료
- 테스트 실패 시 ❌ FAIL (실패한 테스트 목록 포함)
- 모든 테스트 통과 시 → 테스트 코드 품질 리뷰 진행

## 테스트 코드 품질 체크리스트

변경된 파일과 관련된 테스트 파일(`*.test.*`, `*.spec.*`)을 대상으로:

### 테스트 설계
- [ ] 테스트가 **동작**(behavior)을 검증하는가? (구현 세부사항이 아닌)
  - Bad: `expect(component.state.count).toBe(1)`
  - Good: `expect(screen.getByText('1')).toBeInTheDocument()`
- [ ] 테스트 이름이 설명적인가?
  - Bad: `it('works')`
  - Good: `it('사용자가 제출 버튼을 클릭하면 폼이 전송된다')`
- [ ] 하나의 테스트에 하나의 관심사만 검증하는가?

### 테스트 구현
- [ ] 테스트 내부에 로직(if/for/switch)이 없는가?
- [ ] mock은 외부 의존성에만 사용하는가? (내부 구현 mock 금지)
- [ ] 비동기 테스트에 적절한 대기(`waitFor`, `findBy`) 사용
- [ ] `setTimeout`으로 대기하지 않는가? (flaky test 원인)

### 커버리지
- [ ] 엣지 케이스 커버 (빈 배열, null, undefined, 긴 문자열, 특수문자)
- [ ] 에러 시나리오 테스트 (네트워크 에러, 유효성 검증 실패 등)
- [ ] 해피 패스 + 새드 패스 모두 커버

## 판정 기준

| 이슈 | 심각도 |
|------|--------|
| 테스트 실행 실패 | ❌ FAIL |
| 구현 세부사항 테스트 | ⚠️ WARNING |
| 테스트 내 로직 (if/for) | ⚠️ WARNING |
| setTimeout 대기 | ⚠️ WARNING |
| 내부 구현 mock | ⚠️ WARNING |
| 엣지 케이스 미커버 | ⚠️ WARNING |

> 테스트 코드 품질 이슈는 WARNING으로 처리한다. 테스트 실행 실패만 FAIL.
