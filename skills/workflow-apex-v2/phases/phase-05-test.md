---
name: phase-05-test
description: Analyze test patterns, create tests, run until green
prev_phase: ./phase-04-review.md
next_phase: conditional (06-ship | complete)
---

# Phase 05: Test

Execute test strategy and validate implementation against test suite until green.

**Role:** Test engineer designing tests and resolving failures

---

## Part A: Analyze & Plan

1. **Mark phase in progress**
   - Update progress table in `{output_dir}/00-context.md`
   - Set phase 05 status to "In Progress"

2. **Detect test framework**
   - Read `package.json` dependencies and devDependencies
   - Scan for test runners: vitest, jest, mocha, playwright, cypress, testing-library
   - Check project root for config files:
     - `jest.config.js` / `jest.config.ts`
     - `vitest.config.ts` / `vitest.config.js`
     - `playwright.config.ts`
     - `cypress.config.js`
     - `mocha.opts` / `.mocharc.json`
   - Identify test command in `package.json` scripts (typically `test`, `test:unit`, `test:e2e`, `test:integration`)
   - Document detected framework in session log

3. **Analyze test infrastructure**
   - Check for test helpers/utilities in `test/`, `__tests__/`, `.spec.ts` files
   - Identify setup files: `setupTests.ts`, `jest.setup.js`, `vitest.setup.ts`
   - Look for common mocking patterns: jest.mock(), vi.mock(), sinon stubs
   - Find test data fixtures in `__fixtures__/`, `test-data/`, or inline factories
   - Check for environment variables needed (`.env.test`, `.env.test.local`)

4. **Read 2-3 similar test files**
   - Select existing tests covering similar code paths (API route, service, component, utility)
   - For each file, note:
     - Test structure: `describe()` / `it()` vs `test()`
     - Setup patterns: `beforeEach()`, `beforeAll()`, mock initialization
     - Assertion library: expect, assert, chai
     - Mocking approach: function mocks, service mocks, external API stubs
     - Test data: factories, fixtures, inline objects
     - Cleanup: afterEach(), cleanup(), custom teardown

5. **Determine test strategy**
   - Use strategy selection matrix based on implementation type:
     ```
     Code Type              | Primary Test     | Secondary
     API route             | Integration      | E2E
     Service/Middleware    | Integration      | Unit
     Logic/Utility func    | Unit             | -
     React component       | Component        | Integration (if state/context)
     Full feature          | Integration      | E2E
     Database operations   | Integration      | -
     ```
   - Decide: unit tests only, integration, component tests, or E2E
   - Estimate test count needed for coverage

6. **Document strategy**
   - Create `{output_dir}/05-test.md` with sections:
     - Framework detected + version
     - Test types selected + rationale
     - List of test files to create
     - Key patterns observed from existing tests

---

## Part B: Create Tests

7. **Create test files following existing patterns**

   For each test file to create:

   a) **Identify test location**
      - Follow project convention: `{src_file}.spec.ts` or `__tests__/{src_file}.test.ts`
      - Create test file in same directory as source (or `__tests__` parallel dir)

   b) **Write test file with pattern matching**
      - Use exact describe/it structure from similar test
      - Copy assertion style (expect().toBe() vs expect().toEqual() etc.)
      - Replicate mock patterns and setup from analyzed files
      - Use same test data approach (factories, fixtures, or inline objects)

   c) **Concrete code example**
      ```typescript
      // From existing tests, observe:
      // - import statements (test framework, utilities, types)
      // - mock declarations with vi.mock() or jest.mock()
      // - describe block wrapping
      // - beforeEach/afterEach hooks

      import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
      import { myFunction } from './myFunction';

      vi.mock('./dependency', () => ({
        dependencyFn: vi.fn(() => 'mocked'),
      }));

      describe('myFunction', () => {
        beforeEach(() => {
          vi.clearAllMocks();
        });

        it('returns expected result for valid input', () => {
          const result = myFunction('input');
          expect(result).toBe('expected');
        });

        it('handles error case', () => {
          expect(() => myFunction(null)).toThrow();
        });
      });
      ```

   d) **Create complete test file**
      - Read source file being tested
      - Create test imports, mocks, describe block
      - Add 2-4 test cases covering: happy path, edge cases, error handling
      - Verify syntax is valid (no parsing errors)

8. **Log progress**
   - Append to `{output_dir}/05-test.md`:
     - Test file created: [path]
     - Test count: [N cases]
     - Framework used: [vitest/jest/mocha]

---

## Part C: Test Loop

9. **Run test suite**
   ```bash
   # Use detected package manager from phase 03
   {PM} run test
   # OR for specific files:
   {PM} run test -- path/to/test.spec.ts
   ```
   For non-Node.js projects, use the stack-equivalent command (see phase-03 toolchain table).

10. **Analyze failures (detailed failure analysis)**

    For each failing test:

    a) **Read test output carefully**
       - Capture full error message and stack trace
       - Identify assertion that failed
       - Check for timeout, syntax, or runtime error

    b) **Classify failure type**
       - **Code bug:** Source code has incorrect logic, missing implementation, or type mismatch
       - **Test bug:** Test case is wrong - incorrect assertion, bad mock setup, or test logic error
       - **Config issue:** Framework config missing, environment variable needed, or service not running
       - **Transient:** Race condition or timing issue in test execution

    c) **Root cause analysis**
       - If code bug: read source file → identify missing logic
       - If test bug: read test case → check mock setup, assertion logic
       - If config: check jest/vitest config, environment variables, service health
       - Print relevant code snippets in session log

    d) **Fix and retry**
       - Fix identified root cause
       - Commit fix: `git add -u && git commit -m "apex({task_id}): test fix - {brief}" || true`
       - Re-run test

11. **Stuck handling (3x same failure)**

    - Track failure counts per test case
    - If same test fails 3 times with same error:
      - Log warning: `WARNING: Test '{test_name}' failed 3x with error: {error_msg}`
      - Skip test with comment: `it.skip('...', ...)`
      - Document in session: "Skipped due to {reason}"
      - Proceed with remaining tests
      - Do NOT attempt further fixes on that test

12. **Success criteria**
    - All created tests pass (or legitimately skipped with warning)
    - Test output shows: "N passed, 0 failed" (excluding skipped)
    - Max 10 attempts per test file

13. **Document test loop**
    - Append to `{output_dir}/05-test.md`:
      - Attempt log: [Attempt N: {failure description} → {fix applied}]
      - Final results: [✅ All tests passing (N/N)]
      - Any skipped tests with reasons

---

## Part D: Service Management

14. **Detect required services**
    - Check if tests need external services (database, Redis, API servers)
    - Look for test setup/teardown code that starts services
    - Check `.env.test` or test config for service endpoints
    - Common: PostgreSQL, MySQL, MongoDB, Redis, Docker containers

15. **Start services**
    - If using Docker Compose: `docker-compose up -d`
    - If using test containers (testcontainers, Playwright Server): auto-managed by framework
    - Track PIDs of manually started services: `echo $! > .test-pids`
    - Verify service health before running tests

16. **Cleanup background services**
    - After all tests complete (pass or fail):
      ```bash
      # Kill tracked PIDs
      [ -f .test-pids ] && cat .test-pids | xargs kill -9 2>/dev/null || true

      # Stop Docker services
      docker-compose down 2>/dev/null || true

      # Kill any lingering test servers
      lsof -ti:3000,5432,6379 | xargs kill -9 2>/dev/null || true
      ```
    - Verify cleanup: no zombie processes left
    - Document in session: "Services cleaned up"

---

## Part E: Complete & Route

17. **Mark phase complete**
    - Update `{output_dir}/00-context.md` phase table
    - Set phase 05 status to "Complete"

18. **Save session**
    - Finalize `{output_dir}/05-test.md` with:
      - Framework + strategy summary
      - Test files created
      - Attempt log (if any failures)
      - Final test results (all passed, skipped count, error count)
      - Service cleanup status

19. **Commit phase work**
    ```bash
    IF branch_mode:
      git add -u && git commit -m "apex({task_id}): add tests" || true
    ```

20. **Determine next phase**
    ```
    IF pr_mode: → phase-06-ship
    ELSE: → complete
    ```

21. **Check pause mode**
    - IF pause_mode: Run `scripts/session-boundary.sh` and STOP
    - ELSE: Proceed to next phase immediately

---

## Recovery (Resume)

If resuming from phase 05 crash:
- Read `{output_dir}/00-context.md` to restore flags and context
- Check `{output_dir}/05-test.md` for last-completed test file
- Resume creating remaining test files
- Re-run full test suite before routing
- Resume from step where crash occurred (analysis, creation, or test loop)
