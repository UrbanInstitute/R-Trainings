## ML @ Urban
# Alex C. Engler


#### Machine Learning with caret
## caret - _C_lassification _A_nd _RE_gression _T_raining
## by Max Kuhn

set.seed(100) # Controls for randomness

# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("GGally")
# install.packages("caret")
# install.packages("pROC")
# install.packages("rpart")
# install.packages("rpart.plot")
# install.packages("randomForest")
# install.packages("stepPlr")

## Load libraries: 
library(dplyr)

library(ggplot2)
library(GGally)

library(caret)
library(pROC)

library(rpart)
library(rpart.plot)
library(randomForest)
library(stepPlr)

###########################################################################################
################################ Resources & Documentation ################################ 
###########################################################################################

## Caret introduction: https://cran.r-project.org/web/packages/caret/vignettes/caret.pdf
## Caret book: http://topepo.github.io/caret/index.html
## Caret model list: http://topepo.github.io/caret/available-models.html

## Recursive Partition Trees (rpart) is one implementation of a decision tree algorithm.
# Short Introduction: http://www.statmethods.net/advstats/cart.html
# Long Introduction: http://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf

## Modeling in the Tidyverse:
# R for Data Science: http://r4ds.had.co.nz/model-intro.html

## Data:
# National Survey on Drug Use and Health (2012)
# Source: http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/34933?q=&paging.rows=25&sortBy=10

###########################################################################################
###########################################################################################

drugs <- read.csv("NSDUH.csv") ## load the data

dim(drugs) ## check data dimensions (rows, columns)
glimpse(drugs) ## examine data
summary(drugs) ## gives five number summary for continuous variables


## Basic data prepatation ##
drugs <- filter(drugs, AGE %in% c(1,2,3,4,5,6,7,8,9,10)) ## subset out older age categories
drugs$AGE <- drugs$AGE + 11 ## change age

## caret assumes first level is the outcome of interest: 
drugs$MJEVER <- factor(drugs$MJEVER, levels = c("Yes","No"))
drugs$CIGEVER <- factor(drugs$CIGEVER, levels = c("Yes","No"))
drugs$SNFEVER <- factor(drugs$SNFEVER, levels = c("Yes","No"))
drugs$CIGAREVR <- factor(drugs$CIGAREVR, levels = c("Yes","No"))
drugs$ALCEVER <- factor(drugs$ALCEVER, levels = c("Yes","No"))
drugs$GENDER <- factor(drugs$GENDER, levels = c("Male","Female"))

drugs$ALDAYPYR[which(drugs$ALDAYPYR > 365)] <- 0

## Examine missing data:
lapply(drugs, function(x) mean (!is.na(x)))

## End data prepatation ##


## Table of outcome we might want to predict:
table(drugs$MJEVER, useNA="always")
prop.table(table(drugs$MJEVER, useNA="always"))

## Exploratory Visualizations:
ggpairs(drugs[,c(1,4,5,10)], color="MJEVER")

ggplot(drugs, aes(x=AGE, fill=MJEVER)) + geom_density(alpha=0.3)
ggplot(drugs, aes(x=AGE, y=log(ALDAYPYR), color=MJEVER)) + 
  geom_jitter() + 
  geom_smooth()
## more: https://topepo.github.io/caret/visualizations.html



## Create training and testing datasets:
trainIndex <- createDataPartition(drugs$MJEVER, p = .8, list = FALSE)

train_data <- drugs[trainIndex,]
test_data <- drugs[-trainIndex,]

dim(train_data)
dim(test_data)

## Note the consistent proportions of Yes to No in both datasets. This is called creating 'balanced'  datasets, and createDataPartition does that automatically:
prop.table(table(drugs$MJEVER))
prop.table(table(train_data$MJEVER))
prop.table(table(test_data$MJEVER))

# To see other data splitting functions:
# ?createDataPartition
# or: https://topepo.github.io/caret/data-splitting.html


## We will be using R's formula syntax:
## outcome ~ feature1 + feature2 ...

## Use rpart to create simple decision tree:
rpart_model <- rpart(MJEVER ~ GENDER + AGE + ALCEVER + CIGEVER, method="class", data=train_data)

rpart_model
class(rpart_model)
summary(rpart_model)
prp(rpart_model, type=2)
rpart_preds <- predict(rpart_model, newdata = select(test_data, MJEVER, GENDER, AGE, ALCEVER,CIGEVER))


## Now with caret:
tree_model <- train(MJEVER ~ GENDER + AGE + ALCEVER + CIGEVER
                    , data=train_data
                    , method="rpart")

tree_model
class(tree_model)
attributes(tree_model)
summary(tree_model)

## Some external functionality won't work anymore:
prp(tree_model, type=2) 


## Huge advantage of caret is model interchangeability:
plr_model <- train(MJEVER ~ GENDER + AGE + ALCEVER + CIGEVER
                  , data=train_data
                  , method="plr")

rf_model <- train(MJEVER ~ GENDER + AGE + ALCEVER + CIGEVER
                    , data=train_data
                    , method="rf"
                    , trees=10)


?train
# train(form, data, ..., weights, subset, na.action, contrasts = NULL)
# The elipsis "..." is really critical here.


class(tree_model)
class(plr_model)
class(rf_model)

attributes(tree_model)
attributes(plr_model)
attributes(rf_model)

## Attributes: 
plr_model$modelType
plr_model$call
plr_model$method
plr_model$trainingData


## Predict outcome on the test set:
tree_predictions <- predict(tree_model, newdata = test_data)
tree_probability <- predict(tree_model, newdata = test_data, type = "prob")

## Switch in penalized logistic regression:
tree_predictions <- predict(plr_model, newdata = test_data)
tree_probability <- predict(plr_model, newdata = test_data, type = "prob")



## Compare predictions versus actual:
confusionMatrix(data = tree_predictions, test_data$MJEVER[!is.na(test_data$MJEVER)])

## Optional - calculate area under curve (AUC):
library(pROC)
auc(tree_model) ## Area under ROC Curve



table(tree_predictions, test_data$MJEVER)

## trainControl is also a very useful method:
ctrl <- trainControl(method='repeatedcv', repeats=5, classProbs=TRUE)

tree_model2 <- train(MJEVER ~ GENDER + AGE + ALCEVER + CIGEVER
                    , data=train_data
                    , method="rf"
                    , trContrl = ctrl)


