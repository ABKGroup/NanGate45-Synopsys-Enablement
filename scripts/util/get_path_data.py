import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from sklearn.metrics import r2_score
import seaborn as sns
import argparse


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--DESIGN", type=str, default="ldpc_decoder_mod")
    parser.add_argument("--PEX1", type=str, default="INVS")
    parser.add_argument("--STA1", type=str, default="INVS")
    parser.add_argument("--PEX2", type=str, default="FC")
    parser.add_argument("--STA2", type=str, default="FC")
    parser.add_argument("--CC1", type=str, default="true")
    parser.add_argument("--CC2", type=str, default="true")
    parser.add_argument("--SI1", type=str, default="true")
    parser.add_argument("--SI2", type=str, default="true")

    args = parser.parse_args()
   
    DESIGN = args.DESIGN
    PEX1 = args.PEX1
    STA1 = args.STA1
    CC1 = args.CC1
    SI1 = args.SI1
    PEX2 = args.PEX2
    STA2 = args.STA2
    CC2 = args.CC2
    SI2 = args.SI2
 
    TARGET = "timing_details"

    HOME_DIR = "../.."
    DESIGN_DIR = f"{HOME_DIR}/benchmark/{DESIGN}"

    CSV1_FILE = f"{DESIGN_DIR}/{TARGET}/{PEX1}-{STA1}/CC_{CC1}_SI_{SI1}/{TARGET}.csv"
    CSV2_FILE = f"{DESIGN_DIR}/{TARGET}/{PEX2}-{STA2}/CC_{CC2}_SI_{SI2}/{TARGET}.csv"

    SUMMARY_DIR = f"{DESIGN_DIR}/summary"
    SUMMARY_FILE = f"{SUMMARY_DIR}/matched_timing_path.csv"

    DONE_DIR = f"{DESIGN_DIR}/done"

    os.makedirs(SUMMARY_DIR, exist_ok=True)
    os.makedirs(DONE_DIR, exist_ok=True)

    df1 = pd.read_csv(CSV1_FILE)
    df2 = pd.read_csv(CSV2_FILE)

    df1 = df1.drop_duplicates()
    df2 = df2.drop_duplicates()

    df1["points"] = df1["points"].str.replace("{", "").str.replace("}", "")
    df2["points"] = df2["points"].str.replace("{", "").str.replace("}", "")

    df1['endpoint'] = df1['points'].apply(lambda x: x.split()[-1])
    df2['endpoint'] = df2['points'].apply(lambda x: x.split()[-1])

    case1 = pd.merge(df1, df2, on=['points', 'tran_type'], how='inner')

    case2 = pd.merge(df1, df2, on=['points'], how='inner')
    case2 = case2[case2['tran_type_x'] != case2['tran_type_y']]

    num_path1 = len(df1)
    num_path2 = len(df2)
    
    assert num_path1 == num_path2, \
    f"Error: The number of timing paths extracted from the two tools is different. \
    Please verify the timing path extraction options and SDC files for each STA tool. {num_path1} != {num_path2}"

    num_path_case1 = len(case1)
    num_path_case2 = len(case2)
    sum_num_path_case = num_path_case1 + num_path_case2

    ratio1 = f"{num_path_case1/num_path1 * 100:.2f}"
    ratio2 = f"{num_path_case2/num_path1 * 100:.2f}"
    ratio3 = f"{sum_num_path_case/num_path1 * 100:.2f}"


    csv_header = "DESIGN,PEX1,STA1,CC1,SI1,PEX2,STA2,CC2,SI2,# of total timing paths,# of timing paths (case1),# of timing paths (case2),# of timing paths (case1+case2)\n"

    summary = f"{DESIGN},{PEX1},{STA1},{CC1},{SI1},{PEX2},{STA2},{CC2},{SI2},{num_path1},{num_path_case1}({ratio1} %),{num_path_case2}({ratio2} %),{sum_num_path_case}({ratio3} %)\n"

    if not os.path.exists(SUMMARY_FILE):
        with open(SUMMARY_FILE, "w") as f:
            f.writelines(csv_header)

    with open(SUMMARY_FILE, "a") as f:
        f.writelines(summary)

    open(f"{DONE_DIR}/path_{DESIGN}_{PEX1}_{STA1}_{CC1}_{SI1}_{PEX2}_{STA2}_{CC2}_{SI2}", "w").close()
    #open(f"{DONE_DIR}/path_{DESIGN}_{PEX2}_{STA2}_{CC2}_{SI2}_{PEX1}_{STA1}_{CC1}_{SI1}", "w").close()
