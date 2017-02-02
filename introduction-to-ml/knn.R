## ML @ Urban
# Alex Engler

## K-Nearest Neighbors

# Documentation:
# https://stat.ethz.ch/R-manual/R-devel/library/class/html/knn.html

# Load the class package that holds the knn() function
install.packages("class")
library(class)
library(ggplot2)

options(stringsAsFactors = FALSE)
train <- read.csv("knn_data.csv")

dim(train)
str(train)

## Look at the data:
ggplot(train, aes(x=feature1 , y=feature2, color=outcome)) + geom_point(size=5)
       


## Running the algorithm:
## knn(training_data, test_data, training_data_outcome, k)
# k is a 'hyperparameter'

## test1:
test1 <- c(2.5, 2.5)





ggplot(rbind(train, c(test1, NA))
       , aes(x=feature1 , y=feature2, color=outcome)) + geom_point(size=5)

knn(train[,1:2], test1, train[,3], 1)
knn(train[,1:2], test1, train[,3], 2)
knn(train[,1:2], test1, train[,3], 3)



## test2:
test2 <- c(6, 6)

ggplot(rbind(train, c(test2, NA))
       , aes(x=feature1 , y=feature2, color=outcome)) + geom_point(size=5)

knn(train[,1:2], test2, train[,3], 1)
knn(train[,1:2], test2, train[,3], 2)
knn(train[,1:2], test2, train[,3], 3)


## test3: 
test3 <- c(3.5, 3.5)

ggplot(rbind(train, c(test3, NA))
       , aes(x=feature1 , y=feature2, color=outcome)) + geom_point(size=5)

knn(train[,1:2], test3, train[,3], 1)
knn(train[,1:2], test3, train[,3], 3)


