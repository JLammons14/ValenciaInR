#' @title Valencia CST Classification
#' @description Valencia will analyze vaginal microbiome data to obtain CST classification
#' @param input_df  A dataframe of bacterial count data that is in the proper format for Valencia analysis.
#' The first and second column will need to be titled sampleID, read_counts. All following column names must be formatted to fit
#' Valencia reference database naming convention.
#'
#' @import reticulate
#'
#' @return Returns a data frame with CST classifications and confidence scores for each sample
#'

#' @export

## Complete Script
Valencia <- function (input_df ) {

  install_dependencies <- function(..., envname = "R-valencia" ) {
    py_install(packages = c("pandas","numpy"), envname = envname, ...)
  }

  .onLoad <- function(...) {
    use_virtualenv("R-valencia", required = FALSE)
  }

  ## Setting up python virtual environment to Run Valencia
  virtualenv_create("R-valencia")
  ## Install virtual env and dependencies
  install_dependencies(envname = "R-valencia")
  ## Add Python Virtual Env
  use_virtualenv("R-valencia")

  ## Paths for Valcencia script and reference database
  centriod_file_path <- system.file( "CST_centroids_012920.csv", package = "ValenciaTest2")
  valencia_file_path <- system.file( "val_code.py", package = "ValenciaTest2")

  ## Load reference dataframe
  centroid_df <- read.csv(centriod_file_path)

  ### selecting code
  reticulate::source_python(valencia_file_path)

  ##converting R datframes to pandas dataframe
  input_pandas_df <- r_to_py(input_df)
  reference_centroids <- r_to_py(centroid_df)

  ## output from valencia
  CST_results <- Valcencia_CST( input_pandas_df, reference_centroids)
  return(CST_results)
}

#' @examples
#' ## Valencia Analysis
#'
#' \dontrun{CST_output_df <- Valencia(input_df)}
#'
