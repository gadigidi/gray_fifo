`include "uvm_macros.svh"
import uvm_pkg::*;

///////////// scoreboard /////////////
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  bit[3:0] mem_queue[$:15];
  //bit[3:0] wr_queue[$:2] = {'h0, 'h0, 'h0};
  bit[3:0] rd_queue[$:15]; //no need for this FIXME
  
  //bit [2:0] wr_cnt;
  //bit [2:0] rd_cnt;
  
  mon_transaction t;
  uvm_analysis_imp #(mon_transaction, scoreboard) reciver;
  
  function new(string path = "scoreboard", uvm_component parent = null);
    super.new(path, parent);
    reciver = new("reciver", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("scoreboard", "Build phase started", UVM_LOW)
    t = mon_transaction::type_id::create("t");
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("scoreboard", "Connect phase started", UVM_LOW)
  endfunction
  
  virtual function void write(mon_transaction t_mon);
    bit[3:0] wr_data;
    bit wr2q;
    bit rd_valid;
    bit[3:0] rd_data;
    bit rd_q;
    
    t = t_mon;
    //wr pkt operations
    if (t.wr0_rd1 == 0) begin
      `uvm_info("scoreboard", "write transaction recieved", UVM_LOW)
      //wr_data = wr_queue.pop_front();
      wr_data = t.wr_data;
      //wr_queue.push_back(t.wr_data);
      wr2q = (t.wr_req_ == 1'b0);
      //wr_cnt = (wr_cnt>>1);
      //if (t.wr_req_ == 1'b0) wr_cnt[2] = 1'b1;
      if (wr2q == 1'b1) begin
        shadow_write(wr_data);
        `uvm_info("scoreboard", "Shadow Write transaction aplied", UVM_LOW)
      end      
    end 
    
    //rd pkt operations
    if (t.wr0_rd1 == 1) begin
      `uvm_info("scoreboard", "read transaction recieved", UVM_LOW)
      //rd_q = rd_cnt[0];
      //rd_cnt = (rd_cnt>>1);
      rd_q = (t.rd_req_ == 1'b0);
      //if (t.rd_req_ == 1'b0) rd_cnt[2] = 1'b1;
      if (rd_q == 1'b1) begin
        {rd_valid, rd_data} = shadow_read();
        if (rd_valid) begin
          rd_queue.push_back(rd_data);
          `uvm_info("scoreboard", "Shadow Read transaction aplied", UVM_LOW)
        end
      end
      if (t.rd_valid) begin
        `uvm_info("scoreboard", "rd_valid recieved", UVM_LOW)
        rd_data = rd_queue.pop_front();
        rd_compare(t.rd_data, rd_data);
      end
    end
  endfunction
  
  function shadow_write(bit[3:0] data);
    if (mem_queue.size() != 16) begin
      tb.moishi = 1'b0;
      mem_queue.push_back(data);
      `uvm_info("scoreboard", $sformatf("At %0t: queue size=%0d. written data to queue = %0d", $time(), mem_queue.size(), data), UVM_LOW)
    end
    else begin
      `uvm_info("scoreboard", $sformatf("At %0t: queue if full", $time()) ,UVM_LOW)
    end
    if (mem_queue.size() == 16 && t.full==1'b1) begin
      tb.moishi = 1'b1;
      mem_queue.pop_back();
      `uvm_info("scoreboard", $sformatf("At %0t: data was deleted from queue", $time()) ,UVM_LOW)
    end
  endfunction
  
  function bit[4:0] shadow_read();
    bit[3:0] data;
    bit valid;
    if (mem_queue.size() != 0) begin
      data = mem_queue.pop_front();
      `uvm_info("scoreboard", $sformatf("At %0t: queue size=%0d. rd_data from queue = %0d", $time(), mem_queue.size(), data), UVM_HIGH)
      valid = 1;
    end
    else begin
      data = 'h0;
      valid = 'b0;
      `uvm_info("scoreboard", $sformatf("At %0t: queue is empty", $time()), UVM_HIGH)
    end
    `uvm_info("scoreboard", $sformatf("data=%0d, rd_valid=%0d", data, valid), UVM_HIGH)
    return {valid, data};
  endfunction
  
  function rd_compare(bit[3:0] data1, bit[3:0] data2);
    if (data1 == data2)
      `uvm_info("scoreboard", "rd_data comparison passed", UVM_LOW)
    else
      `uvm_error("scoreboard", "rd_data comparison failed")  
    `uvm_info("scoreboard", $sformatf("recieved data=%0d, expected data=%0d", data1, data2), UVM_LOW)
    
  endfunction
endclass

