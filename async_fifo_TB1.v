`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2026 13:59:10
// Design Name: 
// Module Name: async_fifo_TB1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
  
module async_fifo_TB;  
  
  parameter DATA_WIDTH = 8;  
  parameter DEPTH = 8;  
  
  // Wires for outputs from the instantiated module  
  wire [DATA_WIDTH-1:0] data_out;  
  wire full;  
  wire empty;  
   
  // Regs for driving inputs to the instantiated module  
  reg [DATA_WIDTH-1:0] data_in;  
  reg w_en, wclk, wrst_n;  
  reg r_en, rclk, rrst_n;  
  
  // Standard Verilog Array to act as a scoreboard (Queue replacement)  
  reg [DATA_WIDTH-1:0] wdata_q [0:255];   
  integer push_ptr;  
  integer pop_ptr;  
  reg [DATA_WIDTH-1:0] wdata;  
  reg [DATA_WIDTH-1:0] temp_data;  
  integer i; // Loop variable  
  
  // Instantiate the Top Module (DUT - Design Under Test)  
  asynchronous_fifo #(  
    .DEPTH(DEPTH),  
    .DATA_WIDTH(DATA_WIDTH)  
  ) as_fifo (  
    .wclk(wclk),   
    .wrst_n(wrst_n),  
    .rclk(rclk),   
    .rrst_n(rrst_n),  
    .w_en(w_en),  
    .r_en(r_en),  
    .data_in(data_in),  
    .data_out(data_out),  
    .full(full),  
    .empty(empty)  
  );  
  
  // Clock generation (Asynchronous frequencies)  
  always #10 wclk = ~wclk; // 50 MHz write clock  
  always #35 rclk = ~rclk; // ~14.2 MHz read clock  
   
  // ==========================================
  // Write Domain Stimulus (The Producer)
  // ==========================================
  initial begin  
    wclk = 1'b0;   
    wrst_n = 1'b0;  
    w_en = 1'b0;  
    data_in = 0;  
    push_ptr = 0;  
   
    // Hold reset for a few clock cycles  
    repeat(10) @(posedge wclk);  
    wrst_n <= 1'b1;  
  
    repeat(2) begin  
      for (i = 0; i < 30; i = i + 1) begin  
        @(posedge wclk);  
   
        // Wait while the FIFO is full  
        while (full) begin  
          @(posedge wclk);  
        end  
   
        // Drive write enable  
        w_en <= (i % 2 == 0) ? 1'b1 : 1'b0;  
   
        if (i % 2 == 0) begin  
          temp_data = $random;  
          data_in <= temp_data;   
          wdata_q[push_ptr] = temp_data; // Push expected data to array  
          push_ptr = push_ptr + 1;       // Increment array pointer  
        end  
      end  
      #50;  
    end  
  end  
  
  // ==========================================
  // Read Domain Stimulus and Verification
  // ==========================================
  initial begin  
    rclk = 1'b0;   
    rrst_n = 1'b0;  
    r_en = 1'b0;  
    pop_ptr = 0;  
  
    // Hold reset slightly longer to ensure staggered startup  
    repeat(20) @(posedge rclk);  
    rrst_n <= 1'b1;  
  
    repeat(2) begin  
      for (i = 0; i < 30; i = i + 1) begin  
        @(posedge rclk);  
   
        // Wait while the FIFO is empty  
        while (empty) begin  
          @(posedge rclk);  
        end  
   
        // NEW FIX: Wait 1ns AFTER the clock edge to let the FIFO RAM output settle
        #1; 

        r_en <= (i % 2 == 0) ? 1'b1 : 1'b0;  
   
        if (i % 2 == 0) begin  
          wdata = wdata_q[pop_ptr]; // Get the oldest expected data  
          pop_ptr = pop_ptr + 1;    // Increment array pointer  
   
          // Verify data_out against the expected wdata  
          if(data_out !== wdata)   
            $display("ERROR: Time = %0t: Comparison Failed: expected = %h, actual = %h", $time, wdata, data_out);  
          else   
            $display("SUCCESS: Time = %0t: Comparison Passed: expected = %h, actual = %h", $time, wdata, data_out);  
        end  
      end  
      #50;  
    end  
   
    // End simulation  
    #100;  
    $finish;  
  end  
   
endmodule