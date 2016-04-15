########################################################################################################
# Urban Institute R Users Group, 03-02-16
# Retrieving Census data via API
# Hannah Recht & Alex Engler

# IMPORTANT: First, request a Census API key here and save the key: http://api.census.gov/data/key_signup.html
# More information: http://www.census.gov/developers/
########################################################################################################

# Install ggplot2 and dplyr
# We'll use these two packages for working with data and graphing:
# install.packages("ggplot2")
# install.packages("dplyr")
# Load libraries
library(ggplot2)
library(dplyr)


# Paste the key that Census sent you - it should be a string of letters and numbers
censuskey <- "PASTEYOURKEYHERE"

# View an example response of population and median household income by county from the 2000 decennial Census - paste this url into your web browser:
# http://api.census.gov/data/2000/sf3?get=NAME,P001001,P053001&for=county:*

# To get API data directly in R, we'll be using the censusapi package
# Install for the first time
install.packages("devtools")
devtools::install_github("hrecht/censusapi")

# Load the library
library("censusapi")

# See the available APIs - from http://api.census.gov/data.html
apis <- listCensusApis()
View(apis)

# getCensus function takes four arguments:
# apiurl (root URL of the API, e.g. 'http://api.census.gov/data/2000/sf3')
# key (your census API key, saved above)
# vars (a list of variables to get)
# region (geography to use, e.g. 'county:*')

########################################################################################################
# 2000 decennial census API - we'll use Summary File 3
# General information: http://www.census.gov/data/developers/data-sets/decennial-census-data.html
# 2000 decennial datasets: http://api.census.gov/data/2000.html
# "Summary File 3 consists of 813 detailed tables of Census 2000 social, economic and housing characteristics compiled from a sample of approximately 19 million housing units (about 1 in 6 households) that received the Census 2000 long-form questionnaire."
########################################################################################################
# URL of your API
sf3_2000_api <- "http://api.census.gov/data/2000/sf3"
# Let's see what variables are available - from http://api.census.gov/data/2000/sf3/variables.html
vars2000 <- listCensusMetadata(sf3_2000_api, "v")
View(vars2000)

# Variables to get - total population, median household income, median gross rent
myvars <- c("P001001", "P053001", "H063001","REGION")

# Get data at state-level
data2000 <- getCensus(apiurl=sf3_2000_api, key=censuskey, vars=myvars, region="state:*")
# View first 6 rows
head(data2000)

# Let's look at some other geography options
listCensusMetadata(sf3_2000_api, "g")

# Get data at county-level for California
data2000 <- getCensus(apiurl=sf3_2000_api, key=censuskey, vars=myvars, region="county:*&in=state:06")
head(data2000)
# Get data at county-level for all states
data2000 <- getCensus(apiurl=sf3_2000_api, key=censuskey, vars=myvars, region="county:*")
head(data2000)

# Plot median rent vs median household income, population as circle size, colored by region:
qplot(data=data2000, x=P053001, y=H063001, size=P001001, color=REGION)

# Or small multiples:
qplot(data=data2000, x=P053001, y=H063001, size=P001001, color=REGION, facets=REGION~.)

########################################################################################################
# ACS most recent 5-year data - 2010-14
# General information: http://www.census.gov/data/developers/data-sets/acs-survey-5-year-data.html
# List of available variables: http://api.census.gov/data/2014/acs5/variables.html

# Let's get some very specific variables - what % of families with kids under 18 led by single moms are living below the poverty line?
# Variable info: http://api.census.gov/data/2014/acs5/variables/B17010_017E.json, http://api.census.gov/data/2014/acs5/variables/B17010_037M.json
########################################################################################################
# URL of your API
acs_2014_api <- 'http://api.census.gov/data/2014/acs5'
# Variables to get - total population, median household income, families w/ kids led by single moms who are below poverty, families w/ kids led by single moms who are at or above poverty
myvars <- c("B01001_001E", "B19013_001E", "B17010_017E", "B17010_037E")

# Let's look at some other geography options - lots available for the ACS
geos2014 <- listCensusMetadata(acs_2014_api, type="g")
View(geos2014)

# Get data for all PUMAs in California
data2014 <- getCensus(apiurl=acs_2014_api, key=censuskey, vars=myvars, region="public+use+microdata+area:*&in=state:06")
head(data2014)

# Congressional districts
data2014 <- getCensus(apiurl=acs_2014_api, key=censuskey, vars=myvars, region="congressional+district:*")
head(data2014)

# All counties
data2014 <- getCensus(apiurl=acs_2014_api, key=censuskey, vars=myvars, region="county:*")
head(data2014)

# Calculate % of families with kids under 18 led by single moms that are living below the poverty line
data2014$fampov <- data2014$B17010_017E/(data2014$B17010_017E + data2014$B17010_037E)
# Look at the distribution of fampov
summary(data2014$fampov)

########################################################################################################
# Let's graph the distribution of fampov
########################################################################################################

# Make a histogram
ggplot(data=data2014, aes(x=fampov)) + geom_histogram(binwidth=.02, color="black", fill="white")

# Boxplot by state for MD, VA, WV
mvw <- data2014 %>% filter(state %in% c("24", "51", "54"))
ggplot(data=mvw, aes(x=state, y=fampov)) + geom_boxplot()



## Thoughts: Can I get a simple map in here?
## Avoid ggplot2 full syntax and just say the next R thing will be a dataviz one?
## How do people know the geography syntax?
