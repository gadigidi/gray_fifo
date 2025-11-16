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
  
  /*
  synchronizer #(.SYNC_WIDTH(1), .SYNC_DLY(2), .RST_VAL(1))
  rd_req_sync(
    .clk(rd_clk),
    .rst_(rst_),
    .data_in(rd_req_),
    .data_synced(rd_req_synced_));
  */
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

