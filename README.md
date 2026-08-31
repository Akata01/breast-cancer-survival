# Breast Cancer Survival Analysis

## Rotterdam Tumor Bank: Prognostic Factors, Treatment Selection, and Survival Outcomes

This project develops a reproducible survival-analysis workflow using the **Rotterdam Tumor Bank** breast cancer dataset distributed with the R `survival` package.

The analysis focuses on overall survival among women with primary breast cancer, with particular attention to **baseline prognostic factors, treatment selection, and the observed association between chemotherapy and survival**. Because chemotherapy was not randomly assigned in this observational cohort,the project carefully distinguishes between descriptive treatment-group differences,
unadjusted survival comparisons, and later covariate-adjusted analyses.

The project is built in R + Quarto + HTML/SCSS and developed progressively in four analytical stages.

---

## Research questions

1. What are the baseline demographic and clinical characteristics of women in the Rotterdam breast cancer cohort?
2. How do women who received chemotherapy differ from those who did not at baseline?
3. What are the overall and chemotherapy-stratified survival patterns in the cohort?
4. How does the chemotherapy-survival association change after adjustment for measured prognostic factors?
5. Which patient and tumour characteristics are most strongly associated with mortality?
6. Are the findings robust across alternative survival models and estimands?

---

## Data

The Rotterdam Tumor Bank dataset contains **2,982 women** with primary breast cancer and 15 variables covering patient characteristics, tumour characteristics, receptor status, treatment, recurrence follow-up, and mortality follow-up.

The data are available directly through the R `survival` package, so no external dataset download is required.

```r
library(survival)
data("rotterdam", package = "survival")
```

### Primary analysis variables

| Role | Variables |
|---|---|
| Primary exposure | `chemo` |
| Primary survival outcome | `dtime`, `death` |
| Baseline covariates | `year`, `age`, `meno`, `size`, `grade`, `nodes`, `pgr`, `er` |
| Co-treatment / sensitivity variable | `hormon` |
| Secondary recurrence outcome | `rtime`, `recur` |
| Identifier | `pid` |

---

## Project workflow

The analysis is developed as one evolving Quarto project rather than as four separate reports.

### Stage 1 — Cohort characterization and treatment selection ✅

- cohort definition and variable roles;
- data-quality checks;
- descriptive cohort profile;
- baseline characteristics by chemotherapy status;
- standardized mean differences;
- covariate-balance visualization;
- chemotherapy use over calendar time; and
- hormonal co-treatment patterns.

### Stage 2 — Non-parametric survival analysis ✅

- potential follow-up using the reverse Kaplan–Meier estimator;
- overall Kaplan–Meier survival;
- median overall survival;
- landmark survival probabilities;
- chemotherapy-stratified Kaplan–Meier curves; and
- log-rank comparison of unadjusted survival distributions.

### Stage 3 — Multivariable survival modelling

- Cox proportional-hazards modelling;
- adjustment for measured baseline prognostic factors;
- estimation of adjusted hazard ratios;
- assessment of proportional-hazards assumptions; and
- investigation of functional form and model specification.

### Stage 4 — Robustness and model extensions

- sensitivity analyses;
- alternative model specifications;
- assessment of co-treatment;
- alternative survival estimands where appropriate; and
- synthesis of findings across analytical approaches.

---

## Project structure

```text
breast_cancer_survival/
├── breast_cancer_survival.qmd      # Technical analytical report
├── breast_cancer_survival.Rproj
├── README.md
├── .gitignore
├── renv.lock
│
├── R/
│   ├── 01_data-preparation.R       # Shared data preparation
│   ├── 02_stage1-analysis.R        
│   └── 03_stage2-analysis.R        
│
├── parameters/
│   └── directories.R               # Central path configuration
│
├── reports/
│   ├── report.qmd                  # Portfolio report
│   └── report.scss                 # Report design system
│
├── assets/
│   ├── figures/
│   │   ├── stage-1/
│   │   ├── stage-2/
│   │   ├── stage-3/
│   │   └── stage-4/
│   └── tables/
│       ├── stage-1/
│       ├── stage-2/
│       ├── stage-3/
│       └── stage-4/
│
└── index.html
```

### Directory management

Project paths are defined centrally in:

```text
parameters/directories.R
```

This avoids hard-coded file paths throughout the Quarto report and keeps output locations consistent as the project grows.

The script defines the project root, the main `assets/` directory, figure and table output directories, and stage-specific helper functions for saving outputs.

For example:

```r
directory$figures_stage(1)
directory$tables_stage(1)
```

---

### Analysis architecture

The project separates statistical computation from reporting and presentation.

Shared analytical code is stored in the `R/` directory. Data preparation is performed in `01_data-preparation.R`, while stage-specific scripts contain the analytical codes required for each stage.

The `breast_cancer_survival.qmd` document serves as the **technical analytical report**, documenting the study design, methods, diagnostics, results, and interpretation.

A separate portfolio report in `reports/report.qmd` uses the same underlying analytical objects but presents selected findings in a more concise, reader-focused format. Its visual design is controlled through `reports/report.scss`.

---

## Stage 1 findings

The baseline analysis shows substantial treatment-group imbalance.

| Characteristic | Absolute SMD |
|---|---:|
| Age | 1.235 |
| Menopausal status | 1.198 |
| Positive lymph nodes | 0.415 |
| Estrogen receptor level | 0.362 |
| Tumour size | 0.160 |
| Progesterone receptor level | 0.072 |
| Year of cancer incidence | 0.012 |
| Tumour grade | 0.002 |

Women receiving chemotherapy were markedly younger and substantially less likely to be postmenopausal, but they also had greater lymph-node involvement, somewhat larger tumours, and lower estrogen-receptor levels.

These differences indicate substantial baseline imbalance consistent with **non-random treatment allocation**. 

---

## Data quality management

The Stage 1 data audit identified:

- **2,982 patient records**;
- **2,982 unique patient identifiers**;
- **0 duplicated patient identifiers**;
- **0 missing observations** across the 15 source variables;
- **0 invalid death or recurrence indicators**; and
- **0 non-positive mortality or recurrence follow-up times**.

No imputation or complete-case exclusion is required for the baseline analysis.

---

## Analytical principles

This project follows an observational epidemiologic framework.

The analysis distinguishes between:

1. **cohort description** — who is represented in the data;
2. **treatment selection** — how chemotherapy groups differ at baseline;
3. **unadjusted survival patterns** — how observed survival differs before accounting for baseline characteristics;
4. **covariate-adjusted associations** — how the chemotherapy–survival association changes after adjustment for measured prognostic factors; and
5. **robustness analyses** — whether substantive conclusions are sensitive to modelling choices and assumptions.

---

## Tools and skills demonstrated

- R programming
- `data.table` workflows
- survival analysis with `survival`
- Kaplan–Meier estimation
- reverse Kaplan–Meier estimation
- standardized mean differences
- observational treatment-selection assessment
- `ggplot2` data visualization
- `gt` publication-style tables
- Quarto reproducible reporting
- HTML/SCSS report design
- modular R project architecture
- project path management with `here`
- reproducible environments with `renv`
- Git/GitHub version control

---

## Reproducibility

### 1. Clone the repository

```bash
git clone https://github.com/Akata01/breast-cancer-survival.git
cd breast-cancer-survival
```

### 2. Restore the R environment

This project uses `renv` to record package versions.

```r
install.packages("renv")
renv::restore()
```

Quarto must also be installed.


### 3. Analytical workflow

The shared computational workflow is modularized across:

`R/01_data-preparation.R`
`R/0*_stage*-analysis.R`

These scripts are sourced by the Quarto documents for both technical and portfolio reports.

The project directory configuration is loaded from:

```r
source(
  here::here(
    "parameters",
    "directories.R"
  )
)
```

### 4. Render the analysis

**For the technical analysis:**

```bash
quarto render breast_cancer_survival.qmd
```

The rendered technical analysis is written to:

```bash
index.html
```

**For the portfolio report:**

```bash
quarto render report.qmd
```
or open the `.qmd` file in RStudio and click **Render**.

This document presents selected findings in a more concise research-report format.

Its design is controlled through:
```bash
report.scss
```
---



## Output management

Important reusable outputs are saved separately under the relevant stage folders, for example:

```text
assets/figures/stage-*/
assets/tables/stage-*/
```

Equivalent folders are reserved for later analytical stages. This keeps the repository organized without treating exported figures and tables as substitutes for the reproducible Quarto workflow.

---

## Author

**Rabbi Tweneboah**


---

## Project status

## Project status

**Stage 1 complete — cohort characterization and baseline treatment-selection analysis.**

**Stage 2 complete — non-parametric survival analysis.**

The next stage will focus on **multivariable survival modelling**, including Cox proportional-hazards models, covariate adjustment, estimation of adjusted associations, and model diagnostics.