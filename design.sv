
`define MY_DEBUG
module g2b_decoder(
  input [3:0] g_addr,
  output reg [3:0] b_addr);
  always @(*) begin
    case (g_addr)
      'b0000: b_addr = 'b0000;
      'b0001: b_addr = 'b0001;
      'b0011: b_addr = 'b0010;
      'b0010: b_addr = 'b0011;
      'b0110: b_addr = 'b0100;
      'b0111: b_addr = 'b0101;
      'b0101: b_addr = 'b0110;
      'b0100: b_addr = 'b0111;
      'b1100: b_addr = 'b1000;
      'b1101: b_addr = 'b1001;
      'b1111: b_addr = 'b1010;
      'b1110: b_addr = 'b1011;
      'b1010: b_addr = 'b1100;
      'b1011: b_addr = 'b1101;
      'b1001: b_addr = 'b1110;
      'b1000: b_addr = 'b1111;
      default: b_addr = 'b0000;
    endcase
  end
endmodule

module b2g_decoder(
  input [3:0] b_addr,
  output reg [3:0] g_addr);
  always @(*) begin
    case (b_addr)
      'b0000: g_addr = 'b0000;
      'b0001: g_addr = 'b0001;
      'b0010: g_addr = 'b0011;
      'b0011: g_addr = 'b0010;
      'b0100: g_addr = 'b0110;
      'b0101: g_addr = 'b0111;
      'b0110: g_addr = 'b0101;
      'b0111: g_addr = 'b0100;
      'b1000: g_addr = 'b1100;
      'b1001: g_addr = 'b1101;
      'b1010: g_addr = 'b1111;
      'b1011: g_addr = 'b1110;
      'b1100: g_addr = 'b1010;
      'b1101: g_addr = 'b1011;
      'b1110: g_addr = 'b1001;
      'b1111: g_addr = 'b1000;
      default: g_addr = 'b0000;
    endcase
  end
endmodule

module synchronizer #(parameter SYNC_WIDTH=1, parameter SYNC_DLY=1, parameter RST_VAL=0)(
  input clk,
  input rst_,
  input [SYNC_WIDTH-1:0] data_in,
  output [SYNC_WIDTH-1:0] data_synced);
  
  reg [SYNC_WIDTH-1:0] q[SYNC_DLY];
  
  always @(posedge clk) begin
    if (!rst_)
      q[0] <= RST_VAL;
    else
      q[0] <= data_in;
  end 
  
  genvar i;
  generate 
    for (i=1; i<SYNC_DLY; i++) begin
      always @(posedge clk) begin
        if (!rst_)
          q[i] <= RST_VAL;
        else
          q[i] <= q[i-1];
      end
    end
  endgenerate
  
  assign data_synced = q[SYNC_DLY-1];
 
endmodule
	

module wr_ctrl (
  input wr_clk,
  input rst_,
  input [3:0] rd_ptr_g,
  input wr_req_,
  output reg [3:0] wr_ptr_b,
  output reg wr_en,
  output [3:0] wr_ptr_g,
  output full);
  
  wire [3:0] rd_ptr_g_synced;
  wire [3:0] rd_ptr_b;
  wire [3:0] nxt_wr_ptr;
  reg wr_req_synced_;
  wire overlap;
  reg overlap_dly;
  //wire full;
  reg full_dly;
  reg wr_en_dly;
  
  synchronizer #(.SYNC_WIDTH(4), .SYNC_DLY(2), .RST_VAL(0))
  wr_sync(
    .clk(wr_clk),
    .rst_(rst_),
    .data_in(rd_ptr_g),
    .data_synced(rd_ptr_g_synced));
  
  g2b_decoder rd_ptr_g2b(
    .g_addr(rd_ptr_g_synced),
    .b_addr(rd_ptr_b));
  
  synchronizer #(.SYNC_WIDTH(1), .SYNC_DLY(2), .RST_VAL(1))
  wr_req_sync(
    .clk(wr_clk),
    .rst_(rst_),
    .data_in(wr_req_),
    .data_synced(wr_req_synced_));
  
  assign nxt_wr_ptr = wr_ptr_b+1;
  assign overlap = (nxt_wr_ptr == rd_ptr_b);
  
  always @(posedge wr_clk) begin
    if (!rst_)
      wr_en <= 'b0;
    else
      if (wr_req_synced_ == 1'b0 && !full)
        wr_en <= 'b1;
      else
        wr_en <= 'b0;
  end
  
  always @(posedge wr_clk) begin
    if (!rst_)
      wr_ptr_b <= 'h0;
    else
      if (wr_en)
        wr_ptr_b <= nxt_wr_ptr;
      else
        wr_ptr_b <= wr_ptr_b;
  end
  
  always @(posedge wr_clk) begin
    if (!rst_)
      overlap_dly <= 'h0;
    else
      overlap_dly <= overlap;
  end
  
  always @(posedge wr_clk) begin
    if (!rst_)
      full_dly <= 'h0;
    else
      full_dly <= full;
  end
  
  assign full = (wr_ptr_b == rd_ptr_b) && (overlap_dly || full_dly);
  
  b2g_decoder wr_ptr_b2g(
    .b_addr(wr_ptr_b),
    .g_addr(wr_ptr_g));
  
  /*always @(posedge wr_clk) begin
    if (!rst_)
      wr_en_dly <= 'h0;
    else
      wr_en_dly <= wr_en;
  end*/

endmodule

module rd_ctrl (
  input rd_clk,
  input rst_,
  input [3:0] wr_ptr_g,
  input rd_req_,
  input rd_valid,
  output reg [3:0] rd_ptr_b,
  output reg rd_en,
  output [3:0] rd_ptr_g,
  output empty);
  
  wire [3:0] wr_ptr_g_synced;
  wire [3:0] wr_ptr_b;
  wire [3:0] nxt_rd_ptr;
  wire overlap;
  reg overlap_dly;
  //wire empty;
  reg empty_dly;
  
  synchronizer #(.SYNC_WIDTH(4), .SYNC_DLY(2), .RST_VAL(1))
  rd_sync(
    .clk(rd_clk),
    .rst_(rst_),
    .data_in(wr_ptr_g),
    .data_synced(wr_ptr_g_synced));
  
  g2b_decoder wr_ptr_g2b(
    .g_addr(wr_ptr_g_synced),
    .b_addr(wr_ptr_b));
  
  synchronizer #(.SYNC_WIDTH(1), .SYNC_DLY(2), .RST_VAL(1))
  rd_req_sync(
    .clk(rd_clk),
    .rst_(rst_),
    .data_in(rd_req_),
    .data_synced(rd_req_synced_));
  
  assign nxt_rd_ptr = rd_ptr_b+1;
  assign overlap = (nxt_rd_ptr == wr_ptr_b);
  
  always @(posedge rd_clk) begin
	if (!rst_)
      rd_en <= 'b0;
    else
      if (rd_req_ == 1'b0 && !empty)
        rd_en <= 'b1;
      else
        rd_en <= 'b0;
  end
  
  always @(posedge rd_clk) begin
    if (!rst_)
      rd_ptr_b <= 'h0;
    else
      if (rd_en)
        rd_ptr_b <= nxt_rd_ptr;
      else
        rd_ptr_b <= rd_ptr_b;
  end
  
  always @(posedge rd_clk) begin
    if (!rst_)
      overlap_dly <= 'h0;
    else
      overlap_dly <= overlap;
  end
  
  always @(posedge rd_clk) begin
    if (!rst_)
      empty_dly <= 'h1;
    else
      empty_dly <= empty;
  end
  
  assign empty = (wr_ptr_b == rd_ptr_b) && (overlap_dly || empty_dly);
  
  b2g_decoder rd_ptr_b2g(
    .b_addr(rd_ptr_b),
    .g_addr(rd_ptr_g));
  
endmodule

module fifo_mem(
  input rst_,
  input wr_clk,
  input rd_clk,
  input wr_en,
  input [3:0] wr_addr,
  input [3:0] wr_data,
  input rd_en,
  input [3:0] rd_addr,
  output reg [3:0] rd_data,
  output reg rd_valid);
  
  reg [3:0] fifo[16]; 
  
  `ifdef MY_DEBUG
  wire [3:0] fifo_0;
  wire [3:0] fifo_1;
  wire [3:0] fifo_2;
  wire [3:0] fifo_3;
  wire [3:0] fifo_4;
  wire [3:0] fifo_5;
  wire [3:0] fifo_6;
  wire [3:0] fifo_7;
  wire [3:0] fifo_8;
  wire [3:0] fifo_9;
  wire [3:0] fifo_10;
  wire [3:0] fifo_11;
  wire [3:0] fifo_12;
  wire [3:0] fifo_13;
  wire [3:0] fifo_14;
  wire [3:0] fifo_15;
  
  assign fifo_0 = fifo[0];
  assign fifo_1 = fifo[1];
  assign fifo_2 = fifo[2];
  assign fifo_3 = fifo[3];
  assign fifo_4 = fifo[4];
  assign fifo_5 = fifo[5];
  assign fifo_6 = fifo[6];
  assign fifo_7 = fifo[7];
  assign fifo_8 = fifo[8];
  assign fifo_9 = fifo[9];
  assign fifo_10 = fifo[10];
  assign fifo_11 = fifo[11];
  assign fifo_12 = fifo[12];
  assign fifo_13 = fifo[13];
  assign fifo_14 = fifo[14];
  assign fifo_15 = fifo[15];
  `endif
  
  genvar i;
  generate 
    for (i=0; i<16; i=i+1) begin
      always @(posedge wr_clk)
        if (!rst_)
          fifo[i] <= 'h0;
      else if (wr_en && wr_addr == i)
        fifo[i] <= wr_data;
      else
        fifo[i] <= fifo[i];
    end
  endgenerate
  
  always @(posedge rd_clk) begin
    if (!rst_)
      rd_data <= 'h0;
    else if(rd_en)
      rd_data <= fifo[rd_addr];
    else
      rd_data <= rd_data;
  end
  
  always @(posedge rd_clk) begin
    rd_valid <= rd_en;
  end

endmodule

interface gfifo_if ();
  logic wr_clk;
  logic rd_clk;
  logic rst_;
  logic [3:0] wr_data;
  logic wr_req_;
  logic rd_req_;
  logic [3:0] rd_data;
  logic rd_valid;
  
  modport DUT(
    input wr_clk,
    input rd_clk,
    input rst_,
    input wr_data,
    input wr_req_,
    input rd_req_,
    output rd_data,
    output rd_valid);
  
  modport DRVR(
    input wr_clk,
    input rd_clk,
    output rst_,
    output wr_data,
    output wr_req_,
    output rd_req_,
    input rd_data,
    input rd_valid);
  
  modport MON(
    input wr_clk,
    input rd_clk,
    input rst_,
    input wr_data,
    input wr_req_,
    input rd_req_,
    input rd_data,
    input rd_valid);
  
endinterface

module g_fifo(
  gfifo_if gif);
  
  //input wires from IF to DUT
  wire wr_clk = gif.wr_clk;
  wire rd_clk = gif.rd_clk;
  wire rst_ = gif.rst_;
  wire [3:0] wr_data = gif.wr_data;
  wire wr_req_ = gif.wr_req_;
  wire rd_req_ = gif.rd_req_;
  
  //output wires from DUT to IF
  wire rd_valid;
  wire [3:0] rd_data;
  wire full;
  wire empty;
  
  //internal wires
  wire [3:0] wr_ptr_g;
  wire [3:0] wr_ptr_b;
  wire wr_en;
  wire [3:0] rd_ptr_b;
  wire [3:0] rd_ptr_g;
  wire rd_en;
  
  fifo_mem fifo_mem(
    .rst_(rst_),
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .wr_data(wr_data),
    .wr_en(wr_en),
    .wr_addr(wr_ptr_b),
    .rd_en(rd_en),
    .rd_addr(rd_ptr_b),
    .rd_data(rd_data),
    .rd_valid(rd_valid));
  
  wr_ctrl wr_ctrl(
    .wr_clk(wr_clk),
    .rst_(rst_),
    .rd_ptr_g(rd_ptr_g),
    .wr_req_(wr_req_),
    .wr_ptr_b(wr_ptr_b),
    .wr_en(wr_en),
    .wr_ptr_g(wr_ptr_g),
    .full(full));
  
  rd_ctrl rd_ctrl(
    .rd_clk(rd_clk),
    .rst_(rst_),
    .wr_ptr_g(wr_ptr_g),
    .rd_req_(rd_req_),
    .rd_ptr_b(rd_ptr_b),
    .rd_en(rd_en),
    .rd_ptr_g(rd_ptr_g),
    .rd_valid(rd_valid),
    .empty(empty));
  
  assign gif.rd_valid = rd_valid;
  assign gif.rd_data = rd_data;
   
endmodule

