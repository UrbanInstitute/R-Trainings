### Introductory R Tutorial & Notes 
### Alex C. Engler

###################
## R Terminology ##
###################

# This is a comment. Everything after a # (a hashtag) will have no effect if you run it in R. I have comments preceding all  the following commands to explain what they do.

# Working Directory : The folder on your computer that R is currently working in. It will only check this folder for files to load, and will write any new files to this folder.

# Dataframe : the R equivalent of an excel file. It holds relational data in rows and columns that can contain numbers or strings.

# Assignment Operator '<-' : Gives the value on the right to the object on the left.

# Function : Anything that completes a task or set of tasks in R is a function. Most functions have a name, and take one or more arguments within parentheses. Examples include 'head()', 'colnames()', 'hist()', 'mean()', 'and plot()'  

# Argument : An input or an option that affects the result of a function. This often includes the data that the function runs on, AND specifications/options as to what the function should do. For example:

hist(data$column, main = "A Histogram")

# The function (hist is a function for making a histogram) above is given two arguments, separated by a comma. The first is 'data$column', telling the histogram to use the data in this column to make a histogram. The second arguments is 'main = "A Histogram"', which is activating an option, and giving the histogram a main title.

# Remember there are lots of sample data sets in R you can use to practice- you can see those by typing in data() and then looking at the list that appears
# To load a sample data set already in R, type in data(name_of_dataset) to load it, and then you can refer to it by that name.


#######################
## Introduction to R ##
#######################

## You can do basic calculations in R

2+2

4*2

5^3

## And you can save things as objects using the assignment operator: <-

x <- 5

y <- c(1,2,3)

z <- c("cat","dog","fish", "cat")

## if you enter 'x' in R, you will see it is 5
## if you enter 'y' in R, you will see it is a list of 1,2,3
## if you enter 'z' in R, you will see it is a list of four words

x
x * 2

y
length(y) ## returns the number of items in y
y * 3

z
length(z) 
table(z) ## returns a frequency table of z


## This will change your working directory - that is, it will change the default location that R will look for data files.
##
## setwd("/Users/YourUserName/Desktop") 
## setwd("C:/Users/YourUserName/Desktop") 


## This command tells you the current working directory. Use it to make sure that the above command worked properly.

getwd() ## Keep this empty!

setwd("/Users/yourFilePath")


## Use read.csv to read in your data. If you have navigated to the correct working directory (where you data is located) you will only have to put the name of the data file in the quotes.
## data <- read.csv("name_of_your_datafile.csv")

pov <- read.csv("poverty.csv")

## Alternatively, you can use a browser window to navigate to your file, like so:

pov <- read.csv(file.choose(), header = TRUE)


## If you type the name of the data as you saved it, the entire data file will appear. Remember the name of the data file, (in this case I used 'pov') is totally arbitrary, and can be anything you want it to be.

pov
# Alternatively, View(pov) will open a new window where you can see the data.


## Returns the first 6 lines of your data
head(pov)
head(pov, n=10) # now 10 lines



## Returns the names of columns of your data
colnames(pov)



## Returns the number of rows, then columns, of your data. You can generally assume R is indicating rows first, then columns:
dim(pov)

## You can also specify individual rows and columns (again rows first and columns second) using brackets, like so:


pov[1,1]
## returns the cell in the first row and first column

pov[2,1]
## returns the cell in the second row and first column

pov[2,2]
## returns the cell in the second row and second column



## The colon specifies a range.

1:5
## returns 1,2,3,4,5


## So we can specify a range of the data using brackets and a colon

pov[1:3,2]
## returns the first 3 rows of column 2

pov[,2]
## returns the entire second column

## There is also a shorthand syntax for referring to columns by the column names. Below, you can see the 'Country' column being referenced using the dollar sign '$' operator. This shorthand (dataframe$column_name) is very useful, and we will use it often.

pov$Country



## You can see how long the column is:
length(pov$Country)



## Or get all the unique values in that column:
length(unique(pov$Region))


## Or make a frequency table to see all the unique values and how often they appear:
table(pov$Region)


## If the column is a number, you can use functions to get the sum, average, median, standard deviation, five number summary, or range

sum(pov$GNP, na.rm=TRUE) ## sum
mean(pov$BirthRt) ## average
median(pov$BirthRt) ## median
sd(pov$LExpM) ## standard deviation
range(pov$GNP) ## range
range(pov$GNP, na.rm=TRUE)
fivenum(pov$LExpM) ## five number summary 


## Column aggregations by group:
aggregate(pov$GNP, by=list(pov$Region), FUN=mean, na.rm=TRUE)
aggregate(pov$InfMort, by=list(pov$Region), FUN=median, na.rm=TRUE)
aggregate(pov$LExpM, by=list(pov$Region), FUN=sd, na.rm=TRUE)


## For indexing using column names - we use which()
pov[which(pov$GNP > 20000), ]


## Creating a new column:
pov$DeathRt_over10 <- 0 # Set all values to 0
pov$DeathRt_over10[which(pov$DeathRt > 10)] <- 1 # Conditionally change some to 1



## You can look at a histogram of a column
hist(pov$DeathRt)
hist(pov$DeathRt, breaks=10) # Sets number of bins
hist(pov$DeathRt, breaks=30, main = "Histogram of Country Death Rates")


## You can plot two columns together in a scatterplot using
plot(pov$LExpM, pov$LExpF)


## You can create new dataframes using the assignment operator "<-", like the line below. This creates a limited subset of the original data, called 'lim', which only consists of the data where Region is equal to "Europe Mostly"

lim <- subset(pov, Region == "Europe Mostly")

## You could then write this new data to a new file using write.csv. That new file would appear in your current working directory.

write.csv(lim, file = "new_file.csv", row.names=FALSE)





## Model Specification
model1 <- glm(LExpF ~ GNP, data=pov)
summary(model1)

model2 <- glm(BirthRt ~ GNP + InfMort, data=pov)
summary(model2)

model3 <- glm(BirthRt ~ log(GNP) + InfMort, data=pov)
summary(model3)



pov$Log_GNP <- log(pov$GNP)


# Logistic Regression:
model4 <- glm(DeathRt_over10 ~ Log_GNP + InfMort, data=pov, family="binomial")
summary(model4)

## Regression Diagnostics:
coef(model1)
fitted(model1)
residuals(model1) 
plot(model1)



#### R operators:
## You can use the '&' operator to mean 'and'.
## You can use the '|' operator to mean 'or'.
## Here's a list of R's Operators: http://www.statmethods.net/management/operators.html
lim <- subset(pov, (Region == "Europe Mostly" & DeathRt_over10 == 1) |
	(Region == "Asia" & InfMort < 15))



###################################### 
## Some really valuable R packages ##
######################################

## A lot of great packages are covered in the new Free E-Book: R For Data Science
## http://r4ds.had.co.nz/index.html

## To install an R package, run:
install.packages("package_name")
## You only have to do this once.

## To load the functionality of that package into an R session, run:
library("package_name")
## You have to do this in every R session where you want to use this package.

## Reading in SAS/STATA/SPSS Files w/ Haven

install.packages("haven")
library(haven)

sas_data <- read_sas("path/to/file")
stata_data <- read_dta("path/to/file")
spss_data <- read_sav("path/to/file")
## https://cran.r-project.org/web/packages/haven/README.html

## Useful data manipulation with dplyr package
## https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html

## Great data visualization with the ggplot2 package
## http://tutorials.iq.harvard.edu/R/Rgraphics/Rgraphics.html

## Here's a longer list of great packages:
## https://support.rstudio.com/hc/en-us/articles/201057987-Quick-list-of-useful-R-packages

