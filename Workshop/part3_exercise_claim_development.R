####### MODULE 3 : CLAIM DEVELOPMENT #######

# Load the tidyverse meta-package which includes dplyr and many other packages
library(tidyverse)

###### 1. Building Triangle Data #############################################

# In many cases the data is not in the right format for actuarial analysis,
# and we need to transform it. This is the case for the claim transaction table
# that we will use in this module.

#------ 1.1 Load the claim transaction table ---------------------------------

transactions_df <- read_csv("Data/claim_transactions.csv")
transactions_df

# This is a typical dataset that you would find in an insurance company.
# One row corresponds to a transaction on a claim (e.g., a payment or
# a reserve change) The claim transaction table has the following columns:
# - claim_id: a unique id for each claim
# - accident_date: the date at which the accident occurred
# - evaluation_date: the date at which the transaction was evaluated
# - payment_amount: the amount paid for the transaction
# - change_in_reserve: the change in the reserve for the claim


### Exercise 1.1
# The columns accident_date and evaluation_date are provided as character
# strings. Use the mdy() function from the lubridate package to convert them
# to date objects.

# In this module, we will develop reported (incurred) claims to ultimate.

### Exercise 1.2
# Add a new column to the transactions_df data frame called incremental_incurred
# with the incremental change to incurred value after each transaction.

#------ 1.2 Calculate one Value of the Reported Triangle ---------------------

### Exercise 1.3
# Let us calculte one value of the reported triangle. We will calculate the
# cumulative incurred value claims occurring in 2010 at 45 months of maturity.
# 1) Filter the transactions for claims occurring in 2010.
# 2) Filter the transaction for these claims at 45 months of maturity.
# (Hint: The evaluation date of the transaction should be less than or equal to
# the start of the accident year + 45 months. Use functions ymd()/mdy() and
# months() from lubridate)
# 3) Calculate the cumulative incurred value for these transactions.

#------ 1.3 Calculate the Full Triangle Data --------------------------------

# In the above exercise we calculated one value of the reported triangle. We
# can use the same logic to calculate all the values of the reported triangle.
# The best apporach is to first create a new data frame with all the possible
# combinations of accident year and maturity.

# We will use the crossing() function from the tidyr package. This function
# creates a new data frame with all the possible combinations of the columns
# provided as arguments.
# For example:
crossing(a = c(1, 2), b = c("x", "y"))
# will create a data frame with 4 rows:
# a b
# 1 x
# 1 y
# 2 x
# 2 y

### Exercise 1.4
# 1) Create a new triangle_df data frame with all the possible combinations of
# accident year and maturity. The maturity should be in months and should range
# from 21 to 129 in steps of 12 months.
# (hint: Use the seq() function with the by = argument to create the maturity
# column)
# 2) Add two new columns to the triangle_df data frame:
#   * cohort_start_date: the start date of the cohort (use the ymd() function
#     with paste0() to create the date)
#   * evaluation_date: the evaluation date of the reported losses from the
#     cohort (add maturity months to the cohort start date and subtract 1 day)
# 3) Filter the triangle_df data frame to keep only the rows where the
#    evaluation_date is less than or equal to the last possible evaluation date
#    (hint: find the last possible evaluation date by looking at the
#    spreadsheet)

### Exercise 1.5
# We can now calculate the cumulative incurred losses for each row triangle_df.
# 1) Write a function calculate_cumulative_incurred() that takes as arguments
# the accident_year and maturity, and calculates the cumulative incurred value
# for the cohort.
# (hint: reuse the code from exercise 1.3)
# 2) Use the pmap_dbl() function from the purrr package to apply the
# calculate_cumulative_incurred() function to each row of the triangle_df data
# frame. pmab_dbl() iterates over the rows of the data frame and applies the
# function to each row. It returns a numeric vector with the results.
# (hint: add the catch-all `...` argument in the
# calculate_cumulative_incurred() function to ignore the other columns of the
# triangle_df data frame)
# 3) Add the cumulative_incurred column to the triangle_df data frame.

#----- 1.4 Pivot the Triangle Data ------------------------------------------

# The triangle data obtained in the previous steps is in a long format. We
# will pivot it to a wide format to see it the way it is usually presented.

### Exercise 1.6
# 1) Use the select() function from the dplyr package to remove the
# cohort_start_date and evaluation_date columns from the triangle_df data frame.
# 2) Use the pivot_wider() function from the tidyr package to pivot the
# triangle_df data frame to a wide format. The pivot_wider() function takes the
# following arguments:
#   * data: the data frame to pivot (triangle_df)
#   * names_from: the column to use for the column names of the new data frame
#   (maturity)
#   * values_from: the column to use for the values of the new data frame
#   (cumulative_incurred)

# When the triangle data is in a wide format, it is more appropriate to use a
# matrix to store it. We can convert the triangle data frame to a matrix using
# the as.matrix() function.

### Exercise 1.7
# 1) Convert the triangle data frame to a matrix and set the row names to the
# accident years.
# (hint: remove the first column of the triangle data frame before converting
# it to a matrix)
# 2) Add the dimension names to the matrix. The dimension names should be
# "accident_year" and "maturity".

###### 2. Developing Claims to Ultimate ######################################

# In this section, we will develop the reported claims to ultimate using the
# the chain-ladder approach.

#----- 2.1 Age-to-Age Factors ------------------------------------------------

# The first step in the chain-ladder method is to calculate the age-to-age
# factors.

# The library ChainLadder provides the function ata() to calculate the
# age-to-age factors. The ata() function takes a triangle matrix as input and
# returns the age-to-age factors.
# install.packages("ChainLadder")
library(ChainLadder)
ata(triangle_matrix)

# We can also calculate the age-to-age factors manually by dividing each
# element of the triangle matrix by the element in the previous column.

### Exercise 2.1
# 1) Calculate the age-to-age factors manually by dividing each element of the'
# triangle matrix by the element in the previous column.
# (hint: you can do this by dividing two shifted subsets of the triangle matrix)
# 2) Remove the last row of the resulting matrix.
# 3) Add the column names to the resulting matrix. The column names should be
# the combination of the maturity years.
# (hint: use the paste() function with the colnames() function to create the
# column names)

# The next step is to select the age-to-age factors, often an average
# of the age-to-age factors from the age-to-age matrix.

### Exercise 2.2
# Calculate the simply weighted age-to-age factors by taking the average of the
# age-to-age factors in each column of the ata_matrix.
# (hint: use the apply() function with the mean() function, and
# na.rm = TRUE to ignore the missing values)

### Exercise 2.3
# In many cases, the dollar-weighted age-to-age factors are used instead of the
# simply weighted age-to-age factors.
# 1) Using apply(), calculate the dollar-weighted age-to-age factors by
# dividing the sum of each column of the triangle matrix by the sum of the
# previous column.
# (hint: take subsets of the triangle matrices, and make sure to replace the
# remove the extra value in the denominator, for example by setting it to NA)

#----- 2.2 Age-to-Ultimate Factors ------------------------------------------

# The next step is to calculate the age-to-ultimate factors.

### Exercise 2.4
# Assuming we have selected the dollar-weighted age-to-age factors, calculate
# the age-to-ultimate factors. We assume that the tail factor is 1.
# (hint: use the function cumprod() to calculate the cumulative products
# and the rev() function to reverse the order of the elements)

#----- 2.3 Ultimate Claims --------------------------------------------------

# The final step is to calculate the ultimate claims.
# It is easier to do this by working on data frames instead of matrices.

### Exercise 2.5
# Create a new data frame age2ult_df with the age-to-ultimate factors.
# The data frame should have two columns: maturity and the corresponding
# age-to-ultimate factor. Add a row with the last possible maturity (129)
# and the tail factor (1).

### Exercise 2.6
# 1) Filter the triangle_df data frame to keep only the latest
# evaluation_date for each accident_year. You will need to do
# a group-filter operation. First group the rows by accident_year,
# with group_by(), then filter the rows with the maximum maturity
# in each group with filter() and max().
# 2) Add a new column to triangle_df with the age-to-ultimate factor.
# To do this we left join triangle_df with age2ult_df on the
# column "maturity". Use the dplyr function left_join().
# (hint: new_df <- left_join(left_df, right_df, by = "joining_column")
# 3) Calculate the ultimate claims by multiplying the cumulative incurred
# column by the age-to-ultimate factor column.
