# Latency And Error Propagation Notes

## Latency Rule

The bridge must not return AXI `B` or `R` response before the corresponding APB access completes. APB completion is defined by `psel && penable && pready`.

## Error Rule

When APB reports `pslverr=1`, the bridge must map the failure into the matching AXI response channel for that transaction.

## Tests To Keep Separate

| Test | Purpose |
|---|---|
| `bridge_smoke_test` | prove one legal write/read path |
| `bridge_random_rw_test` | exercise valid register addresses |
| `bridge_error_test` | prove invalid APB target propagates error |
| `bridge_wait_state_test` | prove delayed `pready` stalls AXI response |

## Common Bug Classes

- returning AXI response before APB `pready`;
- losing write data when AW and W arrive in different cycles;
- sampling `prdata` before APB access completion;
- mapping APB error to the wrong AXI channel;
- scoreboard assuming zero-wait latency.
