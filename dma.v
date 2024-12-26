module dma #(
    parameter int SZ  = 8,
    parameter int WSZ = 8
) (
    output reg cpu_rx_interrupt,
    input cpu_tx_interrupt,
    inout [SZ-1:0] cpu_addr,
    input cpu_w_notr,
    inout [WSZ-1:0] cpu_data,
    input cpu_clk,

    output reg [SZ-1:0] ram_addr,
    output reg ram_w_notr,
    inout [WSZ-1:0] ram_data,

    output reg io_rx_interrupt,
    input io_tx_interrupt,
    inout [SZ-1:0] io_addr,
    input io_w_notr,
    inout [WSZ-1:0] io_data,
    input io_clk,

    input rst
);

    reg [1:0] io_buffer_ptr;
    reg [SZ-1:0] io_addr_buffer[4];
    reg [WSZ-1:0] io_data_buffer[4];
    reg io_tx_interrupt_buffer;

    reg [WSZ-1:0] io_write_data;
    reg [SZ-1:0] io_write_addr;
    assign io_data = io_rx_interrupt ? io_write_data : 'z;
    assign io_addr = io_rx_interrupt ? io_write_addr : 'z;

    reg [1:0] io_rx_interrupt_status;

    always @(posedge io_clk, negedge rst) begin
        if (!rst) begin
            io_rx_interrupt <= 0;
            io_tx_interrupt_buffer <= 0;
            io_buffer_ptr <= 0;
            io_rx_interrupt_status <= 0;
        end else begin
            if (cpu_buffer_ptr == 2 && io_rx_interrupt_status < 2) begin
                io_rx_interrupt <= 1;
                io_write_addr <= cpu_addr_buffer[io_rx_interrupt_status[0]];
                io_write_data <= cpu_data_buffer[io_rx_interrupt_status[0]];
                io_rx_interrupt_status <= io_rx_interrupt_status + 1;
            end else begin
                io_rx_interrupt <= 0;
                if (io_w_notr) begin
                    $display($time, " dma : io_enque mem[%d] = %x", io_addr, io_data);
                    io_addr_buffer[io_buffer_ptr] <= io_addr;
                    io_data_buffer[io_buffer_ptr] <= io_data;
                    io_tx_interrupt_buffer <= io_tx_interrupt;
                    io_buffer_ptr <= io_buffer_ptr + 1;
                end
            end
        end
    end

    reg [1:0] cpu_buffer_ptr;
    reg [SZ-1:0] cpu_addr_buffer[2];
    reg [WSZ-1:0] cpu_data_buffer[2];

    reg [WSZ-1:0] ram_write_data;
    assign ram_data = ram_w_notr ? ram_write_data : 'z;
    assign cpu_data = cpu_w_notr ? 'z : ram_data;

    reg [1:0] io_buffer_write_status;
    always @(posedge cpu_clk, negedge rst) begin
        if (!rst) begin
            cpu_buffer_ptr <= 0;
            cpu_rx_interrupt <= 0;
            ram_w_notr <= 0;
            io_buffer_write_status <= 0;
        end else begin
            if (cpu_tx_interrupt) begin
                $display($time, " dma : cpu tx interrupt => %d , %d ", cpu_addr, cpu_data);
                cpu_addr_buffer[cpu_buffer_ptr[0]] <= cpu_addr;
                cpu_data_buffer[cpu_buffer_ptr[0]] <= cpu_data;
                cpu_buffer_ptr <= cpu_buffer_ptr + 1;
                ram_w_notr <= 0;
            end else if (io_tx_interrupt_buffer && io_buffer_write_status < io_buffer_ptr) begin
                $display($time, " dma : io_deque mem[%d] = %x",
                         io_addr_buffer[io_buffer_write_status[1:0]],
                         io_data_buffer[io_buffer_write_status[1:0]]);
                ram_addr <= io_addr_buffer[io_buffer_write_status[1:0]];
                ram_write_data <= io_data_buffer[io_buffer_write_status[1:0]];
                ram_w_notr <= 1;
                io_buffer_write_status <= io_buffer_write_status + 1;
            end else begin
                // $monitor($time, " cpu: ", cpu_addr, cpu_data);
                $display($time, " dma : cpu_access mem[%d] =%d= %x", cpu_addr, cpu_w_notr,
                         cpu_data);
                ram_w_notr <= cpu_w_notr;
                ram_addr <= cpu_addr;
                ram_write_data <= cpu_data;
                if (io_buffer_write_status == io_buffer_ptr && |io_buffer_ptr) begin
                    cpu_rx_interrupt <= 1;
                    io_buffer_write_status <= 3;
                end
                if ($time > 100) begin
                    cpu_rx_interrupt <= 1;
                    io_buffer_write_status <= 3;
                end
            end
        end
    end

endmodule
