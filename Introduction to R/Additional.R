## Merge:

gnp <- read.csv("gnp_pc.csv")


new_file <- merge(pov, gnp, by="Country")
dim(new_file)


## Dplyr:
install.packages("dplyr")
library(dplyr)


## Friday, September 9th - 2-3 PM 
## Descriptive Statistics, Basic Charts, and Regression Methods in R:

pov %>% 
	group_by(Region) %>% 
	summarise(average_GNP = mean(GNP, na.rm=TRUE)) %>%
	arrange(desc(average_GNP)) %>% 
	ggplot(aes(x=Region, y=average_GNP)) + 
		geom_bar(stat="identity")


ggplot(diamonds, aes(clarity, fill=cut)) + geom_bar() + scale_fill_brewer()


library(GGally)
ggpairs(iris, aes(color=Species))



## R can have many datasets in memory
## Missing data is specific by NA
## ORdering is not necessary before most operations