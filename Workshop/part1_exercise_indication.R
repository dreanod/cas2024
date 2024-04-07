##### INTRODUCTION #####

###### QUICK INTRODUCTION TO R AND RSTUDIO #######

# What you're reading is an R script. An R script is a text file that ends with
# the suffix .R It contains R commands, ie R instructions that R can understand
# and execute. To execute any line, position your cursor on the line and press
# Ctrl + Enter This will send the line to the R console and execute it For
# example try on this line:

1 + 1 # <--- move your cursor to this line and press Ctrl + Enter

# You should see something like this in the console:
# [1] 2

# Comments are everything that follows the hash (#) character. Comments are
# ignored by R. Their purpose to for the author to communicate to human readers
# of the file. In this file I will use comments to give you instructions and
# hints on what to do.

#-------- Useful shortcuts in RStudio

# * To get help and documentation on a function, place the cursor on it and
# press <F1>
# * To preview a dataset, place the cursor on its name in the editor and press
# <F2>
# * To execute an R expression from the editor, place the cursor on the
# expression and press <Ctrl-Enter>


###### MODULE 1: RATE INDICATION #####


###### 1. Introduction to Vectors #############################################

# The most basic data structure in R is the vector. A vector is a 1-dimensional
# array of values of the same type (double, integer, character, logical).
# For example we can store the annual earned premium in a vector:

earned_premium <- c(14904664, 14494543, 14442449, 14834605, 18265093)

# "earned_premium" is the variable that will refers to the vector object.
# "<-" assigns a value/object to a variable. It's equivalent to "=".
# "c()" is a function that creates a vector by concatenating all of
# its arguments together.

#------ 1.1 Subsetting Vectors ----------------------------------------------

# You can access a particular value through its index. For example to access the
# earned premium for the first year:

earned_premium[1]

# Note: In R, indices start at 1, not 0 like in some other programming
# languages.

# For extracting the first 3 earned_premium you need to do:
earned_premium[1:3]

### Exercise 1.1
# Can you guess how to get premiums for:
# - years 2 to 5?
# - 2 and 4 only? (hint use the function c())
# - year 4 to the end? (hint use the function length() to know that is the
#   index of the last value)

#------ 1.2 Named Vectors ---------------------------------------------------

# One problem with vectors is this is that you have to remember that index 1
# corresponds to year 2010 for example. This can be confusing. One thing
# that can help is to name the vector. This way you can access the value
# by the year instead of the index. The syntax for naming a vector is:
names(earned_premium) <- 2010:2014
earned_premium

# Now we can get the premium for year 2010 using this command:
earned_premium["2010"]

### Exercise 1.2
# Can you guess how to get the premium for:
# - 2011 through 2013?
# - 2011 and 2014?
# Hint: use the as.character() function to convert the years to character,
# because the names of the vector are always characters.

# Named vectors provide more context to the values in the vector. But we will
# see that data frames can do the same and are more powerful in practice.

#--- 1.3 Vectorized Operations ----------------------------------------------

### Exercise 1.3
# Let's now calculate the on-level premium. (Actual premium times the current
# rate level factor). Here is the current rate level factor:
crl_factor <- c(1.2029, 1.2058, 1.2724, 1.3019, 1.2390)

# You might be tempted to use a for loop to do this.
# There are two reasons why you should avoid using for loops in R:
# - Many functions are optimized to work on vectors. Using for loops
#   will result in less efficient code
# - Vectorized code is usually cleaner and more understandable.
#   Which means it's easier to debug and less work to maintain.
# Generally, if you find yourself using a loop try to think hard how you
# could avoid it.

# Let's calculate the ultimate loss and ALAE Ratio
ultimate_loss_alae <- c(11673500, 11200326, 6288433, 18257745, 23362601)
net_trend_factor <- c(1.7907, 1.6444, 1.5100, 1.3866, 1.2732)

### Exercise 1.4
# Calculate the projected ultimate loss and ALAE loss ratio for
# every year?

### Exercise 1.5
# Calculate the aggregated projected loss ratio (The dollar-weighted
# projected ultimate loss and ALAE ratio for all years)
# Hint: use the sum() function

###### 2. Introducing data frames #############################################

# So far we have only used the simple vector data structure to do all the
# calculations. For simple calculations like what we've done this is
# enough. However, when the complexity of the data of the operation
# increases this approach becomes unpractical:
# - We need to create a new variable for each new or derived attribute
# - We cannot easily filter what's related to a single given year
# The solution is to organize the data under the form of a table.
# This is exactly what a data frame is.

#------ 2.1 Creating a data frame -------------------------------------------

# R comes with the base function data.frame() to create a data frame.
# This function is little less easy to use that tibble() which is loaded with
# the tidyverse package. (The tidyverse is a collection of packages that
# work well together and are designed to make data analysis easier.)

library(tidyverse) # Loads the dplyr package.
# If not installed, try install.packages("tidyverse") first

# In essence a data frame bundles together a number of vector that
# are related. Therefore we can create a data frame from several
# vectors (of the same length) like this:

indication_df <- tibble(
  accident_year = 2010:2014,
  earned_premium = c(14904664, 14494543, 14442449, 14834605, 18265093),
)
indication_df
# Printing a data frame displays a nice table in the console
# In RStudio, you can also place the cursor on the variable name and press <F2>
# to open a table viewer.

#------ 2.2 Subsetting data frames ------------------------------------------

# You can extract a single vector using $:
indication_df$earned_premium

# To add a new column, you can use $ along with the assignment operator:
indication_df$crl_factor <- c(1.2029, 1.2058, 1.2724, 1.3019, 1.2390)

### Exercise 2.1
# Add a new column to indication_df with the on-level premium.

#------ 2.3 Modifying the columns with mutate() -------------------------

# Do you notice how we repeat "indication_df$" three times?
# We can avoid this by using the dplyr function mutate():

indication_df <- mutate( # mutate() is a function that creates/modifies a column
  # First argument is the data frame to modify
  indication_df,
  # Other argument defines what columns are added or modified (left of the =)
  # and how they are calculated (right of the =)
  onlevel_premium = earned_premium * crl_factor
)
indication_df

### Exercise 2.2
# 1) Using tibble(), create a new indication_df data frame that has
#    the following columns (copy from the spreadsheet when needed):
#    * accident year
#    * earned premium
#    * current rate level factor
#    * ultimate loss and ALAE
#    * net trend factor
# 2) Using mutate(), create these new columns (calculating from the ones above):
#    * on-level premium
#    * on-level ultimate loss and ALAE
#    * projected ultimate loss and ALAE ratio

#------ 2.4 Selecting and renaming columns with select() --------------------

# As you can see mutate() is quite a useful and flexible function. The dplyr
# package also provides select() to subset and reorder and rename columns.

# For example if you only need the projected LR for each year,
# and want to rename accident year to calendar year, you can do:
select(indication_df, calendar_year = accident_year, projected_lr)

### Exercise 2.3
# 1) Only select the year, projected premium, loss and loss ratio
# 2) Rename and reorder the columns as they appear in the spreadsheet
#    Hint: You can use non-syntactic names (eg names that contain spaces)
#    by enclosing them in backticks (``)

#------ 2.5 Summarizing data frames with summarize() ------------------------

# The dplyr package also provides a function summarize() to calculate
# summary statistics on a data frame.
# The following calculates the total earned premium and ultimate losses
summarize(
  indication_df,
  earned_premium = sum(earned_premium),
  ultimate_loss_alae = sum(ultimate_loss_alae)
)

# In the following module, we will see how to group data and calculate
# summary statistics for each group.

### Exercise 2.4
# 1) Calculate the aggregated on-level earned premium, ultimate loss and
# loss ratio:
# 2) Can you also calculate the straight average projected LR?
