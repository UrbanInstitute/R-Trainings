## Introduction to R Programming 
## Alex C Engler


## R implements interactive programming.
2 + 2
4 * 5

a <- 3 

## <- is the assignment operator
## <- is usually equivalent to a single equal sign '='
## but you still see <- used much more often

a * 2

b^2


x <- c(1,2,3)
x
x * 2

y <- c("cat","dog","fish", "cat")
y

length(y)
table(y)


getwd() ## see current working directory
setwd('D:/Users/AEngler/Desktop') ## change working directory
dir() ## see files in current working directory

pov <- read.csv('poverty.csv') ## reading in data

# If you have missing data specified by a character, you can account for that.
# For example, if the data being read in has periods for missing values:
# pov <- read.csv('poverty.csv', na.strings=".") 

### R can read a huge variety of file types. 

## For SAS Files:
# install.packages("sas7bdat")
# library(sas7bdat)
# whatever <- read.dta('filename.sas7bdat')

## For STATA Files:
# install.packages("foreign")
# library(foreign)
# whatever <- read.dta('filename.dta')


ls() ## 'list' current R objects

class(pov) ## see the object type
dim(pov) ## get the dimensions of the dataframe in rows by columns
colnames(pov) ## get the column names of the dataframe
head(pov) ## see the first six rows of the dataframe
summary(pov) ## 5 Number Summary for Continuous Variables / Frequency Table for Categorical Variables

## Dataframe Indexing [row#, column#]
pov[1,1] ## cell in row 1 and column 1
pov[2,1] ## cell in row 2 and column 1

pov[,1] ## first column
pov[1,] ## first row
pov[1:4,] ## The first four rows


## Columns can also be referenced with the $
pov$Country ## equivalent to pov[,1]



mean(pov$BirthRt) ## average
sd(pov$LExpM) ## standard deviation
range(pov$GNP) ## range
range(pov$GNP, na.rm=TRUE) ## note that = and not <- is used to specify arguments

table(pov$Region) ## frequency table
table(pov$Region, useNA="always")

hist(pov$DeathRt)
hist(pov$DeathRt, breaks=15)

plot(pov$LExpM, pov$LExpF)

?plot ## use the '?' operator see documentation for this function

plot(pov$LExpM, pov$LExpF, col="red")
plot(pov[,1:6]) ## scatterplot matrix

pov$DeathRt_over10 <- 0
pov$DeathRt_over10[which(pov$DeathRt > 10)] <- 1





install.packages("dplyr") ## You only have to install the package once
library(dplyr) ## You must load the package everytime you want to use tis functionality.

glimpse(pov)



filter(pov, Region == "Africa") ## Row Subsetting
arrange(pov, LExpM) ## Row Ordering
select(pov, Region, Country, LExpM, GNP) ## Column Selection

pov <- arrange(pov, LExpM) ## Row Ordering


new_data <- pov %>% 
	filter(Region == "Africa" | Region == "Eastern Europe") %>%
	select(Region, Country, LExpM, GNP) %>%
	arrange(LExpM)

## A more thorough introduction to dplyr: 
## http://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html




gnp_pc <- read.csv("gnp_pc.csv")

pov$Country %in% gnp_pc$Country
table(pov$Country %in% gnp_pc$Country)

pov2 <- merge(pov, gnp_pc, by = "Country")
dim(pov2)



## Variable Creation
pov2$gnp_pc_log <- log(pov2$gnp_pc) 
pov2$gnp_pc_sqrt <- sqrt(pov2$gnp_pc)
pov2$gnp_pc_squared <- (pov2$gnp_pc)^2



## Linear Regression
reg1 <- lm(LExpM ~ gnp_pc_log, data = pov2)

summary(reg1)
plot(reg1)
attributes(reg1)

reg2 <- lm(LExpM ~ gnp_pc_log + Region, data = pov2)

reg3 <- glm(DeathRt_over10 ~ gnp_pc_log, data = pov2, family="binomial") ## glm for generalized linear model. Expands lm to link functions for binomial (e.g. logistic), poisson (e.g. negavtive binomial), gamma distributions.

coef(reg3)
exp(coef(reg3))


## Various regression diagnostics:
lin_fit <- fitted(model) ## calculate fitted values
lin_resid <- residuals(model)  ## calculate residuals values
standard_lin_resid <- rstandard(model) ## calculate standardized residuals
outlierTest(model) # Bonferonni p-value for most extreme obs
vif(model) ## variance influence factors (examine multi-collinearity)
bptest(model) ## bruesch-pagan test for heteroskedascity
cooks <- cooks.distance(lin_model) # cook's distance
lin_model$coeff ## list coefficients 
leveragePlots(model) # leverage plots
leverage <- hatvalues(lin_model) # get the leverage values 