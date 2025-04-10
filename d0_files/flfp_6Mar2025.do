
/*****************************************************
* 			Retaining Variables relevant for Analysis
1. The study focuses on female labor force participation
2. The variables under consideration are:
	a. education
	b. age (women over 25)
	c. race
	d. wage income
	e. total income
	f. social security income
	g. college
	h. employed
	i. self-employed
	j. year

*****************************************************/

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
**************************************
* 			Loading & Subsetting Data


* Estimate labor force Participation Rate
* Retain data on women over 25  
*		a. There are 3,184,275 women over the age of 25.
*		b. 59.82% of the women were in the labor force.
*		c. 1,904,807 were in the labor force
**************************************

cd "/Users/anjanaraja/Desktop/STATA_for_RA/Stata_Project/data_raw" // changing directory
use "cps_women_lfp.dta" // Loading .dta file

list _all in 1/10 // view first 10 obs in data

keep if sex==0 & age>=2 // Retaining observations of women over 25

**********************************************************
//PART 1: Labor Force Participation of Women over 25
**********************************************************
tab lfp, m // Labor Force %

gen flfp_25plus=0
replace flfp_25plus=1 if sex==0 & age>=2 & lfp == 1 // defining variable for women in labor force over 25

gen women_not_in_lfp_25plus=0
replace women_not_in_lfp_25plus=1 if sex==0 & age>=2 & lfp == 0 // defining variable for women in Not labor force over 25

//Plot of Women in and Not in labor Force
**********************************************************
preserve
* Compute total number of women (25+)
gen women_total_25plus = flfp_25plus + women_not_in_lfp_25plus

* Avoid division by zero
replace women_total_25plus = . if women_total_25plus == 0

* Calculate percentage of women in and not in the labor force
gen pct_flfp_25plus = (flfp_25plus / women_total_25plus) * 100
gen pct_women_not_in_lfp_25plus = (women_not_in_lfp_25plus / women_total_25plus) * 100

collapse (mean) pct_flfp_25plus pct_women_not_in_lfp_25plus [aw=wgt], by(year)


twoway ///
    (line pct_flfp_25plus year, color("0 72 137") lwidth(medthick)) || ///  IMF Blue (Women in Labor Force)
    (line pct_women_not_in_lfp_25plus year, color("232 119 34") lwidth(medthick)) ///  IMF Orange (Women Not in Labor Force)
    , ///
    title("Female Labor Force Participation (1994-2024) for Women over 25", size(medium) color(black)) ///
    ytitle("Participation Rate (%)", size(medium) color(black)) ///
    xtitle("Year", size(medium) color(black)) ///
    xlabel(1994(2)2024, labsize(small)) ///
    ylabel(40(5)60, labsize(small)) ///
    legend(order(1 "In Labor Force (%)" 2 "Not in Labor Force (%)") ///
           region(lstyle(none)) pos(6) cols(1) size(small)) ///
    graphregion(color(white)) ///
    plotregion(lstyle(none)) ///
    ylabel(, nogrid) xlabel(, nogrid)

restore

**********************************************************
//PART 2: Education-Levels of Women in labor force
**********************************************************

tab education lfp,m row. // Education-levels of women in lfp

preserve
collapse (mean) lfp [aw=wgt] if sex == 0 & age >= 2 , by(year education)
drop if missing(education)
sort education year
replace lfp = round(lfp*100, 0.01)
graph twoway ///
    (line lfp year if education == 1, color("0 72 137") lwidth(medthick)) || ///  IMF Blue
    (line lfp year if education == 2, color("0 147 213") lwidth(medthick)) || ///  IMF Cyan
    (line lfp year if education == 3, color("0 118 129") lwidth(medthick)) || ///  IMF Teal
    (line lfp year if education == 4, color("232 119 34") lwidth(medthick)) || ///  IMF Orange
    (line lfp year if education == 5, color("242 169 0") lwidth(medthick)) ///  IMF Yellow
	(line lfp year if education == 5, color("134 99 166") lwidth(medthick)) ///  IMF Purple
    , ///
    title("Female Labor Force Participation (1994-2024) for Women over 25 by Education", size(medium) color(black)) ///
    ytitle("Participation Rate (%)", size(medium) color(black)) ///
    xtitle("Year", size(medium) color(black)) ///
    xlabel(1994(2)2024, labsize(small)) ///
	ylabel(25(5)66, labsize(small)) ///
    legend(order(1 "< HS Diploma" 2 "HS Diploma" 3 "Some college, no degree" 4 "Associate's Degree" 5 "Bachelor's Degree"  6 "Master's or Higher") ///
           region(lstyle(none)) pos(3) cols(1) size(small)) ///
    graphregion(color(white)) ///
    plotregion(lstyle(none)) ///
    ylabel(, nogrid) xlabel(, nogrid)
restore
	
graph export "Flfp_Education_Distribution.pdf", replace
restore

**********************************************************
//PART 3: Racial Differences in Labor Force Participation Rates
**********************************************************

tab race lfp, m row

preserve
collapse (mean) lfp [aw=wgt] if sex == 0 & age >= 2 , by(year race)
drop if missing(race)
sort race year
replace lfp = round(lfp*100, 0.01)
graph twoway ///
    (line lfp year if race == 1, color("0 72 137") lwidth(medthick)) || ///  IMF Blue
    (line lfp year if race == 2, color("0 147 213") lwidth(medthick)) || ///  IMF Cyan
    (line lfp year if race == 4, color("232 119 34") lwidth(medthick)) || ///  IMF Orange
    (line lfp year if race == 6, color("242 169 0") lwidth(medthick)) ///  IMF Yellow
    , ///
    title("Female Labor Force Participation (1994-2024) for Women over 25 by Race", size(medium) color(black)) ///
    ytitle("Participation Rate (%)", size(medium) color(black)) ///
    xtitle("Year", size(medium) color(black)) ///
    xlabel(1994(2)2024, labsize(small)) ///
	ylabel(52(2)80, labsize(small)) ///
    legend(order(1 "White" 2 "Black" 4 "Asian or Pacific Islander" 6 "Hispanic") ///
           region(lstyle(none)) pos(6) cols(1) size(small)) ///
    graphregion(color(white)) ///
    plotregion(lstyle(none)) ///
    ylabel(, nogrid) xlabel(, nogrid)
restore
	
**********************************************************
//PART 4: Income Differences in Labor Force Participation Rates
**********************************************************


