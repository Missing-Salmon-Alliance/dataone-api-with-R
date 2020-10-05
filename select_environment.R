#######
# Authentication and target Environment to be selected
#######

# PRODUCTION
# URL https://knb.ecoinformatics.org/
# Load PROD authentication token from file
source("dataonePROD.token.R")
# SET ENVIRONMENT
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
d1c <- D1Client(cn, mn)

# STAGING2 (Development Environment that mirrors PROD exactly)
# URL https://dev.nceas.ucsb.edu/
# Load STAGING2 authentication token from file
source("dataoneTEST.token.R")
# SET ENVIRONMENT
cn <- CNode("STAGING2")
mn <- getMNode(cn, "urn:node:mnTestKNB") # note command 'unlist(lapply(listNodes(cn), function(x) x@subject))' from dataone-federation vignette
d1c <- D1Client(cn, mn)


# CONFIRM token has not expired (expiry occurs frequently, I think daily for PROD)
am <- AuthenticationManager()
getTokenInfo(am)
