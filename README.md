# Direct age-standardized rates with SAS
## What is it?
* A collection of SAS macros that perform direct age-standardization of rates.
* A useful tool for epidemiologists, researchers, and students.
* A collaborative project!
## How does it work?
Data is input from three sources: 1) cases, 2) population demoninators, and 3) apopulation standard. These datasets must all contain an age variable which is used to merge the datasets. Once merged, the age-weighted rate of the event is calculated using the method described by the Association of Public Health Epidemiologists in Ontario (APHEO) in [this document](http://http://core.apheo.ca/resources/indicators/Standardization%20report_NamBains_FINALMarch16.pdf) (.pdf).
## Setup
### Download the programs
The programs in this repository require SAS, so you should consider [downloading SAS](https://www.sas.com/en_us/software/university-edition.html) before attempting to use them.
To download the programs, simply clone this repositrory:

```
git clone https://github.com/lanejames35/sas-age-standardize.git
cd sas-age-standardize
```

Alternatively, you can download the programs in a `.zip` file.

### Define the key inputs
The `main.sas` program is the script you will need to customize and run to get age-standardized rates. There are three places that need input to function properly:
   1. Each `%include` statement should specifiy the path to the respective `.sas` file on your machine.
   2. The `infile` statment should specify the path to the `ageGroupFormat.csv` file on your machine.
   3. The parameters of the `%age_standardize` macro will need to be adjusted to match the set-up of your datasets. Here, use the example to examine how the macro parameters macth up with the example datasets.

### Run the program
Once all the inputs are set, run `main.sas` as usual with `F4` or the `Submit` button.
## Feedback
All bugs, feature requests, pull request, complaints, feedback, etc. are welcome. Please [create an issue](https://github.com/lanejames35/sas-age-standardize/issues).
If you'd prefer a less formal approach, send me an email. My contact information is found on [my profile page](https://github.com/lanejames35).

## Next steps
Contributions to convert this to Stata and/or R would be greatly appreciated!

## License
See [the license file](https://github.com/lanejames35/sas-age-standardize/blob/master/LICENSE).

SAS and all other SAS Institute Inc. product or service names are registered trademarks or trademarks of SAS Institute Inc. in the USA and other countries.
