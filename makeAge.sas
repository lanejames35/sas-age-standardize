%macro makeAge(in=,out=denominator,population=);
%local in out population;
/* Extract age groupings and convert them to logic statements */
proc sql noprint;
	select distinct &age_var
		  ,case
			when index(&age_var,'-')>1 then cat('between ',tranwrd(&age_var,'-',' and '))
			when index(&age_var,'<')=1 then substr(&age_var,index(&age_var,'<'))
			when index(&age_var,'+')>0 then cat(">=",substr(&age_var,1,index(&age_var,'+')-1))
		   end as logic
	into :groupings separated by " ", :logic separated by "#"
	from &in;
quit;
/* Apply the groupings using the logic above */
%if &population=standard %then %do;
 proc sql noprint;
	create table &out as
	select case
			%do i=1 %to %words(string=&groupings,delimiter=" ");
				%let result=%scan(&groupings,&i,%str( ));
				%let expression=%scan(&logic,&i,#);
				when age &expression then "&result"	
			%end;
			else " "
		  end as agecat,
	 	  sum(pop2011) as population
	 	  from pop.canada2011
	 	  group by agecat
		  ;
 quit;
%end;
%if &population=denominator %then %do;
 proc sql noprint;
	create table &out as
	select case
			%do i=1 %to %words(string=&groupings,delimiter=" ");
				%let result=%scan(&groupings,&i,%str( ));
				%let expression=%scan(&logic,&i,#);
				when age &expression then "&result"	
			%end;
			else " "
		  end as agecat,
		  %if &shortSex=YES %then %do;
			upcase(substr(sex,1,1)) as &geo_var,
		  %end;
		  %else %if &shortSex=NO %then %do;
			upcase(sex) as &geo_var,
		  %end;
		  %else %if &shortSex=NA %then %do;
		  	"TOTAL" as &geo_var,
		  %end;
		  sum(&denominator_totals) as denom
	 	  from &denominator
	 	  group by &geo_var, agecat
		  ;
 quit;
%end;
%mend makeAge;