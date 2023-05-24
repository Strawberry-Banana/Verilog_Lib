//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module UART_RX
#(
    parameter CLK_FREQ                      = 32'd50_000_000,
    parameter BAUDRATE                      = 32'd115_200
)
(
    //reset and clock
    input   wire                            rst_n           ,
    input   wire                            clk             ,

    //uart rx data input from outside of chip
    input   wire                            uart_rx_i       ,

    //data pop out
    output  reg                             rx_valid_o      ,
    output  reg     [7:0]                   rx_data_o
);

//parameter -------------------------------------------------------------

localparam BAUD_CNT_MAX  = CLK_FREQ / BAUDRATE;
localparam BAUD_CNT_HALF = BAUD_CNT_MAX / 2 ;

//across clock domain and delay -----------------------------------------

reg     [2:0]                   r_rx_dly;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_rx_dly <= 3'd0; 

    else
        r_rx_dly <= {r_rx_dly[1:0],uart_rx_i};
end

//start bit -------------------------------------------------------------

wire                            w_start_bit_negedge;
assign w_start_bit_negedge = ( r_rx_dly[2] ) && ( ~r_rx_dly[1] );

//receive data control --------------------------------------------------

reg     [31:0]                  r_baud_cnt;
reg     [ 3:0]                  r_bit_cnt;
reg                             r_receive_flag;

always @ ( posedge clk or negedge rst_n ) 
begin
    if ( ~rst_n )
        r_receive_flag <= 1'd0; 

    else if ( w_start_bit_negedge )
        r_receive_flag <= 1'd1; 

    else if (( r_bit_cnt == 4'd9 ) && ( r_baud_cnt == BAUD_CNT_HALF ))
        r_receive_flag <= 1'd0;
end

always @ ( posedge clk or negedge rst_n ) 
begin
    if ( ~rst_n )
        r_baud_cnt <= 'd0; 

    else if ( ~r_receive_flag )
        r_baud_cnt <= 'd0; 

    else if ( r_baud_cnt >= ( BAUD_CNT_MAX - 1 ))
        r_baud_cnt <= 'd0;

    else
        r_baud_cnt <= r_baud_cnt + 'd1; 
end

always @ ( posedge clk or negedge rst_n ) 
begin
    if ( ~rst_n )
        r_bit_cnt <= 'd0; 

    else if ( ~r_receive_flag )
        r_bit_cnt <= 'd0; 

    else if ( r_baud_cnt == ( BAUD_CNT_MAX - 1 ))
        r_bit_cnt <= r_bit_cnt + 'd1; 
end

wire                            w_sample_pulse;
reg     [ 2:0]                  r_sample_bit;

assign w_sample_pulse = r_receive_flag && 
                        ( 4'd1 <= r_bit_cnt ) && ( r_bit_cnt <= 4'd8 ) && 
                        ( r_baud_cnt == BAUD_CNT_HALF );

//received data latch ---------------------------------------------------

reg     [7:0]                   r_receive_data;

always @ ( posedge clk or negedge rst_n ) 
begin
    if ( ~rst_n )
        r_receive_data <= 'd0; 

    else if ( ~r_receive_flag )
        r_receive_data <= 'd0; 

    else if ( w_sample_pulse )
        case ( r_bit_cnt )
            4'd1:    r_receive_data[0] <= r_rx_dly[2];
            4'd2:    r_receive_data[1] <= r_rx_dly[2];
            4'd3:    r_receive_data[2] <= r_rx_dly[2];
            4'd4:    r_receive_data[3] <= r_rx_dly[2];
            4'd5:    r_receive_data[4] <= r_rx_dly[2];
            4'd6:    r_receive_data[5] <= r_rx_dly[2];
            4'd7:    r_receive_data[6] <= r_rx_dly[2];
            4'd8:    r_receive_data[7] <= r_rx_dly[2];
            default: r_receive_data    <= r_receive_data;
        endcase
end

//output ----------------------------------------------------------------

always @ ( posedge clk or negedge rst_n ) 
begin
    if ( ~rst_n )
    begin
        rx_valid_o <= 1'd0;
        rx_data_o  <= 8'd0;
    end
    else if ( rx_valid_o )
    begin
        rx_valid_o <= 1'd0;
        rx_data_o  <= rx_data_o;
    end
    else if (( r_bit_cnt == 4'd8 ) && ( r_baud_cnt == ( BAUD_CNT_HALF + 1 )))
    begin
        rx_valid_o <= 1'd1;
        rx_data_o  <= r_receive_data;
    end
end

endmodule
