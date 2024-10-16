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

    reg [23:0] weights;
    reg [23:0] inputs;

    reg convolution_result[11:0];

    reg [13:0] greatest;

    initial begin
        weights = 24'b0;
      	inputs = 24'b0;
      	
        convolution_result = 12'b0;

        greatest = 14'b0;

        uio_oe[7] = 1'b0;
        uio_oe[6:0] = 2'b1;
    end
  
    always @(posedge clk) begin
        if (!rst_n) begin
            weights <= 24'b0;
            inputs <= 24'b0;
        end else begin
            // HIGH write goes to weights
            if (uio_in[7]) begin
                weights <= {ui_in[5:0], weights[23:6]};
            end else begin
                inputs <= {ui_in[5:0], inputs[23:6]};
            end
        end
    end

    always @ (negedge clk) begin
      if (!rst_n) begin
            greatest <= 10'b0;
      end

      convolution_result <= inputs[5:0] * weights[5:0] + inputs[11:6] * weights[11:6] + inputs[17:12] * weights[17:12] + inputs[23:18] * weights[23:18];

      else if (convolution_result > greatest) begin
            greatest <= convolution_result;
      end
    end

    assign uo_out = greatest[7:0];
    assign uio_out[6:0] = greatest[13:8];

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:6], 1'b0};

endmodule