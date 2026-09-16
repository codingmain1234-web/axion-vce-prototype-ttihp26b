/*
 * AXION VCE Prototype for Tiny Tapeout IHP26b
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_codingmain1234_web_axion_vce (
    input  wire [7:0] ui_in,    // data input
    output wire [7:0] uo_out,   // result output
    input  wire [7:0] uio_in,   // control input
    output wire [7:0] uio_out,  // unused
    output wire [7:0] uio_oe,   // all bidirectional pins configured as inputs
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // uio_in mapping:
    // [2:0] opcode
    // [3]   load A
    // [4]   load B
    // [5]   execute
    // [6]   clear SA accumulator
    // [7]   output select: 0=result, 1=raw accumulator low byte

    axion_vce u_vce (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .data_in(ui_in),
        .op(uio_in[2:0]),
        .load_a(uio_in[3]),
        .load_b(uio_in[4]),
        .execute(uio_in[5]),
        .clear_acc(uio_in[6]),
        .out_sel(uio_in[7]),
        .data_out(uo_out)
    );

    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

endmodule

`default_nettype wire
