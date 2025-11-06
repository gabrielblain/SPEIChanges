#' Reference Evapotranspiration Using the Penman and Monteith Method
#'
#' Calculates daily reference evapotranspiration amounts using the Penman and
#'  Monteith method. This function is imported from the
#'  CropWaterBalance package.
#'
#' @param Tavg
#' A vector, 1-column matrix or data frame with daily average air temperature.
#' @param Tmax
#' A vector, 1-column matrix or data frame with daily maximum air temperature
#'  in Celsius degrees.
#' @param Tmin
#' A vector, 1-column matrix or data frame with daily minimum air temperature
#'  in Celsius degrees.
#' @param Rn
#' A vector, 1-column matrix or data frame with daily net radiation in
#' \eqn{MJ m-2 day-1}.
#' @param RH
#' A vector, 1-column matrix or data frame with daily relative Humidity in percentage.
#' @param WS
#' A vector, 1-column matrix or data frame with daily wind speed in
#'  \eqn{m s-1}.
#' @param G
#' Optional. A vector, 1-column matrix or data frame with daily soil heat flux
#'  in \eqn{MJ m-2 day-1}.
#' Default is `NULL` and if `NULL` it is assumed to be zero.

#' @param Alt
#' A single number defining the altitude in meters.
#' @return
#' A matrix of daily potential evapotranspiration amounts in millimeters.
#' @export
#' @examples

#' Tavg <- Campinas[, 2]
#' Tmax <- Campinas[, 3]
#' Tmin <- Campinas[, 4]
#' Rn <- Campinas[, 8]
#' WS <- Campinas[, 5]
#' RH <- Campinas[, 6]
#' ET0_PM(Tavg = Tavg,
#'        Tmax = Tmax,
#'        Tmin = Tmin,
#'        Rn = Rn,
#'        RH = RH,
#'        WS = WS,
#'        Alt = 658)
#' @importFrom CropWaterBalance ET0_PM Soil_Heat_Flux
ET0_PM <- CropWaterBalance::ET0_PM
