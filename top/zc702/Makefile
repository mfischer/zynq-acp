#
# Copyright 2008-2013 Ettus Research LLC
#

##################################################
# Project Setup
##################################################
TOP_MODULE = zc702
BUILD_DIR = $(abspath build$(ISE))

# set me in a custom makefile
CUSTOM_SRCS =
CUSTOM_DEFS =

##################################################
# Include other makefiles
##################################################

include ../Makefile.common

include ../../lib/accelerator/Makefile.srcs
include ../../lib/control/Makefile.srcs
include zynq-ps/Makefile.srcs

promgen: $(BIT_FILE)
	promgen -w -p bin -c FF -o $(BIN_FILE) -b -s 4096 -u 00000000 $< -bpi_dc parallel -data_width 32

##################################################
# Project Properties
##################################################
export PROJECT_PROPERTIES := \
family "Zynq" \
device XC7Z020 \
package CLG484 \
speed -1 \
top_level_module_type "HDL" \
synthesis_tool "XST (VHDL/Verilog)" \
simulator "ISim (VHDL/Verilog)" \
"Preferred Language" "Verilog" \
"Enable Message Filtering" FALSE \
"Display Incremental Messages" FALSE

##################################################
# Sources
##################################################
TOP_SRCS = \
	zc702.v \
	coregen/xlnx_axi_datamover_synth.v \
	coregen/xlnx_axi_datamover.xco \
	coregen/chipscope_icon.v \
	coregen/chipscope_icon.xco \
	coregen/chipscope_ila_large.v \
	coregen/chipscope_ila_large.xco


SOURCES = \
	$(abspath $(TOP_SRCS)) \
	$(ZYNQ_PS_SRCS) \
	$(CONTROL_LIB_SRCS) \
	$(ACCELERATOR_SRCS)


##################################################
# Process Properties
##################################################
SYNTHESIZE_PROPERTIES = \
"Number of Clock Buffers" 8 \
"Pack I/O Registers into IOBs" Yes \
"Optimization Effort" High \
"Optimize Instantiated Primitives" TRUE \
"Register Balancing" Yes \
"Use Clock Enable" Auto \
"Use Synchronous Reset" Auto \
"Use Synchronous Set" Auto

TRANSLATE_PROPERTIES = \
"Macro Search Path" "$(shell pwd)/../../coregen/"

MAP_PROPERTIES = \
"Generate Detailed MAP Report" TRUE \
"Allow Logic Optimization Across Hierarchy" TRUE \
"Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" \
"Combinatorial Logic Optimization" TRUE \
"Register Duplication" ON

PLACE_ROUTE_PROPERTIES = \
"Place & Route Effort Level (Overall)" High

STATIC_TIMING_PROPERTIES = \
"Number of Paths in Error/Verbose Report" 10 \
"Report Type" "Error Report"

GEN_PROG_FILE_PROPERTIES = \
"Create Binary Configuration File" TRUE \
"Done (Output Events)" 5 \
"Enable Bitstream Compression" TRUE \
"Enable Outputs (Output Events)" 6

SIM_MODEL_PROPERTIES = ""
