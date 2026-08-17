# 1. Gerekli Paketlerin Y??klenmesi
if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, trend, modifiedmk, openxlsx, ggplot2)

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
vars <- c("T2M", "T2M_MAX", "T2M_MIN", "PRECTOTCORR", "RH2M", "WS10M")

# 3. NASA POWER Verisinin ??ekilmesi
cat("Downloading climate data for 9 provinces (1991???2025)...\n")

raw_list <- list()
for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  cat(paste0(" -> Fetching: ", c_name, " (", i, "/9)\n"))
  
  df_raw <- get_power(
    community = "AG",
    pars = vars,
    temporal_api = "daily",
    lonlat = c(cities_df$Lon[i], cities_df$Lat[i]),
    dates = c(paste0(start_year, "-01-01"), paste0(end_year, "-12-31"))
  ) %>%
    rename(date = YYYYMMDD) %>%
    mutate(
      City  = c_name,
      year  = year(date),
      month = month(date),
      season = case_when(
        month %in% c(12, 1, 2) ~ "Winter",
        month %in% c(3, 4, 5)  ~ "Spring",
        month %in% c(6, 7, 8)  ~ "Summer",
        TRUE                   ~ "Autumn"
      )
    )
  
  raw_list[[c_name]] <- df_raw
}

df_daily_all <- bind_rows(raw_list)

# Y??ll??k Seriler
df_annual <- df_daily_all %>%
  group_by(City, year) %>%
  summarise(
    T2M         = mean(T2M, na.rm = TRUE),
    T2M_MAX     = mean(T2M_MAX, na.rm = TRUE),
    T2M_MIN     = mean(T2M_MIN, na.rm = TRUE),
    PRECTOTCORR = sum(PRECTOTCORR, na.rm = TRUE),
    RH2M        = mean(RH2M, na.rm = TRUE),
    WS10M       = mean(WS10M, na.rm = TRUE),
    .groups = "drop"
  )

# Ayl??k Seriler
df_monthly <- df_daily_all %>%
  group_by(City, year, month) %>%
  summarise(
    T2M         = mean(T2M, na.rm = TRUE),
    PRECTOTCORR = sum(PRECTOTCORR, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(City, year, month)

# ==============================================================================
# 4. YILLIK TREND ANAL??Z?? (Mann-Kendall + Sen's Slope + Pre-Whitening)
# ==============================================================================

annual_trend_list <- list()

for (c_name in cities_df$City) {
  df_c <- df_annual %>% filter(City == c_name)
  
  for (v in vars) {
    ts_vec <- df_c[[v]]
    
    # 1. Klasik Mann-Kendall ve Sen's Slope
    mk_res   <- trend::mk.test(ts_vec)
    sen_res  <- trend::sens.slope(ts_vec)
    
    # 2. Otokorelasyon (Lag-1 ACF)
    acf1 <- acf(ts_vec, plot = FALSE, lag.max = 1)$acf[2]
    
    # 3. Pre-whitening (modifiedmk::pwmk kullan??m??)
    pw_res <- modifiedmk::pwmk(ts_vec)
    
    annual_trend_list[[paste(c_name, v, sep = "_")]] <- tibble(
      City               = c_name,
      Variable           = v,
      Start_Year         = min(df_c$year),
      End_Year           = max(df_c$year),
      Lag1_Autocorr      = round(acf1, 3),
      Autocorr_Present   = ifelse(abs(acf1) > (1.96 / sqrt(length(ts_vec))), "Yes", "No"),
      # Klasik MK
      MK_Z               = round(as.numeric(mk_res$statistic), 3),
      MK_p_value         = round(as.numeric(mk_res$p.value), 4),
      MK_Significance    = ifelse(mk_res$p.value < 0.05, "Significant (p<0.05)", "Not Significant"),
      Sens_Slope_Annual  = round(as.numeric(sen_res$estimates), 4),
      # Pre-whitened MK
      PW_MK_Z            = round(as.numeric(pw_res["Z-value"]), 3),
      PW_MK_p_value      = round(as.numeric(pw_res["p-value"]), 4),
      PW_Sens_Slope      = round(as.numeric(pw_res["Sen's slope"]), 4),
      PW_Significance    = ifelse(as.numeric(pw_res["p-value"]) < 0.05, "Significant (p<0.05)", "Not Significant")
    )
  }
}

df_annual_trends <- bind_rows(annual_trend_list)

# ==============================================================================
# 5. MEVS??MSEL VE AYLIK TREND ANAL??Z?? (Seasonal Mann-Kendall)
# ==============================================================================

smk_monthly_list <- list()

for (c_name in cities_df$City) {
  df_cm <- df_monthly %>% filter(City == c_name)
  
  for (v in c("T2M", "PRECTOTCORR")) {
    ts_smk <- ts(df_cm[[v]], start = c(min(df_cm$year), 1), frequency = 12)
    
    smk_test  <- trend::smk.test(ts_smk)
    sea_slope <- trend::sea.sens.slope(ts_smk)
    
    # G??venli E??im De??eri ????karma (Vekt??r / Liste D??n??????m Kontrol??)
    slope_val <- if (is.list(sea_slope) && "estimates" %in% names(sea_slope)) {
      as.numeric(sea_slope$estimates)
    } else {
      as.numeric(sea_slope)
    }
    
    smk_monthly_list[[paste(c_name, v, sep = "_")]] <- tibble(
      City               = c_name,
      Variable           = v,
      Analysis_Level     = "Monthly Time Series (12-Season)",
      SMK_Z              = round(as.numeric(smk_test$statistic), 3),
      p_value            = round(as.numeric(smk_test$p.value), 4),
      Significance       = ifelse(smk_test$p.value < 0.05, "Significant (p<0.05)", "Not Significant"),
      Seasonal_Sens_Slope= round(slope_val, 4)
    )
  }
}

df_smk_monthly <- bind_rows(smk_monthly_list)

# ==============================================================================
# 6. AKADEM??K D??ZEYDE ??NG??L??ZCE GRAF??KLER (9 ??L)
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
      strip.text = element_text(face = "bold", size = 8)
    )
}

# Grafik 1: S??cakl??k Trendleri
p_t2m_trend <- ggplot(df_annual, aes(x = year, y = T2M)) +
  geom_line(color = "gray40", linewidth = 0.4) +
  geom_point(color = "black", size = 0.8) +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "solid", linewidth = 0.6) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  labs(
    title = "Annual Mean Temperature (T2M) Trends across 9 Provinces (1991???2025)",
    subtitle = "Red lines show Sen's Slope linear trend estimator",
    x = "Year",
    y = "Temperature (??C)"
  ) +
  theme_academic()

# Grafik 2: Ya?????? Trendleri
p_prec_trend <- ggplot(df_annual, aes(x = year, y = PRECTOTCORR)) +
  geom_line(color = "#2b5c8f", linewidth = 0.4) +
  geom_point(color = "#2b5c8f", size = 0.8) +
  geom_smooth(method = "lm", se = FALSE, color = "darkgreen", linetype = "solid", linewidth = 0.6) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  labs(
    title = "Annual Total Precipitation (PRECTOTCORR) Trends across 9 Provinces",
    subtitle = "Green lines show Sen's Slope trend trajectory",
    x = "Year",
    y = "Precipitation (mm/year)"
  ) +
  theme_academic()

ggsave("Academic_Trend_T2M_9Cities.png", plot = p_t2m_trend, width = 11, height = 8, dpi = 300)
ggsave("Academic_Trend_Precip_9Cities.png", plot = p_prec_trend, width = 11, height = 8, dpi = 300)

# ==============================================================================
# 7. EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Annual PW-MK and Sen's Slope
addWorksheet(wb, "Annual_Trends_PW_MK")
writeData(wb, "Annual_Trends_PW_MK", df_annual_trends)

# Sheet 2: Seasonal MK
addWorksheet(wb, "Seasonal_MK_Monthly")
writeData(wb, "Seasonal_MK_Monthly", df_smk_monthly)

# Sheet 3: Annual Data
addWorksheet(wb, "Annual_Climate_Data")
writeData(wb, "Annual_Climate_Data", df_annual)

# Sheet 4: Plots
addWorksheet(wb, "Trend_Plots")
insertImage(wb, "Trend_Plots", "Academic_Trend_T2M_9Cities.png", width = 10, height = 7, startRow = 2, startCol = 2)
insertImage(wb, "Trend_Plots", "Academic_Trend_Precip_9Cities.png", width = 10, height = 7, startRow = 38, startCol = 2)

# Save File
excel_output <- "Regional_Trend_Analysis_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nDone! Results saved to: ", excel_output, "\n")