`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// drv_transaction /////////////
class drv_transaction extends uvm_sequence_item;
  
  rand bit[3:0] wr_data;
  rand bit wr_req_;
  rand bit rd_req_;
  
  function new(string path = "drv_transaction");
    super.new(path);
  endfunction 
  
  `uvm_object_utils_begin(drv_transaction)
    `uvm_field_int(wr_data, UVM_DEFAULT)
    `uvm_field_int(wr_req_, UVM_DEFAULT)
    `uvm_field_int(rd_req_, UVM_DEFAULT)
  `uvm_object_utils_end
  
  //constraint a_range {a<'h2;}
  //constraint b_range {b>'h7; b<'ha;}
  
endclass


///////////// mon_transaction /////////////
class mon_transaction extends uvm_sequence_item;
  
  bit wr0_rd1;
  logic [3:0] wr_data;
  logic wr_req_;
  logic rd_req_;
  logic [3:0] rd_data;
  logic rd_valid;
  
  function new(string path = "mon_transaction");
    super.new(path);
  endfunction 
  
  `uvm_object_utils_begin(mon_transaction)
    `uvm_field_int(wr0_rd1, UVM_DEFAULT)
    `uvm_field_int(wr_data, UVM_DEFAULT)
    `uvm_field_int(wr_req_, UVM_DEFAULT)
    `uvm_field_int(rd_req_, UVM_DEFAULT)
    `uvm_field_int(rd_data, UVM_DEFAULT)
    `uvm_field_int(rd_valid, UVM_DEFAULT)
  `uvm_object_utils_end
  
  //constraint a_range {a<'h2;}
  //constraint b_range {b>'h7; b<'ha;}
  
endclass
 

///////////// generator /////////////
class generator extends uvm_sequence#(drv_transaction);
  `uvm_object_utils(generator)
  
  drv_transaction t;
  
  function new(string path = "generator");
    super.new(path);
  endfunction
  
  virtual task pre_body();
    `uvm_info("generator", "Pre-body phase executed", UVM_LOW)
  endtask
  
  virtual task body();
    `uvm_info("generator", "Body phase executed", UVM_LOW)
    repeat(100) begin
      `uvm_info("generator", "generator item pre start", UVM_HIGH)
      t = drv_transaction::type_id::create("t");
      `uvm_info("generator", "Waiting for grant from driver", UVM_HIGH)
      start_item(t);
      `uvm_info("generator", "generator item started", UVM_HIGH)
      assert(t.randomize());
      finish_item(t);
      `uvm_info("generator", "sequence item finished", UVM_HIGH)
    end
  endtask
  
  virtual task post_body();
    `uvm_info("generator", "Post-body phase started", UVM_HIGH)
    `uvm_info("generator", "sequence done!", UVM_HIGH)
  endtask
  
endclass

