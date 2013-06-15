module axi4_stream_master
#(
  parameter C_S_AXI_ADDR_WIDTH       = 32,
  parameter C_S_AXI_DATA_WIDTH       = 32,
  parameter C_M_AXIS_CMD_DATA_WIDTH  = 73,
  parameter C_M_AXIS_STS_DATA_WIDTH  = 8,
  parameter C_STREAMS_WIDTH          = 2,
  parameter C_PAGEWIDTH              = 16
)
(
  // reset and clk
  input                                     clk,
  input                                     rst,

  // these go to the datamover
  output                                    M_AXIS_CMD_TVALID,
  input                                     M_AXIS_CMD_TREADY,
  output [C_M_AXIS_CMD_DATA_WIDTH-1:0]      M_AXIS_CMD_TDATA,

  input                                     S_AXIS_STS_TVALID,
  output                                    S_AXIS_STS_TREADY,
  input [C_M_AXIS_STS_DATA_WIDTH-1:0]       S_AXIS_STS_TDATA,

  input [C_S_AXI_DATA_WIDTH-1:0]            set_data,
  input [C_S_AXI_ADDR_WIDTH-1:0]            set_addr,
  input                                     set_stb,

  output [C_S_AXI_DATA_WIDTH-1:0]           get_data,
  input [C_S_AXI_ADDR_WIDTH-1:0]            get_addr,
  input                                     get_stb,

  input                                     stream_select,
  input                                     stream_valid,

  output [63:0]                             debug
);


  localparam NUM_STREAMS = (1 << C_STREAMS_WIDTH);

  reg [C_STREAMS_WIDTH-1:0] current_stream;

  // select what to connect to get_data output
  reg [C_S_AXI_DATA_WIDTH-1:0] get_data_muxed [NUM_STREAMS-1:0];
  assign get_data = get_data_muxed[get_addr[C_STREAMS_WIDTH+4:5]];

  // cmd + sts fifo mux signals
  wire [C_M_AXIS_CMD_DATA_WIDTH-1:0] cmd_data_muxed [NUM_STREAMS-1:0];
  assign M_AXIS_CMD_TDATA = cmd_data_muxed[current_stream];

  wire      cmd_tvalid_muxed [NUM_STREAMS-1:0];
  wire      sts_tready_muxed [NUM_STREAMS-1:0];

  reg [1:0] state;

  localparam STATE_SET_WHICH_STREAM = 0;
  localparam STATE_ASSERT_DO_CMD = 1;
  localparam STATE_ASSERT_DO_STS = 2;
  localparam STATE_SOME_IDLE = 3;

  // select the stream that will be used
  always @(posedge clk) begin
    if (rst) begin
      state          <= STATE_SET_WHICH_STREAM;
      current_stream <= 0;
    end
    else case (state)

    STATE_SET_WHICH_STREAM: begin
      if (cmd_tvalid_muxed[stream_select])
        state <= STATE_ASSERT_DO_CMD;
      current_stream <= stream_select;
      end

     STATE_ASSERT_DO_CMD: begin
       if (M_AXIS_CMD_TVALID && M_AXIS_CMD_TREADY)
         state <= STATE_ASSERT_DO_STS;
     end

     STATE_ASSERT_DO_STS: begin
       if (S_AXIS_STS_TVALID && S_AXIS_STS_TREADY)
         state <= STATE_SOME_IDLE;
     end

     STATE_SOME_IDLE: begin
       state <= STATE_SET_WHICH_STREAM;
     end

     default: state <= STATE_SET_WHICH_STREAM;

     endcase //state
    end

  wire do_cmd = (state == STATE_ASSERT_DO_CMD);
  wire do_sts = (state == STATE_ASSERT_DO_STS);

  assign M_AXIS_CMD_TVALID = do_cmd && cmd_tvalid_muxed[current_stream];
  assign S_AXIS_STS_TREADY = do_sts && sts_tready_muxed[current_stream];


  wire [32:0] dbg [NUM_STREAMS-1:0];

  // Some regs to poke at
  genvar m;
  generate

  wire write_size;
  wire write_addr;


  for (m = 0; m < NUM_STREAMS; m = m+1) begin : streamer
    wire [15:0] this_streamer = m;


    // Write registers
    wire [C_PAGEWIDTH-3:0] set_addr_aligned = set_addr[C_PAGEWIDTH-1:2];
    wire write_clear   = set_stb && (set_addr_aligned == (0 + m*8));
    wire write_addr    = set_stb && (set_addr_aligned == (1 + m*8));
    wire write_size    = set_stb && (set_addr_aligned == (2 + m*8));
    wire write_sts_rdy = set_stb && (set_addr_aligned == (3 + m*8));
    wire write_sts     = set_stb && (set_addr_aligned == (4 + m*8));
    wire write_axuser  = set_stb && (set_addr_aligned == (5 + m*8));
    wire write_axcache = set_stb && (set_addr_aligned == (6 + m*8));

    // Fill counts for fifos
    wire [10:0] sts_data_count;
    wire [10:0] cmd_addr_count;
    wire [10:0] cmd_size_count;

    wire [C_M_AXIS_STS_DATA_WIDTH-1:0] sts_readback;

    wire [C_S_AXI_DATA_WIDTH-1:0] cmd_size;
    wire [C_S_AXI_ADDR_WIDTH-1:0] cmd_addr;

    // Read registers
    wire [C_PAGEWIDTH-3:0] get_addr_aligned = get_addr[C_PAGEWIDTH-1:2];
    wire read_sig            = (get_addr_aligned == (0 + m*8));
    wire read_status         = (get_addr_aligned == (4 + m*8));
    wire read_sts_data_count = (get_addr_aligned == (5 + m*8));
    wire read_cmd_addr_count = (get_addr_aligned == (6 + m*8));
    wire read_cmd_size_count = (get_addr_aligned == (7 + m*8));

    always @* begin
      if (read_sig)                 get_data_muxed[m] <= {16'hace0, this_streamer};
      else if (read_status)         get_data_muxed[m] <= {24'b0, sts_readback};
      else if (read_sts_data_count) get_data_muxed[m] <= {20'b0, sts_data_count};
      else if (read_cmd_addr_count) get_data_muxed[m] <= {20'b0, cmd_addr_count};
      else if (read_cmd_size_count) get_data_muxed[m] <= {20'b0, cmd_size_count};
      else                          get_data_muxed[m] <= 32'h12345678;
    end

    wire cmd_addr_tvalid, cmd_size_tvalid;
    assign cmd_data_muxed[m][32+39:32+36] = 4'b0; //reserved - 0?
    assign cmd_data_muxed[m][32+35:64]    = m[3:0]; //tag
    assign cmd_data_muxed[m][63:32]       = cmd_addr;
    assign cmd_data_muxed[m][31]          = 1'b0; //DRE ReAlignment Request
    assign cmd_data_muxed[m][30]          = 1'b1; //always EOF for tlast stream
    assign cmd_data_muxed[m][29:24]       = 6'b0; //DRE Stream Alignment
    assign cmd_data_muxed[m][23]          = 1'b0; //reserved - 0?
    assign cmd_data_muxed[m][22:0]        = cmd_size[22:0];

    xlnx_axi_fifo32 addr_fifo
    (
      .s_aclk(clk), .s_aresetn(!rst && !write_clear),
      .s_axis_tvalid(write_addr),
      .s_axis_tready(),
      .s_axis_tdata(set_data),
      .m_axis_tvalid(cmd_addr_tvalid),
      .m_axis_tready(M_AXIS_CMD_TREADY && do_cmd && (current_stream == m)),
      .m_axis_tdata(cmd_addr),
      .axis_data_count(cmd_addr_count)
    );

    xlnx_axi_fifo32 size_fifo
    (
      .s_aclk(clk), .s_aresetn(!rst && !write_clear),
      .s_axis_tvalid(write_size),
      .s_axis_tready(),
      .s_axis_tdata(set_data),
      .m_axis_tvalid(cmd_size_tvalid),
      .m_axis_tready(M_AXIS_CMD_TREADY && do_cmd && (current_stream == m)),
      .m_axis_tdata(cmd_size),
      .axis_data_count(cmd_size_count)
    );

    assign cmd_tvalid_muxed[m] = cmd_addr_tvalid && cmd_size_tvalid && stream_valid;

    wire dm_sts_tvalid = S_AXIS_STS_TVALID && do_sts && (current_stream == m);

    xlnx_axi_fifo8 sts_fifo
    (
      .s_aclk(clk), .s_aresetn(!rst),
      .s_axis_tvalid(write_sts || dm_sts_tvalid),
      .s_axis_tready(sts_tready_muxed[m]),
      .s_axis_tdata(write_sts ? set_data[C_M_AXIS_STS_DATA_WIDTH-1:0] : S_AXIS_STS_TDATA),
      .m_axis_tvalid(),
      .m_axis_tready(write_sts_rdy),
      .m_axis_tdata(sts_readback),
      .axis_data_count(sts_data_count)
    );

    assign dbg[m] = {cmd_addr_count, cmd_size_count, sts_data_count};

  end
  endgenerate

  assign debug [32:0]  = dbg[0];
  assign debug [34:33] = state;

endmodule
