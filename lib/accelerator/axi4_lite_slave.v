module axi4_lite_slave
#(
  parameter C_BASEADDR         = 32'h40000000,
  parameter C_HIGHADDR         = 32'h4001ffff,
  parameter C_S_AXI_ADDR_WIDTH = 32,
  parameter C_S_AXI_DATA_WIDTH = 32
)
(
  input                              S_AXI_ACLK,
  input                              S_AXI_ARESETN,

  // read signals
  input  [C_S_AXI_ADDR_WIDTH-1:0]    S_AXI_ARADDR,
  input                              S_AXI_ARVALID,
  output                             S_AXI_ARREADY,
  output [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_RDATA,
  output [1:0]                       S_AXI_RRESP,
  output                             S_AXI_RVALID,
  input                              S_AXI_RREADY,

  // write signals
  input [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_AWADDR,
  input                              S_AXI_AWVALID,
  output                             S_AXI_AWREADY,
  input [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
  input [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
  input                              S_AXI_WVALID,
  output                             S_AXI_WREADY,
  output [1:0]                       S_AXI_BRESP,
  output                             S_AXI_BVALID,
  input                              S_AXI_BREADY,

  // some registers
  output reg [C_S_AXI_DATA_WIDTH-1:0] set_addr,
  output reg [C_S_AXI_DATA_WIDTH-1:0] set_data,
  output                              set_stb,

  output reg [C_S_AXI_DATA_WIDTH-1:0] get_addr,
  input      [C_S_AXI_DATA_WIDTH-1:0] get_data,
  output                              get_stb
);
  //------------------------------------------------------------------
  // read state machine
  //------------------------------------------------------------------
  localparam STATE_RD_GET_ADDR = 0;
  localparam STATE_RD_READ     = 1;
  localparam STATE_RD_GET_DATA = 2;

  reg [1:0] rd_state;

  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      rd_state  <= STATE_RD_GET_ADDR;
      get_addr <= 0;
    end
    else case (rd_state)

    STATE_RD_GET_ADDR: begin
      if (S_AXI_ARVALID && S_AXI_ARREADY) begin
        get_addr <= (S_AXI_ARADDR - C_BASEADDR);
        rd_state <= STATE_RD_READ;
      end
    end

    STATE_RD_READ: begin
        rd_state <= STATE_RD_GET_DATA;
    end

    STATE_RD_GET_DATA: begin
      if (S_AXI_RVALID && S_AXI_RREADY)
        rd_state <= STATE_RD_GET_ADDR;
    end

    default: rd_state <= STATE_RD_GET_ADDR;

    endcase
  end

  assign get_stb       = (rd_state == STATE_RD_GET_DATA);

  assign S_AXI_RDATA   = get_data;

  assign S_AXI_ARREADY = (rd_state == STATE_RD_GET_ADDR);
  assign S_AXI_RVALID  = (rd_state == STATE_RD_GET_DATA);
  assign S_AXI_RRESP   = 0;

  //------------------------------------------------------------------
  // write state machine
  //------------------------------------------------------------------
  localparam STATE_WR_GET_ADDR = 0;
  localparam STATE_WR_GET_DATA = 1;
  localparam STATE_WR_WRITE    = 2;

  reg [1:0] wr_state;

  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      wr_state   <= STATE_WR_GET_ADDR;
      set_addr <= 0;
      set_data <= 0;
    end
    else case (wr_state)

    STATE_WR_GET_ADDR: begin
      if (S_AXI_AWVALID && S_AXI_AWREADY) begin
        set_addr  <= (S_AXI_AWADDR - C_BASEADDR);
        wr_state  <= STATE_WR_GET_DATA;
      end
    end

    STATE_WR_GET_DATA: begin
      if (S_AXI_WVALID && S_AXI_WREADY) begin
        set_data <= S_AXI_WDATA;
        wr_state <= STATE_WR_WRITE;
      end
    end

    STATE_WR_WRITE: begin
      wr_state <= STATE_WR_GET_ADDR;
    end

    default: wr_state <= STATE_WR_GET_ADDR;

    endcase
  end

  assign set_stb = (wr_state == STATE_WR_WRITE);

  assign S_AXI_AWREADY = (wr_state == STATE_WR_GET_ADDR);
  assign S_AXI_WREADY  = (wr_state == STATE_WR_GET_DATA);
  assign S_AXI_BRESP   = 0;
  assign S_AXI_BVALID  = S_AXI_BREADY;

endmodule
