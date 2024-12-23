module ram_test;
    localparam int SZ = 8;  // ram size
    localparam int WSZ = 8;  // word size
    reg [SZ-1:0] ram_address;
    reg ram_w_notr;
    reg [WSZ-1:0] ram_write_data;
    wire [WSZ-1:0] ram_data = ram_w_notr ? ram_write_data : 'z;
    ram #(
        .SZ (SZ),
        .WSZ(WSZ)
    ) _ram (
        .addr  (ram_address),
        .w_notr(ram_w_notr),
        .data  (ram_data)
    );
    initial begin
        $monitor("%t ram[%x] = %x", $time, ram_address, ram_data);
        ram_w_notr  = 0;
        ram_address = 0;

        #1 ram_w_notr = 1;
        ram_address = 0;
        ram_write_data = 1;
        #1 ram_w_notr = 0;

        #1 ram_w_notr = 1;
        ram_address = 1;
        ram_write_data = 2;
        #1 ram_w_notr = 0;

        #1 ram_w_notr = 1;
        ram_address = 2;
        ram_write_data = 3;
        #1 ram_w_notr = 0;

        #1 ram_w_notr = 0;
        ram_address = 3;

        #1 ram_w_notr = 0;
        ram_address = 2;

        #1 ram_w_notr = 0;
        ram_address = 1;

        #1 ram_w_notr = 0;
        ram_address = 0;
    end
endmodule
