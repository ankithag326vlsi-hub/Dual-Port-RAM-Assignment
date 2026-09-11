
`timescale 1ns/1ps

module tb_memory_test;

    // Parameters
    parameter DataWidth = 32;
    parameter DataDepth = 256;
    parameter AddrWidth = 8;

    // Write Port A signals
    reg write_clk;
    reg write_en;
    reg [AddrWidth-1:0] write_addr;
    reg [DataWidth-1:0] write_data;
    reg [DataWidth-1:0] write_mask;

    // Read Port B signals
    reg read_clk;
    reg read_en;
    reg [AddrWidth-1:0] read_addr;
    wire [DataWidth-1:0] read_data;

    // Variables
    integer i;
    integer errors;


    // DUT - Dual Port RAM
    ram_dp #(
        .DataWidth(DataWidth),
        .DataDepth(DataDepth),
        .AddrWidth(AddrWidth),
        .MaskEnable(0),
        .VendorImpl("")
    ) dut (
        .write_clk(write_clk),
        .write_en(write_en),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_mask(write_mask),

        .read_clk(read_clk),
        .read_en(read_en),
        .read_addr(read_addr),
        .read_data(read_data)
    );


    // Write clock
    initial begin
        write_clk = 0;
        forever #5 write_clk = ~write_clk;
    end


    // Read clock
    initial begin
        read_clk = 0;
        forever #5 read_clk = ~read_clk;
    end


    // Main Test
    initial begin

        // Initial values
        write_en   = 0;
        read_en    = 0;
        write_addr = 0;
        read_addr  = 0;
        write_data = 0;
        write_mask = 0;
        errors     = 0;


        // =====================================
        // STEP 1: WRITE ALL 256 LOCATIONS
        // =====================================

        $display("--------------------------------");
        $display("STARTING MEMORY WRITE TEST");
        $display("--------------------------------");

        for (i = 0; i < 256; i = i + 1) begin

            @(negedge write_clk);

            write_en   = 1;
            write_addr = i;
            write_data = i;

        end

        // Wait for last write
        @(negedge write_clk);

        write_en = 0;


        // =====================================
        // STEP 2: READ AND CHECK ALL LOCATIONS
        // =====================================

        $display("--------------------------------");
        $display("STARTING MEMORY READ TEST");
        $display("--------------------------------");

        for (i = 0; i < 256; i = i + 1) begin

            // Apply read address
            @(negedge read_clk);

            read_en   = 1;
            read_addr = i;

            // Wait for read clock positive edge
            @(posedge read_clk);

            #1;

            // Compare expected and received data
            if (read_data !== i) begin

                errors = errors + 1;

                $display(
                    "ERROR: Address = %0d Expected = %h Received = %h",
                    i,
                    i,
                    read_data
                );

            end

        end


        // Disable read
        @(negedge read_clk);

        read_en = 0;


        // =====================================
        // RESULT
        // =====================================

        $display("--------------------------------");
        $display("MEMORY TEST COMPLETE");
        $display("Addresses tested : 256");
        $display("Errors : %0d", errors);

        if (errors == 0)
            $display("RESULT : PASS");
        else
            $display("RESULT : FAIL");

        $display("--------------------------------");

        #20;
        $finish;

    end

endmodule
