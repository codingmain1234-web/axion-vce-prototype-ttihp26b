`default_nettype none

// VCE = Vector Compute Engine
// Minimal silicon prototype of the concept:
// - two 8-bit operand registers
// - one 8-bit V-Core ALU
// - one tiny SA-Core
// - simple control interface
module axion_vce (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,

    input  wire [7:0] data_in,
    input  wire [2:0] op,
    input  wire       load_a,
    input  wire       load_b,
    input  wire       execute,
    input  wire       clear_acc,
    input  wire       out_sel,

    output wire [7:0] data_out
);
    reg [7:0] a_reg;
    reg [7:0] b_reg;
    reg [7:0] result_reg;

    wire [7:0] alu_y;
    // The upper accumulator bits are intentionally retained inside SA-Core for
    // future wider result modes; Gen0 exposes only the saturated INT8 result.
    /* verilator lint_off UNUSEDSIGNAL */
    wire signed [23:0] sa_acc;
    /* verilator lint_on UNUSEDSIGNAL */
    wire [7:0] sa_relu_sat;
    wire [7:0] sa_mac_relu_sat;

    axion_vcore_alu u_alu (
        .a(a_reg),
        .b(b_reg),
        .op(op),
        .y(alu_y)
    );

    // op=110 : signed INT8 MAC
    wire sa_mac_en = execute && (op == 3'b110);

    axion_sa_core u_sa (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .clear_acc(clear_acc),
        .mac_en(sa_mac_en),
        .a(a_reg),
        .b(b_reg),
        .acc(sa_acc),
        .relu_sat(sa_relu_sat),
        .mac_relu_sat(sa_mac_relu_sat)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            a_reg      <= 8'h00;
            b_reg      <= 8'h00;
            result_reg <= 8'h00;
        end else if (ena) begin
            if (load_a)
                a_reg <= data_in;

            if (load_b)
                b_reg <= data_in;

            if (clear_acc) begin
                result_reg <= 8'h00;
            end else if (execute) begin
                case (op)
                    3'b000,
                    3'b001,
                    3'b010,
                    3'b011,
                    3'b100,
                    3'b101: result_reg <= alu_y;

                    3'b110: result_reg <= sa_mac_relu_sat; // post-MAC ReLU/saturation
                    3'b111: result_reg <= sa_relu_sat; // explicit ReLU/read
                    default: result_reg <= 8'h00;
                endcase
            end
        end
    end

    // out_sel=0 : last V-Core/SA result
    // out_sel=1 : low byte of raw SA accumulator (debug)
    assign data_out = out_sel ? sa_acc[7:0] : result_reg;
endmodule

`default_nettype wire
