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

reg [27:0] data;
reg [27:0] weights;

reg [15:0] result;
reg outputState;

reg [7:0] data_out;

assign uio_oe[7:6] = 1;
assign uio_oe[5:0] = 0;

assign uio_out[7:0] = 0;

always @ (posedge clk) begin
    if (~rst_n) begin
        data <= 28'b0;
        weights <= 28'b0;
    // Write Selection
    end else if(~uio_in[0] && ~uio_in[1]) begin
        data <= {data[22:0], ui_in[6:0]};
    end else if (uio_in[0] && uio_in[1]) begin
        weights <= {weights[22:0], ui_in[6:0]};
    end

    // UIO[1] is ReadSelect
    if (uio_in[1] && outputState) begin
        data_out <= result[7:0];
    end else if(uio_in[1] && ~outputState) begin
        data_out <= result[15:8];
    end

    outputState <= ~outputState;
    result <= (data[6:0] * weights[6:0]) + (data[13:7] * weights[13:7]) + (data[20:14] * weights[20:14]) + (data[27:21] * weights[27:21]);
end

assign uo_out = data_out[7:0];

wire _unused = &{ena, uio_in[7:2], ui_in[7], 1'b0};

endmodule