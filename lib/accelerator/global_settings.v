module global_settings
#(
  parameter C_DATAWIDTH = 32,
  parameter C_ADDRWIDTH = 32,
  parameter C_PAGEWIDTH = 12,
  parameter C_S2H_NUM_STREAMS = 2,
  parameter C_H2S_NUM_STREAMS = 2
)
(
  input clk,
  input rst,

  input [C_DATAWIDTH-1:0]      set_data,
  input                        set_stb,
  input [C_ADDRWIDTH-1:0]      set_addr,

  output reg [C_DATAWIDTH-1:0] get_data,
  input                        get_stb,
  input [C_ADDRWIDTH-1:0]      get_addr,

  output                       soft_reset,
  output [4:0]                 aruser,
  output [3:0]                 arcache,
  output [4:0]                 awuser,
  output [3:0]                 awcache
);
  reg [C_DATAWIDTH-1:0] _aruser;
  reg [C_DATAWIDTH-1:0] _arcache;
  reg [C_DATAWIDTH-1:0] _awuser;
  reg [C_DATAWIDTH-1:0] _awcache;


  localparam [C_DATAWIDTH-1:0] signature = 32'hace0ba53;

  wire [C_PAGEWIDTH-3:0] set_addr_aligned = set_addr[C_PAGEWIDTH-1:2];
  wire write_reset   = set_stb && (set_addr_aligned == 0);
  wire write_aruser  = set_stb && (set_addr_aligned == 1);
  wire write_arcache = set_stb && (set_addr_aligned == 2);
  wire write_awuser  = set_stb && (set_addr_aligned == 3);
  wire write_awcache = set_stb && (set_addr_aligned == 4);

  always @* begin
    if (rst) begin
      _aruser  <= 5'b11111;
      _arcache <= 4'b1111;
      _awuser  <= 5'b11111;
      _awcache <= 4'b1111;
    end
    else if (write_aruser)   _aruser  <= set_data & 5'b11111;
    else if (write_arcache)  _arcache <= set_data & 4'b1111;
    else if (write_awuser)   _awuser  <= set_data & 5'b11111;
    else if (write_awcache)  _awcache <= set_data & 4'b1111;
  end

  wire [C_PAGEWIDTH-3:0] get_addr_aligned = get_addr[C_PAGEWIDTH-1:2];
  wire read_sig      = get_stb && (get_addr_aligned == 0);
  wire read_aruser   = get_stb && (get_addr_aligned == 1);
  wire read_arcache  = get_stb && (get_addr_aligned == 2);
  wire read_awuser   = get_stb && (get_addr_aligned == 3);
  wire read_awcache  = get_stb && (get_addr_aligned == 4);
  wire read_s2h_nstr = get_stb && (get_addr_aligned == 5);
  wire read_h2s_nstr = get_stb && (get_addr_aligned == 6);

  always @* begin
    if(read_sig) get_data <= signature;
    else if (read_aruser)  get_data <= {27'h0, _aruser};
    else if (read_arcache) get_data <= {26'h0, _arcache};
    else if (read_awuser)  get_data <= {27'h0, _awuser};
    else if (read_awcache) get_data <= {28'h0, _awcache};
    else if (read_s2h_nstr)get_data <= C_S2H_NUM_STREAMS;
    else if (read_h2s_nstr)get_data <= C_H2S_NUM_STREAMS;
    else get_data <= 32'h01234567;
  end

  assign soft_reset = write_reset;
  assign aruser  = _aruser;
  assign arcache = _arcache;
  assign awuser  = _awuser;
  assign awcache = _awcache;
  //assign debug[9:0]   = get_addr_aligned;
  //assign debug[41:10] = get_data;
  //assign debug[42]    = read_sig;
  //assign debug[43]    = write_reset;
  //assign debug[44]    = write_aruser;
  //assign debug[45]    = write_awuser;
  //assign debug[46]    = write_arcache;
  //assign debug[47]    = write_awcache;

endmodule
