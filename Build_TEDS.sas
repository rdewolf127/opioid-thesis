/*This data comes from SAMHSA https://wwwdasis.samhsa.gov/dasis2/teds.htm*/

%web_drop_table(mydata.TEDS_&year.);

FILENAME REFILE "/home/me0039/UTICA/opioid-thesis/CSV-Files/tedsa_&year._puf.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=mydata.TEDS_&year.;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=mydata.TEDS_&year.;RUN;

%web_open_table(mydata.TEDS_&year.);

