/*This data comes from CMS and is published by the 
NBER http://www.nber.org/data/cbsa-msa-fips-ssa-county-crosswalk.html*/

%web_drop_table(mydata.CBSA_COUNTY_XREF);

FILENAME REFILE "/home/me0039/UTICA/opioid-thesis/CSV-Files/cbsatocountycrosswalk.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=mydata.CBSA_COUNTY_XREF;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=mydata.CBSA_COUNTY_XREF;RUN;

%web_open_table(mydata.CBSA_COUNTY_XREF);