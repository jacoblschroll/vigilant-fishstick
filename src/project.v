/*
 * Copyright (c) 2024 Your Name
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

    reg [31:0] weights;
    reg [31:0] inputs;

    reg [17:0] greatest;

    initial begin
        weights = 32'b0;
      	inputs = 32'b0;
      	greatest = 18'b0;
    end
  
    always @(posedge clk) begin
        // HIGH write goes to weights
        if (uio_in[0]) begin
            weights <= {ui_in, weights[31:8]};
        end else begin
            inputs <= {ui_in, inputs[31:8]};
        end
    end

    always @ (negedge clk) begin
        if (rst_n) begin
            greatest <= 18'b0;
        end
        
        if ((inputs[7:0] * weights[7:0] + inputs[15:8] * weights[15:8] + inputs[23:16] * weights[23:16] + inputs[31:24] * weights[31:24]) > greatest) begin
            greatest <= (inputs[7:0] * weights[7:0] + inputs[15:8] * weights[15:8] + inputs[23:16] * weights[23:16] + inputs[31:24] * weights[31:24]);
        end
    end

    assign uo_out = greatest[7:0];

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:1], uio_out, uio_oe, 1'b0};

endmodule