module io #(
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
    clk_gen #(
        .PRD(1)
    ) _clk_gen (
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

    reg [WSZ-1:0] internal_data[16];

    // assign w_notr = !rx_interrupt && command_state == 2 ? command_w_notr : 0;
    assign addr = rx_interrupt ? 'z : bus_write_addr;
    assign data = w_notr ? bus_write_data : 'z;

    reg [4:0] indx;
    always @(negedge rst, posedge clk)
        if (!rst) begin
            command_state <= 0;
            w_notr <= 0;
            tx_interrupt <= 0;
            for (indx = 0; indx < 16; indx = indx + 1) begin
                internal_data[indx] = WSZ'($urandom);
                $display($time, " io : data[%d] = %x", indx, internal_data[indx]);
            end
        end else begin
            if (rx_interrupt) begin
                w_notr <= 0;
                if (command_state == 0) begin
                    // get request range
                    $display($time, " io : read[%d,...,%d]", addr, addr + data - 1);
                    command_state  <= 1;
                    command_addr   <= addr;
                    command_length <= data;
                end else if (command_state == 1) begin
                    // get memory address and w_notr
                    $display($time, " io : write_to[%d,...,%d]", addr, addr + command_length - 1);
                    command_state <= 2;
                    command_mem_addr <= addr;
                    command_w_notr <= data[0];
                end
            end else if (command_state == 2) begin
                if (|command_length) begin
                    // write requested data to ram
                    $display($time, " io : request mem[%d] = %x", command_mem_addr,
                             internal_data[command_addr[3:0]]);
                    w_notr <= 1;
                    bus_write_addr <= command_mem_addr;
                    bus_write_data <= internal_data[command_addr[3:0]];
                    command_addr <= command_addr + 1;
                    command_mem_addr <= command_mem_addr + 1;
                    command_length <= command_length - 1;
                    if (command_length == 1) begin
                        // send completion interrupt
                        $display($time, " io : request complete");
                        tx_interrupt <= 1;
                    end
                end else begin
                    w_notr <= 0;
                    command_state <= 0;
                end
            end
        end
endmodule
