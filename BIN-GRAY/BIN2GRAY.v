//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module BIN2GRAY
#(
    parameter DATA_WIDTH                = 4
)
(
    input   wire    [DATA_WIDTH-1:0]    bin_data_i,
    output  wire    [DATA_WIDTH-1:0]    gray_data_o
);

assign gray_data_o = bin_data_i ^ ( bin_data_i >> 1 );

endmodule