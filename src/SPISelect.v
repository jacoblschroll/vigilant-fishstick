/*
module MultiSPI#(parameter REGSIZE = 8, parameter SELECTCODE = 1'b0)(
    input clk,
    input [3:0] I,
    input [1:0] S,
    input writeSelect,
    output reg [REGSIZE-1:0] register
);

always @ (posedge clk) begin
    if (writeSelect == SELECTCODE && S == 2'b00) begin
        register <= {register[REGSIZE - 2:0], I[0]};
    end else if(writeSelect == SELECTCODE && S == 2'b01) begin
        register <= {register[REGSIZE - 3:0], I[1:0]};
    end else if(writeSelect == SELECTCODE && S == 2'b11) begin
        register <= {register[REGSIZE - 5:0], I[3:0]};
    end
end
endmodule
*/