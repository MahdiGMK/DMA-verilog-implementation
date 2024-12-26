module cpu #(
    parameter int SZ = 8,
    parameter int WSZ = 8,
    parameter int CLK_PERIOD = 1
) (
    input rx_interrupt,
    output reg tx_interrupt,
    inout [SZ-1:0] addr,
    output w_notr,
    inout [WSZ-1:0] data,
    output clk,
    input rst
);
    clk_gen _clk_gen (
        .rst(rst),
        .clk(clk)
    );

    reg [1:0] command_state;
    reg [SZ-1:0] command_addr;
    reg [SZ-1:0] command_length;
    reg [SZ-1:0] command_mem_addr;
    reg command_w_notr;

    reg [WSZ-1:0] bus_write_data;
    reg [SZ-1:0] bus_write_addr;

    assign w_notr = !rx_interrupt && command_state == 2 ? command_w_notr : 0;
    assign addr   = rx_interrupt ? 'z : bus_write_addr;
    assign data   = w_notr ? bus_write_data : 'z;

    always @(negedge rst, posedge clk) begin
        if (!rst) begin
            command_state <= 0;
            tx_interrupt  <= 0;

        end else begin

        end
    end

endmodule
