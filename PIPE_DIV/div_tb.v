//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

`timescale 1ns / 1ps

module div_tb ();

//parameter -------------------------------------------------------------

localparam DEND_W = 16;
localparam SOR_W  = 10;

//reg and wire ----------------------------------------------------------

reg                             r_rst_n;
reg                             r_clk;

reg                             r_in_valid;
reg     [DEND_W-1:0]            r_dividend;
reg     [SOR_W -1:0]            r_divisor ;

wire                            w_out_valid;
wire    [DEND_W-1:0]            w_quotient ;
wire    [SOR_W -1:0]            w_remainder;

//connect ---------------------------------------------------------------

PIPE_DIV_TOP
#(
    .DEND_W                         (DEND_W                 ),
    .SOR_W                          (SOR_W                  )
)
u_div_top
(
    //reset and clock
    .rst_n                          (r_rst_n                ),
    .clk                            (r_clk                  ),

    //in
    .valid_i                        (r_in_valid             ),
    .dividend_i                     (r_dividend             ),
    .divisor_i                      (r_divisor              ),

    //out
    .valid_o                        (w_out_valid            ),
    .quotient_o                     (w_quotient             ),
    .remainder_o                    (w_remainder            )
);

//reset and clock logic -------------------------------------------------

always #5 r_clk = ~r_clk ;

initial
begin
    #0;
    r_clk       = 1'b1;
    r_rst_n     = 1'b0;
    r_in_valid  = 1'b0;

    #20;
    @ ( posedge r_clk )
    r_rst_n     = 1'b1;
    r_in_valid  = 1'b1;
end

//test logic ------------------------------------------------------------

always @ ( posedge r_clk or negedge r_rst_n )
begin
    if ( ~r_rst_n ) begin
        r_dividend <= 'd0;
        r_divisor  <= 'd0;
    end
    else if ( r_in_valid ) begin
        r_dividend <= r_dividend + 'd3;
        r_divisor  <= r_divisor  + 'd2;
    end
end

integer i;

reg     [DEND_W-1:0]            r_dividend_dly[DEND_W:0];
reg     [SOR_W -1:0]            r_divisor_dly [DEND_W:0];

always @ ( posedge r_clk or negedge r_rst_n )
begin
    if ( ~r_rst_n )
        for(i=0; i<=SOR_W; i=i+1) begin
            r_dividend_dly[i] <= 'd0;
            r_divisor_dly [i] <= 'd0;
        end
    else if ( r_in_valid ) begin
        
        r_dividend_dly[0] <= r_dividend;
        r_divisor_dly [0] <= r_divisor ;

        for(i=0; i<DEND_W; i=i+1) begin
            r_dividend_dly[i+1] <= r_dividend_dly[i];
            r_divisor_dly [i+1] <= r_divisor_dly [i];
        end
    end
end

wire    [DEND_W-1:0]            w_tb_quotient ;
wire    [SOR_W -1:0]            w_tb_remainder;

assign w_tb_quotient  = r_dividend_dly[DEND_W-1] / r_divisor_dly[DEND_W-1];
assign w_tb_remainder = r_dividend_dly[DEND_W-1] % r_divisor_dly[DEND_W-1];

wire                            w_right;
assign w_right = ( w_tb_quotient == w_quotient ) && ( w_tb_remainder == w_remainder );

endmodule