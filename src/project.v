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

    // Register for storing weight values
    reg [23:0] weights;

    // Register for storing input values
    reg [23:0] inputs;

    // Register for storing the result of each convolution
    reg [13:0] convolution_result;

    // Register for storing the greast value seen since reset
    reg [13:0] greatest;

    // Set starting values or dummy values for unused outputs
    initial begin
        weights = 24'b0;
        inputs = 24'b0;
        
        convolution_result = 14'b0;

        greatest = 14'b0;

        uio_oe[7] = 1'b0;
        uio_oe[6:0] = 7'b1;
        
        uio_out[7:6] = 2'b0;
    end

    // At the rising edge of the clock
    always @(posedge clk) begin
        // Reset at active low
        if (!rst_n) begin
            weights <= 24'b0;
            inputs <= 24'b0;
        end else begin
            // HIGH write goes to weights, shift values in
            if (uio_in[7]) begin
                weights <= {ui_in[5:0], weights[23:6]};
            end else begin
                inputs <= {ui_in[5:0], inputs[23:6]};
            end
        end
    end

    // At the falling edge of the clock
    always @ (negedge clk) begin
        
        // Store the result of the convolution
        convolution_result <= inputs[5:0] * weights[5:0] + inputs[11:6] * weights[11:6] + inputs[17:12] * weights[17:12] + inputs[23:18] * weights[23:18];
        
        // Reset at active low
        if (!rst_n) begin
            greatest <= 14'b0;
        end

        // If the convolution is greater than that seen so far, it becomes the new greatest
        else if (convolution_result > greatest) begin
            greatest <= convolution_result;
        end
    end

    // Write out the greatest result, maxpooling occurs after 4 clock cycles
    assign uo_out = greatest[7:0];
    assign uio_out[5:0] = greatest[13:8];

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in[7:6], uio_in[6:0], 1'b0};
endmodule