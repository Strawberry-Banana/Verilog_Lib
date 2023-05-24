//-----------------------------------------------------------------------
// Author      : DZF
// Description : output is after DEND_W clock of input
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module PIPE_DIV_TOP
#(
    parameter DEND_W                        = 32           ,
    parameter SOR_W                         = 32
)
(
    //reset and clock
    input   wire                            rst_n           ,
    input   wire                            clk             ,

    //in
    input   wire                            valid_i         ,
    input   wire    [DEND_W-1:0]            dividend_i      ,
    input   wire    [SOR_W -1:0]            divisor_i       ,

    //out
    output  wire                            valid_o         ,
    output  wire    [DEND_W-1:0]            quotient_o      ,
    output  wire    [SOR_W -1:0]            remainder_o     
);

wire    [DEND_W+SOR_W-1:0]      w_dividend[DEND_W:0];
wire    [DEND_W+SOR_W-1:0]      w_divisor [DEND_W:0];
wire                            w_valid   [DEND_W:0];

assign w_dividend[0] = {{(SOR_W){1'd0}},dividend_i};
assign w_divisor [0] = {divisor_i,{(DEND_W){1'd0}}};
assign w_valid   [0] = valid_i;

genvar i;

generate
    for(i=0; i<DEND_W; i=i+1) begin : gen_div

        PIPE_DIV_CELL
        #(
            .DEND_W                         (DEND_W                 ),
            .SOR_W                          (SOR_W                  )
        )
        u_div
        (
            //reset and clock
            .rst_n                          (rst_n                  ),
            .clk                            (clk                    ),

            //in
            .valid_i                        (w_valid[i]             ),
            .dividend_i                     (w_dividend[i]          ),
            .divisor_i                      (w_divisor[i]           ),

            //out
            .valid_o                        (w_valid[i+1]           ),
            .dividend_o                     (w_dividend[i+1]        ),
            .divisor_o                      (w_divisor[i+1]         )
        );

    end
endgenerate

assign valid_o     = w_valid   [DEND_W];

assign quotient_o  = w_dividend[DEND_W][DEND_W-1:0];
assign remainder_o = w_dividend[DEND_W][DEND_W+SOR_W-1:DEND_W];

endmodule