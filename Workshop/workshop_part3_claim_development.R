library(dplyr)
library(readr)

transactions_df <- read_csv("Data/claim_transactions.csv")


transactions_df <- transactions_df |>
  mutate(
    accident_date = mdy(accident_date),
    evaluation_date = mdy(evaluation_date)
  )

# calculate cumulative incurred for accident year 2005
# at 21 months maturity

max_eval_date <- ymd("2005-01-01") + months(21)

transactions_2005_21m <- transactions_df |>
  filter(
    year(accident_date) == 2005,
    evaluation_date <= max_eval_date
  )
sum(transactions_2005_21m$incremental_incurred)

# calculate maturity
crossing(
  accident_year = 2005:2014,
  maturity = seq(21, 129, by = 12)
) |>
  mutate(cohort_start_date = ymd(paste0(accident_year, "-01-01"))) |>
  mutate(evaluation_date = cohort_start_date + months(maturity) - days(1))


