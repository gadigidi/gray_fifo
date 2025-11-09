`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// env /////////////
class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent agnt;
  scoreboard scbd;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("env", "Build phase started", UVM_LOW)
    agnt = agent::type_id::create("agnt", this);
    scbd = scoreboard::type_id::create("scbd", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("env", "Connect phase started", UVM_LOW)
    agnt.wr_mon.sender.connect(scbd.reciver);
    agnt.rd_mon.sender.connect(scbd.reciver);
  endfunction
  
endclass

