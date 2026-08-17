# Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye

## A NASA POWER-Based Hydroclimatological Assessment (1991–2025)

**Author: Ahmet Solmaz**

---

## Abstract

This study investigates long-term climatic variability, hydroclimatic aridification, and drought regime changes across Southeastern Türkiye during the period **1991–2025**.

The analysis covers nine provinces representing the major climatic and geographical characteristics of Southeastern Türkiye:

**Diyarbakır · Batman · Siirt · Kilis · Gaziantep · Şanlıurfa · Adıyaman · Şırnak · Mardin**

Daily meteorological data were obtained from the **NASA Prediction of Worldwide Energy Resources (NASA POWER)** database and aggregated to monthly and annual temporal scales.

A multi-method hydroclimatological framework was developed using:

- Mann–Kendall trend analysis
- Sen's slope estimator
- Pettitt change-point detection
- PELT multiple change-point detection
- OLS-CUSUM structural stability analysis
- Cohen's *d* effect size
- Thornthwaite Potential Evapotranspiration (PET)
- De Martonne Aridity Index
- UNEP Aridity Index (P/PET)
- SPI-12
- SPEI-12
- Run-theory drought-event analysis
- Consecutive Dry Days (CDD)
- Pearson correlation
- Spearman correlation

The results reveal a **robust warming signal**, increasing potential evapotranspiration, intensification of hydroclimatic aridity, lengthening dry spells, and an increasing importance of temperature-driven drought conditions.

The comparison between SPI-12 and SPEI-12 indicates that drought characterization based only on precipitation may underestimate drought conditions when increasing atmospheric evaporative demand is considered.

---

# 1. Research Objectives

The primary objective is to determine whether Southeastern Türkiye has experienced a statistically detectable transformation in its hydroclimatic regime during 1991–2025.

The study specifically investigates:

1. Long-term temperature variability
2. Long-term precipitation variability
3. Temperature and precipitation trends
4. Potential evapotranspiration changes
5. Changes in climatic aridity
6. Drought frequency
7. Drought duration
8. Drought severity
9. Consecutive dry-day characteristics
10. Structural climate regime changes
11. Differences between precipitation-driven and temperature-sensitive drought
12. The physical significance of detected climatic regime shifts

---

# 2. Study Region

The analysis covers nine provinces of Southeastern Türkiye:

| Province | Province |
|---|---|
| Diyarbakır | Batman |
| Siirt | Kilis |
| Gaziantep | Şanlıurfa |
| Adıyaman | Şırnak |
| Mardin | |

The selected locations provide a representative spatial framework for investigating hydroclimatic variability across the Southeastern Anatolian region.

---

# 3. Data Source

## NASA POWER

Meteorological data were obtained from the:

**NASA Prediction of Worldwide Energy Resources (POWER)**

NASA POWER provides analysis-ready meteorological and solar data derived from NASA atmospheric modelling and assimilation systems.

### Data period

**1 January 1991 – 31 December 2025**

### Temporal resolution

**Daily**

The daily data were subsequently aggregated into monthly and annual series for statistical analysis.

### Main variables

| Variable | NASA POWER Parameter | Unit |
|---|---|---|
| Air Temperature | T2M | °C |
| Precipitation | PRECTOTCORR | mm/day |

Potential evapotranspiration was subsequently estimated using the Thornthwaite method.

---

# 4. Conceptual Framework

The study follows a process-oriented hydroclimatological framework:

```text
NASA POWER Meteorological Data
              ↓
       Data Processing
              ↓
     Climatic Variability
              ↓
 Temperature & Precipitation Trends
              ↓
     Potential Evapotranspiration
              ↓
         Aridity Change
              ↓
       SPI-12 / SPEI-12
              ↓
       Drought Characteristics
              ↓
        Dry-Spell Analysis
              ↓
      Change-Point Detection
              ↓
    Hydroclimatic Regime Shifts
              ↓
       Regional Interpretation
# 5. Methodological Framework

The methodological framework was designed to evaluate climatic variability, hydroclimatic aridity, drought dynamics, dry-spell persistence, and structural regime changes across Southeastern Türkiye during 1991–2025.

The analysis integrates non-parametric trend analysis, robust slope estimation, change-point detection, drought indices, aridity indicators, event-based drought analysis, effect-size estimation, and climate–drought relationship analysis.

The overall methodological structure is:

```text
NASA POWER Daily Data
        │
        ▼
Data Quality Control
        │
        ▼
Monthly and Annual Aggregation
        │
        ▼
Climate Variability Analysis
        │
        ├───────────────┐
        ▼               ▼
Temperature         Precipitation
        │               │
        └───────┬───────┘
                ▼
       Trend Analysis
                │
        ┌───────┴────────┐
        ▼                ▼
Mann–Kendall        Sen's Slope
        │
        ▼
Change-Point Analysis
        │
   ┌────┼──────────┐
   ▼    ▼          ▼
Pettitt PELT     OLS-CUSUM
   │
   ▼
Potential Evapotranspiration
   │
   ▼
Aridity Assessment
   │
   ├───────────────┐
   ▼               ▼
De Martonne      P / PET
   │
   └───────┬───────┘
           ▼
      Drought Analysis
           │
      ┌────┴────┐
      ▼         ▼
    SPI-12    SPEI-12
      │         │
      └────┬────┘
           ▼
     Drought Events
           │
           ▼
 Frequency–Duration–Severity
           │
           ▼
     Dry-Spell Analysis
           │
           ▼
 Climate–Drought Relationships
           │
           ▼
 Hydroclimatic Regime Interpretation
## 5.1 Data Acquisition and Preparation

Daily meteorological data were obtained from the **NASA Prediction of Worldwide Energy Resources (NASA POWER)** database for nine provinces in Southeastern Türkiye covering the period **1991–2025**.

The analysis primarily used:

- **T2M** – Mean air temperature (°C)
- **PRECTOTCORR** – Corrected precipitation (mm/day)

Daily observations were processed in **R** and aggregated to monthly and annual time scales according to the requirements of the statistical analyses.

The preprocessing workflow included:

1. Date and variable formatting
2. Missing-value and data-quality checks
3. Monthly and annual aggregation
4. Calculation of climatic anomalies and variability indicators
5. Preparation of analysis-ready time series

The resulting dataset was used consistently throughout the trend, change-point, aridity, drought, dry-spell, and climate–drought relationship analyses.

---

## 5.2 Climatic Variability Analysis

Basic climatic characteristics were evaluated using:

- Mean
- Standard deviation
- Minimum and maximum values
- Coefficient of variation
- Annual anomalies
- Seasonal variability

This stage established the baseline climatic characteristics of the nine study locations before inferential statistical analysis.

---

## 5.3 Trend Analysis

Long-term trends were evaluated using the **Mann–Kendall test**, while the magnitude of trends was estimated using **Sen's slope estimator**.

The methods were applied to:

- Temperature
- Precipitation
- Potential evapotranspiration
- Aridity indices
- SPI-12
- SPEI-12
- Consecutive Dry Days

This combination provides both the **statistical significance** and **magnitude** of long-term changes.

### Trend Magnitude

![Sen's Slope Decadal Rates](Academic_Sens_Slope_Decadal_Rates.png)

---

## 5.4 Climate Regime Shift Analysis

Structural changes were investigated using three complementary methods:

| Method | Purpose |
|---|---|
| Pettitt Test | Detection of a dominant change point |
| PELT | Detection of multiple change points |
| OLS-CUSUM | Assessment of structural stability |

These methods were used to determine whether the observed climatic changes represented gradual trends or distinct shifts between climatic regimes.

### Temperature Regime Shift

![Temperature Regime Shift](Academic_Regime_Shift_T2M.png)

### Precipitation Regime Shift

![Precipitation Regime Shift](Academic_Regime_Shift_Precip.png)

---

## 5.5 Potential Evapotranspiration and Aridity

Potential evapotranspiration (**PET**) was estimated using the **Thornthwaite method**.

Two complementary aridity indicators were then calculated:

### De Martonne Aridity Index

\[
AI = \frac{P}{T+10}
\]

### UNEP Aridity Index

\[
AI = \frac{P}{PET}
\]

These indices were used to assess whether increasing temperature and evaporative demand were associated with progressive hydroclimatic aridification.

### De Martonne Aridity

![De Martonne Aridity](Academic_Aridity_DeMartonne_9Cities.png)

### UNEP P/PET Aridity

![UNEP Aridity](Academic_Aridity_UNEP_PPET_9Cities.png)

---

## 5.6 Drought Analysis

Meteorological drought was assessed using two complementary standardized indices:

- **SPI-12** — precipitation-based drought
- **SPEI-12** — precipitation and potential evapotranspiration-based drought

This distinction allows the study to evaluate whether drought conditions are influenced only by precipitation deficits or are amplified by increasing atmospheric evaporative demand.

### SPI-12 and SPEI-12

![SPI-12 vs SPEI-12](Academic_Drought_SPI12_vs_SPEI12_9Cities.png)

---

## 5.7 Drought Event Characteristics

Drought events were identified using a threshold of:

\[
SPI/SPEI \leq -1.0
\]

For each event, the following characteristics were calculated:

- Frequency
- Duration
- Severity
- Intensity

The relationship between drought duration and cumulative severity was also examined.

### Drought Frequency

![Drought Frequency](Academic_Drought_Events_Frequency.png)

### Duration–Severity Relationship

![Drought Duration Severity](Academic_Drought_Duration_vs_Severity.png)

---

## 5.8 Consecutive Dry Days

Dry-spell persistence was evaluated using **Consecutive Dry Days (CDD)**.

A dry day was defined as:

\[
P < 1.0\ mm/day
\]

The analysis focused on:

- Annual maximum CDD
- Seasonal CDD
- Long-term CDD trends

### Annual CDD

![Annual CDD](Academic_DrySpell_Annual_CDD_9Cities.png)

### Seasonal CDD

![Seasonal CDD](Academic_DrySpell_Seasonal_CDD_9Cities.png)

---

## 5.9 Effect Size and Climate–Drought Relationships

To complement statistical significance, **Cohen's *d*** was calculated to quantify the magnitude of differences between pre- and post-regime periods.

### Effect Size

![Cohen's d](Academic_Effect_Size_Cohen_ForestPlot.png)

Relationships between climatic drivers and drought indicators were evaluated using:

- **Pearson correlation** — linear relationships
- **Spearman correlation** — monotonic relationships

The principal relationships examined were:

- Precipitation ↔ SPI-12
- Temperature ↔ SPEI-12
- PET ↔ SPEI-12

### Climate–Drought Relationships

![Climate-Drought Correlations](Academic_Correlations_BarPlot_9Cities.png)

---

## 5.10 Integrated Analytical Framework

The complete analysis can be summarized as:

```text
NASA POWER Data
      ↓
Data Processing
      ↓
Climatic Variability
      ↓
Mann–Kendall + Sen's Slope
      ↓
Pettitt + PELT + OLS-CUSUM
      ↓
Thornthwaite PET
      ↓
De Martonne + P/PET Aridity
      ↓
SPI-12 + SPEI-12
      ↓
Drought Frequency–Duration–Severity
      ↓
Consecutive Dry Days
      ↓
Cohen's d + Correlation Analysis
      ↓
Hydroclimatic Regime Interpretation
