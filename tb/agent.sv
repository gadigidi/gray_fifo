`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// agent /////////////
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  driver wr_drvr;
  driver rd_drvr;
  monitor wr_mon;
  monitor rd_mon;
  uvm_sequencer #(drv_transaction) wr_seqr;
  uvm_sequencer #(drv_transaction) rd_seqr;
  
  
  function new(string path = "agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("agent", "Build phase started", UVM_LOW)
    wr_drvr = driver::type_id::create("wr_drvr", this);
    wr_drvr.wr0_rd1 = 1'b0;
    rd_drvr = driver::type_id::create("rd_drvr", this);
    rd_drvr.wr0_rd1 = 1'b1;
    wr_mon = monitor::type_id::create("wr_mon", this);
    wr_mon.wr0_rd1 = 1'b0;
    rd_mon = monitor::type_id::create("rd_mon", this);
    rd_mon.wr0_rd1 = 1'b1;
    wr_seqr = uvm_sequencer#(drv_transaction)::type_id::create("wr_seqr", this);
    rd_seqr = uvm_sequencer#(drv_transaction)::type_id::create("rd_seqr", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("agent", "Connect phase started", UVM_LOW)
    wr_drvr.seq_item_port.connect(wr_seqr.seq_item_export);
    rd_drvr.seq_item_port.connect(rd_seqr.seq_item_export);
  endfunction

endclass

