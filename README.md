# ValenciaInR
 This package adds the vaginal microbiome analysis tool Valencia to R & converts phyloseq objects to the format needed for Valencia.

## Installing ValenciaInR
- ValenciaInR can be installed using `devtools::install_github("JLammons14/ValenciaInR")`
- If python is not found, you can either try adding it to your path, or re-install python using `reticulate::install_python("Python_version")`
## Functions
Currently the package contains two functions.
 1. `phy_to_val(phyloseq_object)` which will convert a phyloseq object to data frame formatted for Valencia. This function has been designed with the SILVA database naming convention in mind. It may still work with 16s data mapped to other databases, but they have not been tested.
   There are additional options that can be used to adjust the taxanomic classification so that input data better matches the naming convention and taxonomic classification used in the Valencia reference database, as well as to circumvent the limitations of 16s sequencing and classification.  
  - The first option is `gard_adjust = T`, this will convert any OTU assigned to genus Gardnerella to be reassigned to Gardnerella vaginalis. This option has been added because Gardnerella species are rarely identified using 16s sequencing. Gardnerella species other than gardnerella vaginalis are uncommon and some argue that microbes in Gardnerella can not be speciated. 
  - The second option is `prevotella_adjust =T`, this will convert all reads classified at the genus level as "Prevotella_7" or "Prevotella_9" to genus "Prevotella". Similar to the Gardnerella, Prevotella_7 and Prevotella_9 genus are not classifications in the Valencia reference database, are uncommon, and share significant homology with Prevotella genus OTUs.
 
 2. `Valencia("valencia_formated_dataframe")` which will run Valencia, cited below, on a dataframe in the format required by Valencia


## Valcenia Publication and Github
 - France MT, Ma B, Gajer P, Brown S, Humphrys MS, Holm JB, Waetjen LE, Brotman RM, Ravel J. VALENCIA: a nearest centroid classification method for vaginal microbial communities based on composition. Microbiome. 2020 Nov 23;8(1):166. doi: 10.1186/s40168-020-00934-6. PMID: 33228810; PMCID: PMC7684964.
 - https://github.com/ravel-lab/VALENCIA
