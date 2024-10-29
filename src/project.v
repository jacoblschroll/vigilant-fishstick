/*
 * Copyright (c) 2024 Jacob Schroll
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "SPISelect.v"
`include "readData.v"

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

wire [31:0] weights;
wire [127:0] data;

reg weights_reg;
reg data_reg;

reg [1:0] readCycle;
reg [17:0] convolution;

MultiSPI #(.REGSIZE(32), .SELECTCODE(1'b0)) weightSPI (
    .clk(clk),
    .I(ui_in[3:0]),
    .S(ui_in[5:4]),
    .writeSelect(ui_in[7]),
    .register(weights)
);

MultiSPI #(.REGSIZE(128), .SELECTCODE(1'b1)) dataSPI (
    .clk(clk),
    .I(ui_in[3:0]),
    .S(ui_in[5:4]),
    .writeSelect(ui_in[7]),
    .register(data)
);

DataAccess convolutionRead(
    .clk(clk),
    .readEnable(uio_in[0]),
    .readCycle(readCycle),
    .dataIn(convolution),
    .dataOut(uo_out[7:0])
);

assign uio_out[7:0] = 0;
assign uio_oe[7:0] = 0;

assign weights_reg = weights;
assign data_reg = data;

always @ (posedge clk) begin
    if (ui_in[6] == 0 && rst_n == 0) begin
        weights <= 32'b0;
        data <= 128'b0;
    end else if (ui_in[6] == 0 && rst_n == 1) begin
        weights <= 32'b0;
    end else if (ui_in[6] == 1 && rst_n == 0) begin
        data <= 128'b0;
    end

    convolution <= data[7:0] * weights[7:0];
end

// List all unused inputs to prevent warnings
wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule