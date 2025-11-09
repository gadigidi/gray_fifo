`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// tb /////////////
module tb();
  
  gfifo_if gif();
  g_fifo gfifo (.gif(gif.DUT));
  
  logic moishi;
  initial moishi = 1'b0;
  //wire diff;
  //wire wr_req_synced_;
  //wire [3:0] rd_ptr_b_wc;
  //wire [3:0] rd_ptr_b_rc;
  //assign wr_req_synced_ = tb.gfifo.wr_ctrl.wr_req_synced_;
  //assign rd_ptr_b_wc = tb.gfifo.wr_ctrl.rd_ptr_b;
  //assign rd_ptr_b_rc = tb.gfifo.rd_ctrl.rd_ptr_b;
  //assign diff = ~wr_req_synced_ & (rd_ptr_b_wc != rd_ptr_b_rc) & tb.gfifo.wr_ctrl.wr_clk;
  
  initial begin
    gif.wr_clk = 1'b0;
  end
  always begin
    #5;
    gif.wr_clk = ~gif.wr_clk;
  end
  
  initial begin
    gif.rd_clk = 1'b0;
  end  
  always begin
    #8;
    gif.rd_clk = ~gif.rd_clk;
  end
  
  initial begin
    `uvm_info("TB_TOP", "TB initial begin started", UVM_LOW)
    uvm_config_db #(virtual gfifo_if)::set(null, "*", "gif", gif);
    run_test("test");
  end
   
  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
  end         
endmodule

