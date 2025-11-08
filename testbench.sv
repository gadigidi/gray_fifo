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
        $display("Time is %0t. read transaction", $time);
        t.print(uvm_default_line_printer);
        `uvm_info("monitor", "Read transaction sent to Scbd", UVM_HIGH)
        sender.write(t);
      end
    end
  endtask

endclass

    
    
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


    
///////////// scoreboard /////////////
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  bit[3:0] mem_queue[$:15];
  bit[3:0] wr_queue[$:2] = {'h0, 'h0, 'h0};
  bit[3:0] rd_queue[$:15]; //no need for this FIXME
  
  bit [2:0] wr_cnt;
  bit [2:0] rd_cnt;
  
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
      wr_data = wr_queue.pop_front();
      wr_queue.push_back(t.wr_data);
      wr2q = wr_cnt[0];
      wr_cnt = (wr_cnt>>1);
      if (t.wr_req_ == 1'b0) wr_cnt[2] = 1'b1;
      if (wr2q == 1'b1) begin
        shadow_write(wr_data);
        `uvm_info("scoreboard", "Shadow Write transaction aplied", UVM_LOW)
      end      
    end 
    
    //rd pkt operations
    if (t.wr0_rd1 == 1) begin
      `uvm_info("scoreboard", "read transaction recieved", UVM_LOW)
      rd_q = rd_cnt[0];
      rd_cnt = (rd_cnt>>1);
      if (t.rd_req_ == 1'b0) rd_cnt[2] = 1'b1;
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
      mem_queue.push_back(data);
      `uvm_info("scoreboard", $sformatf("At %0t: queue size=%0d. written data to queue = %0d", $time(), mem_queue.size(), data), UVM_LOW)
    end
    else
      `uvm_info("scoreboard", $sformatf("At %0t: queue if full", $time()) ,UVM_LOW)
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
  
  virtual function rd_compare(bit[3:0] data1, bit[3:0] data2);
    if (data1 == data2)
      `uvm_info("scoreboard", "rd_data comparison passed", UVM_LOW)
    else
      `uvm_error("scoreboard", "rd_data comparison failed")  
    `uvm_info("scoreboard", $sformatf("recieved data=%0d, expected data=%0d", data1, data2), UVM_LOW)
    
  endfunction
endclass


      
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
      wr_gen.start(en.agnt.wr_seqr);
      rd_gen.start(en.agnt.rd_seqr);
    join
    `uvm_info("test", "gen.start done", UVM_LOW)
    #100;
    phase.drop_objection(this);
  endtask
endclass
    
    
///////////// tb /////////////
module tb();
  
  gfifo_if gif();
  g_fifo gfifo (.gif(gif.DUT));
  
  wire diff;
  wire wr_req_synced_;
  wire [3:0] rd_ptr_b_wc;
  wire [3:0] rd_ptr_b_rc;
  assign wr_req_synced_ = tb.gfifo.wr_ctrl.wr_req_synced_;
  assign rd_ptr_b_wc = tb.gfifo.wr_ctrl.rd_ptr_b;
  assign rd_ptr_b_rc = tb.gfifo.rd_ctrl.rd_ptr_b;
  assign diff = ~wr_req_synced_ & (rd_ptr_b_wc != rd_ptr_b_rc) & tb.gfifo.wr_ctrl.wr_clk;
  
  initial begin
    gif.wr_clk = 1'b0;
  end
  always begin
    #5;
    gif.wr_clk = ~gif.wr_clk;
  end
  
  initial begin
    gif.rd_clk = 1'b0;
  end  
  always begin
    #8;
    gif.rd_clk = ~gif.rd_clk;
  end
  
  initial begin
    `uvm_info("TB_TOP", "TB initial begin started", UVM_LOW)
    uvm_config_db #(virtual gfifo_if)::set(null, "*", "gif", gif);
    run_test("test");
  end
   
  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
  end         
endmodule


