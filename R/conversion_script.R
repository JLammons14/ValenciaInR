#' @title Convert Phyloseq Object to Valencia Compatible Dataframe
#' @description Converts a phyloseq object to a dataframe that is formatted for Valencia CST classification
#'
#' @param ps_object A phyloseq object containing read count data that has not been agglomerated to any taxonomic level
#' @param gard_adjust An option to adjust the name of gardernella genus/ species to better fix Valencia taxonomic names.
#'                    gard_adjust = T will convert all OTUs mapped to gardnerella genus to be relabeled as Gardnerella_vaginalis
#'
#' @param prevotella_adjust An option to convert OTUs mapped to prevotella_7 & prevotella_9 genus to be relabeled as prevotella genus
#' @param lact_adjust Will adjust the classification of OTUs mapped to some Lactobacillus species. Reads mapped to Lactibacillus_acidophilus,
#' Lactobacillus_casei, or Lactobacillus_gallinarium will be reclassified as Lactobacillus_crispatus. Lactobacillus_fornicalis will be
#' reclassified as Lactobacillus_jensenii.
#' @return Returns a dataframe that is formated for Valencia analysis using the Valencia function.
#'@import tidyr
#'@import dplyr
#'@import phyloseq
#'@importFrom utils read.csv
#'@import tidyselect
#'@importFrom magrittr %>%
#'@import tibble
#'@examples
#'
#' ## Running conversion script on a non-agglommerated phyloseq object
#' \dontrun{valencia_input_df<-phy_to_val(ps)}
#'
#' @export
phy_to_val <- function(ps_object, gard_adjust = F, prevotella_adjust = F, lact_adjust = F) {
    ## Getting Total Sample count
  total_count_df <- sample_sums(ps_object) %>% as.data.frame() %>% tibble::rownames_to_column("Sample") %>% dplyr::rename("read_count" = ".")

## Loading in Reference Data
 centriod_file_path <- system.file( "CST_centroids_012920.csv", package = "ValenciaInR")
 centroids <- read.csv(centriod_file_path)

  ## Fixing taxonomic classification names to be compatible with Valencia
  valencia_tax_prep <- tax_table(ps_object) %>% as.matrix() %>% as.data.frame() %>%
    dplyr:: mutate(Species = paste(Genus, "_", Species, sep =""),
            Species = dplyr::case_when( grepl("_NA", Species) ~ paste("g_", Species, sep = ""), .default = Species),
            Species = dplyr::case_when(grepl("g_NA_NA", Species) ~ paste("f_", Family, sep = ""), .default = Species),
            Species = dplyr::case_when(grepl("f_NA_NA", Species) ~ paste("o_", Order, sep = ""), .default = Species),
            Species = gsub('_NA','',Species))


## Lactobacillus Adjust
lact_crispatus_vec <- c("Lactobacillus_acidophilus", "Lactobacillus_casei", "Lactobacillus_gallinarum")
### Possible additions for Lact gasseri: hominis, johnsonii
### Possible additions for jensenii: mulieris
if(lact_adjust == T) {
  valencia_tax_prep <- valencia_tax_prep %>%
    dplyr::mutate(Species = replace(Species, Species %in% lact_crispatus_vec , "Lactobacillus_crispatus"),
                  Species = replace(Species, Species == "Lactobacillus_fornicalis" , "Lactobacillus_jensenii")
                  #Species = replace(Species, Species == "Lactobacillus_johnsonii" , "Lactobacillus_gasseri"))
                   )
}

## re-glomming all species level classifications that are not in the Valencia database to genus level
valencia_tax_prep <- valencia_tax_prep %>%
  mutate(Species = dplyr::case_when(!Species %in% colnames(centroids) ~  paste("g_", Genus, sep = ""), .default = Species))


  if( gard_adjust == T) {
    valencia_tax_prep <- valencia_tax_prep %>%
      dplyr::mutate(Species = replace(Species, Species == "g_Gardnerella", "Gardnerella_vaginalis"))
  }

  if(prevotella_adjust == T ) {
    valencia_tax_prep <- valencia_tax_prep %>%
      dplyr::mutate(Species = replace(Species, Species == "g_Prevotella_9", "g_Prevotella"),
             Species = replace(Species, Species == "g_Prevotella_7", "g_Prevotella"),
             Genus = replace(Genus, Genus == "Prevotella_7", "Prevotella"),
             Genus = replace(Genus, Genus == "Prevotella_9", "Prevotella"))
  }

## converting taxonomy table back to a matrix
  valencia_tax_prep_mat <- valencia_tax_prep %>% as.matrix()

  # adding compatible taxonomic classification to phyloseq object
  valencia_ps_prep <- ps_object
  tax_table(valencia_ps_prep) <- valencia_tax_prep_mat

  ##Glomming to Lowest level
  valencia_ps_prep_glom <-  tax_glom(valencia_ps_prep, taxrank = "Species")
  # Making Valencia Input File
  valencia_df <- valencia_ps_prep_glom %>% psmelt() %>% dplyr::select(Sample, Abundance, Species) %>%
    tidyr::pivot_wider(names_from = "Species", values_from = "Abundance") %>% dplyr::left_join(total_count_df, by ="Sample") %>%
    dplyr::select(Sample, read_count, tidyselect::everything()) %>% dplyr::rename(sampleID = Sample)

  ## Checking what doesnt match
  not_matched <- colnames(valencia_df[!colnames(valencia_df) %in% colnames(centroids)])
  not_matched <- not_matched[-1:-2]

  return(valencia_df)
message(paste( "Does not match Valencia taxa:", not_matched, "\n"))
}





