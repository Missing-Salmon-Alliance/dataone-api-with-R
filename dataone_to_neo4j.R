# This script will contain methods to move data from KNB to the LSF graph on neo4j
# First use case is to update/synchronise URI and DOI for metadata in the graph with those on the KNB, KNB being the master version.

# TODO: Make the search more intelligent, in it's current form it could potentially overwrite similarly titled datasets
# TODO: Currently blanks the DOI value in neo4j, needs to be changed when we start using DOI's (after releasing KNB repo to public view)


# get metadata information from neo4j
# load neo4j secrets
source("./secrets.R",local = TRUE)
con <- neo4j_api$new(url = secretsurl, user = secretsuser, password = secretspassword)
metadataLabels <- call_neo4j("MATCH (n:Metadata) RETURN n.metadataLabel",con,type = "row")
metadataTitles <- call_neo4j("MATCH (n:Metadata) RETURN n.metadataTitle",con,type = "row")

# search dataone for URI and DOI information

updateURI <- function(title,result){
  # update neo4j with new URI
  print(paste("Local NEO4J object:",title))
  print(paste("KNB object:",result$title))
  n <- readline(prompt="Are the above the same object? If so, continue with update: (yes or no)")
  n <- tolower(n)
  if(n == "yes"){
    newURI <- paste("https://knb.ecoinformatics.org/view/",result$id,sep = "")
    updateQuery <- paste("MATCH (n:Metadata) WHERE n.metadataTitle = '",result$title,"' SET n.URI = '",newURI,"', n.DOI = ''", sep = "")
    call_neo4j(updateQuery,con,include_stats = TRUE)
  }
  else{
    print(paste("UPDATE OF",title,"SKIPPED",sep = " "))
  }
}


