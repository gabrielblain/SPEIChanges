test_that("PPEaggreg_month returns correct structure and values", {
  monthly.PPE <- PPEaggreg_month(
        Campinas_monthly[,7],
        start.year = 1890,
        start.month = 1,
        TS = 1)

  expect_s3_class(monthly.PPE, "PPEaggreg_month")
  expect_true(is.matrix(monthly.PPE))
  expect_equal(ncol(monthly.PPE), 3)
  expect_equal(nrow(monthly.PPE), 1620)
  expect_equal(
    monthly.PPE[1:5,3],
    c(
      155.03,
      75.98,
      46.67,
      -106.72,
      33.30
    ),
    tolerance = 0.05
  )
})

test_that("PPEaggreg_month works as expected in example", {
  three_month <- PPEaggreg_month(
    Campinas_monthly[,7],
    start.year = 1890,
    start.month = 1,
    TS = 3)

  expect_s3_class(three_month, "PPEaggreg_month")
  expect_true(is.matrix(three_month))
  expect_equal(ncol(three_month), 3)
  expect_equal(nrow(three_month), 1618)
  expect_equal(
    three_month[1:5,3],
    c(
      277.68,
      15.93,
      -26.75,
      -122.81,
      -67.50
    ),
    tolerance = 0.05
  )
})

test_that("monthly.PPE input types are handled correctly", {

  x <- as.matrix(Campinas_monthly[,7])

  expect_silent(PPEaggreg_month(x, 1890, 1, 1))
  expect_silent(PPEaggreg_month(as.matrix(x), 1890, 1, 1))
  expect_silent(PPEaggreg_month(data.frame(x), 1890, 1, 1))

})

test_that("monthly.PPE with more than one column fails", {

  bad <- Campinas_monthly[,6:7]

  expect_error(
    PPEaggreg_month(bad, 1890, 1, 1),
    "Physically impossible or missing P-PE values."
  )

})

test_that("monthly.PPE with NA fails", {

  x <- Campinas_monthly[,7]
  x[10] <- NA

  expect_error(
    PPEaggreg_month(x, 1890, 1, 1),
    "Physically impossible or missing P-PE values."
  )

})

test_that("TS validation works correctly", {

  x <- Campinas_monthly[,7]

  expect_error(PPEaggreg_month(x, 1890, 1, 0),"TS must be an integer between 1 and 24.")
  expect_error(PPEaggreg_month(x, 1890, 1, 25),"TS must be an integer between 1 and 24.")
  expect_error(PPEaggreg_month(x, 1890, 1, 1.5),"TS must be an integer between 1 and 24.")
  expect_error(PPEaggreg_month(x, 1890, 1, "3"),"TS must be an integer between 1 and 24.")

})

test_that("start.year and start.month are validated", {

  x <- Campinas_monthly[,7]

  expect_error(PPEaggreg_month(x, -1, 1, 1),
               "start.year must be an integer equal to or larger than 0")
  expect_error(PPEaggreg_month(x, 1890.5, 1, 1),
               "start.year must be an integer equal to or larger than 0")
  expect_error(PPEaggreg_month(x, 1890, 0, 1),
               "start.month must be an integer between 1 and 12")
  expect_error(PPEaggreg_month(x, 1890, 13, 1),
               "start.month must be an integer between 1 and 12")

})

test_that("length constraints are enforced", {

  x_short <- rep(1, 100)
  x_warn  <- rep(1, 200)

  expect_error(
    PPEaggreg_month(x_short, 2000, 1, 1),
    "Less than 10 years of monthly P-PE records. We cannot proceed."
  )

  expect_warning(
    PPEaggreg_month(x_warn, 2000, 1, 1),
    "Less than 30 years of P-PE records. Longer periods are highly recommended."
  )

})

test_that("TS = 1 reproduces original series", {

  x <- Campinas_monthly[,7]

  out <- PPEaggreg_month(x, 1890, 1, 1)

  expect_equal(out[,3], x, tolerance = 1e-10)

})
