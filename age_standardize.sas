/*------------------------------------------------------------
Age-standardization Macro

James Lane

23 December 2015

Updated: 27 March 2018
-------------------------------------------------------------*/
%macro age_standardize(data=,
                  data_type=RECORD,
                  data_counts=,
                  geo_var=,
                  age_var=,
                  denominator=,
                  denominator_type=AGGREGATE,
                  denominator_age=,
                  denominator_totals=,
                  standard=pop.canada2011,
                  where=);
/*********************************************************/
/*   Parameter validation                         */
/*********************************************************/
/*parameter validation -- input dataset */
%if %length(&data)=0 %then %do;
   %let _varflag=E;
   %let _varmsg= A dataset name is required for parameter DATA!;
   %goto err_exit;
%end;
%else %do;
   %let _dsid=%sysfunc(exist(&data,data)); /* check that _last_ exists */
   %if &_dsid=0 %then %do;
      %let _varflag=E;
      %let _varmsg= The dataset &data does not exist!;
      %goto err_exit;
   %end;
%end;
/*parameter validation -- denominator dataset */
%if %length(&denominator)=0 %then %do;
   %let _varflag=E;
   %let _varmsg= A dataset name is required for parameter Denominator!;
   %goto err_exit;
%end;
%else %do;
   %let _dsid=%sysfunc(exist(&denominator,data)); /* check that denominator data exists */
   %if &_dsid=0 %then %do;
      %let _varflag=E;
      %let _varmsg= The dataset &denominator does not exist!;
      %goto err_exit;
   %end;
%end;
/* parameter validation -- AGE_VAR */
%if %length(&age_var)=0 %then %do;
   %let _varflag=E;
   %let _varmsg= A value is required for parameter AGE_VAR!;
   %goto err_exit;
%end;
%else %do;
   %let _dsid=%sysfunc(open(&data)); /* DATA parameter from macro definition */
   %if &_dsid=0 %then %do;
      %let _varflag=E;
      %let _varmsg= The dataset &data cannot be opened!;
      %goto err_exit;
   %end;
   %else %do;/* Check that the variable exists */
      %let _varnum=%sysfunc(varnum(&_dsid,&age_var)); 
      %if &_varnum=0 %then %do; /* variable not found -- throw warning */
         %let _varflag=E;
         %let _varmsg= The variable &age_var does not exits in the dataset &data.!;
         %goto err_exit;
      %end;
      %else %let _dsid=%sysfunc(close(&_dsid)); /* variable found -- close dataset */
   %end;
%end;
/* parameter validation -- DENOMINATOR_AGE */
%if %length(&denominator_age)=0 %then %do;
   %let _varflag=E;
   %let _varmsg= A value is required for parameter DENOMINATOR_AGE!;
   %goto err_exit;
%end;
%else %do;
   %let _dsid=%sysfunc(open(&denominator)); /* DATA parameter from macro definition */
   %if &_dsid=0 %then %do;
      %let _varflag=E;
      %let _varmsg= The dataset &data cannot be opened!;
      %goto err_exit;
   %end;
   %else %do;/* Check that the variable exists */
      %let _varnum=%sysfunc(varnum(&_dsid,&denominator_age)); 
      %if &_varnum=0 %then %do; /* variable not found -- throw warning */
         %let _varflag=E;
         %let _varmsg= The variable &denominator_age does not exits in the dataset &denominator.!;
         %goto err_exit;
      %end;
      %else %let _dsid=%sysfunc(close(&_dsid)); /* variable found -- close dataset */
   %end;
%end;

/********************************************************/
/*   STEP 1 -- Set up numerator (case counts)          */
/*      Create temporary tables and insert a dummy code */
/*      for geo_var is none is specified.            */
/********************************************************/
data _numerator;
   set &data;
run;
%if %length(&geo_var.)=0 %then %do;
   %let geo_var=Location;
   data _numerator;
      length &geo_var. $5;
      set &data;
      &geo_var. = "Total";
   run;
   data _denominator;
      length &geo_var. $5;
      set &denominator.;
      &geo_var. = "Total";
   run;
%end;

%if %upcase(&data_type)=RECORD %then %do;
   proc sql;
      create table numerator as
      select distinct upcase(&geo_var.) as &geo_var
                  ,put(&age_var.,cubeage.) as agecat
                  ,count(*) as count
      from _numerator
   %if %length(&where.)>0 %then %do;
      where &where.
   %end;
      group by &geo_var.
            ,agecat
      order by &geo_var.
            ,agecat
      ;
   quit;
%end;

%else %if %upcase(&data_type)=AGGREGATE %then %do;
   /* parameter validation -- DATA_COUNTS */
   %if %length(&data_counts)=0 %then %do;
      %let _varflag=E;
      %let _varmsg= A value is required for parameter DATA_COUNTS!;
      %goto err_exit;
   %end;
   %else %do;
      %let _dsid=%sysfunc(open(&data)); /* DATA parameter from macro definition */
      %if &_dsid=0 %then %do;
         %let _varflag=E;
         %let _varmsg= The dataset &data cannot be opened!;
         %goto err_exit;
      %end;
      %else %do;/* Check that the variable exists */
         %let _varnum=%sysfunc(varnum(&_dsid,&data_counts)); 
         %if &_varnum=0 %then %do; /* variable not found -- throw warning */
            %let _varflag=E;
            %let _varmsg= The variable &data_counts does not exits in the dataset &data.!;
            %goto err_exit;
         %end;
         %else %let _dsid=%sysfunc(close(&_dsid)); /* variable found -- close dataset */
      %end;
   %end;

   proc sql;
      create table numerator as
      select distinct upcase(&geo_var.) as &geo_var
                     ,&age_var. as agecat
                   ,sum(&data_counts.) as count
      from _numerator
   %if %length(&where.)>0 %then %do;
      where &where.
   %end;
      group by &geo_var.
            ,agecat
      order by &geo_var.
            ,agecat
      ;
   quit;
   /* Check if we need to consider sex when forming the denominators
    * if so, check the format of the variable (i.e. single character - M F
    * versus full word - male female)
    */
   data _null_;
      set numerator;
      regex=prxparse('/(SEX|GENDER)/');
      if prxmatch(regex,upcase("&geo_var")) then do;
         if lengthn(&geo_var)=1 then shortSex="YES";
         else shortSex="NO";
      end;
      else shortSex="NA";
      call symput("shortSex",shortSex);
      stop;
   run;
%end;
/********************************************************/
/*   STEP 2 -- Set up denominator (population counts)   */
/********************************************************/
/*if aggregate population data*/
%if %upcase(&denominator_type)=AGGREGATE %then %do;
   /* parameter validation -- DENOMINATOR_TOTALS */
   %if %length(&denominator_totals)=0 %then %do;
      %let _varflag=E;
      %let _varmsg= A value is required for parameter DENOMINATOR_TOTALS!;
      %goto err_exit;
   %end;
   %else %do;
      %let _dsid=%sysfunc(open(&denominator)); /* DATA parameter from macro definition */
      %if &_dsid=0 %then %do;
         %let _varflag=E;
         %let _varmsg= The dataset &data cannot be opened!;
         %goto err_exit;
      %end;
      %else %do;/* Check that the variable exists */
         %let _varnum=%sysfunc(varnum(&_dsid,&denominator_totals)); 
         %if &_varnum=0 %then %do; /* variable not found -- throw warning */
            %let _varflag=E;
            %let _varmsg= The variable &denominator_totals does not exits in the dataset &data.!;
            %goto err_exit;
         %end;
         %else %let _dsid=%sysfunc(close(&_dsid)); /* variable found -- close dataset */
      %end;
   %end;
   /* check if age groups need to be formed */
   %if %upcase(&data_type)=AGGREGATE %then %do;
      %makeAge(in=&data,out=denominator,population=denominator)
   %end;
   %else %do;
      data denominator;
         set _denominator;
      run;
      proc sql;
         create table denominator as
         select distinct upcase(&geo_var) as &geo_var
                      ,put(&denominator_age,cubeage.) as agecat
                     ,sum(&denominator_totals) as denom
         from _denominator
      %if %length(&where)>0 %then %do;
         where &where
      %end;
         group by &geo_var
               ,agecat
         order by &geo_var
               ,agecat
         ;
      quit;
   %end;
%end;
/*if record level population data*/
%else %if %upcase(&denominator_type)=RECORD %then %do;
   data denominator;
      set _denominator;
   run;
   proc sql;
      create table denominator as
      select distinct upcase(&geo_var) &geo_var
                  ,put(&denominator_age,cubeage.) as agecat
                  ,count(*) as denom

      from _denominator
   %if %length(&where)>0 %then %do;
      where &where
   %end;
      group by &geo_var
            ,agecat
      order by &geo_var
            ,agecat
      ;
   quit;   
%end;
/********************************************************/
/*   STEP 3 -- Merge numerator (case counts) and */
/*           denominator (population counts)*/
/********************************************************/
proc sort data=numerator;
   by &geo_var agecat;
run;

proc sort data=denominator;
   by &geo_var agecat;
run;

data step3;
   drop count;

   merge numerator(keep=&geo_var agecat count in=a) denominator(keep=&geo_var agecat denom in=b);
   by &geo_var agecat;

   numer=count;
   /* For age groups with no cases, set the numerator to zero */
   if denom>0 then
      logden=log(denom);
   else
      logden=.;
   if numer=. and denom=>0 then
      numer=0;
   if denom>=0 then
      output;
run;

proc sort data=step3;
   by agecat;
run;
/******************************************************
   STEP 4 -- Connect to population file for age
           standardization
******************************************************/

/*************************************************************
   CREATE DATASET WITH STANDARD POPULATION 
   FOR AGE STANDARDIZATION USING THE SAME AGE GROUPS
*************************************************************/
%if %upcase(&data_type)=AGGREGATE %then %do;
   %makeAge(in=&data,out=stdrd2,population=standard)

   proc sql noprint;
      select sum(population)
      into :total_std
      from stdrd2
      ;
   quit;
%end;
%else %do;
   data stdrd;
      set &standard;
      agecat = put(age,cubeage.);
   run;
   proc sql noprint;
   create table stdrd2 as
      select agecat
           ,sum(pop2011) as population
      from stdrd
   %if %length(&where)>0 %then %do;
      where &where 
   %end;
      group by agecat;

   select sum(population)
   into :total_std
   from stdrd2
   ;
quit;
%end;

/*Merge incidence/prevalence rates with standard population by age group*/
data step4a;
   merge step3(in=ina) stdrd2(in=inb);
   by agecat;
   if ina and inb;   

   w_i=population/&total_std;

   ir_i=numer/denom;

   varpy_i=numer/(denom**2);

run;
proc sort data=Step4a;
   by &geo_var;
run ;

/***********************************
 Calcuate the age-standardize rate
***********************************/
data Step4b;
   set Step4a;
   by &geo_var;

   /************************************
   IRW=weighted incidence rate
   VARPY=part of person-time variance
   VARPYW=weighted person-time variance
   SUMWI=sum of weights
   CRDEN=crude denominator
   WMAX=maximum weight (for gamma CI)
   ************************************/
   retain IRW VARPY VARPYW SUMWI WMAX CRNUM CRDEN;

   if first.&geo_var then
      do;
         IRW=0;
         VARPYW=0;
         VARPY=0;
         SUMWI=0;
         CRNUM=0;
         CRDEN=0;
      end;

   IRW=IRW + (W_I*IR_I);
   SUMWI = SUMWI + W_I;
   VARPY=VARPY + ((W_I**2)*VARPY_I);
   CRNUM=CRNUM+numer;
   CRDEN=CRDEN+denom;

   if last.&geo_var then
      do;
         /********************************
            Crude incidence rate
         *******************************/
         CIR=CRNUM/CRDEN;

         VARPYW=VARPY/(SUMWI**2);

         /********************************
            95% CONFIDENCE LIMITS
         ********************************/
         LO95 = IRW - (1.96*SQRT(VARPYW));
         HI95 = IRW + (1.96*SQRT(VARPYW));
         output;
      end;

   label CIR='Crude Incidence Rate'
        IRW='Age Standardized Incidence Rate'
        LO95='Lower 95% CI (Normal Approx.)'
        HI95='Upper 95% CI (Normal Approx.)'
        ;
run;
proc print noobs label;
   var &geo_var CIR IRW LO95 HI95;
run;
%goto clean_exit;

%err_exit:
   /* Print the errors to the log */
   %put ====================================================;
   %put;
   %put The following error occured while running the macro:;
   %put &_varmsg;
   %put;
   %put Please review input and try again.;
   %put;
   %put The macro will stop execution.;
   %put ====================================================;
   /* When an error is encountered, stop execution of program */
   %abort;

%clean_exit: 
   proc datasets nodetails nolist lib=work;
      delete numerator;
      delete denominator;
   run;

%mend age_standardize;
