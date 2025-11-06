#' Soil Heat Flux
#'
#' Calculates the daily amounts of soil heat flux.
#' This function is imported from the CropWaterBalance package.
#'
#' @param Tavg
#' A vector, 1-column matrix or data frame with daily average air temperature.
#' @return
#' Daily amounts of soil heat flux in \eqn{MJ m-2 day-1}.
#' @export
#' @examples
#' Tavg <- Campinas[, 2]
#' Soil_Heat_Flux(Tavg)
 #' @importFrom CropWaterBalance Soil_Heat_Flux
Soil_Heat_Flux <- CropWaterBalance::Soil_Heat_Flux
