/*This data comes from the CDC Wonder program. https://www.cdc.gov/wonder */

%web_drop_table(mydata.NAS_Infant_Death);

FILENAME REFILE "/home/me0039/UTICA/opioid-thesis/CSV-Files/NAS_Infant_Deaths.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=mydata.NAS_Infant_Deaths_2015;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=mydata.NAS_Infant_Deaths_2015;RUN;

%web_open_table(mydata.NAS_Infant_Deaths);
	



