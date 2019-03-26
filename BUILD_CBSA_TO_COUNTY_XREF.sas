/*This data comes from CMS and is published by the 
NBER http://www.nber.org/data/cbsa-msa-fips-ssa-county-crosswalk.html*/

%web_drop_table(WORK.CBSA_COUNTY_XREF);

FILENAME REFILE "/home/me0039/UTICA/cbsatocountycrosswalk.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=WORK.CBSA_COUNTY_XREF;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.CBSA_COUNTY_XREF;RUN;

%web_open_table(WORK.CBSA_COUNTY_XREF);