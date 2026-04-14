# From receptor binding to biogeography: Multi-scale prediction of filovirus hosts in bats
Gathered here are all of the scripts dedicated to modeling bat NPC1 binding strength to all currently known mammalian filoviruses. 

The files found here relate to a variety of purposes: 1) scripts that allow for our data collation and modeling pipeline to be transparent and reproducible, and 2) scripts and files that allow for our results to be appropriately viewed and explored. The latter usage is mainly performed using the `FilovirusResultsMammals.Rmd` file. We note that although some of the data required to run these scripts is included in the data folder (mainly used for `FilovirusResultsMammals.Rmd`), the user should also download model results and primary data objects from our [FigShare collection](https://figshare.com/s/911bfcb78d49757902f9). That collection also includes a file for binding strength predictions for 1,342 bats to 11 filoviruses. 

Scripts included here are:
- FilovirusResultsMammals.Rmd: Includes summary figures and interrogations of the data and for each set of model results. Instead of running this, consider heading to the FigShare and downloading the HTML file that is already compiled to easily explore our results.
- FiloPlotFunctions.R: a group of functions that allows for easy creation of the various types of plots used in `FilovirusResultsMammals.Rmd`
- NPC1DataCollation.Rmd: Shows the process of creating our training and prediction datasets using a variety of publicly available trait databases.
- NPC1MammalPhyloIterations.Rmd: The pipeline for running our boosted regression tree analysis using our trait variables.
