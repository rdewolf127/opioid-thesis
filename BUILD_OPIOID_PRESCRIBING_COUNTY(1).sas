/*This data comes from the CDC https://www.cdc.gov/drugoverdose/maps/rxcounty2014.html*/

%web_drop_table(mydata.OPIOID_PRESCRIBING_COUNTY_&year.);

FILENAME REFILE "/home/me0039/UTICA/opioid-thesis/CSV-Files/OpioidPrescribingByCounty&year..csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=mydata.OPIOID_PRESCRIBING_COUNTY_&year.;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=mydata.OPIOID_PRESCRIBING_COUNTY_&year.;RUN;

%web_open_table(mydata.OPIOID_PRESCRIBING_COUNTY_&year.);