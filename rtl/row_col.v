module row_col #(
    parameter width = 32,
    parameter n     = 16
)(
    input                       clk,
    input                       rst_n,
    input                       start,
    input  [n*width-1:0]        a,      // one row of A
    input  [n*width-1:0]        b,      // one col of B
    output reg [width-1:0]      c,
    output reg                  done
);

    localparam IDLE     = 2'd0;
    localparam CALC     = 2'd1;
    localparam WAIT_SUM = 2'd2;
    localparam OUT      = 2'd3;

    reg [1:0]              state;
    reg [$clog2(n)-1:0]    j;
    reg [2*width-1:0]      sum;   
    reg [2*width-1:0]      mult_reg;

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            j     <= 0;
            sum   <= 0;
            c     <= 0;
            done  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        sum   <= 0;
                        j     <= 0;
                        state <= CALC;
                    end
                end

                CALC: begin
                    // Accumulate current element
                    mult_reg <= a[j*width +: width] * b[j*width +: width];

                    if (j != 0)
                        sum <= sum + mult_reg;

                    if (j == n-1)
                        state <= WAIT_SUM;
                    else
                        j <= j + 1;
                    end
        
                WAIT_SUM: begin
                    sum <= sum + mult_reg;
                    state <= OUT;
                end 
             

                OUT: begin
                    c     <= sum[width-1:0];  // truncate to output width
                    done  <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule