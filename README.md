# Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye

### A NASA POWER-Based Hydroclimatological Assessment (1991–2025)

**Author: Ahmet Solmaz**

---

## About the Study

This study investigates **climatic variability, aridity intensification, drought characteristics, and hydroclimatic regime changes in Southeastern Türkiye**.

The analysis covers nine provinces:

**Diyarbakır · Batman · Siirt · Kilis · Gaziantep · Şanlıurfa · Adıyaman · Şırnak · Mardin**

The study was conducted to determine whether the regional climate has experienced **persistent warming, increasing atmospheric dryness, longer dry periods, and a transition toward temperature-driven drought conditions**.

Daily NASA POWER data for **1991–2025** were analysed using R.

---

# Main Results

The results indicate a clear hydroclimatic transformation across Southeastern Türkiye:

* 🌡️ **Persistent warming** was detected across the study region.
* 💧 **Potential evapotranspiration increased**, indicating increasing atmospheric evaporative demand.
* 🌵 **Aridity intensified** according to both De Martonne and UNEP indices.
* ☀️ **Consecutive dry-day periods increased** in several provinces.
* 📉 **SPEI-12 identified stronger drought signals than SPI-12**, indicating an increasing influence of temperature and evaporative demand.
* 🔄 Several provinces experienced **clear climatic regime shifts**.
* 🌧️ Precipitation showed high interannual variability, while its long-term signal was generally weaker than the temperature and PET signals.
* 📊 Effect-size analysis confirmed that several regime changes were not only statistically detectable but also physically meaningful.

Overall, the findings indicate a transition toward a **warmer, drier and more temperature-sensitive hydroclimatic regime**.

---

# Visual Results

## Temperature Trends

![Temperature Trends](Academic_Trend_T2M_9Cities.png)

## Temperature Regime Shifts

![Temperature Regime Shift](Academic_Regime_Shift_T2M.png)

![Temperature Regime Shift Time Series](Academic_Regime_Shift_T2M_Time_Series.png)

![Regime Shift Percentage](Academic_Regime_Shift_Percentage_Bar.png)

---

## Precipitation Trends and Regime Changes

![Precipitation Trends](Academic_Trend_Precip_9Cities.png)

![Precipitation Regime Shift](Academic_Regime_Shift_Precip.png)

---

## Aridity

![De Martonne Aridity](Academic_Aridity_DeMartonne_9Cities.png)

![UNEP Aridity](Academic_Aridity_UNEP_PPET_9Cities.png)

The aridity results indicate a progressive increase in atmospheric dryness, primarily associated with increasing evaporative demand.

---

## Drought Regime

![Drought Frequency](Academic_Drought_Events_Frequency.png)

![Drought Duration and Severity](Academic_Drought_Duration_vs_Severity.png)

![SPEI-12 Drought](Academic_Drought_SPEI12_Bars_9Cities.png)

![SPI-12 vs SPEI-12](Academic_Drought_SPI12_vs_SPEI12_9Cities.png)

The comparison between SPI-12 and SPEI-12 demonstrates the increasing importance of **temperature and atmospheric water demand** in drought development.

---

## Consecutive Dry Days

![Annual CDD](Academic_DrySpell_Annual_CDD_9Cities.png)

![Seasonal CDD](Academic_DrySpell_Seasonal_CDD_9Cities.png)

The CDD analysis shows increasing dry-spell persistence, particularly during the warmer seasons.

---

## Effect Size and Climate Change Magnitude

![Cohen's d Effect Size](Academic_Effect_Size_Cohen_ForestPlot.png)

![Sen's Slope Decadal Rates](Academic_Sens_Slope_Decadal_Rates.png)

Effect-size analysis provides an additional interpretation of the magnitude of observed climatic regime changes.

---

## Climate–Drought Relationships

![Correlation Analysis](Academic_Correlations_BarPlot_9Cities.png)

![PET vs SPEI-12](Academic_Scatter_PET_vs_SPEI12_9Cities.png)

![Precipitation vs SPI-12](Academic_Scatter_Prec_vs_SPI12_9Cities.png)

The relationships demonstrate strong precipitation–SPI coupling and a clear negative relationship between temperature/PET and SPEI-12.

---

# Methodological Framework

The study combines:

* Mann–Kendall trend test
* Sen's slope estimator
* Pettitt change-point test
* PELT change-point analysis
* OLS-CUSUM
* Cohen's *d* effect size
* SPI-12
* SPEI-12
* ETCCDI Consecutive Dry Days (CDD)
* Thornthwaite PET
* De Martonne Aridity Index
* UNEP P/PET Aridity Index
* Pearson correlation
* Spearman correlation
* Run-theory drought event analysis

All analyses were performed in **R** using reproducible scripts.

---

# Excel Results

Detailed numerical results are provided as Excel workbooks:

* [Aridity Analysis](Aridity_Analysis_9Cities.xlsx)
* [Drought Event Statistics](Drought_Event_Statistics_9Cities.xlsx)
* [SPI–SPEI Drought Analysis](Drought_Analysis_SPI_SPEI_All9Cities.xlsx)
* [Dry Spell Analysis](Dry_Spell_Analysis_9Cities.xlsx)
* [Climate Regime Shift Analysis](Climate_Regime_Shift_Analysis_9Cities.xlsx)
* [Climate Effect Size Analysis](Climate_Effect_Size_Analysis_9Cities.xlsx)
* [Climate–Drought Relationships](Climate_Drought_Relationships_9Cities.xlsx)
* [Hydroclimatic Trend Analysis](Hydroclimatic_Trend_Analysis_Results.xlsx)
* [Regional Regime Shift Analysis](Regional_Regime_Shift_Analysis_9Cities.xlsx)
* [Regional Trend Analysis](Regional_Trend_Analysis_9Cities.xlsx)

These files contain the **statistical test results, trend estimates, change points, drought-event statistics, aridity calculations, correlations and regional results**.

---

# Data

**Source:** NASA POWER Agroclimatology Community

**Period:** 1 January 1991 – 31 December 2025

**Temporal resolution:** Daily

**Main variables:**

* Air temperature (T2M)
* Precipitation (PRECTOTCORR)

Daily observations were aggregated to monthly and annual scales where appropriate.

---

# Repository Structure

```text
├── Academic_*.png
├── *.xlsx
├── code 2.R
├── code 3.R
├── code 4.R
├── code 5.R
├── code 6.R
├── code 7.R
├── code 8.R
├── code 9.R
└── README.md
```

The R scripts reproduce the statistical analyses and visual outputs presented in this repository.

---

# Scientific Significance

The study demonstrates that Southeastern Türkiye is experiencing a combination of:

**warming + increasing PET + increasing dryness + longer dry spells + increasing temperature-driven drought risk.**

These changes are particularly important for:

* water resources,
* rain-fed agriculture,
* drought monitoring,
* regional climate adaptation,
* and sustainable environmental planning.

---

# Author

### Ahmet Solmaz

This research project, including the **data processing, statistical analyses, methodological design, figures, Excel result files and scientific interpretation**, was independently designed and conducted by **Ahmet Solmaz**.

The repository is presented as a reproducible research project in **hydroclimatology, climate variability, aridity and drought analysis**.

---

### Citation

**Solmaz, A. (2026).** *Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye: A NASA POWER-Based Hydroclimatological Assessment (1991–2025).*
