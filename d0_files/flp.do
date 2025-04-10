/*******************************************
*******************************************
Labor Force Participation Study
*******************************************
*******************************************/


/* Importing data
*******************************************/
cd "/Users/anjanaraja/Desktop/STATA_for_RA/Module_1"
use "/Users/anjanaraja/Desktop/STATA_for_RA/Stata_Project/data_raw/cps_women_lfp.dta"


/*Inspecting data
*******************************************/
browse
summarize
describe

* Note 1: The raw data contains over 6,000,000 observations and 22 variables
		  * There are no string variables in the data
		  

/* 1. How has female labor force participation evolved since 1994? Please provide graphs
and/or tables to support your answer.
*******************************************/

tab year lfp

*Ans: From 1994 to 2024, about 33.33% were not in the labor force, 66.67% were in the labor force

lowess year over(lfp)
