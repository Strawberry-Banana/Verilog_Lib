//-----------------------------------------------------------------------
// Author      : DZF
// Description : 13 interations: tanθ(k) = 1/2^k, k = 0~12
//               product of all the csoθ approximatively equal to 1244/2048
//               angle positive:     clockwise, i' = cosθ * ( i + q*tanθ ), q' = cosθ * ( q - i*tanθ ), θ' = θ - θ(k)
//               angle negative: anticlockwise, i' = cosθ * ( i - q*tanθ ), q' = cosθ * ( q + i*tanθ ), θ' = θ + θ(k)
// Notes       : output 7 clocks behind input
//-----------------------------------------------------------------------
// Revision    : v0.1
//-----------------------------------------------------------------------

module CORDIC
(
    //reset and clock
    input   wire                    rst_n,
    input   wire                    clk,

    //if run == 0, pause
    input   wire                    run_i,

    //status
    input   wire                    r965_flag_i,

    //sc input
    input   wire    [16:0]          idata_i,
    input   wire    [16:0]          qdata_i,

    input   wire    [14:0]          angle_i,

    //sc output
    output  wire    [15:0]          idata_o,
    output  wire    [15:0]          qdata_o
);

//1 clk delay: rotate 1/2^0 and 1/2^1 -----------------------------------
wire    [17:0]      w_rot0_i_add_q;
wire    [17:0]      w_rot0_i_minus_q;
wire    [17:0]      w_rot0_q_add_i;
wire    [17:0]      w_rot0_q_minus_i;
wire    [14:0]      w_rot0_add_half;
wire    [14:0]      w_rot0_minus_half;
wire    [17:0]      w_rot0_i;
wire    [17:0]      w_rot0_q;
wire    [14:0]      w_rot0_angle;

wire    [17:0]      w_rot1_i_add_q;
wire    [17:0]      w_rot1_i_minus_q;
wire    [17:0]      w_rot1_q_add_i;
wire    [17:0]      w_rot1_q_minus_i;
wire    [14:0]      w_rot1_add_half;
wire    [14:0]      w_rot1_minus_half;
wire    [17:0]      w_rot1_i;
wire    [17:0]      w_rot1_q;
wire    [14:0]      w_rot1_angle;

reg     [17:0]      r_rot1_i;
reg     [17:0]      r_rot1_q;
reg     [14:0]      r_rot1_angle;

//rotate 1/2^0
assign  w_rot0_i_add_q      = {idata_i[16],idata_i} + {qdata_i[16],qdata_i};
assign  w_rot0_i_minus_q    = {idata_i[16],idata_i} - {qdata_i[16],qdata_i};
assign  w_rot0_q_add_i      = {qdata_i[16],qdata_i} + {idata_i[16],idata_i};
assign  w_rot0_q_minus_i    = {qdata_i[16],qdata_i} - {idata_i[16],idata_i};
assign  w_rot0_add_half     = angle_i + 15'd4095;
assign  w_rot0_minus_half   = angle_i - 15'd4095;
assign  w_rot0_i            = angle_i[14] ? w_rot0_i_add_q   : w_rot0_i_minus_q  ;
assign  w_rot0_q            = angle_i[14] ? w_rot0_q_minus_i : w_rot0_q_add_i    ;
assign  w_rot0_angle        = angle_i[14] ? w_rot0_add_half  : w_rot0_minus_half ;

//rotate 1/2^1
assign  w_rot1_i_add_q      = w_rot0_i + {w_rot0_q[17],w_rot0_q[17:1]};
assign  w_rot1_i_minus_q    = w_rot0_i - {w_rot0_q[17],w_rot0_q[17:1]};
assign  w_rot1_q_add_i      = w_rot0_q + {w_rot0_i[17],w_rot0_i[17:1]};
assign  w_rot1_q_minus_i    = w_rot0_q - {w_rot0_i[17],w_rot0_i[17:1]};
assign  w_rot1_add_half     = w_rot0_angle + 15'd2418;
assign  w_rot1_minus_half   = w_rot0_angle - 15'd2418;
assign  w_rot1_i            = w_rot0_angle[14] ? w_rot1_i_add_q   : w_rot1_i_minus_q  ;
assign  w_rot1_q            = w_rot0_angle[14] ? w_rot1_q_minus_i : w_rot1_q_add_i    ;
assign  w_rot1_angle        = w_rot0_angle[14] ? w_rot1_add_half  : w_rot1_minus_half ;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
    begin
        r_rot1_i        <= 18'd0;
        r_rot1_q        <= 18'd0;
        r_rot1_angle    <= 15'd0;
    end
    else if ( run_i )
    begin
        r_rot1_i        <= w_rot1_i;
        r_rot1_q        <= w_rot1_q;
        r_rot1_angle    <= w_rot1_angle;
    end
end

//2 clk delay: rotate 1/2^2 and 1/2^3 -----------------------------------
wire    [17:0]      w_rot2_i_add_q;
wire    [17:0]      w_rot2_i_minus_q;
wire    [17:0]      w_rot2_q_add_i;
wire    [17:0]      w_rot2_q_minus_i;
wire    [14:0]      w_rot2_add_half;
wire    [14:0]      w_rot2_minus_half;
wire    [17:0]      w_rot2_i;
wire    [17:0]      w_rot2_q;
wire    [14:0]      w_rot2_angle;

wire    [17:0]      w_rot3_i_add_q;
wire    [17:0]      w_rot3_i_minus_q;
wire    [17:0]      w_rot3_q_add_i;
wire    [17:0]      w_rot3_q_minus_i;
wire    [14:0]      w_rot3_add_half;
wire    [14:0]      w_rot3_minus_half;
wire    [17:0]      w_rot3_i;
wire    [17:0]      w_rot3_q;
wire    [14:0]      w_rot3_angle;

reg     [17:0]      r_rot3_i;
reg     [17:0]      r_rot3_q;
reg     [14:0]      r_rot3_angle;

//rotate 1/2^2
assign  w_rot2_i_add_q      = r_rot1_i + {{2{r_rot1_q[17]}},r_rot1_q[17:2]};
assign  w_rot2_i_minus_q    = r_rot1_i - {{2{r_rot1_q[17]}},r_rot1_q[17:2]};
assign  w_rot2_q_add_i      = r_rot1_q + {{2{r_rot1_i[17]}},r_rot1_i[17:2]};
assign  w_rot2_q_minus_i    = r_rot1_q - {{2{r_rot1_i[17]}},r_rot1_i[17:2]};
assign  w_rot2_add_half     = r_rot1_angle + 15'd1277;
assign  w_rot2_minus_half   = r_rot1_angle - 15'd1277;
assign  w_rot2_i            = r_rot1_angle[14] ? w_rot2_i_add_q   : w_rot2_i_minus_q  ;
assign  w_rot2_q            = r_rot1_angle[14] ? w_rot2_q_minus_i : w_rot2_q_add_i    ;
assign  w_rot2_angle        = r_rot1_angle[14] ? w_rot2_add_half  : w_rot2_minus_half ;

//rotate 1/2^3
assign  w_rot3_i_add_q      = w_rot2_i + {{3{w_rot2_q[17]}},w_rot2_q[17:3]};
assign  w_rot3_i_minus_q    = w_rot2_i - {{3{w_rot2_q[17]}},w_rot2_q[17:3]};
assign  w_rot3_q_add_i      = w_rot2_q + {{3{w_rot2_i[17]}},w_rot2_i[17:3]};
assign  w_rot3_q_minus_i    = w_rot2_q - {{3{w_rot2_i[17]}},w_rot2_i[17:3]};
assign  w_rot3_add_half     = w_rot2_angle + 15'd648;
assign  w_rot3_minus_half   = w_rot2_angle - 15'd648;
assign  w_rot3_i            = w_rot2_angle[14] ? w_rot3_i_add_q   : w_rot3_i_minus_q  ;
assign  w_rot3_q            = w_rot2_angle[14] ? w_rot3_q_minus_i : w_rot3_q_add_i    ;
assign  w_rot3_angle        = w_rot2_angle[14] ? w_rot3_add_half  : w_rot3_minus_half ;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
    begin
        r_rot3_i        <= 18'd0;
        r_rot3_q        <= 18'd0;
        r_rot3_angle    <= 15'd0;
    end
    else if ( run_i )
    begin
        r_rot3_i        <= w_rot3_i;
        r_rot3_q        <= w_rot3_q;
        r_rot3_angle    <= w_rot3_angle;
    end
end

//3 clk delay: rotate 1/2^4 and 1/2^5 -----------------------------------
wire    [17:0]      w_rot4_i_add_q;
wire    [17:0]      w_rot4_i_minus_q;
wire    [17:0]      w_rot4_q_add_i;
wire    [17:0]      w_rot4_q_minus_i;
wire    [14:0]      w_rot4_add_half;
wire    [14:0]      w_rot4_minus_half;
wire    [17:0]      w_rot4_i;
wire    [17:0]      w_rot4_q;
wire    [14:0]      w_rot4_angle;

wire    [17:0]      w_rot5_i_add_q;
wire    [17:0]      w_rot5_i_minus_q;
wire    [17:0]      w_rot5_q_add_i;
wire    [17:0]      w_rot5_q_minus_i;
wire    [14:0]      w_rot5_add_half;
wire    [14:0]      w_rot5_minus_half;
wire    [17:0]      w_rot5_i;
wire    [17:0]      w_rot5_q;
wire    [14:0]      w_rot5_angle;

reg     [17:0]      r_rot5_i;
reg     [17:0]      r_rot5_q;
reg     [14:0]      r_rot5_angle;

//rotate 1/2^4
assign  w_rot4_i_add_q      = r_rot3_i + {{4{r_rot3_q[17]}},r_rot3_q[17:4]};
assign  w_rot4_i_minus_q    = r_rot3_i - {{4{r_rot3_q[17]}},r_rot3_q[17:4]};
assign  w_rot4_q_add_i      = r_rot3_q + {{4{r_rot3_i[17]}},r_rot3_i[17:4]};
assign  w_rot4_q_minus_i    = r_rot3_q - {{4{r_rot3_i[17]}},r_rot3_i[17:4]};
assign  w_rot4_add_half     = r_rot3_angle + 15'd325;
assign  w_rot4_minus_half   = r_rot3_angle - 15'd325;
assign  w_rot4_i            = r_rot3_angle[14] ? w_rot4_i_add_q   : w_rot4_i_minus_q  ;
assign  w_rot4_q            = r_rot3_angle[14] ? w_rot4_q_minus_i : w_rot4_q_add_i    ;
assign  w_rot4_angle        = r_rot3_angle[14] ? w_rot4_add_half  : w_rot4_minus_half ;

//rotate 1/2^5
assign  w_rot5_i_add_q      = w_rot4_i + {{5{w_rot4_q[17]}},w_rot4_q[17:5]};
assign  w_rot5_i_minus_q    = w_rot4_i - {{5{w_rot4_q[17]}},w_rot4_q[17:5]};
assign  w_rot5_q_add_i      = w_rot4_q + {{5{w_rot4_i[17]}},w_rot4_i[17:5]};
assign  w_rot5_q_minus_i    = w_rot4_q - {{5{w_rot4_i[17]}},w_rot4_i[17:5]};
assign  w_rot5_add_half     = w_rot4_angle + 15'd162;
assign  w_rot5_minus_half   = w_rot4_angle - 15'd162;
assign  w_rot5_i            = w_rot4_angle[14] ? w_rot5_i_add_q   : w_rot5_i_minus_q  ;
assign  w_rot5_q            = w_rot4_angle[14] ? w_rot5_q_minus_i : w_rot5_q_add_i    ;
assign  w_rot5_angle        = w_rot4_angle[14] ? w_rot5_add_half  : w_rot5_minus_half ;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
    begin
        r_rot5_i        <= 18'd0;
        r_rot5_q        <= 18'd0;
        r_rot5_angle    <= 15'd0;
    end
    else if ( run_i )
    begin
        r_rot5_i        <= w_rot5_i;
        r_rot5_q        <= w_rot5_q;
        r_rot5_angle    <= w_rot5_angle;
    end
end

//4 clk delay: rotate 1/2^6 and 1/2^7 -----------------------------------
wire    [17:0]      w_rot6_i_add_q;
wire    [17:0]      w_rot6_i_minus_q;
wire    [17:0]      w_rot6_q_add_i;
wire    [17:0]      w_rot6_q_minus_i;
wire    [14:0]      w_rot6_add_half;
wire    [14:0]      w_rot6_minus_half;
wire    [17:0]      w_rot6_i;
wire    [17:0]      w_rot6_q;
wire    [14:0]      w_rot6_angle;

wire    [17:0]      w_rot7_i_add_q;
wire    [17:0]      w_rot7_i_minus_q;
wire    [17:0]      w_rot7_q_add_i;
wire    [17:0]      w_rot7_q_minus_i;
wire    [14:0]      w_rot7_add_half;
wire    [14:0]      w_rot7_minus_half;
wire    [17:0]      w_rot7_i;
wire    [17:0]      w_rot7_q;
wire    [14:0]      w_rot7_angle;

reg     [17:0]      r_rot7_i;
reg     [17:0]      r_rot7_q;
reg     [14:0]      r_rot7_angle;

//rotate 1/2^6
assign  w_rot6_i_add_q      = r_rot5_i + {{6{r_rot5_q[17]}},r_rot5_q[17:6]};
assign  w_rot6_i_minus_q    = r_rot5_i - {{6{r_rot5_q[17]}},r_rot5_q[17:6]};
assign  w_rot6_q_add_i      = r_rot5_q + {{6{r_rot5_i[17]}},r_rot5_i[17:6]};
assign  w_rot6_q_minus_i    = r_rot5_q - {{6{r_rot5_i[17]}},r_rot5_i[17:6]};
assign  w_rot6_add_half     = r_rot5_angle + 15'd81;
assign  w_rot6_minus_half   = r_rot5_angle - 15'd81;
assign  w_rot6_i            = r_rot5_angle[14] ? w_rot6_i_add_q   : w_rot6_i_minus_q  ;
assign  w_rot6_q            = r_rot5_angle[14] ? w_rot6_q_minus_i : w_rot6_q_add_i    ;
assign  w_rot6_angle        = r_rot5_angle[14] ? w_rot6_add_half  : w_rot6_minus_half ;

//rotate 1/2^7
assign  w_rot7_i_add_q      = w_rot6_i + {{7{w_rot6_q[17]}},w_rot6_q[17:7]};
assign  w_rot7_i_minus_q    = w_rot6_i - {{7{w_rot6_q[17]}},w_rot6_q[17:7]};
assign  w_rot7_q_add_i      = w_rot6_q + {{7{w_rot6_i[17]}},w_rot6_i[17:7]};
assign  w_rot7_q_minus_i    = w_rot6_q - {{7{w_rot6_i[17]}},w_rot6_i[17:7]};
assign  w_rot7_add_half     = w_rot6_angle + 15'd40;
assign  w_rot7_minus_half   = w_rot6_angle - 15'd40;
assign  w_rot7_i            = w_rot6_angle[14] ? w_rot7_i_add_q   : w_rot7_i_minus_q  ;
assign  w_rot7_q            = w_rot6_angle[14] ? w_rot7_q_minus_i : w_rot7_q_add_i    ;
assign  w_rot7_angle        = w_rot6_angle[14] ? w_rot7_add_half  : w_rot7_minus_half ;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
    begin
        r_rot7_i        <= 18'd0;
        r_rot7_q        <= 18'd0;
        r_rot7_angle    <= 15'd0;
    end
    else if ( run_i )
    begin
        r_rot7_i        <= w_rot7_i;
        r_rot7_q        <= w_rot7_q;
        r_rot7_angle    <= w_rot7_angle;
    end
end

//5 clk delay: rotate 1/2^8 and 1/2^9 -----------------------------------
wire    [17:0]      w_rot8_i_add_q;
wire    [17:0]      w_rot8_i_minus_q;
wire    [17:0]      w_rot8_q_add_i;
wire    [17:0]      w_rot8_q_minus_i;
wire    [14:0]      w_rot8_add_half;
wire    [14:0]      w_rot8_minus_half;
wire    [17:0]      w_rot8_i;
wire    [17:0]      w_rot8_q;
wire    [14:0]      w_rot8_angle;

wire    [17:0]      w_rot9_i_add_q;
wire    [17:0]      w_rot9_i_minus_q;
wire    [17:0]      w_rot9_q_add_i;
wire    [17:0]      w_rot9_q_minus_i;
wire    [14:0]      w_rot9_add_half;
wire    [14:0]      w_rot9_minus_half;
wire    [17:0]      w_rot9_i;
wire    [17:0]      w_rot9_q;
wire    [14:0]      w_rot9_angle;

reg     [17:0]      r_rot9_i;
reg     [17:0]      r_rot9_q;
reg     [14:0]      r_rot9_angle;

//rotate 1/2^8
assign  w_rot8_i_add_q      = r_rot7_i + {{8{r_rot7_q[17]}},r_rot7_q[17:8]};
assign  w_rot8_i_minus_q    = r_rot7_i - {{8{r_rot7_q[17]}},r_rot7_q[17:8]};
assign  w_rot8_q_add_i      = r_rot7_q + {{8{r_rot7_i[17]}},r_rot7_i[17:8]};
assign  w_rot8_q_minus_i    = r_rot7_q - {{8{r_rot7_i[17]}},r_rot7_i[17:8]};
assign  w_rot8_add_half     = r_rot7_angle + 15'd20;
assign  w_rot8_minus_half   = r_rot7_angle - 15'd20;
assign  w_rot8_i            = r_rot7_angle[14] ? w_rot8_i_add_q   : w_rot8_i_minus_q  ;
assign  w_rot8_q            = r_rot7_angle[14] ? w_rot8_q_minus_i : w_rot8_q_add_i    ;
assign  w_rot8_angle        = r_rot7_angle[14] ? w_rot8_add_half  : w_rot8_minus_half ;

//rotate 1/2^9
assign  w_rot9_i_add_q      = w_rot8_i + {{9{w_rot8_q[17]}},w_rot8_q[17:9]};
assign  w_rot9_i_minus_q    = w_rot8_i - {{9{w_rot8_q[17]}},w_rot8_q[17:9]};
assign  w_rot9_q_add_i      = w_rot8_q + {{9{w_rot8_i[17]}},w_rot8_i[17:9]};
assign  w_rot9_q_minus_i    = w_rot8_q - {{9{w_rot8_i[17]}},w_rot8_i[17:9]};
assign  w_rot9_add_half     = w_rot8_angle + 15'd10;
assign  w_rot9_minus_half   = w_rot8_angle - 15'd10;
assign  w_rot9_i            = w_rot8_angle[14] ? w_rot9_i_add_q   : w_rot9_i_minus_q  ;
assign  w_rot9_q            = w_rot8_angle[14] ? w_rot9_q_minus_i : w_rot9_q_add_i    ;
assign  w_rot9_angle        = w_rot8_angle[14] ? w_rot9_add_half  : w_rot9_minus_half ;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
    begin
        r_rot9_i        <= 18'd0;
        r_rot9_q        <= 18'd0;
        r_rot9_angle    <= 15'd0;
    end
    else if ( run_i )
    begin
        r_rot9_i        <= w_rot9_i;
        r_rot9_q        <= w_rot9_q;
        r_rot9_angle    <= w_rot9_angle;
    end
end

//6 clk delay: rotate 1/2^10 and 1/2^11 ---------------------------------
wire    [17:0]      w_rot10_i_add_q;
wire    [17:0]      w_rot10_i_minus_q;
wire    [17:0]      w_rot10_q_add_i;
wire    [17:0]      w_rot10_q_minus_i;
wire    [14:0]      w_rot10_add_half;
wire    [14:0]      w_rot10_minus_half;
wire    [17:0]      w_rot10_i;
wire    [17:0]      w_rot10_q;
wire    [14:0]      w_rot10_angle;

wire    [17:0]      w_rot11_i_add_q;
wire    [17:0]      w_rot11_i_minus_q;
wire    [17:0]      w_rot11_q_add_i;
wire    [17:0]      w_rot11_q_minus_i;
wire    [14:0]      w_rot11_add_half;
wire    [14:0]      w_rot11_minus_half;
wire    [17:0]      w_rot11_i;
wire    [17:0]      w_rot11_q;
wire    [14:0]      w_rot11_angle;

reg     [17:0]      r_rot11_i;
reg     [17:0]      r_rot11_q;
reg     [14:0]      r_rot11_angle;

//rotate 1/2^10
assign  w_rot10_i_add_q     = r_rot9_i + {{10{r_rot9_q[17]}},r_rot9_q[17:10]};
assign  w_rot10_i_minus_q   = r_rot9_i - {{10{r_rot9_q[17]}},r_rot9_q[17:10]};
assign  w_rot10_q_add_i     = r_rot9_q + {{10{r_rot9_i[17]}},r_rot9_i[17:10]};
assign  w_rot10_q_minus_i   = r_rot9_q - {{10{r_rot9_i[17]}},r_rot9_i[17:10]};
assign  w_rot10_add_half    = r_rot9_angle + 15'd5;
assign  w_rot10_minus_half  = r_rot9_angle - 15'd5;
assign  w_rot10_i           = r_rot9_angle[14] ? w_rot10_i_add_q   : w_rot10_i_minus_q  ;
assign  w_rot10_q           = r_rot9_angle[14] ? w_rot10_q_minus_i : w_rot10_q_add_i    ;
assign  w_rot10_angle       = r_rot9_angle[14] ? w_rot10_add_half  : w_rot10_minus_half ;

//rotate 1/2^11
assign  w_rot11_i_add_q     = w_rot10_i + {{11{w_rot10_q[17]}},w_rot10_q[17:11]};
assign  w_rot11_i_minus_q   = w_rot10_i - {{11{w_rot10_q[17]}},w_rot10_q[17:11]};
assign  w_rot11_q_add_i     = w_rot10_q + {{11{w_rot10_i[17]}},w_rot10_i[17:11]};
assign  w_rot11_q_minus_i   = w_rot10_q - {{11{w_rot10_i[17]}},w_rot10_i[17:11]};
assign  w_rot11_add_half    = w_rot10_angle + 15'd2;
assign  w_rot11_minus_half  = w_rot10_angle - 15'd2;
assign  w_rot11_i           = w_rot10_angle[14] ? w_rot11_i_add_q   : w_rot11_i_minus_q  ;
assign  w_rot11_q           = w_rot10_angle[14] ? w_rot11_q_minus_i : w_rot11_q_add_i    ;
assign  w_rot11_angle       = w_rot10_angle[14] ? w_rot11_add_half  : w_rot11_minus_half ;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
    begin
        r_rot11_i        <= 18'd0;
        r_rot11_q        <= 18'd0;
        r_rot11_angle    <= 15'd0;
    end
    else if ( run_i )
    begin
        r_rot11_i        <= w_rot11_i;
        r_rot11_q        <= w_rot11_q;
        r_rot11_angle    <= w_rot11_angle;
    end
end

//7 clk delay: rotate 1/2^12 --------------------------------------------
wire    [17:0]      w_rot12_i_add_q;
wire    [17:0]      w_rot12_i_minus_q;
wire    [17:0]      w_rot12_q_add_i;
wire    [17:0]      w_rot12_q_minus_i;
wire    [17:0]      w_rot12_i;
wire    [17:0]      w_rot12_q;

reg     [17:0]      r_rot12_i;
reg     [17:0]      r_rot12_q;

//rotate 1/2^12
assign  w_rot12_i_add_q     = r_rot11_i + {{12{r_rot11_q[17]}},r_rot11_q[17:12]};
assign  w_rot12_i_minus_q   = r_rot11_i - {{12{r_rot11_q[17]}},r_rot11_q[17:12]};
assign  w_rot12_q_add_i     = r_rot11_q + {{12{r_rot11_i[17]}},r_rot11_i[17:12]};
assign  w_rot12_q_minus_i   = r_rot11_q - {{12{r_rot11_i[17]}},r_rot11_i[17:12]};
assign  w_rot12_i           = r_rot11_angle[14] ? w_rot12_i_add_q   : w_rot12_i_minus_q;
assign  w_rot12_q           = r_rot11_angle[14] ? w_rot12_q_minus_i : w_rot12_q_add_i;

always @ ( posedge clk or negedge rst_n )
begin
    if ( ~rst_n )
    begin
        r_rot12_i        <= 18'd0;
        r_rot12_q        <= 18'd0;
    end
    else if ( run_i )
    begin
        r_rot12_i        <= w_rot12_i;
        r_rot12_q        <= w_rot12_q;
    end
end

//output ----------------------------------------------------------------

assign idata_o = r_rot12_i;
assign qdata_o = r_rot12_q;


endmodule
