module axi4_stream_master
#(
  parameter C_S_AXI_ADDR_WIDTH      = 32,
  parameter C_S_AXI_DATA_WIDTH      = 32,
  parameter C_M_AXIS_CMD_DATA_WIDTH = 73,
  parameter C_M_AXIS_STS_DATA_WIDTH = 8,
  parameter STREAMS_WIDTH           = 2,
  parameter PAGE_SIZE              = 16
)
(
  /* reset and clk */
  input                                     clk,
  input                                     rst,

  /* these go to the datamover */
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


  localparam NUM_STREAMS = (1 << STREAMS_WIDTH);

  reg [STREAMS_WIDTH-1:0] current_stream;

  /* select what to connect to get_data output */
  reg [C_S_AXI_DATA_WIDTH-1:0] get_data_muxed [NUM_STREAMS-1:0];
  assign get_data = get_data_muxed[get_data[STREAMS_WIDTH+4:5]];

  /* cmd + sts fifo mux signals */
  wire [C_M_AXIS_CMD_DATA_WIDTH-1:0] cmd_data_muxed [NUM_STREAMS-1:0];
  assign M_AXIS_CMD_TDATA = cmd_data_muxed[current_stream];

  wire      cmd_tvalid_muxed [NUM_STREAMS-1:0];
  wire      sts_tready_muxed [NUM_STREAMS-1:0];

  reg [1:0] state;

  localparam STATE_SET_WHICH_STREAM = 0;
  localparam STATE_ASSERT_DO_CMD = 1;
  localparam STATE_ASSERT_DO_STS = 2;
  localparam STATE_SOME_IDLE = 3;

  /* select the stream that will be used */
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

endmodule
