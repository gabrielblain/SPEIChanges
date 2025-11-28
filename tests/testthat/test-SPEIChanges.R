# Setup mock input data similar to PPEaggreg output
set.seed(123)
n <- 48 * 32  # 32 years, 48 quasi-weeks per year

# Create a matrix with columns Year, Month, quasiWeek, PPE.at.TS (random normal values)
years <- rep(1995:(1995 + 31), each = 48)
months <- rep(rep(1:12, each = 4), times = 32)
quasiWeeks <- rep(1:4, times = 12 * 32)
PPE.at.TS <- rnorm(n, mean = 2, sd = 1)

input.mat <- cbind(years, months, quasiWeeks, PPE.at.TS)
colnames(input.mat) <- c("Year", "Month", "quasiWeek", "PPE.at.TS")
class(input.mat) <- c("TSaggreg", "matrix")

test_that("SPEIChanges returns expected list structure", {
  result <- suppressWarnings(SPEIChanges(input.mat))
  expect_true(is.list(result))
  expect_named(result, c("data.week", "Changes.Freq.Drought", "GEV.parameters"))
  expect_true(is.data.frame(result$data.week))
  expect_true(is.matrix(result$Changes.Freq.Drought))
  expect_true(is.data.frame(result$GEV.parameters))
})

test_that("Input validation errors for PPE.at.TS class", {
  bad_input <- input.mat[, -1]  # remove a column
  expect_error(SPEIChanges(bad_input), "Physically impossible or missing values in PPE.at.TS.")
})

test_that("Input validation errors for nonstat.models", {
  expect_error(SPEIChanges(input.mat, nonstat.models = 0), "must be a single integer")
  expect_error(SPEIChanges(input.mat, nonstat.models = 6), "must be a single integer")
})

test_that("Input validation errors for missing values", {
  input_bad_na <- input.mat
  input_bad_na[1, 4] <- NA
  expect_error(SPEIChanges(input_bad_na), "Physically impossible or missing values in PPE.at.TS.")
})

test_that("Input validation errors for short data length (<10 years)", {
  short_input <- input.mat[1:479, ]
  expect_error(SPEIChanges(short_input), "Less than 10 years")
})

test_that("Warning for less than 30 years data", {
  medium_input <- input.mat[1:(48*29), ]
  expect_warning(SPEIChanges(medium_input), "Less than 30 years")
})

test_that("Input validation for malformed Month and quasiWeek columns", {
  input_bad_month <- input.mat
  input_bad_month[1, 2] <- 13
  expect_error(SPEIChanges(input_bad_month), "Column Month")

  input_bad_quasi <- input.mat
  input_bad_quasi[1, 3] <- 0
  expect_error(SPEIChanges(input_bad_quasi), "Column quasiWeek")
})

test_that("SPEIChanges returns consistent output dimensions and names", {
  result <- suppressWarnings(SPEIChanges(input.mat, nonstat.models = 1))

  # Check data.week structure
  expect_equal(ncol(result$data.week), 8)
  expect_true(all(c("Year", "Month", "quasiWeek", "PPE.at.TS",
                    "SPEI", "Exp.Acum.Prob", "Actual.Acum.Prob",
                    "ChangeDryFreq") %in% names(result$data.week)))

  # Check Changes.Freq.Drought structure
  expect_equal(ncol(result$Changes.Freq.Drought), 8)
  expect_true(all(c("Month", "quasiWeek", "Model", "StatNormalPPE",
                    "NonStatNormalPPE", "ChangeMod", "ChangeSev", "ChangeExt")
                  %in% colnames(result$Changes.Freq.Drought)))

  # Check new GEV.parameters structure
  expect_true(is.data.frame(result$GEV.parameters))
  expect_true(all(c("Month",
                    "quasiWeek",
                    "Location","Scale","Shape") %in% colnames(result$GEV.parameters)))

  # All scale parameters must be positive
  expect_true(all(result$GEV.parameters$Sc1 > 0))
  expect_true(all(result$GEV.parameters$Sc2 > 0))
})

test_that("SPEIChanges handles nonstat.models parameter correctly", {
  for (model in 1:3) {
    result <- suppressWarnings(SPEIChanges(input.mat, nonstat.models = model))
    expect_true(is.list(result))
    expect_named(result, c("data.week", "Changes.Freq.Drought", "GEV.parameters"))
  }
})

test_that("SPEIChanges produces physically consistent probabilities and SPEI values", {
  result <- suppressWarnings(SPEIChanges(input.mat, nonstat.models = 1))
  dw <- result$data.week

  # Probabilities must be in (0, 1)
  expect_true(all(dw$Exp.Acum.Prob > 0 & dw$Exp.Acum.Prob < 1))
  expect_true(all(dw$Actual.Acum.Prob > 0 & dw$Actual.Acum.Prob < 1))

  # SPEI is finite and roughly centered near zero
  expect_true(all(is.finite(dw$SPEI)))
  expect_true(abs(mean(dw$SPEI)) < 0.2)
  expect_true(sd(dw$SPEI) > 0.8 & sd(dw$SPEI) < 1.2)
})

test_that("GEV.parameters contains realistic values", {
  result <- suppressWarnings(SPEIChanges(input.mat, nonstat.models = 1))
  gp <- result$GEV.parameters

  # Expected number of rows (12 months × 4 quasi-weeks)
  expect_equal(nrow(gp), 1536)

  # Shape parameter in typical range (-1, 1)
  expect_true(all(gp$Sh > -1 & gp$Sh < 1))

  # No missing values
  expect_false(anyNA(gp))
})
