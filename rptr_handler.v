`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2026 12:14:08
// Design Name: 
// Module Name: rptr_handler
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
module rptr_handler #(parameter PTR_WIDTH=3)(
input rclk,rrst_n,r_en,
input [PTR_WIDTH:0] g_wptr_sync,
output reg [PTR_WIDTH:0] b_rptr,g_rptr,
output reg empty
    );
    
    wire [PTR_WIDTH:0] b_rptr_next;
    wire [PTR_WIDTH:0] g_rptr_next;
    
    assign b_rptr_next=b_rptr+(!empty&r_en);
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
    assign rempty = (g_wptr_sync == g_rptr_next);

    
    always @(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) begin
    b_rptr<=0;
    g_rptr<=0;
    end
    
    else begin
    b_rptr<=b_rptr_next;
    g_rptr<=g_rptr_next;
    end 
    end
    
    always @(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) empty<=1;
    else empty<=rempty;
    end    
endmodule
