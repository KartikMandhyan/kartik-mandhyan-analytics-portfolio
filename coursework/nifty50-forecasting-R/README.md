# Nifty 50 Forecasting with ARIMA and Holt-Winters (R)

**Group paper (four authors), *Advanced Data Analytics for Business*, CIA IV (Apr 2025).** My individual contribution is not itemised here.

- **Data:** Nifty 50 monthly average closing values, Sep 2007 - Apr 2025 (212 months), from Kaggle.
- **Models:** ARIMA vs Holt-Winters, 20-month forecast (May 2025 - Dec 2026).
- **Reported accuracy (in-sample):** ARIMA MAE 294.43, MAPE 3.32% vs Holt-Winters MAE 384.29, MAPE 4.48%.
- **File:** the paper (PDF), with the R code in it.

## Known limitations
- Accuracy figures are in-sample, with no holdout test, so "ARIMA is better" is not validated out-of-sample.
- Monthly averages smooth the series, which makes errors look smaller.
- Some wording and citations were carried over from a template paper and have not been re-verified.
