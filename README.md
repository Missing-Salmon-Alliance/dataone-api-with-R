# dataone-api-with-R
Examples and workflows for uploading and modifying DataONE/KNB datapackages
https://knb.ecoinformatics.org/
https://www.dataone.org/

## Description

The Likely Suspects Framework leverages the metadata catalogue at https://knb.ecoinformatics.org/ as an immutable and FAIR data resource.
Data sets relevant to the LSF should be described here and tagged with a minimum set of tags ("Likely Suspects Framework", "Atlantic Salmon", "Essential Salmon Variable")

Requires R packages:
library(dataone) # used to interact with DataONE/KNB API
library(datapack) # used for creating datapackages to upload to KNB
library(uuid) # used to generate new PackageId for datapackages
library(xml2) # used for manipulating xml files
library(EML) # For working specifically within the EML schema for xml
library(tidyverse) # always tidy
library(neo4r) # for interacting with neo4j graph
