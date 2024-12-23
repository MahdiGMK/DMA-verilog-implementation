module testbench;
    localparam int SZ = 8;  // ram size
    localparam int WSZ = 8;  // word size
    reg [SZ-1:0] ram_address;
    reg ram_w_notr;
    reg [WSZ-1:0] ram_write_data;
    wire [WSZ-1:0] ram_data = ram_w_notr ? ram_write_data : 'z;
    dma _dma ();
    cpu _cpu ();
    ram #(
        .SZ (SZ),
        .WSZ(WSZ)
    ) _ram (
        .addr  (ram_address),
        .w_notr(ram_w_notr),
        .data  (ram_data)
    );
    io _io ();
    initial begin

    end
endmodule
