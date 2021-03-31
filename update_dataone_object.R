# Search for and update an existing DataPackage
# Find search terms - useful documents and examples
vignette(package="dataone")
vignette("v03-searching-dataone")
??getQueryEngineDescription
getQueryEngineDescription(cn,"solr")

# Search - Some ideas that might or might not work :/
queryParamList <- list(q="author:Graeme Diack", rows="10",fl="id,title,author,archived,obsoletedBy") # rows value just to override default of 10
queryParamList <- list(q="keywords:'Likely Suspects Framework'", rows="100",fl="id,title,author,archived,obsoletedBy,dateUploaded")
queryParamList <- list(q="id:*2d060720-25c0-4d6d-b37d-6edd7835d425", rows="1",fl="title,author,contactOrganization")

# The actual working search to find all data objects with a specific rightsHolder (Heavily escaped ORCID)
# ESCAPE-ORAMA! All these mad backslashes are just to escape solr special characters https://lucene.apache.org/core/6_5_1/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Escaping_Special_Characters
# Not sure why I need two of each, just works
queryParamList <- list(q="rightsHolder:http\\:\\/\\/orcid.org\\/0000\\-0003\\-1023\\-4700", rows="1000",fl="id,title,archived,obsoletedBy")

result <- query(mn,solrQuery=queryParamList,as="data.frame")

# remove obsoleted entries
result <- filter(result,is.na(obsoletedBy))
# remove those with no title (TODO: WHAT Are they?)
result <- filter(result,!is.na(title))


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

for(pid in result$id){
  sysmeta <- getSystemMetadata(mn, pid)
  sysmeta <- addAccessRule(sysmeta, accessRules)
  #sysmeta <- removeAccessRule(sysmeta, accessRules)
  status <- updateSystemMetadata(mn, pid, sysmeta)
  # print(pid)
  # print(sysmeta@accessPolicy)
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
