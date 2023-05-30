//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module TWINKLE_LED
#(
    parameter LED_ON_MODE                   = 1'b0          ,//1'b0: when output LOW, LED will on; 1'b1: when output HIGH, LED will on
    parameter CLK_FREQ                      = 50_000_000    ,
    parameter TWINKLE_PERIOD                = 1000           //unit:ms
)
(
    //reset and clock
    input   wire                            rst_n           ,
    input   wire                            clk             ,

    //LED
    input   wire                            en_i            ,
    output  wire                            led_o
);

//parameter -------------------------------------------------------------

localparam TWINKLE_CNT_MAX  = CLK_FREQ / 1000 * TWINKLE_PERIOD;
localparam TWINKLE_CNT_HALF = TWINKLE_CNT_MAX / 2;

//twinkle cnt -----------------------------------------------------------

reg     [31:0]                  r_twinkle_cnt;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_twinkle_cnt <= 'd0;

    else if ( r_twinkle_cnt == ( TWINKLE_CNT_MAX - 1 ))
        r_twinkle_cnt <= 'd0;

    else if ( en_i )
        r_twinkle_cnt <= r_twinkle_cnt + 'd1;
end

//twinkle ctrl ----------------------------------------------------------

reg                             r_led;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_led <= 'd0;

    else if ( en_i )
        r_led <= ( r_twinkle_cnt > TWINKLE_CNT_HALF );
end

//output ----------------------------------------------------------------

generate
    if ( LED_ON_MODE )
        assign led_o = r_led;
    else
        assign led_o = ~r_led;
endgenerate


endmodule