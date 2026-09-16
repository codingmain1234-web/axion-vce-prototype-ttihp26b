# AXION Gen0 Silicon Architecture

## Block hierarchy

```text
Tiny Tapeout IO
      |
      v
+--------------------+
|  VCE control       |
|  A/B registers     |
+------+-------------+
       |
   +---+----------------------+
   |                          |
   v                          v
+---------+              +-----------+
| V-Core  |              | SA-Core   |
| 8-bit   |              | INT8 MAC  |
| ALU     |              | 24b ACC   |
+----+----+              +-----+-----+
     |                         |
     +-----------+-------------+
                 |
                 v
             DATA_OUT
```

## V-Core

The V-Core is a small arithmetic lane. In this prototype it supports:

- ADD
- SUB
- MUL
- AND
- XOR
- MAX

## SA-Core

SA-Core means **Special AI Core**.

The first silicon version contains:

- signed INT8 multiplier
- signed 24-bit accumulator
- ReLU
- signed-positive saturation to 8-bit range 0..127

The accumulator wraps in signed 24-bit two's-complement arithmetic. A MAC
command returns the ReLU/saturated value computed from the updated accumulator,
while the raw low byte remains available through `OUT_SEL` for bring-up and
debugging.

A future GPU version can replace this with wider matrix units and FP16/BF16/FP8 support.

## Scaling path

Gen0:
- 1 VCE
- 1 V-Core-style lane
- 1 SA-Core
- 8-bit IO

Gen1 FPGA:
- multiple SIMD lanes
- scheduler
- local SRAM
- wider memory interface

Gen1 ASIC:
- multiple VCEs
- SRAM/register files
- network-on-chip
- memory controller
