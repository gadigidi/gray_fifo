`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// test /////////////
class test extends uvm_test;
  `uvm_component_utils(test)
  env en;
  generator wr_gen;
  generator rd_gen;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("test", "Build phase started", UVM_LOW)
    wr_gen = generator::type_id::create("wr_gen");
    rd_gen = generator::type_id::create("rd_gen");
    en = env::type_id::create("en", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("test", "Run phase started", UVM_LOW)
    phase.raise_objection(this);
    `uvm_info("test", "Objection raised", UVM_LOW)
    fork
      wr_gen.start(en.wr_agnt.wr_seqr);
      rd_gen.start(en.rd_agnt.rd_seqr);
    join
    `uvm_info("test", "gen.start done", UVM_LOW)
    #100;
    phase.drop_objection(this);
  endtask
endclass

