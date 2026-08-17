# 1. Gerekli Paketlerin Y??klenmesi
if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, SPEI, openxlsx, ggplot2, reshape2)

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

# 3. NASA POWER Verisinin ??ekilmesi ve ??ndekslerin Haz??rlanmas??
cat("Downloading daily climate data and constructing monthly series (1991???2025)...\n")

monthly_list <- list()

for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  c_lat  <- cities_df$Lat[i]
  c_lon  <- cities_df$Lon[i]
  
  cat(paste0(" -> Fetching: ", c_name, " (", i, "/9)\n"))
  
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
      PRECTOTCORR = sum(PRECTOTCORR, na.rm = TRUE),
      T2M         = mean(T2M, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year, month)
  
  # Thornthwaite PET & Su Bilan??osu
  pet_vec <- as.numeric(thornthwaite(df_m$T2M, lat = c_lat))
  df_m    <- df_m %>% mutate(PET = pet_vec, D = PRECTOTCORR - PET)
  
  # 12 Ayl??k SPI ve SPEI
  spi12  <- as.numeric(spi(df_m$PRECTOTCORR, scale = 12)$fitted)
  spei12 <- as.numeric(spei(df_m$D, scale = 12)$fitted)
  
  monthly_list[[c_name]] <- df_m %>%
    mutate(
      City    = c_name,
      Date    = make_date(year, month, 1),
      SPI_12  = spi12,
      SPEI_12 = spei12
    )
}

df_all_monthly <- bind_rows(monthly_list)

# ==============================================================================
# 4. PEARSON VE SPEARMAN KORELASYON HESAPLAMALARI
# ==============================================================================

pairs_to_test <- list(
  list(x = "PRECTOTCORR", y = "SPI_12",  label = "Precipitation vs SPI-12"),
  list(x = "T2M",         y = "SPEI_12", label = "Temperature vs SPEI-12"),
  list(x = "PET",         y = "SPEI_12", label = "PET vs SPEI-12"),
  list(x = "PRECTOTCORR", y = "SPEI_12", label = "Precipitation vs SPEI-12")
)

cor_results_list <- list()

for (c_name in cities_df$City) {
  df_c <- df_all_monthly %>% filter(City == c_name) %>% drop_na(SPI_12, SPEI_12)
  
  for (pair in pairs_to_test) {
    x_var <- pair$x
    y_var <- pair$y
    lbl   <- pair$label
    
    vx <- df_c[[x_var]]
    vy <- df_c[[y_var]]
    
    # Pearson Correlation
    p_cor <- cor.test(vx, vy, method = "pearson")
    # Spearman Correlation
    s_cor <- cor.test(vx, vy, method = "spearman", exact = FALSE)
    
    cor_results_list[[paste(c_name, x_var, y_var, sep = "_")]] <- tibble(
      City                = c_name,
      Relationship        = lbl,
      Variable_X          = x_var,
      Variable_Y          = y_var,
      Pearson_r           = round(as.numeric(p_cor$estimate), 3),
      Pearson_p_value     = round(as.numeric(p_cor$p.value), 4),
      Pearson_Sig         = ifelse(p_cor$p.value < 0.05, "p < 0.05", "Not Sig"),
      Spearman_rho        = round(as.numeric(s_cor$estimate), 3),
      Spearman_p_value    = round(as.numeric(s_cor$p.value), 4),
      Spearman_Sig        = ifelse(s_cor$p.value < 0.05, "p < 0.05", "Not Sig")
    )
  }
}

df_correlations <- bind_rows(cor_results_list)

# ==============================================================================
# 5. AKADEM??K D??ZEYDE ??NG??L??ZCE KORELASYON GRAF??KLER??
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

# Grafik 1: Pearson r vs. Spearman rho Kar????la??t??rmal?? ??ubuk Grafi??i
p_cor_bar <- ggplot(df_correlations, aes(x = City, y = Pearson_r, fill = Relationship)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  scale_fill_manual(values = c(
    "Precipitation vs SPI-12"  = "#2b5c8f",
    "Precipitation vs SPEI-12" = "#41b6c4",
    "Temperature vs SPEI-12"   = "#d95f02",
    "PET vs SPEI-12"           = "#7570b3"
  )) +
  labs(
    title = "Climate???Drought Sensitivity Across 9 Provinces (Pearson Linear Correlation)",
    subtitle = "Quantifying linear coupling between drivers (P, T2M, PET) and multi-scalar drought indices",
    x = "Province",
    y = "Pearson Correlation Coefficient (r)",
    fill = "Variable Pair"
  ) +
  theme_academic() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# Grafik 2: PET vs SPEI-12 Serile??tirilmi?? Da????l??m ve Regresyon Grafi??i
df_clean_scatter <- df_all_monthly %>% drop_na(PET, SPEI_12)

p_pet_spei <- ggplot(df_clean_scatter, aes(x = PET, y = SPEI_12)) +
  geom_point(alpha = 0.25, size = 0.7, color = "#7570b3") +
  geom_smooth(method = "lm", color = "darkred", linewidth = 0.7, se = FALSE) +
  geom_smooth(method = "loess", color = "blue", linetype = "dashed", linewidth = 0.6, se = FALSE) +
  facet_wrap(~City, ncol = 3) +
  labs(
    title = "Evaporative Demand (PET) vs. SPEI-12 Relationships across 9 Provinces",
    subtitle = "Solid red line: Linear fit (Pearson) | Dashed blue line: Non-linear LOESS fit (Spearman trend)",
    x = "Potential Evapotranspiration - PET (mm/month)",
    y = "SPEI-12 Index"
  ) +
  theme_academic()

# Grafik 3: Precipitation vs SPI-12 Da????l??m Grafi??i
df_clean_spi <- df_all_monthly %>% drop_na(PRECTOTCORR, SPI_12)

p_prec_spi <- ggplot(df_clean_spi, aes(x = PRECTOTCORR, y = SPI_12)) +
  geom_point(alpha = 0.25, size = 0.7, color = "#2b5c8f") +
  geom_smooth(method = "lm", color = "darkgreen", linewidth = 0.7, se = FALSE) +
  facet_wrap(~City, ncol = 3) +
  labs(
    title = "Monthly Precipitation vs. SPI-12 Relationships across 9 Provinces",
    subtitle = "Strong positive correlation indicating precipitation dominance on standardized moisture deficits",
    x = "Monthly Total Precipitation (mm)",
    y = "SPI-12 Index"
  ) +
  theme_academic()

ggsave("Academic_Correlations_BarPlot_9Cities.png", plot = p_cor_bar, width = 11, height = 6.5, dpi = 300)
ggsave("Academic_Scatter_PET_vs_SPEI12_9Cities.png", plot = p_pet_spei, width = 11, height = 8, dpi = 300)
ggsave("Academic_Scatter_Prec_vs_SPI12_9Cities.png", plot = p_prec_spi, width = 11, height = 8, dpi = 300)

# ==============================================================================
# 6. EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Correlation Metrics Summary Table
addWorksheet(wb, "Correlation_Metrics")
writeData(wb, "Correlation_Metrics", df_correlations)

# Sheet 2: Monthly Data Series (P, T2M, PET, SPI, SPEI)
addWorksheet(wb, "Monthly_Climate_Drought_Data")
writeData(wb, "Monthly_Climate_Drought_Data", df_all_monthly)

# Sheet 3: Embedded High-Resolution Plots
addWorksheet(wb, "Correlation_Plots")
insertImage(wb, "Correlation_Plots", "Academic_Correlations_BarPlot_9Cities.png", width = 10, height = 6, startRow = 2, startCol = 2)
insertImage(wb, "Correlation_Plots", "Academic_Scatter_PET_vs_SPEI12_9Cities.png", width = 10, height = 7, startRow = 34, startCol = 2)
insertImage(wb, "Correlation_Plots", "Academic_Scatter_Prec_vs_SPI12_9Cities.png", width = 10, height = 7, startRow = 72, startCol = 2)

# Save Excel
excel_output <- "Climate_Drought_Relationships_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nClimate-drought relationship analysis completed! Results saved to: ", excel_output, "\n")