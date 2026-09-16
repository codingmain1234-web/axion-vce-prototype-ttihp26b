# Tapeout submission checklist

## Before paying

- [ ] Repository is based on the current Tiny Tapeout IHP Verilog format.
- [ ] `info.yaml` validates.
- [ ] RTL test workflow passes.
- [ ] GDS workflow passes.
- [ ] Tiny Tapeout precheck passes.
- [ ] Gate-level test passes.
- [ ] Generated GDS viewer shows the intended layout.
- [ ] Synthesis did not remove the SA-Core or accumulator.
- [ ] Timing report meets the configured 10 MHz clock.
- [ ] Area fits the selected tile count.
- [ ] No unconnected output pins.
- [ ] Reset behavior was tested.
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
