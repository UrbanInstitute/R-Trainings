########################################################################################################
# Urban Institute R Users Group, 03-02-16
# Retrieving Census data via API
# Hannah Recht & Alex Engler

# IMPORTANT: First, request a Census API key here and save the key: http://api.census.gov/data/key_signup.html
# List of Census datasets available via API: http://api.census.gov/data.html
########################################################################################################

# Paste the key that Census sent you - it should be a string of letters and numbers
censuskey <- "PASTEYOURKEYHERE"

# View an example response of population and median household income by county from the 2000 decennial Census - paste this url into your web browser:
# http://api.census.gov/data/2000/sf3?get=NAME,P001001,P053001&for=county:*

# To get API data directly in R, we'll be using a function called getCensusApi, written by Nicholas Nagle - with some additions
# For more information on the original function and examples, see https://rpubs.com/nnnagle/19337

# We'll need XML installed to be able to read in Census API information tables
# install.packages("XML")

# 'Source' tells R to run the script, in this case loading the Census API functions
source("https://raw.githubusercontent.com/UrbanInstitute/R-Trainings/master/accesing-census-apis/getCensusApi.R")
# getCensusApi function takes four arguments:
# data-url (root URL of the API, e.g. 'http://api.census.gov/data/2000/sf3')
# key (your census API key, saved above)
# vars (a list of variables to get)
# region (geography to use, e.g. 'county:*')

# See the available APIs - from http://api.census.gov/data.html
apis <- listCensusApis()
head(apis)

########################################################################################################
# 2000 decennial census API - we'll use Summary File 3
# General information: http://www.census.gov/data/developers/data-sets/decennial-census-data.html
# 2000 decennial datasets: http://api.census.gov/data/2000.html
# "Summary File 3 consists of 813 detailed tables of Census 2000 social, economic and housing characteristics compiled from a sample of approximately 19 million housing units (about 1 in 6 households) that received the Census 2000 long-form questionnaire."
########################################################################################################
# URL of your API
sf3_2000_api <- "http://api.census.gov/data/2000/sf3"
# Let's see what variables are available - from http://api.census.gov/data/2000/sf3/variables.html
vars2000 <- listCensusVars(sf3_2000_api)

# Variables to get - total population, median household income, median gross rent
myvars <- c("P001001", "P053001", "H063001")

# Get data at state-level
data2000 <- getCensusApi(data_url=sf3_2000_api, key=censuskey, vars=myvars, region="state:*")
# View first 6 rows
head(data2000)

# Let's look at some other geography options
geos2000 <- listCensusGeos(sf3_2000_api)

# Get data at county-level for California
data2000 <- getCensusApi(data_url=sf3_2000_api, key=censuskey, vars=myvars, region="county:*&in=state:06")
head(data2000)
# Get data at county-level for all states
data2000 <- getCensusApi(data_url=sf3_2000_api, key=censuskey, vars=myvars, region="county:*")
head(data2000)

# Plot median rent vs median household income
plot(data2000$P053001, data2000$H063001)

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
geos2014 <- listCensusGeos(acs_2014_api)
# Get all PUMAs in California
data2014 <- getCensusApi(data_url=acs_2014_api, key=censuskey, vars=myvars, region="public+use+microdata+area:*&in=state:06")
head(data2014)

# Congressional districts
data2014 <- getCensusApi(data_url=acs_2014_api, key=censuskey, vars=myvars, region="congressional+district:*")
head(data2014)

# Get data for all counties
data2014 <- getCensusApi(data_url=acs_2014_api, key=censuskey, vars=myvars, region="county:*")
head(data2014)

# Calculate % of families with kids under 18 led by single moms that are living below the poverty line
data2014$fampov <- data2014$B17010_017E/(data2014$B17010_017E + data2014$B17010_037E)
# Look at the distribution of fampov
summary(data2014$fampov)

########################################################################################################
# Let's graph the distribution of fampov
########################################################################################################
# Install ggplot2 and dplyr
# install.packages("ggplot2")
# install.packages("dplyr")
# Load libraries
library("ggplot2")
library("dplyr")

# Make a histogram
ggplot(data=data2014, aes(x=fampov)) + geom_histogram(binwidth=.02, color="black", fill="white")

# Boxplot by state for MD, VA, WV
mvw <- data2014 %>% filter(state %in% c("24", "51", "54"))
ggplot(data=mvw, aes(x=state, y=fampov)) + geom_boxplot()