# ============================================================
# Stage 1 analysis
# Cohort characterization and treatment selection
# ============================================================

# ------------------------------------------------------------
# Headline cohort metrics
# ------------------------------------------------------------

stage1_metrics <- list(
  n_patients = nrow(dt),
  n_unique_pid = data.table::uniqueN(dt$pid),
  n_chemo = sum(dt$chemo == 1),
  prop_chemo = mean(dt$chemo == 1),
  n_hormonal = sum(dt$hormon == 1),
  prop_hormonal = mean(dt$hormon == 1),
  n_deaths = sum(dt$death == 1),
  prop_deaths = mean(dt$death == 1),
  n_recurrences = sum(dt$recur == 1),
  prop_recurrences = mean(dt$recur == 1),
  median_age = median(dt$age),
  median_observed_followup = median(dt$dtime_yrs)
)

# ------------------------------------------------------------
# Data-quality assessment
# ------------------------------------------------------------

missing_by_variable <- dt[
  ,
  lapply(.SD, function(x) sum(is.na(x)))
]

quality_summary <- data.table::data.table(
  Check = c(
    "Patient records",
    "Unique patient identifiers",
    "Duplicated patient identifiers",
    "Total missing values",
    "Variables with any missing values",
    "Invalid death indicators",
    "Invalid recurrence indicators",
    "Non-positive mortality follow-up times",
    "Non-positive recurrence follow-up times"
  ),
  Result = c(
    nrow(dt),
    data.table::uniqueN(dt$pid),
    sum(duplicated(dt$pid)),
    sum(unlist(missing_by_variable)),
    sum(unlist(missing_by_variable) > 0),
    sum(!dt$death %in% c(0, 1)),
    sum(!dt$recur %in% c(0, 1)),
    sum(dt$dtime <= 0, na.rm = TRUE),
    sum(dt$rtime <= 0, na.rm = TRUE)
  )
)

# ------------------------------------------------------------
# Cohort profile
# ------------------------------------------------------------

cohort_summary <- data.table::data.table(
  Measure = c(
    "Women in cohort",
    "Received chemotherapy",
    "Received hormonal therapy",
    "Deaths observed",
    "Recurrences observed",
    "Median age at incidence",
    "Median observed mortality follow-up"
  ),
  Value = c(
    format(stage1_metrics$n_patients, big.mark = ","),
    sprintf(
      "%s (%.1f%%)",
      format(stage1_metrics$n_chemo, big.mark = ","),
      100 * stage1_metrics$prop_chemo
    ),
    sprintf(
      "%s (%.1f%%)",
      format(stage1_metrics$n_hormonal, big.mark = ","),
      100 * stage1_metrics$prop_hormonal
    ),
    sprintf(
      "%s (%.1f%%)",
      format(stage1_metrics$n_deaths, big.mark = ","),
      100 * stage1_metrics$prop_deaths
    ),
    sprintf(
      "%s (%.1f%%)",
      format(stage1_metrics$n_recurrences, big.mark = ","),
      100 * stage1_metrics$prop_recurrences
    ),
    sprintf("%.0f years", stage1_metrics$median_age),
    sprintf("%.1f years", stage1_metrics$median_observed_followup)
  )
)

# ------------------------------------------------------------
# Baseline standardized mean differences
# ------------------------------------------------------------

baseline_vars <- c(
  "age",
  "meno_f",
  "size_f",
  "grade_f",
  "nodes",
  "pgr",
  "er",
  "year"
)

factor_vars <- c(
  "meno_f",
  "size_f",
  "grade_f"
)

table1_smd <- tableone::CreateTableOne(
  vars = baseline_vars,
  strata = "chemo_f",
  data = dt,
  factorVars = factor_vars,
  test = FALSE
)

smd_matrix <- tableone::ExtractSmd(table1_smd)

smd_dt <- data.table::data.table(
  variable = rownames(smd_matrix),
  smd = as.numeric(smd_matrix[, 1])
)

smd_lookup <- stats::setNames(smd_dt$smd, smd_dt$variable)

# ------------------------------------------------------------
# Baseline descriptive table data
# ------------------------------------------------------------

fmt_mean_sd <- function(x) {
  sprintf("%.1f (%.1f)", mean(x, na.rm = TRUE), stats::sd(x, na.rm = TRUE))
}

fmt_median_iqr <- function(x) {
  q <- stats::quantile(x, c(0.25, 0.75), na.rm = TRUE)

  sprintf(
    "%.1f [%.1f, %.1f]",
    stats::median(x, na.rm = TRUE),
    q[[1]],
    q[[2]]
  )
}

fmt_n_pct <- function(x) {
  sprintf(
    "%s (%.1f%%)",
    format(sum(x, na.rm = TRUE), big.mark = ","),
    100 * mean(x, na.rm = TRUE)
  )
}

all_dt <- dt
no_dt <- dt[chemo == 0]
yes_dt <- dt[chemo == 1]

baseline_table <- data.table::rbindlist(
  list(
    data.table::data.table(
      Characteristic = "Age, years — mean (SD)",
      Overall = fmt_mean_sd(all_dt$age),
      `No chemotherapy` = fmt_mean_sd(no_dt$age),
      Chemotherapy = fmt_mean_sd(yes_dt$age),
      SMD = unname(smd_lookup["age"])
    ),
    data.table::data.table(
      Characteristic = "Postmenopausal, n (%)",
      Overall = fmt_n_pct(all_dt$meno == 1),
      `No chemotherapy` = fmt_n_pct(no_dt$meno == 1),
      Chemotherapy = fmt_n_pct(yes_dt$meno == 1),
      SMD = unname(smd_lookup["meno_f"])
    ),
    data.table::data.table(
      Characteristic = "Tumour size: ≤20 mm, n (%)",
      Overall = fmt_n_pct(all_dt$size == "<=20"),
      `No chemotherapy` = fmt_n_pct(no_dt$size == "<=20"),
      Chemotherapy = fmt_n_pct(yes_dt$size == "<=20"),
      SMD = unname(smd_lookup["size_f"])
    ),
    data.table::data.table(
      Characteristic = "Tumour size: 20–50 mm, n (%)",
      Overall = fmt_n_pct(all_dt$size == "20-50"),
      `No chemotherapy` = fmt_n_pct(no_dt$size == "20-50"),
      Chemotherapy = fmt_n_pct(yes_dt$size == "20-50"),
      SMD = NA_real_
    ),
    data.table::data.table(
      Characteristic = "Tumour size: >50 mm, n (%)",
      Overall = fmt_n_pct(all_dt$size == ">50"),
      `No chemotherapy` = fmt_n_pct(no_dt$size == ">50"),
      Chemotherapy = fmt_n_pct(yes_dt$size == ">50"),
      SMD = NA_real_
    ),
    data.table::data.table(
      Characteristic = "Grade 3 tumour, n (%)",
      Overall = fmt_n_pct(all_dt$grade == 3),
      `No chemotherapy` = fmt_n_pct(no_dt$grade == 3),
      Chemotherapy = fmt_n_pct(yes_dt$grade == 3),
      SMD = unname(smd_lookup["grade_f"])
    ),
    data.table::data.table(
      Characteristic = "Positive lymph nodes — median [IQR]",
      Overall = fmt_median_iqr(all_dt$nodes),
      `No chemotherapy` = fmt_median_iqr(no_dt$nodes),
      Chemotherapy = fmt_median_iqr(yes_dt$nodes),
      SMD = unname(smd_lookup["nodes"])
    ),
    data.table::data.table(
      Characteristic = "Progesterone receptor — median [IQR]",
      Overall = fmt_median_iqr(all_dt$pgr),
      `No chemotherapy` = fmt_median_iqr(no_dt$pgr),
      Chemotherapy = fmt_median_iqr(yes_dt$pgr),
      SMD = unname(smd_lookup["pgr"])
    ),
    data.table::data.table(
      Characteristic = "Estrogen receptor — median [IQR]",
      Overall = fmt_median_iqr(all_dt$er),
      `No chemotherapy` = fmt_median_iqr(no_dt$er),
      Chemotherapy = fmt_median_iqr(yes_dt$er),
      SMD = unname(smd_lookup["er"])
    ),
    data.table::data.table(
      Characteristic = "Year of cancer incidence — mean (SD)",
      Overall = fmt_mean_sd(all_dt$year),
      `No chemotherapy` = fmt_mean_sd(no_dt$year),
      Chemotherapy = fmt_mean_sd(yes_dt$year),
      SMD = unname(smd_lookup["year"])
    )
  ),
  use.names = TRUE,
  fill = TRUE
)

# ------------------------------------------------------------
# Chemotherapy use over calendar time
# ------------------------------------------------------------

chemo_by_year <- dt[
  ,
  .(
    n = .N,
    chemo_n = sum(chemo == 1),
    chemo_pct = mean(chemo == 1)
  ),
  by = year
]

data.table::setorder(chemo_by_year, year)

# ------------------------------------------------------------
# Hormonal co-treatment patterns
# ------------------------------------------------------------

hormone_table <- dt[
  ,
  .(
    Patients = .N,
    `Hormonal therapy, n` = sum(hormon == 1),
    `Hormonal therapy, %` = mean(hormon == 1)
  ),
  by = chemo_f
]

# Remove intermediate objects that are not needed
rm(missing_by_variable, all_dt, no_dt, yes_dt)





# ------------------------------------------------------------
# Stage 1 report objects Specifics
# ------------------------------------------------------------

stage1_imbalance <- data.table::copy(smd_dt)

imbalance_labels <- c(
  age = "Age",
  meno_f = "Menopausal status",
  nodes = "Positive lymph nodes",
  er = "Estrogen receptor",
  size_f = "Tumour size",
  pgr = "Progesterone receptor",
  year = "Year of incidence",
  grade_f = "Tumour grade"
)

stage1_imbalance[
  ,
  label := unname(imbalance_labels[variable])
]

stage1_imbalance[
  ,
  abs_smd := abs(smd)
]

# Fixed visual scale so bar lengths have a common meaning
smd_display_max <- 1.25

stage1_imbalance[
  ,
  bar_pct := pmin(
    100 * abs_smd / smd_display_max,
    100
  )
]

setorder(
  stage1_imbalance,
  -abs_smd
)


# Selected baseline characteristics for the portfolio table

stage1_selected <- rbindlist(
  list(
    data.table(
      Characteristic = "Sample size",
      No_chemo = format(
        sum(dt$chemo == 0),
        big.mark = ","
      ),
      Chemo = format(
        sum(dt$chemo == 1),
        big.mark = ","
      )
    ),
    
    baseline_table[
      Characteristic == "Age, years — mean (SD)",
      .(
        Characteristic = "Age, mean (SD)",
        No_chemo = `No chemotherapy`,
        Chemo = Chemotherapy
      )
    ],
    
    baseline_table[
      Characteristic == "Postmenopausal, n (%)",
      .(
        Characteristic = "Postmenopausal",
        No_chemo = `No chemotherapy`,
        Chemo = Chemotherapy
      )
    ],
    
    baseline_table[
      Characteristic == "Positive lymph nodes — median [IQR]",
      .(
        Characteristic = "Positive lymph nodes, median [IQR]",
        No_chemo = `No chemotherapy`,
        Chemo = Chemotherapy
      )
    ],
    
    baseline_table[
      Characteristic == "Estrogen receptor — median [IQR]",
      .(
        Characteristic = "Estrogen receptor, median [IQR]",
        No_chemo = `No chemotherapy`,
        Chemo = Chemotherapy
      )
    ]
  ),
  use.names = TRUE
)
