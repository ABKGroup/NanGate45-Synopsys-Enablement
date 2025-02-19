ifndef DESIGN
  $(error DESIGN is not defined)
endif

ifndef PEX_TOOL1
  $(error PEX_TOOL1 is not defined)
endif

ifndef STA_TOOL1
  $(error STA_TOOL1 is not defined)
endif

ifndef CC1
  $(error CC1 is not defined)
endif

ifndef SI1
  $(error SI1 is not defined)
endif

ifndef PEX_TOOL2
  $(error PEX_TOOL2 is not defined)
endif

ifndef STA_TOOL2
  $(error STA_TOOL2 is not defined)
endif

ifndef CC2
  $(error CC2 is not defined)
endif

ifndef SI2
  $(error SI2 is not defined)
endif

CASE ?= 1
NWORST ?= 1

HOME_DIR = $(dir $(lastword $(MAKEFILE_LIST)))
DESIGN_DIR = $(HOME_DIR)/benchmark
UTIL_DIR = $(HOME_DIR)/scripts/util
DONE_DIR = $(DESIGN_DIR)/$(DESIGN)/done


define get_pex_abbr
$(shell arg=$$(echo "$1" | sed 's/^ *//; s/ *$$//'); \
       if [ "$$arg" = "innovus" ]; then echo "INVS"; \
       elif [ "$$arg" = "quantus" ]; then echo "QTS"; \
       elif [ "$$arg" = "fusion_compiler" ]; then echo "FC"; \
       elif [ "$$arg" = "starRC" ]; then echo "STRC"; \
       else echo "Error: Invalid PEX_TOOL value: $$arg" >&2; exit 1; fi)
endef

define get_sta_abbr
$(shell arg=$$(echo "$1" | sed 's/^ *//; s/ *$$//'); \
       if [ "$$arg" = "innovus" ]; then echo "INVS"; \
       elif [ "$$arg" = "tempus" ]; then echo "TPS"; \
       elif [ "$$arg" = "fusion_compiler" ]; then echo "FC"; \
       elif [ "$$arg" = "primetime" ]; then echo "PT"; \
       else echo "Error: Invalid STA_TOOL value: $$arg" >&2; exit 1; fi)
endef


PEX1 := $(call get_pex_abbr, $(PEX_TOOL1))
STA1 := $(call get_sta_abbr, $(STA_TOOL1))

PEX2 := $(call get_pex_abbr, $(PEX_TOOL2))
STA2 := $(call get_sta_abbr, $(STA_TOOL2))


CAP_DONE_FILE = $(DONE_DIR)/cap_$(DESIGN)_$(PEX1)_$(CC1)_$(PEX2)_$(CC2)
PATH_DONE_FILE = $(DONE_DIR)/path_$(DESIGN)_$(PEX1)_$(STA1)_$(CC1)_$(SI1)_$(PEX2)_$(STA2)_$(CC2)_$(SI2)
TIMING_DONE_FILE = $(DONE_DIR)/timing_$(DESIGN)_$(PEX1)_$(STA1)_$(CC1)_$(SI1)_$(PEX2)_$(STA2)_$(CC2)_$(SI2)_$(CASE)

.PHONY: all gen cap path timing

all: gen cap path timing

gen: 
	$(MAKE) -C scripts DESIGN=$(DESIGN) PEX_TOOL=$(PEX_TOOL1) STA_TOOL=$(STA_TOOL1) CC=$(CC1) SI=$(SI1)
	$(MAKE) -C scripts DESIGN=$(DESIGN) PEX_TOOL=$(PEX_TOOL2) STA_TOOL=$(STA_TOOL2) CC=$(CC2) SI=$(SI2)
	@echo "Successfully generated design data."

cap: $(CAP_DONE_FILE)
	@echo "Successfully generated net capacitance plot and summary."

path: $(PATH_DONE_FILE)
	@echo "Successfully generated matching path data summary."

timing: $(TIMING_DONE_FILE)
	@echo "Successfully generated matching timing details plot and summary."

$(CAP_DONE_FILE):
	@cd $(UTIL_DIR) && python3 get_cap_data.py --DESIGN=$(DESIGN) --PEX1=$(PEX1) --PEX2=$(PEX2) --CC1=$(CC1) --CC2=$(CC2)

$(PATH_DONE_FILE):
	@cd $(UTIL_DIR) && python3 get_path_data.py --DESIGN=$(DESIGN) --PEX1=$(PEX1) --STA1=$(STA1) --CC1=$(CC1) --SI1=$(SI1) --PEX2=$(PEX2) --STA2=$(STA2) --CC2=$(CC2) --SI2=$(SI2) 

$(TIMING_DONE_FILE):
	@cd $(UTIL_DIR) && python3 get_timing_data.py --DESIGN=$(DESIGN) --PEX1=$(PEX1) --STA1=$(STA1) --CC1=$(CC1) --SI1=$(SI1) --PEX2=$(PEX2) --STA2=$(STA2) --CC2=$(CC2) --SI2=$(SI2) --CASE=$(CASE)

