# test-Ra.R
test_that("Ra() produces correct and consistent results", {

  # 1. Basic structure and output type
  out <- Ra(lat = 0, start.date = "2020-01-01", end.date = "2020-01-05")

  expect_s3_class(out, "data.frame")
  expect_true(all(c("Date", "Ra") %in% names(out)))
  expect_equal(nrow(out), 5)
  expect_type(out$Ra, "double")
  expect_true(all(!is.na(out$Ra)))

  # 2. Physical range sanity check (Ra in MJ m^-2 day^-1)
  expect_true(all(out$Ra > 0 & out$Ra < 45))

  # 4. Known approximate values for validation
  # At equator, Ra ≈ 37–39 MJ m^-2 day^-1 around equinoxes
  ra_equator <- Ra(lat = 0, start.date = "2020-03-21", end.date = "2020-03-21")$Ra
  expect_true(ra_equator > 35 && ra_equator < 40)

  # 5. Error handling: invalid inputs
  expect_error(Ra(lat = 120, "2020-01-01", "2020-01-02"), "Latitude")
  expect_error(Ra(lat = 0, "2020-01-05", "2020-01-01"), "earlier")
  expect_error(Ra(lat = NA, "2020-01-01", "2020-01-02"), "Latitude")
})
test_that("check_date() correctly validates and parses dates", {
  # Valid date formats
  expect_equal(check_date("2020-01-01"), as.Date("2020-01-01"))
  expect_equal(check_date("01/01/2020"), as.Date("2020-01-01"))
  expect_equal(check_date("January 1, 2020"), as.Date("2020-01-01"))
  expect_equal(check_date("1 Jan 2020"), as.Date("2020-01-01"))

  # Invalid date formats
  expect_error(check_date("2020/13/01"), "not in a valid date format")
  expect_error(check_date("31-02-2020"), "not in a valid date format")
  expect_error(check_date("invalid-date"), "not in a valid date format")
})
test_that("Ra() handles edge cases correctly", {
  # Edge case: Latitude at poles
  ra_north_pole <- Ra(lat = 89.9, start.date = "2020-12-21", end.date = "2020-12-21")$Ra
  ra_south_pole <- Ra(lat = -89.9, start.date = "2020-06-21", end.date = "2020-06-21")$Ra
  expect_equal(ra_north_pole, 0)  # No radiation during polar night
  expect_equal(ra_south_pole, 0)  # No radiation during polar night

  # Edge case: Start and end date are the same
  ra_single_day <- Ra(lat = 45, start.date = "2020-03-21", end.date = "2020-03-21")
  expect_equal(nrow(ra_single_day), 1)

  # Edge case: Very short date range (2 days)
  ra_two_days <- Ra(lat = 30, start.date = "2020-06-20", end.date = "2020-06-21")
  expect_equal(nrow(ra_two_days), 2)
})
test_that("Ra() handles leap years correctly", {
  # Leap year: February 29 should be included
  ra_leap_year <- Ra(lat = 0, start.date = "2020-02-28", end.date = "2020-03-01")
  expect_equal(nrow(ra_leap_year), 3)
  expect_equal(ra_leap_year$Date[2], as.Date("2020-02-29"))

  # Non-leap year: February 29 should not exist
  ra_non_leap_year <- Ra(lat = 0, start.date = "2019-02-28", end.date = "2019-03-01")
  expect_equal(nrow(ra_non_leap_year), 2)
})
test_that("Ra() handles large date ranges efficiently", {
  # Large date range: 10 years
  ra_large_range <- Ra(lat = 45, start.date = "2010-01-01", end.date = "2020-01-01")
  expect_equal(nrow(ra_large_range), 3653)  # 10 years including leap years

  # Check a few random dates for expected Ra values
  expect_true(all(ra_large_range$Ra > 0 & ra_large_range$Ra < 45))
})
