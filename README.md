# Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye

**A NASA POWER-Based Hydroclimatological Assessment (1991–2025)**

**Author:** Ahmet Solmaz  

---

## Abstract

This study investigates multi-decadal climatic variability, progressive aridification, and drought regime shifts across nine provinces of Southeastern Türkiye (Diyarbakır, Batman, Siirt, Kilis, Gaziantep, Şanlıurfa, Adıyaman, Şırnak, and Mardin) using NASA POWER daily reanalysis data for the period **1991–2025**.  

A multi-method framework combining Mann–Kendall trends, Sen’s slope, Pettitt and PELT change-point detection, Cohen’s *d* effect sizes, SPI-12 / SPEI-12 drought indices, ETCCDI Consecutive Dry Days (CDD), and classical aridity indices (De Martonne and UNEP P/PET) was applied.  

**Key findings** indicate a robust warming signal, rising potential evapotranspiration, lengthening dry spells, and a clear shift toward temperature-driven (SPEI-dominated) drought regimes. These changes pose increasing risks to water resources and rain-fed agriculture in the GAP region.

---

## 1. Study Area & Data

**Provinces analysed:**  
Diyarbakır · Batman · Siirt · Kilis · Gaziantep · Şanlıurfa · Adıyaman · Şırnak · Mardin

**Data source:** NASA POWER Agroclimatology community  
**Variables:** T2M, PRECTOTCORR (daily)  
**Period:** 1 January 1991 – 31 December 2025  

Daily series were aggregated to monthly and annual scales. Potential Evapotranspiration (PET) was calculated using the Thornthwaite method.

---

## 2. Core Results & Visual Evidence

### 2.1 Temperature Regime Shifts

All nine provinces exhibit statistically significant warming. Pettitt change-point analysis consistently detects structural breaks concentrated between the late 1990s and mid-2000s. Post-break regimes show elevated mean temperatures and accelerated evaporative demand.

**Figures:**
- `Academic_Regime_Shift_T2M.png`  
- `Academic_Regime_Shift_T2M_Time_Series.png`  
- `Academic_Trend_T2M_9Cities.png`  
- `Academic_Regime_Shift_Percentage_Bar.png`

---

### 2.2 Aridity Intensification

Both the **De Martonne Index** and the **UNEP Aridity Index (P/PET)** display declining trends, indicating progressive aridification. The dominant driver is the increase in PET rather than a strong decline in precipitation.

**Figures:**
- `Academic_Aridity_DeMartonne_9Cities.png`  
- `Academic_Aridity_UNEP_PPET_9Cities.png`

---

### 2.3 Drought Regime Changes (SPI-12 vs SPEI-12)

SPEI-12 systematically detects more frequent and/or more severe drought events than SPI-12, demonstrating the growing influence of atmospheric evaporative demand. Run-theory analysis reveals that longer drought durations are linearly associated with higher cumulative severity.

**Figures:**
- `Academic_Drought_Events_Frequency.png`  
- `Academic_Drought_Duration_vs_Severity.png`  
- `Academic_Drought_SPEI12_Bars_9Cities.png`  
- `Academic_Drought_SPI12_vs_SPEI12_9Cities.png`

---

### 2.4 Consecutive Dry Days (CDD – ETCCDI)

Annual maximum Consecutive Dry Days show an upward tendency in the majority of provinces. Seasonal boxplots highlight the dominance of summer and autumn dry spells.

**Figures:**
- `Academic_DrySpell_Annual_CDD_9Cities.png`  
- `Academic_DrySpell_Seasonal_CDD_9Cities.png`

---

### 2.5 Effect Size of Regime Shifts (Cohen’s *d*)

Standardized mean differences between pre- and post-break regimes were quantified using Cohen’s *d* with 95 % confidence intervals. Temperature and PET shifts frequently fall into the **medium-to-large** effect magnitude classes, confirming that the observed changes are not only statistically significant but also physically meaningful.

**Figures:**
- `Academic_Effect_Size_Cohen_ForestPlot.png`  
- `Academic_Sens_Slope_Decadal_Rates.png`

---

### 2.6 Climate–Drought Coupling

Pearson and Spearman correlations confirm:
- Strong positive coupling between precipitation and SPI-12  
- Clear negative coupling between temperature / PET and SPEI-12  

This supports the interpretation of a transition from precipitation-dominated to temperature-dominated drought regimes.

**Figures:**
- `Academic_Correlations_BarPlot_9Cities.png`  
- `Academic_Scatter_PET_vs_SPEI12_9Cities.png`  
- `Academic_Scatter_Prec_vs_SPI12_9Cities.png`

---

### 2.7 Precipitation Behaviour

Precipitation series display high interannual variability. Long-term trends are generally weaker and less spatially coherent than temperature and PET trends.

**Figures:**
- `Academic_Regime_Shift_Precip.png`  
- `Academic_Trend_Precip_9Cities.png`

---

## 3. Methodological Framework

| Component                    | Methods Applied                                      |
|-----------------------------|------------------------------------------------------|
| Trend detection             | Mann–Kendall + Sen’s slope                           |
| Change-point detection      | Pettitt, PELT, OLS-CUSUM                             |
| Effect size                 | Cohen’s *d* (with 95 % CI)                           |
| Drought indices             | SPI-12, SPEI-12                                      |
| Drought event extraction    | Run theory (threshold ≤ −1.0)                        |
| Dry spells                  | ETCCDI CDD / CWD (PR < 1.0 mm day⁻¹)                 |
| Aridity indices             | De Martonne, UNEP P/PET                              |
| PET estimation              | Thornthwaite                                         |
| Climate–drought coupling    | Pearson & Spearman correlations                      |

All analyses were performed in **R** using the packages `nasapower`, `SPEI`, `trend`, `changepoint`, `strucchange`, `effsize`, `tidyverse`, and `ggplot2`.

---

## 4. Data Products

High-resolution Excel workbooks containing full numerical results:

- `Aridity_Analysis_9Cities.xlsx`
- `Drought_Event_Statistics_9Cities.xlsx`
- `Drought_Analysis_SPI_SPEI_All9Cities.xlsx`
- `Dry_Spell_Analysis_9Cities.xlsx`
- `Climate_Regime_Shift_Analysis_9Cities.xlsx`
- `Climate_Effect_Size_Analysis_9Cities.xlsx`
- `Climate_Drought_Relationships_9Cities.xlsx`
- `Hydroclimatic_Trend_Analysis_Results.xlsx`
- `Regional_Regime_Shift_Analysis_9Cities.xlsx`
- `Regional_Trend_Analysis_9Cities.xlsx`

Each workbook includes multiple sheets with time series, statistical test outputs, event catalogues, and (where applicable) embedded figures.

---

## 5. Repository Structure
├── Academic_*.png                          # All high-resolution figures
├── *.xlsx                                  # Detailed statistical outputs
├── code 2.R … code 9.R                     # Modular, fully documented R scripts
└── README.md

Scripts are modular and can be executed sequentially to fully reproduce every figure and table.

---

## 6. Scientific Significance

The results demonstrate that Southeastern Türkiye is undergoing a clear **hydroclimatic regime shift** characterised by:

1. Persistent warming  
2. Rising evaporative demand  
3. Lengthening consecutive dry periods  
4. Increasing dominance of temperature-driven drought (SPEI) over purely precipitation-driven drought (SPI)  
5. Progressive aridification of the regional climate  

These findings have direct implications for water resource management, agricultural planning, and climate adaptation strategies in the GAP region.

---

## 7. Citation

If you use this work, please cite:

> Solmaz, A. (2026). *Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye: A NASA POWER-Based Hydroclimatological Assessment (1991–2025)*. GitHub repository.  
> https://github.com/ahmetsolmaz2134/Climatic-Variability-Aridity-and-Drought-Regime-Changes-in-Southeastern-T-rkiye

---

## 8. Author

**Ahmet Solmaz**  
Independent researcher specialising in hydroclimatology, drought monitoring, and climate regime analysis in the Eastern Mediterranean and Southeastern Anatolia.

---

*All analyses, statistical tests, figures, and interpretations presented in this repository were designed and executed exclusively by **Ahmet Solmaz**.*
