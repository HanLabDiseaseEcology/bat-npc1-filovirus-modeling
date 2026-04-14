Contained in this folder are most data products required to run the FilovirusResults.Rmd script. This script describes all of the results, creates several plots, and allows for exploration of these data and results (see the HTML version uploaded if you don't want to run it!). Due to storage space limitations on Github, the model results are mostly found on [FigShare](https://figshare.com/s/911bfcb78d49757902f9). The remaining files included are:
- batpcoa.csv: Principal coordinates analysis values for the first 17 axes provided for each of the bats. The names used are from Upham et al. 2019.
- batphylodist_09Jul2025: a file containing pairwise phylogenetic distances of these bats created from 1,000 random trees from Upham et al. 2019. This is mainly for ease of use and also to allow this process to run faster (and without needing all of the trees on hand).
- bats_obs_pred.csv: Binding strength label values from Lasso et al. 2025
- filobats_threshold.csv: Bats above a binding strength threshold at around a ~100 km resolution across the globe. The binding strength threshold is 217.9 representing the binding strength of Mops condylurus to BOMV. 
- FilovirusPredictions.csv: Binding strength predictions for each bat species to each filovirus.
- Jordan_Updated_Ebola.csv: A record of filovirus outbreaks and detections (no serological evidence included) for all described mammalian filoviruses.
- mammphylodata_21Jan2025.csv: Training dataset used for all analyses with variables removed due to missing values and skewed variables log transformed. Allows for quicker use.
- MamPhy_fullPosterior_BDvr_Completed_5911sp_topoCons_FBDasZhouEtAl_MCC_v2_target.tre: Tree from Upham et al. 2019 that is used to grab family information and act as a backbone for any plotting of phylogenetic information.
- npc1prediction_20Mar2024.csv: Prediction dataset used that includes most species of bats with trait information.
- npc1training_18Mar2024.csv: Training dataset that includes trait variables for species used in the training of our models.
- PredictedBatsHan2016.csv: Predictions from Han et al. 2016 used for easy comparison with results from this paper. The results were available in a PDF format, so this makes them easier to use.
- shap_geometric_mean.csv: The geometric mean of SHAP values at ~100 km resolution across the globe as mapped to bat distributions. Mammal distribution data is from Marsh et al. 2022.
- waterbodies.shp: Large waterbody data to help clean up the plots a bit :)

Files not included here are CSVs containing parameterization evaluations, evaluation metrics for the chosen parameter set, variable importance values using SHAP, and finer scale SHAP values for each variable that can be used to make partial dependence plots. As mentioned above, these are found in the FigShare collection linked above.
