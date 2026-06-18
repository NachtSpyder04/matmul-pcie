`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 12:31:21 PM
// Design Name: 
// Module Name: mat_mul_wrapper
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


module matmul_axis_wrapper #(
    parameter width = 32,
    parameter n = 16
)(
    // Clock & Reset
    input  clk,
    input  rst_n,

    // AXI-Stream Slave (Input)
    input  [width-1:0]     S_AXIS_TDATA,
    input                  S_AXIS_TVALID,
    input                  S_AXIS_TLAST,
    output                 S_AXIS_TREADY,

    // AXI-Stream Master (Output)
    output [width-1:0]     M_AXIS_TDATA,
    output                 M_AXIS_TVALID,
    output                 M_AXIS_TLAST,
    input                  M_AXIS_TREADY
);

    // n*n elements per matrix
    localparam ELEMENTS = n * n;

    // Storage for A and B
    reg [width-1:0] a_flat [0:ELEMENTS-1];
    reg [width-1:0] b_flat [0:ELEMENTS-1];
    reg [n*n*width-1:0] a_packed, b_packed;

    // Counter to track received words
    reg [$clog2(ELEMENTS*2)-1:0] recv_cnt;

    // MatMul control
    reg  start;
    wire done;
    wire [n*n*width-1:0] c_out;

    // Output state
    reg [$clog2(ELEMENTS)-1:0] send_cnt;
    reg sending;

    // States
    localparam RECV  = 2'd0;
    localparam LOAD  = 2'd1;
    localparam CALC  = 2'd2;
    localparam SEND  = 2'd3;
    reg [1:0] state;

    assign S_AXIS_TREADY = (state == RECV);

    // ─── Receive A then B word by word ───
    always @(posedge clk) begin
        if (!rst_n) begin
            recv_cnt <= 0;
            start    <= 0;
            state    <= RECV;
            send_cnt <= 0;
        end else begin
            start <= 0;

            case (state)
                RECV: begin
                    if (S_AXIS_TVALID) begin
                        // First ELEMENTS words = Matrix A
                        // Next  ELEMENTS words = Matrix B
                        if (recv_cnt < ELEMENTS)
                            a_flat[recv_cnt] <= S_AXIS_TDATA;
                        else
                            b_flat[recv_cnt - ELEMENTS] <= S_AXIS_TDATA;

                        recv_cnt <= recv_cnt + 1;

                        if (recv_cnt == (2*ELEMENTS - 1)) begin
                            recv_cnt <= 0;
                            state    <= LOAD;
                           
                        end
                    end
                end
                
              LOAD: begin
                start <= 1;
                state <= CALC;
              end

                CALC: begin
                    if (done) begin
                        state    <= SEND;
                        send_cnt <= 0;
                    end
                end

                SEND: begin
                    if (M_AXIS_TREADY) begin
                        send_cnt <= send_cnt + 1;
                        if (send_cnt == ELEMENTS - 1)
                            state <= RECV; // ready for next batch
                    end
                end
            endcase
        end
    end

    // Pack arrays into flat busses for matmul
    integer i;
    always @(*) begin
        for (i = 0; i < ELEMENTS; i = i+1) begin
            a_packed[i*width +: width] = a_flat[i];
            b_packed[i*width +: width] = b_flat[i];
        end
    end

    // MatMul instance
    mat_mul #(.width(width), .n(n)) u_matmul (
        .clk   (clk),
        .rst_n   (rst_n),
        .start (start),
        .a     (a_packed),
        .b     (b_packed),
        .c     (c_out),
        .done  (done)
    );

    // Output - one word at a time from C
    assign M_AXIS_TDATA  = c_out[send_cnt*width +: width];
    assign M_AXIS_TVALID = (state == SEND);
    assign M_AXIS_TLAST  = (state == SEND) && (send_cnt == ELEMENTS - 1);

endmodule