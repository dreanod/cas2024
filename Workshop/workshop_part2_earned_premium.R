library(tidyverse)

# This loads the policy table
policy_df <- read_csv("./policy_table.csv")

# printing the table will show a few rows and columns
policy_df

# policy_id: a unique id for each policy written
# inception_date:
# ...

# another way to have a glimpse:
str(policy_df)
glimpse(policy_df)

# to sea all the column names
colnames(policy_df)

# Get a sense of what is going on
summary(policy_df)

# ---- Calculating summaries

summarize(
  policy_df,
  average_premium = mean(premium),
  total_premium = sum(premium),
  total_exposure = sum(n_expo)
)

# ----- Calculate the written premium for year 2010
# use the filter() function

df <- dplyr::filter(policy_df, year == 2010)
summarize(df, average_premium = mean(premium))

# ----- Introducing the pipe `|>`

# Notice how we had to introduce the variable df
# take the result of filter() and feed it to summarize()?
# df is a temporary variable and that does not get
# reused. It often happen that we will have to chain
# operations, each one using the result of the previous
# operation. In this case we are not interested in the
# intermediary results. To avoid having to name and
# manage temporary data frames, we introduce the pipe |>.

# 
# let x, y be variables and fun() a function
# Then `x |> fun()` is equivalent to `fun(x)`
# `x |> fun(y)` is equivalent to `fun(x, y)`

# Rewrite the filter and summarize operation above
# using the pipe:

policy_df |>
  filter(year == 2010) |>
  summarize(average_premium = mean(premium))

# ----- Grouping and summarizing

# this only gives us for one year. How to do it for several years?
# with SQL there is GROUP BY.
# dplyr proposes group_by()

policy_df |>
  group_by(year) |>
  summarize(average_premium = mean(premium))










