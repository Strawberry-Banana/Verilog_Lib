//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module ASYNC_FIFO
#(
    parameter DATA_WIDTH                    = 4             ,
    //must be power of 2, and at least 8
    parameter DATA_DEPTH                    = 8             ,
    //if connent to a ram, suggested value is 4; if set to 0, almost_full_o == full_o
    parameter ALMOST_FULL_MARGIN            = 4             ,
    //suggested value is 1; if set to 0, almost_empty_o == empty_o
    parameter ALMOST_EMPTY_MARGIN           = 1
)
(
    //reset and clock
    input   wire                            wr_rst_n        ,
    input   wire                            wr_clk          ,
    input   wire                            rd_rst_n        ,
    input   wire                            rd_clk          ,

    //data push in
    input   wire                            wr_valid_i      ,
    output  wire                            wr_ready_o      ,//wr_ready_o == ~full_o
    input   wire    [DATA_WIDTH-1:0]        wr_data_i       ,
    output  wire                            full_o          ,
    output  wire                            almost_full_o   ,

    //data pop out
    output  wire                            rd_valid_o      ,//rd_valid_o == ~empty_o
    input   wire                            rd_ready_i      ,
    output  wire    [DATA_WIDTH-1:0]        rd_data_o       ,
    output  wire                            empty_o         ,
    output  wire                            almost_empty_o
);

//parameter -------------------------------------------------------------

//to use gary code, must plus 2
localparam ADDR_WIDTH = $clog2( DATA_DEPTH ) + 1;

//fifo ------------------------------------------------------------------

reg     [DATA_WIDTH-1:0]        r_fifo  [DATA_DEPTH-1:0];

reg     [ADDR_WIDTH-1:0]        r_wr_addr;
wire    [ADDR_WIDTH-1:0]        w_wr_addr_gray;
reg     [ADDR_WIDTH-1:0]        r_wr_addr_gray_dly1;
reg     [ADDR_WIDTH-1:0]        r_wr_addr_gray_dly2;
wire    [ADDR_WIDTH-1:0]        w_wr_addr_dly2;

reg     [ADDR_WIDTH-1:0]        r_rd_addr;
wire    [ADDR_WIDTH-1:0]        w_rd_addr_gray;
reg     [ADDR_WIDTH-1:0]        r_rd_addr_gray_dly1;
reg     [ADDR_WIDTH-1:0]        r_rd_addr_gray_dly2;
wire    [ADDR_WIDTH-1:0]        w_rd_addr_dly2;

//write in --------------------------------------------------------------

always @ ( posedge wr_clk or negedge wr_rst_n )
begin
    if ( ~wr_rst_n )
        r_wr_addr <= 'd0;

    else if ( wr_valid_i && wr_ready_o )
        r_wr_addr <= r_wr_addr + 'd1;
end

always @ ( posedge wr_clk )
begin
    if ( wr_valid_i && wr_ready_o )
        r_fifo[r_wr_addr[ADDR_WIDTH-2:0]] <= wr_data_i;
end

assign wr_ready_o = ( ~full_o );

//read out --------------------------------------------------------------

always @ ( posedge rd_clk or negedge rd_rst_n )
begin
    if ( ~rd_rst_n )
        r_rd_addr <= 'd0;

    else if ( rd_valid_o && rd_ready_i )
        r_rd_addr <= r_rd_addr + 'd1;
end

assign rd_data_o = r_fifo[r_rd_addr[ADDR_WIDTH-2:0]];

assign rd_valid_o = ( ~empty_o );

//gray sync --------------------------------------------------------------

BIN2GRAY
#(
    .DATA_WIDTH                     (ADDR_WIDTH             )
)
u_wr_addr_gray
(
    .bin_data_i                     (r_wr_addr              ),
    .gray_data_o                    (w_wr_addr_gray         )
);

BIN2GRAY
#(
    .DATA_WIDTH                     (ADDR_WIDTH             )
)
u_rd_addr_gray
(
    .bin_data_i                     (r_rd_addr              ),
    .gray_data_o                    (w_rd_addr_gray         )
);

always @ ( posedge rd_clk or negedge wr_rst_n )
begin
    if ( ~wr_rst_n )
    begin
        r_wr_addr_gray_dly1 <= 'd0;
        r_wr_addr_gray_dly2 <= 'd0;
    end
    else
    begin
        r_wr_addr_gray_dly1 <= w_wr_addr_gray;
        r_wr_addr_gray_dly2 <= r_wr_addr_gray_dly1;
    end
end

always @ ( posedge wr_clk or negedge rd_rst_n )
begin
    if ( ~rd_rst_n )
    begin
        r_rd_addr_gray_dly1 <= 'd0;
        r_rd_addr_gray_dly2 <= 'd0;
    end
    else
    begin
        r_rd_addr_gray_dly1 <= w_rd_addr_gray;
        r_rd_addr_gray_dly2 <= r_rd_addr_gray_dly1;
    end
end

//full and empty --------------------------------------------------------

assign full_o  = ( w_wr_addr_gray == { ( ~r_rd_addr_gray_dly2[ADDR_WIDTH-1:ADDR_WIDTH-2] ), r_rd_addr_gray_dly2[ADDR_WIDTH-3:0] } );
assign empty_o = ( w_rd_addr_gray == r_wr_addr_gray_dly2 );

//almost full -----------------------------------------------------------

generate

    if ( ALMOST_FULL_MARGIN != 0 )
    begin

        GRAY2BIN
        #(
            .DATA_WIDTH                     (ADDR_WIDTH             )
        )
        u_rd_addr_gray
        (
            .gray_data_i                    (r_rd_addr_gray_dly2    ),
            .bin_data_o                     (w_rd_addr_dly2         )
        );

        assign almost_full_o = (( r_wr_addr + ALMOST_FULL_MARGIN ) == w_rd_addr_dly2 );

    end
    else
    begin
        assign almost_full_o = full_o;
    end

endgenerate

//almost empty ----------------------------------------------------------

generate

    if ( ALMOST_EMPTY_MARGIN != 0 )
    begin

        GRAY2BIN
        #(
            .DATA_WIDTH                     (ADDR_WIDTH             )
        )
        u_wr_addr_gray
        (
            .gray_data_i                    (r_wr_addr_gray_dly2    ),
            .bin_data_o                     (w_wr_addr_dly2         )
        );
        
        assign almost_empty_o = (( r_rd_addr + ALMOST_EMPTY_MARGIN ) == r_wr_addr_gray_dly2 );

    end
    else
    begin
        assign almost_empty_o = empty_o;
    end

endgenerate


endmodule