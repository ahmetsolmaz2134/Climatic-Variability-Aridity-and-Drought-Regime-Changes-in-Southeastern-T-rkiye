# 1. Gerekli Paketlerin Y??klenmesi
if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, trend, changepoint, strucchange, openxlsx, ggplot2)

# 2. Do??ru 9 ??l ve Koordinat Tan??mlar?? (G??neydo??u Anadolu Havzas??)
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
vars <- c("T2M", "T2M_MAX", "T2M_MIN", "PRECTOTCORR", "RH2M", "WS10M")

# 3. T??m ??ller ????in Veri ??ekme ve Y??ll??k ??klim Serilerinin Haz??rlanmas??
cat("Fetching NASA POWER data for the 9 correct provinces...\n")
all_cities_annual <- list()

for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  cat(paste0(" -> Downloading: ", c_name, " (", i, "/", nrow(cities_df), ")\n"))
  
  raw_data <- get_power(
    community = "AG",
    pars = vars,
    temporal_api = "daily",
    lonlat = c(cities_df$Lon[i], cities_df$Lat[i]),
    dates = c(paste0(start_year, "-01-01"), paste0(end_year, "-12-31"))
  )
  
  annual_data <- raw_data %>%
    rename(date = YYYYMMDD) %>%
    mutate(year = year(date)) %>%
    group_by(year) %>%
    summarise(
      City        = c_name,
      T2M         = mean(T2M, na.rm = TRUE),
      T2M_MAX     = mean(T2M_MAX, na.rm = TRUE),
      T2M_MIN     = mean(T2M_MIN, na.rm = TRUE),
      PRECTOTCORR = sum(PRECTOTCORR, na.rm = TRUE),
      RH2M        = mean(RH2M, na.rm = TRUE),
      WS10M       = mean(WS10M, na.rm = TRUE),
      .groups = "drop"
    )
  
  all_cities_annual[[c_name]] <- annual_data
}

df_all_annual <- bind_rows(all_cities_annual)

# ==============================================================================
# 4. DE????????M NOKTASI ANAL??Z?? (PETTITT + PELT + CUSUM)
# ==============================================================================

pettitt_results <- list()
pelt_results    <- list()
cusum_results   <- list()

for (city_curr in cities_df$City) {
  city_sub <- df_all_annual %>% filter(City == city_curr)
  
  for (v in vars) {
    ts_vec <- city_sub[[v]]
    years  <- city_sub$year
    n      <- length(ts_vec)
    
    # A. PETTITT TESTI (Tek K??r??lma Noktas?? ve D??nem Kar????la??t??rmas??)
    pet_test <- trend::pettitt.test(ts_vec)
    k_idx    <- pet_test$estimate
    k_year   <- years[k_idx]
    p_val    <- pet_test$p.value
    
    pre_mean  <- mean(ts_vec[1:k_idx], na.rm = TRUE)
    post_mean <- mean(ts_vec[(k_idx + 1):n], na.rm = TRUE)
    abs_diff  <- post_mean - pre_mean
    pct_diff  <- (abs_diff / abs(pre_mean)) * 100
    
    pettitt_results[[paste(city_curr, v, sep = "_")]] <- tibble(
      City              = city_curr,
      Variable          = v,
      Break_Year        = k_year,
      Pettitt_Stat_K    = pet_test$statistic,
      p_value           = round(p_val, 4),
      Significance      = ifelse(p_val < 0.05, "Significant (p < 0.05)", "Not Significant"),
      Pre_Break_Period  = paste0(min(years), "???", k_year),
      Post_Break_Period = paste0(k_year + 1, "???", max(years)),
      Pre_Break_Mean    = round(pre_mean, 2),
      Post_Break_Mean   = round(post_mean, 2),
      Mean_Change_Abs   = round(abs_diff, 2),
      Mean_Change_Pct   = round(pct_diff, 2)
    )
    
    # B. PELT ALGORT??MASI (??oklu Rejim K??r??lmas??)
    pelt_cpt <- changepoint::cpt.meanvar(ts_vec, method = "PELT", penalty = "MBIC")
    pelt_idx <- changepoint::cpts(pelt_cpt)
    
    pelt_years_str <- if(length(pelt_idx) > 0) {
      paste(years[pelt_idx], collapse = ", ")
    } else {
      "No Break Detected"
    }
    
    pelt_results[[paste(city_curr, v, sep = "_")]] <- tibble(
      City              = city_curr,
      Variable          = v,
      Num_Breakpoints   = length(pelt_idx),
      Break_Years       = pelt_years_str
    )
    
    # C. CUSUM TEST?? (Yap??sal Kararl??l??k Destek Analizi)
    cusum_efp  <- strucchange::efp(ts_vec ~ 1, type = "OLS-CUSUM")
    cusum_test <- strucchange::sctest(cusum_efp)
    
    cusum_results[[paste(city_curr, v, sep = "_")]] <- tibble(
      City         = city_curr,
      Variable     = v,
      CUSUM_Stat   = round(cusum_test$statistic, 3),
      p_value      = round(cusum_test$p.value, 4),
      Stability    = ifelse(cusum_test$p.value < 0.05, "Structural Shift", "Stable")
    )
  }
}

df_pettitt_summary <- bind_rows(pettitt_results)
df_pelt_summary    <- bind_rows(pelt_results)
df_cusum_summary   <- bind_rows(cusum_results)

# ==============================================================================
# 5. AKADEM??K D??ZEYDE ??NG??L??ZCE GRAF??K YAZDIRMA
# ==============================================================================

theme_academic <- function() {
  theme_bw(base_size = 10) +
    theme(
      text = element_text(family = "sans"),
      plot.title = element_text(face = "bold", size = 11, hjust = 0.5),
      plot.subtitle = element_text(size = 8.5, hjust = 0.5, color = "gray30"),
      axis.title = element_text(face = "bold", size = 9),
      axis.text = element_text(color = "black", size = 8),
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "gray92", color = "black"),
      strip.text = element_text(face = "bold", size = 8.5)
    )
}

# 9 ??l ????in S??cakl??k (T2M) Pettitt K??r??lma Grafi??i
p_t2m <- ggplot(df_all_annual, aes(x = year, y = T2M)) +
  geom_line(color = "gray50", linewidth = 0.5) +
  geom_point(color = "black", size = 0.8) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  geom_vline(
    data = df_pettitt_summary %>% filter(Variable == "T2M"),
    aes(xintercept = Break_Year), color = "red", linetype = "dashed", linewidth = 0.6
  ) +
  labs(
    title = "Regime Shift Analysis for Mean Temperature (T2M) across 9 Provinces",
    subtitle = "Red dashed lines indicate Pettitt single change-points (1991???2025)",
    x = "Year",
    y = "Temperature (??C)"
  ) +
  theme_academic()

# 9 ??l ????in Ya?????? (PRECTOTCORR) K??r??lma Grafi??i
p_prec <- ggplot(df_all_annual, aes(x = year, y = PRECTOTCORR)) +
  geom_line(color = "#2b5c8f", linewidth = 0.5) +
  geom_point(color = "#2b5c8f", size = 0.8) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  geom_vline(
    data = df_pettitt_summary %>% filter(Variable == "PRECTOTCORR"),
    aes(xintercept = Break_Year), color = "darkgreen", linetype = "dashed", linewidth = 0.6
  ) +
  labs(
    title = "Annual Precipitation (PRECTOTCORR) Change-Point Analysis",
    subtitle = "Green dashed lines represent Pettitt structural break points",
    x = "Year",
    y = "Precipitation (mm/year)"
  ) +
  theme_academic()

ggsave("Academic_Regime_Shift_T2M.png", plot = p_t2m, width = 10, height = 7.5, dpi = 300)
ggsave("Academic_Regime_Shift_Precip.png", plot = p_prec, width = 10, height = 7.5, dpi = 300)

# ==============================================================================
# 6. ??OK SEKMEL?? EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Pettitt Change-Points & Period Averages
addWorksheet(wb, "Pettitt_Breakpoints")
writeData(wb, "Pettitt_Breakpoints", df_pettitt_summary)

# Sheet 2: PELT Multiple Breakpoints
addWorksheet(wb, "PELT_Multi_Breakpoints")
writeData(wb, "PELT_Multi_Breakpoints", df_pelt_summary)

# Sheet 3: CUSUM Stability Test
addWorksheet(wb, "CUSUM_Stability_Test")
writeData(wb, "CUSUM_Stability_Test", df_cusum_summary)

# Sheet 4: Academic Plots
addWorksheet(wb, "Regime_Shift_Plots")
insertImage(wb, "Regime_Shift_Plots", "Academic_Regime_Shift_T2M.png", width = 9, height = 6.5, startRow = 2, startCol = 2)
insertImage(wb, "Regime_Shift_Plots", "Academic_Regime_Shift_Precip.png", width = 9, height = 6.5, startRow = 36, startCol = 2)

# Save Workbook
excel_output <- "Regional_Regime_Shift_Analysis_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nAnalysis complete for the 9 correct cities! Results saved to: ", excel_output, "\n")