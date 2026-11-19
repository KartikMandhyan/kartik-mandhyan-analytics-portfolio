  ##############################################################################
  ## Airline Operating Income — Linear Regression — FINAL VERSION
  ## Backward elimination shown step by step, each removal justified by a
  ## specific metric (VIF for multicollinearity, p-value for significance).
  ##############################################################################
  
  ### STEP 0: IMPORT DATA ###
  airline <- read.csv("D:/IIM EDGE Course/airline_financials.csv") # <-- update path
  summary(airline)
  
  ### STEP 1: DATA CLEANING ###
  airline <- na.omit(airline)   # 0 rows dropped - no missing values
  
  ### STEP 2: ENCODING ###
  library(fastDummies)
  airline <- dummy_cols(airline,
                        select_columns = c("business_model", "region"),
                        remove_first_dummy = TRUE,
                        remove_selected_columns = TRUE)
  
  ### STEP 3: STRUCTURAL EXCLUSION (done BEFORE any testing, not metric-based) ###
  # revenue_usd_bn and operating_margin_pct are removed here, before correlation
  # or modeling begins. operating_income_usd_bn = revenue_usd_bn *
  # operating_margin_pct / 100 (accounting identity, confirmed corr ~0.999).
  # Including either lets the model reconstruct the DV algebraically instead of
  # explaining it. This is the ONLY variable excluded for a non-statistical
  # reason; everything else below is tested and removed/kept based on evidence.
  #
  # NOTE: airline_name and year are kept in `candidates` here (not just the
  # model-formula variables) so they're available later for the DV-justification
  # check, the grouped split, and the temporal split.
  candidates <- airline[, c("airline_name", "year",
                            "passengers_carried_m", "load_factor_pct", "fleet_size_est",
                            "revenue_usd_bn", "operating_margin_pct",
                            grep("^business_model_", names(airline), value = TRUE),
                            grep("^region_", names(airline), value = TRUE),
                            "operating_income_usd_bn")]
  
  
  ##############################################################################
  ## STEP 3B: DV JUSTIFICATION — evidence-based, not opinion-based
  ## Compares Operating Income vs Operating Margin vs Revenue as DV candidates,
  ## using the SAME non-circular predictor set for all three, to see which DV
  ## produces the most genuinely multivariate (vs. single-variable-dominated) story.
  ##############################################################################
  dv_test_predictors <- "passengers_carried_m + load_factor_pct + business_model_low_cost + business_model_regional + region_Europe + `region_Latin America` + `region_Middle East` + `region_North America`"
  
  model_dv_income  <- lm(as.formula(paste("operating_income_usd_bn ~", dv_test_predictors)), data = candidates)
  model_dv_margin  <- lm(as.formula(paste("operating_margin_pct ~", dv_test_predictors)), data = candidates)
  model_dv_revenue <- lm(as.formula(paste("revenue_usd_bn ~", dv_test_predictors)), data = candidates)
  
  count_sig <- function(model) sum(summary(model)$coefficients[-1, 4] < 0.05)  # excl. intercept
  
  dv_comparison <- data.frame(
    DV = c("operating_income_usd_bn", "operating_margin_pct", "revenue_usd_bn"),
    R2 = c(summary(model_dv_income)$r.squared, summary(model_dv_margin)$r.squared, summary(model_dv_revenue)$r.squared),
    Significant_IVs_of_8 = c(count_sig(model_dv_income), count_sig(model_dv_margin), count_sig(model_dv_revenue))
  )
  dv_comparison
  # DECISION: the DV with the most predictors individually significant (not just
  # highest R^2) is the one demonstrating a genuine multivariate relationship -
  # a single dominant predictor (e.g. margin driven almost entirely by load
  # factor) is a weaker regression story even if R^2 looks fine.
  
  
  ### STEP 4: CORRELATION CHECK ON ALL REMAINING CANDIDATES ###
  # fleet_size_est and year ARE included here - they are still live candidates.
  # Their fate is decided in the iterations below using VIF/p-value evidence.
  library(corrplot)
  num_cols <- c("passengers_carried_m","load_factor_pct","fleet_size_est",
                "year","operating_income_usd_bn")
  cor_mat <- cor(candidates[num_cols])
  cor_mat
  png("correlation_matrix.png", width = 1400, height = 1200, res = 150)
  par(mar = c(1, 5, 1, 1))
  corrplot.mixed(cor_mat, tl.col = "black", tl.cex = 0.9, number.cex = 0.9)
  dev.off()
  # OBSERVATION: fleet_size_est <-> passengers_carried_m = 0.85 -> flag for VIF
  # check in Iteration 1.
  
    ### STEP 5: TRAIN / TEST SPLIT (70/30 for the elimination process; alternate
    ### ratios compared separately in Step 8 once the variable set is locked) ###
    library(caTools)
    set.seed(111)
    split <- sample.split(candidates$operating_income_usd_bn, SplitRatio = 0.7)
    training <- subset(candidates, split == TRUE)
    testing  <- subset(candidates, split == FALSE)
  
  
  ##############################################################################
  ## STEP 6: BACKWARD ELIMINATION - ONE VARIABLE REMOVED PER ITERATION
  ## NOTE: model formulas below explicitly list variables (rather than using
  ## " ~ .") since `candidates`/`training` now also contains airline_name, year,
  ## revenue_usd_bn, operating_margin_pct (kept for Steps 3B/8/9B) which must
  ## NOT be fed into the actual regression as predictors.
  ##############################################################################
  library(car)
  
  model_formula_full <- operating_income_usd_bn ~ passengers_carried_m + load_factor_pct +
    fleet_size_est + year + business_model_low_cost + business_model_regional +
    region_Europe + `region_Latin America` + `region_Middle East` + `region_North America`
  
  ## --- ITERATION 1: FULL MODEL (all remaining candidates) ---
  cat("\n========== ITERATION 1: FULL MODEL ==========\n")
  model_it1 <- lm(model_formula_full, data = training)
  summary(model_it1)
  vif(model_it1)
  # DECISION METRIC: VIF. fleet_size_est and passengers_carried_m both show
  # VIF ~9-10 (>5 = concern, >10 = serious). REMOVE fleet_size_est -
  # passengers_carried_m is the more direct, current-year business metric.
  
  ## --- ITERATION 2: REMOVE fleet_size_est (metric: VIF ~9-10) ---
  cat("\n========== ITERATION 2: DROPPED fleet_size_est (VIF) ==========\n")
  model_it2 <- update(model_it1, . ~ . - fleet_size_est)
  summary(model_it2)
  vif(model_it2)
  # DECISION METRIC: p-value. Check `year` now - p=0.118, not significant, and
  # its correlation with the DV was already near-zero in Step 4 (0.05).
  
  ## --- ITERATION 3 (FINAL MODEL): REMOVE year (metric: p-value > 0.05) ---
  cat("\n========== ITERATION 3: DROPPED year (p-value) - FINAL MODEL ==========\n")
  model_final <- update(model_it2, . ~ . - year)
  summary(model_final)
  vif(model_final)
  # DECISION: VIF now clean (<3) for every remaining variable. Individual dummy
  # levels within business_model/region may still show p > 0.05 - these are NOT
  # removed one-by-one; categorical variables are tested as a BLOCK (Step 7).
  
  png("residual_plot.png", width = 2000, height = 1250, res = 220, bg = "white")
  par(mar = c(5, 5, 4, 2) + 0.1, family = "sans")
  plot(model_final$fitted.values, model_final$residuals,
       main = "Residual Plot — Final Model",
       xlab = "Fitted Values", ylab = "Residuals",
       pch = 21, bg = "#3a6ea5", col = "white", cex = 1.3,
       cex.main = 1.6, cex.lab = 1.3, cex.axis = 1.1,
       col.main = "#0f2942", col.lab = "#0f2942", col.axis = "#8a94a6",
       fg = "#8a94a6")
  grid(col = "grey90", lty = "dotted")
  abline(h = 0, col = "#c0504d", lty = 2, lwd = 2)
  dev.off()
  
  
  ##############################################################################
  ## STEP 7: BLOCK F-TESTS (categorical variables tested as groups)
  ##############################################################################
  model_no_region <- update(model_final, . ~ . - region_Europe - `region_Latin America` -
                              `region_Middle East` - `region_North America`)
  anova(model_no_region, model_final)
  # EXPECT: region block significant -> KEEP all region dummies even though some
  # individual levels show p > 0.05.
  
  model_no_bmodel <- update(model_final, . ~ . - business_model_low_cost - business_model_regional)
  anova(model_no_bmodel, model_final)
  # EXPECT: business_model block also significant -> KEEP both dummies.
  
  
  ##############################################################################
  ## STEP 8: COMPARE MULTIPLE TRAIN/TEST SPLIT RATIOS
  ## Uses the FINAL variable set (model_final's formula) on each ratio, to show
  ## the 70/30 choice was tested against alternatives, not picked arbitrarily.
  ##############################################################################
  final_formula <- formula(model_final)
  
  test_split_ratio <- function(ratio, seed = 111) {
    set.seed(seed)
    sp <- sample.split(candidates$operating_income_usd_bn, SplitRatio = ratio)
    tr <- subset(candidates, sp == TRUE)
    te <- subset(candidates, sp == FALSE)
    fit <- lm(final_formula, data = tr)
    pred <- predict(fit, newdata = te)
    c(ratio = ratio,
      n_train = nrow(tr), n_test = nrow(te),
      R2 = summary(fit)$r.squared,
      AdjR2 = summary(fit)$adj.r.squared,
      MAE = mean(abs(te$operating_income_usd_bn - pred)),
      RMSE = sqrt(mean((te$operating_income_usd_bn - pred)^2)))
  }
  
  results_60_40 <- test_split_ratio(0.60)
  results_70_30 <- test_split_ratio(0.70)
  results_75_25 <- test_split_ratio(0.75)
  results_80_20 <- test_split_ratio(0.80)
  
  split_comparison <- rbind(results_60_40, results_70_30, results_75_25, results_80_20)
  round(split_comparison, 3)
  # DECISION: 70/30 is the conventional default at n=497 - keeps a large enough
  # test set (~150 rows) for reliable metrics while giving the model sufficient
  # training data. Report this comparison table as evidence multiple ratios
  # were tested before finalizing.
  
  
  ##############################################################################
  ## STEP 8B: GROUPED SPLIT + TEMPORAL SPLIT (robustness checks beyond random split)
  ##############################################################################
  
  ### GROUPED SPLIT — hold out entire airlines, not just random rows ###
  # Tests: does the model generalize to airlines it's NEVER seen at all?
  set.seed(111)
  airlines_all <- unique(candidates$airline_name)
  test_airlines <- sample(airlines_all, size = round(0.30 * length(airlines_all)))
  
  mask_train_grouped <- !(candidates$airline_name %in% test_airlines)
  mask_test_grouped  <-  (candidates$airline_name %in% test_airlines)
  
  fit_grouped  <- lm(final_formula, data = candidates[mask_train_grouped, ])
  pred_grouped <- predict(fit_grouped, newdata = candidates[mask_test_grouped, ])
  
  grouped_results <- c(
    R2 = summary(fit_grouped)$r.squared,
    MAE = mean(abs(candidates$operating_income_usd_bn[mask_test_grouped] - pred_grouped)),
    RMSE = sqrt(mean((candidates$operating_income_usd_bn[mask_test_grouped] - pred_grouped)^2))
  )
  grouped_results
  
  ### TEMPORAL SPLIT — train on past years, test on more recent years ###
  # Tests: does the model work like a real forecast (predicting forward)?
  # 2026 excluded here since it's an incomplete/uncertain year (see Step 11).
  mask_train_temporal <- candidates$year <= 2022
  mask_test_temporal  <- candidates$year >= 2023 & candidates$year < 2026
  
  fit_temporal  <- lm(final_formula, data = candidates[mask_train_temporal, ])
  pred_temporal <- predict(fit_temporal, newdata = candidates[mask_test_temporal, ])
  
  temporal_results <- c(
    R2 = summary(fit_temporal)$r.squared,
    MAE = mean(abs(candidates$operating_income_usd_bn[mask_test_temporal] - pred_temporal)),
    RMSE = sqrt(mean((candidates$operating_income_usd_bn[mask_test_temporal] - pred_temporal)^2))
  )
  temporal_results
  
  # COMPARE: random-split R^2 (Step 8, ~0.635) vs grouped vs temporal. If all
  # three land in a similar range, that's evidence the model generalizes to
  # unseen airlines AND unseen future years, not just memorizing known rows.
  
  
  ##############################################################################
  ## STEP 9: FINAL MODEL DIAGNOSTICS (using the 70/30 split from Step 5)
  ##############################################################################
  library(lmtest)
  library(sandwich)
  
  bptest(model_final)   # heteroscedasticity check
  coeftest(model_final, vcov = vcovHC(model_final, type = "HC3"))
  # REPORT THIS TABLE as the final, corrected significance values.
  
  ##############################################################################
  ## STEP 9C: CLUSTER-ROBUST STANDARD ERRORS (accounts for repeated
  ## observations per airline - 497 rows are really 30 airlines x ~17 years,
  ## not 497 independent observations)
  ##############################################################################
  coeftest(model_final, vcov = vcovCL(model_final, cluster = ~airline_name))
  # COMPARE this table against the HC3 table above - report which coefficients
  # remain significant after accounting for within-airline correlation.
  library(car)
  png("influence_plot.png", width = 2000, height = 1250, res = 220, bg = "white")
  par(mar = c(5, 5, 5, 2) + 0.1, family = "sans")   # extra top margin (5 vs default ~4) fixes the clipped title
  influencePlot(model_final, main = "Influence Plot — Final Model",
                cex.main = 1.6, cex.lab = 1.3, cex.axis = 1.1,
                col.main = "#0f2942", col.lab = "#0f2942", col.axis = "#8a94a6",
                fg = "#8a94a6")
  dev.off()
  cooks_d <- cooks.distance(model_final)
  which(cooks_d > 4/nrow(training))
  max(cooks_d)
  
  model_step <- step(model_it1, direction = "both")
  summary(model_step)
  # COMPARE against model_final's variable set - step() is blind to
  # multicollinearity, so disagreement (if any) is expected and explainable.
  
  
  ##############################################################################
  ## STEP 9B: BASELINE MAE COMPARISON — is the model actually better than
  ## just guessing the average every time?
  ##############################################################################
  baseline_pred <- mean(training$operating_income_usd_bn)
  baseline_MAE <- mean(abs(testing$operating_income_usd_bn - baseline_pred))
  baseline_MAE
  # COMPARE this to your model's actual MAE from Step 10 below - a much lower
  # model MAE than baseline_MAE proves the model is genuinely learning
  # something, not just centered near the average.
  
  
  ##############################################################################
  ## STEP 10: PREDICT + EVALUATE ON TEST SET (final 70/30 split)
  ##############################################################################
  pred <- predict(model_final, newdata = testing)
  
  png("actual_vs_predicted.png", width = 2400, height = 1100, res = 220, bg = "white")
  par(mar = c(5, 5, 4, 2) + 0.1, family = "sans")
  plot(testing$operating_income_usd_bn, type = "l", col = "#0f2942", lwd = 2.2,
       main = "Actual vs Predicted Operating Income — Final Model",
       xlab = "Test Set Index", ylab = "Operating Income (USD bn)",
       ylim = range(c(testing$operating_income_usd_bn, pred)) * 1.5,  # <- adds headroom so legend doesn't collide
       cex.main = 1.6, cex.lab = 1.3, cex.axis = 1.1,
       col.main = "#0f2942", col.lab = "#0f2942", col.axis = "#8a94a6",
       fg = "#8a94a6")
  grid(col = "grey90", lty = "dotted")
  lines(pred, col = "#3a6ea5", lwd = 2.2)
  legend("topleft", legend = c("Actual", "Predicted"),
         col = c("#0f2942", "#3a6ea5"), lwd = 2.2, bty = "n", cex = 1.3)
  dev.off()
  
  MAE  <- mean(abs(testing$operating_income_usd_bn - pred))
  MSE  <- mean((testing$operating_income_usd_bn - pred)^2)
  RMSE <- sqrt(MSE)
  MAE; MSE; RMSE
  
  cat("\nModel MAE:", round(MAE, 3), " vs Baseline MAE:", round(baseline_MAE, 3), "\n")
  
  ##############################################################################
  ## END. model_final (Iteration 3) is the FINAL model. No further changes.
  ##############################################################################
  
  
