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

#' Fit the nonstationary GEV models (SPEIChanges and SPEIChanges_month)
#'
#' @param PPE.week Numeric vector of (rainfall - PET)
#' @param time Numeric vector (same length as PPE.week)
#' @param nonstat.models single integer value indicating the number of nonstationary models to be fitted (from 1 to 3)
#' @param sample.size Integer value indicating the length of PPE.week
#' @note This version uses the \CRANpkg{ismev} package with MLE estimation.
#' @noRd
#' @keywords Internal

Fit.Models <- function(PPE.week, time,nonstat.models,sample.size,criterion="BIC") {
  # Ensure data are finite
  valid <- is.finite(PPE.week) & is.finite(time)
  PPE.week <- PPE.week[valid]
  time <- time[valid]
  criterion <- toupper(criterion)
  if (!criterion %in% c("AICC", "BIC")) {
    stop("`criterion` must be either 'AICc' or 'BIC'.")
  }
  # normalize to lowercase for later comparisons
  criterion_low <- tolower(criterion)
  # Fit candidate models
  if (nonstat.models == 1){
    t.gevs <- list(
      # Stationary
      t.gev = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = NULL, sigl = NULL, shl = NULL,
                                     mulink = identity, siglink = identity, shlink = identity,
                                     muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                     method = "Nelder-Mead", maxit = 10000),
                             error = function(e) NULL
      )),
      # Nonstationary in location only
      t.gev.ns10 = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = 1, sigl = NULL, shl = NULL,
                                          mulink = identity, siglink = identity, shlink = identity,
                                          muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                          method = "Nelder-Mead", maxit = 10000),
                                  error = function(e) NULL
      )))} else if (nonstat.models == 2){
        t.gevs <- list(
          # Stationary
          t.gev = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = NULL, sigl = NULL, shl = NULL,
                                         mulink = identity, siglink = identity, shlink = identity,
                                         muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                         method = "Nelder-Mead", maxit = 10000),
                                 error = function(e) NULL
          )),
          # Nonstationary in location only
          t.gev.ns10 = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = 1, sigl = NULL, shl = NULL,
                                              mulink = identity, siglink = identity, shlink = identity,
                                              muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                              method = "Nelder-Mead", maxit = 10000),
                                      error = function(e) NULL
          )),
          # Nonstationary in scale only
          t.gev.ns01 = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = NULL, sigl = 1, shl = NULL,
                                              mulink = identity, siglink = identity, shlink = identity,
                                              muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                              method = "Nelder-Mead", maxit = 10000),
                                      error = function(e) NULL
          )))
      } else {
        t.gevs <- list(
          # Stationary
          t.gev = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = NULL, sigl = NULL, shl = NULL,
                                         mulink = identity, siglink = identity, shlink = identity,
                                         muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                         method = "Nelder-Mead", maxit = 10000),
                                 error = function(e) NULL
          )),
          # Nonstationary in location only
          t.gev.ns10 = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = 1, sigl = NULL, shl = NULL,
                                              mulink = identity, siglink = identity, shlink = identity,
                                              muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                              method = "Nelder-Mead", maxit = 10000),
                                      error = function(e) NULL
          )),
          # Nonstationary in scale only
          t.gev.ns01 = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = NULL, sigl = 1, shl = NULL,
                                              mulink = identity, siglink = identity, shlink = identity,
                                              muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                              method = "Nelder-Mead", maxit = 10000),
                                      error = function(e) NULL
          )),
          # Nonstationary in both location and scale
          t.gev.ns11 = quiet(tryCatch(gev.fit(PPE.week, ydat = as.matrix(time), mul = 1, sigl = 1, shl = NULL,
                                              mulink = identity, siglink = identity, shlink = identity,
                                              muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                              method = "Nelder-Mead", maxit = 10000),
                                      error = function(e) NULL
          ))
        )
      }

  # Extract log-likelihoods (NLLH = negative log-likelihood)
  ll <- sapply(t.gevs, function(x) if(is.null(x)) NA else -x$nllh)
  # Number of parameters (consistent with your previous definitions)
  k <- c(3, 4, 4, 5)
  if (criterion_low == "aicc"){
    # ---- Calculate AICc ------------------------------------------------------
    AICc <- (2*k - 2*ll) + (2*k*(k+1))/(sample.size - k - 1)
    best <- which.min(AICc)} else {
      # ---- Calculate BIC -------------------------------------------------------
      BIC <- (k*log(sample.size) - 2*ll)
      best <- which.min(BIC)}
  selected.model <- t.gevs[[best]]
  if (best == 1) {
    loc <- rep(as.numeric(selected.model$mle[1]),sample.size)
    scale <- rep(as.numeric(selected.model$mle[2]),sample.size)
    shape <- rep(as.numeric(selected.model$mle[3]),sample.size)} else if (best == 2) {
      loc <- selected.model$mle[1] + selected.model$mle[2]*time
      scale <- rep(as.numeric(selected.model$mle[3]),sample.size)
      shape <- rep(as.numeric(selected.model$mle[4]),sample.size)} else if (best == 3) {
        loc <- rep(as.numeric(selected.model$mle[1]),sample.size)
        scale <- selected.model$mle[2] + selected.model$mle[3]*time
        shape <- rep(as.numeric(selected.model$mle[4]),sample.size)} else {
          loc <- selected.model$mle[1] + selected.model$mle[2]*time
          scale <- selected.model$mle[3] + selected.model$mle[4]*time
          shape <- rep(as.numeric(selected.model$mle[5]),sample.size)}
  return(list(selected.model = selected.model, best = best, loc = loc, scale = scale, shape = shape))
}
