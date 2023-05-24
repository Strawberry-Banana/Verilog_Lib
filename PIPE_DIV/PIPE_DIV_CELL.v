//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module PIPE_DIV_CELL
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
    input   wire    [DEND_W+SOR_W-1:0]      dividend_i      ,//dividend from last cell
    input   wire    [DEND_W+SOR_W-1:0]      divisor_i       ,//divisor from last cell

    //out
    output  reg                             valid_o         ,
    output  reg     [DEND_W+SOR_W-1:0]      dividend_o      ,
    output  reg     [DEND_W+SOR_W-1:0]      divisor_o       
);

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n )
        valid_o <= 1'd0;

    else
        valid_o <= valid_i;
end

wire    [DEND_W+SOR_W-1:0]      w_dividend_shift;
assign w_dividend_shift = {dividend_i[DEND_W+SOR_W-2:0], 1'd0};

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n )begin
        dividend_o <= 'd0;
        divisor_o  <= 'd0;
    end
    else if ( valid_i ) begin
        dividend_o <= ( w_dividend_shift >= divisor_i ) ? ( w_dividend_shift - divisor_i + 1'd1 ) : w_dividend_shift;
        divisor_o  <= divisor_i;
    end
end

endmodule