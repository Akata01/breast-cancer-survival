# ============================================================
# Data preparation
# Rotterdam Tumor Bank breast cancer survival project
# ============================================================

# Load source data distributed with the survival package
data("rotterdam", package = "survival")

# Work with a data.table copy so the package dataset is preserved
dt <- data.table::as.data.table(data.table::copy(rotterdam))

# Follow-up time in years
dt[, dtime_yrs := dtime / 365.25]
dt[, rtime_yrs := rtime / 365.25]

# Labelled variables used throughout the analysis
dt[, chemo_f := factor(
  chemo,
  levels = c(0, 1),
  labels = c("No chemotherapy", "Chemotherapy")
)]

dt[, meno_f := factor(
  meno,
  levels = c(0, 1),
  labels = c("Premenopausal", "Postmenopausal")
)]

dt[, grade_f := factor(
  grade,
  levels = c(2, 3),
  labels = c("Grade 2", "Grade 3")
)]

dt[, hormon_f := factor(
  hormon,
  levels = c(0, 1),
  labels = c("No hormonal therapy", "Hormonal therapy")
)]

dt[, size_f := factor(
  size,
  levels = c("<=20", "20-50", ">50"),
  labels = c("≤20 mm", "20–50 mm", ">50 mm")
)]
