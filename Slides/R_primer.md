---
title: "Actuarial Data Manipulation with R"
subtitle: "CAS Spring Meeting 2024 -- Workshop"
author: Denis Dreano
theme: metropolis
date: 5/5/2024
format: beamer
---
Resources:

* Rstudio cheatsheet
* R cheatseet
* Introduction to R, Hadley Wickham
* ...


# R Cheatsheet

## Syntax

### Comments

```
# Everything right of a '#' is a comment
```


### Assignment



```
x <- 1
```

### Functions
```
my_new_function <- function(arg1, arg2) {
  x <- arg1 * 2
  y <- arg2 + 1
  x + y #
}
```

```
my_new_function(1, 2)
```

### Control Flow

```
if (premium < 1e6) {
  account_type <- 'small'
} else {
  account_type <- 'large'
}
```

Certainly! Here's a basic cheatsheet for the R language syntax:

### Basic Syntax:
- R is case sensitive.
- Statements are typically terminated by a semicolon (`;`), but it's often optional.
- Comments are preceded by the hash symbol (`#`).

### Variables:
```R
# Assigning values to variables
variable_name <- value
```

### Data Types:
- Numeric: integers, doubles
- Character: strings
- Logical: TRUE/FALSE
- Vector: One-dimensional array-like structure
- Matrix: Two-dimensional array
- Data Frame: Tabular data structure

### Basic Operations:
```R
# Arithmetic operators
+, -, *, /, ^ (exponentiation)

# Assignment operators
<- (preferred), = (less preferred)

# Comparison operators
<, >, <=, >=, ==, !=

# Logical operators
&, |, ! (AND, OR, NOT)
```

### Control Structures:
#### 1. Conditional Statements:
```R
if (condition) {
  # code block
} else if (condition) {
  # code block
} else {
  # code block
}
```

#### 2. Loops:
- `for` loop:
```R
for (variable in sequence) {
  # code block
}
```
- `while` loop:
```R
while (condition) {
  # code block
}
```

#### 3. Functions:
```R
function_name <- function(arguments) {
  # code block
  return(output) # optional
}
```

### Data Manipulation:
#### 1. Vector Operations:
```R
# Indexing
vector_name[index]

# Vectorized operations
c(1, 2, 3) + c(4, 5, 6)

# Functions
length(), sum(), mean(), min(), max()
```

#### 2. DataFrame Operations:
```R
# Accessing columns
dataframe$column_name

# Selecting rows
dataframe[condition, ]

# Functions
dim(), nrow(), ncol(), summary(), str()
```

### Packages:
```R
# Install package
install.packages("package_name")

# Load package
library(package_name)
```

### Data Import/Export:
```R
# Import data
read.csv("file.csv")
read.table("file.txt")

# Export data
write.csv(dataframe, "file.csv")
```

This is a basic overview of R syntax. For more advanced topics and detailed explanations, refer to R documentation or specific tutorials.
