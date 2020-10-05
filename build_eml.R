# EXAMPLE - How to build XML/EML from scratch

x_root <- xml_new_root("eml")
xml_set_attr(x_root, "xmlns:eml","https://eml.ecoinformatics.org/eml-2.2.0")
xml_set_attr(x_root, "xmlns:stmml","http://www.xml-cml.org/schema/stmml-1.1")
xml_set_attr(x_root, "xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
xml_set_attr(x_root, "xsi:schemaLocation","https://eml.ecoinformatics.org/eml-2.2.0 https://eml.ecoinformatics.org/eml-2.2.0/eml.xsd")
xml_add_child(xml_find_all(x_root, xpath = "/eml"), "dataset")
# NOTE - Refer to EML schema to continue adding nodes, there is a specific order and required nodes
xml_add_child(xml_find_all(x_root, xpath = "/eml/dataset", xml_ns(x_root)), "keywordSet")
xml_add_child(xml_find_all(x_root, xpath = "/eml/dataset/keywordSet", xml_ns(x_root)), "keyword")
