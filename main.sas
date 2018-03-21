/********************************************************
 * Step 1 - change the directories to the correct path  *
 *******************************************************/
/* Pull in the macros */
%include 'c:\path\to\age_standardize.sas' / lrecl=15000;
%include 'c:\path\to\makeAge.sas' / lrecl=15000;
%include 'c:\path\to\words.sas' / lrecl=15000;

/********************************************************
 * Step 2 - import the age group formats 
 * N.B. Change the location of the file below!
 *******************************************************/
data ageGroupFormat;
   length
     fmtname          $ 7
     start            $ 2
     end              $ 4
     label            $ 5
     min                8
     max                8
     default            8
     length             8
     fuzz               8
     prefix           $ 1
     mult               8
     fill             $ 1
     noedit             8
     type             $ 1
     sexcl            $ 1
     eexcl            $ 1
     hlo              $ 1
     decsep           $ 1
     dig3sep          $ 1
     datatype         $ 1
     language         $ 1 ;
   format
     fmtname          $char7.
     start            $char2.
     end              $char4.
     label            $char5.
     min              best1.
     max              best2.
     default          best1.
     length           best1.
     fuzz             best1.
     prefix           $char1.
     mult             best1.
     fill             $char1.
     noedit           best1.
     type             $char1.
     sexcl            $char1.
     eexcl            $char1.
     hlo              $char1.
     decsep           $char1.
     dig3sep          $char1.
     datatype         $char1.
     language         $char1. ;
   informat
     fmtname          $char7.
     start            $char2.
     end              $char4.
     label            $char5.
     min              best1.
     max              best2.
     default          best1.
     length           best1.
     fuzz             best1.
     prefix           $char1.
     mult             best1.
     fill             $char1.
     noedit           best1.
     type             $char1.
     sexcl            $char1.
     eexcl            $char1.
     hlo              $char1.
     decsep           $char1.
     dig3sep          $char1.
     datatype         $char1.
     language         $char1. ;
   /* Change this line to match the file location */
   infile 'c:\path\to\ageGroupFormat.csv'
     lrecl=54
     encoding="utf-8"
     termstr=lf
     missover
     dsd ;
   input
     fmtname          : $char7.
     start            : $char2.
     end              : $char4.
     label            : $char5.
     min              : ?? best1.
     max              : ?? best2.
     default          : ?? best1.
     length           : ?? best1.
    fuzz             : ?? best1.
    prefix           : $char1.
    mult             : ?? best1.
    fill             : $char1.
    noedit           : ?? best1.
    type             : $char1.
    sexcl            : $char1.
    eexcl            : $char1.
    hlo              : $char1.
    decsep           : $char1.
    dig3sep          : $char1.
    datatype         : $char1.
    language         : $char1. ;
run;
/* create the age group format */
proc format cntlin=ageGroupFormat;
run;

/**************************************
 * For example use only
 * remove these lines when you're ready
 **************************************/
*Create sample data set with raw event numbers numbers;
data study_data;
format foo $char5. events 8.;
input foo$ events;
cards;
<1     37
1-4    25
5-9    23
10-14  27
15-19  47
20-24  66
25-29  122
30-34  264
35-39  443
40-44  731
45-49  1022
50-54  1523
55-59  2223
60-64  3108
65-69  3866
70-74  3345
75-79  2719
80-84  1692
85-89  906
90+    121
;
run;
data pop_data;
format population comma12. Age 8.;
input  population age;
cards;
6321 0
9990 1
3179 2
3741 3
5833 4
6757 5
1038 6
3440 7
8621 8
1577 9
5198 10
6458 11
9838 12
1245 13
5425 14
6802 15
0145 16
6524 17
5872 18
9609 19
9650 20
4077 21
4052 22
8775 23
1800 24
1522 25
5052 26
4287 27
5287 28
3693 29
9377 30
2955 31
2922 32
5951 33
6750 34
7914 35
8413 36
8563 37
2150 38
8047 39
2129 40
8010 41
5541 42
3014 43
9224 44
6180 45
1424 46
7834 47
2501 48
1970 49
8958 50
8847 51
6639 52
9913 53
6903 54
1158 55
3948 56
3623 57
1080 58
3281 59
4456 60
4501 61
5624 62
4282 63
1580 64
4130 65
7981 66
6903 67
2908 68
1018 69
7990 70
1638 71
1156 72
1638 73
6400 74
1626 75
1737 76
1672 77
6879 78
1424 79
3436 80
2274 81
8753 82
9386 83
7291 84
7226 85
193 86
151 87
870 88
399 89
115 90
307 91
444 92
184 93
966 94
842 95
62 96
79 97
74 98
60 99
68 100
;
run;
data canada2011;
input pop2011 age;
cards;
376321 0
379990 1
383179 2
383741 3
375833 4
366757 5
361038 6
363440 7
358621 8
360577 9
365198 10
376458 11
379838 12
391245 13
405425 14
426802 15
440145 16
446524 17
455872 18
469609 19
479650 20
484077 21
470052 22
458775 23
461800 24
471522 25
475052 26
474287 27
475287 28
473693 29
479377 30
472955 31
462922 32
455951 33
456750 34
457914 35
458413 36
448563 37
450150 38
458047 39
480129 40
478010 41
475541 42
473014 43
479224 44
506180 45
541424 46
557834 47
562501 48
551970 49
558958 50
548847 51
536639 52
529913 53
516903 54
501158 55
493948 56
473623 57
451080 58
433281 59
424456 60
414501 61
405624 62
404282 63
401580 64
344130 65
317981 66
306903 67
292908 68
271018 69
257990 70
240638 71
230156 72
218638 73
206400 74
200626 75
190737 76
180672 77
176879 78
170424 79
163436 80
152274 81
138753 82
129386 83
117291 84
107226 85
96193 86
85051 87
73870 88
64399 89
54015 90
43307 91
31444 92
24184 93
18966 94
13842 95
9962 96
7109 97
4974 98
3260 99
5268 100
;
run;
/************************
 * END sample data      *
 ***********************/

/* Run the macro */
/* Edit the inputs when your done with the example */
%age_standardize(data=study_data /* datasets containing cases */
                 ,age_var=foo /* age variable */
                 ,data_type=AGGREGATE /* Takes either AGGREGATE or RECORD */
                 ,data_counts=events /* case counts variable */
                 ,denominator=pop_data /* dataset containing denominators */
                 ,denominator_type=AGGREGATE /* same as above */
                 ,denominator_age=agegroup /* age variable */
                 ,denominator_totals=population /* population counts variable */
                 ,standard=canada2011 /* dataset containing standard population */
                 ,geo_var=/* leave blank for total rate. Can use sex var here too */
                 ,where=/* use this to subset the data to a specific age group */
                 )