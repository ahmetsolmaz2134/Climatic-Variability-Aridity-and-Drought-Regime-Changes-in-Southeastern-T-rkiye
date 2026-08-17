# 1. Gerekli Paketlerin Y??klenmesi
if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, trend, effsize, SPEI, openxlsx, ggplot2)

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

# 3. NASA POWER Verisinin ??ekilmesi ve Y??ll??k Metriklerin Hesaplanmas??
cat("Downloading daily climate data and computing annual metrics (1991???2025)...\n")

annual_data_list <- list()

for (i in 1:nrow(cities_df)) {
  c_name <- cities_df$City[i]
  c_lat  <- cities_df$Lat[i]
  c_lon  <- cities_df$Lon[i]
  
  cat(paste0(" -> Fetching and processing: ", c_name, " (", i, "/9)\n"))
  
  df_daily <- get_power(
    community = "AG",
    pars = c("T2M", "PRECTOTCORR"),
    temporal_api = "daily",
    lonlat = c(c_lon, c_lat),
    dates = c(paste0(start_year, "-01-01"), paste0(end_year, "-12-31"))
  ) %>%
    rename(date = YYYYMMDD, Precip = PRECTOTCORR) %>%
    mutate(year = year(date), month = month(date), is_dry = Precip < 1.0)
  
  # Y??ll??k CDD (Consecutive Dry Days) Hesaplama
  df_cdd <- df_daily %>%
    group_by(year) %>%
    summarise(
      Max_CDD = max(rle(is_dry)$lengths[rle(is_dry)$values], na.rm = TRUE),
      .groups = "drop"
    )
  
  # Ayl??k Veri ??zerinden PET Hesaplama
  df_m <- df_daily %>%
    group_by(year, month) %>%
    summarise(
      P_m = sum(Precip, na.rm = TRUE),
      T_m = mean(T2M, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year, month)
  
  pet_m <- as.numeric(thornthwaite(df_m$T_m, lat = c_lat))
  df_m <- df_m %>% mutate(PET_m = pet_m)
  
  # Y??ll??k Toplam ve Ortalamalar
  df_ann <- df_m %>%
    group_by(year) %>%
    summarise(
      Precip_mm = sum(P_m, na.rm = TRUE),
      Tmean_C   = mean(T_m, na.rm = TRUE),
      PET_mm    = sum(PET_m, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(df_cdd, by = "year") %>%
    mutate(City = c_name)
  
  annual_data_list[[c_name]] <- df_ann
}

df_all_annual <- bind_rows(annual_data_list)

# ==============================================================================
# 4. EFFECT SIZE (ETK?? B??Y??KL??????) VE KAVRAMSAL METR??K HESAPLAMALARI
# ==============================================================================

effect_size_results <- list()
target_vars <- c("Tmean_C", "Precip_mm", "PET_mm", "Max_CDD")

for (c_name in cities_df$City) {
  df_c <- df_all_annual %>% filter(City == c_name) %>% arrange(year)
  
  for (v in target_vars) {
    ts_vec <- df_c[[v]]
    years  <- df_c$year
    
    # A. Trend Magnitude (Sen's Slope & Relative Trend)
    sen_res    <- trend::sens.slope(ts_vec)
    slope_yr   <- as.numeric(sen_res$estimates)
    slope_dec  <- slope_yr * 10  # De??i??im / On Y??l (Per Decade)
    base_mean  <- mean(ts_vec, na.rm = TRUE)
    pct_per_dec <- (slope_dec / base_mean) * 100
    
    mk_res     <- trend::mk.test(ts_vec)
    p_val_mk   <- as.numeric(mk_res$p.value)
    
    # B. Pettitt Break Point Determination
    pet_test   <- trend::pettitt.test(ts_vec)
    break_idx  <- as.numeric(pet_test$estimate)
    break_year <- years[break_idx]
    
    # Rejim Ayr??m?? (Regime 1 vs Regime 2)
    vec_r1 <- ts_vec[years <= break_year]
    vec_r2 <- ts_vec[years > break_year]
    
    m1 <- mean(vec_r1, na.rm = TRUE)
    m2 <- mean(vec_r2, na.rm = TRUE)
    sd1 <- sd(vec_r1, na.rm = TRUE)
    sd2 <- sd(vec_r2, na.rm = TRUE)
    
    abs_diff <- m2 - m1
    pct_change <- (abs_diff / m1) * 100
    
    # C. Cohen's d (Standardized Mean Difference)
    cohen_obj <- effsize::cohen.d(vec_r2, vec_r1) # Regime 2 - Regime 1
    cohen_d   <- as.numeric(cohen_obj$estimate)
    cohen_ci_low <- cohen_obj$conf.int[1]
    cohen_ci_high <- cohen_obj$conf.int[2]
    
    # Cohen's d S??n??fland??rmas?? (Effect Magnitude)
    d_abs <- abs(cohen_d)
    effect_magnitude <- case_when(
      d_abs < 0.2 ~ "Negligible",
      d_abs < 0.5 ~ "Small",
      d_abs < 0.8 ~ "Medium",
      TRUE        ~ "Large"
    )
    
    effect_size_results[[paste(c_name, v, sep = "_")]] <- tibble(
      City                    = c_name,
      Variable                = v,
      Break_Year              = break_year,
      # Statistical Significance
      MK_p_value              = round(p_val_mk, 4),
      Stat_Significant        = ifelse(p_val_mk < 0.05, "Yes (p<0.05)", "No"),
      # Effect Size Metrics
      Sens_Slope_Per_Year     = round(slope_yr, 4),
      Sens_Slope_Per_Decade   = round(slope_dec, 3),
      Relative_Decadal_Trend_Pct = round(pct_per_dec, 2),
      Regime_1_Mean           = round(m1, 2),
      Regime_2_Mean           = round(m2, 2),
      Absolute_Shift          = round(abs_diff, 2),
      Percentage_Shift_Pct    = round(pct_change, 2),
      # Standardized Effect Size (Cohen's d)
      Cohens_d                = round(cohen_d, 3),
      Cohens_d_CI_Low         = round(cohen_ci_low, 3),
      Cohens_d_CI_High        = round(cohen_ci_high, 3),
      Effect_Magnitude        = effect_magnitude
    )
  }
}

df_effect_sizes <- bind_rows(effect_size_results)

# ==============================================================================
# 5. AKADEM??K D??ZEYDE ??NG??L??ZCE EFFECT SIZE GRAF??KLER??
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

# Grafik 1: Forest Plot - Cohen's d (Standartla??t??r??lm???? Rejim Farklar?? ve %95 G??ven Aral??????)
p_forest_cohen <- ggplot(df_effect_sizes, aes(x = Cohens_d, y = City, color = Effect_Magnitude)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray40", linewidth = 0.6) +
  geom_vline(xintercept = c(-0.8, -0.5, -0.2, 0.2, 0.5, 0.8), linetype = "dotted", color = "gray70") +
  geom_errorbarh(aes(xmin = Cohens_d_CI_Low, xmax = Cohens_d_CI_High), height = 0.2, linewidth = 0.6) +
  geom_point(size = 2.2) +
  facet_wrap(~Variable, ncol = 2, scales = "free_x") +
  scale_color_manual(values = c(
    "Large"      = "#d95f02",
    "Medium"     = "#7570b3",
    "Small"      = "#2b5c8f",
    "Negligible" = "gray50"
  )) +
  labs(
    title = "Standardized Regime Shift Magnitude (Cohen's d) across 9 Provinces",
    subtitle = "Quantifying physical significance beyond p-values | Error bars represent 95% Confidence Intervals",
    x = "Cohen's d (Standardized Mean Difference between Regime 2 and Regime 1)",
    y = "Province",
    color = "Effect Magnitude Class"
  ) +
  theme_academic()

# Grafik 2: Y??ll??k Sen's Slope vs Rejim Shift (%) Kar????la??t??rmas?? (S??cakl??k ve Buharla??ma)
df_plot_slopes <- df_effect_sizes %>%
  filter(Variable %in% c("Tmean_C", "PET_mm"))

p_slope_bar <- ggplot(df_plot_slopes, aes(x = City, y = Sens_Slope_Per_Decade, fill = Variable)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  facet_wrap(~Variable, scales = "free_y", ncol = 2) +
  scale_fill_manual(values = c("Tmean_C" = "#d95f02", "PET_mm" = "#7570b3")) +
  labs(
    title = "Decadal Trend Magnitude (Sen's Slope per Decade) across 9 Provinces",
    subtitle = "Direct physical rate of increase: Thermal warming (??C/decade) and Evaporative demand (mm/decade)",
    x = "Province",
    y = "Decadal Change Rate (Units / Decade)",
    fill = "Variable"
  ) +
  theme_academic() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1), legend.position = "none")

ggsave("Academic_Effect_Size_Cohen_ForestPlot.png", plot = p_forest_cohen, width = 11, height = 8, dpi = 300)
ggsave("Academic_Sens_Slope_Decadal_Rates.png", plot = p_slope_bar, width = 11, height = 6, dpi = 300)

# ==============================================================================
# 6. EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Comprehensive Effect Size Metrics Table
addWorksheet(wb, "Effect_Size_Summary")
writeData(wb, "Effect_Size_Summary", df_effect_sizes)

# Sheet 2: Annual Climate Metrics (1991-2025)
addWorksheet(wb, "Annual_Base_Data")
writeData(wb, "Annual_Base_Data", df_all_annual)

# Sheet 3: Embedded Plots
addWorksheet(wb, "Effect_Size_Plots")
insertImage(wb, "Effect_Size_Plots", "Academic_Effect_Size_Cohen_ForestPlot.png", width = 10, height = 7.5, startRow = 2, startCol = 2)
insertImage(wb, "Effect_Size_Plots", "Academic_Sens_Slope_Decadal_Rates.png", width = 10, height = 5.5, startRow = 40, startCol = 2)

# Save Excel
excel_output <- "Climate_Effect_Size_Analysis_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nEffect Size analysis completed successfully! Output saved to: ", excel_output, "\n")