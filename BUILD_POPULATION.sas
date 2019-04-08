/*This data is from the US Census Bureau 
https://www.census.gov/data/datasets/2017/demo/popest/counties-total.html#par_textimage_70769902*/

%web_drop_table(mydata.pop_est);

FILENAME REFILE "/home/me0039/UTICA/opioid-thesis/CSV-Files/PopulationEST.csv";

PROC IMPORT DATAFILE=REFILE
	DBMS=CSV
	OUT=mydata.pop_est;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=mydata.pop_est;RUN;

%web_open_table(mydata.pop_est);