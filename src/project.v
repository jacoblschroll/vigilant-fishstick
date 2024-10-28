/*
 * Copyright (c) 2024 Jacob Schroll
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

reg [31:0] weights_reg;
reg [127:0] data_reg;

wire [31:0] weights;
wire [127:0] data;

MultiSPI #(.REGSIZE(32)) weightSPI (
    .clk(clk),
    .I(ui_in[3:0]),
    .S(ui_in[5:4]),
    .register(weights)
);

MultiSPI #(.REGSIZE(128)) dataSPI (
    .clk(clk),
    .I(ui_in[3:0]),
    .S(ui_in[5:4]),
    .register(data)
);

assign weights_reg = weights;
assign data_reg = data;

assign uio_out[7:0] = 0;
assign uo_out[7:0] = 0;
assign uio_oe[7:0] = 0;

always @ (posedge clk) begin
    if (ui_in[7:6] == 2'b00) begin
        weights_reg <= 32'b0;
        data_reg <= 128'b0;
    end else if (ui_in[7:6] == 2'b01) begin
        weights_reg <= 32'b0;
    end else if (ui_in[7:6] == 2'b10) begin
        data_reg <= 128'b0;
    end

    data_reg <= {data_reg[126:0], 1};
    weights_reg <= {weights_reg[126:0], 1};
end

// List all unused inputs to prevent warnings
wire _unused = &{ena, uio_in[7:0], rst_n, 1'b0};

endmodule