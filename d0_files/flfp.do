/*******

		***** LABOR FORCE PARTICIPATION DATA *****


4. Between 1994 and 2024, which year had the steepest increase in female labor force
participation relative to the previous year? What factors do you think are driving
this pattern? Support your answers by using the data, referencing major events that
happened around this time period, and/or citing previous studies.

5. How has labor force participation for college-educated and not college-educated women
evolved since 1994? Please provide graphs and/or tables to support your answer.

6. Create an alternative measure of labor force participation that excludes individuals
from the labor force if they are self-employed in their main job (lfp = 0 if self-employed
in main job). Using the new measure, describe how labor force participation for collegeeducated
and not college-educated women has evolved since 1994. Please provide
graphs and/or tables to support your answer.

7. How does our labor market analysis change when we use the new measure? Which
measure do you prefer? Explain.
***********/

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
ssc intall blindschemes, replace
ssc intall brewscheme, replace
ssc install outreg2, replace
ssc install tabout, replace


/***************************************
*EXPLORING THE DATA
***************************************/

// SUMMARY STATISTICS
sum 
outreg2 using summary_output.xlsx, replace excel sum(log) // exporting suummary stats

// FREQUENCY DISTRIBUTION
foreach var in sex education age race wageinc_quantiles income_quantiles {
    tabout `var' using tab_`var'.csv, replace c(freq col)
} // Exporting tables to csv for the vars

// CROSS-TABS
tab age lfp, cell
tab education lfp, cell
tab race lfp, cell
tab wageinc_quantiles lfp, cell

// CROSS-TABS for FEMALE LABOR FORCE PARTICIPATION

gen flfp = 0
replace flfp = 1 if sex == 0 & lfp == 1 & !missing(lfp) & !missing(sex)
drop if missing(sex) & !missing(flfp)
label define flfp 0 "Rest" 1 "Female in Labor Force" // dummy variable to identify observations that are female and in the labor force

tab age flfp, cell
tab education flfp, cell
tab race flfp, cell
tab wageinc_quantiles flfp, cell
/***************************************
* 			Question 1
How has female labor force participation evolved since 1994? Please provide graphs
and/or tables to support your answer.
***************************************/
describe 

/*Note 1: a. There are a total of 6,823,494 observations and 22 variables.
		  b. There are 31, 674 missing observations.
*/

order cpsidp year lfp
sort year cpsidp
tab lfp, m nolab // verifying that its binary
tab sex // 

tabstat lfp if sex==0 [aw=wgt],by(year) // inverse probablity weights, will give accurate standard errors.

preserve
collapse (mean) lfp [aw=wgt]  , by(year sex)
replace lfp = round(lfp*100, 0.01)

twoway line lfp year if sex == 0, ///
    title("Female Labor Force Participation (1994-2024)") ///
    ytitle("Participation Rate") xtitle("Year") ///
    xlabel(1994(5)2024) ///
    lcolor(blue) lwidth(medthick)
graph export "Female_Labor_Force_Participatione.pdf", replace
restore


/***************************************
* 			Question 2
Among women older than 25, which groups (race, age, income percentile, etc.) of
people had the biggest changes in labor force participation since 1994? Please provide
at least three graphs and/or tables to support your answer.
***************************************/

// A. FLFP based on age
tab age, m nolab // age coded 2-7 falls are women over 25

tabstat lfp if (age==2|age==3 | age==4 | age==5 | age==6 | age==7) [aw=wgt],by(year)

preserve
collapse (mean) lfp [aw=wgt] if sex == 0 & age >= 2 , by(year age)
drop if missing(age)
replace lfp = round(lfp*100, 0.01)
graph twoway ///
    (line lfp year if age == 1, color("0 72 137") lwidth(thick)) || ///  IMF Blue
    (line lfp year if age == 2, color("0 147 213") lwidth(thick)) || ///  IMF Cyan
    (line lfp year if age == 3, color("0 118 129") lwidth(thick)) || ///  IMF Teal
    (line lfp year if age == 4, color("232 119 34") lwidth(thick)) || ///  IMF Orange
    (line lfp year if age == 5, color("242 169 0") lwidth(thick)) ///  IMF Yellow
    , ///
    title("Female Labor Force Participation (1994-2024) for Women over 25", size(large) color(black)) ///
    ytitle("Participation Rate (%)", size(medium) color(black)) ///
    xtitle("Year", size(medium) color(black)) ///
    xlabel(1994(5)2024, labsize(small)) ///
    legend(order(1 "Under 25" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") ///
           region(lstyle(none)) pos(6) cols(1) size(small)) ///
    graphregion(color(white)) ///
    plotregion(lstyle(none)) ///
    ylabel(, nogrid) xlabel(, nogrid)
restore
	
graph export "Flfp_Age_Distribution.pdf", replace
restore

// B. FLFP based on race

tab race, m nolab // There are six races

tabstat lfp if (race==1 | race==2|race==3 | race==4 | race==5 | race==6 ) [aw=wgt],by(year race)

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
	ylabel(52(2)66, labsize(small)) ///
    legend(order(1 "White" 2 "Black" 4 "Asian or Pacific Islander" 6 "Hispanic") ///
           region(lstyle(none)) pos(6) cols(1) size(small)) ///
    graphregion(color(white)) ///
    plotregion(lstyle(none)) ///
    ylabel(, nogrid) xlabel(, nogrid)
restore
	
graph export "Flfp_Race_Distribution.pdf", replace
restore

// B. FLFP based on education

tab education, m nolab // There are six races


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
	ylabel(52(2)66, labsize(small)) ///
    legend(order(1 "< HS Diploma" 2 "HS Diploma" 3 "Some college, no degree" 4 "Associate's Degree" 5 "Bachelor's Degree"  6 "Master's or Higher") ///
           region(lstyle(none)) pos(6) cols(1) size(small)) ///
    graphregion(color(white)) ///
    plotregion(lstyle(none)) ///
    ylabel(, nogrid) xlabel(, nogrid)
restore
	
graph export "Flfp_Education_Distribution.pdf", replace
restore


/***************************************
3. Use the data to examine trends among women older than 25 for each of the following
factors from 1994 to 2024:
	(a) Wage and salary income
	(b) Social insurance income
	(c) Education attainment
Based on these trends, what factors could be driving the patterns you found in Questions
1 and 2?
***************************************/

// Creating a dataset with women over 25

* Assuming sex=2 is female, filter for women over 25
keep if sex == 0 & age >= 2 // (3,639,219 observations deleted)
summarize
drop freq_age1 freq_edu1 freq_lfp1 freq_wage1
drop category

tab age, missing // checking for missing values

keep if sex == 0 & inlist(age,2,3, 4, 5, 6, 7) // retaining complete records, 29,253 observations deleted.

save "cps_women_over25.dta", replace // exporting file with females over 25

use "cps_women_over25.dta", replace

preserve
collapse (mean) lfp [aw=wgt], by(year)
replace lfp = round(lfp*100, 0.01)
twoway line lfp year, title("Labor Force Participation of Women over 25, (1994–2024)") ///
ylabel(, format(%9.2g)) xlabel(1994(5)2024) ///
xtitle("Year") ytitle("Mean LFP (%)")
restore


// Trends in Wage and Total Income of Women over 25
preserve
collapse (mean) wageinc_quantiles income_quantiles [aw=wgt], by(year)

twoway ///
    line wageinc_quantiles year, lcolor("0 72 137") lpattern(solid) lwidth(medthick) || ///
    line income_quantiles year, lcolor("232 119 34") lpattern(dash) lwidth(medthick) ///
    title("Income and Wage Quantile Trends of Women over 25 (1994–2024)") ///
    xlabel(1994(5)2024) ///
    ylabel(, format(%9.0g)) ///
    xtitle("Year") ytitle("Mean Income Quantiles") ///
    legend(order(1 "Wage Income " 2 "Total Income "))
restore

// Trends in Social Security Income

summarize ,d
