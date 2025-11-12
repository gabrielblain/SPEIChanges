
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
  expect_named(result, c("data.week", "Changes.Freq.Drought"))
  expect_true(is.data.frame(result$data.week))
  expect_true(is.matrix(result$Changes.Freq.Drought))
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
  expect_equal(ncol(result$Changes.Freq.Drought), 14)
  expect_true(all(c("Month", "quasiWeek", "Model", "StatNormalPPE",
                    "NonStatNormalPPE", "ChangeMod", "ChangeSev", "ChangeExt",
                    "Loc1", "Loc2", "Loc3", "Sc1", "Sc2", "Sh")
                  %in% colnames(result$Changes.Freq.Drought)))
})
test_that("SPEIChanges handles nonstat.models parameter correctly", {
  for (model in 1:5) {
    result <- suppressWarnings(SPEIChanges(input.mat, nonstat.models = model))
    expect_true(is.list(result))
    expect_named(result, c("data.week", "Changes.Freq.Drought"))
  }
})

test_that("SPEIChanges produces physically consistent probabilities and SPEI values", {
  result <- suppressWarnings(SPEIChanges(input.mat, nonstat.models = 1))
  dw <- result$data.week

  # Probabilities must be in (0, 1)
  expect_true(all(dw$Exp.Acum.Prob > 0 & dw$Exp.Acum.Prob < 1))
  expect_true(all(dw$Actual.Acum.Prob > 0 & dw$Actual.Acum.Prob < 1))

  # SPEI is finite and approximately normal
  expect_true(all(is.finite(dw$SPEI)))
  expect_true(abs(mean(dw$SPEI)) < 0.2)   # Roughly centered near 0
})

