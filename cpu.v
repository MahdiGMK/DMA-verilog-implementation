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
    // reg [SZ-1:0] command_addr;
    // reg [SZ-1:0] command_length;
    // reg [SZ-1:0] command_mem_addr;
    // reg command_w_notr;

    reg [WSZ-1:0] bus_write_data;
    reg [SZ-1:0] bus_write_addr;

    assign w_notr = tx_interrupt;
    assign addr   = rx_interrupt ? 'z : bus_write_addr;
    assign data   = w_notr ? bus_write_data : 'z;

    always @(negedge rst, posedge clk) begin
        if (!rst) begin
            command_state <= 0;
            tx_interrupt  <= 0;
        end else begin
            if (rx_interrupt) begin
                $display($time, " cpu : job is done");
                tx_interrupt   <= 0;
                bus_write_addr <= 12;
                #1 $display($time, " ram[%d] = %d", bus_write_addr, data);
                bus_write_addr <= 13;
                #1 $display($time, " ram[%d] = %d", bus_write_addr, data);
                bus_write_addr <= 14;
                #1 $display($time, " ram[%d] = %d", bus_write_addr, data);
            end else begin
                if (command_state == 0) begin
                    command_state  <= 1;
                    tx_interrupt   <= 1;
                    bus_write_addr <= 5;
                    bus_write_data <= 3;
                    $display($time, " cpu : read[5,6,7]");
                end else if (command_state == 1) begin
                    command_state  <= 2;
                    tx_interrupt   <= 1;
                    bus_write_addr <= 12;
                    bus_write_data <= 1;
                    $display($time, " cpu : write_to[12,13,14]");
                end else begin
                    tx_interrupt <= 0;
                end
            end
        end
    end

endmodule
