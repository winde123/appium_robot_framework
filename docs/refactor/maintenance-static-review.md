# Maintenance refactors — static review and handoff

> Implementation and independent review of the six maintenance suggestions approved on 2026-09-06, separate from the SGAC fork-migration tasks.

- Status: Static review complete; implementation prepared for dev-lead integration, not merged
- Last reviewed: 2026-09-06
- Implementation: Four OpenCode 1.18.20 workers using `moonshotai/kimi-k2.7-code`
- Reviewer and coordinator: Codex

## Outcome and scope

No blocking static findings remain in the reviewed change set. Codex reviewed the worker diffs, requested corrections, reviewed those corrections, and independently ran the combined device-free checks. This is not a claim of live-device acceptance.

| Task | Implemented scope | Focused unit tests |
| --- | --- | --- |
| [M01](../../todo/done/m01-portable-reproducible-test-data.md) | Portable cargo-file loading with the existing 100-permit minimum; explicit per-test profile records and seed/reference-date/country replay; migration of active callers | 46 passed |
| [M02](../../todo/done/m02-helpers-import-safe-tools.md) | Helper contracts and boundary validation; import-safe QR/date examples with compatibility entry points | 45 passed |
| [M03](../../todo/done/m03-eservices-templates.md) | Shared iOS e-services template with original case mappings, assertions, and action order retained | 16 passed |
| [M04](../../todo/done/m04-bounded-interaction-waits.md) | Configurable readiness polling for the existing click/type keywords, single execution of each action, and implicit-wait restoration | 57 passed |

Overlapping suggestions were grouped into four exclusive worker scopes. Workers used isolated worktrees and made no commits, merges, or pushes. Codex combined their changes in a separate review worktree, synchronized affected `CLAUDE.md` guidance and the documentation index, and corrected one helper doctest's expected `timedelta` representation. Existing concurrent fork-migration work was not overwritten.

## Findings corrected before acceptance

| Priority | Finding in a worker revision | Correction and regression evidence |
| --- | --- | --- |
| High | The template interpolated a locator into a quoted Python condition. The existing `Apply for Student's Pass` locator caused a runtime syntax error that dry runs did not catch. | Uses Robot's `$header_locator` expression variable. Actual resource-execution tests cover apostrophes, quotes/backslashes, empty headers, and ordered single execution. |
| High | Wait handling could overwrite session state or silently guess an unreadable implicit wait. A setter can also apply a value before raising. | Requires a readable prior value; guarded restoration runs on success and failure, including partial initial-set failures. Fake-driver tests cover read/set/restore failures and exception chaining. |
| Medium | Invalid wait values could silently select defaults; environment overrides did not reach the public Robot keywords; late results could bypass the deadline. | Defaults apply only to omitted values; invalid/non-finite inputs are rejected; actual `commands.robot` execution tests verify environment wiring; fake-clock tests verify monotonic deadline handling. Invalid-session errors propagate. |
| Medium | Profile migration initially left incomplete explicit-data flow and replay metadata, changed the standalone CLI's car-registration output, and modified global import search order. | Both resident helpers accept, use, and return an explicit record while preserving no-argument callers. Seed/date/country validation and replay tests include real Robot execution with stubbed UI keywords; original CLI field semantics and import-path isolation are preserved. |
| Medium | Helper revisions changed valid fractional-duration behavior and allowed non-integral chunk sizes to be truncated. | Compatibility and boundary tests cover fractional durations, integral versus fractional numeric inputs, named arguments, in-place reversal, and exact date formatting. |
| Medium | Template execution tests shadowed/deleted `AppiumLibrary` modules and depended on the old wait implementation. They passed alone but failed when combined with M04. | Suite-level UI overrides record high-level template actions without replacing AppiumLibrary. All 164 tests pass together and in reverse file order with the real AppiumLibrary pre-imported; pre-existing module identities remain intact. |

## Independent validation

Validation was run on the combined review worktree, based on `e7a15f1c1d339af7b1d06efa5a3cd2c8fcc1bba1`:

| Check | Result |
| --- | --- |
| Full `tests/unit` suite | 164 passed |
| Reverse unit-file order with real AppiumLibrary pre-imported | 164 passed; no pre-existing AppiumLibrary modules replaced or removed |
| SGAC1 Robot dry run | 66 passed, 0 failed |
| SGAC2 Robot dry run | 66 passed, 0 failed |
| Original versus reviewed suite inventory | 66 tests each; no test-name, tag, setup, or teardown changes |
| Strict fork-parity check | 0 errors, 0 warnings; 230 existing intentional divergences suppressed by the repository allowlist |
| Helper doctests and `git diff --check` | Passed |
| Reviewed patch applicability | `git apply --check` passed against main at `ab2cefe2465e8f301a11570eef99e55eb08b6378` |

The workers started from `738fcda61f63ee2d8bcefaa59ddf826e35dd46f2`, which had seven pre-existing locator-parity findings. The newer integration baseline incorporates the dev lead's intervening fork-migration changes and allowlist. The maintenance patch does **not** modify locator trees, the parity checker, or its allowlist; the passing combined gate must not be attributed to maintenance fixes to those files.

Environment used: Python 3.13.3, Robot Framework 7.4, AppiumLibrary 3.2.1, Appium Python Client 5.2.4, Selenium 4.39.0, Faker 39.0.0, pytest 9.0.2. Existing dependencies were reused; none were installed.

To repeat the main checks from a checkout containing the patch, set `PROJECT_PYTHON` to that project's existing virtualenv interpreter:

```sh
PROJECT_PYTHON=/path/to/repo/venv/bin/python
"$PROJECT_PYTHON" -B -m pytest -q -p no:cacheprovider tests/unit
"$PROJECT_PYTHON" -B -m doctest Resources/helper_func.py
APP_FORK=sgac1 "$PROJECT_PYTHON" -B -m robot --dryrun --output NONE --log NONE --report NONE tests
APP_FORK=sgac2 "$PROJECT_PYTHON" -B -m robot --dryrun --output NONE --log NONE --report NONE tests
"$PROJECT_PYTHON" -B tools/check_fork_parity.py --strict
git diff --check
```

## Integration handoff

The durable [reviewed patch](../../todo/artifacts/maintenance-refactors-2026-09-06.patch) contains 43 implementation, test, and documentation files. It does not include this report or the canonical task records, which already reside in the main checkout.

- Patch SHA-256: `0509012d5dfa3ef9def758485f08c673ce80ed4431680aa1d80523e7ae00dae3`
- Review worktree: `/private/tmp/sgac-maintenance.BUsYX8/integrated`
- Review branch: `refactor/maintenance-reviewed`
- Implementation is an **uncommitted working-tree diff**, not a commit on that branch. The patch is the durable copy if temporary worktrees are removed.
- Worker worktrees and local run logs are under `/private/tmp/sgac-maintenance.BUsYX8/` (`data`, `utilities`, `templates`, `waits`).

The dev lead should review the patch, recheck applicability against the then-current checkout, integrate it through the repository's normal ownership/merge process, and rerun the checks above. Do not both apply the patch and copy the same worker changes. Commit/merge/push authority remains with the dev lead under the [fork-refactor workflow](sgac-fork-refactor-tasks.md).

## Remaining validation limits

- No Appium sessions, physical devices, simulators, remote portals, or Device Farm runs were used. Device Farm/T12 and the ongoing fork tasks remain outside this work.
- Ignored APK binaries are absent from the isolated review worktree. Its dry-run missing-APK warnings are expected; dry runs validate Robot structure and imports, not installation or UI behavior.
- The wait helper now requires visible and enabled elements. Android and iOS smoke tests should confirm those driver-reported states for representative controls before accepting the behavior on devices. Polling has a deadline; remote HTTP requests, state restoration, and the subsequent action are not hard-cancelled by it.
- Profile replay requires the same seed, reference date, country, Faker version, and locale. Normal Robot argument/return logging can expose synthetic profile values; the helper's metadata log is not a promise of global log redaction.
- QR generation is tested with a mocked backend. The optional treepoem/Pillow/Ghostscript setup and actual barcode output were not exercised.

The requested implementation and static-review tasks are complete. Integration and live-device acceptance remain explicit follow-up work for the dev lead.
