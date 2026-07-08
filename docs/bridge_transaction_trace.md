# AXI4-Lite To APB Transaction Trace

## Purpose

This capstone proves cross-bus reasoning: one AXI4-Lite register access must produce a matching APB transfer and a matching AXI response.

## Write Path

| Step | AXI4-Lite side | Bridge/APB side | Check |
|---|---|---|---|
| 1 | Accept `AW` address | capture target APB address | address alignment and decode |
| 2 | Accept `W` data/strobes | capture write payload | byte-enable policy matches register map |
| 3 | Start APB setup | `psel=1`, `penable=0` | APB setup phase appears once |
| 4 | Start APB access | `psel=1`, `penable=1`, `pwrite=1` | controls stable until `pready` |
| 5 | APB completes | observe `pready`/`pslverr` | no early AXI response |
| 6 | Return AXI `B` | map APB error to AXI response | scoreboard compares expected response |

## Read Path

| Step | AXI4-Lite side | Bridge/APB side | Check |
|---|---|---|---|
| 1 | Accept `AR` address | capture target APB address | address alignment and decode |
| 2 | Start APB setup | `psel=1`, `penable=0`, `pwrite=0` | setup before access |
| 3 | Start APB access | wait for `pready` | no early read response |
| 4 | APB completes | capture `prdata`/`pslverr` | stable data at completion |
| 5 | Return AXI `R` | return data and response | scoreboard compares data/response |

## Evidence Needed

- Regression log with test name and result.
- Transaction log showing AXI request, APB transfer, and AXI response.
- Waveform around at least one write and one read transfer.
- Coverage report before claiming numeric closure.
