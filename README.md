# ==============================================================================
# CLIMATE VARIABILITY, ARIDITY AND DROUGHT REGIME ANALYSIS IN SOUTHEASTERN TÜRKİYE
# Author: Ahmet Solmaz
# Part 1: Data Acquisition, Dry Spells (ETCCDI), Regime Shifts & Effect Sizes
# ==============================================================================

if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, trend, changepoint, effsize, SPEI, openxlsx, ggplot2)

# 1. 9 Provincial Coordinates
cities_df <- tibble::tribble(
  ~City,       ~Lat,   ~Lon,
  "Diyarbakir", 37.91, 40.21,
  "Batman",     37.88, 41.13,
  "Siirt",      37.93, 41.94,
  "Kilis",      36.71, 37.11,
  "Gaziantep",  37.06, 37.38,
  "Sanliurfa",  37.16, 38.79,
  "Adiyaman",   37.76, 38.28,
  "Sirnak",     37.52, 42.46,
  "Mardin",     37.31, 40.74
)

start_year <- 1991
end_year   <- 2025
dry_thresh <- 1.0 # ETCCDI PR < 1.0 mm/day

cat("Downloading NASA POWER daily data (1991-2025)...\n")
daily_list <- list()

for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  cat(paste0(" -> Fetching: ", c_name, " (", i, "/9)\n"))
  
  df_raw <- get_power(
    community = "AG",
    pars = c("T2M", "PRECTOTCORR"),
    temporal_api = "daily",
    lonlat = c(cities_df$Lon[i], cities_df$Lat[i]),
    dates = c(paste0(start_year, "-01-01"), paste0(end_year, "-12-31"))
  ) %>%
    rename(date = YYYYMMDD, Precip = PRECTOTCORR) %>%
    mutate(
      City   = c_name,
      year   = year(date),
      month  = month(date),
      season = case_when(
        month %in% c(12, 1, 2) ~ "Winter",
        month %in% c(3, 4, 5)  ~ "Spring",
        month %in% c(6, 7, 8)  ~ "Summer",
        TRUE                   ~ "Autumn"
      ),
      is_dry = Precip < dry_thresh
    )
  
  daily_list[[c_name]] <- df_raw
}

df_daily_all <- bind_rows(daily_list)

# 2. CDD and CWD Calculation
calc_max_run <- function(vec, target_bool = TRUE) {
  runs <- rle(vec == target_bool)
  if (!any(runs$values)) return(0)
  max(runs$lengths[runs$values], na.rm = TRUE)
}

df_annual_spells <- df_daily_all %>%
  group_by(City, year) %>%
  summarise(
    Annual_Max_CDD  = calc_max_run(is_dry, TRUE),
    Annual_Max_CWD  = calc_max_run(is_dry, FALSE),
    Total_Dry_Days  = sum(is_dry, na.rm = TRUE),
    Total_Precip_mm = sum(Precip, na.rm = TRUE),
    .groups = "drop"
  )

df_seasonal_cdd <- df_daily_all %>%
  group_by(City, year, season) %>%
  summarise(
    Seasonal_Max_CDD = calc_max_run(is_dry, TRUE),
    .groups = "drop"
  )

# 3. Monthly PET (Thornthwaite) and Annual Aggregations
monthly_climate_list <- list()

for (c_name in cities_df$City) {
  c_lat <- cities_df$Lat[cities_df$City == c_name]
  df_c <- df_daily_all %>% filter(City == c_name)
  
  df_m <- df_c %>%
    group_by(year, month) %>%
    summarise(
      P_m = sum(Precip, na.rm = TRUE),
      T_m = mean(T2M, na.rm = TRUE),
      .groups = "drop"
    ) %>% arrange(year, month)
  
  pet_m <- as.numeric(thornthwaite(df_m$T_m, lat = c_lat))
  df_m <- df_m %>% mutate(PET_m = pet_m, D_m = P_m - PET_m)
  
  spi12  <- as.numeric(spi(df_m$P_m, scale = 12)$fitted)
  spei12 <- as.numeric(spei(df_m$D_m, scale = 12)$fitted)
  
  monthly_climate_list[[c_name]] <- df_m %>%
    mutate(City = c_name, Date = make_date(year, month, 1), SPI_12 = spi12, SPEI_12 = spei12)
}

df_monthly_all <- bind_rows(monthly_climate_list)

df_annual_climate <- df_monthly_all %>%
  group_by(City, year) %>%
  summarise(
    Precip_mm = sum(P_m, na.rm = TRUE),
    Tmean_C   = mean(T_m, na.rm = TRUE),
    PET_mm    = sum(PET_m, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(df_annual_spells %>% select(City, year, Annual_Max_CDD, Annual_Max_CWD), by = c("City", "year"))

# 4. Effect Size (Cohen's d) & Trend & Regime Shifts
effect_size_results <- list()
target_vars <- c("Tmean_C", "Precip_mm", "PET_mm", "Annual_Max_CDD")

for (c_name in cities_df$City) {
  df_c <- df_annual_climate %>% filter(City == c_name) %>% arrange(year)
  
  for (v in target_vars) {
    ts_vec <- df_c[[v]]
    years  <- df_c$year
    
    sen_res  <- trend::sens.slope(ts_vec)
    slope_yr <- as.numeric(sen_res$estimates)
    mk_res   <- trend::mk.test(ts_vec)
    
    pet_test   <- trend::pettitt.test(ts_vec)
    break_idx  <- as.numeric(pet_test$estimate)
    break_year <- years[break_idx]
    
    vec_r1 <- ts_vec[years <= break_year]
    vec_r2 <- ts_vec[years > break_year]
    
    m1 <- mean(vec_r1, na.rm = TRUE)
    m2 <- mean(vec_r2, na.rm = TRUE)
    
    cohen_obj <- effsize::cohen.d(vec_r2, vec_r1)
    cohen_d   <- as.numeric(cohen_obj$estimate)
    
    effect_size_results[[paste(c_name, v, sep = "_")]] <- tibble(
      City                    = c_name,
      Variable                = v,
      Break_Year              = break_year,
      MK_p_value              = round(as.numeric(mk_res$p.value), 4),
      Sens_Slope_Per_Decade   = round(slope_yr * 10, 3),
      Regime_1_Mean           = round(m1, 2),
      Regime_2_Mean           = round(m2, 2),
      Percentage_Shift_Pct    = round(((m2 - m1) / m1) * 100, 2),
      Cohens_d                = round(cohen_d, 3),
      Cohens_d_CI_Low         = round(cohen_obj$conf.int[1], 3),
      Cohens_d_CI_High        = round(cohen_obj$conf.int[2], 3),
      Effect_Magnitude        = case_when(
        abs(cohen_d) < 0.2 ~ "Negligible",
        abs(cohen_d) < 0.5 ~ "Small",
        abs(cohen_d) < 0.8 ~ "Medium",
        TRUE               ~ "Large"
      )
    )
  }
}

df_effect_sizes <- bind_rows(effect_size_results)

# Theme for Graphics (Ahmet Solmaz Publication Style)
theme_academic <- function() {
  theme_bw(base_size = 9) +
    theme(
      text = element_text(family = "sans"),
      plot.title = element_text(face = "bold", size = 11, hjust = 0.5),
      plot.subtitle = element_text(size = 8.5, hjust = 0.5, color = "gray30"),
      axis.title = element_text(face = "bold", size = 9),
      axis.text = element_text(color = "black", size = 7.5),
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "gray92", color = "black"),
      legend.position = "bottom"
    )
}

# Figures Generation
p_cdd_annual <- ggplot(df_annual_spells, aes(x = year, y = Annual_Max_CDD)) +
  geom_line(color = "gray40", linewidth = 0.4) +
  geom_point(color = "#d95f02", size = 0.8) +
  geom_smooth(method = "lm", se = FALSE, color = "darkred", linewidth = 0.7) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  labs(
    title = "Annual Maximum Consecutive Dry Days (CDD) across 9 Provinces (1991–2025)",
    subtitle = "ETCCDI Threshold: PR < 1.0 mm/day | Designed by Ahmet Solmaz",
    x = "Year", y = "Maximum CDD (Days)"
  ) + theme_academic()

p_forest_cohen <- ggplot(df_effect_sizes, aes(x = Cohens_d, y = City, color = Effect_Magnitude)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray40") +
  geom_errorbarh(aes(xmin = Cohens_d_CI_Low, xmax = Cohens_d_CI_High), height = 0.2) +
  geom_point(size = 2.2) +
  facet_wrap(~Variable, ncol = 2, scales = "free_x") +
  scale_color_manual(values = c("Large"="#d95f02", "Medium"="#7570b3", "Small"="#2b5c8f", "Negligible"="gray50")) +
  labs(
    title = "Standardized Regime Shift Magnitude (Cohen's d) across 9 Provinces",
    subtitle = "Quantifying physical shift significance | Designed by Ahmet Solmaz",
    x = "Cohen's d (Regime 2 vs Regime 1)", y = "Province", color = "Effect Magnitude Class"
  ) + theme_academic()

ggsave("figures/Academic_DrySpell_Annual_CDD_9Cities.png", plot = p_cdd_annual, width = 11, height = 8, dpi = 300)
ggsave("figures/Academic_Effect_Size_Cohen_ForestPlot.png", plot = p_forest_cohen, width = 11, height = 8, dpi = 300)

cat("Part 1 complete! Saved data and initial figures.\n")
# ==============================================================================
# CLIMATE VARIABILITY, ARIDITY AND DROUGHT REGIME ANALYSIS IN SOUTHEASTERN TÜRKİYE
# Author: Ahmet Solmaz
# Part 2: Climate-Drought Coupling, Regime Shift Visualizations & Consolidated Excel
# ==============================================================================

# 1. Pearson vs. Spearman Coupling
pairs_to_test <- list(
  list(x = "P_m",    y = "SPI_12",  label = "Precipitation vs SPI-12"),
  list(x = "T_m",    y = "SPEI_12", label = "Temperature vs SPEI-12"),
  list(x = "PET_m",  y = "SPEI_12", label = "PET vs SPEI-12")
)

cor_results_list <- list()

for (c_name in cities_df$City) {
  df_c <- df_monthly_all %>% filter(City == c_name) %>% drop_na(SPI_12, SPEI_12)
  
  for (pair in pairs_to_test) {
    vx <- df_c[[pair$x]]
    vy <- df_c[[pair$y]]
    
    p_cor <- cor.test(vx, vy, method = "pearson")
    s_cor <- cor.test(vx, vy, method = "spearman", exact = FALSE)
    
    cor_results_list[[paste(c_name, pair$x, pair$y, sep = "_")]] <- tibble(
      City             = c_name,
      Relationship     = pair$label,
      Pearson_r        = round(as.numeric(p_cor$estimate), 3),
      Pearson_p_value  = round(as.numeric(p_cor$p.value), 4),
      Spearman_rho     = round(as.numeric(s_cor$estimate), 3),
      Spearman_p_value = round(as.numeric(s_cor$p.value), 4)
    )
  }
}

df_correlations <- bind_rows(cor_results_list)

# 2. Additional Visualizations (Ahmet Solmaz Signature Series)
p_cor_bar <- ggplot(df_correlations, aes(x = City, y = Pearson_r, fill = Relationship)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  scale_fill_manual(values = c("Precipitation vs SPI-12"="#2b5c8f", "Temperature vs SPEI-12"="#d95f02", "PET vs SPEI-12"="#7570b3")) +
  labs(
    title = "Climate–Drought Sensitivity Across 9 Provinces (Pearson Linear Correlation)",
    subtitle = "Designed and executed by Ahmet Solmaz",
    x = "Province", y = "Pearson Correlation Coefficient (r)", fill = "Variable Pair"
  ) + theme_academic() + theme(axis.text.x = element_text(angle = 30, hjust = 1))

t2m_breaks <- df_effect_sizes %>% filter(Variable == "Tmean_C") %>% select(City, Break_Year)

df_plot_t2m <- df_annual_climate %>%
  left_join(t2m_breaks, by = "City") %>%
  mutate(Regime = ifelse(year <= Break_Year, "Regime 1 (Pre-Break)", "Regime 2 (Post-Break)"))

p_regime_t2m <- ggplot(df_plot_t2m, aes(x = year, y = Tmean_C)) +
  geom_line(color = "gray50", linewidth = 0.4) +
  geom_point(aes(color = Regime), size = 1) +
  geom_vline(aes(xintercept = Break_Year), color = "black", linetype = "dashed", linewidth = 0.6) +
  stat_summary(aes(group = Regime, color = Regime), fun = mean, geom = "line", linewidth = 1) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  scale_color_manual(values = c("Regime 1 (Pre-Break)" = "#2b5c8f", "Regime 2 (Post-Break)" = "#d95f02")) +
  labs(
    title = "Annual Mean Temperature Climate Regime Shifts across 9 Provinces",
    subtitle = "Pettitt change-point detection | Designed by Ahmet Solmaz",
    x = "Year", y = "Temperature (°C)", color = "Climatic Regime"
  ) + theme_academic()

p_pet_spei <- ggplot(df_monthly_all %>% drop_na(PET_m, SPEI_12), aes(x = PET_m, y = SPEI_12)) +
  geom_point(alpha = 0.25, size = 0.7, color = "#7570b3") +
  geom_smooth(method = "lm", color = "darkred", linewidth = 0.7, se = FALSE) +
  geom_smooth(method = "loess", color = "blue", linetype = "dashed", linewidth = 0.6, se = FALSE) +
  facet_wrap(~City, ncol = 3) +
  labs(
    title = "Evaporative Demand (PET) vs. SPEI-12 Coupling across 9 Provinces",
    subtitle = "Solid red line: Linear Pearson | Dashed blue line: LOESS Spearman | Designed by Ahmet Solmaz",
    x = "Potential Evapotranspiration - PET (mm/month)", y = "SPEI-12 Index"
  ) + theme_academic()

ggsave("figures/Academic_Correlations_BarPlot_9Cities.png", plot = p_cor_bar, width = 11, height = 6.5, dpi = 300)
ggsave("figures/Academic_Regime_Shift_T2M_Time_Series.png", plot = p_regime_t2m, width = 11, height = 8, dpi = 300)
ggsave("figures/Academic_Scatter_PET_vs_SPEI12_9Cities.png", plot = p_pet_spei, width = 11, height = 8, dpi = 300)

# 3. Consolidated Excel Report Generation (openxlsx)
wb <- createWorkbook()

addWorksheet(wb, "Effect_Size_Summary")
writeData(wb, "Effect_Size_Summary", df_effect_sizes)

addWorksheet(wb, "Correlation_Analysis")
writeData(wb, "Correlation_Analysis", df_correlations)

addWorksheet(wb, "Annual_Climate_Spells")
writeData(wb, "Annual_Climate_Spells", df_annual_climate)

addWorksheet(wb, "Monthly_Indices_Data")
writeData(wb, "Monthly_Indices_Data", df_monthly_all)

# Embed Key Figures in Excel
addWorksheet(wb, "Visual_Outputs")
insertImage(wb, "Visual_Outputs", "figures/Academic_Effect_Size_Cohen_ForestPlot.png", width = 10, height = 7, startRow = 2, startCol = 2)
insertImage(wb, "Visual_Outputs", "figures/Academic_Regime_Shift_T2M_Time_Series.png", width = 10, height = 7, startRow = 38, startCol = 2)
insertImage(wb, "Visual_Outputs", "figures/Academic_Correlations_BarPlot_9Cities.png", width = 10, height = 6, startRow = 74, startCol = 2)

excel_path <- "outputs/Climate_Regime_Shift_and_Effect_Size_9Cities.xlsx"
dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
saveWorkbook(wb, excel_path, overwrite = TRUE)

cat("\nFull multi-decadal analysis complete! Results exported to Excel and figures folder.\n")
