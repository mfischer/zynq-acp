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

module axi_demux #
(
  C_AXIS_DATA_WIDTH = 64,
  C_ACTIVE_MASK = 4'b0011
)
(
  input                          clk,
  input                          rst,

  /* AXI4 stream Inputs */
  input [C_AXIS_DATA_WIDTH-1:0]  S_AXIS_TDATA,
  input                          S_AXIS_TVALID,
  input                          S_AXIS_TLAST,
  output                         S_AXIS_TREADY,

  /* AXI4 stream output 0*/
  output                         M_AXIS_TDATA0,
  output [C_AXIS_DATA_WIDTH-1:0] M_AXIS_TVALID0,
  input                          M_AXIS_TREADY0,
  output                         M_AXIS_TLAST0,

  /* AXI4 stream output 1*/
  output                         M_AXIS_TDATA1,
  output [C_AXIS_DATA_WIDTH-1:0] M_AXIS_TVALID1,
  input                          M_AXIS_TREADY1,
  output                         M_AXIS_TLAST1,

  /* AXI4 stream output 2*/
  output                         M_AXIS_TDATA2,
  output [C_AXIS_DATA_WIDTH-1:0] M_AXIS_TVALID2,
  input                          M_AXIS_TREADY2,
  output                         M_AXIS_TLAST2,

  /* AXI4 stream output 3*/
  output                         M_AXIS_TDATA3,
  output [C_AXIS_DATA_WIDTH-1:0] M_AXIS_TVALID3,
  input                          M_AXIS_TREADY3,
  output                         M_AXIS_TLAST3,

  input [1:0]                    dest
);

  reg [3:0] state;
  localparam IDLE = 4'b0000;
  localparam ST0  = 4'b0001;
  localparam ST1  = 4'b0010;
  localparam ST2  = 4'b0100;
  localparam ST3  = 4'b1000;

  always @ (posedge clk) begin
    if (rst)
      state <= IDLE;
    else
    case(state)
      IDLE:
        case (dest)
        2'b00: state <= ST0;

        2'b01: state <= ST1;

        2'b10: state <= ST2;

        2'b11: state <= ST3;
        endcase

      ST0, ST1, ST2, ST3:
        if(S_AXIS_TVALID & S_AXIS_TREADY & S_AXIS_TLAST)
          state <= IDLE;

      default:
        state <= IDLE;
    endcase
  end


 assign {M_AXIS_TVALID3, M_AXIS_TVALID2, M_AXIS_TVALID1, M_AXIS_TVALID0} = state & {4{S_AXIS_TVALID}};
 assign S_AXIS_TREADY = |(state & ({M_AXIS_TREADY3, M_AXIS_TREADY2, M_AXIS_TREADY1, M_AXIS_TREADY0} | ~C_ACTIVE_MASK));

 assign {M_AXIS_TLAST0, M_AXIS_TDATA0} = {S_AXIS_TLAST, S_AXIS_TDATA};
 assign {M_AXIS_TLAST1, M_AXIS_TDATA1} = {S_AXIS_TLAST, S_AXIS_TDATA};
 assign {M_AXIS_TLAST2, M_AXIS_TDATA2} = {S_AXIS_TLAST, S_AXIS_TDATA};
 assign {M_AXIS_TLAST3, M_AXIS_TDATA3} = {S_AXIS_TLAST, S_AXIS_TDATA};
endmodule
