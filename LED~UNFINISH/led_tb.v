//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

`timescale 1ns / 1ps

module led_tb ();

//parameter -------------------------------------------------------------

localparam LED_NUM = 5;

//reg and wire ----------------------------------------------------------

reg                             r_rst_n;
reg                             r_clk;

reg                             r_en;
wire    [LED_NUM-1:0]           w_led;

//connect ---------------------------------------------------------------

FLOW_LED
#(
    .LED_NUM                        (LED_NUM                ),
    .LED_ON_MODE                    (1'b0                   ),
    .CLK_FREQ                       (50_000_000             ),
    .FLOW_PERIOD                    (1                      ),
    .FLOW_MODE                      (2'd2                   )
)
u_led
(
    //reset and clock
    .rst_n                          (r_rst_n                ),
    .clk                            (r_clk                  ),

    //LED
    .en_i                           (r_en                   ),
    .led_o                          (w_led                  )
);


//reset and clock logic -------------------------------------------------

always #5 r_clk = ~r_clk ;

initial
begin
    #0;
    r_clk       = 1'b1;
    r_rst_n     = 1'b0;
    r_en        = 1'b0;

    #20;
    @ ( posedge r_clk )
    r_rst_n     = 1'b1;

    
    #100;
    @ ( posedge r_clk )
    r_en        = 1'b1;
end


endmodule