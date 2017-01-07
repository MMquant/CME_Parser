curl "ftp://ftp.cmegroup.com/pub/settle/{stlint,stleqt,stlags,stlcur,stlnymex}" -o "/Users/jvr23/Documents/R/CME_data/data/#1.txt"
curl "ftp://ftp.cmegroup.com/settle/stlcomex" -o "/Users/jvr23/Documents/R/CME_data/data/stlcomex.txt"

# Run script 23:11 UTC

url <- c("ftp://ftp.cmegroup.com/pub/settle/stlint",
        "ftp://ftp.cmegroup.com/pub/settle/stleqt",
        "ftp://ftp.cmegroup.com/pub/settle/stlags",
        "ftp://ftp.cmegroup.com/pub/settle/stlnymex",
        "ftp://ftp.cmegroup.com/settle/stlcomex")
destfile <- c("stlint","stleqt","stlags","stlnymex","stlcomex")
download.file(url, destfile, method = "libcurl", quiet = FALSE, mode = "w",
              cacheOK = TRUE,
              extra = getOption("download.file.extra"))
