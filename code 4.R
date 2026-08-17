# 1. Gerekli Paketlerin Y??klenmesi
if (!require("pacman")) install.packages("pacman")
pacman::p_load(nasapower, tidyverse, lubridate, SPEI, openxlsx, ggplot2)

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

# 3. NASA POWER Verisinin ??ekilmesi ve SPI/SPEI Serilerinin Olu??turulmas??
cat("Downloading daily climate data and computing monthly SPI/SPEI-12...\n")

all_drought_series <- list()

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
  
  df_monthly <- df_daily %>%
    rename(date = YYYYMMDD) %>%
    mutate(year = year(date), month = month(date)) %>%
    group_by(year, month) %>%
    summarise(
      Precip = sum(PRECTOTCORR, na.rm = TRUE),
      Tmean  = mean(T2M, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(year, month)
  
  # Thornthwaite PET ve Su Bilan??osu
  pet_vec <- as.numeric(thornthwaite(df_monthly$Tmean, lat = c_lat))
  df_monthly <- df_monthly %>% mutate(PET = pet_vec, D = Precip - PET)
  
  # 12 Ayl??k ??ndeksler
  spi12  <- as.numeric(spi(df_monthly$Precip, scale = 12)$fitted)
  spei12 <- as.numeric(spei(df_monthly$D, scale = 12)$fitted)
  
  df_result <- df_monthly %>%
    mutate(
      City    = c_name,
      Date    = make_date(year, month, 1),
      SPI_12  = spi12,
      SPEI_12 = spei12
    )
  
  all_drought_series[[c_name]] <- df_result
}

df_all_series <- bind_rows(all_drought_series)

# ==============================================================================
# 4. ??ALI??TIRMA TEOR??S?? (RUN THEORY) ??LE KURAKLIK OLAYLARININ ??IKARILMASI
# ==============================================================================

extract_drought_events <- function(df, index_col, threshold = -1.0) {
  vec <- df[[index_col]]
  
  # Kurakl??k durumu: ??ndeks <= threshold (Orta/??iddetli Kurakl??k E??i??i)
  is_drought <- !is.na(vec) & (vec <= threshold)
  runs <- rle(is_drought)
  
  events <- list()
  curr_idx <- 1
  event_id <- 1
  
  for (i in seq_along(runs$lengths)) {
    len <- runs$lengths[i]
    val <- runs$values[i]
    
    if (val) {
      sub_idx  <- curr_idx:(curr_idx + len - 1)
      sub_vals <- vec[sub_idx]
      
      duration  <- len                                    # S??re (Ay)
      severity  <- sum(abs(sub_vals))                    # ??iddet / Toplam A????k
      intensity <- severity / duration                   # Yo??unluk (Ortalama ??iddet)
      peak_int  <- max(abs(sub_vals))                    # Zirve ??iddet
      
      events[[event_id]] <- tibble(
        City           = df$City[1],
        Index_Type     = index_col,
        Event_ID       = event_id,
        Start_Date     = df$Date[curr_idx],
        End_Date       = df$Date[curr_idx + len - 1],
        Duration_Months= duration,
        Severity       = round(severity, 2),
        Intensity      = round(intensity, 2),
        Peak_Intensity = round(peak_int, 2)
      )
      event_id <- event_id + 1
    }
    curr_idx <- curr_idx + len
  }
  
  if (length(events) == 0) return(tibble())
  bind_rows(events)
}

# 9 ??l ????in T??m Kurakl??k Olaylar??n??n Ay??klanmas??
events_list <- list()

for (c_name in cities_df$City) {
  df_c <- df_all_series %>% filter(City == c_name)
  
  ev_spi  <- extract_drought_events(df_c, "SPI_12", threshold = -1.0)
  ev_spei <- extract_drought_events(df_c, "SPEI_12", threshold = -1.0)
  
  events_list[[paste0(c_name, "_SPI")]]  <- ev_spi
  events_list[[paste0(c_name, "_SPEI")]] <- ev_spei
}

df_all_events <- bind_rows(events_list)

# ==============================================================================
# 5. ??STAT??ST??KSEL ??L BAZLI ??ZET (FREQUENCY, DURATION, SEVERITY, INTENSITY)
# ==============================================================================

drought_stats_summary <- df_all_events %>%
  group_by(City, Index_Type) %>%
  summarise(
    Frequency_Event_Count = n(),
    Mean_Duration_Months  = round(mean(Duration_Months), 1),
    Max_Duration_Months   = max(Duration_Months),
    Mean_Severity         = round(mean(Severity), 2),
    Max_Severity          = round(max(Severity), 2),
    Mean_Intensity        = round(mean(Intensity), 2),
    Max_Peak_Intensity    = round(max(Peak_Intensity), 2),
    .groups = "drop"
  )

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
      axis.text = element_text(color = "black", size = 8),
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "gray92", color = "black"),
      legend.position = "bottom"
    )
}

# Grafik 1: 9 ??l ????in Kurakl??k Frekans?? ve Ortalama S??re Kar????la??t??rmas??
p_freq_dur <- ggplot(drought_stats_summary, aes(x = City, y = Frequency_Event_Count, fill = Index_Type)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_text(aes(label = paste0(Frequency_Event_Count, " ev.")), 
            position = position_dodge(0.8), vjust = -0.5, size = 2.8) +
  scale_fill_manual(values = c("SPI_12" = "#2b5c8f", "SPEI_12" = "#d95f02"),
                    labels = c("SPI-12", "SPEI-12")) +
  labs(
    title = "Drought Event Frequency across 9 Provinces (1991???2025)",
    subtitle = "Threshold: Index <= -1.0 | Comparison between SPI-12 and SPEI-12",
    x = "Province",
    y = "Number of Drought Events (Frequency)",
    fill = "Index Type"
  ) +
  theme_academic() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# Grafik 2: Kurakl??k S??resi vs. ??iddet (Duration vs Severity Scatter)
p_dur_sev <- ggplot(df_all_events, aes(x = Duration_Months, y = Severity, color = Index_Type)) +
  geom_point(alpha = 0.7, size = 2) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.6) +
  facet_wrap(~City, ncol = 3) +
  scale_color_manual(values = c("SPI_12" = "#2b5c8f", "SPEI_12" = "#d95f02")) +
  labs(
    title = "Drought Event Duration vs. Severity Relationship across 9 Provinces",
    subtitle = "Higher duration linearly escalates total cumulative drought severity",
    x = "Event Duration (Months)",
    y = "Cumulative Severity Deficit",
    color = "Index Type"
  ) +
  theme_academic()

ggsave("Academic_Drought_Events_Frequency.png", plot = p_freq_dur, width = 10, height = 6, dpi = 300)
ggsave("Academic_Drought_Duration_vs_Severity.png", plot = p_dur_sev, width = 11, height = 8, dpi = 300)

# ==============================================================================
# 7. EXCEL ??IKTISI (openxlsx)
# ==============================================================================

wb <- createWorkbook()

# Sheet 1: Province Summary (Frequency, Duration, Severity, Intensity)
addWorksheet(wb, "Drought_Stats_Summary")
writeData(wb, "Drought_Stats_Summary", drought_stats_summary)

# Sheet 2: Detailed All Events List (Event Level Data)
addWorksheet(wb, "All_Drought_Events_Detailed")
writeData(wb, "All_Drought_Events_Detailed", df_all_events)

# Sheet 3: Monthly Raw SPI/SPEI Data
addWorksheet(wb, "Monthly_Indices_Data")
writeData(wb, "Monthly_Indices_Data", df_all_series)

# Sheet 4: Plots
addWorksheet(wb, "Drought_Plots")
insertImage(wb, "Drought_Plots", "Academic_Drought_Events_Frequency.png", width = 9.5, height = 5.5, startRow = 2, startCol = 2)
insertImage(wb, "Drought_Plots", "Academic_Drought_Duration_vs_Severity.png", width = 10, height = 7, startRow = 32, startCol = 2)

# Save Workbook
excel_output <- "Drought_Event_Statistics_9Cities.xlsx"
saveWorkbook(wb, excel_output, overwrite = TRUE)

cat("\nAnalysis complete! Detailed event metrics saved to: ", excel_output, "\n")