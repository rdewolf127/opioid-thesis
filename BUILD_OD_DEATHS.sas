/*This data comes from the CDC Wonder Program https://wonder.cdc.gov*/

%web_drop_table(mydata.OD_Deaths_&year.);

FILENAME REFILE "/home/me0039/UTICA/opioid-thesis/CSV-Files/Unintentional_OD_Deaths_&year..csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=mydata.OD_DEATHS_&year.;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=mydata.OD_DEATHS_&year.;RUN;

%web_open_table(mydata.OD_DEATHS_&year.);