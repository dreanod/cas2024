# Preparing Premium data

n_pol <- 10000
library(actuarialRecipes)
library(lubridate)

policy_df <- simulate_portfolio(
  sim_years = 2004:2015,
  initial_policy_count = 10000,
  ptf_growth = 0,
  n_expo_per_policy = 1,
  policy_length = 12,
  initial_avg_premium = 1,
  premium_trend = 0,
  rate_change_data = NULL
)

# calculate number of earned expo per year

earned_exposures <- purrr::map_dbl(set_names(2005:2014), function(y) {
  start_of_year <- ymd(paste0(y, "-01-01"))
  end_of_year <- ymd(paste0(y, "-12-31"))
  start_of_expo_in_year <- pmax(start_of_year, policy_df$inception_date)
  end_of_expo_in_year <- pmin(end_of_year, policy_df$expiration_date)
  ee <- pmax(0, (start_of_expo_in_year %--% (end_of_expo_in_year + days(1))) / years(1))
  ep <- ee * policy_df$premium
  sum(ep)
})

earned_exposures

df <- purrr::map_dfr(set_names(2005:2014), function(y) {
  start_of_year <- ymd(paste0(y, "-01-01"))
  end_of_year <- ymd(paste0(y, "-12-31"))

  df1 <- policy_df |> dplyr::filter(year(inception_date) < y)
  df2 <- policy_df |> dplyr::filter(year(inception_date) >= y)

  start_of_expo_in_year <- pmax(start_of_year, df1$inception_date)
  end_of_expo_in_year <- pmin(end_of_year, df1$expiration_date)
  policy_duration <- ((df1$inception_date %--% df1$expiration_date) / days(1)) + 1
  ee <- pmax(0, (start_of_expo_in_year %--% (end_of_expo_in_year + days(1))) / days(1)) / policy_duration
  ee_previous_year <- sum(ee)

  start_of_expo_in_year <- pmax(start_of_year, df2$inception_date)
  end_of_expo_in_year <- pmin(end_of_year, df2$expiration_date)
  policy_duration <- ((df2$inception_date %--% df2$expiration_date) / days(1)) + 1
  ee <- pmax(0, (start_of_expo_in_year %--% (end_of_expo_in_year + days(1))) / days(1)) / policy_duration
  ee_this_year <- sum(ee)

  tibble::tibble(
    year = y,
    ee_from_previous_years = ee_previous_year,
    ee_from_current_year = ee_this_year,
  )
})

df <- df |>
  mutate(
    total_ee = ee_from_current_year + ee_from_previous_years,
    ep = c(
      17944254,
      17942995,
      18532758,
      18265093,
      15590108,
      14904664,
      14494543,
      14442449,
      14834605,
      18265093
    )
  )
df$average_premium <- NA_real_
df$average_premium[1] <- df$ep[1] / df$total_ee[1]
df$ep_prev_year <- NA_real_
df$ep_current_year <- NA_real_


for (n in 2:nrow(df)) {
  df$ep_prev_year[n] <- df$ee_from_previous_years[n] * df$average_premium[n - 1]
  df$ep_current_year[n] <- df$ep[n] - df$ep_prev_year[n]
  df$average_premium[n] <- df$ep_current_year[n] / df$ee_from_current_year[n]
}

df |> select(year, ep_prev_year, ep_current_year, ep)

readr::write_csv(df, "out2.csv")

policy_df$premium <- NULL
policy_df$year <- lubridate::year(policy_df$inception_date)

df <- df |> select(year, premium = average_premium)
df <- dplyr::rows_insert(df, tibble(year = 2004, premium = df$premium[1]))
policy_df <- policy_df |>
  dplyr::left_join(df, by = "year") |>
  dplyr::filter(year < 2015)
df

readr::write_csv(policy_df, "policy_table.csv")
