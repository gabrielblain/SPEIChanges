#' Potential Evapotranspiration Using Hargreaves-Samani Method
#'
#' Calculates daily reference evapotranspiration amounts using the
#' Hargreaves-Samani method. This function is imported from the
#' CropWaterBalance package.
#'
#' @param Ra
#' A `vector`, 1-column `matrix` or `data.frame` with extraterrestrial solar
#'  radiation in \eqn{MJ m-2 day-1}.
#' @param Tmax
#' A `vector`, 1-column `matrix` or `data.frame` with daily maximum air
#'  temperature in Celsius degrees.
#' @param Tmin
#' A `vector`, 1-column `matrix` or `data.frame` with daily minimum air
#'  temperature in Celsius degrees.
#' @param Tavg
#' A `vector`, 1-column `matrix` or `data.frame` column with daily average air
#'  temperature.
#' @return
#' A `matrix` of 1-column with the same length as `the input values with the
#'  daily potential evapotranspiration values in millimeters.
#' @export

#' @examples
#' # See `?Campinas` for more on this data set
#' Tavg <- Campinas[, 2]
#' Tmax <- Campinas[, 3]
#' Tmin <- Campinas[, 4]
#' Ra <- Campinas[, 7]
#' ET0_HS(Ra = Ra, Tavg = Tavg, Tmax = Tmax, Tmin = Tmin)
#' @importFrom CropWaterBalance ET0_HS
ET0_HS <- CropWaterBalance::ET0_HS
