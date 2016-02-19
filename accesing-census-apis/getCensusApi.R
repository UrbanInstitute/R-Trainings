library(XML)
# Return all available APIs as data frame
listCensusApis <- function() {
  u <- 'http://api.census.gov/data.html'
  apis <- as.data.frame(readHTMLTable(u))
  apis <- apis[,c(1:4,10)]
  colnames(apis) <- c("title", "description", "vintage", "name", "url")
  apis[] <- lapply(apis, as.character)
  return(apis)
}
# Example:
# apis <- listCensusApis()

# Return list of variables available by api
listCensusVars <- function(data_url) {
  # Trim trailing ? or /
  lastchar <- substr(data_url, nchar(data_url), nchar(data_url))
  if (lastchar=="?" | lastchar=="/") {
    data_url <- substr(data_url, 1, nchar(data_url)-1)
  }
  
  u <- paste(data_url, "variables.html", sep="/")
  vartable <- as.data.frame(readHTMLTable(u))
  colnames(vartable) <- c("name", "label", "concept", "required", "predicatetype")
  vartable[] <- lapply(vartable, as.character)
  return(vartable)
}
# Example:
# vars2014 <- listCensusVars("http://api.census.gov/data/2014/acs5")

# Return list of geographies available by api
listCensusGeos <- function(data_url) {
  # Trim trailing ? or /
  lastchar <- substr(data_url, nchar(data_url), nchar(data_url))
  if (lastchar=="?" | lastchar=="/") {
    data_url <- substr(data_url, 1, nchar(data_url)-1)
  }
  
  u <- paste(data_url, "geography.html", sep="/")
  geotable <- as.data.frame(readHTMLTable(u))
  colnames(geotable) <- c("reference_date", "geography_level", "geography_hierarchy")
  geotable[] <- lapply(geotable, as.character)
  return(geotable)
}
# Example:
# geos2014 <- listCensusGeos("http://api.census.gov/data/2014/acs5")

# List of state fips (50 states + DC)
statesuse <- c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56)

# Code source: Nicholas Nagle, https://rpubs.com/nnnagle/19337
# getCensusApi
# get Census data via the public API: loop through variables if needed
# Inputs:
#   data_url: the url root of the api, including the '?'
#     example: http://api.census.gov/data/2010/sf1?
#   key: your API key
#   vars: a character vector of variables to get.
#     example c("H0110001","H0110002","H0110003")
#     If there are more than 50, then it will be automatically split into separate queries.
#   region: region to get data for.  contains a for:, and possibly an in:
#     example: for=block:1213&in=state:47+county:015+tract:*
# Output:
#   If successful, a data.frame
#   If unsuccessful, prints the url query that caused the error.
getCensusApi <- function(data_url,key, vars, region, numeric=TRUE){
  if(length(vars)>50){
    vars <- vecToChunk(vars) # Split vars into a list
    get <- lapply(vars, function(x) paste(x, sep='', collapse=","))
    data <- lapply(vars, function(x) getCensusApi2(data_url,key, x, region, numeric=TRUE))
  } else {
    get <- paste(vars, sep='', collapse=',')
    data <- list(getCensusApi2(data_url,key, get, region, numeric=TRUE))
  }
  # Format output.  If there were no errors, than paste the data together
  # If there is an error, just return the unformatted list.
  if(all(sapply(data, is.data.frame))){
    colnames <- unlist(lapply(data, names))
    data <- do.call(cbind,data)
    names(data) <- colnames
    # Prettify the output
    # If there are nonunique colums, remove them
    data <- data[,unique(colnames, fromLast=TRUE)]
    # Reorder columns so that numeric fields follow non-numeric fields
    data <- data[,c(which(sapply(data, class)!='numeric'), which(sapply(data, class)=='numeric'))]
    return(data)
  }else{
    print('unable to create single data.frame in getCensusApi')
    return(data)
  }
}

# get Census data via the public API using a single query
# Inputs:
#   data_url: the url root of the api, including the '?'
#     example: http://api.census.gov/data/2010/sf1?
#   key: your API key
#   get: The variables to get. Separate multiple variables by commas.
#     example 'H0110001,H0110002,H0110003'
#   region: region to get data for.  contains a for:, and possibly an in:
#     example: for=block:1213&in=state:47+county:015+tract:*
# Output:
#   If successful, a data.frame
#   If unsuccessful, prints the url query that was constructed.
getCensusApi2 <- function(data_url,key, get, region, numeric=TRUE){
  if(length(get)>1) get <- paste(get, collapse=',', sep='')
  api_call <- paste(data_url, 
                    '?key=', key, 
                    '&get=', get,
                    '&for=', region,
                    sep='')
  
  dat_raw <- try(readLines(api_call, warn="F"))
  if(class(dat_raw)=='try-error') {
    print(api_call)
    return}
  dat_df <- data.frame()
  
  #split the datastream into a list with each row as an element
  # Thanks to roodmichael on github
  tmp <- strsplit(gsub("[^[:alnum:], _]", '', dat_raw), "\\,")
  #dat_df <- rbind(dat_df, t(sapply(tmp, '[')))
  #names(dat_df) <- sapply(dat_df[1,], as.character)
  #dat_df <- dat_df[-1,]
  dat_df <- as.data.frame(do.call(rbind, tmp[-1]), stringsAsFactors=FALSE)
  names(dat_df) <- tmp[[1]]
  # convert to numeric
  # The fips should stay as character... so how to distinguish fips from data?
  # I think all of the data have numbers in the names, the fips do not
  #  Example: field names of B01001_001E vs state
  if(numeric==TRUE){
    value_cols <- grep("[0-9]", names(dat_df), value=TRUE)
    for(col in value_cols) dat_df[,col] <- as.numeric(as.character(dat_df[,col]))
  }
  return(dat_df)
}

vecToChunk <- function(x, max=50){
  s <- seq_along(x)
  x1 <- split(x, ceiling(s/max))
  return(x1)
}