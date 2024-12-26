module clk_gen #(
    parameter PRD = 1
) (
    input rst,
    output reg clk
);
    always #PRD begin
        if (!rst) clk <= 0;
        else clk <= !clk;
    end
endmodule
