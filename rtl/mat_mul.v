module mat_mul #(
    parameter width = 32,
    parameter n     =16 
)(
    input                       clk,
    input                       rst_n,
    input                       start,
    input  [n*n*width-1:0]      a,
    input  [n*n*width-1:0]      b,
    output [n*n*width-1:0]      c,
    output                      done
);

    wire [width-1:0]   c_reg    [0:n-1][0:n-1];  
    wire               done_reg [0:n-1][0:n-1];

    assign done = &{done_reg[0][0], done_reg[0][1], done_reg[0][2],
                    done_reg[1][0], done_reg[1][1], done_reg[1][2],
                    done_reg[2][0], done_reg[2][1], done_reg[2][2]};

    genvar i, j;
    generate
        for (i = 0; i < n; i = i + 1) begin : ROW
            for (j = 0; j < n; j = j + 1) begin : COL

                // Extract row i of A
                wire [n*width-1:0] a_row;
                // Extract col j of B
                wire [n*width-1:0] b_col;

                genvar k;
                for (k = 0; k < n; k = k + 1) begin : EXTRACT
                    assign a_row[k*width +: width] = a[(i*n + k)*width +: width];
                    assign b_col[k*width +: width] = b[(k*n + j)*width +: width];
                end

                row_col #(.width(width), .n(n)) u_rc (
                    .clk   (clk),
                    .rst_n   (rst_n),
                    .start (start),
                    .a     (a_row),
                    .b     (b_col),
                    .c     (c_reg[i][j]),
                    .done  (done_reg[i][j])
                );

                assign c[(i*n + j)*width +: width] = c_reg[i][j];
            end
        end
    endgenerate

endmodule