/*This data comes from the CDC Wonder Program https://wonder.cdc.gov*/

%web_drop_table(WORK.OD_Deaths_2015);

FILENAME REFILE "/home/me0039/UTICA/Unintentional_OD_Deaths_2015.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=WORK.OD_DEATHS_2015;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.OD_DEATHS_2015;RUN;

%web_open_table(WORK.OD_DEATHS_2015);