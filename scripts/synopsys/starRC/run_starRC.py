import os

DESIGN = os.environ["DESIGN"]
CC = os.environ["CC"]

HOME_DIR = "../../.."
PDK_DIR = f"{HOME_DIR}/NanGate45"
DESIGN_DIR = f"{HOME_DIR}/benchmark/{DESIGN}"

CC_FLAG = "YES" if CC == "false" else "NO" ;# From Synopsys Reference

### For replacement ###
DEF_FILE = f"{DESIGN_DIR}/{DESIGN}.def"
NXTGRD_FILE = f"{PDK_DIR}/tlup/NangateOpenCellLibrary.nxtgrd"
LAYERMAP = f"{PDK_DIR}/tlup/NangateOpenCellLibrary.layermap"
SPEF_FILE = f"{DESIGN_DIR}/{DESIGN}_STRC_CC_{CC}.spef"
RUN_DIR = f"{DESIGN}/CC_{CC}"

os.makedirs(RUN_DIR, exist_ok=True)

with open("ref_cmd", "r") as f:
    read_lines = f.readlines()

replacements = {
    "__DESIGN__": DESIGN,
    "__DEF_FILE__": DEF_FILE,
    "__LAYERMAP__": LAYERMAP,
    "__NXTGRD_FILE__": NXTGRD_FILE,
    "__SPEF_FILE__": SPEF_FILE,
    "__CC__": CC_FLAG, 
    "__RUN_DIR__": RUN_DIR
}

write_lines = []
for line in read_lines:
    for key, value in replacements.items():
        line = line.replace(key, value)
    write_lines.append(line)

with open("run_starRC", "w") as f:
    f.writelines(write_lines)

os.system("StarXtract -clean run_starRC")
os.system("rm run_starRC")
os.system(f"rm {DESIGN}.star_sum")
os.system(f"rm -r {RUN_DIR}")
