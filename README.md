# Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye

**A NASA POWER-Based Hydroclimatological Assessment (1991–2025)**

**Author:** Ahmet Solmaz  
**Repository:** [Climatic-Variability-Aridity-and-Drought-Regime-Changes-in-Southeastern-T-rkiye](https://github.com/ahmetsolmaz2134/Climatic-Variability-Aridity-and-Drought-Regime-Changes-in-Southeastern-T-rkiye)

---

## 1. Overview

This repository presents a comprehensive hydroclimatological assessment of climatic variability, aridity intensification, and drought regime shifts across nine provinces of Southeastern Türkiye (Diyarbakır, Batman, Siirt, Kilis, Gaziantep, Şanlıurfa, Adıyaman, Şırnak, and Mardin). The study covers the period **1991–2025** and is entirely based on high-resolution NASA POWER reanalysis data.

The analysis integrates:
- Long-term trend detection (Mann–Kendall & Sen’s slope)
- Structural change-point detection (Pettitt, PELT, CUSUM)
- Standardized drought indices (SPI-12 and SPEI-12)
- Consecutive Dry Days (CDD) following ETCCDI definitions
- Classical and modern aridity indices (De Martonne and UNEP P/PET)
- Effect-size quantification of regime shifts (Cohen’s *d*)
- Climate–drought coupling diagnostics

All figures, statistical summaries, and processed datasets are provided for full reproducibility and academic use.

---

## 2. Study Area

Nine provinces representing the core of the Southeastern Anatolia Region (GAP region):

| Province    | Latitude (°N) | Longitude (°E) |
|-------------|---------------|----------------|
| Diyarbakır  | 37.91         | 40.21          |
| Batman      | 37.88         | 41.13          |
| Siirt       | 37.93         | 41.94          |
| Kilis       | 36.71         | 37.11          |
| Gaziantep   | 37.06         | 37.38          |
| Şanlıurfa   | 37.16         | 38.79          |
| Adıyaman    | 37.76         | 38.28          |
| Şırnak      | 37.52         | 42.46          |
| Mardin      | 37.31         | 40.74          |

These provinces experience a semi-arid to arid climate with pronounced summer dryness and are highly sensitive to temperature-driven increases in atmospheric evaporative demand.

---

## 3. Data Source

- **Platform:** NASA POWER (Prediction Of Worldwide Energy Resources)
- **Community:** AG (Agroclimatology)
- **Temporal resolution:** Daily
- **Period:** 1 January 1991 – 31 December 2025
- **Variables used:**
  - `T2M` – Mean 2-m air temperature (°C)
  - `T2M_MAX` / `T2M_MIN` – Maximum / Minimum temperature
  - `PRECTOTCORR` – Corrected precipitation (mm day⁻¹)
  - `RH2M` – Relative humidity (%)
  - `WS10M` – Wind speed at 10 m (m s⁻¹)

Daily data were aggregated to monthly and annual scales for subsequent analyses.

---

## 4. Methodology

### 4.1 Dry Spell Analysis (ETCCDI)
- Consecutive Dry Days (CDD): maximum number of consecutive days with precipitation < 1.0 mm
- Consecutive Wet Days (CWD)
- Seasonal and annual CDD series

### 4.2 Potential Evapotranspiration & Water Balance
- Thornthwaite method for monthly PET
- Climatic water balance: D = P − PET

### 4.3 Drought Indices
- **SPI-12** (Standardized Precipitation Index, 12-month scale)
- **SPEI-12** (Standardized Precipitation–Evapotranspiration Index, 12-month scale)
- Drought events defined by the threshold ≤ −1.0 (moderate and more severe droughts)
- Event characteristics extracted via run theory: frequency, duration, severity, intensity, and peak intensity

### 4.4 Aridity Indices
- **De Martonne Index:** \( I_{DM} = \frac{P}{T + 10} \)
- **UNEP Aridity Index:** \( AI = \frac{P}{PET} \)
- Climate classification according to standard thresholds

### 4.5 Trend & Regime-Shift Analysis
- Mann–Kendall trend test + Sen’s slope estimator
- Pettitt single change-point test
- PELT multiple change-point detection
- OLS-CUSUM structural stability test
- Cohen’s *d* effect size for pre- vs post-break regimes

### 4.6 Climate–Drought Coupling
- Pearson and Spearman correlations between:
  - Precipitation ↔ SPI-12
  - Temperature / PET ↔ SPEI-12

---

## 5. Key Results

### 5.1 Temperature and Precipitation Trends
- Statistically significant warming trends in mean temperature (T2M) across all nine provinces.
- Precipitation series exhibit high interannual variability with predominantly non-significant or weakly negative trends.
- Regime shifts in temperature frequently detected in the late 1990s to mid-2000s (Pettitt test).

### 5.2 Aridity Intensification
- Both De Martonne and UNEP P/PET indices show a clear tendency toward increasing aridity.
- Rising PET (driven by temperature increase) is the dominant driver of aridification even when precipitation remains relatively stable.
- Many provinces are transitioning toward or remaining within the semi-arid class.

**Related figures:**
- `Academic_Aridity_DeMartonne_9Cities.png`
- `Academic_Aridity_UNEP_PPET_9Cities.png`

### 5.3 Drought Regime Changes (SPI vs SPEI)
- SPEI-12 generally detects more frequent and/or more intense drought events than SPI-12, highlighting the growing role of evaporative demand.
- Longer drought durations are associated with higher cumulative severity.
- Notable multi-year drought clusters appear in the 2000s and early 2020s.

**Related figures:**
- `Academic_Drought_Events_Frequency.png`
- `Academic_Drought_Duration_vs_Severity.png`
- `Academic_Drought_SPEI12_Bars_9Cities.png`
- `Academic_Drought_SPI12_vs_SPEI12_9Cities.png`

### 5.4 Consecutive Dry Days (CDD)
- Annual maximum CDD shows an upward tendency in several provinces.
- Seasonal analysis indicates particularly long dry spells in summer and autumn.

**Related figures:**
- `Academic_DrySpell_Annual_CDD_9Cities.png`
- `Academic_DrySpell_Seasonal_CDD_9Cities.png`

### 5.5 Regime Shifts and Effect Sizes
- Clear structural breaks in temperature series (Pettitt).
- Post-break regimes are characterized by higher mean temperatures and, in many cases, elevated PET and CDD.
- Cohen’s *d* quantifies the magnitude of these shifts (small to large effects depending on variable and province).

**Related figures:**
- `Academic_Regime_Shift_T2M.png`
- `Academic_Regime_Shift_T2M_Time_Series.png`
- `Academic_Regime_Shift_Precip.png`
- `Academic_Regime_Shift_Percentage_Bar.png`
- `Academic_Effect_Size_Cohen_ForestPlot.png`
- `Academic_Sens_Slope_Decadal_Rates.png`
- `Academic_Trend_T2M_9Cities.png`
- `Academic_Trend_Precip_9Cities.png`

### 5.6 Climate–Drought Coupling
- Strong positive correlation between precipitation and SPI-12 (as expected).
- Negative correlations between temperature / PET and SPEI-12, confirming the thermal contribution to drought severity.

**Related figures:**
- `Academic_Correlations_BarPlot_9Cities.png`
- `Academic_Scatter_PET_vs_SPEI12_9Cities.png`
- `Academic_Scatter_Prec_vs_SPI12_9Cities.png`

---

## 6. Repository Structure
├── Academic_*.png                  # High-resolution academic figures (all analyses)
├── Aridity_Analysis_9Cities.xlsx
├── Climate_Drought_Relationships_9Cities.xlsx
├── Climate_Effect_Size_Analysis_9Cities.xlsx
├── Climate_Regime_Shift_Analysis_9Cities.xlsx
├── Drought_Analysis_SPI_SPEI_All9Cities.xlsx
├── Drought_Event_Statistics_9Cities.xlsx
├── Dry_Spell_Analysis_9Cities.xlsx
├── Hydroclimatic_Trend_Analysis_Results.xlsx
├── Regional_Regime_Shift_Analysis_9Cities.xlsx
├── Regional_Trend_Analysis_9Cities.xlsx
├── code 2.R … code 9.R             # Modular R scripts
└── README.md

All Excel workbooks contain multiple sheets with:
- Raw and processed time series
- Statistical test results
- Event catalogues
- Embedded figures where applicable

---

## 7. Software & Reproducibility

**Language:** R  
**Key packages:**
- `nasapower` – data retrieval
- `SPEI` – SPI / SPEI calculation and Thornthwaite PET
- `trend` – Mann–Kendall, Sen’s slope, Pettitt
- `changepoint` – PELT
- `strucchange` – CUSUM
- `effsize` – Cohen’s *d*
- `tidyverse`, `lubridate`, `ggplot2`, `openxlsx`

Scripts are modular (`code 2.R` to `code 9.R`). Users can re-run the entire pipeline by executing the scripts sequentially after installing the required packages (preferably via `pacman`).

---

## 8. Citation

If you use this repository or any of its outputs in academic work, please cite:

> Solmaz, A. (2026). *Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye: A NASA POWER-Based Hydroclimatological Assessment (1991–2025)*. GitHub repository. https://github.com/ahmetsolmaz2134/Climatic-Variability-Aridity-and-Drought-Regime-Changes-in-Southeastern-T-rkiye

---

## 9. Author

**Ahmet Solmaz**  
Independent researcher focusing on hydroclimatology, drought monitoring, and climate regime analysis in the Eastern Mediterranean and Southeastern Anatolia.

---

## 10. License & Contact

This work is intended for academic and research purposes.  
For questions, collaboration, or data requests, please open an issue in this repository or contact the author via GitHub.

---

*All analyses, figures, and statistical results presented in this repository were designed and executed by **Ahmet Solmaz**.*
