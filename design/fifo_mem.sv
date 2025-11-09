`define MY_DEBUG
//MY_DEBUG used to seperate multi-dimensional bus into multiple 1D signals
//because waver tool don't support multi-dimensional bus
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

