module io #(
    parameter int SZ = 8,
    parameter int WSZ = 8,
    parameter int CLK_PERIOD = 1
) (
    input outside_interrupt,
    inout [SZ-1:0] addr,
    inout w_notr,
    inout [WSZ-1:0] data,
    output reg clk
);
    initial clk = 0;
    always #1 begin
        clk <= !clk;
    end
    always @(clk)
        if (outside_interrupt) begin
        end
endmodule
