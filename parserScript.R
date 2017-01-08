### Parser script
source("Parser.R")
# Initialization of new R6 Class object
p <- Parser$new()
<<<<<<< Updated upstream
p$set("db", list("192.168.88.202", 5432, "yourPassword"))
p$parse()
p$exportQuery()
=======
# Configuring database connection
p$set("db", list("192.168.88.202", 5432, "cauneasi54Ahoj"))
# write("10/28/15","log/reportdate.log") # uncomment for debugging purposes
# parse method of Parser object downloads and parse settlement report files
p$parse()
# exportQuery method constructs SQL query and exports data to the database
p$exportQuery()
>>>>>>> Stashed changes
