module accelerator
#(
  parameter integer C_S_AXI_ADDR_WIDTH       = 32,
  parameter integer C_S_AXI_DATA_WIDTH       = 32,
  parameter integer C_M_AXI_ADDR_WIDTH       = 32,
  parameter integer C_M_AXI_DATA_WIDTH       = 64,
  parameter integer C_AXIS_DATA_WIDTH        = 64,
  parameter integer C_AXIS_HOST_DATA_WIDTH   = 32,
  parameter integer C_BASEADDR               = 32'h40000000,
  parameter integer C_HIGHADDR               = 32'h4001ffff,
  parameter         C_PROT                   = 3'b010,
  parameter         C_PAGEWIDTH              = 16
)
(
  // generic stuff
  input                             clk,
  input                             rst,

  // control axi slave signals (write)
  input  [C_S_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
  input                             S_AXI_AWVALID,
  output                            S_AXI_AWREADY,
  input [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_WDATA,
  input [C_S_AXI_DATA_WIDTH/8-1:0]  S_AXI_WSTRB,
  input                             S_AXI_WVALID,
  output                            S_AXI_WREADY,
  output [1:0]                      S_AXI_BRESP,
  output                            S_AXI_BVALID,
  input                             S_AXI_BREADY,

  // control axi slave signals (read)
  input [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_ARADDR,
  input                             S_AXI_ARVALID,
  output                            S_AXI_ARREADY,
  output [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA,
  output [1:0]                      S_AXI_RRESP,
  output                            S_AXI_RVALID,
  input                             S_AXI_RREADY,

  // these go to the ACP port (write)
  output [C_M_AXI_ADDR_WIDTH-1:0]   M_AXI_AWADDR,
  output [2:0]                      M_AXI_AWPROT,
  output                            M_AXI_AWVALID,
  input                             M_AXI_AWREADY,
  output [C_M_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
  output [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
  output                            M_AXI_WVALID,
  input                             M_AXI_WREADY,
  input [1:0]                       M_AXI_BRESP,
  input                             M_AXI_BVALID,
  output                            M_AXI_BREADY,
  output [7:0]                      M_AXI_AWLEN,
  output [2:0]                      M_AXI_AWSIZE,
  output [1:0]                      M_AXI_AWBURST,
  output [3:0]                      M_AXI_AWCACHE,
  output                            M_AXI_WLAST,

  // these go to the ACP port (read)
  output [C_M_AXI_ADDR_WIDTH-1:0]   M_AXI_ARADDR,
  output [2:0]                      M_AXI_ARPROT,
  output                            M_AXI_ARVALID,
  input                             M_AXI_ARREADY,
  input [C_M_AXI_DATA_WIDTH-1:0]    M_AXI_RDATA,
  input [1:0]                       M_AXI_RRESP,
  input                             M_AXI_RVALID,
  output                            M_AXI_RREADY,
  input                             M_AXI_RLAST,
  output [3:0]                      M_AXI_ARCACHE,
  output [7:0]                      M_AXI_ARLEN,
  output [1:0]                      M_AXI_ARBURST,
  output [2:0]                      M_AXI_ARSIZE
);
  // AXI stream to custom hardware
  wire [C_AXIS_DATA_WIDTH-1:0]         h2s_tdata;
  wire                                 h2s_tlast;
  wire                                 h2s_tvalid;
  wire                                 h2s_tready;

  // AXI stream from custom hardware
  wire [C_AXIS_DATA_WIDTH-1:0]         s2h_tdata;
  wire                                 s2h_tlast;
  wire                                 s2h_tvalid;
  wire                                 s2h_tready;

  // AXI stream to custom hardware command and status signals
  wire [C_AXIS_HOST_DATA_WIDTH-1+40:0] h2s_cmd_tdata;
  wire [7:0]                           h2s_sts_tdata;
  wire                                 h2s_cmd_tvalid;
  wire                                 h2s_cmd_tready;
  wire                                 h2s_sts_tvalid;
  wire                                 h2s_sts_tready;

  // AXI stream from custom hardware command and status signals
  wire [C_AXIS_HOST_DATA_WIDTH-1+40:0] s2h_cmd_tdata;
  wire                                 s2h_cmd_tvalid;
  wire                                 s2h_cmd_tready;
  wire [7:0]                           s2h_sts_tdata;
  wire                                 s2h_sts_tvalid;
  wire                                 s2h_sts_tready;

  //------------------------------------------------------------------
  //-- chipscope
  //------------------------------------------------------------------
  wire [35:0] CONTROL;
  wire [1023:0] DATA;
  wire [7:0] TRIG;

  chipscope_icon chipscope_icon(.CONTROL0(CONTROL));
  chipscope_ila_large chipscope_ila
  (
    .CONTROL(CONTROL), .CLK(clk),
    .DATA(DATA), .TRIG0(TRIG)
  );

  //------------------------------------------------------------------
  // control logic reachable via AXI slave
  //------------------------------------------------------------------
  wire [C_S_AXI_ADDR_WIDTH-1:0] set_addr;
  wire [C_S_AXI_DATA_WIDTH-1:0] set_data;
  wire                          set_stb;

  wire [C_S_AXI_ADDR_WIDTH-1:0] get_addr;
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data;
  wire                          get_stb;

  axi4_lite_slave #
  (.C_BASEADDR(C_BASEADDR),
   .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
   .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)
  )
  slave0
  (
    .S_AXI_ACLK(clk),
    .S_AXI_ARESETN(!rst),
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),

    .S_AXI_AWADDR(S_AXI_AWADDR),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),
    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),
    .S_AXI_BRESP(S_AXI_BRESP),
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),

    .set_addr(set_addr),
    .set_data(set_data),
    .set_stb(set_stb),

    .get_addr(get_addr),
    .get_data(get_data),
    .get_stb(get_stb)
  );

  // memory is paged into two pages
  wire set_stb_s2h = set_stb && !set_addr[C_PAGEWIDTH];
  wire get_stb_s2h = get_stb && !get_addr[C_PAGEWIDTH];

  wire set_stb_h2s = set_stb &&  set_addr[C_PAGEWIDTH];
  wire get_stb_h2s = get_stb &&  get_addr[C_PAGEWIDTH];


  // AXI 4 stream master to handle accelerator to host
  axi4_stream_master #
  ( .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_M_AXIS_CMD_DATA_WIDTH(72),
    .C_M_AXIS_STS_DATA_WIDTH(8)
  )
  s2h_master
  (
    .clk(clk),
    .rst(rst),

    .M_AXIS_CMD_TVALID(s2h_cmd_tvalid),
    .M_AXIS_CMD_TREADY(s2h_cmd_tready),
    .M_AXIS_CMD_TDATA(s2h_cmd_tdata),

    .S_AXIS_STS_TVALID(s2h_sts_tvalid),
    .S_AXIS_STS_TREADY(s2h_sts_tready),
    .S_AXIS_STS_TDATA(s2h_sts_tdata),

    .set_data(set_data),
    .set_addr(set_addr),
    .set_stb(set_stb_s2h),

    .get_data(get_data),
    .get_addr(get_addr),
    .get_stb(get_stb_s2h)
  );

  // AXI 4 stream master to handle host to accelerator
  axi4_stream_master #
  ( .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_M_AXIS_CMD_DATA_WIDTH(72),
    .C_M_AXIS_STS_DATA_WIDTH(8)
  )
  h2s_master
  (
    .clk(clk),
    .rst(rst),

    .M_AXIS_CMD_TVALID(h2s_cmd_tvalid),
    .M_AXIS_CMD_TREADY(h2s_cmd_tready),
    .M_AXIS_CMD_TDATA(h2s_cmd_tdata),

    .S_AXIS_STS_TVALID(h2s_sts_tvalid),
    .S_AXIS_STS_TREADY(h2s_sts_tready),
    .S_AXIS_STS_TDATA(h2s_sts_tdata),

    .set_data(set_data),
    .set_addr(set_addr),
    .set_stb(set_stb_h2s),

    .get_data(get_data),
    .get_addr(get_addr),
    .get_stb(get_stb_h2s)
  );


  assign TRIG[0] = get_stb;
  assign TRIG[1] = set_stb;

  assign DATA[0] = get_stb_s2h;
  assign DATA[1] = set_stb_s2h;
  assign DATA[33:2] = get_data;
  assign DATA[65:34] = get_addr;
  assign DATA[97:66] = set_addr;


  axi_demux stream_demux
  (
    .clk(clk),
    .rst(rst)
  );

  //assign get_data = (get_stb && (get_addr == 0)) ? 32'hace0b00b
                  //: (get_stb && (get_addr == 4)) ? 32'hace0b004
                  //: 32'hdeadbeef;

endmodule
