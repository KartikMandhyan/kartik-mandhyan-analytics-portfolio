# Airline Operating Income: What Drives Profit? (Group Capstone, R)

**Group 8 capstone, IIM Sirmaur EDGE program (six members; names are on the title slide of the deck).**

## Question
Airline profits are small and fragile. Which controllable operating factors (scale, load factor, business model, region) translate into operating income, and by how much?

## Data
- Kaggle: *Global Aviation Industry 2010-2026* (as cited in the report). Not redistributed here; download it from the source and save as `airline_financials.csv`.
- 497 airline-year records, 30 airlines, 5 regions, 2010-2026. Full-year 2026 figures are treated as provisional and excluded from the temporal validation.

## Method (R)
Multiple linear regression (`lm`), dummy encoding (`fastDummies`), 70/30 split (`caTools`), backward elimination (VIF first, then p-value, `car`), block F-tests for categorical variables, Breusch-Pagan test, HC3 and cluster-robust standard errors (`lmtest`, `sandwich`), Cook's Distance, random / grouped / temporal validation, and a stepwise cross-check.

## Key results
- Final model: 4 predictors (passengers carried, load factor, business model, region), R² = 0.635.
- Test MAE $516M vs $827M for a naive baseline (about 38% lower error).
- Load factor is the strongest driver: +$101M operating income per +1 point (p < 0.001), robust to HC3 and cluster-robust corrections.
- Low-cost carriers earn about $494M less than legacy carriers. North American carriers earn about $758M less than the Asia baseline.

## My part
Core contributor across modeling, methodology rationale and presentation (split by task, not by script):
- **Data and modeling (Task 2, with a teammate):** data import, cleaning, dummy encoding, variable selection and model building in R.
- **Methodological rationale (Task 3, with a teammate):** chose operating income as the dependent variable over margin and revenue; excluded revenue and margin (circular), fleet size (multicollinearity, VIF 9.23) and year (p = 0.197); ran backward elimination in a set order and chose manual selection over automated stepwise.
- **Output analysis and validation (Task 4, with a teammate):** interpreted MAE vs baseline, RMSE, split ratios (60/40 to 80/20), grouped and temporal splits.
- **Presentation:** presented slides 4-7 solo, co-presented the Limitations slide, covered the Recommendations slide with a teammate, and defended the dependent-variable choice in faculty Q&A.
- This README does not claim authorship of individual lines of code or of the diagnostics step (HC3, cluster-robust, Cook's Distance), which were part of the group's analysis.

## Files
- `Capstone_Project.R`: full R script
- `Code_and_Output.pdf`: regression tables and diagnostic plots
- `Capstone_Report.pdf`: 17-page report
- `Capstone_Presentation.pptx`: 16-slide deck

## Known limitations
- Explains 63.5% of variance. The model underestimates extreme crisis-year losses (2020-21) and shows associations, not causes.
- The script reads a hard-coded path (`D:/IIM EDGE Course/...`). Change it to run the code.
- The code comment lists the `year` p-value as 0.118, but the report gives 0.197. Use the report's figure.
