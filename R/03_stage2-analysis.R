# ==================================================================
# Stage 2 analysis
# Non-parametric survival analysis
# ==================================================================

# ------------------------------------------------------------------
# Reverse Kaplan–Meier method & Overall survival 
# ------------------------------------------------------------------

followup_fit <- survival::survfit(
  Surv(dtime_yrs, 1- death) ~ 1,
  data = dt
)

followup_tab <- summary(followup_fit)$table

followup <- list()
followup$median = followup_tab[7]
followup$lower = followup_tab[8]
followup$upper = followup_tab[9]

km_overall_fit <- survival::survfit(
  Surv(dtime_yrs, death) ~ 1,
  data = dt
)

km_overall_tab <- summary(km_overall_fit)$table

km_overall <- list()  
km_overall$median = km_overall_tab[7]  
km_overall$lower = km_overall_tab[8]  
km_overall$upper = km_overall_tab[9]  

km_n_deaths <- unname(km_overall_tab["events"])

cohort_survival_dt <- data.table::data.table(
  Measure = c("Median potential follow-up",
              "Median overall survival"),
  Estimate = c(followup$median,
               km_overall$median),
  lower = c(followup$lower,
            km_overall$lower),
  upper = c(followup$upper,
            km_overall$upper)
)


# ------------------------------------------------------------------
# Kaplan–Meier curves for survival probabilities
# ------------------------------------------------------------------

km_overall_summary <- summary(km_overall_fit) # overall survival

km_overall_dt <- data.table::data.table(
  time = km_overall_summary$time,
  survival = km_overall_summary$surv,
  lower = km_overall_summary$lower,
  upper = km_overall_summary$upper,
  risk = km_overall_summary$n.risk
)

# Survival by groups
km_chemo_fit <- survfit(
  Surv(dtime_yrs, death) ~ chemo_f,
  data = dt
)
km_chemo_summary <- summary(km_chemo_fit)



# ------------------------------------------------------------------
# Landmark survival probabilities
# ------------------------------------------------------------------

times <- c(1, 5, 10, 15)

# Extract landmark estimates fnc
get_landmarks <- function(fit, overall = FALSE) {
  x <- summary(fit, times = times, extend = TRUE)
  
  data.table(
    Years = x$time,
    Group = if (overall) {
      "Overall"
    } else {
      sub("^chemo_f=", "", x$strata)
    },
    Survival = x$surv,
    Lower = x$lower,
    Upper = x$upper,
    At_risk = x$n.risk
  )
}

landmarks <- rbindlist(list(
  get_landmarks(km_overall_fit, overall = TRUE),
  get_landmarks(km_chemo_fit)
))[
  , Estimate := sprintf(
    "%.1f%%  \n[%.1f–%.1f]",
    100 * Survival,
    100 * Lower,
    100 * Upper
  )
]


# Reshape 
landmarks_tab <- dcast(
  landmarks,
  Years ~ Group,
  value.var = c("Estimate", "Survival", "At_risk")
)[
  , Difference := 100 * (
    Survival_Chemotherapy -
      `Survival_No chemotherapy`
  )
][
  , .(
    Years,
    Overall = Estimate_Overall,
    Overall_risk = At_risk_Overall,
    No_chemo = `Estimate_No chemotherapy`,
    No_chemo_risk = `At_risk_No chemotherapy`,
    Chemotherapy = Estimate_Chemotherapy,
    Chemo_risk = At_risk_Chemotherapy,
    Difference
  )
]

over_surv <- list()
over_surv$surv1 <- landmarks[Group == "Overall" & Years == 1, Survival]
over_surv$surv5 <- landmarks[Group == "Overall" & Years == 5, Survival]
over_surv$surv10 <- landmarks[Group == "Overall" & Years == 10, Survival]
over_surv$surv15 <- landmarks[Group == "Overall" & Years == 15, Survival]


# ------------------------------------------------------------------
# Median survival by treatment status
# ------------------------------------------------------------------

median_table <- summary(km_chemo_fit)$table

median_chemo_dt <- data.table(
  Group = sub(
    "^chemo_f=",
    "",
    rownames(median_table)
  ),
  N = as.integer(median_table[, "records"]),
  Deaths = as.integer(median_table[, "events"]),
  Median = median_table[, "median"],
  Lower = median_table[, "0.95LCL"],
  Upper = median_table[, "0.95UCL"]
)

# ------------------------------------------------------------------
#  Log-rank comparison
# ------------------------------------------------------------------
logrank <- survdiff(
  Surv(dtime_yrs, death) ~ chemo_f,
  data = dt
)

logrank_p <- pchisq(
  logrank$chisq,
  df = length(logrank$n) - 1,
  lower.tail = FALSE
)

logrank_dt <- data.table(
  Test = "Log-rank test",
  Chi_square = unname(logrank$chisq),
  df = length(logrank$n) - 1,
  p_value = logrank_p
)


# ------------------------------------------------------------
# Stage 2 report objects specifics
# ------------------------------------------------------------

# KM-curves (overall)

overall_km_report_plot <- ggsurvfit(
  km_overall_fit,
  linewidth = 0.7,
  colour = "black"
) +
  add_confidence_interval(
    fill = "#2C7FB8",
    alpha = 0.15
  ) +
  
  scale_x_continuous(
    breaks = seq(0, 18, 3),
    limits = c(0, 18)
  ) +
  scale_y_continuous(
    breaks = seq(0, 1, 0.25),
    labels = scales::label_percent(),
    limits = c(0, 1)
  ) +
  labs(
    title = "Overall survival trajectory",
    x = "Time since baseline (years)",
    y = "Survival probability"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 12),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),   
    axis.line = element_line(colour = "black", linewidth = 0.5), 
    legend.position = "none"
  )

ggsave(
  filename = file.path(
    directory$figures_stage(2),
    "report-km-overall.png"
  ),
  plot = overall_km_report_plot,
  width = 7,
  height = 4.7,
  dpi = 300
)

# KM-CURVE (treatment arm)
cols <- c("#0072B2", "#D55E00")
p1 <- ggsurvfit(km_chemo_fit, linewidth = 0.8) +
  add_confidence_interval(alpha = 0.12) +
  scale_colour_manual(values = cols) +
  scale_fill_manual(values = cols) +
  coord_cartesian(xlim = c(0, 18), ylim = c(0, 1)) +
  scale_x_continuous(breaks = seq(0, 18, 3)) +
  scale_y_continuous(
    breaks = seq(0, 1, 0.25),
    labels = scales::label_percent()
  ) +
  labs(
    title = "Survival by chemotherapy status",
    x = "Time since baseline (years)",
    y = "Survival probability",
    colour = NULL,
    fill = NULL
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    axis.line = element_line(colour = "black", linewidth = 0.5), 
    legend.position = "bottom"
  )

ggsave(
  filename = file.path(
    directory$figures_stage(2),
    "report-km-chemo.png"
  ),
  plot = p1,
  width = 7,
  height = 4.7,
  dpi = 300
)


# Landmark survival estimates
times <- c(1, 5, 10, 15)
km_chemo_summary_lm <- summary(km_chemo_fit,
                               times = times,
                               extend = TRUE)



km_chemo_dt <- data.table::data.table(
  Landmark = paste(km_chemo_summary_lm$time, ifelse(km_chemo_summary_lm$time == 1, "year", "years")),
  Group = sub("^chemo_f=", "", km_chemo_summary_lm$strata),
  Estimate = sprintf("%.1f%%", 100 * km_chemo_summary_lm$surv)
) |>
  dcast(Landmark ~ Group, value.var = "Estimate")

# Median survival estimates
med <- setNames(
  median_chemo_dt$Median,
  median_chemo_dt$Group
)

km_chemo_dt <- rbind(
  km_chemo_dt,
  data.table(
    Landmark = "Median",
    `No chemotherapy` = sprintf("%.2f y", med[["No chemotherapy"]]),
    Chemotherapy = sprintf("%.2f y", med[["Chemotherapy"]])
  )
)

# Arrange landmarks correctly
km_chemo_dt[
  , Landmark := factor(
    Landmark,
    levels = c("1 year", "5 years", "10 years", "15 years", "Median")
  )
]

setorder(km_chemo_dt, Landmark)


