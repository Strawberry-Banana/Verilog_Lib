//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------


`timescale 1ns / 1ps

module fifo_tb ();

//parameter -------------------------------------------------------------

localparam DATA_WIDTH   = 10;


//reg and wire ----------------------------------------------------------

reg                             r_rst_n;
reg                             r_clk;

reg                             r_in_valid;
wire                            w_in_ready;
reg     [DATA_WIDTH-1:0]        r_in_data ;

wire                            w_out_valid;
reg                             r_out_ready;
wire    [DATA_WIDTH-1:0]        w_out_data ;

//connect ---------------------------------------------------------------

FIFO
#(
    .DATA_WIDTH                     (DATA_WIDTH             ),
    .DATA_DEPTH                     (8                      ),
    .ALMOST_FULL_MARGIN             (4                      ),
    .ALMOST_EMPTY_MARGIN            (1                      )
)
u_fifo
(
    //reset and clock
    .rst_n                          (r_rst_n                ),
    .clk                            (r_clk                  ),
    
    //data push in
    .wr_valid_i                     (r_in_valid             ),
    .wr_ready_o                     (w_in_ready             ),
    .wr_data_i                      (r_in_data              ),
    .full_o                         (                       ),
    .almost_full_o                  (                       ),

    //data pop out
    .rd_valid_o                     (w_out_valid            ),
    .rd_ready_i                     (r_out_ready            ),
    .rd_data_o                      (w_out_data             ),
    .empty_o                        (                       ),
    .almost_empty_o                 (                       )
);

//reset and clock logic -------------------------------------------------

always #5 r_clk = ~r_clk ;

initial
begin
    #0;
    r_clk       = 1'b1;
    r_rst_n     = 1'b0;

    #20;
    @ ( posedge r_clk )
    r_rst_n     = 1'b1;
end

//test logic ------------------------------------------------------------

reg     [64:0]                  r_clk_cnt;

always @ ( posedge r_clk or negedge r_rst_n )
begin
    if ( ~r_rst_n )
        r_clk_cnt <= 'd0;
    else
        r_clk_cnt <= r_clk_cnt + 'd1;
end

always @ ( posedge r_clk or negedge r_rst_n )
begin
    if ( ~r_rst_n )
        r_in_data <= 'd0;
        
    else if ( r_in_valid && w_in_ready )
        r_in_data <= r_in_data + 'd1;
end

always @ ( posedge r_clk or negedge r_rst_n )
begin
    if ( ~r_rst_n )
    begin
        r_in_valid  <= 1'b0;
        r_out_ready <= 1'b0;
    end
    else if (( 'd20 <= r_clk_cnt ) && ( r_clk_cnt <= 'd50 ))
    begin
        r_in_valid  <= 1'b1;
        r_out_ready <= 1'b0;
    end
    else if (( 'd60 <= r_clk_cnt ) && ( r_clk_cnt <= 'd80 ))
    begin
        r_in_valid  <= 1'b0;
        r_out_ready <= 1'b1;
    end
    else
    begin
        r_in_valid  <= 1'b1;
        r_out_ready <= 1'b1;
    end
end

endmodule