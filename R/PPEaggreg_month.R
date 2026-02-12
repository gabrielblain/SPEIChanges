#' Aggregate monthly precipitation minus potential evapotranspiration (P - PE)
#' totals at several time scales
#'
#' @param monthly.PPE Numeric vector, 1-column matrix, or data frame with monthly P - PE totals.
#' @param start.year Year at which the aggregation should start.
#'   A single integer.
#' @param start.month Month at which the aggregation should start.
#'   A single integer number from 1 to 12. Default is 1, representing January.
#' @param TS Integer indicating the time scale on monthly basis
#'   (values between 1 and 24). Default is 1, representing a monthly scale.
#'
#' @return A numeric matrix with columns:
#'   Year, Month, and PPE.at.TS.
#'   The PPE.at.TS column contains the aggregated P - PE values at the specified monthly time scale.
#' @examples
#' three_month <- PPEaggreg_month(
#' Campinas_monthly[,7],
#' start.year = 1890,
#' start.month = 1,
#' TS = 3)
#'
#' @importFrom lubridate year month make_date
#' @importFrom zoo rollsum
#' @export
PPEaggreg_month <- function(monthly.PPE, start.year, start.month = 1L, TS) {

  monthly.PPE <- as.matrix(monthly.PPE)
  if (!is.numeric(monthly.PPE) || anyNA(monthly.PPE) ||
      ncol(monthly.PPE) != 1) {
    stop("Physically impossible or missing P-PE values.")
  }

  n <- length(monthly.PPE)

  if (!is.numeric(TS) ||
      length(TS) != 1 ||
      !isTRUE(all.equal(TS, as.integer(TS))) ||
      TS < 1 ||
      TS > 24) {
    stop("TS must be an integer between 1 and 24.")
  }

  if (!is.numeric(start.year) ||
      length(start.year) != 1 ||
      !isTRUE(all.equal(start.year, as.integer(start.year))) ||
      start.year < 0) {
    stop("start.year must be an integer equal to or larger than 0.")
  }

  if (!is.numeric(start.month) ||
      length(start.month) != 1 ||
      !isTRUE(all.equal(start.month, as.integer(start.month))) ||
      start.month < 1 ||
      start.month > 12) {
    stop("start.month must be an integer between 1 and 12.")
  }


  if (n < 120) {
    stop("Less than 10 years of monthly P-PE records. We cannot proceed.")
  }
  if (n < 360) {
    warning("Less than 30 years of P-PE records. Longer periods are highly recommended.")
  }

  start.cycle <- lubridate::make_date(start.year, start.month, 1)
  all.period <- seq(
    from = start.cycle,
    by   = "1 month",
    length.out = n
  )
  years <- year(all.period)
  months <- month(all.period)
  PPE.at.TS <- zoo::rollsum(monthly.PPE,TS, align = "right")
  PPE <- matrix(NA, (n-(TS-1)), 3)
  PPE[,1:3] <- c(years[TS:n], months[TS:n], PPE.at.TS)
  colnames(PPE) <- c("Year", "Month", paste0("PPE.at.TS", TS))
  class(PPE) <- union("PPEaggreg_month", class(PPE))
  return(PPE)
}
