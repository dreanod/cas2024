library(tidyverse)

# This loads the policy table
policy_df <- read_csv("Data/policy_table.csv")

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
  summarize(average_written_premium = mean(premium))

# ------- Calculating earned premium

# This is more complicated. We need to work on inception dates
# and expiration dates to figure out the proportion of premium
# earned over a given year 2010.

start_of_year <- ymd("2010-01-01")
end_of_year <- ymd("2010-12-31")

# Filter the policies that are in-force in 2010

policy_df_2010 <- policy_df |>
  filter(
    inception_date <= end_of_year,
    expiration_date >= start_of_year
  )

# What is the period over which these policies earn in 2010?

policy_df_2010 <- policy_df_2010 |>
  mutate(
    begin_earn_date = pmax(start_of_year, inception_date),
    end_earn_date = pmin(end_of_year, expiration_date)
  )

# how many days of the policies are earned in 2010?
policy_df_2010 <- policy_df_2010 |>
  mutate(
    nb_earn_days = (begin_earn_date %--% end_earn_date) / days(1) + 1
  )

# how many days are covered by the policy?
policy_df_2010 <- policy_df_2010 |>
  mutate(
    policy_duration = (inception_date %--% expiration_date) / days(1) + 1
  )

# Calculate the ratio of premium earned in 2010
policy_df_2010 <- policy_df_2010 |>
  mutate(
    ratio_earned_policy = nb_earn_days / policy_duration
  )

# calculate the premium earned in 2010
policy_df_2010 <- policy_df_2010 |>
  mutate(
    earned_premium = ratio_earned_policy * premium
  )

# Calculate the total premium earned in 2010
sum(policy_df_2010$earned_premium)


# Now to calculate the earned premium for each year between 2010
# and 2014 we need to loop over the year and redo the above calculation.
# The traditional way to approach this problem is through a for loop.
# However, mapping functions are a better alternative, because they
# lead to cleaner code. The R package `purrr` provides a set of mapping
# functions. The most basic one is map() which takes a minimum of two
# arguments:
# * x, a vector of elements over which to iterate
# * fun, a function to be called for each element of x
# Calling map(x, fun) will return a list of the form:
# list(fun(x[[1]]), fun(x[[2]]), ...)

# Use map() to calculate the square of all numbers between 1 and 10
square_fun <- function(x) x^2
map(1:10, square_fun)

# map() always returns a list. Generally, this is not what we want. 
# In this case, returning a vector of double is more appropriate.
# Use the purrr cheatsheet to find which mapping function to use.
# Hint: it is of the form map_*()
map_dbl(1:10, square_fun)

# In a lot of situations, it is very useful to return a data frame
# because much more information can be returned in this way. Find
# the mapping function that allows you to return a data frame,
# with one row per item in x. Use it to return a data frame with
# two columns, one for x and one for x squared.
# Hint: you will have to modify the input function.
square_df_fun <- function(x) tibble(x = x, x_square = x^2)
map_dfr(1:10, square_df_fun)

# Let's now use the previous mapping function to create a data
# frame that has a column for the years (2010 to 2014) and a column
# for the corresponding earned premium.
# Hint: the input function should take one argument for the year.
# Reuse the calculations for 2010 in the body of the function, just
# make them general for any year.

calculate_earned_premium <- function(year) {
  start_of_year <- ymd(paste0(year, "-01-01"))
  end_of_year <- ymd(paste0(year, "-12-31"))

  df <- policy_df |>
    filter(
      inception_date <= end_of_year,
      expiration_date >= start_of_year
    ) |>
    mutate(
      begin_earn_date = pmax(start_of_year, inception_date),
      end_earn_date = pmin(end_of_year, expiration_date),
      nb_earn_days = (begin_earn_date %--% end_earn_date) / days(1) + 1,
      policy_duration = (inception_date %--% expiration_date) / days(1) + 1,
      ratio_earned_policy = nb_earn_days / policy_duration,
      earned_premium = ratio_earned_policy * premium
    )

  earned_premium <- sum(df$earned_premium)

  tibble(year = year, earned_premium = earned_premium)
}
map_dfr(2010:2014, calculate_earned_premium)
