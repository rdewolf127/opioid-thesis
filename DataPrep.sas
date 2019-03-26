libname mydata "/home/me0039/UTICA";

/*get opioid NDCs*/
data mydata.ndc;
set mydata.cdc_mme_table_sept2018;
run;

proc freq data = mydata.ndc;
tables class;
run;

proc sql;
create table mydata.opioid_ndcs as
select distinct * from mydata.ndc where class = "Opioid";
quit;

/*get 2015 TEDS data*/
%include "/home/me0039/UTICA/Build_TEDS_2015.sas";

/*subset TEDS data to opioid admissions and summarize by CBSA*/
proc sql;
create table mydata.TEDS_CBSA_2015 as
select count(distinct(CASEID)) as num_admissions, CBSA10
from mydata.TEDS_2015
where (OPSYNFLG = 1 or DSMCRIT = 12) and CBSA10 ^= -9
group by CBSA10;
quit;

/*get 2015 unintentional overdose data*/
%include "/home/me0039/UTICA/BUILD_OD_DEATHS_2015.sas";

/*get crosswalk to bring overdose deaths from county level up to CBSA10 to match TEDS data*/
%include "/home/me0039/UTICA/BUILD_CBSA_TO_COUNTY_XREF.sas";

/*get distinct county/cbsa combinations*/
proc sql;
create table mydata.crosswalk_cleaned as
select distinct cbsa, fipscounty
from mydata.cbsa_county_xref
where cbsa IS NOT NULL;
quit;

/*merge OD Deaths with crosswalk*/
proc sql;
create table mydata.OD_Deaths_XREF as
select distinct a.*, b.cbsa from mydata.OD_Deaths a
join mydata.crosswalk_cleaned b 
on a.County_Code = b.fipscounty;
quit;

/*summarize OD Deaths by CBSA*/
proc sql;
create table mydata.OD_Deaths_CBSA_2015 as
select distinct cbsa, sum(deaths) as num_od_deaths 
from mydata.OD_Deaths_XREF
group by cbsa;
quit;

/*merge TEDS and OD Deaths at CBSA level*/
proc sql;
create table mydata.TEDS_OD_MERGE as
select a.*, b.num_od_deaths
from mydata.TEDS_CBSA_2015 a 
left join mydata.OD_Deaths_CBSA_2015 b 
on a.CBSA10 = b.CBSA;
quit;

/*get opioid prescribing data by county*/
%include "/home/me0039/UTICA/BUILD_OPIOID_PRESCRIBING_COUNTY.sas";

/*get population data by county (to back into the total number of opioid prescriptions filled)*/








