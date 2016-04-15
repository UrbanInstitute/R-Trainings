## Introduction to Data Visualization in R
# Urban Institute R Users Group
# 4/13/2015

########################
## ggplot2: gg stands for 'Grammar of Graphics' 
## This very popular package that attemps to create a consistent and meaningful syntax (or grammar) that translates data into visualizations.

#### More Resources:
## Extensive Tutorial from Harvard: http://tutorials.iq.harvard.edu/R/Rgraphics/Rgraphics.html
## ggplot2 cheatsheet: https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf
## ggplot2 Documentation: http://docs.ggplot2.org/current/
## Concepts of ggplot2: http://opr.princeton.edu/workshops/201401/ggplot2Jan2014DawnKoffman.pdf
## More on 'Grammar of Graphics': http://byrneslab.net/classes/biol607/readings/wickham_layered-grammar.pdf
########################


########################
### Setup

## Make sure R is updated to the most recent version.
## And that these packages are installed:
install.packages("ggplot2")
install.packages("grid")
install.packages("RColorBrewer")

### Load the Urban Institute ggplot2 theme (in development) created by Ben Chartoff.
## This theme will automatically alter graphics to closely, though not exactly, match the Urban Institute Data Visualization Style Guide

## For Windows Users Run:
source('https://raw.githubusercontent.com/UrbanInstitute/urban_R_theme/temp-windows/urban_ggplot_theme.R')

## For Mac Users Run:
source('https://raw.githubusercontent.com/UrbanInstitute/urban_R_theme/temp-mac/urban_ggplot_theme.R')

## Urban Institute R Theme: https://github.com/UrbanInstitute/urban_R_theme
## Urban Institute Data Visualization Style Guide: http://urbaninstitute.github.io/graphics-styleguide/
########################


########################
#### Introduction to ggplot2

# Set working directory:
setwd("D:/Users/urbantemp/Desktop")
enr <- read.csv("enr.csv")

## DC Public Students Enrollment Data

dim(enr) # See numbers of rows and columns
head(enr, n=10) # Look at first ten rows
unique(enr$grade) # See all grades
table(enr$ell_indicator) # Frequency Table
fivenum(enr$read_scale_score) # See five number summary (min, 25th, median, 75th, max)


## Histograms

# ggplot is meant to work with dataframes, and will most often start like this:
ggplot(data=enr)

# Create an aesthetic mapping with aes, but don't graph anything: 
ggplot(data=enr, aes(x=read_scale_score))

# Now add a geometry, aka a visual encoding of the data, in this case: 'geom_histogram'
ggplot(data=enr, aes(x=read_scale_score)) + 
  geom_histogram()

# You could also write this like this:
ggplot(data=enr) + 
  geom_histogram(aes(x=read_scale_score))

# What is important is that the mapping of data to geometries happens within aes()
# You can changes options that are not data-driven within geom_histogram()
ggplot(data=enr, aes(x=read_scale_score)) + 
  geom_histogram(binwidth=0.2, fill="blue")


# ggplot works in layers:
ggplot(data=enr, aes(x=read_scale_score)) + 
  geom_histogram(binwidth=0.2) +
  geom_vline(aes(xintercept=median(read_scale_score)))


## Remember that data-driven changes happen within aes()
# And non data driven changes (see linetipe and size below) do not:
ggplot(data=enr, aes(x=read_scale_score)) + 
  geom_histogram(binwidth=0.2) +
  geom_vline(aes(xintercept=median(enr$read_scale_score))
             , linetype="dashed", size=1)


## Sample dataset:
num_rows <- nrow(enr)
enr_lim <- enr[sample(num_rows, num_rows/25),]

# Scatterplot:
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score)) + 
  geom_point()

# Note how quickly you can switch between similar geometries:
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score)) + 
  geom_density_2d()
# install.packages("hexbin")
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score)) + 
  geom_hex()


## Back to the Scatterplot - change transparency with 'alpha':
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score)) + 
  geom_point(alpha = 0.3)


## Back to the Scatterplot - change transparencywith 'alpha':
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score)) + 
  geom_point(alpha = 0.3) + 
  ggtitle("DC Student Test Scores")

## Use color to show different groups, based on the data:
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score)) + 
  geom_point(aes(color= factor(atrisk)), alpha = 0.3) +
  ggtitle("DC Student Test Scores")


## Add another geom layet of a local average:
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score)) + 
  geom_point(aes(color= factor(atrisk)), alpha = 0.3) +
  geom_smooth() +
  ggtitle("DC Student Test Scores")

  
## Note the inheretence of aesthetics. Above, geom_smooth inherents the x and y aesthetics, but not color. Below, geom_smooth gets all three:
ggplot(data=enr_lim, aes(x=read_scale_score, y=math_scale_score, color= factor(atrisk))) + 
    geom_point(alpha = 0.3) +
    geom_smooth() + 
    ggtitle("DC Student Test Scores")
  
  
## Creating an ordered categorical variable with factor()
enr$grade <- factor(enr$grade, levels = c("PK3","PK4","KG","2","3","4","5","6","7","8","9","10","11","12","AO","UN"))

# Bar charts:
ggplot(data=enr, aes(factor(grade))) + geom_bar()

# Stacked bar chart - use 'fill' for color:
ggplot(data=enr, aes(factor(grade), fill=ell_indicator)) + geom_bar()



## Additional examples (mostly from Ben Chartoff) with R's included datasets:
data(Orange)


head(Orange)

ggplot(data=Orange, aes(x=age, y= circumference))
ggplot(data=Orange, aes(x=age, y= circumference)) + geom_line()

ggplot(data=Orange, aes(x=age, y= circumference)) 
  + geom_line(aes(color=Tree))

ggplot(data=Orange, aes(x=age, y= circumference)) + geom_line(aes(color=Tree)) + facet_grid(. ~ Tree)









####Bar
##1 color
print(ggplot(mtcars, aes(factor(cyl))) + geom_bar() + coord_cartesian(ylim = c(0, 100))+ggtitle("Title"))

##3 colors
print(qplot(factor(cyl), data=mtcars, geom="bar", fill=factor(cyl))+ggtitle("Title"))

##5 colors
print(ggplot(diamonds, aes(clarity, fill=cut)) + geom_bar() +ggtitle("Title") + coord_cartesian(ylim = c(0, 15000)))


####Scatter
##3 colors
print(ggplot(mtcars, aes(wt, mpg))+geom_point(aes(colour = factor(cyl))) + ggtitle("Title"))

##9 colors
dsamp <- diamonds[sample(nrow(diamonds), 1000), ]
d <- qplot(carat, price, data=dsamp, colour=clarity, size = 3)
# print(d+ggtitle("Title"))

###Line
##3 colors
mtcars.long <- melt(mtcars, id = "mpg", measure = c("disp", "hp", "wt"))
print(ggplot(mtcars.long, aes(mpg, value, colour = variable)) + geom_line()+ggtitle("Title"))

###Facet Grid
p <- ggplot(mtcars, aes(mpg, wt)) + geom_point() + ggtitle("Title")
print(p + facet_grid(vs ~ am, margins=TRUE))

