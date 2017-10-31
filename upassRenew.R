library(RSelenium)
library(magrittr)
library(stringr)
library(methods)

print('starting selenium')
system('java -jar selenium-server-standalone-3.4.0.jar -port 4445 &') # clicking doesn't work in latest 3.6 version

sleepyTime = 5
Sys.sleep(sleepyTime)

cprof<-makeFirefoxProfile(list(
    #browser.download.dir = '/home/omancarci/git repos/MSigDB/data-raw/', # this line doesn't work. not sure why
    browser.helperApps.neverAsk.saveToDisk='text/plain, text/xml,application/xml, application/vnd.ms-excel, text/csv, text/comma-separated-values, application/octet-stream','application/gedit',
    browser.download.manager.showWhenStarting = FALSE,
    browser.helperApps.alwaysAsk.force = FALSE
))

remDr <- remoteDriver(remoteServerAddr = "localhost"
                      , port = 4445L
                      , browserName = "firefox",
                      extraCapabilities=cprof
                      
)

print('starting firefox')
remDr$open()


Sys.sleep(sleepyTime)


print('go to translink')
remDr$navigate("https://upassbc.translink.ca/")
Sys.sleep(sleepyTime)

webElem = remDr$findElement(using = 'xpath', value = "//*/option[@value = 'ubc']")
webElem$clickElement()

Sys.sleep(sleepyTime)

webElem = remDr$findElement(using = 'id', value = "goButton")
webElem$clickElement()

Sys.sleep(sleepyTime)

pass = readLines('pass')
username = pass[1]
pass = pass[2]

webElem = remDr$findElement(using = 'id', value = "j_username")
webElem$sendKeysToElement(sendKeys = list(username))
Sys.sleep(sleepyTime)


webElem = remDr$findElement(using = 'id', value = "password")
webElem$sendKeysToElement(sendKeys = list(pass))
Sys.sleep(sleepyTime)


webElem = remDr$findElement(using = 'name', value = "action")
webElem$clickElement()
Sys.sleep(sleepyTime)

tryCatch({
    webElem = remDr$findElement(using = 'id', value = "chk_1")
webElem$clickElement()
Sys.sleep(sleepyTime)

webElem = remDr$findElement(using = 'id', value = "requestButton")
webElem$clickElement()
Sys.sleep(sleepyTime)
},error = function(e){
    print('no new pass')
})


# auto kill server at the end
killPid = system(' ps ax  | grep selenium',intern = TRUE) %>% str_extract('^(\\s)*[0-9]*(?=\\s)')
killPid %>% sapply(function(x){
    system(paste('kill -9',x))
})

killPid = system(' ps ax  | grep firefox',intern = TRUE) %>% str_extract('^\\s*[0-9]*(?=\\s)')
killPid %>% sapply(function(x){
    system(paste('kill -9',x))
})

