module io #(
    parameter int SZ = 8,
    parameter int WSZ = 8,
    parameter int CLK_PERIOD = 1
) (
    input rx_interrupt,
    output reg tx_interrupt,
    inout [SZ-1:0] addr,
    output w_notr,
    inout [WSZ-1:0] data,
    output reg clk,
    input rst
);
    always #1 begin
        clk <= !clk;
    end
    reg [1:0] command_state;
    reg [SZ-1:0] command_addr;
    reg [SZ-1:0] command_length;
    reg [SZ-1:0] command_mem_addr;
    reg command_w_notr;

    reg [WSZ-1:0] bus_write_data;
    reg [SZ-1:0] bus_write_addr;

    reg [WSZ-1:0] internal_data[3:0];

    assign w_notr = !rx_interrupt && command_state == 2 ? command_w_notr : 0;
    assign addr   = rx_interrupt ? 'z : bus_write_addr;
    assign data   = w_notr ? bus_write_data : 'z;

    always @(negedge rst) begin
        command_state <= 0;
        tx_interrupt <= 0;
        clk <= 0;
        for (int i = 0; i < 16; i = i + 1) internal_data[i] = $rand;
    end
    always @(clk)
        if (rx_interrupt) begin
            if (command_state == 0) begin
                command_state  <= 1;
                command_addr   <= addr;
                command_length <= data;
            end else if (command_state == 1) begin
                command_state <= 2;
                command_mem_addr <= addr;
                command_w_notr <= data[0];
            end
        end else if (command_state == 2) begin
            if (|command_length) begin
                bus_write_addr <= command_mem_addr;
                bus_write_data <= internal_data[command_addr];
                command_addr <= command_addr + 1;
                command_mem_addr <= command_mem_addr + 1;
                command_length <= command_length - 1;
            end else begin
                command_state <= 0;
                tx_interrupt  <= 1;
            end
        end
endmodule
