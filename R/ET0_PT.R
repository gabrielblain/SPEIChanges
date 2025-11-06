#' Reference Evapotranspiration Using the Preistley-Taylor Method
#'
#' Calculates daily reference evapotranspiration amounts using the
#'   Priestley-Taylor method.
#'
#' @param Rn
#' A vector, 1-column matrix or data frame with daily net radiation in
#'  \eqn{MJ m-2 day-1}.
#' @param Tavg
#' A vector, 1-column matrix or data frame with daily average air temperature.
#' @param G
#' Optional. A vector, 1-column matrix or data frame with daily soil heat flux
#'   in \eqn{MJ m-2 day-1}. Default is `NULL` and if `NULL` it is assumed to be zero.
#' @param Coeff
#' Single number defining the Priestley and Taylor coefficient. Default is
#'   1.26.
#
#' @return
#' A matrix object of the daily potential evapotranspiration values in
#'  millimeters.
#'
#' @export
#' @examples

#' Tavg <- Campinas[, 2]
#' Rn <- Campinas[, 8]
#' ET0_PT(Tavg = Tavg, Rn = Rn)
#' @importFrom CropWaterBalance ET0_PT Soil_Heat_Flux
ET0_PT <- CropWaterBalance::ET0_PT
