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
   
  wire [DATA_WIDTH-1:0] data_out;  
  wire full;  
  wire empty;  
   
  reg [DATA_WIDTH-1:0] data_in;  
  reg w_en, wclk, wrst_n;  
  reg r_en, rclk, rrst_n;  
  
  reg [DATA_WIDTH-1:0] wdata_q [0:255];   
  integer push_ptr;  
  integer pop_ptr;  
  reg [DATA_WIDTH-1:0] wdata;  
  reg [DATA_WIDTH-1:0] temp_data;  
  integer i; 
  
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
   
  always #10 wclk = ~wclk;
  always #35 rclk = ~rclk; 
   
  initial begin  
    wclk = 1'b0;   
    wrst_n = 1'b0;  
    w_en = 1'b0;  
    data_in = 0;  
    push_ptr = 0;  
   
    repeat(10) @(posedge wclk);  
    wrst_n <= 1'b1;  
  
    repeat(2) begin  
      for (i = 0; i < 30; i = i + 1) begin  
        @(posedge wclk);  
   
        while (full) begin  
          @(posedge wclk);  
        end  
   
        w_en <= (i % 2 == 0) ? 1'b1 : 1'b0;  
   
        if (i % 2 == 0) begin  
          temp_data = $random;  
          data_in <= temp_data;   
          wdata_q[push_ptr] = temp_data; 
          push_ptr = push_ptr + 1; 
        end  
      end  
      #50;  
    end  
  end  
  
  initial begin  
    rclk = 1'b0;   
    rrst_n = 1'b0;  
    r_en = 1'b0;  
    pop_ptr = 0;  
  
    repeat(20) @(posedge rclk);  
    rrst_n <= 1'b1;  
  
    repeat(2) begin  
      for (i = 0; i < 30; i = i + 1) begin  
        @(posedge rclk);  

        while (empty) begin  
          @(posedge rclk);  
        end  
   
        #1; 

        r_en <= (i % 2 == 0) ? 1'b1 : 1'b0;  
   
        if (i % 2 == 0) begin  
          wdata = wdata_q[pop_ptr];  
          pop_ptr = pop_ptr + 1;    
   
          if(data_out !== wdata)   
            $display("ERROR: Time = %0t: Comparison Failed: expected = %h, actual = %h", $time, wdata, data_out);  
          else   
            $display("SUCCESS: Time = %0t: Comparison Passed: expected = %h, actual = %h", $time, wdata, data_out);  
        end  
      end  
      #50;  
    end  
   
    #100;  
    $finish;  
  end  
   
endmodule
