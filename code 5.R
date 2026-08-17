# 1. Gerekli Paketlerin Y??klenmesi
if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, SPEI, trend, openxlsx, ggplot2)

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

# 3. NASA POWER Verisinin ??ekilmesi ve Aridity ??ndekslerinin Hesaplanmas??
cat("Downloading climate data and computing Aridity Indices (1991???2025)...\n")

annual_aridity_list <- list()

for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  c_lat  <- cities_df$Lat[i]
  c_lon  <- cities_df$Lon[i]
  
  cat(paste0(" -> Processing: ", c_name, " (", i, "/9)\n"))
  
  # G??nl??k Veri
  df_daily <- get_power(
    community = "AG",
    pars = vars,
    temporal_api = "daily",
    lonlat = c(c_lon, c_lat),
    dates = c(paste0(start_year, "-01-01"), paste0(end_year, "-12-31"))
  )
  
  # Ayl??k Toplamlar
  df_monthly <- df_daily %>%
    rename(date = YYYYMMDD) %>%
    mutate(year = year(date), month = month(date)) %>%
    group_by(year, month) %>%
    summarise(
      P_monthly     = sum(PRECTOTCORR, na.rm = TRUE),
      Tmean_monthly = mean(T2M, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year, month)
  
  # Thornthwaite PET (Ayl??k)
  pet_monthly <- as.numeric(thornthwaite(df_monthly$Tmean_monthly, lat = c_lat))
  df_monthly <- df_monthly %>% mutate(PET_monthly = pet_monthly)
  
  # Y??ll??k Agregasyon
  df_annual <- df_monthly %>%
    group_by(year) %>%
    summarise(
      City          = c_name,
      P_annual      = sum(P_monthly, na.rm = TRUE),
      Tmean_annual  = mean(Tmean_monthly, na.rm = TRUE),
      PET_annual    = sum(PET_monthly, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      # De Martonne Aridity Index: I = P / (T + 10)
      De_Martonne_Index = P_annual / (Tmean_annual + 10),
      
      # UNEP Aridity Index: AI = P / PET
      UNEP_P_PET_Ratio  = P_annual / PET_annual,
      
      # De Martonne S??n??fland??rmas??
      De_Martonne_Class = case_when(
        De_Martonne_Index < 5  ~ "Dry / Desert",
        De_Martonne_Index < 10 ~ "Semi-Arid",
        De_Martonne_Index < 20 ~ "Mediterranean / Step",
        De_Martonne_Index < 30 ~ "Semi-Humid",
        TRUE                   ~ "Humid"
      ),
      
      # UNEP S??n??fland??rmas??
      UNEP_Class = case_when(
        UNEP_P_PET_Ratio < 0.05 ~ "Hyper-Arid",
        UNEP_P_PET_Ratio < 0.20 ~ "Arid",
        UNEP_P_PET_Ratio < 0.50 ~ "Semi-Arid",
        UNEP_P_PET_Ratio < 0.65 ~ "Dry Sub-Humid",
        TRUE                    ~ "Humid"
      )
    )
  
  annual_aridity_list[[c_name]] <- df_annual
}

df_all_aridity <- bind_rows(annual_aridity_list)

# ==============================================================================
# 4. TREND ANAL??Z?? VE H??POTEZ TEST?? (P, PET, De Martonne, P/PET)
# ==============================================================================
# Soru: P sabit/dalgal?? olsa bile y??kselen PET aridity indekslerini d??????r??yor mu?
# (D????en De Martonne ve P/PET de??erleri artan kurakla??may?? temsil eder)

aridity_trends <- list()
target_vars <- c("P_annual", "PET_annual", "De_Martonne_Index", "UNEP_P_PET_Ratio")

for (c_name in cities_df$City) {
  df_c <- df_all_aridity %>% filter(City == c_name)
  
  for (v in target_vars) {
    ts_vec  <- df_c[[v]]
    mk_res  <- trend::mk.test(ts_vec)
    sen_res <- trend::sens.slope(ts_vec)
    
    aridity_trends[[paste(c_name, v, sep = "_")]] <- tibble(
      City            = c_name,
      Variable        = v,
      MK_Z            = round(as.numeric(mk_res$statistic), 3),
      p_value         = round(as.numeric(mk_res$p.value), 4),
      Significance    = ifelse(mk_res$p.value < 0.05, "Significant (p<0.05)", "Not Significant"),
      Sens_Slope      = round(as.numeric(sen_res$estimates), 4),
      Trend_Direction = case_when(
        mk_res$p.value < 0.05 & sen_res$estimates > 0 ~ "Increasing Trend",
        mk_res$p.value < 0.05 & sen_res$estimates < 0 ~ "Decreasing (Aridification)",
        TRUE                                         ~ "No Significant Trend"
      )
    )
  }
}

df_aridity_trends <- bind_rows(aridity_trends)

# ==============================================================================
# 5. AKADEM??K D??ZEYDE ??NG??L??ZCE GRAF??KLER
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
      strip.background = element_rect(fill = "gray92", color = "black")
    )
}

# Grafik 1: UNEP P / PET Oran??n??n Zamansal De??i??imi (D???????? = Kurakla??ma)
p_ppet <- ggplot(df_all_aridity, aes(x = year, y = UNEP_P_PET_Ratio)) +
  geom_line(color = "gray40", linewidth = 0.4) +
  geom_point(color = "#d95f02", size = 0.8) +
  geom_smooth(method = "lm", se = FALSE, color = "red", linewidth = 0.7) +
  geom_hline(yintercept = 0.50, linetype = "dashed", color = "brown", linewidth = 0.5) +
  facet_wrap(~City, ncol = 3) +
  labs(
    title = "Annual UNEP Aridity Index (P / PET) Trends across 9 Provinces (1991???2025)",
    subtitle = "Dashed brown line = Semi-Arid threshold (0.50) | Decreasing trend indicates thermal aridification",
    x = "Year",
    y = "P / PET Ratio"
  ) +
  theme_academic()

# Grafik 2: De Martonne Kurakl??k ??ndeksi De??i??imi
p_dm <- ggplot(df_all_aridity, aes(x = year, y = De_Martonne_Index)) +
  geom_line(color = "gray40", linewidth = 0.4) +
  geom_point(color = "#2b5c8f", size = 0.8) +
  geom_smooth(method = "lm", se = FALSE, color = "darkred", linewidth = 0.7) +
  geom_hline(yintercept = 20, linetype = "dashed", color = "orange", linewidth = 0.5) +
  facet_wrap(~City, ncol = 3) +
  labs(
    title = "De Martonne Aridity Index (I_DM) Trends across 9 Provinces",
    subtitle = "Dashed orange line = Mediterranean/Semi-Arid transition threshold (20)",
    x = "Year",
    y = "De Martonne Index (I_DM)"
  ) +
  theme_academic()

ggsave("Academic_Aridity_UNEP_PPET_9Cities.png", plot = p_ppet, width = 11, height = 8, dpi = 300)
ggsave("Academic_Aridity_DeMartonne_9Cities.png", plot = p_dm, width = 11, height = 8, dpi = 300)

# ==============================================================================
# 6. EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Trend Results for Aridity & Drivers
addWorksheet(wb, "Aridity_Trends_MK")
writeData(wb, "Aridity_Trends_MK", df_aridity_trends)

# Sheet 2: Annual Aridity Indices Data (1991-2025)
addWorksheet(wb, "Annual_Aridity_Data")
writeData(wb, "Annual_Aridity_Data", df_all_aridity)

# Sheet 3: Plots
addWorksheet(wb, "Aridity_Plots")
insertImage(wb, "Aridity_Plots", "Academic_Aridity_UNEP_PPET_9Cities.png", width = 10, height = 7, startRow = 2, startCol = 2)
insertImage(wb, "Aridity_Plots", "Academic_Aridity_DeMartonne_9Cities.png", width = 10, height = 7, startRow = 38, startCol = 2)

# Save Workbook
excel_output <- "Aridity_Analysis_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nAridity analysis completed successfully! Output saved to: ", excel_output, "\n")