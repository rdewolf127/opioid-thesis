/*This data comes from SAMHSA https://wwwdasis.samhsa.gov/dasis2/teds.htm*/

%web_drop_table(WORK.TEDS_2015);

FILENAME REFILE "/home/me0039/UTICA/tedsa_2015_puf.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=WORK.TEDS_2015;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.TEDS_2015;RUN;

%web_open_table(WORK.TEDS_2015);

