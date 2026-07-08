# Evidence Policy

## Allowed Claims

- Claim UVM/SVA/coverage intent only when source files exist and are linked.
- Claim a test or regression passed only when a log with command, test name, seed if applicable, and result exists.
- Claim coverage numbers only from simulator-generated coverage output.
- Claim waveform/debug evidence only when waveform screenshot, VCD/FST, or annotated trace exists.

## Forbidden Without Evidence

- `full coverage`
- `sign-off`
- `production-ready`
- `industry-grade`
- `100% coverage`

## Review Checklist

- README evidence map links exist.
- vPlan maps requirement to test, checker/assertion, coverage, and evidence.
- Bug notes separate DUT bug, testbench bug, checker bug, stimulus bug, and environment/config bug.
- Limitations are explicit when using open-source smoke tests instead of commercial UVM regression.
