#' Check User Input Dates for Validity
#'
#' @param x User entered date value
#' @return Validated date string as a `Date` object.
#' @note This was taken from \CRANpkg{nasapower}, but tz changed to UTC.
#' @example .check_date(x)
#' @author Adam H. Sparks \email{adamhsparks@@gmail.com}
#' @importFrom lubridate parse_date_time
#' @keywords Internal
#' @noRd
check_date <- function(x) {
  tryCatch(
    x <- parse_date_time(x,
                         c(
                           "Ymd",
                           "dmY",
                           "mdY",
                           "BdY",
                           "Bdy",
                           "bdY",
                           "bdy"
                         ),
                         tz = "UTC"),
    warning = function(c) {
      stop(
        call. = FALSE,
        "\n`",
        x,
        "` is not in a valid date format. Please enter a valid date format.",
        "\n"
      )
    }
  )
  return(as.Date(x))
}
