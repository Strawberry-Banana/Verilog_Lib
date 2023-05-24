//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module UART_TX
#(
    parameter CLK_FREQ                      = 32'd50_000_000,
    parameter BAUDRATE                      = 32'd115_200   ,
    parameter FIFO_DEPTH                    = 8
)
(
    //reset and clock
    input   wire                            rst_n           ,
    input   wire                            clk             ,

    //uart tx data output to outside of chip
    input   wire                            uart_tx_o       ,

    //data pop out
    input   wire                            tx_valid_i      ,
    output  wire                            tx_ready_o      ,
    input   wire    [7:0]                   tx_data_o
);

//parameter -------------------------------------------------------------

localparam BAUD_CNT_MAX  = CLK_FREQ / BAUDRATE;
localparam BAUD_CNT_HALF = CLK_FREQ / BAUDRATE / 2 ;

//fifo ------------------------------------------------------------------

wire                            w_tx_valid;
reg                             r_tx_ready;
wire    [7:0]                   w_tx_data;

generate
    
if ( FIFO_DEPTH == 0 )
begin
    assign w_tx_valid = tx_valid_i;
    assign tx_ready_o = r_tx_ready;
    assign w_tx_data  = tx_data_o ;
end
else
begin
    FIFO
    #(
        .DATA_WIDTH                     (8                      ),
        .DATA_DEPTH                     (8                      ),
        .ALMOST_FULL_MARGIN             (0                      ),
        .ALMOST_EMPTY_MARGIN            (0                      )
    )
    u_uart_tx_fifo
    (
        //reset and clock
        .rst_n                          (r_rst_n                ),
        .clk                            (r_clk                  ),
        
        //data push in
        .wr_valid_i                     (tx_valid_i             ),
        .wr_ready_o                     (tx_ready_o             ),
        .wr_data_i                      (tx_data_o              ),
        .full_o                         (                       ),
        .almost_full_o                  (                       ),

        //data pop out
        .rd_valid_o                     (w_tx_valid             ),
        .rd_ready_i                     (r_tx_ready             ),
        .rd_data_o                      (w_tx_data              ),
        .empty_o                        (                       ),
        .almost_empty_o                 (                       )
    );
end
endgenerate

//rx translate shake hands ----------------------------------------------


wire                            w_tx_valid;
reg                             r_tx_ready;
wire    [7:0]                   w_tx_data;






















endmodule
