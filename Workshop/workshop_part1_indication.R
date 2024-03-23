##### INTRODUCTION #####


# Welcome to the R workshop!
# This file reproduces all the steps that go into making the Rate Indication
# Appendix A from Werner, CAS Exam 5
# We will walk step by step to make the rate indication
# Along the way I will introduce different feature of the R language

#----- Objective


#----- Organization

# We will follow the precept of "Starting with the end in mind"
# 



###### A PRIMER TO R AND RSTUDIO #######

# What you're reading is an R script.
# An R script is a text file that ends with the suffix .R
# It contains R commands, ie R instructions that R can understand and execute.
# To execute any line, position your cursor on the line and press Ctrl + Enter
# This will send the line to R console and execute it
# For example try on this line:

1 + 1 # <--- move your cursor to this line and press Ctrl + Enter

# You should see something like this in the console:

# > 1 + 1 # <--- move your cursor to this line and press Ctrl + Enter
# [1] 2

# Comments are everything that follows the hash (#) character.
# Comments are alway ignored by R and are never executes. Their purpose to for
# the author to communicate to human readers of the file.
# In this file I will use a lot of comments to explain what is happening.

###### STEP 1: Introduction to Vectors

# The most basic data structure in R is the vector. A vector is a 1-dimensional array
# of values of the same type (double, integer, character, logical).
# For example we can store the annual earned premium in a vector
# TODO: link to datapasta

earned_premium <- c(14904664, 14494543, 14442449, 14834605, 18265093)
# "earned_premium" is the variable that will refer to the earned premium
# "<-" assigns a value/object to a variable. It's equivalent to "=".
# "c()" is a function that creates a vector by concatenating all of its arguments together

# Splicing
# You can access a particular value through its index. For example to access the
# earned premium for the first year:

earned_premium[1]

# Warning if you're coming from a different programming language, you may be used to
# having the first index be 0!
# For extracting the first 3 earned_premium you need to do:

earned_premium[1:3]

# Can you guess how to get premiums for:
# - years 2 to 5?
# - 2 and 4 only?
# - year 4 to the end? (hint use the function length() to know that is the index of the last value)

# solutions:
earned_premium[2:5]
earned_premium[c(2, 4)]
earned_premium[4:length(earned_premium)]

# Now one problem with this is this is that you have to remember that index 1 corresponds to 2010 for example.
# This is not very practical.
# One thing you can do therefore is to name the vector with the years
names(earned_premium) <- 2010:2014

# Now we can get the premium for year 2010 using this command:
earned_premium["2010"]

# Can you guess how to get the premium for:
# - 2011 through 2013?
# - 2011 and 2014?

# Solution
earned_premium[as.character(2011:2013)]
earned_premium[c("2011", "2014")]

# Named vectors are interesting in that they provide more context to the values
# in the vector. But we will see that data frames can do the same and are far superior, so in
# practice I don't use named vector that often.

# Let's now try to calculate the on-level premium. For this we
# need the current rate level factor:
crl_factor <- c(1.2029, 1.2058, 1.2724, 1.3019, 1.2390)

# Can you guess how to calculate the on-level premium:

# Solution:
onlevel_premium <- earned_premium * crl_factor

# You might be tempted to use a for loop to do this. Resist the urge!
# There are two reasons why:
# - Many functions are optimized to work on vectors. Using for loops
#   will result in less efficient code
# - Vectorized code is usually cleaner and more understandable.
#   Which means it's easier to debug and less work to maintain.
# Generally, if you find yourself using a loop try to think hard how you
# could avoid it.

# Let's calculate the ultimate loss and ALAE Ratio
ultimate_loss_alae <- c(11673500, 11200326, 6288433, 18257745, 23362601)
net_trend_factor <- c(1.7907, 1.6444, 1.5100, 1.3866, 1.2732)
# Can you calculate the projected ultimate loss and ALAE loss ratio for
# every year?

# Solution
onlevel_ultimate_loss_lae <- ultimate_loss_alae * net_trend_factor
projected_lr <- onlevel_ultimate_loss_lae / onlevel_premium
projected_lr

# Can you calculate the aggregated projected Loss Ratio as well?
# Hint: use the sum() function
total_ol_ult_loss <- sum(onlevel_ultimate_loss_lae)
total_ol_premium <- sum(onlevel_premium)
total_projected_lr <- total_ol_ult_loss / total_ol_premium
total_projected_lr

#### Introducing data frames

# So far we have only used the simple vector data structure to do all the
# calculations. For simple calculations like what we've done this is
# enough. However, when the complexity of the data of the operation
# increases this approach becomes unpractical:
# - We need to create a new variable for each new or derived attribute
# - We cannot easily filter what's related to a single given year
# The solution is to organize the data under the form of a table.
# This is exactly what a data frame is.

# R comes with the base function data.frame() to create a data frame.
# This function is little less easy to use that tibble() which comes
# with the R package dplyr, which we will use here.

library(dplyr) # Loads the dplyr package.
# If not installed, try install.packages("dplyr") first

# In essence a data frame bundles together a number of vector that
# are related. Therefore we can create a data frame from several
# vectors:

indication_df <- tibble(
  accident_year = 2010:2014,
  earned_premium = c(14904664, 14494543, 14442449, 14834605, 18265093),
)
indication_df
# Printing a data frame displays a nice table in the console
# In RStudio, you can also place the cursor on the variable name and press <F2>
# to open a table viewer.

# You can extract the vector using $:
indication_df$earned_premium

# To add a new column, you can use $ along with the assignment operator:
indication_df$crl_factor <- c(1.2029, 1.2058, 1.2724, 1.3019, 1.2390)

# Can you guess how to create a new column with the on-level premium?

# Solution
indication_df$onlevel_premium <- indication_df$earned_premium * indication_df$crl_factor
indication_df

# Do you notice how we repeat "indication_df$" three times?
# We can avoid this by using the dplyr function mutate():

indication_df <- mutate(
  indication_df,                                # First argument is the data frame to modify
  onlevel_premium = earned_premium * crl_factor # Second argument defines what to create
)
indication_df

# Exercise
# 1) Using tibble(), create a new indication_df data frame that has accident year, earned premium
# current rate level factor, ultimate loss and ALAE, and net trend factor
# 2) Using mutate(), calculate the on-level premium, the on-level ultimate loss and ALAE and the
# projected ultimate loss and ALAE ratio
indication_df <- tibble(
  accident_year = 2010:2014,
  earned_premium = c(14904664, 14494543, 14442449, 14834605, 18265093),
  crl_factor = c(1.2029, 1.2058, 1.2724, 1.3019, 1.2390),
  ultimate_loss_alae = c(11673500, 11200326, 6288433, 18257745, 23362601),
  net_trend_factor = c(1.7907, 1.6444, 1.5100, 1.3866, 1.2732),
)
indication_df <- mutate(
  indication_df,
  onlevel_premium = earned_premium * crl_factor,
  onlevel_loss_alae = ultimate_loss_alae * net_trend_factor,
  projected_lr = onlevel_loss_alae / onlevel_premium
)

# As you can see mutate() is quite a useful and flexible function.
# The dplyr package also provides useful select() to subset and reorder and
# rename columns, and summarize() to aggregate accross rows.

# For example you may be only interested in the projected LR for each year,
# and want to rename accident year to calendar year:
select(indication_df, calendar_year = accident_year, projected_lr)

# Exercise:
# 1) Only select the year projected premium, loss and loss ratio
# 2) Reorder the columns in the same order as in the spreadsheet

# The following calculates the total earned premium and ultimate losses
summarize(
  indication_df,
  earned_premium = sum(earned_premium),
  ultimate_loss_alae = sum(ultimate_loss_alae)
)

# Exercise:
# 1) Calculate the aggregated on-level earned premium, ultimate loss and
# loss ratio:
# 2) Can you also calculate the straight average projected LR?

# Solution
summarize(
  indication_df,
  earned_premium = sum(earned_premium),
  onlevel_premium = sum(onlevel_premium),
  ultimate_loss_alae = sum(ultimate_loss_alae),
  onlevel_ultimate_loss_lae = sum(onlevel_ultimate_loss_lae),
  straight_average_projected_lr = mean(projected_lr),
  dollar_average_projected_lr = onlevel_ultimate_loss_lae / onlevel_premium
)


#### Calculating Earned premium from a policy table #####

# loading data
# use read_csv()

# working with dates to calculate earned premium
# use group_by()
# use summarize()


# group and summarize


#### Developing Losses to Ultimate #######



######### Current Rate Level

#------- Current Rate Level 1

library(lubridate) # this makes it easier to work with dates

# Introducing vectors and named vectors
rate_change <- c(-.076, .146, .136)
rate_change_dates <- c("10/1/11", "3/1/14", "7/1/15")

rate_change_dates <- mdy(rate_change_dates)

# Introducting data frames
rate_change_df <- tibble(
  rate_level_group = LETTERS[1:4],
  effective_date = c(NA, rate_change_dates),
  rate_change = c(0, rate_change),
)

rate_change_df <- rate_change_df |>
  mutate(
    rate_change_index = 1 + rate_change,
    cumulative_rate_level_index = cumprod(rate_change_index)
  )

crl_index <- rate_change_df$cumulative_rate_level_index[nrow(rate_change_df)]

# write back to csv

#------- Current Rate Level 2

# load portion of premium in each rate level group
library(readxl)
rate_level_groups_df <- read_excel("rate_level_groups.xlsx")

# do the join
rate_level_groups_df <- rate_level_groups_df |>
  left_join(rate_change_df, by = "rate_level_group")

rate_level_groups_df |>
  group_by(calendar_year) |>
  summarize(average_rate_level = sum(portion_of_earned_premium * cumulative_rate_level_index)) |>
  mutate(crl_factor = crl_index / average_rate_level)

# write back to csv

########## Loss Development

#--------- Loss Development - 1: Paid Loss Development

claim_trans_df <- read_excel("Appendix A - Auto Indication.xlsx", sheet = "Claim Transaction Data")

