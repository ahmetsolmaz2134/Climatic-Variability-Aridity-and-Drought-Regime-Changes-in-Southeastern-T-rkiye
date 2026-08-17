# Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye

## A NASA POWER-Based Hydroclimatological Assessment (1991–2025)

**Author: Ahmet Solmaz**

---

## Abstract

This study investigates climatic variability, aridity, drought dynamics, and hydroclimatic regime changes across nine provinces of Southeastern Türkiye during **1991–2025**.

The study uses daily meteorological data from the **NASA Prediction of Worldwide Energy Resources (NASA POWER)** database and applies a multi-method hydroclimatological framework including **Mann–Kendall, Sen's slope, Pettitt, PELT, OLS-CUSUM, Cohen's *d*, SPI-12, SPEI-12, Thornthwaite PET, De Martonne, UNEP P/PET, drought-event analysis, and Consecutive Dry Days (CDD)**.

The results indicate a coherent warming signal, increasing evaporative demand, progressive aridification, increasing dry-spell persistence, and an increasing contribution of temperature and evaporative demand to drought conditions.

---

# 1. Study Area and Data

The study covers nine provinces in Southeastern Türkiye:

**Diyarbakır · Batman · Siirt · Kilis · Gaziantep · Şanlıurfa · Adıyaman · Şırnak · Mardin**

### Data Source

**NASA POWER**

### Period

**1991–2025**

### Temporal Resolution

**Daily → Monthly → Annual**

### Main Variables

| Variable | Parameter | Unit |
|---|---|---|
| Air Temperature | T2M | °C |
| Precipitation | PRECTOTCORR | mm/day |

Potential evapotranspiration was estimated using the **Thornthwaite method**.

---

# 2. Research Questions

The study addresses four main questions:

1. Has temperature significantly increased across Southeastern Türkiye?
2. Have climatic aridity and atmospheric evaporative demand changed?
3. Has the frequency, duration, and severity of drought changed?
4. Are recent drought conditions increasingly influenced by temperature and evaporative demand?

---

# 3. Core Results

## 3.1 Temperature Change

A statistically significant warming signal was detected across the analysed provinces.

Mann–Kendall and Sen's slope analyses were used to quantify long-term warming, while Pettitt and PELT analyses were used to identify structural temperature changes.

### Temperature Trend

![Temperature Trend](Academic_Trend_T2M_9Cities.png)

### Temperature Regime Shift

![Temperature Regime Shift](Academic_Regime_Shift_T2M.png)

### Temperature Time Series

![Temperature Time Series](Academic_Regime_Shift_T2M_Time_Series.png)

### Percentage Change Between Regimes

![Temperature Regime Percentage Change](Academic_Regime_Shift_Percentage_Bar.png)

**Main finding:** The region exhibits a persistent warming tendency accompanied by a shift toward warmer post-break conditions.

---

## 3.2 Precipitation Variability

Precipitation displays substantial interannual variability and weaker spatial coherence than temperature.

### Precipitation Trend

![Precipitation Trend](Academic_Trend_Precip_9Cities.png)

### Precipitation Regime Shift

![Precipitation Regime Shift](Academic_Regime_Shift_Precip.png)

**Main finding:** Regional hydroclimatic drying cannot be explained by precipitation decline alone.

---

## 3.3 Aridity and Potential Evapotranspiration

Potential evapotranspiration was estimated using the Thornthwaite method.

Aridity was evaluated using:

- De Martonne Aridity Index
- UNEP P/PET Aridity Index

### De Martonne Aridity

![De Martonne Aridity](Academic_Aridity_DeMartonne_9Cities.png)

### UNEP P/PET Aridity

![UNEP Aridity](Academic_Aridity_UNEP_PPET_9Cities.png)

**Main finding:** Increasing evaporative demand contributes substantially to the observed hydroclimatic drying and aridification.

---

## 3.4 Drought Regime

Long-term drought conditions were assessed using:

- **SPI-12** — precipitation-based drought
- **SPEI-12** — precipitation + evaporative-demand drought

### SPEI-12 Drought Conditions

![SPEI-12 Drought](Academic_Drought_SPEI12_Bars_9Cities.png)

### SPI-12 vs SPEI-12

![SPI-12 vs SPEI-12](Academic_Drought_SPI12_vs_SPEI12_9Cities.png)

**Main finding:** SPEI-12 identifies additional drought stress associated with increasing atmospheric evaporative demand.

---

## 3.5 Drought Frequency, Duration and Severity

Drought events were identified using run-theory analysis.

The analysis considers:

- Frequency
- Duration
- Severity
- Intensity

### Drought Frequency

![Drought Frequency](Academic_Drought_Events_Frequency.png)

### Drought Duration vs Severity

![Drought Duration vs Severity](Academic_Drought_Duration_vs_Severity.png)

**Main finding:** Longer drought events are associated with greater cumulative drought severity, highlighting the importance of drought persistence.

---

## 3.6 Consecutive Dry Days

Dry-spell persistence was evaluated using **Consecutive Dry Days (CDD)**.

A dry day was defined as:

**PR < 1.0 mm/day**

### Annual CDD

![Annual CDD](Academic_DrySpell_Annual_CDD_9Cities.png)

### Seasonal CDD

![Seasonal CDD](Academic_DrySpell_Seasonal_CDD_9Cities.png)

**Main finding:** Dry-spell persistence shows an increasing tendency across a substantial part of the study region.

---

## 3.7 Trend Magnitude and Effect Size

Sen's slope was used to estimate decadal trend magnitudes.

Cohen's *d* was used to quantify the magnitude of differences between pre- and post-regime periods.

### Sen's Slope

![Sen's Slope](Academic_Sens_Slope_Decadal_Rates.png)

### Cohen's *d*

![Cohen's d](Academic_Effect_Size_Cohen_ForestPlot.png)

**Main finding:** Several detected regime differences are not only statistically significant but also substantial in magnitude.

---

## 3.8 Climate–Drought Relationships

Pearson and Spearman correlations were used to investigate relationships among climatic variables and drought indices.

The main relationships examined were:

- Precipitation ↔ SPI-12
- Temperature ↔ SPEI-12
- PET ↔ SPEI-12

### Correlation Analysis

![Climate-Drought Correlations](Academic_Correlations_BarPlot_9Cities.png)

### PET vs SPEI-12

![PET vs SPEI-12](Academic_Scatter_PET_vs_SPEI12_9Cities.png)

### Precipitation vs SPI-12

![Precipitation vs SPI-12](Academic_Scatter_Prec_vs_SPI12_9Cities.png)

**Main finding:** Temperature and PET show an important negative relationship with SPEI-12, supporting the increasing role of atmospheric evaporative demand in drought development.

---

# 4. Methodological Framework

| Research Component | Method |
|---|---|
| Climate variability | Descriptive statistics |
| Trend detection | Mann–Kendall |
| Trend magnitude | Sen's slope |
| Change-point detection | Pettitt |
| Multiple change points | PELT |
| Structural stability | OLS-CUSUM |
| PET | Thornthwaite |
| Aridity | De Martonne |
| Aridity | UNEP P/PET |
| Drought | SPI-12 |
| Drought | SPEI-12 |
| Drought events | Run theory |
| Dry spells | CDD |
| Effect size | Cohen's *d* |
| Correlation | Pearson + Spearman |

All analyses were implemented in **R**.

---

# 5. Integrated Hydroclimatic Interpretation

The combined evidence indicates a regional hydroclimatic transformation characterized by:

```text
Warming
   ↓
Increasing PET
   ↓
Increasing Atmospheric Water Demand
   ↓
Increasing Aridity
   ↓
Longer Dry Spells
   ↓
Increasing Temperature-Sensitive Drought
   ↓
Hydroclimatic Regime Change
