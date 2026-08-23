library(here)

directory <- list()

# Project root
directory$main_path <- here()

# Main assets directory
directory$assets <- file.path(
  directory$main_path,
  "assets"
)

# Main output directories
directory$figures <- file.path(
  directory$assets,
  "figures"
)

directory$tables <- file.path(
  directory$assets,
  "tables"
)

# Functions returning stage-specific directories
directory$figures_stage <- function(stage_number) {
  file.path(
    directory$figures,
    paste0("stage-", stage_number)
  )
}

directory$tables_stage <- function(stage_number) {
  file.path(
    directory$tables,
    paste0("stage-", stage_number)
  )
}

# Create main folders
dir.create(
  directory$assets,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  directory$figures,
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  directory$tables,
  recursive = TRUE,
  showWarnings = FALSE
)

# Create stage folders
for (i in 1:4) {
  
  dir.create(
    directory$figures_stage(i),
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  dir.create(
    directory$tables_stage(i),
    recursive = TRUE,
    showWarnings = FALSE
  )
}