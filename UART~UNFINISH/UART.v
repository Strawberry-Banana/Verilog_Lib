//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module UART
#(
    parameter CLK_FREQ                      = 32'd50_000_000,
    parameter BAUDRATE                      = 32'd115_200   ,
    parameter ENABLE_RX                     = 1             ,
    parameter ENABLE_TX                     = 1
)
(
    //reset and clock
    input   wire                            rst_n           ,
    input   wire                            clk             ,

    //rx data
    input   wire                            uart_rx_i       ,
    output  reg                             rx_valid_o      ,
    output  reg     [7:0]                   rx_data_o       ,

    //tx data
    input   wire                            uart_tx_o       ,
    input   wire                            tx_valid_i      ,
    output  wire                            tx_ready_o      ,
    input   wire    [7:0]                   tx_data_o
);











endmodule