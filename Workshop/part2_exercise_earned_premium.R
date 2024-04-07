####### MODULE 2 : EARNED PREMIUM #######

# Load the tidyverse meta-package which includes dplyr and many other packages
library(tidyverse)

###### 1. Exploring Policy Data #############################################

#------ 1.1 Load the policy table ------------------------------------------

# This loads the policy table
policy_df <- read_csv("Data/policy_table.csv")

#------ 1.2 Display the structure of the policy table -----------------------

# printing the table will show a few rows and columns
policy_df

# This is a typical dataset that you would find in an insurance company.
#
# The table has 5 columns:
# policy_id: a unique id for each policy written
# inception_date: the date at which the policy coverage starts
# expiration_date: the date at which the policy coverage ends
# premium: the amount of written premium for the policy
# n_expo: the number of exposures covered by the policy

# Here are other functions to have a quick overview of the data:
str(policy_df)
glimpse(policy_df)
summary(policy_df)

#----- 1.3 Calculate summary statistics ------------------------------------

# High-level information about the data can be obtained using the summarize()
# function that was introduce in the previous module.

### Exercise 1.1
# Using the summarize() function, calculate:
# 1) the average premium
# 2) the total premium
# 3) the total number of exposures

#----- 1.4 Filter the data using filter() ----------------------------------

# In general, statistics across many years are not very useful for actuarial
# analysis. Statistics for a single year are more useful. The filter() function
# from dplyr can be used to select only the rows that correspond to
# a specific year.

df <- filter(  # return a filtered data frame
  policy_df,   # the data frame to filter
  year == 2010 # the condition to filter on: the column "year" is equal to 2010
)

### Exercise 1.2
# Using filter and summarize(), calculate the average premium for policies
# written in 2011.

#------ 1.5 Introducing the pipe `|>` ---------------------------------------

# Notice how we had to create the variable "df" to store the result of filter()
# before sending it to summarize()? df is a temporary variable that is not
# reused.
# When manipulating data, we often chain operations, each function call one
# using the result from the previous function. In this case we are not
# interested in the intermediary results. The pipe operator `|>` avoids the
# need to introduce temporary variables.

# let x, y be variables and fun() a function
# Then `x |> fun()` is equivalent to `fun(x)`
# `x |> fun(y)` is equivalent to `fun(x, y)`

### Exercise 1.3
# Rewrite the filter and summarize operation above using the pipe:

#------ 1.6 Grouping and summarizing ---------------------------------------

# The summarize() function is useful to calculate statistics for the whole
# dataset. However, it is often more useful to calculate statistics for each
# group of a variable. In our case, we might want to calculate the average
# written premium for each year. This is done using the group_by() function:

policy_df |>
  group_by(year) |> # group the data by year
  summarize(average_written_premium = mean(premium))
# This will return the average written premium for each year.

### Exercise 1.4
# Using group_by() and summarize(), calculate the total number of:
# 1) written exposures for each year.
# 2) written premium for each year.
# 3) written policies for each year. (Hint: use n() in summarize()

####### 2. Calculating Earned Premium #######################################

# Calculating the earned premium for each year is more complicated because we
# need to take into account the inception and expiration date of the policies
# to calculate the portion of the premium that is earned in a given year.

#------ 2.1 Calculating earned premium for year 2010 ------------------------

# We first calculate the earned_premium for a single year, 2010.

# First let us define the start and end dates of 2010, using the ymd()
# function from the lubridate package:
start_of_year <- ymd("2010-01-01")
end_of_year <- ymd("2010-12-31")

### Exercise 2.1
# Find another function from lubridate that can be used to calculate the
# end of the year date with a date in the standard US format (mm/dd/yyyy).
# Hint: the function name should start with m.

### Exercise 2.2
# Filter the policies that are in-force in 2010, using the filter()
# function.

# If filter() is provided with multiple conditions, it will return
# only the rows that satisfy all conditions.

### Exercise 2.3
# Create two new columns in policy_df_2010 that contains the beginning date of
# the earning period (begin_earn_date) and the end date of the earning period
# (end_earn_date), over year 2010.
# Hint: use the pmax() and pmin() functions from base R.

# To calculate a duration between two dates using the functions from lubridate,
# there are two steps:
# 1) Define a period between the two dates using the %--% operator
# 2) Calculate the duration of the period, by dividing it by a period object

# For example to calculate the number of days between in 2010:
(start_of_year %--% end_of_year) / days(1) + 1
# The + 1 is necessary because lubridate excludes the end date from the period,
# 12/31/2010 is included in year 2010. Generally, one need to be careful wit
# the boundaries when calculating durations, and in particular check whether the
# expiration date is included in the policy coverage period. Different companies
# might have different conventions.

### Exercise 2.4
# Add new columns in policy_df_2010 with:
# 1) The duration of each policy in policy_df_2010.
# 2) The number of days of the policy that are earned in 2010.
# 3) The ratio of policy earned in 2010 (nb_earn_days / policy_duration).
# 4) The premium earned in 2010 for each policy.

### Exercise 2.5
# Calculate the total premium earned in 2010

#------ 2.2 Calculating earned premium for years 2010 to 2014 ---------------

# Now to calculate the earned premium for each year between 2010
# and 2014 we need to loop over the years and redo the above calculation.
# The traditional way to approach this problem is through a for loop.
# However, mapping functions are a better alternative, because they
# lead to cleaner code. The R package `purrr` provides a set of mapping
# functions. The most basic one is map() which takes a minimum of two
# arguments:
# * x, a vector of elements over which to iterate
# * fun, a function to be called for each element of x
# Calling map(x, fun) will return a list of the form:
# list(fun(x[[1]]), fun(x[[2]]), ...)

### Exercise 2.6
# Use map() to calculate the square of all numbers between 1 and 10

# map() always returns a list. Generally, this is not what we want.
# In this case, returning a vector of double is more appropriate.

### Exercise 2.7
# Use the purrr cheatsheet to find which mapping function to use.
# Hint: it is of the form map_*()

# In a lot of situations, it is very useful to return a data frame
# because much more information can be returned in this way.

### Exercise 2.8
# Find the mapping function that allows you to return a data frame,
# with one row per item in x. Use it to return a data frame with
# two columns, one for x and one for x squared.
# Hint: you will have to modify the input function.

### Exercise 2.9
# Let's now use the previous mapping function to create a data
# frame that has a column for the years (2010 to 2014) and a column
# for the corresponding earned premium.
# Hint: the input function should take one argument for the year.
# Reuse the calculations for 2010 in the body of the function, just
# make them general for any year.
