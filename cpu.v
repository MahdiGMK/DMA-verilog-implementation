module cpu #(
    parameter int SZ = 8,
    parameter int WSZ = 8,
    parameter int CLK_PERIOD = 1
) (
    input rx_interrupt,
    output reg tx_interrupt,
    inout [SZ-1:0] addr,
    output reg w_notr,
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

    assign addr = bus_write_addr;
    assign data = w_notr ? bus_write_data : 'z;


    always @(negedge rst, posedge clk) begin
        if (!rst) begin
            command_state <= 0;
            tx_interrupt <= 0;
            w_notr <= 0;
        end else begin
            if (rx_interrupt) begin
                $display($time, " cpu : job is done");
                w_notr <= 0;
                tx_interrupt <= 0;
                // normal memory reads
                bus_write_addr <= 10;
                #4 $display($time, " ram[%d] = %x", bus_write_addr, data);
                bus_write_addr <= 11;
                #4 $display($time, " ram[%d] = %x", bus_write_addr, data);
                bus_write_addr <= 12;
                #4 $display($time, " ram[%d] = %x", bus_write_addr, data);
                bus_write_addr <= 13;
                #4 $display($time, " ram[%d] = %x", bus_write_addr, data);
                bus_write_addr <= 14;
                #4 $display($time, " ram[%d] = %x", bus_write_addr, data);
                bus_write_addr <= 15;
                #4 $display($time, " ram[%d] = %x", bus_write_addr, data);

                $finish(0);
            end else begin
                if (command_state == 0) begin
                    command_state <= 1;
                    // io request p1
                    w_notr <= 1;
                    tx_interrupt <= 1;
                    bus_write_addr <= 5;
                    bus_write_data <= 3;
                    $display($time, " cpu : read[5,6,7]");
                end else if (command_state == 1) begin
                    command_state <= 2;
                    // io request p2
                    w_notr <= 1;
                    tx_interrupt <= 1;
                    bus_write_addr <= 12;
                    bus_write_data <= 1;
                    $display($time, " cpu : write_to[12,13,14]");
                end else if (command_state == 2) begin
                    command_state <= 3;
                    tx_interrupt <= 0;
                    w_notr <= 1;
                    // normal memory writes
                    bus_write_addr <= 15;
                    bus_write_data <= 'hdd;
                    $display($time, " cpu : mem[15] := dd");
                    #4 bus_write_addr <= 10;
                    bus_write_data <= 'hee;
                    $display($time, " cpu : mem[10] := ee");
                    #4 bus_write_addr <= 12;
                    bus_write_data <= 'hff;
                    $display($time, " cpu : mem[10] := ee");
                    #4 bus_write_addr <= 13;
                    bus_write_data <= 'haa;
                    $display($time, " cpu : mem[10] := ee");
                end else begin
                    w_notr <= 0;
                    tx_interrupt <= 0;
                end
            end
        end
    end

endmodule
