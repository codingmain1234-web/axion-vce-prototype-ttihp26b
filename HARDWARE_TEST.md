# AXION Gen0 hardware test procedure

Use this procedure only after RTL, GDS, precheck, gate-level, timing, and area
checks have passed. The target clock for first-silicon bring-up is 10 MHz.

## Control byte

| Bit | Name | Meaning |
|---|---|---|
| 2:0 | OP | operation code |
| 3 | LOAD_A | capture `ui_in` into A on the next rising edge |
| 4 | LOAD_B | capture `ui_in` into B on the next rising edge |
| 5 | EXECUTE | execute OP on the next rising edge |
| 6 | CLEAR_ACC | clear the SA accumulator on the next rising edge |
| 7 | OUT_SEL | 0: result register, 1: raw accumulator low byte |

For every command, present `ui_in` and `uio_in`, pulse one rising clock edge,
then return `uio_in` to zero. Do not load an operand and execute in the same
cycle; execution intentionally uses the previously stored A and B values.

## Bring-up sequence

1. Hold `rst_n=0` for at least two rising edges, then set `rst_n=1`.
2. Confirm `uo_out=0`, `uio_out=0`, and `uio_oe=0`.
3. Load A=5 with control `0x08`.
4. Load B=3 with control `0x10`.
5. Execute ADD with control `0x20`; expect `uo_out=8`.
6. Execute MUL-low with control `0x22`; expect `uo_out=15`.
7. Clear the SA accumulator with control `0x40`.
8. Execute signed MAC with control `0x26`; expect `uo_out=15`.
9. Set control `0x80` without a clock requirement; expect raw low byte 15.
10. Load A=`0xFE` (-2), load B=4, and execute MAC (`0x26`); expect 7.
11. Execute ReLU/read with control `0x27`; expect 7.
12. Clear, load A=100 and B=2, then execute MAC; expect saturated result 127.
13. Set `OUT_SEL=1`; expect raw low byte 200.
14. Clear, load A=`0xFC` (-4) and B=2, then execute MAC; expect ReLU result 0.
15. Set `OUT_SEL=1`; expect raw low byte `0xF8`.

Record the board, shuttle/chip identifier, supply voltage, clock frequency,
temperature, every observed byte, and whether reset was applied before the run.
