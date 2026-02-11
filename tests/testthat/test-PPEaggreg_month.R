test_that("PPEaggreg_month returns correct structure", {
  set.seed(1)
  monthly.PPE <- rnorm(360)

  res <- PPEaggreg_month(
    monthly.PPE,
    start.year = 2000,
    start.month = 1,
    TS = 3
  )

  expect_s3_class(res, "PPEaggreg_month")
  expect_true(is.matrix(res))
  expect_equal(ncol(res), 3)
})
