#' Aggregate daily precipitation minus potential evapotranspiration (P-PE)
#' totals at quasi-week time scales
#'
#' @param daily.PPE Numeric vector, 1-column matrix, or data frame with daily P-PE totals.
#' @param start.date Date at which the aggregation should start.
#'   Accepts most common formats (e.g., "YYYY-MM-DD", "YYYY/MM/DD").
#' @param TS Integer indicating the time scale on a quasi-week basis
#'   (values between 1 and 96). Default is 4, representing a monthly scale.
#'
#' @return A numeric matrix with columns:
#'   Year, Month, quasiWeek, and PPE.at.TS.
#'
#' @details
#' This function divides each month into four fixed quasi-week periods:
#' days 1–7, 8–14, 15–21, and 22–end of month. This yields 48 quasi-week
#' intervals per year, independent of the aggregation scale.
#' When `TS = 4`, the function computes rolling sums of four consecutive
#' quasi-weekly totals (≈ one month).
#'
#' @examplesIf interactive()
#' daily.PPE <- CampinasPPE[, 2]
#' PPE_TS4 <- PPEaggreg(daily.PPE, start.date = "1980-01-01", TS = 4)
#'
#' @importFrom lubridate year month day parse_date_time
#' @importFrom zoo rollsum
#' @importFrom stats na.omit aggregate
#' @importFrom utils tail
#' @export
PPEaggreg <- function(daily.PPE, start.date, TS = 4L) {

  # --- Input validation ---
  daily.PPE <- as.numeric(daily.PPE)
  if (anyNA(daily.PPE))
    stop("Missing P-PE values detected. Please remove or impute them before aggregation.")
  if (length(daily.PPE) < 3650)
    stop("Less than 10 years of P-PE records. Cannot proceed.")
  if (length(daily.PPE) < 10950)
    warning("Less than 30 years of P-PE records. Longer records are recommended.")
  if (!is.numeric(TS) || length(TS) != 1 || TS < 1 || TS > 96)
    stop("`TS` must be an integer between 1 and 96.")

  # --- Date sequence setup ---
  start.date <- .check_date(start.date)
  all.dates <- seq.Date(start.date, by = "day", length.out = length(daily.PPE))
  years  <- year(all.dates)
  months <- month(all.dates)
  days   <- day(all.dates)

  # --- Quasi-week assignment ---
  quasiWeek <- cut(days, breaks = c(0, 7, 14, 21, 31), labels = 1:4, right = TRUE)
  df <- data.frame(Year = years, Month = months,
                   quasiWeek = as.integer(quasiWeek),
                   PPE = daily.PPE)

  # --- Aggregate by quasi-week ---
  weekly_sum <- aggregate(PPE ~ Year + Month + quasiWeek, df, sum, na.rm = TRUE)
  weekly_sum <- weekly_sum[order(weekly_sum$Year, weekly_sum$Month, weekly_sum$quasiWeek), ]

  # --- Apply rolling sum for selected TS ---
  if (TS > 1) {
    roll_vals <- rollsum(weekly_sum$PPE, TS, align = "right", na.pad = TRUE)
    weekly_sum[[paste0("PPE.at.TS", TS)]] <- roll_vals
  } else {
    weekly_sum[[paste0("PPE.at.TS", TS)]] <- weekly_sum$PPE
  }

  # --- Trim incomplete end periods ---
  final.day <- tail(days, 1)
  final.quasiweek <- pmin(4, ceiling(final.day / 7))
  final.year  <- tail(years, 1)
  final.month <- tail(months, 1)
  weekly_sum <- subset(
    weekly_sum,
    (Year < final.year) |
      (Year == final.year & Month < final.month) |
      (Year == final.year & Month == final.month & quasiWeek <= final.quasiweek)
  )

  weekly_sum <- na.omit(weekly_sum)
  out_name <- paste0("PPE.at.TS", TS)
  weekly_sum <- weekly_sum[, c("Year", "Month", "quasiWeek", out_name)]

  # --- Ensure numeric matrix output (compatible with SPIChange format) ---
  out <- as.matrix(weekly_sum)
  storage.mode(out) <- "numeric"
  colnames(out) <- c("Year", "Month", "quasiWeek", out_name)

  message("Done. Ensure the last quasi-week is complete. ",
          "Last day = ", final.day, ", TS = ", TS)

  class(out) <- union("TSaggreg", class(out))
  return(out)
}

#' Validate and parse date input
#' @keywords internal
.check_date <- function(x) {
  parsed <- tryCatch(
    parse_date_time(x,
                    orders = c("Ymd", "dmY", "mdY", "BdY", "Bdy", "bdY", "bdy"),
                    tz = "UTC"),
    error = function(e) stop("Invalid date format: ", x)
  )
  as.Date(parsed)
}
