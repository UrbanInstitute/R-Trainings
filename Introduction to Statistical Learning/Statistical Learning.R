#### Introdcution to R for Statistical Learning 
#### Urban Institute Training
### Alex C. Engler
### 8/19/2015

##############################################################

### More Resources:

## 1. R CRAN Task Views: https://cran.r-project.org/web/views/
# CRAN is the Comprehensive R Archive Network, tasked with storing R and all of its packages.
# 
# CRAN Task Views are guides to doing certain tasks in R that are maintained by experts in that area. Most critically, this includes an overview of the many packages that 

## 2. Introduction to Statistical Learning: http://www-bcf.usc.edu/~gareth/ISL/ISLR%20First%20Printing.pdf
# 
# Wonderful textbook for 'statistical learning' - which includes not only statistics, but also many of the foundational skills in machine learning and data science. Nine out of ten of these chapters also have an R tutorial at the end. 

##############################################################

## You should remove the '#' and install the packages below, if you do not have them already:
# install.packages("dplyr")
# install.packages("tidyr")

library(dplyr) 
## dplyr 
# Convenient easy functions for subseting, reordering, adding columns, simple aggregations, simple random sampling
# Introduction here: https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html


library(tidyr)
## tidyr
# Wide >> Long with gather()
# Long >> Wide with spread()
# Introduction here: http://blog.rstudio.org/2014/07/22/introducing-tidyr/

## General guide to tidyr and dplyr: https://rpubs.com/bradleyboehmke/data_wrangling

diamonds <- read.csv(file.choose(), header=TRUE)


head(diamonds) # See first six rows.
str(diamonds) # See data structure


## dplyr example:

# Simple functions for data manipulation:
new_data <- filter(diamonds, cut == "Ideal")
new_data <- group_by(new_data, channel)
new_data <- summarize(new_data, avg_price = mean(price))
new_data <- arrange(new_data, -avg_price)

# Can chain those operations together with the %>% operator:
new_data2 <- diamonds %>%
	filter(cut == "Ideal") %>%
	group_by(channel) %>%
	summarize(avg_price = mean(price)) %>%
	arrange(-avg_price)

new_data == new_data2
table(new_data == new_data2)


## dplyr's chain operators work into ggplot2 as well:

library(ggplot2)
diamonds %>%
	filter(cut == "Ideal") %>%
	group_by(channel) %>%
	summarize(avg_price = mean(price)) %>%
	arrange(-avg_price) %>%
	ggplot(aes(x=channel, y=avg_price)) + geom_bar(stat="identity")

rm(new_data, new_data2) ## delete these dataframes



## By default, R considers strings to be factors (R's categorical variables) upon loading. We can change the data type back to a string easily.
diamonds$store <- as.character(diamonds$store)

## Handy Descriptive Statistics:
mean(diamonds$price)
median(diamonds$price)
sd(diamonds$price)
fivenum(diamonds$price)

quantile(diamonds$price, 0.33)
quantile(diamonds$price, c(0.33,0.66))

cor(diamonds$carat, diamonds$price) ## correlation
cov(diamonds$carat, diamonds$price) ## covariance

## apply family of functions (more here: http://faculty.nps.edu/sebuttre/home/R/apply.html)
sapply(diamonds, mean)
sapply(diamonds, sd)




## Simple linear regression use lm()

linear_model <- lm(price ~ carat, data = diamonds)

linear_model
summary(linear_model) ## Quick Overview

attributes(linear_model)

# You can refer to individual attributes with the '$'
linear_model$call
linear_model$fitted.values


## Multivariate Linear Regression
linear_model2 <- lm(price ~ ., data = diamonds) ## Regress against all vars in dataframe

linear_model2 <- lm(price ~ . -store, data = diamonds) ## Regress against all vars in dataframe, except for 'store'

linear_model2 <- lm(price ~ carat + color + clarity + cut + channel, data = diamonds) ## Or specify variables to be included

summary(linear_model2)
plot(linear_model2)


## More regression diagnostics:
plot(linear_model2$fitted.values, linear_model2$residuals)

# QQ Plots
qqnorm(linear_model2$residuals)
qqline(linear_model2$residuals)
hist(linear_model2$residuals) 

## Leverage and Outliers 
?influence.measures
hatvalues(linear_model2) ## check for leverage
cook_list <- cooks.distance(linear_model2) ## check for high influence 
cook_list[cook_list > 0.05]


# Interaction Effects with *
linear_model3 <- lm(price ~ carat*color + clarity + cut + channel, data = diamonds) 
summary(linear_model3)

# Interaction Effects with * and -
linear_model4 <- lm(price ~ carat*color - color + clarity + cut + channel, data = diamonds) 
summary(linear_model4)


## Analysis of Variance with anova()
anova(linear_model2, linear_model3)
anova(linear_model, linear_model2, linear_model3)




## Generalized Linear Models use glm()
# GLM Overview: http://www.statmethods.net/advstats/glm.html

logistic_model <- glm(cut ~ price + carat + clarity + channel, data = diamonds, family = binomial)
logistic_model$coefficients
exp(logistic_model$coefficients)

poisson_model <- glm(clarity ~ color + cut + channel, data = diamonds, family = "poisson")


## CAR - Companion to Applied Regression
## install.packages("car")
library(car)
?car ## Look at documentation (only works after you load library)

outlierTest(linear_model2) ## outlier tests using Bonferonni p-value
vif(linear_model2) ## Variance Influence Factors


## MASS - Modern Applied Statistics

library(MASS) 
r_lm <- rlm(price ~ carat + color + clarity + cut + channel, data = diamonds) ## robust linear regression
attributes(r_lm)



## Caret Package - For Applied Machine Learning 
# install.packages("caret")
library(caret)

rf_model <- train(price ~., data = diamonds, method="rf")
nnet_model <- train(price ~., data = diamonds, method="nnet")

## Model training with caret: http://topepo.github.io/caret/training.html
