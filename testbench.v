module testbench;
    localparam SZ = 8;  // ram size
    localparam WSZ = 8;  // word size

    reg rst;
    initial begin
        rst = 0;
        #1 rst = 1;
    end

    wire [SZ-1:0] ram_address;
    wire [WSZ-1:0] ram_data;
    wire ram_w_notr;

    wire io_rx_interrupt;
    wire io_tx_interrupt;
    wire [SZ-1:0] io_addr;
    wire io_w_notr;
    wire [WSZ-1:0] io_data;
    wire io_clk;

    wire cpu_rx_interrupt;
    wire cpu_tx_interrupt;
    wire [SZ-1:0] cpu_addr;
    wire cpu_w_notr;
    wire [WSZ-1:0] cpu_data;
    wire cpu_clk;

    ram #(
        .SZ (SZ),
        .WSZ(WSZ)
    ) _ram (
        .addr(ram_address),
        .data(ram_data),
        .w_notr(ram_w_notr),
        .clk(cpu_clk)
    );

    dma #(
        .SZ (SZ),
        .WSZ(WSZ)
    ) _dma (
        .ram_addr  (ram_address),
        .ram_data  (ram_data),
        .ram_w_notr(ram_w_notr),

        .cpu_rx_interrupt(cpu_rx_interrupt),
        .cpu_tx_interrupt(cpu_tx_interrupt),
        .cpu_addr(cpu_addr),
        .cpu_w_notr(cpu_w_notr),
        .cpu_data(cpu_data),
        .cpu_clk(cpu_clk),

        .io_rx_interrupt(io_rx_interrupt),
        .io_tx_interrupt(io_tx_interrupt),
        .io_addr(io_addr),
        .io_w_notr(io_w_notr),
        .io_data(io_data),
        .io_clk(io_clk),

        .rst(rst)
    );

    cpu #(
        .SZ (SZ),
        .WSZ(WSZ)
    ) _cpu (
        .rx_interrupt(cpu_rx_interrupt),
        .tx_interrupt(cpu_tx_interrupt),
        .addr(cpu_addr),
        .w_notr(cpu_w_notr),
        .data(cpu_data),
        .clk(cpu_clk),
        .rst(rst)
    );

    io #(
        .SZ (SZ),
        .WSZ(WSZ)
    ) _io (
        .rx_interrupt(io_rx_interrupt),
        .tx_interrupt(io_tx_interrupt),
        .addr(io_addr),
        .w_notr(io_w_notr),
        .data(io_data),
        .clk(io_clk),
        .rst(rst)
    );
endmodule
