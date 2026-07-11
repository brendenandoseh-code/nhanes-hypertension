# What Drives High Blood Pressure? Lifestyle Factors in U.S. Adults

**Author:** Brenden Andoseh · [LinkedIn](https://www.linkedin.com/in/brenden-andoseh-189484177/)
**Stack:** Python (pandas · statsmodels · samplics) · R (`survey`) · Jupyter
**Data:** [CDC NHANES 2017–March 2020](https://wwwn.cdc.gov/nchs/nhanes/) — 7,921 U.S. adults aged 18–80, nine survey files (blood pressure, body measures, diet, physical activity, sleep)

> NHANES isn't a simple random sample, so most of the effort here went into getting the statistics honest rather than into the regression itself: adjusting for age before trusting any association, then applying the survey design weights and checking the headline numbers against R's `survey` package.

---

## Business problem
High blood pressure is common and serious, but much of the risk is tied to **modifiable** habits. Which everyday lifestyle factors are most strongly linked to hypertension in U.S. adults — and which are realistic prevention targets? Audience: public-health teams, workplace-wellness owners, and preventive-care leaders.

## The data
Nine NHANES 2017–March 2020 files merged into one analytic dataset of **7,921 adults**. Hypertension is defined from measured blood-pressure readings; predictors cover physical activity (vigorous/moderate), BMI and waist circumference, sleep duration and trouble sleeping, age, and sex.

## Method
1. **Build & validate** — merge the nine files, define the outcome, catch encoding/sentinel issues (e.g. a SAS export `5.397605e-79` decoded to `NaN`).
2. **Describe** — rank each factor's crude association, then break hypertension rates down by group.
3. **Adjust** — a multivariable **logistic regression** reporting each factor's odds ratio *holding age and sex constant* (the crucial step — older adults exercise less *and* have more hypertension, so raw gaps overstate effects).
4. **Project nationally** — apply NHANES survey weights (strata + PSUs + `WTMEC2YR`) via `samplics` (Taylor linearization) for design-correct rates with 95% CIs.
5. **Confirm** — refit the exact model in R's gold-standard `survey` package (`svy_logistic.R`) for design-based inference; the notebook calls it via `conda run` and **degrades gracefully if R is absent**.

## Key findings *(real NHANES figures)*

**1. Vigorous activity is the standout modifiable factor.** The crude 23-point activity gap shrinks once age is accounted for, but a real, significant association with lower odds remains — **OR ≈ 0.74** (95% CI 0.65–0.84, *p* < .001) in the age- and sex-adjusted **unweighted** model; the survey-weighted Python model and R's design-based model both put it at **≈ 0.68** (see finding 4).

**2. What survives age-adjustment vs. what doesn't.** *(unweighted, age/sex-adjusted model)*

| Factor | Adjusted odds ratio | Verdict |
|---|---|---|
| Vigorous activity | **0.74** (0.65–0.84) | Associated with lower odds — most robust modifiable finding |
| Trouble sleeping | **1.52** (1.36–1.71) | Independently associated with higher odds |
| BMI (per unit) | **1.06** | ~6% higher odds per unit |
| Age (per year) | **1.06** | Dominant, compounds across decades |
| Sleep *duration* | ≈ 1.00 (*p* > 0.8) | **Not** significant once age-adjusted |
| Moderate activity | ≈ 1.00 (*p* > 0.8) | **Not** significant once age-adjusted |

Short sleep *length* and moderate activity looked important in the raw comparisons, but most of that turned out to be **age confounding**: once age was in the model, both effects landed on the no-effect line.

**3. The pattern holds nationally.** Survey-weighted, the national hypertension rate comes out to **~50%** (95% CI ~47–52%), below the raw-sample 55% because NHANES over-samples higher-risk groups. The group gaps stay real: vigorous-active vs. inactive (≈33% vs ≈57%) and sleep-trouble vs. none (≈62% vs ≈44%) have non-overlapping confidence intervals.

**4. The estimates hold up across methods.** The unweighted and weighted models agree in direction and statistical conclusion, and the weighted Python model and R's design-based `survey` model match each other (vigorous ≈ 0.68, sleep trouble ≈ 1.59, weight ≈ 1.08). R's confidence intervals come out a little wider, which is what you'd expect from proper survey linearization, but none of the conclusions change.

## Recommendations
- **Prioritize vigorous activity** in prevention messaging — it's the modifiable factor with the strongest age-independent association with lower odds.
- **Treat sleep *quality* (trouble sleeping), not just hours**, as associated with higher odds.
- **Act before midlife** — age shows the steepest climb, so habit change earns the most when started early.

## Honest notes (data caveats)
- **Observational, cross-sectional** — associations, not causation (e.g. a single-day dietary "sodium paradox" reflects reverse causation in 24-hour recall).
- **BMI and waist circumference are collinear** (*r* ≈ 0.91) — only BMI is kept, to avoid variance inflation.
- Raw NHANES data files are **not committed** here; re-download from the CDC link above (2017–March 2020 cycle) to reproduce.

## Reproduce it
```powershell
# Open the notebook and run top-to-bottom:
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.kernel_name=python3 "Hypertension Project.ipynb"
# Optional gold-standard R confirmation (skips itself if R is missing):
#   conda create -n renv -c conda-forge r-base r-survey -y
```

## Files
```
nhanes-hypertension/
├─ README.md                  ← this file
├─ Hypertension Project.ipynb ← full analysis (build → adjust → weight → confirm)
├─ svy_logistic.R             ← R `survey` design-exact refit, called from the notebook
└─ visuals/                   ← exported charts
   ├─ correlation_heatmap.png
   ├─ weighted_rates.png
   ├─ adjusted_odds_ratios.png
   └─ final_plots.png
```
