import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


def ctrl(op=0, load_a=0, load_b=0, execute=0, clear=0, out_sel=0):
    return (
        (op & 0x7)
        | ((load_a & 1) << 3)
        | ((load_b & 1) << 4)
        | ((execute & 1) << 5)
        | ((clear & 1) << 6)
        | ((out_sel & 1) << 7)
    )


async def reset_dut(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


async def start_and_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 100, unit="ns").start())  # 10 MHz
    await reset_dut(dut)


async def pulse_control(dut, ctrl, data=0):
    dut.ui_in.value = data
    dut.uio_in.value = ctrl
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    dut.uio_in.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


async def load_operands(dut, a, b):
    await pulse_control(dut, ctrl(load_a=1), a)
    await pulse_control(dut, ctrl(load_b=1), b)


async def execute(dut, op):
    await pulse_control(dut, ctrl(op=op, execute=1))
    return int(dut.uo_out.value)


@cocotb.test()
async def test_reset_and_fixed_outputs(dut):
    await start_and_reset(dut)
    assert int(dut.uo_out.value) == 0
    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0


@cocotb.test()
async def test_vcore_operations(dut):
    await start_and_reset(dut)

    vectors = (
        # op, A, B, expected
        (0, 250, 10, 4),       # ADD wraps to 8 bits
        (1, 3, 5, 0xFE),       # SUB wraps to 8 bits
        (2, 20, 13, 4),        # MUL returns low byte of 260
        (3, 0xAC, 0x3C, 0x2C), # AND
        (4, 0xAC, 0x3C, 0x90), # XOR
        (5, 0xFE, 4, 0xFE),    # unsigned MAX
    )

    for op, a, b, expected in vectors:
        await load_operands(dut, a, b)
        assert await execute(dut, op) == expected


@cocotb.test()
async def test_enable_gates_state_changes(dut):
    await start_and_reset(dut)
    await load_operands(dut, 5, 3)

    dut.ena.value = 0
    await pulse_control(dut, ctrl(load_a=1), 100)
    await pulse_control(dut, ctrl(op=0, execute=1))
    assert int(dut.uo_out.value) == 0

    dut.ena.value = 1
    assert await execute(dut, 0) == 8


@cocotb.test()
async def test_sa_core_mac_relu_saturation_and_clear(dut):
    await start_and_reset(dut)

    await pulse_control(dut, ctrl(clear=1))
    await load_operands(dut, 5, 3)
    assert await execute(dut, 6) == 15  # post-MAC result is immediately visible

    # raw accumulator low byte
    dut.uio_in.value = ctrl(out_sel=1)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 15

    await load_operands(dut, 0xFE, 4)  # -2 * 4
    assert await execute(dut, 6) == 7
    dut.uio_in.value = ctrl(out_sel=1)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 7

    assert await execute(dut, 7) == 7

    # Positive values saturate to signed INT8 maximum, raw accumulator remains 200.
    await pulse_control(dut, ctrl(clear=1))
    await load_operands(dut, 100, 2)
    assert await execute(dut, 6) == 127
    dut.uio_in.value = ctrl(out_sel=1)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 200

    # Negative accumulated values are clamped to zero by ReLU.
    await pulse_control(dut, ctrl(clear=1))
    await load_operands(dut, 0xFC, 2)  # -4 * 2
    assert await execute(dut, 6) == 0
    dut.uio_in.value = ctrl(out_sel=1)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 0xF8

    # Clear has priority over MAC when both controls are asserted.
    await pulse_control(dut, ctrl(op=6, execute=1, clear=1))
    assert int(dut.uo_out.value) == 0
    dut.uio_in.value = ctrl(out_sel=1)
    await Timer(1, unit="ns")
    assert int(dut.uo_out.value) == 0
