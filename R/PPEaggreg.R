#' Aggregate daily precipitation minus potential evapotranspiration (P - PE)
#' totals at quasi-week time scales
#'
#' @param daily.PPE Numeric vector, 1-column matrix, or data frame with daily P - PE totals.
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
#' quasi-weekly totals, which aligns with the widely used one month time scale.
#'
#' @examples
#' daily.PPE <- Campinas_daily[, 9]
#' PPE.at.TS <- PPEaggreg(daily.PPE, start.date = "1995-01-01", TS = 4)
#'
#' @importFrom lubridate year month day
#' @importFrom zoo rollsum
#' @importFrom stats na.omit
#' @export
PPEaggreg <- function(daily.PPE, start.date, TS = 4L) {

  daily.PPE <- as.matrix(daily.PPE)
  if (!is.numeric(daily.PPE) || anyNA(daily.PPE) ||
      ncol(daily.PPE) != 1) {
    stop("Physically impossible or missing P-PE values.")
  }
  if (!is.numeric(TS) || length(TS) != 1 ||
      TS < 1 ||
      TS > 96) {
    stop("TS must be an integer between 1 and 96.")
  }

  n <- length(daily.PPE)
  if (n < 3650) {
    stop("Less than 10 years of P-PE records. We cannot proceed.")
  }
  if (n < 10950) {
    warning("Less than 30 years of P-PE records. Longer periods are highly recommended.")
  }
  start.cycle <- check_date(start.date)
  end.cycle <- start.cycle + (n - 1)
  all.period <- seq(start.cycle, end.cycle, "days")
  years <- year(all.period)
  months <- month(all.period)
  days <- day(all.period)
  PPE <- matrix(NA, n, 4)
  PPE[, 1:4] <- c(years, months, days, daily.PPE)
  a <- 1
  b <- 2
  c <- 3
  d <- 4
  data.week <- matrix(NA, n, 5)
  start.year <- PPE[1,1]
  final.year <- PPE[n,1]
  start.month <- PPE[1,2]
  final.month <- PPE[n,2]
  month <- start.month
  year <- start.year
  while (year <= final.year || month <= final.month) {
    data.week1 <- sum(PPE[which(PPE[,1] ==
                                  year &
                                  PPE[,2] == month &
                                  PPE[,3] <= 7),4])
    data.week2 <- sum(PPE[which(PPE[,1] ==
                                  year &
                                  PPE[,2] == month &
                                  PPE[,3] > 7 &
                                  PPE[,3] <= 14), 4])
    data.week3 <- sum(PPE[which(PPE[,1] ==
                                  year &
                                  PPE[,2] == month &
                                  PPE[,3] > 14 &
                                  PPE[,3] <= 21), 4])
    data.week4 <- sum(PPE[which(PPE[,1] ==
                                  year &
                                  PPE[,2] == month &
                                  PPE[,3] > 21),4])
    data.week[a, 1:4] <- c(year, month, 1, data.week1)
    data.week[b, 1:4] <- c(year, month, 2, data.week2)
    data.week[c, 1:4] <- c(year, month, 3, data.week3)
    data.week[d, 1:4] <- c(year, month, 4, data.week4)
    month <- month + 1
    if (year == final.year & month > final.month) {
      break
    }
    if (month > 12) {
      year <- year + 1
      month <- 1
    }
    a <- a + 4
    b <- b + 4
    c <- c + 4
    d <- d + 4
  }
  if (TS > 1){
    data.at.TS <- na.omit(rollsum(data.week[,4],TS))
    n.TS <- length(data.at.TS)
    data.week[TS:(n.TS+(TS-1)),5]<- data.at.TS
    data.week <- data.week[-c((n.TS+(TS)):n),]
  } else{
    data.week[,5] <- data.week[,4]
  }
  data.week <- data.week[,-c(4)]
  data.week <- na.omit(data.week)
  colnames(data.week) <- c("Year", "Month", "quasiWeek", paste0("PPE.at.TS", TS))
  final.day <- days[n]
  final.quasiweek <- pmin(4, ceiling(final.day/7))
  data.week <- subset(data.week,
                      (data.week[,1] < final.year) |
                        (data.week[,1] == final.year & data.week[,2] < final.month) |
                        (data.week[,1] == final.year & data.week[,2] == final.month &
                           data.week[,3] <= final.quasiweek))
  message("Done. Just ensure the last quasi-week is complete.
  The last day of your series is ", final.day, " and TS is ", TS)

  class(data.week) <- union("TSaggreg", class(data.week))

  return(data.week)
}
