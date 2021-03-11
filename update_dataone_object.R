# Search for and update an existing DataPackage
# Find search terms - useful documents and examples
vignette("searching-dataone")
??getQueryEngineDescription
getQueryEngineDescription(mn,"solr")

# Search
queryParamList <- list(q="author:Graeme Diack", rows="100",fl="id,title,author,archived,obsoletedBy") # rows value just to override default of 10
queryParamList <- list(q="keywords:WKSALMON", rows="100",fl="id,title,author,archived,obsoletedBy,dateUploaded")

queryParamList <- list(q="id:*2d060720-25c0-4d6d-b37d-6edd7835d425", rows="1",fl="title,author,contactOrganization")

result <- query(mn,solrQuery=queryParamList,as="data.frame")
resultNotObselete <- filter(result,is.na(obsoletedBy))

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

accessRules <- data.frame(
  subject=c("CN=Likely Suspects Framework Users,DC=dataone,DC=org"),
  permission=c("read","write"))

for(pid in resultNotObselete$id){
  sysmeta <- getSystemMetadata(mn, pid)
  sysmeta <- addAccessRule(sysmeta, accessRules)
  #sysmeta <- removeAccessRule(sysmeta, accessRules)
  status <- updateSystemMetadata(mn, pid, sysmeta)
  #print(pid)
  #print(sysmeta@accessPolicy)
}






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
