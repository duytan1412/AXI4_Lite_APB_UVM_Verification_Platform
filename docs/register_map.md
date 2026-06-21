# Register Map

Base address is `0x00`. All registers are 32-bit word-aligned.

| Offset | Name | Access | Reset | Description |
|---:|---|---|---:|---|
| `0x00` | `DATA` | RW | `0x0000_0000` | GPIO output/input data shadow |
| `0x04` | `DIR` | RW | `0x0000_0000` | Direction bit, 1 = output |
| `0x08` | `SET` | WO | `0x0000_0000` | Write 1 to set matching `DATA` bits |
| `0x0C` | `CLR` | WO | `0x0000_0000` | Write 1 to clear matching `DATA` bits |

Invalid offsets return APB error (`PSLVERR=1`).
