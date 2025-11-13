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
  wire overlap;
  reg overlap_dly;
  reg full_dly;
  
  synchronizer #(.SYNC_WIDTH(4), .SYNC_DLY(2), .RST_VAL(0))
  wr_sync(
    .clk(wr_clk),
    .rst_(rst_),
    .data_in(rd_ptr_g),
    .data_synced(rd_ptr_g_synced));
  
  g2b_decoder rd_ptr_g2b(
    .g_addr(rd_ptr_g_synced),
    .b_addr(rd_ptr_b));
  
  /*
  synchronizer #(.SYNC_WIDTH(1), .SYNC_DLY(2), .RST_VAL(1))
  wr_req_sync(
    .clk(wr_clk),
    .rst_(rst_),
    .data_in(wr_req_),
    .data_synced(wr_req_synced_));
  */
  
  assign nxt_wr_ptr = wr_ptr_b+1;
  assign overlap = (nxt_wr_ptr == rd_ptr_b);
  
  always @(posedge wr_clk) begin
    if (!rst_)
      wr_en <= 'b0;
    else
      if (wr_req_ == 1'b0 && !full)
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

endmodule

