cd "/Users/anjanaraja/Desktop/STATA_for_RA/Stata_Project/data_raw" // changing directory

use "cps_women_lfp.dta" // Loading .dta file

**************************************
* 			LOADING PACKAGES
**************************************
ssc install elabel, replace
ssc install tabstatmat, replace
ssc intall palettes, replace
ssc install colrspace, replace
ssc install schemepack, replace
ssc install blindschemes, replace
ssc intall brewscheme, replace
ssc install outreg2, replace
ssc install tabout, replace

/***************************************************************************
*ANALYZING FEMALE LABOR FORCE PARTICIPATION OVER 25 YEARS OF AGE
***************************************************************************/


// Exploring Dataset
describe // checking variable types
summarize // checking summary statistics

count if missing(cpsidp) // There are no missing ids

tab sex age, m // Studying distribution of Gender and Age

tab sex lfp,m // Studying distribution of Gender and Labor force Participation 

tab education flfp, m // Studying distribution of Gender and Labor force Participation 

tab race flfp,m //distribution of Gender and Labor force Participation 

tab sex age, summarize(lfp) m // Studying distribution of Gender, Labor force Participation and Age combined

/*
Notes:
1.  Observations:     6,823,494                  
    Variables:            22
2. CPS data allows for same individual to be surveyed in different months of the year, Need not check for duplicates in cpsidp
*/

//Variable People over 25

gen age_25plus =0
replace age_25plus=1 if (age >=2 )  

//Variable Women over 25

gen women_25plus=0
replace women_25plus=1 if sex==0 & age >=2 & !missing(age) & !missing(sex) 
label define women_25plus 0 " Women under 25" 1 "Women 25+" 



//Variable Women over 25 in the labor force

gen flfp_25plus=0
replace flfp=1 if lfp==1 & women_25plus==1  & !missing(lfp) & !missing(women_25plus)
 
// Variable for Women Over 25 Not in labor Force
gen Not_flfp_25plus=0
replace Not_flfp=1 if lfp==0 & sex==0 & age >=2  & !missing(lfp) & !missing(age) & !missing(sex) 
 

// Tabulations:


tab race lfp if sex==0 & age>=2, m row
tab education lfp if sex==0 & age>=2, m row
tab wageinc_quantiles lfp if sex==0 & age>=2, m row

/*
Notes:
1.  Women_25plus=1 coded for women over 24
2.	3,155,022 women over the age of 25, no missing values.
3.	There are 1901933 women over 25 in the labor force.
4. There are 1,250,647 women over 25 not in the labor force
tab women_25plus,m // Tabulation of Women over 25


tab flfp, m // Tabulation of Women over 25 in the Labor Force Cross-Check: tab lfp if women_25plus==1, m
tab age flfp, m
tab education flfp// Tabluation of Education Levels and Women
tab wageinc_quantiles flfp // Tabluation of Wage Income Levels and Women
tab income_quantiles flfp // Tabluation of Total Income Levels and Women
tab Not_flfp // Tabluation of Labor Force Participation if age greater than 25 and female
tab education if Not_flfp==1 // Education of Women Not in Labor Force
*/

keep if sex==0 & age>=2 // Retain observations with Women over 25


collapse (mean) lfp incss [aw=wgt], by(year sex education race wageinc_quantiles income_quantiles age)

replace lfp = round(lfp * 100, 0.01)
