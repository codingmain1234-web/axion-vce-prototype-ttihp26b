`default_nettype none

// AXION V-Core prototype ALU
// 8-bit datapath intentionally chosen to fit a minimum-cost Tiny Tapeout tile.
module axion_vcore_alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] op,
    output reg  [7:0] y
);
    wire [15:0] product_u = a * b;

    always @* begin
        case (op)
            3'b000: y = a + b;                          // ADD
            3'b001: y = a - b;                          // SUB
            3'b010: y = product_u[7:0];                // MUL low byte
            3'b011: y = a & b;                          // AND
            3'b100: y = a ^ b;                          // XOR
            3'b101: y = (a > b) ? a : b;               // MAX unsigned
            default: y = 8'h00;                         // SA ops handled elsewhere
        endcase
    end
endmodule

`default_nettype wire
