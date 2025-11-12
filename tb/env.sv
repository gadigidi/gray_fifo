`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// env /////////////
class env extends uvm_env;
  `uvm_component_utils(env)
  
  write_agent wr_agnt;
  read_agent rd_agnt;
  scoreboard scbd;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("env", "Build phase started", UVM_LOW)
    wr_agnt = write_agent::type_id::create("wr_agnt", this);
    rd_agnt = read_agent::type_id::create("rd_agnt", this);
    scbd = scoreboard::type_id::create("scbd", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("env", "Connect phase started", UVM_LOW)
    wr_agnt.wr_mon.sender.connect(scbd.reciver);
    rd_agnt.rd_mon.sender.connect(scbd.reciver);
  endfunction
  
endclass

