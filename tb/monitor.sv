`include "uvm_macros.svh"
import uvm_pkg::*;
///////////// monitor /////////////
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  virtual gfifo_if gif;
  mon_transaction t;
  uvm_analysis_port #(mon_transaction) sender;
  bit wr0_rd1;
  
  function new(string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
    sender = new("sender", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("monitor", "Build phase started", UVM_LOW)
    t = mon_transaction::type_id::create("t");
    if (!uvm_config_db#(virtual gfifo_if)::get(this, "", "gif", gif))
      `uvm_error("monitor", "Unable to access virtual gfifo_if")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("monitor", "Run phase started", UVM_LOW)
    wait (gif.MON.rst_ == 1'b1);
    
    forever begin
      if (wr0_rd1 == 1'b0) begin
        @(posedge gif.MON.wr_clk);
        t.wr0_rd1 = 'b0;
        t.wr_data = gif.MON.wr_data;
        t.wr_req_ = gif.MON.wr_req_;
        t.full = gif.MON.full;
        $display("Time is %0t. write transaction", $time);
        t.print(uvm_default_line_printer);
        `uvm_info("monitor", "Write transaction sent to Scbd", UVM_HIGH)
        sender.write(t);
      end
      if (wr0_rd1 == 1'b1) begin
        @(posedge gif.MON.rd_clk);
        t.wr0_rd1 = 'b1;
        t.rd_req_ = gif.MON.rd_req_;
        t.rd_data = gif.MON.rd_data;
        t.rd_valid = gif.MON.rd_valid;
        t.empty = gif.MON.empty;
        $display("Time is %0t. read transaction", $time);
        t.print(uvm_default_line_printer);
        `uvm_info("monitor", "Read transaction sent to Scbd", UVM_HIGH)
        sender.write(t);
      end
    end
  endtask

endclass

