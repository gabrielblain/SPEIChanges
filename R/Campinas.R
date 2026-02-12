#' Meteorological data for Campinas, Brazil
#'
#' Daily meteorological data from Campinas, Sao Paulo State, Brazil.
#' The meteorological data belongs to the \acronym{NASA} \acronym{POWER} Project.
#'
#'  @format ## `Campinas`
#'  A data frame with 12 columns and 10958 rows:
#'  \describe{
#'    \item{Date}{date}
#'    \item{Tavg}{Average air temperature in Celsius degrees}
#'    \item{Tmax}{Maximum air temperature in Celsius degrees}
#'    \item{Tmin}{Minimum air temperature in Celsius degrees}
#'    \item{WS}{Wind speed in \eqn{m s-1}}
#'    \item{RH}{Relative Humidity  in percentage}
#'    \item{Ra}{Extraterrestrial solar radiation in \eqn{MJ m-2 day-1}}
#'    \item{Rn}{Net radiation in \eqn{MJ m-2 day-1}}
#'    \item{Rain}{Rain in millimetres}
#'    \item{Drz}{Depth of the root zone in metres}
#'    \item{PE}{Potential evapotranspiration calculated using
#'              the Penman-Monteith method in millimeters}
#'    \item{PPE}{Difference between Rain and PE in millimetres}
#'    }
#' @source <https://power.larc.nasa.gov/>.
#'
#' @examples
#' data(Campinas)
"Campinas"
