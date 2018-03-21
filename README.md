# Direct age-standaridized rates with SAS
## What is it?
* A collection of SAS macros that perform direct age-standardization of rates.
* A useful tool for epidemiologists, researchers, and students.
* A collaborative project!
## How does it work?
Data is input from three sources: 1) cases, 2) population demoninators, and 3) apopulation standard. These datasets must all contain an age variable which is used to merge the datasets. Once merged, the age-weighted rate of the event is calculated using the method described by the Association of Public Health Epidemiologiest in Ontario (APHEO) in [this document](http://http://core.apheo.ca/resources/indicators/Standardization%20report_NamBains_FINALMarch16.pdf) (.pdf).
## Setup
The programs in this repository require SAS, so you should consider [downloading SAS](https://www.sas.com/en_us/software/university-edition.html) before attempting to use them.
To download the programs, simply clone this repositrory:

```
git clone https://github.com/lanejames35/sas-age-standardize.git
cd sas-age-standardize
```

Alternatively, you can download the program in a `.zip` file.
