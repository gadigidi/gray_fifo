module g2b_decoder(
  input [3:0] g_addr,
  output reg [3:0] b_addr);
  always @(*) begin
    case (g_addr)
      'b0000: b_addr = 'b0000;
      'b0001: b_addr = 'b0001;
      'b0011: b_addr = 'b0010;
      'b0010: b_addr = 'b0011;
      'b0110: b_addr = 'b0100;
      'b0111: b_addr = 'b0101;
      'b0101: b_addr = 'b0110;
      'b0100: b_addr = 'b0111;
      'b1100: b_addr = 'b1000;
      'b1101: b_addr = 'b1001;
      'b1111: b_addr = 'b1010;
      'b1110: b_addr = 'b1011;
      'b1010: b_addr = 'b1100;
      'b1011: b_addr = 'b1101;
      'b1001: b_addr = 'b1110;
      'b1000: b_addr = 'b1111;
      default: b_addr = 'b0000;
    endcase
  end
endmodule

module b2g_decoder(
  input [3:0] b_addr,
  output reg [3:0] g_addr);
  always @(*) begin
    case (b_addr)
      'b0000: g_addr = 'b0000;
      'b0001: g_addr = 'b0001;
      'b0010: g_addr = 'b0011;
      'b0011: g_addr = 'b0010;
      'b0100: g_addr = 'b0110;
      'b0101: g_addr = 'b0111;
      'b0110: g_addr = 'b0101;
      'b0111: g_addr = 'b0100;
      'b1000: g_addr = 'b1100;
      'b1001: g_addr = 'b1101;
      'b1010: g_addr = 'b1111;
      'b1011: g_addr = 'b1110;
      'b1100: g_addr = 'b1010;
      'b1101: g_addr = 'b1011;
      'b1110: g_addr = 'b1001;
      'b1111: g_addr = 'b1000;
      default: g_addr = 'b0000;
    endcase
  end
endmodule

