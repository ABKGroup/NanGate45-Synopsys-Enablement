import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from sklearn.metrics import r2_score
import seaborn as sns
import argparse

def plot(data1, data2, x_axis, y_axis, title, plot_dir):
    plot_name = "%s/%s.png" %(plot_dir, title)

    plt.figure(figsize=(8, 6))
    plt.scatter(data1, data2, alpha=0.1)

    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title(title)

    plt.grid(True)

    min_val = min(data1.min(), data2.min())
    max_val = max(data1.max(), data2.max())
    plt.plot([min_val, max_val], [min_val, max_val], color='red', linestyle='dashed', linewidth=1)

    R2 = r2_score(data1, data2)

    text_x = min_val + (max_val - min_val) * 0.05
    text_y = max_val - (max_val - min_val) * 0.1  

    plt.text(text_x, text_y, f"R2: {R2:.4f}", fontsize=12, color='black', bbox=dict(facecolor='white', alpha=0.7))

    plt.savefig(plot_name, dpi=300, bbox_inches='tight')
    plt.close()

    return R2



def save_ad_dist(y_true, y_pred, plot_dir):
    mask = ~((y_true == 0) & (y_pred == 0))
    y_true = y_true[mask]
    y_pred = y_pred[mask]

    title = 'Dist_of_AbsDiff_of_Cap'
    plot_name = "%s/%s.png" %(plot_dir, title)

    ad = np.abs(y_true - y_pred)

    max_ad = np.max(ad)
    mean_ad = np.mean(ad)

    plt.figure(figsize=(10, 6))
    plt.hist(ad, bins=1000, edgecolor='none')

    plt.axvline(mean_ad, color='blue', linestyle='--', label=f'Mean: {mean_ad:.4f}')
    plt.axvline(max_ad, color='red', linestyle='--', label=f'Max: {max_ad:.4f}')

    plt.legend(loc='best')

    plt.xlabel('AbsDiff (fF)')
    plt.ylabel('Frequency')
    plt.title(title)
    plt.grid(True)

    plt.savefig(plot_name, dpi=300, bbox_inches='tight')
    plt.close()

    return mean_ad, max_ad


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--DESIGN", type=str, default="ldpc_decoder_mod")
    parser.add_argument("--PEX1", type=str, default="INVS")
    parser.add_argument("--PEX2", type=str, default="FC")
    parser.add_argument("--CC1", type=str, default="true")
    parser.add_argument("--CC2", type=str, default="true")

    args = parser.parse_args()

    DESIGN = args.DESIGN
    PEX1 = args.PEX1
    PEX2 = args.PEX2
    CC1 = args.CC1
    CC2 = args.CC2


    TARGET = "net_capacitance"

    HOME_DIR = "../.."
    DESIGN_DIR = f"{HOME_DIR}/benchmark/{DESIGN}"

    CSV1_FILE = f"{DESIGN_DIR}/{TARGET}/{PEX1}/CC_{CC1}/net_parasitics.csv"
    CSV2_FILE = f"{DESIGN_DIR}/{TARGET}/{PEX2}/CC_{CC2}/net_parasitics.csv"

    PLOT_DIR = f"{DESIGN_DIR}/plot/{TARGET}/{PEX1}_CC_{CC1}_vs_{PEX2}_CC_{CC2}"
    SUMMARY_DIR = f"{DESIGN_DIR}/summary"
    DONE_DIR = f"{DESIGN_DIR}/done"

    SUMMARY_FILE = f"{SUMMARY_DIR}/{TARGET}.csv"

    os.makedirs(PLOT_DIR, exist_ok=True)
    os.makedirs(SUMMARY_DIR, exist_ok=True)
    os.makedirs(DONE_DIR, exist_ok=True)

    df1 = pd.read_csv(CSV1_FILE)
    df2 = pd.read_csv(CSV2_FILE)

    df1["cap"] = df1["cap"].astype(float)
    df2["cap"] = df2["cap"].astype(float)

    df1 = df1.dropna(subset=["cap"])
    df2 = df2.dropna(subset=["cap"])

    df = pd.merge(df1, df2, on='net_name', how='inner')

    #df['cap_diff'] = abs(df['cap_x'] - df['cap_y'])
    #max_diff_net = df.loc[df['cap_diff'].idxmax(), 'net_name']
    #print(f"net_name: {max_diff_net}")

    cap_x_flat = df["cap_x"].to_numpy()
    cap_y_flat = df["cap_y"].to_numpy()

    cap = np.concatenate([cap_x_flat, cap_y_flat])
    
    max_cap = np.max(cap)
    mean_cap = np.mean(cap)
    std_cap = np.std(cap)
    min_cap = np.min(cap)

    mean_ad, max_ad = save_ad_dist(cap_x_flat, cap_y_flat, PLOT_DIR)
    R2 = plot(cap_x_flat, cap_y_flat, "Cap (%s) [fF]" %(PEX1), "Cap (%s) [fF]" %(PEX2), "Comp_of_Cap", PLOT_DIR)
   
    csv_header = "DESIGN,PEX1,PEX2,CC1,CC2,R2,mean_ad,max_ad,min_cap,mean_cap,std_cap,max_cap\n"
    summary = f"{DESIGN},{PEX1},{PEX2},{CC1},{CC2},{R2:.4f},{mean_ad:.4f},{max_ad:.4f},{min_cap:.4f},{mean_cap:.4f},{std_cap:.4f},{max_cap:.4f}\n"

    if not os.path.exists(SUMMARY_FILE):
        with open(SUMMARY_FILE, "w") as f:
            f.writelines(csv_header)

    with open(SUMMARY_FILE, "a") as f:
        f.writelines(summary)

    open(f"{DONE_DIR}/cap_{DESIGN}_{PEX1}_{CC1}_{PEX2}_{CC2}", "w").close()
    #open(f"{DONE_DIR}/cap_{DESIGN}_{PEX2}_{CC2}_{PEX1}_{CC1}", "w").close()
