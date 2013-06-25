//
// Copyright 2013 Ettus Research LLC
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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
  parameter         C_PAGEWIDTH              = 12,
  parameter integer C_H2S_STREAMS_WIDTH      = 2,
  parameter integer C_S2H_STREAMS_WIDTH      = 2
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
  output [4:0]                      M_AXI_AWUSER,
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
  output [4:0]                      M_AXI_ARUSER,
  output [7:0]                      M_AXI_ARLEN,
  output [1:0]                      M_AXI_ARBURST,
  output [2:0]                      M_AXI_ARSIZE,

  output                            irq
);

  // sweet sweet lazyness
  wire rst_n = !rst;

  // For the moment we have a shared interrupt
  assign irq = h2s_sts_tvalid | s2h_sts_tvalid;

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
  //-- hopefully fix misbehaving axi datamover
  //------------------------------------------------------------------
  //only active in cycles between command and tlast
  //this prevents bullshit consumption after tlast
  reg s2h_active;
  always @(posedge clk) begin
    if (rst) s2h_active <= 1;
    else if (s2h_cmd_tvalid && s2h_cmd_tready) s2h_active <= 1;
    else if (s2h_tready && s2h_tvalid && s2h_tlast) s2h_active <= 0;
  end

  //cut fifo comms when not in active state
  wire s2h_tready_int, s2h_tvalid_int;
  assign s2h_tvalid_int = s2h_tvalid && s2h_active;
  assign s2h_tready = s2h_tready_int && s2h_active;


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
    .S_AXI_ARESETN(rst_n),
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

  // memory is paged into three pages
  wire [1:0] set_page = set_addr[C_PAGEWIDTH+1:C_PAGEWIDTH];
  wire [1:0] get_page = get_addr[C_PAGEWIDTH+1:C_PAGEWIDTH];

  wire set_stb_s2h = set_stb && (set_page == 2'h1);
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data_s2h;

  wire set_stb_h2s = set_stb && (set_page == 2'h0);
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data_h2s;

  wire set_stb_global = set_stb && (set_page == 2'h2);
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data_global;

  assign get_data = (get_page == 2'h0) ? get_data_h2s
                  : (get_page == 2'h1) ? get_data_s2h
                  : (get_page == 2'h2) ? get_data_global
                  : 32'hdeadbeef;

  wire soft_reset;
  wire soft_reset_n = !set_stb_global;

  global_settings #
  (
    .C_DATAWIDTH(C_S_AXI_DATA_WIDTH),
    .C_ADDRWIDTH(C_S_AXI_ADDR_WIDTH),
    .C_PAGEWIDTH(C_PAGEWIDTH)
  )
  settings0
  (
    .clk(clk), .rst(rst),
    .get_addr(get_addr),
    .get_data(get_data_global),
    .set_stb(set_stb_global),
    .set_addr(set_addr),
    .set_data(set_data),
    .arcache(M_AXI_ARCACHE),
    .aruser(M_AXI_ARUSER),
    .awcache(M_AXI_AWCACHE),
    .awuser(M_AXI_AWUSER),
    .soft_reset(soft_reset)
  );

  assign TRIG[7] = soft_reset;

  // simple round robin implementation for checking available packets
  reg [C_H2S_STREAMS_WIDTH-1:0] which_stream_h2s;
  always @(posedge clk)
    if (rst)
      which_stream_h2s <= 0;
    else
      which_stream_h2s <= which_stream_h2s + 1'b1;

  // AXI 4 stream master to handle accelerator to host
  axi4_stream_master #
  ( .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_M_AXIS_CMD_DATA_WIDTH(72),
    .C_M_AXIS_STS_DATA_WIDTH(8),
    .C_PAGEWIDTH(C_PAGEWIDTH)
  )
  s2h_master
  (
    .clk(clk),
    .rst(rst || soft_reset),

    .M_AXIS_CMD_TVALID(s2h_cmd_tvalid),
    .M_AXIS_CMD_TREADY(s2h_cmd_tready),
    .M_AXIS_CMD_TDATA(s2h_cmd_tdata),

    .S_AXIS_STS_TVALID(s2h_sts_tvalid),
    .S_AXIS_STS_TREADY(s2h_sts_tready),
    .S_AXIS_STS_TDATA(s2h_sts_tdata),

    .set_data(set_data),
    .set_addr(set_addr),
    .set_stb(set_stb_s2h),

    .get_data(get_data_s2h),
    .get_addr(get_addr),

    .stream_select(1'b0),
    .stream_valid(1'b1),

    .debug(DATA[183:120])
  );


  // AXI 4 stream master to handle host to accelerator
  axi4_stream_master #
  ( .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_M_AXIS_CMD_DATA_WIDTH(72),
    .C_M_AXIS_STS_DATA_WIDTH(8),
    .C_PAGEWIDTH(C_PAGEWIDTH)
  )
  h2s_master
  (
    .clk(clk),
    .rst(rst || soft_reset),

    .M_AXIS_CMD_TVALID(h2s_cmd_tvalid),
    .M_AXIS_CMD_TREADY(h2s_cmd_tready),
    .M_AXIS_CMD_TDATA(h2s_cmd_tdata),

    .S_AXIS_STS_TVALID(h2s_sts_tvalid),
    .S_AXIS_STS_TREADY(h2s_sts_tready),
    .S_AXIS_STS_TDATA(h2s_sts_tdata),

    .set_data(set_data),
    .set_addr(set_addr),
    .set_stb(set_stb_h2s),

    .get_data(get_data_h2s),
    .get_addr(get_addr),

    .stream_select(which_stream_h2s),
    .stream_valid(1'b1),

    .debug(DATA[283:220])
  );

  wire [14:0] loopback_count;

  assign TRIG[0] = get_stb;
  assign TRIG[1] = set_stb;

  assign TRIG[4] = h2s_sts_tvalid;
  assign TRIG[5] = s2h_sts_tvalid;

  assign DATA[1] = set_stb_s2h;
  assign DATA[33:2] = get_data;
  assign DATA[65:34] = get_addr;
  assign DATA[97:66] = set_addr;
  assign DATA[112:98] = loopback_count;

  assign DATA[113] = h2s_sts_tvalid;
  assign DATA[114] = s2h_sts_tvalid;

  assign DATA[309]     = h2s_cmd_tvalid;
  assign DATA[381:310] = h2s_cmd_tdata;
  assign DATA[382]     = h2s_cmd_tready;

  assign DATA[383]     = h2s_sts_tvalid;
  assign DATA[391:384] = h2s_sts_tdata;
  assign DATA[392]     = h2s_sts_tready;

  assign DATA[409]     = s2h_cmd_tvalid;
  assign DATA[481:410] = s2h_cmd_tdata;
  assign DATA[482]     = s2h_cmd_tready;

  assign DATA[483]     = s2h_sts_tvalid;
  assign DATA[491:484] = s2h_sts_tdata;
  assign DATA[492]     = s2h_sts_tready;

  // hook up debug to ACP read signals
  assign DATA[543:512] = M_AXI_ARADDR;
  assign DATA[544]     = M_AXI_ARVALID;
  assign DATA[545]     = M_AXI_ARREADY;
  assign DATA[609:546] = M_AXI_RDATA;
  assign DATA[610]     = M_AXI_RVALID;
  assign DATA[611]     = M_AXI_RREADY;

  assign TRIG[3]       = M_AXI_RVALID;

  // hook up debug to ACP write signals
  assign DATA[643:612] = M_AXI_AWADDR;
  assign DATA[644]     = M_AXI_AWVALID;
  assign DATA[645]     = M_AXI_AWREADY;
  assign DATA[709:646] = M_AXI_WDATA;
  assign DATA[710]     = M_AXI_WVALID;
  assign DATA[711]     = M_AXI_WREADY;

  assign TRIG[2]       = M_AXI_WVALID;

  xlnx_axi_fifo loopback_fifo
  (
   .s_aclk(clk), .s_aresetn(rst_n && soft_reset_n),
   .s_axis_tvalid(h2s_tvalid),
   .s_axis_tready(h2s_tready),
   .s_axis_tdata(h2s_tdata),
   .s_axis_tlast(h2s_tlast),
   .m_axis_tvalid(s2h_tvalid),
   .m_axis_tready(s2h_tready),
   .m_axis_tdata(s2h_tdata),
   .m_axis_tlast(s2h_tlast),
   .axis_data_count(loopback_count)
  );

  // hook up debug to loopback fifo in and out
  assign DATA[775:712] = h2s_tdata;
  assign DATA[776]     = h2s_tvalid;
  assign DATA[777]     = h2s_tready;
  assign DATA[778]     = h2s_tlast;

  assign DATA[842:779] = s2h_tdata;
  assign DATA[843]     = s2h_tvalid;
  assign DATA[844]     = s2h_tready;
  assign DATA[845]     = s2h_tlast;

  assign DATA[846]     = s2h_tvalid_int;
  assign DATA[847]     = s2h_tready_int;


  xlnx_axi_datamover datamover (

    // AXI stream to custom hardware reset
    .m_axi_mm2s_aclk(clk),
    .m_axi_mm2s_aresetn(rst_n && soft_reset_n),
    .mm2s_halt(1'b0),
    .mm2s_halt_cmplt(),
    .mm2s_err(),

    // AXI stream to custom hardware command
    .m_axis_mm2s_cmdsts_aclk(clk),
    .m_axis_mm2s_cmdsts_aresetn(rst_n && soft_reset_n),
    .s_axis_mm2s_cmd_tvalid(h2s_cmd_tvalid),
    .s_axis_mm2s_cmd_tready(h2s_cmd_tready),
    .s_axis_mm2s_cmd_tdata(h2s_cmd_tdata),

    // AXI stream to custom hardware status
    .m_axis_mm2s_sts_tvalid(h2s_sts_tvalid),
    .m_axis_mm2s_sts_tready(h2s_sts_tready),
    .m_axis_mm2s_sts_tdata(h2s_sts_tdata),
    //.m_axis_mm2s_sts_tkeep(),
    .m_axis_mm2s_sts_tlast(),

    // store and forward - can always post?
    .mm2s_allow_addr_req(1'b1),
    .mm2s_addr_req_posted(),
    .mm2s_rd_xfer_cmplt(),

    // this will go to the ACP (read)
    .m_axi_mm2s_arid(),
    .m_axi_mm2s_araddr(M_AXI_ARADDR),
    .m_axi_mm2s_arlen(M_AXI_ARLEN),
    .m_axi_mm2s_arsize(M_AXI_ARSIZE),
    .m_axi_mm2s_arburst(M_AXI_ARBURST),
    .m_axi_mm2s_arprot(M_AXI_ARPROT),
//    .m_axi_mm2s_arcache(M_AXI_ARCACHE),
    .m_axi_mm2s_arvalid(M_AXI_ARVALID),
    .m_axi_mm2s_arready(M_AXI_ARREADY),
    .m_axi_mm2s_rdata(M_AXI_RDATA),
    .m_axi_mm2s_rresp(M_AXI_RRESP),
    .m_axi_mm2s_rlast(M_AXI_RLAST),
    .m_axi_mm2s_rvalid(M_AXI_RVALID),
    .m_axi_mm2s_rready(M_AXI_RREADY),

    // AXI stream to custom hardware
    .m_axis_mm2s_tdata(h2s_tdata), // TODO flip?!
    .m_axis_mm2s_tkeep(), // TODO good like this?!
    .m_axis_mm2s_tlast(h2s_tlast),
    .m_axis_mm2s_tvalid(h2s_tvalid),
    .m_axis_mm2s_tready(h2s_tready),

    // we're not using debug
    .mm2s_dbg_sel(4'b0),
    .mm2s_dbg_data(),

    // AXI stream from custom hardware reset
    .m_axi_s2mm_aclk(clk),
    .m_axi_s2mm_aresetn(rst_n && soft_reset_n),
    .s2mm_halt(1'b0),
    .s2mm_halt_cmplt(),
    .s2mm_err(),

    // AXI stream from custom hardware command
    .m_axis_s2mm_cmdsts_awclk(clk),
    .m_axis_s2mm_cmdsts_aresetn(rst_n && soft_reset_n),
    .s_axis_s2mm_cmd_tvalid(s2h_cmd_tvalid),
    .s_axis_s2mm_cmd_tready(s2h_cmd_tready),
    .s_axis_s2mm_cmd_tdata(s2h_cmd_tdata),

    // AXI stream from custom hardware status
    .m_axis_s2mm_sts_tvalid(s2h_sts_tvalid),
    .m_axis_s2mm_sts_tready(s2h_sts_tready),
    .m_axis_s2mm_sts_tdata(s2h_sts_tdata),
    .m_axis_s2mm_sts_tkeep(),
    .m_axis_s2mm_sts_tlast(),

    // store and forward - can always post?
    .s2mm_allow_addr_req(1'b1),
    .s2mm_addr_req_posted(),
    .s2mm_wr_xfer_cmplt(),
    .s2mm_ld_nxt_len(),
    .s2mm_wr_len(),

    // this will go to the ACP (write)
    .m_axi_s2mm_awid(),
    .m_axi_s2mm_awaddr(M_AXI_AWADDR),
    .m_axi_s2mm_awlen(M_AXI_AWLEN),
    .m_axi_s2mm_awsize(M_AXI_AWSIZE),
    .m_axi_s2mm_awburst(M_AXI_AWBURST),
    .m_axi_s2mm_awprot(M_AXI_AWPROT),
 //   .m_axi_s2mm_awcache(M_AXI_AWCACHE),
    .m_axi_s2mm_awvalid(M_AXI_AWVALID),
    .m_axi_s2mm_awready(M_AXI_AWREADY),
    .m_axi_s2mm_wdata(M_AXI_WDATA),
    .m_axi_s2mm_wstrb(M_AXI_WSTRB),
    .m_axi_s2mm_wlast(M_AXI_WLAST),
    .m_axi_s2mm_wvalid(M_AXI_WVALID),
    .m_axi_s2mm_wready(M_AXI_WREADY),
    .m_axi_s2mm_bresp(M_AXI_BRESP),
    .m_axi_s2mm_bvalid(M_AXI_BVALID),
    .m_axi_s2mm_bready(M_AXI_BREADY),

    // AXI stream from custom hardware
    .s_axis_s2mm_tdata(s2h_tdata), // TODO flip?!
    .s_axis_s2mm_tkeep(8'hff), // keep 'em all
    .s_axis_s2mm_tlast(s2h_tlast),
    .s_axis_s2mm_tvalid(s2h_tvalid_int),
    .s_axis_s2mm_tready(s2h_tready_int),

    // we're not using debug
    .s2mm_dbg_sel(4'b0),
    .s2mm_dbg_data()
  );

endmodule
