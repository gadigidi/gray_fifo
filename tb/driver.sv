`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// driver /////////////
class driver extends uvm_driver#(drv_transaction);
  `uvm_component_utils(driver)
  
  virtual gfifo_if gif;
  drv_transaction t;
  bit wr0_rd1;
  
  function new(string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("driver", "Build phase started", UVM_LOW)
    t = drv_transaction::type_id::create("t");
    if (!uvm_config_db#(virtual gfifo_if)::get(this, "", "gif", gif))
      `uvm_error("driver", "Unable to access virtual gfifo_if")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("driver", "run phase started", UVM_LOW)
    `uvm_info("driver", "Starting Reset", UVM_LOW)

    if (wr0_rd1 == 1'b0) dut_rst();
    if (wr0_rd1 == 1'b1) begin
      wait (gif.DRVR.rst_ == 1'b0); //waut rst start
    end
    wait (gif.DRVR.rst_ == 1'b1); //wait rst done
    #5;
    forever begin
      `uvm_info("driver", "Sending Grant to sequence" , UVM_HIGH);
      seq_item_port.get_next_item(t);
      t.print(uvm_default_line_printer);
      
      if (wr0_rd1 == 1'b0) write(t.wr_data);
      if (wr0_rd1 == 1'b1) read();
            
      `uvm_info("driver", "Sending item_done response to sequence", UVM_LOW)
      seq_item_port.item_done();
    end
  endtask

  task dut_rst();
    `uvm_info("driver", "Reset started", UVM_LOW)
    gif.DRVR.rst_ = 1'b0;
    gif.DRVR.wr_req_ = 1'b1;
    gif.DRVR.rd_req_ = 1'b1;
    repeat (20) @(posedge gif.DRVR.wr_clk);
    gif.DRVR.rst_ = 1'b1;
    `uvm_info("driver", "Reset done", UVM_LOW)
  endtask

  task write(bit[3:0] wr_data);
    if (t.wr_req_ == 1'b0) begin
      @(posedge gif.DRVR.wr_clk);
      `uvm_info("driver", "Applying Write transaction to DUT", UVM_LOW)
      gif.DRVR.wr_req_ <= 1'b0;
      gif.DRVR.wr_data <= wr_data;
    end
    @(posedge gif.DRVR.wr_clk);
    gif.DRVR.wr_req_ <= 1'b1;
  endtask
    
  task read ();
    if (t.rd_req_ == 1'b0) begin
      @(posedge gif.DRVR.rd_clk);
      `uvm_info("driver", "Applying Read transaction to DUT", UVM_LOW)
      gif.DRVR.rd_req_ <= 1'b0;
    end
    @(posedge gif.DRVR.rd_clk);
    gif.DRVR.rd_req_ <= 1'b1;
  endtask  
    
endclass

