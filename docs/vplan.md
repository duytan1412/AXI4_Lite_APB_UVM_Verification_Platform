# Verification Plan — AXI4-Lite to APB Bridge

## Scope

Verify an AXI4-Lite slave front-end that converts register accesses into APB transfers targeting a small GPIO-style APB peripheral.

## Requirement Traceability

| ID | Requirement | Test | Coverage | Assertion / Check | Evidence |
|---|---|---|---|---|---|
| REQ-RESET-01 | Reset returns bridge FSM to idle and deasserts APB controls | `bridge_smoke_test` | reset transition bin | reset control check | `sim_results/regression_summary.txt` |
| REQ-WR-01 | AXI write address/data produces one APB write transfer | `bridge_smoke_test`, `bridge_random_rw_test` | write x address bins | APB setup/access sequencing | planned full UVM log |
| REQ-RD-01 | AXI read address produces one APB read transfer and returns data | `bridge_smoke_test`, `bridge_random_rw_test` | read x address bins | APB read data stability | planned full UVM log |
| REQ-ERR-01 | Invalid APB address returns an error response | `bridge_error_test` | error response bin | PSLVERR to AXI response mapping | planned full UVM log |
| REQ-WAIT-01 | APB wait states stall AXI response until completion | `bridge_wait_state_test` | wait-state length bins | no early B/R response | planned full UVM log |
| REQ-COV-01 | Coverage model observes direction, address, response, wait state, and reset | all tests | covergroups in `bridge_coverage` | coverage sampling hooks | `docs/coverage_report.txt` |

## Test Intent

- `bridge_smoke_test`: minimal write/read path to prove the harness is connected.
- `bridge_random_rw_test`: random aligned accesses across valid registers.
- `bridge_error_test`: out-of-map address and error response propagation.
- `bridge_wait_state_test`: delayed `pready` with stable APB controls.

## Closure Criteria

- All planned tests complete with zero UVM errors.
- Functional coverage bins for valid addresses, read/write directions, OKAY/error responses, and wait states are hit.
- Assertions report zero failures.
- Any waived item is documented in `docs/bug_log.md`.

## Current Status

This is a portfolio-ready verification platform skeleton with RTL, UVM structure, vPlan, coverage intent, and CI RTL lint. Full numerical closure requires running the regression on VCS/Xcelium/Questa and archiving the generated reports.
