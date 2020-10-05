# Search for and update an existing DataPackage
# Find search terms - useful documents and examples
vignette("searching-dataone")
??getQueryEngineDescription
getQueryEngineDescription(mn,"solr")

# Search
queryParamList <- list(q="author:Graeme Diack", rows="100",fl="id,title,author,archived,obsoletedBy") # rows value just to override default of 10
result <- query(mn,solrQuery=queryParamList,as="data.frame")

############
# Sometimes archive status can lag in the search results
# If results suspect of including archived, use the following routine to update archived column

v <- c() # define empty vector to hold updated archived status
for(pid in result$id){
  v <- append(v,getSystemMetadata(mn,pid)@archived)
}
result$archived_new <- v
result_new <- filter(result, archived_new == FALSE)

############
# Update access policy of DataONE objects
sysmeta <- getSystemMetadata(mn, pid)
sysmeta <- removeAccessRule(sysmeta, "public", "read")
sysmeta <- addAccessRule(sysmeta, "public", "read")
status <- updateSystemMetadata(mn, pid, sysmeta)


accessRules <- data.frame(
  subject=c("CN=knb-data-admins,DC=dataone,DC=org","CN=knb-data-admins,DC=dataone,DC=org","CN=knb-data-admins,DC=dataone,DC=org"),
  permission=c("read","write","changePermission"))

sysmeta <- addAccessRule(sysmeta, accessRules)
status <- updateSystemMetadata(mn, pid, sysmeta)


############
#retrieve and update/change package from dataone

pid <- "urn:uuid:7117441a-a2c5-4933-833b-684457f7fa70"
pkg <- getDataPackage(d1c,identifier = pid, lazyLoad=TRUE,limit="0MB", quiet=FALSE)

#TODO: Manipulate package contents and update. Does this create a new object, new uuid, and marks old object with obsoletedBy?


############
#ARCHIVE

pid <- "enter pid"

response <- archive(mn, pid)
sysmeta <- getSystemMetadata(mn, pid)
sysmeta@archived
sysmeta

for(pid in result$id){
  archive(mn, pid)
  sysmeta <- getSystemMetadata(mn, pid)
  print(sysmeta@archived)
}
