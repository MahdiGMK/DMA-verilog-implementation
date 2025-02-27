module ram #(
    parameter int SZ  = 8,
    parameter int WSZ = 8
) (
    input [SZ-1:0] addr,
    input w_notr,
    inout [WSZ-1:0] data,
    input clk
);
    reg [WSZ-1:0] storage[(1 << SZ) - 1];
    assign data = w_notr ? 'z : storage[addr];
    always @(posedge clk) begin
        if (w_notr) storage[addr] <= data;
    end
endmodule
