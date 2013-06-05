module axi4_stream_master
#(
  parameter C_S_AXI_ADDR_WIDTH      = 32,
  parameter C_S_AXI_DATA_WIDTH      = 32,
  parameter C_M_AXIS_CMD_DATA_WIDTH = 72,
  parameter C_M_AXIS_STS_DATA_WIDTH = 8
)
(
  // reset and clk
  input                                     clk,
  input                                     rst,

  // these go to the datamover
  output                                    M_AXIS_CMD_TVALID,
  input                                     M_AXIS_CMD_TREADY,
  output reg [C_M_AXIS_CMD_DATA_WIDTH-1:0]  M_AXIS_CMD_TDATA,

  input                                     S_AXIS_STS_TVALID,
  output                                    S_AXIS_STS_TREADY,
  input [C_M_AXIS_STS_DATA_WIDTH-1:0]       S_AXIS_STS_TDATA,

  input [C_S_AXI_DATA_WIDTH-1:0]            set_data,
  input [C_S_AXI_ADDR_WIDTH-1:0]            set_addr,
  input                                     set_stb,

  output [C_S_AXI_DATA_WIDTH-1:0]           get_data,
  input  [C_S_AXI_ADDR_WIDTH-1:0]           get_addr,
  input                                     get_stb
);

reg [1:0] foo;

always @ (posedge clk)
    foo <= foo + 1'b1;

endmodule


