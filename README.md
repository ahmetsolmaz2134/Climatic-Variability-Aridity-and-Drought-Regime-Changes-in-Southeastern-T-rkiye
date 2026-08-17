# Climatic Variability, Aridity and Drought Regime Changes in Southeastern Türkiye

### A NASA POWER-Based Hydroclimatological Assessment

---

## Overview

This repository presents a hydroclimatological assessment of climatic variability, aridity, and drought regime changes across Southeastern Türkiye using NASA POWER meteorological data and statistical time-series analysis.

The study is designed to investigate climate change not only through conventional temperature and precipitation trends, but also through changes in:

- climatic variability,
- atmospheric moisture conditions,
- potential evapotranspiration,
- aridity,
- drought frequency,
- drought duration,
- drought severity,
- dry-spell characteristics,
- and hydroclimatic regime structure.

The central conceptual framework of the study is:

**Climate Variability → Atmospheric Drying → Aridity Change → Drought Regime Change**

The analysis is implemented in **R** and is designed as a reproducible hydroclimatological workflow.

---

## Study Region

### Southeastern Türkiye

The study focuses on the major climatic characteristics of Southeastern Türkiye, a region characterized by:

- semi-arid to dry sub-humid climatic conditions,
- strong seasonal precipitation variability,
- high summer temperatures,
- high potential evapotranspiration,
- recurrent meteorological drought,
- and increasing sensitivity to climatic water stress.

The study evaluates spatial and temporal differences among representative locations across Southeastern Türkiye.

---

## Research Motivation

Climate change in semi-arid environments cannot be adequately described using temperature trends alone.

Changes in precipitation, atmospheric moisture, evapotranspiration, and drought persistence may interact and produce substantial changes in the regional hydroclimatic regime.

Therefore, this study asks whether the climatic characteristics of Southeastern Türkiye are undergoing a transition toward:

> **warmer, drier, and more persistent hydroclimatic conditions.**

The study particularly focuses on whether changes in climatic variability are accompanied by systematic changes in aridity and drought characteristics.

---

# Research Questions

The study addresses the following research questions:

### RQ1 — Climatic Variability

How have temperature and precipitation characteristics changed across Southeastern Türkiye?

### RQ2 — Seasonal Structure

Have the seasonal characteristics of temperature and precipitation changed over time?

### RQ3 — Atmospheric Drying

Is there evidence of increasing atmospheric dryness and evaporative demand?

### RQ4 — Aridity

Has the regional aridity regime changed during the study period?

### RQ5 — Drought

Have drought frequency, duration, and severity changed over time?

### RQ6 — Dry Spells

Have consecutive dry-day characteristics changed?

### RQ7 — Regime Changes

Can statistically significant climatic or drought regime shifts be identified?

### RQ8 — Hydroclimatic Transformation

Is Southeastern Türkiye experiencing a coherent transition toward a warmer and/or more arid hydroclimatic regime?

---

# Data Source

## NASA POWER

Meteorological data are obtained from the:

**NASA Prediction of Worldwide Energy Resources (POWER)**

NASA POWER provides analysis-ready meteorological and solar time series at daily, monthly, annual, and climatological temporal scales.

Daily POWER data are available from **1981 to near-real-time**, providing an appropriate temporal framework for long-term hydroclimatological analysis.

Source:

https://power.larc.nasa.gov/

NASA POWER Documentation:

https://power.larc.nasa.gov/docs/

NASA POWER Daily API:

https://power.larc.nasa.gov/docs/services/api/temporal/daily/

---

# Study Period

### Primary Analysis Period

**1981–2025**

The primary analysis period is selected to provide a consistent long-term climate record while avoiding interpretation of incomplete current-year observations.

The temporal framework may be extended when complete and quality-controlled data become available.

---

# Meteorological Variables

The analysis will primarily use the following NASA POWER variables:

| Variable | NASA POWER Parameter | Unit | Purpose |
|---|---|---:|---|
| Mean Air Temperature | T2M | °C | Temperature variability |
| Maximum Air Temperature | T2M_MAX | °C | Thermal extremes |
| Minimum Air Temperature | T2M_MIN | °C | Night-time warming |
| Precipitation | PRECTOTCORR | mm/day | Precipitation variability |
| Relative Humidity | RH2M | % | Atmospheric moisture |
| Wind Speed | WS10M | m/s | Atmospheric conditions |
| Solar Radiation | ALLSKY_SFC_SW_DWN | kWh/m²/day | Radiative conditions |

Additional parameters may be incorporated where required by specific hydroclimatic indices.

---

# Methodological Framework

The analysis is organized into five major components.

## 1. Climate Variability

The first stage characterizes long-term variability in:

- mean temperature,
- maximum temperature,
- minimum temperature,
- precipitation,
- relative humidity,
- wind speed,
- and solar radiation.

### Temporal scales

Analysis will be conducted at:

- monthly,
- seasonal,
- annual,
- and climatological scales.

---

# 2. Temperature and Precipitation Trends

Long-term trends will be evaluated using:

### Mann–Kendall Test

Used to determine the statistical significance of monotonic trends.

### Sen's Slope Estimator

Used to estimate the magnitude and direction of the trend.

### Seasonal Mann–Kendall

Used where seasonal dependence is important.

### Trend-free Pre-whitening

Applied where serial correlation may influence trend significance.

---

# 3. Hydroclimatic Aridity

The second major component evaluates changes in regional moisture availability and aridity.

Potential evapotranspiration and moisture conditions will be used to characterize hydroclimatic drying.

### Main indicators

- Potential Evapotranspiration (PET)
- Aridity Index
- De Martonne Aridity Index
- Moisture availability
- Precipitation/PET relationship
- SPEI

The objective is to determine whether increasing thermal demand is accompanied by declining effective moisture availability.

---

# 4. Drought Regime Analysis

Meteorological drought will be evaluated using standardized drought indices.

## Standardized Precipitation Index

Multiple accumulation periods will be evaluated:

- SPI-1
- SPI-3
- SPI-6
- SPI-12

These timescales allow the identification of:

- short-term precipitation deficits,
- seasonal drought,
- medium-term drought,
- and long-term hydroclimatic drought.

---

## Standardized Precipitation Evapotranspiration Index

SPEI will be used to incorporate both:

**precipitation variability**

and

**atmospheric evaporative demand**

into drought assessment.

This allows the analysis to move beyond precipitation-only drought characterization.

---

# 5. Drought Characteristics

Individual drought events will be characterized according to:

### Frequency

Number of drought events per year or analysis period.

### Duration

Number of consecutive months affected by drought.

### Severity

Cumulative drought intensity during an event.

### Intensity

Mean standardized drought anomaly during an event.

### Onset and Termination

Beginning and ending dates of drought events.

---

# Dry-Spell Analysis

Daily precipitation data will be used to characterize dry periods.

The analysis will include:

- Consecutive Dry Days (CDD)
- Consecutive Wet Days (CWD)
- Maximum dry-spell duration
- Annual dry-spell frequency
- Seasonal dry-spell characteristics
- Changes in dry-spell persistence

A dry day will be defined using a precipitation threshold specified in the methodological section of the final analysis.

---

# Climate and Drought Regime Shifts

A major objective of the study is to determine whether the regional climate system exhibits statistically detectable regime changes.

## Change-Point Analysis

The following methods will be considered:

### Pettitt Test

Identification of statistically significant single change points.

### CUSUM

Detection of shifts in the mean structure of time series.

### PELT

Identification of multiple structural change points.

The final change-point method will be selected according to the statistical properties of each variable.

---

# Hydroclimatic Regime Classification

The study will compare periods before and after statistically identified regime shifts.

For each identified regime, the following characteristics will be calculated:

- mean temperature,
- temperature variability,
- precipitation,
- precipitation variability,
- PET,
- aridity,
- SPI,
- SPEI,
- drought frequency,
- drought duration,
- drought severity,
- and dry-spell persistence.

This allows the study to move from conventional trend analysis toward **hydroclimatic regime analysis**.

---

# Statistical Framework

The general statistical workflow is:

```text
NASA POWER Data
        ↓
Data Quality Control
        ↓
Temporal Aggregation
        ↓
Climate Variability Analysis
        ↓
Temperature & Precipitation Trends
        ↓
PET / Aridity Assessment
        ↓
SPI / SPEI Drought Analysis
        ↓
Dry-Spell Analysis
        ↓
Change-Point Detection
        ↓
Hydroclimatic Regime Identification
        ↓
Spatial & Temporal Interpretation
