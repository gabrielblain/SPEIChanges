
test_that("PPEaggreg output has correct structure and class", {
  set.seed(123)
  daily.PPE <- rnorm(365 * 30, mean = 5, sd = 2)  # 30 years of daily data
  start.date <- "1995-01-01"

  output <- PPEaggreg(daily.PPE, start.date)

  expect_true(is.matrix(output))
  expect_equal(colnames(output), c("Year", "Month", "quasiWeek", "PPE.at.TS4"))
  expect_s3_class(output, "TSaggreg")
})

test_that("PPEaggreg gives error for invalid TS values", {
  set.seed(123)
  daily.PPE <- rnorm(365 * 30, mean = 5, sd = 2)
  start.date <- "1995-01-01"

  expect_error(PPEaggreg(daily.PPE, start.date, TS = 0), "TS must be an integer between 1 and 96")
  expect_error(PPEaggreg(daily.PPE, start.date, TS = 97), "TS must be an integer between 1 and 96")
})

test_that("PPEaggreg error on less than 10 years data", {
  short.PPE <- rnorm(3650 - 1)
  start.date <- "1995-01-01"

  expect_error(PPEaggreg(short.PPE, start.date), "Less than 10 years of P-PE records")
})

test_that("PPEaggreg warning on less than 30 years data", {
  PPE_20years <- rnorm(365 * 20)
  start.date <- "1995-01-01"

  expect_warning(PPEaggreg(PPE_20years, start.date), "Less than 30 years of P-PE records")
})

test_that("PPEaggreg TS=1 equals quasi-week sums", {
  set.seed(123)
  daily.PPE <- rnorm(365 * 30, mean = 5, sd = 2)
  start.date <- "1995-01-01"

  output_TS1 <- PPEaggreg(daily.PPE, start.date, TS = 1)
  expect_equal(output_TS1[1:5,4], c(41.28766, 34.39555, 32.84609, 44.49740, 41.96083),tolerance = 0.1)
})

test_that("PPEaggreg handles NA values correctly", {
  set.seed(123)
  daily.PPE <- rnorm(365 * 30, mean = 5, sd = 2)
  daily.PPE[c(100, 200, 300)] <- NA  # Introduce some NA values
  start.date <- "1995-01-01"

  expect_error(PPEaggreg(daily.PPE, start.date), "Physically impossible or missing P-PE values.")
})
