#' Meteorological data for Campinas, Brazil
#'
#' Daily meteorological data from Campinas, Sao Paulo State, Brazil.
#' The meteorological data belongs to the Agronomic Institute of Campinas.
#'
#'  @format ## `Campinas_daily`
#'  A data frame with 10 columns and 49308 rows:
#'  \describe{
#'    \item{dates}{date}
#'    \item{year}{years}
#'    \item{month}{months}
#'    \item{days}{days}
#'    \item{Rain}{Rain in millimetres}
#'    \item{tmin}{Minimum air temperature in Celsius degrees}
#'    \item{tmax}{Maximum air temperature in Celsius degrees}
#'    \item{PE}{Potential evapotranspiration in millimetres}
#'    \item{PPE}{Rain minus potential evapotranspiration in millimetres}
#'    \item{julian.day}{julian days}
#'    }
#' @source <https://rpubs.com/gabrielblain/1265900>.
#'
#' @examples
#' data(Campinas_daily)
"Campinas_daily"
