### Parser script
setwd("/Users/jvr23/Documents/R/CME_Parser")
source("Parser.R")
# Initialization of new R6 Class object
p <- Parser$new()
# Configuring database connection
<<<<<<< Updated upstream
p$set("db", list("192.168.88.202", 5432, "yourPassword"))
# write("10/28/15","log/reportdate.log") # uncomment for debugging purposes
=======
p$set("db", list("192.168.88.202", 5432, "cauneasi54Ahoj"))
>>>>>>> Stashed changes
# parse method of Parser object downloads and parse settlement report files
p$parse()
# exportQuery method constructs SQL query and exports data to the database
p$exportQuery()
<<<<<<< Updated upstream
=======
# Uncomment when running from CRON
q("no")
>>>>>>> Stashed changes
