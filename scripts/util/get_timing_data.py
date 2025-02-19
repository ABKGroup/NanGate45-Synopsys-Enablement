import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from sklearn.metrics import r2_score
import seaborn as sns
import argparse

def get_init_delay_type(points):
    elements = points.split()  
    if len(elements) < 2:
        raise "It is not valid path." 
   
    slash_count_0 = elements[0].count("/")
    slash_count_1 = elements[1].count("/")

    if slash_count_0 != slash_count_1:
        return "wire_delay"

    first_inst = elements[0].split("/")[0]  
    second_inst = elements[1].split("/")[0]  
    
    if first_inst == second_inst:
        return "cell_delay"  

    else:
        return "wire_delay"  

def split_delays_and_slews(row):
    delay_list = list(map(float, row["delays"].split()))
    slew_list = list(map(float, row["slews"].split()))

    wire_delays = [delay_list[0]]
    wire_slews = [slew_list[0]]

    if row["init_delay_type"] == "cell_delay":
        cell_delays = delay_list[1::2]  
        wire_delays += delay_list[2::2]  

        cell_slews = slew_list[1::2]  
        wire_slews += slew_list[2::2]  
    else:
        wire_delays += delay_list[1::2]  
        cell_delays = delay_list[2::2]  

        wire_slews += slew_list[1::2]  
        cell_slews = slew_list[2::2]  

    return pd.Series({
        "cell_delays": cell_delays,
        "wire_delays": wire_delays,
        "cell_slews": cell_slews,
        "wire_slews": wire_slews
    })


def plot(data1, data2, x_axis, y_axis, title, plot_dir):
    file_name = "%s/%s.png" %(plot_dir, title)

    plt.figure(figsize=(8, 6))
    plt.scatter(data1, data2, alpha=0.1)

    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title(title)

    plt.grid(True)

    min_val = min(data1.min(), data2.min())
    max_val = max(data1.max(), data2.max())
    plt.plot([min_val, max_val], [min_val, max_val], color='red', linestyle='dashed', linewidth=1)

    r2 = r2_score(data1, data2)

    text_x = min_val + (max_val - min_val) * 0.05
    text_y = max_val - (max_val - min_val) * 0.1  
    plt.text(text_x, text_y, f"R2: {r2:.4f}", fontsize=12, color='black', bbox=dict(facecolor='white', alpha=0.7))


    plt.savefig(file_name, dpi=300, bbox_inches='tight')
    plt.close()
    
    return r2



def save_ad_dist(data1, data2, x_axis, y_axis, title, plot_dir):
    mask = ~((data1 == 0) & (data2 == 0))
    data1 = data1[mask]
    data2 = data2[mask]

    file_name = "%s/%s.png" %(plot_dir, title)

    ad = np.abs(data1 - data2)

    mean_ad = np.mean(ad)
    max_ad = np.max(ad)

    plt.figure(figsize=(10, 6))
    plt.hist(ad, bins=1000, edgecolor='none')

    plt.axvline(mean_ad, color='blue', linestyle='--', label=f'Mean: {mean_ad:.4f}')
    plt.axvline(max_ad, color='red', linestyle='--', label=f'Max: {max_ad:.4f}')

    plt.legend(loc='best')

    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title(title)
    plt.grid(True)

    plt.savefig(file_name, dpi=300, bbox_inches='tight')
    plt.close()

    return mean_ad, max_ad


   
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
    parser.add_argument("--CASE", type=str, default="1")

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
    CASE = args.CASE

    TARGET = "timing_details"

    HOME_DIR = "../.."
    DESIGN_DIR = f"{HOME_DIR}/benchmark/{DESIGN}"

    CSV1_FILE = f"{DESIGN_DIR}/{TARGET}/{PEX1}-{STA1}/CC_{CC1}_SI_{SI1}/{TARGET}.csv"
    CSV2_FILE = f"{DESIGN_DIR}/{TARGET}/{PEX2}-{STA2}/CC_{CC2}_SI_{SI2}/{TARGET}.csv"

    PLOT_DIR = f"{DESIGN_DIR}/plot/{TARGET}/{PEX1}-{STA1}_CC_{CC1}_SI_{SI1}_vs_{PEX2}-{STA2}_CC_{CC2}_SI_{SI2}_CASE_{CASE}"
    SUMMARY_DIR = f"{DESIGN_DIR}/summary"
    SUMMARY_FILE = f"{SUMMARY_DIR}/{TARGET}.csv"
    DONE_DIR = f"{DESIGN_DIR}/done"

    os.makedirs(PLOT_DIR, exist_ok=True)
    os.makedirs(SUMMARY_DIR, exist_ok=True)
    os.makedirs(DONE_DIR, exist_ok=True)

    df1 = pd.read_csv(CSV1_FILE)
    df2 = pd.read_csv(CSV2_FILE)

    df1 = df1.drop_duplicates()
    df2 = df2.drop_duplicates()

    df1["arrival"] = df1["arrival"].astype(float)
    df2["arrival"] = df2["arrival"].astype(float)

    df1["required"] = df1["required"].astype(float)
    df2["required"] = df2["required"].astype(float)

    df1["slack"] = df1["slack"].astype(float)
    df2["slack"] = df2["slack"].astype(float)

    df1["points"] = df1["points"].str.replace("{", "").str.replace("}", "")
    df2["points"] = df2["points"].str.replace("{", "").str.replace("}", "")

    df1["init_delay_type"] = df1["points"].apply(get_init_delay_type)
    df2["init_delay_type"] = df2["points"].apply(get_init_delay_type)

    df1[["cell_delays", "wire_delays", "cell_slews", "wire_slews"]] = df1.apply(split_delays_and_slews, axis=1)
    df2[["cell_delays", "wire_delays", "cell_slews", "wire_slews"]] = df2.apply(split_delays_and_slews, axis=1)


    if CASE == "1":
        matched_df = pd.merge(df1, df2, on=['points', 'tran_type'], how='inner')

    elif CASE == "2":
        matched_df = pd.merge(df1, df2, on=['points'], how='inner')
        matched_df = matched_df[matched_df['tran_type_x'] != matched_df['tran_type_y']]

    cell_delays_x = np.concatenate(matched_df["cell_delays_x"].values)
    cell_delays_y = np.concatenate(matched_df["cell_delays_y"].values)

    r2_CD = plot(cell_delays_x, cell_delays_y, f"Cell Delay ({PEX1}-{STA1}) [ns]", f"Cell Delay ({PEX2}-{STA2}) [ns]", "Comp_of_Cell_delay", PLOT_DIR)
    mean_ad_CD, max_ad_CD = save_ad_dist(cell_delays_x, cell_delays_y, "AbsDiff [ns]", "Frequency", "Dist_of_AbsDiff_of_Cell_Delay", PLOT_DIR)

    cell_delays = np.concatenate([cell_delays_x, cell_delays_y])
    
    max_CD = np.max(cell_delays)
    mean_CD = np.mean(cell_delays)
    min_CD = np.min(cell_delays)

    #####################################

    wire_delays_x = np.concatenate(matched_df["wire_delays_x"].values)
    wire_delays_y = np.concatenate(matched_df["wire_delays_y"].values)

    r2_WD = plot(wire_delays_x, wire_delays_y, f"Wire Delay ({PEX1}-{STA1}) [ns]", f"Wire Delay ({PEX2}-{STA2}) [ns]", "Comp_of_Wire_delay", PLOT_DIR)
    mean_ad_WD, max_ad_WD = save_ad_dist(wire_delays_x, wire_delays_y, "AbsDiff [ns]", "Frequency", "Dist_of_AbsDiff_of_Wire_Delay", PLOT_DIR)

    wire_delays = np.concatenate([wire_delays_x, wire_delays_y])
    
    max_WD = np.max(wire_delays)
    mean_WD = np.mean(wire_delays)
    min_WD = np.min(wire_delays)

    #####################################

    cell_slews_x = np.concatenate(matched_df["cell_slews_x"].values)
    cell_slews_y = np.concatenate(matched_df["cell_slews_y"].values)

    r2_CS = plot(cell_slews_x, cell_slews_y, f"Cell Slew ({PEX1}-{STA1}) [ns]", f"Cell Slew ({PEX2}-{STA2}) [ns]", "Comp_of_Cell_slew", PLOT_DIR)
    mean_ad_CS, max_ad_CS = save_ad_dist(cell_slews_x, cell_slews_y, "AbsDiff [ns]", "Frequency", "Dist_of_AbsDiff_of_Cell_Slew", PLOT_DIR)

    cell_slews = np.concatenate([cell_slews_x, cell_slews_y])
    
    max_CS = np.max(cell_slews)
    mean_CS = np.mean(cell_slews)
    min_CS = np.min(cell_slews)

    #####################################

    wire_slews_x = np.concatenate(matched_df["wire_slews_x"].values)
    wire_slews_y = np.concatenate(matched_df["wire_slews_y"].values)

    r2_WS = plot(wire_slews_x, wire_slews_y, f"Wire Slew ({PEX1}-{STA1}) [ns]", f"Wire Slew ({PEX2}-{STA2}) [ns]", "Comp_of_Wire_slew", PLOT_DIR)
    mean_ad_WS, max_ad_WS = save_ad_dist(wire_slews_x, wire_slews_y, "AbsDiff [ns]", "Frequency", "Dist_of_AbsDiff_of_Wire_Slew", PLOT_DIR)

    wire_slews = np.concatenate([wire_slews_x, wire_slews_y])
    
    max_WS = np.max(wire_slews)
    mean_WS = np.mean(wire_slews)
    min_WS = np.min(wire_slews)

    #####################################

    arrival_x = matched_df["arrival_x"].to_numpy()
    arrival_y = matched_df["arrival_y"].to_numpy()

    r2_A = plot(arrival_x, arrival_y, f"Arrival ({PEX1}-{STA1}) [ns]", f"Arrival ({PEX2}-{STA2}) [ns]", "Comp_of_Arrival", PLOT_DIR)
    mean_ad_A, max_ad_A = save_ad_dist(arrival_x, arrival_y, "AbsDiff [ns]", "Frequency", "Dist_of_AbsDiff_of_Arrival", PLOT_DIR)

    arrivals = np.concatenate([arrival_x, arrival_y])
    
    max_A = np.max(arrivals)
    mean_A = np.mean(arrivals)
    min_A = np.min(arrivals)

    #####################################

#    required_x = matched_df["required_x"].to_numpy()
#    required_y = matched_df["required_y"].to_numpy()
#
#    r2_R = plot(required_x, required_y, f"Required Time ({PEX1}-{STA1}) [ns]", f"Required Time ({PEX2}-{STA2}) [ns]", "Comp_of_Required", PLOT_DIR)
#    mean_ad_R, max_ad_R = save_ad_dist(required_x, required_y, "AbsDiff [ns]", "Frequency", "Dist_of_AbsDiff_of_Required", PLOT_DIR)
#
#    requireds = np.concatenate([required_x, required_y])
#    
#    max_R = np.max(requireds)
#    mean_R = np.mean(requireds)
#    min_R = np.min(requireds)

    #####################################

    slack_x = matched_df["slack_x"].to_numpy()
    slack_y = matched_df["slack_y"].to_numpy()

    r2_S = plot(slack_x, slack_y, f"Slack ({PEX1}-{STA1}) [ns]", f"Slack ({PEX2}-{STA2}) [ns]", "Comp_of_Slack", PLOT_DIR)
    mean_ad_S, max_ad_S = save_ad_dist(slack_x, slack_y, "AbsDiff [ns]", "Frequency", "Dist_of_AbsDiff_of_Slack", PLOT_DIR)

    slacks = np.concatenate([slack_x, slack_y])

    max_S = np.max(slacks)
    mean_S = np.mean(slacks)
    min_S = np.min(slacks)

    #####################################

    csv_header_list = list()
    for t1 in ["Cell_Delay", "Wire_Delay", "Cell_Slew", "Wire_Slew", "Arrival", "Slack"]:
        for t2 in ["R2", "mean_ad", "max_ad", "min", "mean", "max"]:
            item = "%s (%s)" % (t1, t2)
            csv_header_list.append(item)
    csv_header = "DESIGN,PEX1,STA1,CC1,SI1,PEX2,STA2,CC2,SI2,CASE,"+",".join(csv_header_list)+"\n"

    summary = f"{DESIGN},{PEX1},{STA1},{CC1},{SI1},{PEX2},{STA2},{CC2},{SI2},{CASE}"
    summary += f",{r2_CD:.4f},{mean_ad_CD:.4f},{max_ad_CD:.4f},{min_CD:.4f},{mean_CD:.4f},{max_CD:.4f}"
    summary += f",{r2_WD:.4f},{mean_ad_WD:.4f},{max_ad_WD:.4f},{min_WD:.4f},{mean_WD:.4f},{max_WD:.4f}"
    summary += f",{r2_CS:.4f},{mean_ad_CS:.4f},{max_ad_CS:.4f},{min_CS:.4f},{mean_CS:.4f},{max_CS:.4f}"
    summary += f",{r2_WS:.4f},{mean_ad_WS:.4f},{max_ad_WS:.4f},{min_WS:.4f},{mean_WS:.4f},{max_WS:.4f}"
    summary += f",{r2_A:.4f},{mean_ad_A:.4f},{max_ad_A:.4f},{min_A:.4f},{mean_A:.4f},{max_A:.4f}"
    # summary += f",{r2_R:.4f},{mean_ad_R:.4f},{max_ad_R:.4f},{min_R:.4f},{mean_R:.4f},{max_R:.4f}"
    summary += f",{r2_S:.4f},{mean_ad_S:.4f},{max_ad_S:.4f},{min_S:.4f},{mean_S:.4f},{max_S:.4f}"
    summary += "\n"

    if not os.path.exists(SUMMARY_FILE):
        with open(SUMMARY_FILE, "w") as f:
            f.writelines(csv_header)

    with open(SUMMARY_FILE, "a") as f:
        f.writelines(summary)

    open(f"{DONE_DIR}/timing_{DESIGN}_{PEX1}_{STA1}_{CC1}_{SI1}_{PEX2}_{STA2}_{CC2}_{SI2}_{CASE}", "w").close()
    #open(f"{DONE_DIR}/timing_{DESIGN}_{PEX2}_{STA2}_{CC2}_{SI2}_{PEX1}_{STA1}_{CC1}_{SI1}_{CASE}", "w").close()
