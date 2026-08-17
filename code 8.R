# 1. Gerekli Paketlerin Y??klenmesi
if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, trend, changepoint, SPEI, openxlsx, ggplot2)

# 2. 9 ??l ve Koordinat Tan??mlar??
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
vars <- c("T2M", "PRECTOTCORR")

# 3. NASA POWER Verisinin ??ekilmesi ve Y??ll??k ??klim/PET De??i??kenlerinin Olu??turulmas??
cat("Downloading climate data and extracting annual time series (1991???2025)...\n")

annual_climate_list <- list()

for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  c_lat  <- cities_df$Lat[i]
  c_lon  <- cities_df$Lon[i]
  
  cat(paste0(" -> Processing: ", c_name, " (", i, "/9)\n"))
  
  df_daily <- get_power(
    community = "AG",
    pars = vars,
    temporal_api = "daily",
    lonlat = c(c_lon, c_lat),
    dates = c(paste0(start_year, "-01-01"), paste0(end_year, "-12-31"))
  )
  
  df_m <- df_daily %>%
    rename(date = YYYYMMDD) %>%
    mutate(year = year(date), month = month(date)) %>%
    group_by(year, month) %>%
    summarise(
      P_monthly = sum(PRECTOTCORR, na.rm = TRUE),
      T_monthly = mean(T2M, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year, month)
  
  pet_monthly <- as.numeric(thornthwaite(df_m$T_monthly, lat = c_lat))
  df_m <- df_m %>% mutate(PET_monthly = pet_monthly)
  
  df_ann <- df_m %>%
    group_by(year) %>%
    summarise(
      City        = c_name,
      Precip_mm   = sum(P_monthly, na.rm = TRUE),
      Tmean_C     = mean(T_monthly, na.rm = TRUE),
      PET_mm      = sum(PET_monthly, na.rm = TRUE),
      Aridity_P_PET = Precip_mm / PET_mm,
      .groups = "drop"
    )
  
  annual_climate_list[[c_name]] <- df_ann
}

df_all_annual <- bind_rows(annual_climate_list)

# ==============================================================================
# 4. PETTITT VE PELT KIRILMA NOKTASI TESP??T?? VE REJ??M KAR??ILA??TIRMASI
# ==============================================================================

regime_comp_list <- list()
target_vars <- c("Tmean_C", "Precip_mm", "PET_mm", "Aridity_P_PET")

for (c_name in cities_df$City) {
  df_c <- df_all_annual %>% filter(City == c_name) %>% arrange(year)
  
  for (v in target_vars) {
    ts_vec <- df_c[[v]]
    years  <- df_c$year
    N      <- length(ts_vec)
    
    # 1. Pettitt Change-Point Test
    pet_res    <- trend::pettitt.test(ts_vec)
    k_pettitt  <- as.numeric(pet_res$estimate)
    p_pettitt  <- as.numeric(pet_res$p.value)
    break_yr_pet <- years[k_pettitt]
    
    # 2. PELT Algorithm (Mean & Variance Shifts)
    pelt_cpt   <- changepoint::cpt.meanvar(ts_vec, method = "PELT", penalty = "MBIC")
    cpt_pts    <- changepoint::cpts(pelt_cpt)
    break_yr_pelt <- if (length(cpt_pts) > 0) years[cpt_pts[1]] else break_yr_pet
    
    # Ana k??r??lma y??l?? olarak Pettitt tercih ediliyor
    break_yr <- break_yr_pet
    
    # Seriyi Rejim 1 ve Rejim 2 olarak ay??rma
    r1_idx <- which(years <= break_yr)
    r2_idx <- which(years > break_yr)
    
    vec_r1 <- ts_vec[r1_idx]
    vec_r2 <- ts_vec[r2_idx]
    
    m1 <- mean(vec_r1, na.rm = TRUE)
    m2 <- mean(vec_r2, na.rm = TRUE)
    sd1 <- sd(vec_r1, na.rm = TRUE)
    sd2 <- sd(vec_r2, na.rm = TRUE)
    
    abs_diff <- m2 - m1
    pct_diff <- ifelse(m1 != 0, (abs_diff / m1) * 100, NA)
    
    # Hipotez Testleri (Rejimler aras?? fark??n anlaml??l??????)
    ttest_p   <- t.test(vec_r1, vec_r2)$p.value
    wilcox_p  <- wilcox.test(vec_r1, vec_r2)$p.value
    
    regime_comp_list[[paste(c_name, v, sep = "_")]] <- tibble(
      City                  = c_name,
      Variable              = v,
      Pettitt_Break_Year    = break_yr_pet,
      Pettitt_p_value       = round(p_pettitt, 4),
      Pettitt_Sig           = ifelse(p_pettitt < 0.05, "Significant Shift", "Not Significant"),
      PELT_Break_Year       = break_yr_pelt,
      Regime_1_Period       = paste0(min(years[r1_idx]), "???", max(years[r1_idx])),
      Regime_2_Period       = paste0(min(years[r2_idx]), "???", max(years[r2_idx])),
      Regime_1_Mean         = round(m1, 2),
      Regime_1_SD           = round(sd1, 2),
      Regime_2_Mean         = round(m2, 2),
      Regime_2_SD           = round(sd2, 2),
      Absolute_Change       = round(abs_diff, 2),
      Percentage_Change_Pct = round(pct_diff, 2),
      t_Test_p_value        = round(ttest_p, 4),
      Wilcoxon_p_value      = round(wilcox_p, 4),
      Regime_Difference_Sig = ifelse(wilcox_p < 0.05, "Significant Difference (p<0.05)", "No Significant Difference")
    )
  }
}

df_regime_summary <- bind_rows(regime_comp_list)

# ==============================================================================
# 5. AKADEM??K D??ZEYDE ??NG??L??ZCE REJ??M DE????????M GRAF??KLER??
# ==============================================================================

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

# Grafik 1: S??cakl??k (Tmean) Rejim K??r??lmalar?? ve ??ki D??nem Ortalama ??izgileri
t2m_breaks <- df_regime_summary %>% filter(Variable == "Tmean_C") %>% select(City, Pettitt_Break_Year)

df_plot_t2m <- df_all_annual %>%
  left_join(t2m_breaks, by = "City") %>%
  mutate(Regime = ifelse(year <= Pettitt_Break_Year, "Regime 1 (Pre-Break)", "Regime 2 (Post-Break)"))

p_regime_t2m <- ggplot(df_plot_t2m, aes(x = year, y = Tmean_C)) +
  geom_line(color = "gray50", linewidth = 0.4) +
  geom_point(aes(color = Regime), size = 1) +
  geom_vline(aes(xintercept = Pettitt_Break_Year), color = "black", linetype = "dashed", linewidth = 0.6) +
  stat_summary(aes(group = Regime, color = Regime), fun = mean, geom = "line", linewidth = 1) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  scale_color_manual(values = c("Regime 1 (Pre-Break)" = "#2b5c8f", "Regime 2 (Post-Break)" = "#d95f02")) +
  labs(
    title = "Annual Mean Temperature (Tmean) Climate Regime Shifts across 9 Provinces",
    subtitle = "Dashed line indicates Pettitt change-point | Thick lines mark Regime 1 vs Regime 2 mean state",
    x = "Year",
    y = "Temperature (??C)",
    color = "Climatic Regime"
  ) +
  theme_academic()

# Grafik 2: Rejim 1 vs Rejim 2 S??cakl??k ve Buharla??ma (PET) Y??zde De??i??im ??ubuk Grafi??i
df_bar_change <- df_regime_summary %>%
  filter(Variable %in% c("Tmean_C", "PET_mm"))

p_regime_change_bar <- ggplot(df_bar_change, aes(x = City, y = Percentage_Change_Pct, fill = Variable)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", linewidth = 0.5) +
  scale_fill_manual(
    values = c("Tmean_C" = "#d95f02", "PET_mm" = "#7570b3"),
    labels = c("Tmean (??C)", "PET (mm)")
  ) +
  labs(
    title = "Percentage Shift (%) from Regime 1 to Regime 2 across 9 Provinces",
    subtitle = "Quantifying post-break thermal warming and evaporative demand acceleration",
    x = "Province",
    y = "Percentage Change (%)",
    fill = "Climatic Variable"
  ) +
  theme_academic() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("Academic_Regime_Shift_T2M_Time_Series.png", plot = p_regime_t2m, width = 11, height = 8, dpi = 300)
ggsave("Academic_Regime_Shift_Percentage_Bar.png", plot = p_regime_change_bar, width = 10, height = 6, dpi = 300)

# ==============================================================================
# 6. EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Detailed Regime Comparison Table
addWorksheet(wb, "Regime_Comparison_Summary")
writeData(wb, "Regime_Comparison_Summary", df_regime_summary)

# Sheet 2: Annual Climate Metrics (1991-2025)
addWorksheet(wb, "Annual_Climate_Data")
writeData(wb, "Annual_Climate_Data", df_all_annual)

# Sheet 3: High-Resolution Visualizations
addWorksheet(wb, "Regime_Shift_Plots")
insertImage(wb, "Regime_Shift_Plots", "Academic_Regime_Shift_T2M_Time_Series.png", width = 10, height = 7, startRow = 2, startCol = 2)
insertImage(wb, "Regime_Shift_Plots", "Academic_Regime_Shift_Percentage_Bar.png", width = 10, height = 6, startRow = 38, startCol = 2)

# Save Workbook
excel_output <- "Climate_Regime_Shift_Analysis_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nRegime comparison analysis completed! File saved to: ", excel_output, "\n")