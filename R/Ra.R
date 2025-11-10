#' Calculates daily extraterrestrial solar radiation (Ra) based on latitude and date.
#'
#' @param lat Latitude in decimal degrees (-90 to 90).
#' @param start.date First day of the series.
#'   Accepts most common formats (e.g., "YYYY-MM-DD", "YYYY/MM/DD").
#' @param end.date Last day of the series.
#'   Accepts most common formats (e.g., "YYYY-MM-DD", "YYYY/MM/DD").
#'
#' @return A data frame with columns: Date and Ra (MJ m^-2 day^-1).
#'
#' @examples
#' daily.Ra <- Ra(lat = -23, start.date = "1995-01-01", end.date = "1995-12-31")
#' head(daily.Ra)
#' @export
Ra <- function(lat, start.date, end.date) {

  # Validate latitude
  if (!is.numeric(lat) || length(lat) != 1 || lat <= -90 || lat >= 90) {
    stop("Latitude must be a single numeric value between -90 and 90 degrees.")
  }

  # Validate dates
  start.cycle <- check_date(start.date)
  end.cycle   <- check_date(end.date)
  if (start.cycle > end.cycle)
    stop("start.date must be earlier than end.date.")

  # Define period and compute day of year
  all.period <- seq(start.cycle, end.cycle, by = "days")
  julian.day <- as.numeric(format(all.period, "%j"))

  # Latitude and declination in radians
  lat.rad <- lat * pi / 180
  solar.decli <- 23.45 * sin((360 * (julian.day - 80) / 365) * pi / 180)
  solar.decli.rad <- solar.decli * pi / 180

  # Sunset hour angle (radians) with polar-day/night adjustment
  x <- -tan(lat.rad) * tan(solar.decli.rad)
  x <- pmin(pmax(x, -1), 1)  # Numerical safety: clip between -1 and 1
  hn.rad <- acos(x)

  # Handle polar day/night explicitly
  # Polar day: Sun never sets -> hn = π
  # Polar night: Sun never rises -> hn = 0
  hn.rad[(lat > 0 & solar.decli.rad > 0 & x <= -1) |
           (lat < 0 & solar.decli.rad < 0 & x <= -1)] <- pi
  hn.rad[(lat > 0 & solar.decli.rad < 0 & x >= 1)  |
           (lat < 0 & solar.decli.rad > 0 & x >= 1)] <- 0

  # Earth–Sun distance factor
  dist.terra.sol <- 1 + 0.033 * cos(2 * pi * julian.day / 365)

  ra <- 37.6 * dist.terra.sol * (
    hn.rad * sin(lat.rad) * sin(solar.decli.rad) +
      cos(lat.rad) * cos(solar.decli.rad) * sin(hn.rad)
  )

  # Return as data frame
  data.frame(Date = all.period, Ra = ra)
}
