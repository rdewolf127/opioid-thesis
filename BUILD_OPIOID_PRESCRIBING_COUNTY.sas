/*This data comes from the CDC https://www.cdc.gov/drugoverdose/maps/rxcounty2014.html*/

%web_drop_table(mydata.OPIOID_PRESCRIBING_COUNTY);

FILENAME REFILE "/home/me0039/UTICA/OpioidPrescribingByCounty.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=mydata.OPIOID_PRESCRIBING_COUNTY;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=mydata.OPIOID_PRESCRIBING_COUNTY;RUN;

%web_open_table(mydata.OPIOID_PRESCRIBING_COUNTY);