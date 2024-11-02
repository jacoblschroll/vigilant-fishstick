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

reg [31:0] data;
reg [31:0] weights;

reg [9:0] data_out;

reg [17:0] result;
reg outputState;

assign uio_oe[7:6] = 1;
assign uio_oe[5:0] = 0;

always @ (posedge clk) begin
    if (~rst_n) begin
        data <= 32'b0;
        weights <= 32'b0;
    // Write Selection
    end else if(~uio_in[0]) begin
        data <= {data[23:0], ui_in[7:0]};
    end else if (uio_in[0]) begin
        weights <= {weights[23:0], ui_in[7:0]};
    end

    if (uio_in[1] && outputState) begin
        data_out <= {outputState, result[8:0]};
    end else if(uio_in[1] && ~outputState) begin
        data_out <= {outputState, result[17:9]};
    end

    outputState = ~outputState;
    result <= (data[7:0] * weights[7:0]) + (data[15:8] * weights[15:8]) + (data[23:16] * weights[23:16]) + (data[31:24] * weights[31:24]);
end

assign uo_out = data_out[7:0];
assign uio_out[7:6] = data_out[9:8];

wire _unused = &{ena, uio_in[7:2], 1'b0};

endmodule