`default_nettype none

// SA-Core = Special AI Core
// Tiny first-generation prototype:
// - signed INT8 x INT8 multiply
// - signed 24-bit accumulator
// - ReLU + INT8 saturation output
module axion_sa_core (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire       clear_acc,
    input  wire       mac_en,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output reg  signed [23:0] acc,
    output wire [7:0] relu_sat,
    output wire [7:0] mac_relu_sat
);
    wire signed [7:0]  a_s = a;
    wire signed [7:0]  b_s = b;
    wire signed [15:0] product = a_s * b_s;
    wire signed [23:0] product_ext = {{8{product[15]}}, product};
    wire signed [23:0] acc_after_mac = acc + product_ext;

    function [7:0] sat_relu8;
        input signed [23:0] x;
        begin
            if (x < 0)
                sat_relu8 = 8'd0;
            else if (x > 24'sd127)
                sat_relu8 = 8'd127;
            else
                sat_relu8 = x[7:0];
        end
    endfunction

    assign relu_sat = sat_relu8(acc);
    assign mac_relu_sat = sat_relu8(acc_after_mac);

    always @(posedge clk) begin
        if (!rst_n)
            acc <= 24'sd0;
        else if (ena) begin
            if (clear_acc)
                acc <= 24'sd0;
            else if (mac_en)
                acc <= acc + product_ext;
        end
    end
endmodule

`default_nettype wire
