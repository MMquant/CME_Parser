### Parser script
setwd("/Users/jvr23/Documents/R/CME_Parser")
source("Parser.R")
# Initialization of new R6 Class object
p <- Parser$new()
# Configuring database connection
p$set("db", list("192.168.88.202", 5432, "cauneasi54Ahoj"))
# parse method of Parser object downloads and parse settlement report files
p$parse()
# exportQuery method constructs SQL query and exports data to the database
p$exportQuery()
# Uncomment when running from CRON
q("no")