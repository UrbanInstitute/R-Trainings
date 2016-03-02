########################################################################################################
# Urban Institute R Users Group, 03-02-16
# Retrieving Census data via API
# Hannah Recht & Alex Engler

# Slides: http://urbaninstitute.github.io/R-Trainings/accesing-census-apis/presentation/index.html#/

# IMPORTANT: First, request a Census API key here and save the key: http://api.census.gov/data/key_signup.html
# More information: http://www.census.gov/developers/
########################################################################################################

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

# getCensus function takes five main arguments:
# name (name of the API, e.g. 'sf3' or 'acs5')
# vintage (year, e.g. 2014, required for non-timeseries APIs)
# key (your census API key, saved above)
# vars (a list of variables to get)
# region (geography to use, e.g. 'county:*')

########################################################################################################
# ACS most recent 5-year data - 2010-14
# General information: http://www.census.gov/data/developers/data-sets/acs-survey-5-year-data.html

# Let's get some very specific variables - what % of families with kids under 18 led by single moms are living below the poverty line?
# Variable info: http://api.census.gov/data/2014/acs5/variables/B17010_017E.json, http://api.census.gov/data/2014/acs5/variables/B17010_037M.json
########################################################################################################
# Look at our geography options - lots available for the ACS
# Information read in from http://api.census.gov/data/2014/acs5/geography.html
geos2014 <- listCensusMetadata(name="acs5", vintage=2014,  type="g")
View(geos2014)

# See list of variables available - for some APIs there are only a few, for ACS there are tens of thousands
# This is the data from http://api.census.gov/data/2014/acs5/variables.html
# Not running in training session unless Internet is fast
# vars2014 <- listCensusMetadata(name="acs5", vintage=2014, "v")
# View(vars2014)

# Variables to get - total population, median household income, families w/ kids led by single moms who are below poverty, families w/ kids led by single moms who are at or above poverty
myvars <- c("NAME", "B01001_001E", "B19013_001E", "B17010_017E", "B17010_037E")

# Geography note: "*" means all available - so region="state:*" means all available states
# Get data for all congressional districts
data2014 <- getCensus(name="acs5", vintage=2014, key=censuskey, vars=myvars, region="congressional district:*")
View(data2014)

# All counties
data2014 <- getCensus(name="acs5", vintage=2014, key=censuskey, vars=myvars, region="county:*")
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
ggplot(data=data2014, aes(x=fampov)) + geom_histogram(binwidth=.02, color="black", fill="#1696d2")

# Boxplot by state for MD, VA, WV
mvw <- data2014 %>% filter(state %in% c("24", "51", "54"))
ggplot(data=mvw, aes(x=state, y=fampov)) + geom_boxplot()

########################################################################################################
# Additional example
# 2000 decennial census API - we'll use Summary File 3
# General information: http://www.census.gov/data/developers/data-sets/decennial-census-data.html
# 2000 decennial datasets: http://api.census.gov/data/2000.html
# "Summary File 3 consists of 813 detailed tables of Census 2000 social, economic and housing characteristics compiled from a sample of approximately 19 million housing units (about 1 in 6 households) that received the Census 2000 long-form questionnaire."
########################################################################################################
# Let's see what variables are available - from http://api.census.gov/data/2000/sf3/variables.html
vars2000 <- listCensusMetadata(name="sf3", vintage=2000, "v")
View(vars2000)

# Variables to get - total population, median household income, median gross rent, Census Region
myvars <- c("P001001", "P053001", "H063001", "REGION")

# Get data at state-level
data2000 <- getCensus(name="sf3", vintage=2000, key=censuskey, vars=myvars, region="state:*")
# View first 6 rows
head(data2000)

# Let's look at some other geography options
listCensusMetadata(name="sf3", vintage=2000, "g")

# Get data at county-level for all states
data2000 <- getCensus(name="sf3", vintage=2000, key=censuskey, vars=myvars, region="county:*")
head(data2000)
data2000 <- data2000 %>% rename(income = P053001, rent = H063001, population = P001001)

# Plot this data in a bubble chart:
qplot(data=data2000, x=income, y=rent, size=population, color=REGION, alpha=0.7)

# Or will small multiples:
qplot(data=data2000, x=income, y=rent, size=population, color=REGION, alpha=0.7) +
  facet_grid(facets = REGION~., scales="free_y")

########################################################################################################
# Advanced functions
########################################################################################################

# Get sub-state data within a specified state (fips code 06 = California)
data2000 <- getCensus(name="sf3", vintage=2000, key=censuskey, vars=c("P001001", "P053001", "H063001"), region="county:*", regionin="state:06")
head(data2000)

data2014 <- getCensus(name="acs5", vintage=2014, key=censuskey, vars=c("B01001_001E", "B19013_001E", "B17010_017E", "B17010_037E"), region="public use microdata area:*", regionin="state:06")
head(data2014)

# Fips code list (all 50 states + DC + Puerto Rico) is included in the censusapi package - see it
fips
# Loop over all states for small geographies that are nested under state-level geography (e.g. tract)
# Note: this might take a few minutes depending on your Internet speed
tracts <- NULL
# For all states in the fips list
for (f in fips) {
	# Define what state to get
	stateget <- paste("state:", f, sep="")
	# Get data for all tracts within that state
	temp <- getCensus(name="acs5", vintage=2014, key=censuskey, vars=c("B01001_001E", "B19013_001E", "B17010_017E", "B17010_037E"), region="tract:*", regionin=stateget)
	# Bind to existing data
	tracts <- rbind(tracts, temp)
}
head(tracts)

# Use makeVarlist function to return a list or data frame of variables containing a search word
?makeVarlist #function info

# Return a list of all variables with 'military' in the label field
militaryvars <- makeVarlist(name="sf1", vintage=2000, find="military", varsearch="label")
# Then use the getCensus function to retrieve those variables
militarydt <- getCensus(name="sf1", vintage=2000, key=censuskey, vars=militaryvars, region="state:*")

# Get metadata on all H16 variables
vartable <- makeVarlist(name="sf1", vintage=2000, find="h16", varsearch="concept", output="dataframe")