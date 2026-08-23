# Breast Cancer Survival Analysis

## Rotterdam Tumor Bank: Prognostic Factors, Treatment Selection, and Survival Outcomes

This project develops a reproducible survival-analysis workflow using the **Rotterdam Tumor Bank** breast cancer dataset distributed with the R `survival` package.

The analysis focuses on overall survival among women with primary breast cancer, with particular attention to **baseline prognostic factors, treatment selection, and the observed association between chemotherapy and survival**. Because chemotherapy was not randomly assigned in this observational cohort, the project aim to distinguishes carefully between descriptive treatment-group differences, unadjusted survival comparisons, and later covariate-adjusted analyses.

The project is built in **R + Quarto** and developed progressively in four analytical stages.

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

### Stage 2 — Non-parametric survival analysis

- overall Kaplan-Meier survival;

---

## Project structure

```text
breast_cancer_survival/
├── breast_cancer_survival.qmd
├── breast_cancer_survival.Rproj
├── README.md
├── .gitignore
├── renv.lock
│
├── parameters/
│   └── directories.R
│
├── assets/
│   ├── figures/
│   │   ├── stage-1/
│   │   ├── stage-2/
│   │   ├── stage-3/
│   │   └── stage-4/
│   │
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

Selected figures and tables that are useful outside the rendered report are exported to the appropriate stage subfolder. The Quarto document remains the primary reproducible analysis, while the `assets/` directory stores important reusable outputs for GitHub, portfolio presentation, and future reporting.

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

The analysis separates:

1. **cohort description** — who is represented in the data;
2. **treatment selection** — how chemotherapy groups differ at baseline;
3.

---

## Tools and skills demonstrated

- R programming
- `data.table`
- Quarto reproducible reporting
- `gt` publication-style tables
- `ggplot2` data visualization
- project path management with `here`
- reproducible environments with `renv`
- epidemiologic cohort characterization
- standardized mean differences
- treatment-selection assessment

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

### 3. Render the analysis

```bash
quarto render breast_cancer_survival.qmd
```

or open the `.qmd` file in RStudio and click **Render**.

The project directory configuration is loaded from:

```r
source(here::here("parameters", "directories.R"))
```

---

## Output management

The full analysis is rendered from `breast_cancer_survival.qmd`.

Important reusable outputs are saved separately under the relevant stage folders, for example:

```text
assets/figures/stage-1/
assets/tables/stage-1/
```

Equivalent folders are reserved for later analytical stages. This keeps the repository organized without treating exported figures and tables as substitutes for the reproducible Quarto workflow.

---

## Author

**Rabbi Tweneboah**


---

## Project status

**Stage 1 complete — cohort characterization and baseline treatment-selection analysis.**

The next stage will focus on **Kaplan-Meier estimation**
