`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// write monitor /////////////
class write_monitor extends uvm_monitor;
  `uvm_component_utils(write_monitor)
  
  virtual gfifo_if gif;
  mon_transaction t;
  uvm_analysis_port #(mon_transaction) sender;
  
  covergroup full_cg with function sample(bit full);
    full_cp : coverpoint full {
      bins to_full = (0 => 1);
      bins from_full = (1 => 0);
    }
  endgroup

  function new(string path = "wr_mon", uvm_component parent = null);
    super.new(path, parent);
    sender = new("sender", this);
    full_cg = new();
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("wr_monitor", "Build phase started", UVM_LOW)
    t = mon_transaction::type_id::create("t");
    if (!uvm_config_db#(virtual gfifo_if)::get(this, "", "gif", gif))
      `uvm_error("wr_monitor", "Unable to access virtual gfifo_if")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("wr_monitor", "Run phase started", UVM_LOW)
    wait (gif.MON.rst_ == 1'b1);
    
    fork 
      forever begin
        @(posedge gif.MON.wr_clk);
        t.wr0_rd1 = 'b0;
        t.wr_data = gif.MON.wr_data;
        t.wr_req_ = gif.MON.wr_req_;
        t.full = gif.MON.full;
        $display("Time is %0t. write transaction", $time);
        t.print(uvm_default_line_printer);
        `uvm_info("wr_monitor", "Write transaction sent to Scbd", UVM_HIGH)
        sender.write(t);
      end
      forever begin
        @(posedge gif.MON.wr_clk);
        full_cg.sample(gif.MON.full);
      end
    join
  endtask

endclass

///////////// read monitor /////////////
class read_monitor extends uvm_monitor;
  `uvm_component_utils(read_monitor)
  
  virtual gfifo_if gif;
  mon_transaction t;
  uvm_analysis_port #(mon_transaction) sender;
  
  covergroup empty_cg with function sample(bit empty);
    empty_cp : coverpoint empty {
      bins to_empty = (0 => 1);
      bins from_empty = (1 => 0);
    }
  endgroup
  
  function new(string path = "rd_mon", uvm_component parent = null);
    super.new(path, parent);
    sender = new("sender", this);
    empty_cg = new();
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("rd_monitor", "Build phase started", UVM_LOW)
    t = mon_transaction::type_id::create("t");
    if (!uvm_config_db#(virtual gfifo_if)::get(this, "", "gif", gif))
      `uvm_error("rd_monitor", "Unable to access virtual gfifo_if")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("rd_monitor", "Run phase started", UVM_LOW)
    wait (gif.MON.rst_ == 1'b1);
    
    fork
      forever begin  
        @(posedge gif.MON.rd_clk);
        t.wr0_rd1 = 'b1;
        t.rd_req_ = gif.MON.rd_req_;
        t.rd_data = gif.MON.rd_data;
        t.rd_valid = gif.MON.rd_valid;
        t.empty = gif.MON.empty;
        $display("Time is %0t. read transaction", $time);
        t.print(uvm_default_line_printer);
        `uvm_info("rd_monitor", "Read transaction sent to Scbd", UVM_HIGH)
        sender.write(t);
      end
      forever begin
        @(posedge gif.MON.rd_clk);
        empty_cg.sample(gif.MON.empty);
      end
    join
  endtask

endclass

