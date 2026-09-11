
`timescale 1ns/1ps

module tb_basic;

    // Parameters
    parameter DataWidth = 32;
    parameter DataDepth = 256;
    parameter AddrWidth = 8;

    // Write Port (Port A) signals
    reg write_clk;
    reg write_en;
    reg [AddrWidth-1:0] write_addr;
    reg [DataWidth-1:0] write_data;
    reg [DataWidth-1:0] write_mask;

    // Read Port (Port B) signals
    reg read_clk;
    reg read_en;
    reg [AddrWidth-1:0] read_addr;
    wire [DataWidth-1:0] read_data;


    // RAM Instantiation
    ram_dp #(
        .DataWidth(DataWidth),
        .DataDepth(DataDepth),
        .AddrWidth(AddrWidth),
        .MaskEnable(0),
        .VendorImpl("")
    ) dut (

        // Port A - Write
        .write_clk(write_clk),
        .write_en(write_en),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_mask(write_mask),

        // Port B - Read
        .read_clk(read_clk),
        .read_en(read_en),
        .read_addr(read_addr),
        .read_data(read_data)
    );


    // Write Clock
    initial begin
        write_clk = 0;
        forever #5 write_clk = ~write_clk;
    end


    // Read Clock
    initial begin
        read_clk = 0;
        forever #5 read_clk = ~read_clk;
    end


    // Test
    initial begin

        // Initial values
        write_en   = 0;
        read_en    = 0;
        write_addr = 0;
        read_addr  = 0;
        write_data = 0;
        write_mask = 0;


        // Test 1: Write ABCD1234 to Address 10
        @(negedge write_clk);

        write_en   = 1;
        write_addr = 8'd10;
        write_data = 32'hABCD1234;

        @(negedge write_clk);

        write_en = 0;


        // Test 1: Read Address 10 using Port B
        @(negedge read_clk);

        read_en   = 1;
        read_addr = 8'd10;

        @(negedge read_clk);

        read_en = 0;


        // Test 2: Write 12345678 to Address 20
        @(negedge write_clk);

        write_en   = 1;
        write_addr = 8'd20;
        write_data = 32'h12345678;

        @(negedge write_clk);

        write_en = 0;


        // Test 2: Read Address 20 using Port B
        @(negedge read_clk);

        read_en   = 1;
        read_addr = 8'd20;

        @(negedge read_clk);

        read_en = 0;


        // Test 3: Different addresses through both ports

        // Write to Address 30
        @(negedge write_clk);

        write_en   = 1;
        write_addr = 8'd30;
        write_data = 32'hAAAAAAAA;

        // At the same time read Address 10
        read_en   = 1;
        read_addr = 8'd10;

        @(negedge write_clk);

        write_en = 0;

        #20;

        read_en = 0;


        #20;

        $finish;

    end

endmodule
