#######
# Commands for creating a single datapackage from an EML.xml file
# and uploading to KNB. Ensure correct ENV variables have been defined
# from 'select_environment.R' script (cn, mn and d1c)
#######

# Create a DataPackage to be uploaded
dp <- new("DataPackage")

# A DataPackage will contain at least the EML metadata, but can contain data files, code files, output files, each defined as a "DataObject"
# and added to the DataPackage using addMember

# Set filename containing required EML
filename <- "enter_filename.eml"

# Get values from EML file
x <- read_xml(filename)
id <- xml_attr(x, "packageId")
format <- xml_attr(x, "xmlns:eml")

metadataObj <- new("DataObject", id, format=format, filename=filename)
dp <- addMember(dp, metadataObj)

# with a metadata object added the package can now be uploaded

packageId <- uploadDataPackage(d1c, dp, public=FALSE, quiet=FALSE)
message(sprintf("Uploaded package with identifier: %s", packageId))

# For records keep id and packageId

#TODO Create some kind of history tibble in .RData? or as project file
