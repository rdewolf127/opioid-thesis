libname mydata "/home/me0039/UTICA"; 
 
data ndc; 
set mydata.cdc_mme_table_sept2018; 
run; 
 
proc freq data = ndc; 
tables class; 
run; 
 
proc sql; 
create table mydata.opioid_ndcs as 
select distinct * from ndc where class = "Opioid"; 
quit;
