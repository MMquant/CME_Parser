### Parser script
source("Parser.R")
p <- Parser$new()
p$set("db", list("192.168.88.202", 5432, "yourPassword"))
p$parse()
p$exportQuery()
