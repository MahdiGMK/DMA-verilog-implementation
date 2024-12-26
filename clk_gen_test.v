module clk_gen_test;
    reg  rst;
    wire clk;
    clk_gen _clk_gen (
        .rst(rst),
        .clk(clk)
    );
    initial begin
        $monitor($time, " : ", clk);
        rst = 0;
        #6 rst = 1;
        #20 rst = 0;
        #4 rst = 1;
        #20 $finish(0);
    end
endmodule
