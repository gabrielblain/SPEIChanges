make_test_data <- function(n_years = 40) {
  set.seed(123)

  years  <- rep(1980:(1980 + n_years - 1), each = 12)
  months <- rep(1:12, times = n_years)

  # Simulated PPE with mild variability
  ppe <- rnorm(length(years), mean = 0, sd = 50)

  cbind(years, months, ppe)
}

test_that("SPEIChanges_month runs with valid input", {

  PPE <- make_test_data()

  expect_message(
    res <- SPEIChanges_month(PPE, nonstat.models = 1)
  )

  expect_true(is.list(res))
})

test_that("SPEIChanges_month fails with invalid input type", {

  bad_input <- data.frame(a = 1:10, b = 1:10)

  expect_error(
    SPEIChanges_month(bad_input, nonstat.models = 1),
    class = "error"
  )

})

test_that("SPEIChanges_month checks number of columns", {

  PPE <- make_test_data()
  PPE_wrong <- PPE[, 1:2]   # remove one column

  expect_error(
    SPEIChanges_month(PPE_wrong, nonstat.models = 1)
  )

})

test_that("SPEIChanges_month handles missing values", {

  PPE <- make_test_data()
  PPE[1,3] <- NA

  expect_error(
    SPEIChanges_month(PPE, nonstat.models = 1)
  )

})
