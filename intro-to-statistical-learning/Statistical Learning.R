#### Introduction to R for Statistical Learning 
#### Urban Institute Training
### Alex C. Engler
### 4/27/2017

##############################################################

### More Resources:

## 1. R CRAN Task Views: https://cran.r-project.org/web/views/
# CRAN is the Comprehensive R Archive Network, tasked with storing R and all of its packages.
# 
# CRAN Task Views are guides to doing certain tasks in R that are maintained by experts in that area. Most critically, this includes an overview of the many packages that 

## 2. Introduction to Statistical Learning: http://www-bcf.usc.edu/~gareth/ISL/ISLR%20First%20Printing.pdf
# 
# Wonderful textbook for 'statistical learning' - which includes not only statistics, but also many of the foundational skills in machine learning and data science. Nine out of ten of these chapters also have an R tutorial at the end. 

## R for Data Science - Chapters 23/24/25: http://r4ds.had.co.nz/model-basics.html#visualising-models
# This new free ebook goes into depth explaining R models and shows a wide variety of tricks to analyze and visualize those models. 

##############################################################

## You should remove the '#' and install the packages below, if you do not have them already:
# install.packages("dplyr")
# install.packages("ggplot2")

library(dplyr) 
library(ggplot2)

## Read in our sample dataset:
diamonds <- read.csv("diamonds.csv", header=TRUE)

glimpse(diamonds)

## dplyr & ggplot refresher:
diamonds %>%
	group_by(store) %>%
	summarize(avg_price = mean(price),
		med_carat = median(carat),
		count = n()) %>%
	filter(count > 10) %>%
	arrange(-avg_price) %>%
	ggplot(aes(x=med_carat, y=avg_price, color=store, size=count)) + 
		geom_point() + 
		ggtitle("Diamond Stores by Carat & Cost") +
		theme_bw()

## By default, R considers strings to be factors (R's categorical variables) upon loading. We can change the data type back to a string easily.
class(diamonds$store)
diamonds$store <- as.character(diamonds$store)

## Note you can also run:
# options(stringsAsFactors=FALSE)
## at the start of an R session, which will undo this default.

## Handy Descriptive Statistics:
mean(diamonds$price)
median(diamonds$price)
sd(diamonds$price)
fivenum(diamonds$price)

## Quantiles:
quantile(diamonds$price, 0.33)
quantile(diamonds$price, c(0.33,0.66))
quantile(diamonds$price, c(0.2,0.4,0.6,0.8))

## Correlation & Covariance
cor(diamonds$carat, diamonds$price) ## correlation
cov(diamonds$carat, diamonds$price) ## covariance

## Scatterplot:
ggplot(diamonds, aes(x=carat, y=price)) + 
  geom_point() +
  theme_bw()

## apply family of functions (more here: http://faculty.nps.edu/sebuttre/home/R/apply.html). Sapply applies  
sapply(diamonds[,c(1,2,3,7)], mean)
sapply(diamonds[,c(1,2,3,7)], sd)
sapply(diamonds[,c(1,2,3,7)], quantile, c(0.2, 0.4, 0.6, 0.8))


## Simple linear regression use lm()
## lm(formula, dataframe)
linear_model <- lm(price ~ carat, data = diamonds)

## Quick Overview:
linear_model
summary(linear_model)

## Accessing specific model information:
class(linear_model)
attributes(linear_model)

# You can refer to individual attributes with the '$' operator:
linear_model$call
linear_model$coefficients
linear_model$fitted.values


## Plot the fitted model:
coefs <- linear_model$coefficients

ggplot(data=diamonds) + 
  geom_point(aes(x=carat, y=price), alpha=0.6) +
  geom_abline(aes(intercept=coefs[1], slope=coefs[2])) + 
  theme_bw()

## Combine fitted values and our original dataset:
diamonds_more <- bind_cols(diamonds, as.data.frame(linear_model$fitted.values))
glimpse(diamonds_more)
colnames(diamonds_more)[8] <- "fitted_values"

## Plotting residuals with ggplot2:
ggplot(data=diamonds_more) + 
  geom_point(aes(x=carat, y=price), alpha=0.6) +
  geom_abline(aes(intercept=coefs[1], slope=coefs[2])) + 
  geom_segment(aes(x=carat, xend=carat, y=price, yend=fitted_values), color="#1696d3") +
  theme_bw()



## Multivariate Linear Regression with R Formula Syntax:
### Notes of R forumla syntax: http://faculty.chicagobooth.edu/richard.hahn/teaching/formulanotation.pdf

## . signifies all vars in dataframe:
linear_model <- lm(price ~ ., data = diamonds) 
summary(linear_model)

## - signifies removing this variable:
linear_model <- lm(price ~ . -store, data = diamonds)
summary(linear_model)

## Or you can use + to specify the list of variables you want to include:
linear_model <- lm(price ~ carat + color + clarity + cut + channel, data = diamonds)
summary(linear_model)

## Note how the modeling treats factors, the first level is left out:
linear_model$coefficients
levels(diamonds$cut)
levels(diamonds$channel)

## You can reoder factor if you prefer a different value left out:
diamonds$cut <- factor(diamonds$cut, levels=c("Not Ideal","Ideal"))


## : signifies an interaction between two variables:
linear_model <- lm(price ~ carat + clarity:cut, data = diamonds) 
summary(linear_model)

## * signifies an interaction between two variables AND those variables independently:
linear_model <- lm(price ~ carat + clarity*cut, data = diamonds) 
summary(linear_model)

## You can manipulate variables in the forumla, too:
linear_model <- lm(price ~ carat + sqrt(carat), data = diamonds) 
summary(linear_model)


## There is a 'weights' argument for most models that can use them:
linear_model <- lm(price ~ color + clarity + cut + channel, weight=carat, data = diamonds) 
summary(linear_model)


## Missing data - R will silently drop rows with missing data (if that column is in regression):
diamonds_tmp <- diamonds
diamonds_tmp$carat[5] <- NA
model <- lm(price ~ carat, data = diamonds_tmp) 

nrow(diamonds)
nobs(model)


if(nrow(data) != nobs(model)){print("Problem!")}

## the tidy() function in the broom package is useful for storing model results:
# install.packages("broom")
library(broom)
tidy_model <- tidy(linear_model)
class(tidy_model)

tidy(linear_model)

# QQ Plots
qqnorm(linear_model2$residuals)
qqline(linear_model2$residuals)
hist(linear_model2$residuals, breaks=30) 
## Basics on interpreting a qqplot: https://stats.stackexchange.com/questions/101274/how-to-interpret-a-qq-plot

## Analysis of Variance with anova()
# Performs chi-square test to check significance in RSS 
linear_model1 <- lm(price ~ carat + sqrt(carat), data = diamonds) 
linear_model2 <- lm(price ~ carat + log(carat) + cut, data = diamonds) 

anova(linear_model, linear_model2)


## Generalized Linear Models use glm()
# GLM Overview: http://www.statmethods.net/advstats/glm.html
str(diamonds$cut)
table(diamonds$cut)

logistic_model <- glm(cut ~ price + carat + clarity + channel, data = diamonds, family = binomial)
summary(logistic_model)
?family

## Exponentiate coefficients to get odds ratio:
logistic_model$coefficients
exp(logistic_model$coefficients)
## Interpreting odds-ratio: http://www.appstate.edu/~whiteheadjc/service/logit/intro.htm#interp




## Leverage and Outliers 
?influence.measures
hatvalues(linear_model) ## check for leverage

cook_list <- cooks.distance(linear_model2) ## check for high influence 
outliers <- cook_list[cook_list > 0.05] 

## To look at the rows of data with high cooks distance:
names(outliers)
diamonds[names(outliers),]


## CAR - Companion to Applied Regression
## install.packages("car")
library(car)
outlierTest(linear_model) ## outlier tests using Bonferonni p-value
vif(linear_model) ## Variance Influence Factors

## MASS - Modern Applied Statistics
library(MASS) 
## Robust Linear Regression w/ IRLS
r_lm <- rlm(price ~ carat + color + clarity + cut + channel, data = diamonds) 
attributes(r_lm)


## Penalized methods with glmnet
library(glmnet)
ridge <- glmnet(x=as.matrix(diamonds[,1:3]), y=diamonds$price)
attributes(ridge)

## Caret Package - For Applied Machine Learning 
# install.packages("caret")
library(caret)

rf_model <- train(price ~., data = diamonds, method="rf")
nnet_model <- train(price ~., data = diamonds, method="nnet")
## Model training with caret: http://topepo.github.io/caret/training.html
