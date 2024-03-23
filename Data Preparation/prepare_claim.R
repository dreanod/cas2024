library(actuarialRecipes)
library(tidyverse)
library(dplyr)
library(tidyr)

load_triangle <- function(loss_dev_sheet, values_to) {
  df <- readxl::read_excel(
    "./Appendix A - Auto Indication.xlsx",
    sheet = paste0("Loss Development - ", loss_dev_sheet),
    range = "B9:L19"
  ) |>
    pivot_longer(
      2:11,
      names_to = "maturity",
      values_to = values_to
    ) |>
    mutate(
      maturity = stringr::str_extract(.data$maturity, "^[0-9]+"),
      maturity = as.numeric(.data$maturity)
    )

  df[!is.na(df[[values_to]]), ]
}

paid_triangle <- load_triangle("1", "cumulative_paid")
reported_triangle <- load_triangle("2", "cumulative_incurred")
reported_cc_triangle <- load_triangle("3", "cumulative_incurred_cc")

triangle_data <- paid_triangle |>
  left_join(reported_triangle, by = c("Accident Year", "maturity")) |>
  left_join(reported_cc_triangle, by = c("Accident Year", "maturity")) |>
  mutate(begin_accident_period = first_day_of_year(`Accident Year`)) |>
  mutate(evaluation_date = begin_accident_period + months(maturity))

# Creates one row per claim transaction
transactions <- triangle_data[rep(seq_len(nrow(triangle_data)), triangle_data$cumulative_incurred_cc), ]

# calculate individual claim cumulative incurred and paid
transactions <- transactions |>
  mutate(
    cumulative_incurred = cumulative_incurred / cumulative_incurred_cc,
    cumulative_paid = cumulative_paid / cumulative_incurred_cc
  )

# Drop unused columns
transactions <- transactions |> select(-any_of(c("cumulative_incurred_cc", "maturity", "begin_accident_period")))

# Create claim id
transactions <- transactions |>
  group_by(`Accident Year`, evaluation_date) |>
  mutate(claim_id = paste("claim", `Accident Year`, seq_len(n()), sep = "-")) |>
  ungroup()

transactions <- transactions |>
  group_by(claim_id) |>
  arrange(evaluation_date) |>
  mutate(
    incremental_incurred = cumulative_incurred - dplyr::lag(cumulative_incurred, default = 0),
    incremental_paid = cumulative_paid - dplyr::lag(cumulative_paid, default = 0)
  )

transactions |>
  dplyr::filter(claim_id == "claim-2006-1") |>
  arrange(evaluation_date) |>
  mutate(
    incremental_incurred = cumulative_incurred - dplyr::lag(cumulative_incurred, default = 0),
    incremental_paid = cumulative_paid - dplyr::lag(cumulative_paid, default = 0)
  ) |>
  pull(incremental_incurred)

transactions$incremental_incurred |> range()

# Add date of loss
df_date_of_loss <- transactions |>
  distinct(`Accident Year`, claim_id) |>
  group_by(`Accident Year`) |>
  mutate(accident_date = actuarialRecipes::seq_date_in_year(dplyr::first(`Accident Year`), dplyr::n())) |>
  ungroup() |>
  select(-`Accident Year`)

transactions <- transactions |>
  left_join(df_date_of_loss, by = "claim_id")
# reorder columns

transactions <- transactions |>
  select(
    claim_id, accident_date,
    evaluation_date, incremental_incurred, incremental_paid,
    cumulative_incurred, cumulative_paid
  )

# check on reaggregation

# export
write_csv(transactions, "claim_transactions.csv")


