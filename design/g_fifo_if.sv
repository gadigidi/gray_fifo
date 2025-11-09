interface gfifo_if ();
  logic wr_clk;
  logic rd_clk;
  logic rst_;
  logic [3:0] wr_data;
  logic wr_req_;
  logic rd_req_;
  logic [3:0] rd_data;
  logic rd_valid;
  logic full;
  logic empty;
  
  modport DUT(
    input wr_clk,
    input rd_clk,
    input rst_,
    input wr_data,
    input wr_req_,
    input rd_req_,
    output rd_data,
    output rd_valid,
    output full,
    output empty);
  
  modport DRVR(
    input wr_clk,
    input rd_clk,
    output rst_,
    output wr_data,
    output wr_req_,
    output rd_req_,
    input rd_data,
    input rd_valid,
    input full,
    input empty);
  
  modport MON(
    input wr_clk,
    input rd_clk,
    input rst_,
    input wr_data,
    input wr_req_,
    input rd_req_,
    input rd_data,
    input rd_valid,
    input full,
    input empty);
  
endinterface

