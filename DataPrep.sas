libname mydata "/home/me0039/UTICA/opioid-thesis/SAS-Datasets";

/*get opioid NDCs.  This dataset came from CDC 
https://www.cdc.gov/drugoverdose/resources/data.html*/
/*proc sql;
create table mydata.opioid_ndcs as
select distinct * from mydata.cdc_mme_table_sept2018 where class = "Opioid";
quit;*/

/*get TEDS data*/
%macro get_TEDS(year);
%include "/home/me0039/UTICA/opioid-thesis/Scripts/Build_TEDS.sas";
%mend;

%get_TEDS(2013);
%get_TEDS(2014);
%get_TEDS(2015);
%get_TEDS(2016);


%macro subset_teds(year);
/*subset TEDS data to opioid admissions and summarize by CBSA*/
proc sql;
create table mydata.TEDS_CBSA_&year. as
select count(distinct(CASEID)) as num_admissions, CBSA10, year
from mydata.TEDS_&year.
where (OPSYNFLG = 1) and CBSA10 ^= -9
group by CBSA10, year;
quit;
%mend;

%subset_teds(2013);
%subset_teds(2014);
%subset_teds(2015);
%subset_teds(2016);

%macro subset_heroin_teds(year);
/*subset TEDS data to heroin admissions and summarize by CBSA*/
proc sql;
create table mydata.TEDS_HEROIN_CBSA_&year. as
select count(distinct(CASEID)) as num_admissions, CBSA10, year
from mydata.TEDS_&year.
where (HERFLG = 1) and CBSA10 ^= -9
group by CBSA10, year;
quit;
%mend;

%subset_heroin_teds(2013);
%subset_heroin_teds(2014);
%subset_heroin_teds(2015);
%subset_heroin_teds(2016);

/*combine all of the teds subset datasets into one table*/
proc sql;
create table mydata.teds_CBSA as
select * from mydata.teds_cbsa_2013
union
select * from mydata.teds_cbsa_2014
union
select * from mydata.teds_cbsa_2015
union
select * from mydata.teds_cbsa_2016;
quit;

/*combine all of the teds heroin subset datasets into one table*/
proc sql;
create table mydata.teds_heroin_CBSA as
select * from mydata.teds_heroin_cbsa_2013
union
select * from mydata.teds_heroin_cbsa_2014
union
select * from mydata.teds_heroin_cbsa_2015
union
select * from mydata.teds_heroin_cbsa_2016;
quit;

/*remove datasets we no longer need to save space*/
proc datasets library=mydata;
	delete teds_2013;
	delete teds_2014;
	delete teds_2015;
	delete teds_2016;
	delete teds_cbsa_2013;
	delete teds_cbsa_2014;
	delete teds_cbsa_2015;
	delete teds_cbsa_2016;
	delete teds_heroin_cbsa_2013;
	delete teds_heroin_cbsa_2014;
	delete teds_heroin_cbsa_2015;
	delete teds_heroin_cbsa_2016;
run;

/*get unintentional overdose data*/
%macro get_od_deaths(year);
%include "/home/me0039/UTICA/opioid-thesis/Scripts/BUILD_OD_DEATHS.sas";
%mend;

%get_od_deaths(2013);
%get_od_deaths(2014);
%get_od_deaths(2015);
%get_od_deaths(2016);

/*combine all years into one table*/
proc sql;
create table mydata.od_deaths as 
select * from mydata.od_deaths_2013
union 
select * from mydata.od_deaths_2014
union 
select * from mydata.od_deaths_2015
union 
select * from mydata.od_deaths_2016;
quit;

/*delete datasets we don't need anymore to save space*/
proc datasets library=mydata;
	delete od_deaths_2013;
	delete od_deaths_2014;
	delete od_deaths_2015;
	delete od_deaths_2016;
run;

/*get crosswalk to bring overdose deaths from county level up to CBSA10 to match TEDS data*/
%include "/home/me0039/UTICA/opioid-thesis/Scripts/BUILD_CBSA_TO_COUNTY_XREF.sas";

/*get distinct county/cbsa combinations*/
proc sql;
create table mydata.crosswalk_cleaned as
select distinct a.cbsa, a.fipscounty
from mydata.cbsa_county_xref a 
where a.cbsa IS NOT NULL;
quit;


/*merge OD Deaths with crosswalk*/
proc sql;
create table mydata.OD_Deaths_XREF as
select distinct a.*, b.cbsa 
from mydata.od_deaths a
join mydata.crosswalk_cleaned b 
on a.County_Code = b.fipscounty;
quit;

/*summarize OD Deaths by CBSA*/
proc sql;
create table mydata.OD_Deaths_CBSA as
select distinct cbsa, year, sum(deaths) as num_od_deaths 
from mydata.OD_Deaths_XREF
group by cbsa, year;
quit;

/*delete datasets we no longer need to save space*/
proc datasets library=mydata;
	delete od_deaths;
	delete od_deaths_xref;
	delete cbsa_county_xref;
run;

/*get opioid prescribing data by county*/
%macro get_prescribing(year);
%include "/home/me0039/UTICA/opioid-thesis/Scripts/BUILD_OPIOID_PRESCRIBING_COUNTY.sas";
%mend;

%get_prescribing(2012);
%get_prescribing(2013);
%get_prescribing(2014);
%get_prescribing(2015);

/*put all years into one table*/
proc sql;
create table mydata.opioid_prescribing_county as
select * from mydata.opioid_prescribing_county_2012
union
select * from mydata.opioid_prescribing_county_2013
union
select * from mydata.opioid_prescribing_county_2014
union
select * from mydata.opioid_prescribing_county_2015;
quit;

/*remove datasets we no longer need*/
proc datasets library = mydata;
	delete opioid_prescribing_county_2012;
	delete opioid_prescribing_county_2013;
	delete opioid_prescribing_county_2014;
	delete opioid_prescribing_county_2015;
run;

/*get vintage 2017 population data by county (to back into the total number of opioid prescriptions filled)*/
%include "/home/me0039/UTICA/opioid-thesis/Scripts/BUILD_POPULATION.sas";

/*format the county in the population file*/
proc sql;
create table mydata.pop_county_clean as
select popestimate2014, popestimate2015, popestimate2013, popestimate2012, county, state
,(case when state < 10 then put(state, 1.) else put(state, 2.) end) as state_char
from mydata.pop_est;
quit;

proc sql;
create table mydata.pop_county_clean2 as
select popestimate2014, popestimate2015, popestimate2013, popestimate2012,county, state, state_char,
(case when county <10 then compress(state_char||'0'||'0'||put(county, 1.))
	when county between 10 and 99 then compress(state_char||'0'||put(county, 2.))
	else compress(state_char||put(county, 3.)) end) as county_cleaned
from mydata.pop_county_clean;
quit;

data mydata.pop_county_clean3;
set mydata.pop_county_clean2;
county_new = input(county_cleaned, 8.);
run;

proc sql;
create table mydata.opioid_prescribing_w_pop as
select a.*
,(case when a.year = 2012 then b.popestimate2012 
	when a.year=2013 then b.popestimate2013
	when a.year=2014 then b.popestimate2014
	when a.year=2015 then b.popestimate2015 else 0 end) as tot_population
from mydata.opioid_prescribing_county a 
join mydata.pop_county_clean3 b
on a.FIPS_County_Code = b.county_new;
quit;

/*get tot_number of opioid prescriptions*/
/*I'm backing into this number based on the rate per 100 so it isn't 100% exact 
because the rate per hundred is left blank for certain counties with low prescribing
and I'm rounding.  It should be adequate for risk modeling though*/
data mydata.opioid_prescribing_w_pop2;
set mydata.opioid_prescribing_w_pop;
if Prescribing_Rate >0 then tot_opioid_prescriptions = round((tot_population * Prescribing_Rate)/100);
	else tot_opioid_prescriptions = 0;
run;

/*join to the crosswalk to aggregate prescribing to CBSA level*/
proc sql;
create table mydata.prescribing_CBSA_XREF as
select a.*, b.CBSA from 
mydata.opioid_prescribing_w_pop2 a 
join mydata.crosswalk_cleaned b 
on a.FIPS_County_Code = b.fipscounty;
quit;

/*aggregate to CBSA level*/
proc sql;
create table mydata.prescribing_CBSA as
select cbsa, year, sum(tot_opioid_prescriptions) as tot_opioid_prescriptions
from mydata.prescribing_CBSA_XREF
group by CBSA, year;
quit;

/*get rid of the datasets no longer needed*/
proc datasets library=mydata;
	delete opioid_prescribing_county;
	delete opioid_prescribing_w_pop;
	delete opioid_prescribing_w_pop2;
	delete pop_county_clean;
	delete pop_county_clean2;
	delete pop_county_clean3;
	delete pop_est;
	delete prescribing_cbsa_xref;
	delete crosswalk_cleaned;
run;
	
/*merge prescribing, opioid treatment, heroin treatment, and overdose death data*/
proc sql;
create table mydata.rx_treatment_merge as
select distinct a.CBSA, a.tot_opioid_prescriptions, a.year as prescribing_year
,b.year as outcome_year, b.num_admissions
,c.num_od_deaths, d.num_admissions as num_heroin_admissions
from mydata.prescribing_CBSA a
join mydata.teds_cbsa b
on a.CBSA = b.CBSA10 and a.year+1 = b.year
join mydata.od_deaths_cbsa c
on a.cbsa = c.cbsa and a.year+1 = c.year
left join mydata.teds_heroin_cbsa d
on a.cbsa = d.cbsa10 and a.year+1 = d.year;
quit;

data mydata.rx_treatment_merge;
set mydata.rx_treatment_merge;
if num_heroin_admissions = . then num_heroin_admissions = 0;
run;

proc sql;
create table mydata.all_years as
select cbsa, count(distinct(prescribing_year)) as num_years_avail
from mydata.rx_treatment_merge
group by cbsa
having count(distinct(prescribing_year)) =4;
quit; 

proc sql;
create table mydata.rx_treatment_merge2 as
select * from mydata.rx_treatment_merge
where cbsa IN (select distinct cbsa from mydata.all_years);
quit;

proc sql;
create table mydata.rx_treatment_od_priors as
select a.*, b.tot_opioid_prescriptions as prior_year_prescribing
,b.num_heroin_admissions as prior_heroin_admissions
,b.num_admissions as prior_admissions
,b.num_od_deaths as prior_od_deaths
,((a.tot_opioid_prescriptions - b.tot_opioid_prescriptions)/b.tot_opioid_prescriptions) as rx_change_rate
,((a.num_heroin_admissions - b.num_heroin_admissions)/b.num_heroin_admissions) as heroin_ad_change_rate
,((a.num_od_deaths - b.num_od_deaths)/b.num_od_deaths) as od_death_change_rate
,((a.num_admissions-b.num_admissions)/b.num_admissions) as opioid_ad_change_rate
from mydata.rx_treatment_merge2 a 
join mydata.rx_treatment_merge2 b
on a.cbsa = b.cbsa and a.prescribing_year = b.prescribing_year+1;
quit;

/*standardize the data*/
proc standard data=mydata.rx_treatment_od_priors mean=0 std=1 /*replace*/
	print out=mydata.zscore;
run;

data mydata.zscore;
set mydata.zscore;
if rx_change_rate>0 then rx_increase =1;else rx_increase=0;
if heroin_ad_change_rate>0 then heroin_increase=1;else heroin_increase=0;
if od_death_change_rate>0 then od_death_increase = 1;else od_death_increase=0;
if opioid_ad_change_rate>0 then opioid_ad_increase = 1;else opioid_ad_increase=0;
run;

/*quick linear model*/
proc glm data=mydata.zscore plots (unpack)=all;
model num_admissions = prior_year_prescribing prior_heroin_admissions prior_admissions prior_od_deaths
num_od_deaths tot_opioid_prescriptions num_heroin_admissions od_death_change_rate heroin_ad_change_rate
rx_change_rate rx_increase heroin_increase od_death_increase 
/solution clparm;
output residual=res	student=stdres out=results;
run;

proc export data=mydata.rx_treatment_od_priors
	dbms=csv
	outfile="/home/me0039/UTICA/opioid-thesis/CSV-Files/final_dataset.csv"
	replace;
run;

proc surveyselect data=mydata.zscore out=mydata.train1 method=srs samprate=.70
	outall seed=123 noprint;
	samplingunit cbsa;
run;

data mydata.train;
set mydata.train1;
if selected = 1;
run;

data mydata.test;
set mydata.train1;
if selected = 0;
run;

proc logistic descending data =mydata.train; 
model opioid_ad_increase = tot_opioid_prescriptions prior_heroin_admissions prior_admissions prior_od_deaths
od_death_change_rate heroin_ad_change_rate rx_change_rate/
ctable lackfit
selection=stepwise ridging=none maxiter=500 slentry=.1 slstay=.15;
output out=mydata.pred p=phat lower=lcl upper=ucl
             predprob=(individual crossvalidate);
run;

proc npar1way data=mydata.pred edf;
class opioid_ad_increase;
var phat;
run;

data mydata.pred_all;
set mydata.pred;
keep cbsa phat _from_ _into_ opioid_ad_increase;
run;

proc sql;
select 
((a.TP + a.TN)/(a.TP + a.TN + a.FP + a.FN)) as Accuracy,
((a.TN)/(a.TN + a.FP)) as Specificity,
((a.TP)/(a.TP + a.FN)) as Sensitivity
from
(select 
sum(case when _from_ = '1' and _into_ = '1' then 1 else 0 end) as TP,
sum(case when _from_ = '0' and _into_ = '0' then 1 else 0 end) as TN,
sum(case when _from_ = '0' and _into_ = '1' then 1 else 0 end) as FP,
sum(case when _from_ = '1' and _into_ = '0' then 1 else 0 end) as FN
from mydata.pred_all) a;
quit;

proc logistic descending data =mydata.test; 
model opioid_ad_increase = tot_opioid_prescriptions prior_heroin_admissions prior_admissions prior_od_deaths
od_death_change_rate heroin_ad_change_rate rx_change_rate/
ctable lackfit
selection=stepwise ridging=none maxiter=500 slentry=.1 slstay=.15;
output out=mydata.pred p=phat lower=lcl upper=ucl
             predprob=(individual crossvalidate);
run;

proc npar1way data=mydata.pred edf;
class opioid_ad_increase;
var phat;
run;

data mydata.pred_all;
set mydata.pred;
keep cbsa phat _from_ _into_ opioid_ad_increase;
run;

proc sql;
select 
((a.TP + a.TN)/(a.TP + a.TN + a.FP + a.FN)) as Accuracy,
((a.TN)/(a.TN + a.FP)) as Specificity,
((a.TP)/(a.TP + a.FN)) as Sensitivity
from
(select 
sum(case when _from_ = '1' and _into_ = '1' then 1 else 0 end) as TP,
sum(case when _from_ = '0' and _into_ = '0' then 1 else 0 end) as TN,
sum(case when _from_ = '0' and _into_ = '1' then 1 else 0 end) as FP,
sum(case when _from_ = '1' and _into_ = '0' then 1 else 0 end) as FN
from mydata.pred_all) a;
quit;






















