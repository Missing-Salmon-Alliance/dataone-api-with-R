# FUNCTION: This script helps create and import multiple metadata descriptions on to KNB and in turn MSA DataONE portal
# INPUT: csv of metadata
# INPUT: DataONE EML Template.xml
# OUTPUT: eml.xml file with new unique ID incorporated into filename
# OUTPUT: create datapackage and upload to KNB

# REQUIRED FILES: Fresh metadata csv file ("KNBTranslations_For_R.csv") from Data Sources folder on AST drive, based on the template

# TODO: There is no duplication check at the moment, adding a search query to KNB for each row before file creation to flag potential duplicate
# TODO: Incorporate Essential Salmon Variables into Keywords

#IMPORT METADATA as TIBBLE
y <- read_csv("KNBTranslations.csv", locale = locale(encoding = "latin1"),quoted_na = FALSE) # added locale information as getting odd results with default UTF-8
y$pubDate <- Sys.Date() # set publication date to today
## Check for NA values, they look rubbish on KNB, replace with empty string
# Needs some manual input if any columns as set to lgl change them to chr
# Note a way to do this is if all values in lgl column are known to be NA, just replace whole column manually with ""
# NOTE Some eml fields must be non-empty string if they exist and so "NA" is most appropriate
# Sample Code
# y$`coverage/taxonomicCoverage/generalTaxonomicCoverage` <- c("Non-Specific")
# y$`coverage/taxonomicCoverage/taxonomicClassification/taxonRankName` <- c("NA")
# y$`coverage/taxonomicCoverage/taxonomicClassification/taxonRankValue` <- c("NA")
# y$`creator/userId` <- c("") # UserID is OK with empty strings

# This line will replace any remaining NA value with empty string once lgl columns are dealt with
y <- y %>% replace(is.na(.), "")

#Capture keywords in separate tibble
y_keywords <- y[, c("commonKeywords","additionalKeywords")]
# and remove them from the main tibble
y <- select(y, -c("commonKeywords","additionalKeywords"))

#IMPORT EML Template
x <- read_xml("DataONE EML Template.xml")

#SET BASE XML NODE PATH
xpath_base <- "/eml:eml/dataset/"

# Create report tibble with UUID, KNB URL and Dataset Title

report <- tibble::tibble(uuid = character(),knbURI = character(), datasetTitle = character())


###
#Main FOR loop - FOR EACH TIBBLE ROW: Set new xml node values based on row, export to file and create/upload knb datapackage from file
###
for(i in 1:nrow(y)){ #rows ROWS CONTAIN NODE VALUES
  
  # REMOVE ALL KEYWORDS BEFORE MOVING TO NEXT ROW - AT BEGINNING OF ROUTINE TO CATCH AND REMOVE TEMPLATE KEYWORD
  xml_remove(xml_find_all(x, "//keyword"))
  
  for(z in 1:ncol(y)){ #cols COL NAMES ARE NODE PATH (TAIL only)
    xpath_tail <- names(y[z])
    xpath_full <- paste(xpath_base,xpath_tail,sep = "")
    node_value <- toString(y[i,z])
    xml_set_text(xml_find_all(x, xpath = xpath_full,xml_ns(x)),node_value)
  }
  # keyword routine
  # Create keyword_vector of all keywords for ROW (TWO COLUMNS of KEYWORDS)
  # COLUMN 1
  commonKeywords_vector <- str_trim(str_split(y_keywords$commonKeywords[i],",")[[1]])
  # COLUMN 2
  additionalKeywords_vector <- str_trim(str_split(y_keywords$additionalKeywords[i],",")[[1]])
  # MERGE into keyword_vector
  keyword_vector <- c(commonKeywords_vector,additionalKeywords_vector)
  
  #CREATE keyword NODES, add the same number as there are keywords (length of keyword_vector)
  for(kw in 1:length(keyword_vector)){
    xml_add_child(xml_find_all(x, xpath = "/eml:eml/dataset/keywordSet", xml_ns(x)), "keyword") # dummy initial value "keyword"
  }
  # APPLY keyword values to new nodes
  xml_find_all(x, "//keyword") %>% xml_set_text(keyword_vector)
  
  ### Valid EML xml object has now been created
  ### It will now be given a unique ID, exported to a file which will then be used to create KNB datapackage
  
  # Create and Set PID
  id_part <- UUIDgenerate()
  id <- paste("urn:uuid:", id_part, sep="")
  xml_set_attr(x, "packageId", id)
  
  # set metadataProvider node id attribute so that CONTACT/REFERENCES node works
  xml_set_attr(xml_find_all(x, "//metadataProvider"),"id",y[i,]$`metadataProvider/userId`)
  # export to xml file, with custom file name based on generated uuid
  filename <- paste("eml/eml_",id_part,".xml",sep = "")
  write_xml(x,filename)
  
  # File creation complete
  
  # Create KNB Datapackage and upload
  
  dp <- new("DataPackage")
  #x <- read_xml(filename)
  id <- xml_attr(x, "packageId")

  metadataObj <- new("DataObject", id, format="https://eml.ecoinformatics.org/eml-2.2.0", filename=filename)
  dp <- addMember(dp, metadataObj)

  # with a metadata object added the package can now be uploaded

  packageId <- uploadDataPackage(d1c, dp, public=FALSE, quiet=FALSE)
  
  ###
  # Create upload report tibble
  
  report <- dplyr::bind_rows(report,tibble::tibble(uuid = id_part,knbURI = paste0("https://knb.ecoinformatics.org/view/urn:uuid:",id_part), datasetTitle = y$title[i]))
}

write_csv(report,paste0("report_",Sys.Date()))
