`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// write agent /////////////
class write_agent extends uvm_agent;
  `uvm_component_utils(write_agent)
  
  write_driver wr_drvr;
  write_monitor wr_mon;
  uvm_sequencer #(drv_transaction) wr_seqr;
  
  
  function new(string path = "wr_agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("wr_agent", "Build phase started", UVM_LOW)
    wr_drvr = write_driver::type_id::create("wr_drvr", this);
    wr_mon = write_monitor::type_id::create("wr_mon", this);
    wr_seqr = uvm_sequencer#(drv_transaction)::type_id::create("wr_seqr", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("wr_agent", "Connect phase started", UVM_LOW)
    wr_drvr.seq_item_port.connect(wr_seqr.seq_item_export);
  endfunction

endclass

///////////// read agent /////////////
class read_agent extends uvm_agent;
  `uvm_component_utils(read_agent)
  
  read_driver rd_drvr;
  read_monitor rd_mon;
  uvm_sequencer #(drv_transaction) rd_seqr;
  
  
  function new(string path = "rd_agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("rd_agent", "Build phase started", UVM_LOW)
    rd_drvr = read_driver::type_id::create("rd_drvr", this);
    rd_mon = read_monitor::type_id::create("rd_mon", this);
    rd_seqr = uvm_sequencer#(drv_transaction)::type_id::create("rd_seqr", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("rd_agent", "Connect phase started", UVM_LOW)
    rd_drvr.seq_item_port.connect(rd_seqr.seq_item_export);
  endfunction

endclass

