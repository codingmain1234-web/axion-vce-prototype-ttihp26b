# AXION VCE Prototype — Tiny Tapeout IHP26b

This repository is structured as a Tiny Tapeout IHP26b Verilog project.

Version: **0.2 (AXION Gen0)**

## Goal

Make the cheapest realistic first-silicon prototype of the AXION GPU idea:

- **VCE** = Vector Compute Engine
- **V-Core** = general arithmetic lane
- **SA-Core** = Special AI Core

The design is intentionally tiny. It verifies that the basic compute architecture can become real silicon before attempting a full GPU.

## Important

This archive contains the RTL and submission project, but **not a pre-generated final GDSII file**.

To reach actual fabrication submission:
1. Put these files in a GitHub repository.
2. Enable GitHub Actions.
3. Wait for `gds`, `precheck`, and `gl_test` to pass.
4. Inspect the generated GDS/metrics.
5. Submit that repository/revision through Tiny Tapeout.

Never pay for fabrication while any precheck or gate-level test is failing.

## Interface rule

`LOAD_A`, `LOAD_B`, `EXECUTE`, and `CLEAR_ACC` are synchronous, active-high
controls. Hold one control command for a rising clock edge, then return the
control byte to zero. Load A and B in separate cycles before executing an
operation. For opcode `110`, `uo_out` reports the post-MAC ReLU/saturated value;
setting `OUT_SEL=1` exposes the raw accumulator low byte for debugging.

## Local RTL test

Install Icarus Verilog, GNU Make, and Python 3.11, then run:

```sh
python -m pip install -r test/requirements.txt
cd test
make clean
make
```

The same cocotb suite is reused by the official Tiny Tapeout gate-level test.
See `HARDWARE_TEST.md` for the physical-chip test sequence.

## Clock

Target: 10 MHz for first silicon.

The design may be capable of more, but the first objective is reliable silicon, not peak clock speed.
