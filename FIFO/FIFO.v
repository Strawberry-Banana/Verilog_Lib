//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module FIFO
#(
    parameter DATA_WIDTH                    = 4             ,
    //must be power of 2, and at least 4
    parameter DATA_DEPTH                    = 8             ,
    //if connent to a ram, suggested value is 4; if set to 0, almost_full_o == full_o
    parameter ALMOST_FULL_MARGIN            = 4             ,
    //suggested value is 1; if set to 0, almost_empty_o == empty_o
    parameter ALMOST_EMPTY_MARGIN           = 1
)
(
    //reset and clock
    input   wire                            rst_n           ,
    input   wire                            clk             ,

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

localparam ADDR_WIDTH = $clog2( DATA_DEPTH );

//fifo ------------------------------------------------------------------

reg     [DATA_WIDTH-1:0]        r_fifo  [DATA_DEPTH-1:0];

reg     [ADDR_WIDTH  :0]        r_wr_addr;
reg     [ADDR_WIDTH  :0]        r_rd_addr;
wire    [ADDR_WIDTH  :0]        r_data_num;

//write in --------------------------------------------------------------

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_wr_addr <= 'd0;

    else if ( wr_valid_i && wr_ready_o )
        r_wr_addr <= r_wr_addr + 'd1;
end

always @ ( posedge clk )
begin
    if ( wr_valid_i && wr_ready_o )
        r_fifo[r_wr_addr[ADDR_WIDTH-1:0]] <= wr_data_i;
end

assign wr_ready_o = ( ~full_o );

//read out --------------------------------------------------------------

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
        r_rd_addr <= 'd0;

    else if ( rd_valid_o && rd_ready_i )
        r_rd_addr <= r_rd_addr + 'd1;
end

assign rd_data_o = r_fifo[r_rd_addr[ADDR_WIDTH-1:0]];

assign rd_valid_o = ( ~empty_o );

//full and empty --------------------------------------------------------

assign r_data_num     = r_wr_addr - r_rd_addr;

assign full_o         = ( r_data_num == DATA_DEPTH );
assign empty_o        = ( r_data_num == 'd0 );

assign almost_full_o  = ( r_data_num >= ( DATA_DEPTH - ALMOST_FULL_MARGIN ));
assign almost_empty_o = ( r_data_num <= ALMOST_EMPTY_MARGIN );

endmodule