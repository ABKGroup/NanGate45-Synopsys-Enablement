# NanGate45-Synopsys-Enablement
This work was conducted by students at UCSD, POSTECH, and Drexel to help enable fundamental research in EDA using the NanGate45 open-source PDK and the NanGate Open Cell Library. 
When the NanGate45 research enablement was first released (e.g., https://eda.ncsu.edu/downloads), only Cadence enablement was provided. 
As a result, researchers have not been able to perform post-route extraction and timing, or timing-driven P&R, using Synopsys tools. 
Our work develops and makes public .tluplus and other necessary design enablement so that post-route extraction and timing, as well as timing-driven P&R, are possible for Synopsys tool users. 
We provide testcases and example scripts showing “reasonable” correlation of our new Synopsys enablement to the previously-existing Cadence enablement. 
Importantly, please note that indicators of correlation that we present are not, and should not be construed as, "benchmarking" of any kind. 
We make no value judgments regarding the respective merits of commercial EDA tools. We welcome suggestions for improvement or improved materials to be included in this repository; 
please communicate these by email or use GitHub issues, pull requests, etc. Our contact information is provided below. Last, please note and read carefully the headers of all TCL files in this repository that invoke commercial EDA tools. We thank both Cadence and Synopsys for allowing their copyrighted IP to be made publicly available for use by researchers in this manner.


## Contacts
- Andrew B. Kahng (abk@ucsd.edu)
- Seokhyeong Kang (shkang@postech.ac.kr)
- Jakang Lee (wkrkd95@postech.ac.kr)
- Ioannis Savidis (is338@drexel.edu)
- Pratik Shrestha (ps937@drexel.edu)
- Dooseok Yoon (d3yoon@ucsd.edu)

## Contents 
- [Design Enablement](#Design-Enablement)
- [Validation of Design Enablement](#Validation-of-Design-Enablement)
  - [Experimental Flows](#Experimental-Flows)
  - [Types of Timing Path Matching](#Types-of-Timing-Path-Matching)
- [Experimental Results](#Experimental-Results)
  - [Summary](#Summary)
- [Usage and Running Instructions](#Usage-and-Running-Instructions)
  - [How to use](#How-to-use)
  - [Directory and File Descriptions](#Directory-and-File-Descriptions)
  - [Additional Design Constraints](#Additional-Design-Constraints)
  - [Environment](#Environment)
- [References](#References)
- [Appendix](#Appendix)
  - [Experimental Tables and Plots](#Experimental-Tables-and-Plots)


## Design Enablement
The files required for design implementation are as follows.
|                      |  Cadence  | Synopsys |
|:--------------------:|:---------:|:--------:|
|   Physical library   |    LEF   |   LEF   |
|  Technology library  |    LEF   |    TF   |
|    Liberty library   |    LIB   |    DB   |
|   Interconnect File  |    ICT   |   ITF   |
|    RC Lookup Table   | CAPTABLE |  TLU+ |
| Parasitic Extraction |    QRC   |  NXTGRD |

All enablements, except for Synopsys enablement, are taken from [[1]](https://github.com/TILOS-AI-Institute/MacroPlacement). Additionally, this repository includes .tf files (modified from [[2]](https://github.com/mflowgen/freepdk-45nm)), as well as .db, .itf, .ict, .tluplus, and .nxtgrd files.

## Validation of Design Enablement
To validate the Synopsys enablement that we provide, we conduct experiments comparing the results from the flows of two EDA companies (i.e., Synopsys and Cadence) under various conditions. The evaluation metrics we use are as follows:
- **Number of Matching Timing Paths.** This metric is based on the endpoint timing information output by both tools. It measures the consistency of PEX and STA engines between the two tools.
- **Net Capacitance.** The capacitance of all nets in the design. This metric can be further categorized based on whether coupling capacitance is present.
- **Timing Details for Each Endpoint.** The characteristics of all timing endpoints in the design, based on setup analysis. These values can be further categorized based on whether the options for coupling capacitance extraction and signal integrity analysis are enabled.
  - Actual Arrival Time
  - Worst Slack
  - Each Cell Delay
  - Each Wire Delay
  - Each Cell Output Slew
  - Each Wire Output Slew

###  Experimental Flows
Timing details vary depending on the design stage and the tools we use.

- Flow 1: Embedded PEX in P&R tool, and embedded STA in P&R tool  
<div align="center">
  <img src="https://github.com/user-attachments/assets/1975657c-7e62-42a2-a2b3-cc6a209052a3" alt="Figure" style="width: 90%">
  <br>
</div>


- Flow 2: Embedded PEX in P&R tool, and Standalone STA  
<div align="center">
  <img src="https://github.com/user-attachments/assets/e9a6e402-881d-415c-b2fe-354693d3f58f" alt="Figure" style="width: 90%">
  <br>
</div>


- Flow 3: Standalone PEX, and Standalone STA  
<div align="center">
  <img src="https://github.com/user-attachments/assets/3f39b066-e558-493c-92b7-073db945ce92" alt="Figure" style="width: 90%">
  <br>
</div>


- **Flow 1**: This flow uses the embedded PEX and STA engines in each P&R tool as-is, juxtaposing the results from Cadence Innovus and Synopsys Fusion Compiler.

- **Flow 2**: In this flow, the embedded PEX engine of each P&R tool is used as-is, while the STA analysis is performed with the same tool (Synopsys PrimeTime). By fixing the STA engine, only the differences between the PEX engines are analyzed. In this flow, we use the SPEF files generated by Cadence Innovus and Synopsys Fusion Compiler as input for Synopsys PrimeTime. (Note that we have also implemented a symmetric flow that uses Cadence Tempus. The fact that we discuss Synopsys PrimeTime here in no way implies any preference or value judgment. For the Cadence Tempus-based flow, please refer to the instructions below.)

- **Flow 3**: This flow independently utilizes both the PEX and STA engines for analysis, employing Cadence Quantus and Tempus alongside Synopsys StarRC and PrimeTime.

### Types of Timing Path Matching
We must note that when extracting timing paths from different tools, the timing paths reported for given endpoints and/or for given analysis requests do not always exactly match. Therefore, for the purpose of comparing the characteristics of the timing paths in our experiment, we define ‘matching timing path types’ as follows:
  - Case 1: The timing paths from both tools have the same cells and transition types (i.e., rise, fall).
  - Case 2: The timing paths from both tools consist of the same cells but have different transition types.
  - Case 3: At least one cell in the timing paths differs between the two tools.

In this repository, we use only Cases 1 and 2 for comparison and evaluation.

The figure below shows the path matching types in our repository:
<div align="center">
  <img src="https://github.com/user-attachments/assets/ce7cc0a7-9c6d-451f-bfdd-34aeb998c007" alt="Figure" style="width: 90%;">
  <br>
</div>

## Experimental Results

We summarize the experimental results using tables and plots. The plots presented here have been selected as representative examples for validation scenarios of interest. 
Data and plots can be directly examined, either by following usage instructions below to extract the data yourself, or by checking the files that have been uploaded in the "benchmark" directory.

We use “absolute difference” for evaluation because the scale of the data we handle is very small, and use of relative difference would lead to data distortion.
However, since absolute difference is expressed in absolute terms, its value varies depending on the range of the data. Therefore, when reporting our results here, we use “Normalized Absolute difference.” 
This is simply the mean or the maximum absolute difference, divided by the data range. Here, data range is defined as the difference between the maximum and minimum values across all data points from both groups being compared.

The formula is as follows:  
```
Normalized Absolute Difference = Absolute Difference / (Maximum - Minimum)
```
The abbreviations used in the experimental report have the following meanings:

- DESIGN: The name of the top module in the benchmark.
- CC: Whether or not to include and extract the “Coupling Capacitance” (CC) during parasitic extraction.
- SI: Whether or not to enable “Signal Integrity” (SI) analysis during static timing analysis.
- INVS: Innovus
- FC: Fusion Compiler
- QTS: Quantus
- TPS: Tempus
- STRC: StarRC
- PT: PrimeTime
- PEX: Parasitic Extraction Engine
- STA: Static Timing Analysis Engine

### Summary

- **Number of Matching Timing Paths**  
  Statistics for paths that match both Case 1 and Case 2.
  - Flow 1:  
    - When coupling capacitance extraction and signal integrity analysis are **disabled**:
      - **Lowest matching rate**: 64 % (IBEX)
      - **Average matching rate**: 88.41 %
      - **Highest matching rate**: 98.68 % (LDPC)
    
    - When coupling capacitance extraction and signal integrity analysis are **enabled**:
      - **Lowest matching rate**: 59.07 % (IBEX)
      - **Average matching rate**: 77.69 %
      - **Highest matching rate**: 97.08 % (JPEG)
  
  - Flow 2:  
    - When coupling capacitance extraction and signal integrity analysis are **disabled**:
      - **Lowest matching rate**: 78.21 % (IBEX)
      - **Average matching rate**: 92.70 %
      - **Highest matching rate**: 98.83 % (LDPC)
    
    - When coupling capacitance extraction and signal integrity analysis are **enabled**:
      - **Lowest matching rate**: 68.85 % (LDPC)
      - **Average matching rate**: 81.11 %
      - **Highest matching rate**: 98.56 % (JPEG)
  
  - Flow 3:    
    - When coupling capacitance extraction and signal integrity analysis are **enabled**:
      - **Lowest matching rate**: 58.31 % (IBEX)
      - **Average matching rate**: 79.72 %
      - **Highest matching rate**: 96.79 % (JPEG)

  - Summary: Consolidating the results from the three flows, we observe that the average matching rates range from approximately 77.7% to 92.7%. Overall, our implemented Synopsys enablement achieves an average timing path matching rate of about 83.93% compared to Cadence enablement.  


- **Net Capacitance**  
The average net capacitance comparison results across all designs are as follows:
  - **R2 score**: 0.9957
  - **mean normalized absolute difference**: 0.09 %
  - **maximum normalized absolute difference**: 7.71 %


- **Timing Details for Each Endpoint**  
The table in the Appendix Section summarizes the comparison results for Actual Arrival Time (AAT) and Slack in Timing Path Matching Case 1. Overall, across all designs:

  - **AAT**:
    - **R2 score**: 0.9993
    - **Mean normalized absolute difference**: 0.37 %
    - **Maximum normalized absolute difference**: 3.92 %
  
  - **Slack**:
    - **R2 score**: 0.9991
    - **Mean normalized absolute difference**: 0.37 %
    - **Maximum normalized absolute difference**: 6.82 %
  


 
## Usage and Running Instructions

### How to use
If you want to run the predefined studies, please use:
```
Usage) ./run.sh
```

If you want to run with a custom combination:
```
Example) make DESIGN=ldpc_decoder_mod PEX_TOOL1=innovus STA_TOOL1=innovus CC1=true SI1=true PEX_TOOL2=fusion_compiler STA_TOOL2=fusion_compiler CC2=true SI2=true CASE=1
```

The execution results are stored in the "benchmark/(your_design_name)" directory.


### Directory and File Descriptions
Our repository is composed of the following files and directories:  
- **NanGate45**: Directory containing design enablement for Cadence and Synopsys.
- **benchmark**: The design directory that we used for evaluation:
  - Input files for Extracting Design Data
    - DEF file with routing
    - Flattened netlist file after routing stage
    - SDC file with all input/output port constraints
  - Output files
    - SPEF files
    - CSV files of net capacitance
    - CSV files of timing details
    - summary files
    - plot
    - done: A directory that collects files used to verify the completion of a particular step in the Makefile. In particular, it deals with generating data tables and plots.
- **scripts**: This directory contains EDA tool scripts that allow users to run PEX and STA according to their preferences.
- **Makefile**: Users can process data from various tools they wish to compare using the make command. This Makefile performs the following functions:
  - It executes the user-selected PEX tool and STA tool to generate CSV files containing net capacitance and timing details. Since two types of data are required for comparison, users must define two flow types (please refer to the example parameters below).
  - It reads the generated CSV files and produces evaluation metrics such as plots, R2 scores, and absolute differences.
  - Parameters
    - **DESIGN**: The top-level block name defined in the DEF and netlist.
    - **PEX_TOOL1 / PEX_TOOL2**: The PEX Engine for extracting the SPEF file. The allowed values are "innovus", "quantus", "fusion_compiler", and "starRC". Innovus utilizes TQuantus which is the built-in PEX engine.
    - **STA_TOOL1 / STA_TOOL2**: The STA engine for extracting timing details. The allowed values are "innovus", "tempus", "fusion_compiler", and "PrimeTime".
    - **CC1 / CC2**: Whether to extract coupling capacitance along with the SPEF when using the PEX Engine. The allowed values are "true", "false".
    - **SI1 / SI2**: Whether to extract timing details with signal integrity analysis in the STA engine. The allowed values are "true", "false".
    - **NWORST**: The maximum number of worst paths to extract at each endpoint. This is typically set to 1. The allowed values are the number over one.
    - **CASE**: Which matched path type to assume when extracting timing details (please refer to the aforementioned "path matching type"). The allowed values are "1", "2".
- **run.sh**: The file that defines the presets used in the experiment.


### Additional Design Constraints
To extract as many timing paths as possible, we add the following constraints to the SDC. These constraints intentionally apply timing constraints to the primary input/output ports so that they are considered as timing paths during STA.
- set_input_delay -clock [get_clocks $clock_name] 0.0 [all_inputs]
- set_output_delay -clock [get_clocks $clock_name] 0.0 [all_outputs]

Additionally, since Fusion Compiler allows timing borrowing in latch timing analysis by default while Innovus does not, we recommend adding the following constraint to facilitate comparison under identical analysis conditions. (Optional)
- set_max_time_borrow 0 [all_registers]

The figure below shows the types of timing paths that we extract.
<div align="center">
  <img src="https://github.com/user-attachments/assets/919640aa-f5d6-4376-b39d-cb89a11939d4" alt="Figure" style="width: 90%">
</div>

### Environment
For commercial EDA tools, we tested the tools with the versions below.  
[Cadence]  
- Innovus: 21.1
- Quantus: 21.1
- Tempus: 21.1

[Synopsys]  
- Fusion Compiler: 22.3  
- PrimeTime: 18.6
- StarRC: 18.6

## References
[1] NanGate45 from [TILOS-AI-Institute/MacroPlacement's github](https://github.com/TILOS-AI-Institute/MacroPlacement)  
[2] Synopsys tech file (.tf) from [mflowgen/freepdk-45nm](https://github.com/mflowgen/freepdk-45nm)  



## Appendix

### Experimental Tables and Plots

#### Number of Matching Timing Paths

- Flow 1  
<table><thead>
  <tr>
    <th>DESIGN</th>
    <th>CC &amp; SI</th>
    <th># of timing paths</th>
    <th># of matched timing paths [Case 1 + Case 2]</th>
  </tr></thead>
<tbody>
  <tr>
    <td align="center" rowspan="2">AES</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">1444</td>
    <td align="right">1368 (94.74 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">1241 (85.94 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">IBEX</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">4925</td>
    <td align="right">3152 (64.00 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">2909 (59.07 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">JPEG</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">12131</td>
    <td align="right">11771 (97.03 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">11777 (97.08 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">LDPC</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">6145</td>
    <td align="right">6064 (98.68 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">4123 (67.10 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">Ariane133</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">62086</td>
    <td align="right">50845 (81.89 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">50039 (80.60 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">NVDLA<br>part c</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">122999</td>
    <td align="right">115792 (94.14 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">93906 (76.35 %)</td>
  </tr>
</tbody></table>

- Flow 2  

<table><thead>
  <tr>
    <th align="center">DESIGN</th>
    <th align="center">CC &amp; SI</th>
    <th align="center"># of timing paths</th>
    <th align="center"># of matched timing paths [Case 1 + Case 2]</th>
  </tr></thead>
<tbody>
  <tr>
    <td align="center" rowspan="2">AES</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">1444</td>
    <td align="right">1394 (96.54 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">1232 (85.32 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">IBEX</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">4925</td>
    <td align="right">3852 (78.21 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">3406 (69.16 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">JPEG</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">12131</td>
    <td align="right">11942 (98.44 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">11956 (98.56 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">LDPC</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">6145</td>
    <td align="right">6073 (98.83 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">4231 (68.85 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">Ariane133</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">62086</td>
    <td align="right">54195 (87.29 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">54237 (87.36 %)</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">NVDLA<br>part c</td>
    <td align="center">OFF</td>
    <td align="right" rowspan="2">122999</td>
    <td align="right">119180 (96.90 %)</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">95179 (77.38 %)</td>
  </tr>
</tbody></table>


- Flow 3  
<table><thead>
  <tr>
    <th align="center">DESIGN</th>
    <th align="center">CC &amp; SI</th>
    <th align="center"># of timing paths</th>
    <th align="center"># of matched timing paths [Case 1 + Case 2]</th>
  </tr></thead>
<tbody>
  <tr>
    <td align="center">AES</td>
    <td align="center">ON</td>
    <td align="right">1444</td>
    <td align="right">1209 (83.73 %)</td>
  </tr>
  <tr>
    <td align="center">IBEX</td>
    <td align="center">ON</td>
    <td align="right">4925</td>
    <td align="right">2872 (58.31 %)</td>
  </tr>
  <tr>
    <td align="center">JPEG</td>
    <td align="center">ON</td>
    <td align="right">12131</td>
    <td align="right">11741 (96.79 %)</td>
  </tr>
  <tr>
    <td align="center">LDPC</td>
    <td align="center">ON</td>
    <td align="right">6145</td>
    <td align="right">4144 (67.44 %)</td>
  </tr>
  <tr>
    <td align="center">Ariane133</td>
    <td align="center">ON</td>
    <td align="right">62086</td>
    <td align="right">46865 (75.48 %)</td>
  </tr>
  <tr>
    <td align="center">NVDLA<br>part c</td>
    <td align="center">ON</td>
    <td align="right">122999</td>
    <td align="right">118787 (96.58 %)</td>
  </tr>
</tbody>
</table>


#### Net Capacitance

<table><thead>
  <tr>
    <th align="center" rowspan="2">DESIGN</th>
    <th align="center" rowspan="2">Cadence's PEX ↔ Synopsys's PEX</th>
    <th align="center" rowspan="2">CC</th>
    <th align="center" rowspan="2">R2</th>
    <th align="center" colspan="3">Normalized Absolute Error</th>
  </tr>
  <tr>
    <th align="center">Mean</th>
    <th align="center">Std</th>
    <th align="center">Max</th>
  </tr></thead>
<tbody>
  <tr>
    <td align="center" rowspan="3">AES</td>
    <td align="center" rowspan="2">INVS ↔ FC</td>
    <td align="center">OFF</td>
    <td align="right">0.9966</td>
    <td align="right">0.13%</td>
    <td align="right">0.22%</td>
    <td align="right">5.53%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9968</td>
    <td align="right">0.13%</td>
    <td align="right">0.22%</td>
    <td align="right">5.54%</td>
  </tr>
  <tr>
    <td align="center">QTS ↔ STRC</td>
    <td align="center">ON</td>
    <td align="right">0.9965</td>
    <td align="right">0.15%</td>
    <td align="right">0.22%</td>
    <td align="right">5.81%</td>
  </tr>
  <tr>
    <td align="center" rowspan="3">IBEX</td>
    <td align="center" rowspan="2">INVS ↔ FC</td>
    <td align="center">OFF</td>
    <td align="right">0.9955</td>
    <td align="right">0.13%</td>
    <td align="right">0.42%</td>
    <td align="right">13.81%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9955</td>
    <td align="right">0.12%</td>
    <td align="right">0.42%</td>
    <td align="right">14.36%</td>
  </tr>
  <tr>
    <td align="center">QTS ↔ STRC</td>
    <td align="center">ON</td>
    <td align="right">0.9952</td>
    <td align="right">0.22%</td>
    <td align="right">0.46%</td>
    <td align="right">6.46%</td>
  </tr>
  <tr>
    <td align="center" rowspan="3">JPEG</td>
    <td align="center" rowspan="2">INVS ↔ FC</td>
    <td align="center">OFF</td>
    <td align="right">0.9929</td>
    <td align="right">0.05%</td>
    <td align="right">0.23%</td>
    <td align="right">10.11%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9925</td>
    <td align="right">0.05%</td>
    <td align="right">0.24%</td>
    <td align="right">10.45%</td>
  </tr>
  <tr>
    <td align="center">QTS ↔ STRC</td>
    <td align="center">ON</td>
    <td align="right">0.9956</td>
    <td align="right">0.07%</td>
    <td align="right">0.16%</td>
    <td align="right">5.52%</td>
  </tr>
  <tr>
    <td align="center" rowspan="3">LDPC</td>
    <td align="center" rowspan="2">INVS ↔ FC</td>
    <td align="center">OFF</td>
    <td align="right">0.9961</td>
    <td align="right">0.11%</td>
    <td align="right">0.25%</td>
    <td align="right">5.69%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9963</td>
    <td align="right">0.10%</td>
    <td align="right">0.24%</td>
    <td align="right">5.53%</td>
  </tr>
  <tr>
    <td align="center">QTS ↔ STRC</td>
    <td align="center">ON</td>
    <td align="right">0.9962</td>
    <td align="right">0.12%</td>
    <td align="right">0.26%</td>
    <td align="right">5.26%</td>
  </tr>
  <tr>
    <td align="center" rowspan="3">Ariane133</td>
    <td align="center" rowspan="2">INVS ↔ FC</td>
    <td align="center">OFF</td>
    <td align="right">0.9947</td>
    <td align="right">0.07%</td>
    <td align="right">0.34%</td>
    <td align="right">13.00%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9945</td>
    <td align="right">0.07%</td>
    <td align="right">0.34%</td>
    <td align="right">13.28%</td>
  </tr>
  <tr>
    <td align="center">QTS ↔ STRC</td>
    <td align="center">ON</td>
    <td align="right">0.9961</td>
    <td align="right">0.12%</td>
    <td align="right">0.31%</td>
    <td align="right">5.78%</td>
  </tr>
  <tr>
    <td align="center" rowspan="3">NVDLA part c</td>
    <td align="center" rowspan="2">INVS ↔ FC</td>
    <td align="center">OFF</td>
    <td align="right">0.9988</td>
    <td align="right">0.00%</td>
    <td align="right">0.01%</td>
    <td align="right">0.84%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9980</td>
    <td align="right">0.00%</td>
    <td align="right">0.01%</td>
    <td align="right">3.47%</td>
  </tr>
  <tr>
    <td align="center">QTS ↔ STRC</td>
    <td align="center">ON</td>
    <td align="right">0.9948</td>
    <td align="right">0.00%</td>
    <td align="right">0.02%</td>
    <td align="right">8.30%</td>
  </tr>
</tbody></table>

The plot below shows the "worst-case" (i.e., in the sense of exhibiting largest deviations between analysis scenarios) comparisons for mean normalized absolute difference and for maximum normalized absolute difference.
 
<div align="center">
  <img src="https://github.com/user-attachments/assets/2f227b90-504d-4b7b-ba94-d52a23a0713e" alt="Figure" style="width: 100%;">
  <br>
</div>


#### Timing Details for Each Endpoint

<table><thead>
  <tr>
    <th align="center" rowspan="3">DESIGN</th>
    <th align="center" rowspan="3">FLOW</th>
    <th align="center" rowspan="3">CC &amp; SI</th>
    <th align="center" colspan="3">Actual Arrival Time</th>
    <th align="center" colspan="3">Slack</th>
  </tr>
  <tr>
    <th align="center" rowspan="2">R2</th>
    <th align="center" colspan="2">Normalized Absolute Difference</th>
    <th align="center" rowspan="2">R2</th>
    <th align="center" colspan="2">Normalized Absolute Difference</th>
  </tr>
  <tr>
    <th align="center">Mean</th>
    <th align="center">Max</th>
    <th align="center">Mean</th>
    <th align="center">Max</th>
  </tr></thead>
<tbody>
  <tr>
    <td align="center" rowspan="5">AES</td>
    <td align="center" rowspan="2">1</td>
    <td align="center">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.25%</td>
    <td align="right">1.22%</td>
    <td align="right">0.9999</td>
    <td align="right">0.25%</td>
    <td align="right">1.17%</td>
  </tr>
  <tr>
    <td align="center" align="right">ON</td>
    <td align="right">0.9991</td>
    <td align="right">0.51%</td>
    <td align="right">5.31%</td>
    <td align="right">0.9991</td>
    <td align="right">0.53%</td>
    <td align="right">5.47%</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">2</td>
    <td align="center">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.24%</td>
    <td align="right">1.04%</td>
    <td align="right">0.9999</td>
    <td align="right">0.25%</td>
    <td align="right">1.13%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9993</td>
    <td align="right">0.38%</td>
    <td align="right">6.13%</td>
    <td align="right">0.9993</td>
    <td align="right">0.40%</td>
    <td align="right">6.19%</td>
  </tr>
  <tr>
    <td align="center">3</td>
    <td align="center">ON</td>
    <td align="right">0.9984</td>
    <td align="right">0.66%</td>
    <td align="right">7.05%</td>
    <td align="right">0.9984</td>
    <td align="right">0.68%</td>
    <td align="right">7.16%</td>
  </tr>
  <tr>
    <td align="center" rowspan="5">IBEX</td>
    <td align="center" rowspan="2">1</td>
    <td align="center">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.15%</td>
    <td align="right">0.81%</td>
    <td align="right">0.9976</td>
    <td align="right">0.20%</td>
    <td align="right"><b><i>44.04%</i></b></td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9996</td>
    <td align="right">0.24%</td>
    <td align="right">3.26%</td>
    <td align="right">0.9962</td>
    <td align="right">0.29%</td>
    <td align="right"><b><i>46.82%</i></b></td>
  </tr>
  <tr>
    <td align="center" rowspan="2">2</td>
    <td align="center">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.19%</td>
    <td align="right">0.73%</td>
    <td align="right">0.9999</td>
    <td align="right">0.20%</td>
    <td align="right">0.76%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9996</td>
    <td align="right">0.35%</td>
    <td align="right">3.40%</td>
    <td align="right">0.9995</td>
    <td align="right">0.36%</td>
    <td align="right">3.50%</td>
  </tr>
  <tr>
    <td align="center">3</td>
    <td align="center">ON</td>
    <td align="right">0.9997</td>
    <td align="right">0.23%</td>
    <td align="right">2.44%</td>
    <td align="right">0.9997</td>
    <td align="right">0.23%</td>
    <td align="right">2.54%</td>
  </tr>
  <tr>
    <td align="center" rowspan="5">JPEG</td>
    <td align="center" rowspan="2">1</td>
    <td align="center">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.23%</td>
    <td align="right">1.34%</td>
    <td align="right">0.9999</td>
    <td align="right">0.23%</td>
    <td align="right">1.35%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9999</td>
    <td align="right">0.24%</td>
    <td align="right">2.65%</td>
    <td align="right">0.9999</td>
    <td align="right">0.23%</td>
    <td align="right">2.81%</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">2</td>
    <td align="center" align="right">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.18%</td>
    <td align="right">0.94%</td>
    <td align="right">0.9999</td>
    <td align="right">0.19%</td>
    <td align="right">0.98%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9999</td>
    <td align="right">0.16%</td>
    <td align="right">2.26%</td>
    <td align="right">0.9999</td>
    <td align="right">0.16%</td>
    <td align="right">2.34%</td>
  </tr>
  <tr>
    <td align="center">3</td>
    <td align="center">ON</td>
    <td align="right">0.9992</td>
    <td align="right">0.65%</td>
    <td align="right">2.61%</td>
    <td align="right">0.9992</td>
    <td align="right">0.63%</td>
    <td align="right">2.67%</td>
  </tr>
  <tr>
    <td align="center" rowspan="5">LDPC</td>
    <td align="center" rowspan="2">1</td>
    <td align="center">OFF</td>
    <td align="right">0.9991</td>
    <td align="right">0.79%</td>
    <td align="right">2.57%</td>
    <td align="right">0.9991</td>
    <td align="right">0.80%</td>
    <td align="right">2.59%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9984</td>
    <td align="right">0.40%</td>
    <td align="right">9.61%</td>
    <td align="right">0.9985</td>
    <td align="right">0.40%</td>
    <td align="right">9.34%</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">2</td>
    <td align="center">OFF</td>
    <td align="right">0.9990</td>
    <td align="right">0.82%</td>
    <td align="right">2.40%</td>
    <td align="right">0.9991</td>
    <td align="right">0.80%</td>
    <td align="right">2.35%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9989</td>
    <td align="right">0.47%</td>
    <td align="right">6.89%</td>
    <td align="right">0.9990</td>
    <td align="right">0.47%</td>
    <td align="right">6.68%</td>
  </tr>
  <tr>
    <td align="center">3</td>
    <td align="center">ON</td>
    <td align="right">0.9981</td>
    <td align="right">0.59%</td>
    <td align="right">6.82%</td>
    <td align="right">0.9984</td>
    <td align="right">0.57%</td>
    <td align="right">6.65%</td>
  </tr>
  <tr>
    <td align="center" rowspan="5">Ariane133</td>
    <td align="center" rowspan="2">1</td>
    <td align="center">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.06%</td>
    <td align="right">0.44%</td>
    <td align="right">0.9999</td>
    <td align="right">0.07%</td>
    <td align="right">0.45%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9995</td>
    <td align="right">0.11%</td>
    <td align="right">2.52%</td>
    <td align="right">0.9995</td>
    <td align="right">0.11%</td>
    <td align="right">2.55%</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">2</td>
    <td align="center">OFF</td>
    <td align="right">0.9999</td>
    <td align="right">0.06%</td>
    <td align="right">0.39%</td>
    <td align="right">0.9999</td>
    <td align="right">0.06%</td>
    <td align="right">0.39%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9998</td>
    <td align="right">0.07%</td>
    <td align="right">1.11%</td>
    <td align="right">0.9998</td>
    <td align="right">0.07%</td>
    <td align="right">1.12%</td>
  </tr>
  <tr>
    <td align="center">3</td>
    <td align="center">ON</td>
    <td align="right">0.9989</td>
    <td align="right">0.21%</td>
    <td align="right">1.62%</td>
    <td align="right">0.9989</td>
    <td align="right">0.21%</td>
    <td align="right">1.63%</td>
  </tr>
  <tr>
    <td align="center" rowspan="5">NVDLA<br>part c</td>
    <td align="center" rowspan="2">1</td>
    <td align="center">OFF</td>
    <td align="right">0.9997</td>
    <td align="right">0.33%</td>
    <td align="right">4.20%</td>
    <td align="right">0.9997</td>
    <td align="right">0.34%</td>
    <td align="right">4.33%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9960</td>
    <td align="right">0.88%</td>
    <td align="right">14.90%</td>
    <td align="right">0.9960</td>
    <td align="right">0.86%</td>
    <td align="right">14.97%</td>
  </tr>
  <tr>
    <td align="center" rowspan="2">2</td>
    <td align="center">OFF</td>
    <td align="right">0.9998</td>
    <td align="right">0.26%</td>
    <td align="right">4.11%</td>
    <td align="right">0.9998</td>
    <td align="right">0.26%</td>
    <td align="right">4.31%</td>
  </tr>
  <tr>
    <td align="center">ON</td>
    <td align="right">0.9997</td>
    <td align="right">0.23%</td>
    <td align="right">6.05%</td>
    <td align="right">0.9997</td>
    <td align="right">0.23%</td>
    <td align="right">6.03%</td>
  </tr>
  <tr>
    <td align="center">3</td>
    <td align="center">ON</td>
    <td align="right">0.9972</td>
    <td align="right">1.08%</td>
    <td align="right">12.63%</td>
    <td align="right">0.9973</td>
    <td align="right">1.05%</td>
    <td align="right">12.41%</td>
  </tr>
</tbody></table>


For IBEX in Flow 1, the Slack comparison shows outliers—with the maximum normalized absolute difference reaching a very high value (**44–47%**). With Flow 2, this phenomenon is not observed. Such a difference may be due to differences between STA engine algorithms or implementations. This said, our focus in this work is solely to provide wire parasitic component modeling files for use of Synopsys tools with NanGate45.  

The plot below shows the Slack results for IBEX in Flow 1 and Flow 2, with outliers highlighted by red dotted lines.

<div align="center">
  <img src="https://github.com/user-attachments/assets/3ef4a669-bf6c-4b62-b5a5-8dd4207f42ec" alt="Figure" style="width: 100%;">
  <br>
</div>


The following plot shows the "worst-case" comparisons for mean normalized absolute difference and for maximum normalized absolute difference, excluding outlier cases.  

<div align="center">
  <img src="https://github.com/user-attachments/assets/8a5acebd-2ef6-4682-b362-0a4123be211a" alt="Figure" style="width: 100%;">
  <br>
</div>

