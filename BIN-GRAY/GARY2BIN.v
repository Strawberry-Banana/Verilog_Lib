//-----------------------------------------------------------------------
// Author      : DZF
// Description :
// Notes       :
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module GRAY2BIN
#(
    parameter DATA_WIDTH                = 4
)
(
    input   wire    [DATA_WIDTH-1:0]    gray_data_i,
    output  wire    [DATA_WIDTH-1:0]    bin_data_o
);

assign bin_data_o[DATA_WIDTH-1] = gray_data_i[DATA_WIDTH-1];

genvar i;

generate

    for  (i=0; i<DATA_WIDTH-1; i=i+1)
    begin : gen_gary2bin

        assign bin_data_o[i] = bin_data_o[i+1] ^ gray_data_i[i];

    end

endgenerate

endmodule