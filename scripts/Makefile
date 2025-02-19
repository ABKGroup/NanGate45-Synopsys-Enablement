ifndef DESIGN
  $(error DESIGN is not defined)
endif

ifndef PEX_TOOL
  $(error PEX_TOOL is not defined)
endif

ifndef STA_TOOL
  $(error STA_TOOL is not defined)
endif

ifndef CC
  $(error CC is not defined)
endif

ifndef SI
  $(error SI is not defined)
endif

NWORST ?= 1


COMBO := $(PEX_TOOL)$(STA_TOOL)
ifneq ($(filter $(COMBO),fusion_compilerinnovus innovusfusion_compiler),)
  $(error "Error: The combination of PEX_TOOL=$(PEX_TOOL) and STA_TOOL=$(STA_TOOL) is not supported.")
endif


SCRIPT_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
DESIGN_DIR = $(SCRIPT_DIR)/../benchmark

PEX_COMPANY = $(shell if [ "$(PEX_TOOL)" = "innovus" ]; then echo "cadence"; \
  elif [ "$(PEX_TOOL)" = "quantus" ]; then echo "cadence"; \
  elif [ "$(PEX_TOOL)" = "fusion_compiler" ]; then echo "synopsys"; \
  elif [ "$(PEX_TOOL)" = "starRC" ]; then echo "synopsys"; \
  else echo "Error: Invalid PEX_TOOL value: $(PEX_TOOL)" >&2; exit 1; fi)

PEX = $(shell if [ "$(PEX_TOOL)" = "innovus" ]; then echo "INVS"; \
  elif [ "$(PEX_TOOL)" = "quantus" ]; then echo "QTS"; \
  elif [ "$(PEX_TOOL)" = "fusion_compiler" ]; then echo "FC"; \
  elif [ "$(PEX_TOOL)" = "starRC" ]; then echo "STRC"; \
  else echo "Error: Invalid PEX_TOOL value: $(PEX_TOOL)" >&2; exit 1; fi)

STA_COMPANY = $(shell if [ "$(STA_TOOL)" = "innovus" ]; then echo "cadence"; \
  elif [ "$(STA_TOOL)" = "tempus" ]; then echo "cadence"; \
  elif [ "$(STA_TOOL)" = "fusion_compiler" ]; then echo "synopsys"; \
  elif [ "$(STA_TOOL)" = "primetime" ]; then echo "synopsys"; \
  else echo "Error: Invalid STA_TOOL value: $(STA_TOOL)" >&2; exit 1; fi)

STA = $(shell if [ "$(STA_TOOL)" = "innovus" ]; then echo "INVS"; \
  elif [ "$(STA_TOOL)" = "tempus" ]; then echo "TPS"; \
  elif [ "$(STA_TOOL)" = "fusion_compiler" ]; then echo "FC"; \
  elif [ "$(STA_TOOL)" = "primetime" ]; then echo "PT"; \
  else echo "Error: Invalid STA_TOOL value: $(STA_TOOL)" >&2; exit 1; fi)



SPEF_FILE = $(DESIGN_DIR)/$(DESIGN)/$(DESIGN)_$(PEX)_CC_$(CC).spef
NET_CAP_CSV = $(DESIGN_DIR)/$(DESIGN)/net_capacitance/$(PEX)/CC_$(CC)/net_parasitics.csv
TIMING_CSV = $(DESIGN_DIR)/$(DESIGN)/timing_details/$(PEX)-$(STA)/CC_$(CC)_SI_$(SI)/timing_details.csv

.PHONY: all pex sta

all: pex sta

pex: $(SPEF_FILE)

sta: $(NET_CAP_CSV) $(TIMING_CSV)

$(SPEF_FILE):
	@cd $(SCRIPT_DIR)/$(PEX_COMPANY)/$(PEX_TOOL) && ./run.sh $(DESIGN) $(NWORST) $(CC) $(SI) $(PEX)

$(NET_CAP_CSV) $(TIMING_CSV):
	@cd $(SCRIPT_DIR)/$(STA_COMPANY)/$(STA_TOOL) && ./run.sh $(DESIGN) $(NWORST) $(CC) $(SI) $(PEX)
