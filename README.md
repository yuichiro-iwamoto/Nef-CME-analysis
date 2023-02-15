# Nef-CME-analysis
ImageJ scripts and python notebooks used for image analysis in HIV Nef CME project.

ImageJ_scripts_HIV_Nef_CME: 

  These scripts can be run in imageJ. The scripts include basic image processing scripts and scripts used for evaluating colocalization. Instructions can be 
found commented on the scripts themselves for the colocalization scripts. 
  
ImageJ_scripts_cmeAnalysis_prep:

  These scripts can be run in imageJ. The scripts were written to segment a movie that includes a field of cells into individual cells. The cells will be outputted 
into individual folders with a structure compatible with the cmeAnalysis script. 
  
python_scripts_HIV-Nef_CME:

  These are python notebooks and related dependencies that were used to filter and evaluate tracks obtained from cmeAnalysis. The processing software was written 
by Cyna Shirazinejad. Details about filtering parameters as well as the extracted values from analysis can be obtained here. 
  
Scripts_cme_analysis_montage_compilation:

  This folder includes files related to generating a compiled list of montages based off of a list of tracks obtained from cmeAnalysis. The MATLAB script has 
details on dependencies (cmeAnalysis, export_fig, ghostscript). To generate this list of tracks, the included jupyter lab notebook was used. This jupyter lab notebook requires files from the python_scripts_HIV-Nef_CME folder to operate. 
