Version 4
SymbolType BLOCK
TEXT 32 32 LEFT 4 xlnx_axi_datamover
RECTANGLE Normal 32 32 736 1600
LINE Normal 0 80 32 80
PIN 0 80 LEFT 36
PINATTR PinName mm2s_halt
PINATTR Polarity IN
LINE Normal 768 80 736 80
PIN 768 80 RIGHT 36
PINATTR PinName mm2s_halt_cmplt
PINATTR Polarity OUT
LINE Normal 768 112 736 112
PIN 768 112 RIGHT 36
PINATTR PinName mm2s_err
PINATTR Polarity OUT
LINE Normal 0 176 32 176
PIN 0 176 LEFT 36
PINATTR PinName s_axis_mm2s_cmd_tvalid
PINATTR Polarity IN
LINE Normal 768 144 736 144
PIN 768 144 RIGHT 36
PINATTR PinName s_axis_mm2s_cmd_tready
PINATTR Polarity OUT
LINE Wide 0 208 32 208
PIN 0 208 LEFT 36
PINATTR PinName s_axis_mm2s_cmd_tdata[71:0]
PINATTR Polarity IN
LINE Normal 768 176 736 176
PIN 768 176 RIGHT 36
PINATTR PinName m_axis_mm2s_sts_tvalid
PINATTR Polarity OUT
LINE Normal 0 240 32 240
PIN 0 240 LEFT 36
PINATTR PinName m_axis_mm2s_sts_tready
PINATTR Polarity IN
LINE Wide 768 208 736 208
PIN 768 208 RIGHT 36
PINATTR PinName m_axis_mm2s_sts_tdata[7:0]
PINATTR Polarity OUT
LINE Normal 768 240 736 240
PIN 768 240 RIGHT 36
PINATTR PinName m_axis_mm2s_sts_tkeep
PINATTR Polarity OUT
LINE Normal 768 272 736 272
PIN 768 272 RIGHT 36
PINATTR PinName m_axis_mm2s_sts_tlast
PINATTR Polarity OUT
LINE Normal 0 272 32 272
PIN 0 272 LEFT 36
PINATTR PinName mm2s_allow_addr_req
PINATTR Polarity IN
LINE Wide 768 304 736 304
PIN 768 304 RIGHT 36
PINATTR PinName mm2s_addr_req_posted[7:0]
PINATTR Polarity OUT
LINE Normal 768 336 736 336
PIN 768 336 RIGHT 36
PINATTR PinName mm2s_rd_xfer_cmplt
PINATTR Polarity OUT
LINE Normal 0 304 32 304
PIN 0 304 LEFT 36
PINATTR PinName m_axi_mm2s_aclk
PINATTR Polarity IN
LINE Normal 0 336 32 336
PIN 0 336 LEFT 36
PINATTR PinName m_axi_mm2s_aresetn
PINATTR Polarity IN
LINE Wide 768 368 736 368
PIN 768 368 RIGHT 36
PINATTR PinName m_axi_mm2s_araddr[31:0]
PINATTR Polarity OUT
LINE Wide 768 400 736 400
PIN 768 400 RIGHT 36
PINATTR PinName m_axi_mm2s_arlen[7:0]
PINATTR Polarity OUT
LINE Wide 768 432 736 432
PIN 768 432 RIGHT 36
PINATTR PinName m_axi_mm2s_arsize[2:0]
PINATTR Polarity OUT
LINE Wide 768 464 736 464
PIN 768 464 RIGHT 36
PINATTR PinName m_axi_mm2s_arburst[1:0]
PINATTR Polarity OUT
LINE Wide 768 496 736 496
PIN 768 496 RIGHT 36
PINATTR PinName m_axi_mm2s_arprot[2:0]
PINATTR Polarity OUT
LINE Wide 768 528 736 528
PIN 768 528 RIGHT 36
PINATTR PinName m_axi_mm2s_arcache[3:0]
PINATTR Polarity OUT
LINE Normal 768 560 736 560
PIN 768 560 RIGHT 36
PINATTR PinName m_axi_mm2s_arvalid
PINATTR Polarity OUT
LINE Normal 0 368 32 368
PIN 0 368 LEFT 36
PINATTR PinName m_axi_mm2s_arready
PINATTR Polarity IN
LINE Wide 0 400 32 400
PIN 0 400 LEFT 36
PINATTR PinName m_axi_mm2s_rdata[63:0]
PINATTR Polarity IN
LINE Wide 0 432 32 432
PIN 0 432 LEFT 36
PINATTR PinName m_axi_mm2s_rresp[1:0]
PINATTR Polarity IN
LINE Normal 0 464 32 464
PIN 0 464 LEFT 36
PINATTR PinName m_axi_mm2s_rlast
PINATTR Polarity IN
LINE Normal 0 496 32 496
PIN 0 496 LEFT 36
PINATTR PinName m_axi_mm2s_rvalid
PINATTR Polarity IN
LINE Normal 768 592 736 592
PIN 768 592 RIGHT 36
PINATTR PinName m_axi_mm2s_rready
PINATTR Polarity OUT
LINE Wide 768 624 736 624
PIN 768 624 RIGHT 36
PINATTR PinName m_axi_mm2s_arid[3:0]
PINATTR Polarity OUT
LINE Wide 768 656 736 656
PIN 768 656 RIGHT 36
PINATTR PinName m_axis_mm2s_tdata[63:0]
PINATTR Polarity OUT
LINE Wide 768 688 736 688
PIN 768 688 RIGHT 36
PINATTR PinName m_axis_mm2s_tkeep[7:0]
PINATTR Polarity OUT
LINE Normal 768 720 736 720
PIN 768 720 RIGHT 36
PINATTR PinName m_axis_mm2s_tlast
PINATTR Polarity OUT
LINE Normal 768 752 736 752
PIN 768 752 RIGHT 36
PINATTR PinName m_axis_mm2s_tvalid
PINATTR Polarity OUT
LINE Normal 0 528 32 528
PIN 0 528 LEFT 36
PINATTR PinName m_axis_mm2s_tready
PINATTR Polarity IN
LINE Normal 0 560 32 560
PIN 0 560 LEFT 36
PINATTR PinName s2mm_halt
PINATTR Polarity IN
LINE Normal 768 784 736 784
PIN 768 784 RIGHT 36
PINATTR PinName s2mm_halt_cmplt
PINATTR Polarity OUT
LINE Normal 768 816 736 816
PIN 768 816 RIGHT 36
PINATTR PinName s2mm_err
PINATTR Polarity OUT
LINE Normal 0 656 32 656
PIN 0 656 LEFT 36
PINATTR PinName s_axis_s2mm_cmd_tvalid
PINATTR Polarity IN
LINE Normal 768 848 736 848
PIN 768 848 RIGHT 36
PINATTR PinName s_axis_s2mm_cmd_tready
PINATTR Polarity OUT
LINE Wide 0 688 32 688
PIN 0 688 LEFT 36
PINATTR PinName s_axis_s2mm_cmd_tdata[71:0]
PINATTR Polarity IN
LINE Normal 768 880 736 880
PIN 768 880 RIGHT 36
PINATTR PinName m_axis_s2mm_sts_tvalid
PINATTR Polarity OUT
LINE Normal 0 720 32 720
PIN 0 720 LEFT 36
PINATTR PinName m_axis_s2mm_sts_tready
PINATTR Polarity IN
LINE Wide 768 912 736 912
PIN 768 912 RIGHT 36
PINATTR PinName m_axis_s2mm_sts_tdata[7:0]
PINATTR Polarity OUT
LINE Wide 768 944 736 944
PIN 768 944 RIGHT 36
PINATTR PinName m_axis_s2mm_sts_tkeep[0:0]
PINATTR Polarity OUT
LINE Normal 768 976 736 976
PIN 768 976 RIGHT 36
PINATTR PinName m_axis_s2mm_sts_tlast
PINATTR Polarity OUT
LINE Normal 0 752 32 752
PIN 0 752 LEFT 36
PINATTR PinName s2mm_allow_addr_req
PINATTR Polarity IN
LINE Normal 768 1008 736 1008
PIN 768 1008 RIGHT 36
PINATTR PinName s2mm_addr_req_posted
PINATTR Polarity OUT
LINE Normal 768 1040 736 1040
PIN 768 1040 RIGHT 36
PINATTR PinName s2mm_wr_xfer_cmplt
PINATTR Polarity OUT
LINE Normal 768 1072 736 1072
PIN 768 1072 RIGHT 36
PINATTR PinName s2mm_ld_nxt_len
PINATTR Polarity OUT
LINE Wide 768 1104 736 1104
PIN 768 1104 RIGHT 36
PINATTR PinName s2mm_wr_len[7:0]
PINATTR Polarity OUT
LINE Normal 0 784 32 784
PIN 0 784 LEFT 36
PINATTR PinName m_axi_s2mm_aclk
PINATTR Polarity IN
LINE Normal 0 816 32 816
PIN 0 816 LEFT 36
PINATTR PinName m_axi_s2mm_aresetn
PINATTR Polarity IN
LINE Wide 768 1136 736 1136
PIN 768 1136 RIGHT 36
PINATTR PinName m_axi_s2mm_awaddr[31:0]
PINATTR Polarity OUT
LINE Wide 768 1168 736 1168
PIN 768 1168 RIGHT 36
PINATTR PinName m_axi_s2mm_awlen[7:0]
PINATTR Polarity OUT
LINE Wide 768 1200 736 1200
PIN 768 1200 RIGHT 36
PINATTR PinName m_axi_s2mm_awsize[2:0]
PINATTR Polarity OUT
LINE Wide 768 1232 736 1232
PIN 768 1232 RIGHT 36
PINATTR PinName m_axi_s2mm_awburst[1:0]
PINATTR Polarity OUT
LINE Wide 768 1264 736 1264
PIN 768 1264 RIGHT 36
PINATTR PinName m_axi_s2mm_awprot[2:0]
PINATTR Polarity OUT
LINE Wide 768 1296 736 1296
PIN 768 1296 RIGHT 36
PINATTR PinName m_axi_s2mm_awcache[3:0]
PINATTR Polarity OUT
LINE Normal 768 1328 736 1328
PIN 768 1328 RIGHT 36
PINATTR PinName m_axi_s2mm_awvalid
PINATTR Polarity OUT
LINE Normal 0 848 32 848
PIN 0 848 LEFT 36
PINATTR PinName m_axi_s2mm_awready
PINATTR Polarity IN
LINE Wide 768 1360 736 1360
PIN 768 1360 RIGHT 36
PINATTR PinName m_axi_s2mm_wdata[63:0]
PINATTR Polarity OUT
LINE Wide 768 1392 736 1392
PIN 768 1392 RIGHT 36
PINATTR PinName m_axi_s2mm_wstrb[3:0]
PINATTR Polarity OUT
LINE Normal 768 1424 736 1424
PIN 768 1424 RIGHT 36
PINATTR PinName m_axi_s2mm_wlast
PINATTR Polarity OUT
LINE Normal 768 1456 736 1456
PIN 768 1456 RIGHT 36
PINATTR PinName m_axi_s2mm_wvalid
PINATTR Polarity OUT
LINE Normal 0 880 32 880
PIN 0 880 LEFT 36
PINATTR PinName m_axi_s2mm_wready
PINATTR Polarity IN
LINE Wide 0 912 32 912
PIN 0 912 LEFT 36
PINATTR PinName m_axi_s2mm_bresp[1:0]
PINATTR Polarity IN
LINE Normal 0 944 32 944
PIN 0 944 LEFT 36
PINATTR PinName m_axi_s2mm_bvalid
PINATTR Polarity IN
LINE Normal 768 1488 736 1488
PIN 768 1488 RIGHT 36
PINATTR PinName m_axi_s2mm_bready
PINATTR Polarity OUT
LINE Wide 768 1520 736 1520
PIN 768 1520 RIGHT 36
PINATTR PinName m_axi_s2mm_awid[3:0]
PINATTR Polarity OUT
LINE Wide 0 976 32 976
PIN 0 976 LEFT 36
PINATTR PinName s_axis_s2mm_tdata[63:0]
PINATTR Polarity IN
LINE Wide 0 1008 32 1008
PIN 0 1008 LEFT 36
PINATTR PinName s_axis_s2mm_tkeep[7:0]
PINATTR Polarity IN
LINE Normal 0 1040 32 1040
PIN 0 1040 LEFT 36
PINATTR PinName s_axis_s2mm_tlast
PINATTR Polarity IN
LINE Normal 0 1072 32 1072
PIN 0 1072 LEFT 36
PINATTR PinName s_axis_s2mm_tvalid
PINATTR Polarity IN
LINE Normal 768 1552 736 1552
PIN 768 1552 RIGHT 36
PINATTR PinName s_axis_s2mm_tready
PINATTR Polarity OUT

