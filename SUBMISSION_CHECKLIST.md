# Tapeout submission checklist

## Before paying

- [x] Repository is based on the current Tiny Tapeout IHP Verilog format.
- [x] `info.yaml` validates.
- [x] RTL test workflow passes.
- [x] GDS workflow passes.
- [x] Tiny Tapeout precheck passes.
- [x] Gate-level test passes.
- [x] Generated GDS viewer shows the intended layout.
- [x] Synthesis did not remove the SA-Core or accumulator.
- [x] Timing report meets the configured 10 MHz clock.
- [x] Area fits the selected tile count.
- [x] No unconnected output pins.
- [x] Reset behavior was tested.
- [x] Hardware test procedure is written down in `HARDWARE_TEST.md`.

## Do not fabricate yet if

- any GDS or precheck job is red
- gate-level simulation differs from RTL simulation
- timing fails
- the design spills outside the tile
- synthesis warnings indicate missing clocks, latches, or undriven nets

## Final production artifact

The foundry-facing physical layout is the generated GDSII produced by the official hardening flow.
The Verilog files alone are not a foundry mask submission.

## Verified build

- Repository revision: `449d71b`
- GitHub Actions run: <https://github.com/codingmain1234-web/axion-vce-prototype-ttihp26b/actions/runs/35219544851>
- Result: RTL test, GDS build, 10 Tiny Tapeout prechecks, 4 gate-level tests, and viewer deployment all passed.
- Final metrics: 0 lint warnings, 0 setup/hold violations, 0 routed DRC errors, 0 LVS errors, and 0 disconnected pins.
- Physical result: 1,243 standard cells at 51.2256% placement utilization; 1,179 logic cells excluding fill and tap cells.

This verification does not place or pay for a fabrication order.
