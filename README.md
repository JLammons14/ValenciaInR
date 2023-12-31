# ValenciaInR
 This package adds the vaginal microbiome analysis tool Valencia to R & converts phyloseq objects to the format needed for Valencia.

## Installing ValenciaInR
- ValenciaInR can be installed using `devtools::install_github("JLammons14/ValenciaInR")`
- If python is not found, you can either try adding it to your path, or re-install python using `reticulate::install_python("Python_version")`
## Functions
Currently the package contains two functions.
 1. `phy_to_val(phyloseq_object)` which will convert a phyloseq object to a dataframe formatted for Valencia classification. The input phyloseq object should contain read count data that isn't agglomerated. This function has been designed with the SILVA database naming convention in mind. It may still work with 16s data mapped to other databases, but they have not been tested.
- The script will agglomerated reads the the lowest level listed in the Valencia database. All taxonomic classifications in the output dataframe that do not match classifications in the Valencia reference database will be listed in the console at the genus level. 
- There are additional options that can be used to adjust classifications to better match Valcencia naming convention and taxonomic classification, as well as to circumvent the limitations associated with 16s sequencing of the V4 region.  
  - `gard_adjust = T`,  will convert any OTU assigned to genus "Gardnerella" to be reassigned to "Gardnerella_vaginalis".
  - `prevotella_adjust =T`, will convert all reads classified at the genus level as "Prevotella_7" or "Prevotella_9" to genus "Prevotella".
  - `lact_adjust = T` will rename the classification of OTUs labeled as "Lactobacillus_acidophilus", "Lactobacillus_gallinarum", or "Lactobacillus_casei" to "Lactobacillus_crispatus". Also OTUs labeled "Lactobacillus_fornicalis" we be reclassified to "Lactobacillus_jensenii" 
 
 2. `Valencia("valencia_formated_dataframe")` which will run Valencia, cited below, on a properly formatted dataframe. Additional details on how dataframes need to be formatted for Valencia analysis can be found on the Valencia github page.  

## Valcenia Publication and Github
 - France MT, Ma B, Gajer P, Brown S, Humphrys MS, Holm JB, Waetjen LE, Brotman RM, Ravel J. VALENCIA: a nearest centroid classification method for vaginal microbial communities based on composition. Microbiome. 2020 Nov 23;8(1):166. doi: 10.1186/s40168-020-00934-6. PMID: 33228810; PMCID: PMC7684964.
 - https://github.com/ravel-lab/VALENCIA
