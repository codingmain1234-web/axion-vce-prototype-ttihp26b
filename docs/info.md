# AXION VCE Prototype

This is a minimum-area first-silicon prototype of the AXION GPU architecture.

## What is inside?

- One **VCE (Vector Compute Engine)**
- One tiny **V-Core** ALU
- One **SA-Core (Special AI Core)**
- 8-bit external data path
- Signed INT8 multiply-accumulate for AI-style arithmetic

This is **not a complete display GPU**. It is the smallest practical silicon experiment intended to validate the compute-core concept before building a much larger architecture.

## Interface

`ui_in[7:0]` is the input data byte.

`uio_in` controls the core:

| Bit | Function |
|---|---|
| 2:0 | opcode |
| 3 | load A |
| 4 | load B |
| 5 | execute |
| 6 | clear SA accumulator |
| 7 | output select |

`uo_out[7:0]` is the result.

## Opcodes

| Opcode | Operation |
|---|---|
| 000 | A + B |
| 001 | A - B |
| 010 | A * B, low 8 bits |
| 011 | A AND B |
| 100 | A XOR B |
| 101 | unsigned MAX(A,B) |
| 110 | SA-Core signed INT8 MAC |
| 111 | SA-Core ReLU/saturated read |

All state-changing controls are sampled on the rising edge of `clk`. Load A
and B in separate cycles before asserting `execute`. Opcode `110` returns the
post-MAC ReLU/saturated result on `uo_out`; `OUT_SEL=1` instead selects the raw
accumulator's low byte.

## Why only 8-bit?

The target is a very small MPW tile. A real GPU needs far more area, memory bandwidth, caches, scheduling logic, and IO. This chip is deliberately a proof-of-concept.
