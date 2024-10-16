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

    reg [15:0] weights;
    reg [15:0] inputs;

    reg [9:0] greatest;

    initial begin
        weights = 16'b0;
      	inputs = 16'b0;
      	greatest = 10'b0;
        uio_oe[7] = 1'b0;
        ui_oe[1:0] = 2'b0;
    end
  
    always @(posedge clk) begin
        // HIGH write goes to weights
        if (rst_n) begin
            weights = 16'b0;
            inputs = 16'b0;
        end

        if (uio_in[7]) begin
            weights <= {ui_in[3:0], weights[15:4]};
        end else begin
            inputs <= {ui_in[3:0], inputs[15:4]};
        end
    end

    always @ (negedge clk) begin
        if (rst_n) begin
            greatest <= 10'b0;
        end
        
        if ((inputs[3:0] * weights[3:0] + inputs[7:4] * weights[7:4] + inputs[11:8] * weights[11:8] + inputs[15:12] * weights[15:12]) > greatest) begin
            greatest <= (inputs[3:0] * weights[3:0] + inputs[7:4] * weights[7:4] + inputs[11:8] * weights[11:8] + inputs[15:12] * weights[15:12]);
        end
    end

    assign uo_out = greatest[1:0];

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:1], uio_out, uio_oe[6:2], 1'b0};

endmodule