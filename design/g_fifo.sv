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

