//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module FLOW_LED
#(
    parameter LED_NUM                       = 8             ,
    parameter LED_ON_MODE                   = 1'b0          ,//1'b0: when output LOW, LED will on; 1'b1: when output HIGH, LED will on
    parameter CLK_FREQ                      = 50_000_000    ,
    parameter FLOW_PERIOD                   = 1000          ,//unit:ms
    parameter FLOW_MODE                     = 2'd0           //0: LOW 2 HIGH; 1: HIGH 2 LOW; 2: TWO SIDE
)
(
    //reset and clock
    input   wire                            rst_n           ,
    input   wire                            clk             ,

    //LED
    input   wire                            en_i            ,
    output  wire    [LED_NUM-1:0]           led_o
);

//parameter -------------------------------------------------------------

localparam FLOW_CNT_MAX = CLK_FREQ / 1000 * FLOW_PERIOD;

//flow cnt --------------------------------------------------------------

reg     [31:0]                  r_flow_cnt;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_flow_cnt <= 'd0; 

    else if ( r_flow_cnt == ( FLOW_CNT_MAX - 1 ))
        r_flow_cnt <= 'd0; 
        
    else if ( en_i )
        r_flow_cnt <= r_flow_cnt + 'd1; 
end

//enable posedge detect -------------------------------------------------

reg                             r_en_dly;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_en_dly <= 'd0; 
    else
        r_en_dly <= en_i;
end

wire                            w_en_posedge;
assign w_en_posedge = en_i && ( ~r_en_dly );

//flow ctrl -------------------------------------------------------------

reg                             r_direction; //0: LOW 2 HIGH; 1: HIGH 2 LOW
reg     [LED_NUM-1:0]           r_led;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_direction <= 1'd0; 

    else if ( FLOW_MODE == 2'd0 )
        r_direction <= 1'd0;

    else if ( FLOW_MODE == 2'd1 )
        r_direction <= 1'd1;

    else if (( FLOW_MODE == 2'd2 ) && ( r_flow_cnt == ( FLOW_CNT_MAX - 2 )))
    begin
        if ( r_led[0] )
            r_direction <= 1'd0;
        else if ( r_led[LED_NUM-1] )
            r_direction <= 1'd1;
    end
end


always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_led <= 'd0; 

    else if ( w_en_posedge )
    begin
        if ( r_led == 'd0 ) 
        begin
            if ( FLOW_MODE == 2'd1 )
                r_led <= {1'd1,{(LED_NUM-1){1'd0}}} ;
            else
                r_led <= {{(LED_NUM-1){1'd0}},1'd1} ;
        end
        else 
            r_led <= r_led;
    end
    else if ( en_i && ( r_flow_cnt == ( FLOW_CNT_MAX - 1 )))
    begin
        if ( ~r_direction )
            r_led <= {r_led[LED_NUM-2:0],r_led[LED_NUM-1]};
        else
            r_led <= {r_led[0],r_led[LED_NUM-1:1]};
    end
end

//output -------------------------------------------------------------

generate
    if ( LED_ON_MODE )
        assign led_o = r_led;
    else
        assign led_o = ~r_led;
endgenerate


endmodule