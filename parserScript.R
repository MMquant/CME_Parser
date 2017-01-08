### Parser script
source("Parser.R")
p <- Parser$new()
p$set("db", list("192.168.88.202", 5432, "cauneasi54Ahoj"))
write("10/28/15","log/reportdate.log")
p$parse()
p$exportQuery()