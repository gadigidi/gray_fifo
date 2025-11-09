module synchronizer #(parameter SYNC_WIDTH=1, parameter SYNC_DLY=1, parameter RST_VAL=0)(
  input clk,
  input rst_,
  input [SYNC_WIDTH-1:0] data_in,
  output [SYNC_WIDTH-1:0] data_synced);
  
  reg [SYNC_WIDTH-1:0] q[SYNC_DLY];
  
  always @(posedge clk) begin
    if (!rst_)
      q[0] <= RST_VAL;
    else
      q[0] <= data_in;
  end 
  
  genvar i;
  generate 
    for (i=1; i<SYNC_DLY; i++) begin
      always @(posedge clk) begin
        if (!rst_)
          q[i] <= RST_VAL;
        else
          q[i] <= q[i-1];
      end
    end
  endgenerate
  
  assign data_synced = q[SYNC_DLY-1];
 
endmodule
	
