/*
module DataAccess
(
    input clk,
    input readEnable,
    input wire [1:0] readCycle,
    input wire [17:0] dataIn,
    output [7:0] dataOut
);

reg toAssign[7:0] = 8'b0;

always @ (posedge clk) begin
    if (readEnable && readCycle == 2b'00) begin
        toAssign <= dataIn[7:0];
    end else if (readEnable && readCycle == 2b'01) begin
        toAssign <= dataIn[15:8];
    end else if (readEnable && readCycle == 2b'01) begin
        toAssign <= {dataIn[17:16], 6'b0};
    end

    readCycle += 1;
end

assign dataOut = toAssign;

endmodule
*/