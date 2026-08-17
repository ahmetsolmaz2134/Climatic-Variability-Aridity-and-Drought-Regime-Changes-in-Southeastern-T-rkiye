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
dry_threshold <- 1.0  # ETCCDI Standard: Precipitation < 1.0 mm/day = Dry Day

# 3. NASA POWER Verisinin ??ekilmesi
cat("Downloading daily precipitation data for 9 provinces (1991???2025)...\n")

raw_list <- list()
for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  cat(paste0(" -> Fetching: ", c_name, " (", i, "/9)\n"))
  
  df_raw <- get_power(
    community = "AG",
    pars = "PRECTOTCORR",
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
      is_dry = Precip < dry_threshold
    )
  
  raw_list[[c_name]] <- df_raw
}

df_daily_all <- bind_rows(raw_list)

# ==============================================================================
# 4. CDD VE CWD ??ND??SLER??N??N HESAPLANMASI (ETCCDI RUN ALGOR??TMASI)
# ==============================================================================

calc_max_run <- function(vec, target_bool = TRUE) {
  runs <- rle(vec == target_bool)
  if (!any(runs$values)) return(0)
  max(runs$lengths[runs$values], na.rm = TRUE)
}

# Y??ll??k CDD ve CWD
df_annual_spells <- df_daily_all %>%
  group_by(City, year) %>%
  summarise(
    Annual_Max_CDD  = calc_max_run(is_dry, TRUE),
    Annual_Max_CWD  = calc_max_run(is_dry, FALSE),
    Total_Dry_Days  = sum(is_dry, na.rm = TRUE),
    Total_Wet_Days  = sum(!is_dry, na.rm = TRUE),
    Total_Precip_mm = sum(Precip, na.rm = TRUE),
    .groups = "drop"
  )

# Mevsimsel CDD
df_seasonal_cdd <- df_daily_all %>%
  group_by(City, year, season) %>%
  summarise(
    Seasonal_Max_CDD = calc_max_run(is_dry, TRUE),
    .groups = "drop"
  )

# ==============================================================================
# 5. ??LER?? D??ZEY TREND VE PETTITT DE????????M NOKTASI TESTLER??
# ==============================================================================

# A. Y??ll??k Trend + Pettitt Analizi
annual_trend_list <- list()

for (c_name in cities_df$City) {
  df_c <- df_annual_spells %>% filter(City == c_name) %>% arrange(year)
  
  for (v in c("Annual_Max_CDD", "Annual_Max_CWD", "Total_Dry_Days")) {
    ts_vec <- df_c[[v]]
    
    # Mann-Kendall & Sen's Slope
    mk_res  <- trend::mk.test(ts_vec)
    sen_res <- trend::sens.slope(ts_vec)
    
    # Pettitt Change-Point Test
    pet_res    <- trend::pettitt.test(ts_vec)
    break_idx  <- as.numeric(pet_res$estimate)
    break_year <- df_c$year[break_idx]
    
    annual_trend_list[[paste(c_name, v, sep = "_")]] <- tibble(
      City                = c_name,
      Indicator           = v,
      Start_Year          = min(df_c$year),
      End_Year            = max(df_c$year),
      # Mann-Kendall
      MK_Z                = round(as.numeric(mk_res$statistic), 3),
      MK_p_value          = round(as.numeric(mk_res$p.value), 4),
      MK_Significance     = ifelse(mk_res$p.value < 0.05, "Significant (p<0.05)", "Not Significant"),
      Sens_Slope_Days_Yr  = round(as.numeric(sen_res$estimates), 4),
      # Pettitt Test
      Pettitt_K_Stat      = round(as.numeric(pet_res$statistic), 2),
      Pettitt_p_value     = round(as.numeric(pet_res$p.value), 4),
      Pettitt_Break_Year  = break_year,
      Pettitt_Sig         = ifelse(pet_res$p.value < 0.05, "Shift Significant", "No Shift")
    )
  }
}

df_annual_trends <- bind_rows(annual_trend_list)

# B. Mevsimsel CDD Trend + Pettitt Analizi
seasonal_trend_list <- list()

for (c_name in cities_df$City) {
  for (s_name in c("Winter", "Spring", "Summer", "Autumn")) {
    df_cs <- df_seasonal_cdd %>% filter(City == c_name, season == s_name) %>% arrange(year)
    ts_vec <- df_cs$Seasonal_Max_CDD
    
    mk_res  <- trend::mk.test(ts_vec)
    sen_res <- trend::sens.slope(ts_vec)
    pet_res <- trend::pettitt.test(ts_vec)
    
    break_idx  <- as.numeric(pet_res$estimate)
    break_year <- df_cs$year[break_idx]
    
    seasonal_trend_list[[paste(c_name, s_name, sep = "_")]] <- tibble(
      City                = c_name,
      Season              = s_name,
      Indicator           = "Seasonal_Max_CDD",
      MK_Z                = round(as.numeric(mk_res$statistic), 3),
      MK_p_value          = round(as.numeric(mk_res$p.value), 4),
      MK_Significance     = ifelse(mk_res$p.value < 0.05, "Significant (p<0.05)", "Not Significant"),
      Sens_Slope_Days_Yr  = round(as.numeric(sen_res$estimates), 4),
      Pettitt_p_value     = round(as.numeric(pet_res$p.value), 4),
      Pettitt_Break_Year  = break_year,
      Pettitt_Sig         = ifelse(pet_res$p.value < 0.05, "Shift Significant", "No Shift")
    )
  }
}

df_seasonal_trends <- bind_rows(seasonal_trend_list)

# ==============================================================================
# 6. AKADEM??K D??ZEYDE ??NG??L??ZCE GRAF??KLER
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

# Grafik 1: Y??ll??k Maksimum CDD ve Sen's Slope E??ilimleri (9 ??l)
p_cdd_annual <- ggplot(df_annual_spells, aes(x = year, y = Annual_Max_CDD)) +
  geom_line(color = "gray40", linewidth = 0.4) +
  geom_point(color = "#d95f02", size = 0.8) +
  geom_smooth(method = "lm", se = FALSE, color = "darkred", linewidth = 0.7) +
  facet_wrap(~City, ncol = 3, scales = "free_y") +
  labs(
    title = "Annual Maximum Consecutive Dry Days (CDD) across 9 Provinces (1991???2025)",
    subtitle = "ETCCDI Threshold: PR < 1.0 mm/day | Red line denotes Sen's Slope trajectory",
    x = "Year",
    y = "Maximum Consecutive Dry Days (Days)"
  ) +
  theme_academic()

# Grafik 2: Mevsimsel CDD Kutu Grafi??i (Mevsimsel Kurakl??k Y??k?? Da????l??m??)
p_cdd_seasonal <- ggplot(df_seasonal_cdd, aes(x = season, y = Seasonal_Max_CDD, fill = season)) +
  geom_boxplot(alpha = 0.7, outlier.size = 0.8, show.legend = FALSE) +
  facet_wrap(~City, ncol = 3) +
  scale_fill_manual(values = c("Winter" = "#2b5c8f", "Spring" = "#2ca02c", "Summer" = "#d95f02", "Autumn" = "#9467bd")) +
  labs(
    title = "Seasonal Variation of Maximum Consecutive Dry Days (CDD) across 9 Provinces",
    subtitle = "Boxplots illustrate seasonal dry-spell duration dynamics (1991???2025)",
    x = "Season",
    y = "Seasonal Max CDD (Days)"
  ) +
  theme_academic()

ggsave("Academic_DrySpell_Annual_CDD_9Cities.png", plot = p_cdd_annual, width = 11, height = 8, dpi = 300)
ggsave("Academic_DrySpell_Seasonal_CDD_9Cities.png", plot = p_cdd_seasonal, width = 11, height = 8, dpi = 300)

# ==============================================================================
# 7. EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Annual Trend & Pettitt Change-Point Results
addWorksheet(wb, "Annual_CDD_CWD_Trends_Pettitt")
writeData(wb, "Annual_CDD_CWD_Trends_Pettitt", df_annual_trends)

# Sheet 2: Seasonal CDD Trends & Pettitt Results
addWorksheet(wb, "Seasonal_CDD_Trends_Pettitt")
writeData(wb, "Seasonal_CDD_Trends_Pettitt", df_seasonal_trends)

# Sheet 3: Annual Spells Raw Data (1991-2025)
addWorksheet(wb, "Annual_Spells_Data")
writeData(wb, "Annual_Spells_Data", df_annual_spells)

# Sheet 4: Seasonal Spells Raw Data
addWorksheet(wb, "Seasonal_CDD_Data")
writeData(wb, "Seasonal_CDD_Data", df_seasonal_cdd)

# Sheet 5: Plots
addWorksheet(wb, "DrySpell_Plots")
insertImage(wb, "DrySpell_Plots", "Academic_DrySpell_Annual_CDD_9Cities.png", width = 10, height = 7, startRow = 2, startCol = 2)
insertImage(wb, "DrySpell_Plots", "Academic_DrySpell_Seasonal_CDD_9Cities.png", width = 10, height = 7, startRow = 38, startCol = 2)

# Save Workbook
excel_output <- "Dry_Spell_Analysis_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nDry-spell and Pettitt change-point analysis completed! File saved to: ", excel_output, "\n")