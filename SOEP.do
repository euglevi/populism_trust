clear all

*set maxvar 32767

*cd "/Users/ramadasimariani/Dropbox/Stata/Hostility"
cd "C:\Users\rmariani2\Dropbox\Stata\Hostility"

**************************************************************
                
	* Trust and Hostility toward Immigration  *     
                                                         
**************************************************************                                                           
**  Country: Germany      YEAR:   1984 - 2019       
**                                                            
**                                                            
**  Input Data Sets: pl.dta , ppathl.dta
**  Output Data Set: soepcore.dta                                   
**                                                                          
**                                                            
**  Description:  Fixed-effect estimation of the effect of trust on hostility towards immigrants
** 
**                                             
**  Author: Rama Dasi Mariani - CEIS and University of Rome "Tor Vergata"                               	
**  Date first written: July, 2020
**  Date this version:  January, 2021
***************************************************************
***************************************************************

/*gl DATA "/Users/ramadasimariani/Dropbox/Stata/Hostility/Data/"
gl TAB "/Users/ramadasimariani/Dropbox/Stata/Hostility/Tables/"

gl BHPS "/Users/ramadasimariani/Dropbox/Stata/Hostility/Data/BHPS/"
gl UKHLS "/Users/ramadasimariani/Dropbox/Stata/Hostility/Data/UKHLS/"
gl SOEP "/Users/ramadasimariani/Dropbox/Stata/Hostility/Data/SOEP/"*/

gl DATA "C:\Users\rmariani2\Dropbox\Stata\Hostility\Data\"
gl TAB "C:\Users\rmariani2\Dropbox\Stata\Hostility\Tables\"

gl BHPS "C:\Users\rmariani2\Dropbox\Stata\Hostility\Data\BHPS\"
gl UKHLS "C:\Users\rmariani2\Dropbox\Stata\Hostility\Data\UKHLS\"
gl SOEP "C:\Users\rmariani2\Dropbox\Stata\Hostility\Data\SOEP\"

*SOEP core
/*
use "${SOEP}cs-transfer/Stata/pl.dta", clear
	
mer 1:1 pid syear using "${SOEP}cs-transfer/Stata/ppathl.dta", nogen keep(3)
mer 1:1 pid syear using "${SOEP}cs-transfer/Stata/pgen.dta", nogen keep(3)

mer m:1 hid syear using "${SOEP}cs-transfer/Stata/hbrutto.dta", nogen keep(3)


	label language EN
	
qui mvdecode _all, mv(-8/-1 = .)

save "${SOEP}soepcore_h.dta", replace

///////////////////////////////////////

use "${SOEP}soepcore.dta", clear

* Keep only private households
keep if pop==1 | pop==2

keep pid syear plh0377_v2 plh0378_v2 plh0379_v2 plh0380_v2 plh0381_v2 plh0382_v2 plh0383_v2 plh0384_v2 plh0385_v2 plh0386_v2 plh0244
keep if !missing(plh0379_v2 plh0378_v2 plh0380_v2 plh0377_v2 plh0381_v2 plh0382_v2 plh0383_v2 plh0384_v2 plh0385_v2 plh0386_v2 plh0244)

drop syear

save "${DATA}locus_pessimism.dta", replace

*/

use "${SOEP}soepcore_h.dta", clear

sort pid syear
	bys pid: replace plh0333=plh0333[_n+1] if syear==2013
	
sort pid syear
	bys pid: replace plh0004=plh0004[_n+2] if syear==2003
	bys pid: replace plh0004=plh0004[_n+1] if syear==2008
	bys pid: replace plh0004=plh0004[_n+1] if syear==2013

sort pid syear
	bys pid: replace plh0041=plh0041[_n+3] if syear==2008
	

* Keep only private households
keep if pop==1 | pop==2

* Keep only waves when question about trust has been asked
keep if syear==2003 | syear==2008 | syear==2013 | syear==2018

	recode plh0192 (1 = 4) (2 = 3) (3 = 2) (4 = 1), g(trust) /*Trust (People Can Genarally Be Trusted)*/
	
	lab var trust "Trustworthiness"
	
	g trust2 = (plh0192==1 | plh0192==2)
		replace trust2=. if missing(plh0192)
		
		lab var trust2 "Trustworthiness (dummy)"
		
		qui sum trust
	g trust3 = (trust - `r(min)') / (`r(max)' - 1) /* Non-standardized variable for summary stats */
	
	lab var trust3 "Trustworthiness"
		
		*qui sum trust
	replace trust = (trust - .4998384) / .2941191 /*The standardization is now done across datasets*/
	
	recode plj0046 (1 = 3) (3 = 1), g(hostility) /*Concern about Immigration*/
		
		lab var hostility "Hostility towards Immigration"
		
		qui sum hostility
	g hostility2 = (hostility - `r(min)') / (`r(max)' - 1) /// Non-standardized variable for summary stats
		
		*qui sum hostility
	replace hostility = (hostility - .5410336) / .3184543 /*The standardization is now done across datasets*/

	replace gebjahr =. if gebjahr<0
	
	g age_c = syear - gebjahr
	recode age_c (0/35 = 1 "under 35") (36/64 = 0 "middle age") (65/max = 2 "over 65"), gen(age)
		lab var age "Class Age"
		lab var age_c "Age"
	
	recode sex (1 = 0 "Male") (2 = 1 "Female") , g(female)
	
	recode pgfamstd (3=0) (1 6/8 =1) (4/5 =2), g(marital_status)
	
		lab var female "Gender (Female)"
		lab var marital_status "Marital Status"
	
	lab def marital 0 "Single" 1 "Married" 2 "Separated"
	lab value marital_status marital
	
	lab values sex dummy
	
	g divorce = (pgfamstd==2 | pgfamstd==4)
		replace divorce=. if missing(pgfamstd)
	
	lab value divorce dummy
		lab var divorce "Separated/Divorced"
	
	g education = (pgpbbil02>0 & pgpbbil02!=.)
		recode education (0 = 1) (1 = 0)
	
	lab value education dummy
		lab var education "Low Education"
	
	g edu_year = pgbilzeit
		lab var edu_year "Years of Completed Education"
	
	recode germborn (1=0) (2=1), g(immigrant)
	
	lab value immigrant dummy
		lab var immigrant "Immigrant"
	
	recode plb0022_h (1/4 = 0 "Employed") (9 = 1 "Unemployed") (5/8 = 2 "Nilf") (10 = 0), g(employment_status)
		lab var employment_status "Employment Status"
		
		
	sort pid syear
	bys pid: g unemployed=1 if plb0022_h==9 & (plb0022_h[_n-1]>=1 & plb0022_h[_n-1]<=4) 
		replace unemployed=0 if unemployed!=1 & !missing(plb0022_h)
		
	lab value unemployed dummy	
		lab var unemployed "Unemployed"
	
qui sum pglabgro, detail

	g income = (pglabgro < `r(mean)')
		replace income=. if missing(pglabgro)

	lab value income dummy
		lab var income "Low Income"

	recode pli0098_h (5 = 0 "No") (1/4 = 1 "Yes"), g(religious)
		lab var religious "Religious"
	
	g occupation = pgisco88
		lab var occupation "Occupation"
		
	replace occupation = occupation/1000
	replace occupation = int(occupation)
	
	recode occupation (0 = 6) (3 = 2) (4/5 = 3) (7/8 = 4) (6 9 = 5) 
	
	*replace occupation = 0 if employment_status != 0
	
	lab def occupation 0 "Unemployed/Nilf" 1 "Managers" 2 "Professionals" 3 "Clerks/Service Workers" 4 "Craftmen/Manufacturing Operators" 5 "Agriculture/Elementary Occupations" 6 "Armed Forces" 
		lab values occupation occupation
		
	*potential channels/mechanisms
	
	recode pli0165 (1 = 5) (2 = 4) (4 = 2) (5 = 1), g(social) /*Social networks (online)*/
	
	qui sum social
	replace social = (social - `r(mean)')/`r(sd)'
	
	lab var social "Use of Social Networks (Online)"

	g weight = phrf
		*expand weight, g(tag)
		
		qui tab syear, g(year)
		qui tab birthregion, g(land)
		
xtset pid syear

	bys pid: g panel = _N

////////////////////////////////////////////////////////////////////////////////

	g AfD2 = (plh0333==27) /* Party */
		replace AfD2 =. if missing(plh0333)
		
	qui su AfD2
	g AfD = (AfD2 - `r(mean)') / `r(sd)'
	
	lab var AfD2 "AfD"
		
		qui sum plh0004 /* Political attitude */
	g right = (plh0004 - `r(mean)') / `r(sd)'
			lab var right "Right/Left"
			
	g not_vote = (plh0333==28)
		replace not_vote=. if missing(plh0333)
			lab var not_vote "Did not vote"
			lab val not_vote "dummy"
	
////////////////////////////////////////////////////////////////////////////////

preserve

drop if missing(trust)

xi, noomit: estpost sum AfD2 hostility2 trust3 i.age female i.marital_status education i.occupation i.employment_status income syear
est store summary

esttab summary using "${TAB}Summary.csv", cells("mean sd min max") ///
title (Summary Statistics of SOEP Data) notes addn(Authors' elaboration) b(.3) label mti("Mean" "St. Deviation" "Min" "Max") nogaps ///
nonumbers collabels(none) modelwidth(15 15 15 15) varwidth(23) ///
replace

restore

////////////////////////////////////////////////////////////////////////////////
	
xi: reg AfD trust i.age i.female i.marital_status i.education i.occupation i.employment_status i.income i.syear i.birthregion, vce(cl pid)

outreg2 using "${TAB}soep.xls", excel dec(3) ctitle("OLS") lab text ///
addn("Federal States and year FE are included but not reported.") ///
replace

xi: xtreg AfD trust i.age i.female i.marital_status i.education i.occupation i.employment_status i.income i.syear i.birthregion, fe vce(cl pid)

outreg2 using "${TAB}soep.xls", excel dec(3) ctitle("Panel FE") lab text ///
addn("Federal States and year FE are included but not reported.") ///
append

	
xi: reg hostility trust i.age i.female i.marital_status i.education i.occupation i.employment_status i.income i.syear i.birthregion, vce(cl pid)

outreg2 using "${TAB}soep.xls", excel dec(3) ctitle("OLS") lab text ///
addn("Federal States and year FE are included but not reported.") ///
append

xi: xtreg hostility trust i.age i.female i.marital_status i.education i.occupation i.employment_status i.income i.syear i.birthregion, fe vce(cl pid)

outreg2 using "${TAB}soep.xls", excel dec(3) ctitle("Panel FE") lab text ///
addn("Federal States and year FE are included but not reported.") ///
append

 *** Mechanisms ***

xi: reg social trust i.age i.female i.marital_status i.education i.occupation i.employment_status i.income i.syear i.birthregion, vce(cl pid)

outreg2 using "${TAB}soep_channel.xls", excel dec(3) ctitle("OLS") lab text ///
addn("Federal States and year FE are included but not reported.") ///
replace

xi: xtreg social trust i.age i.female i.marital_status i.education i.occupation i.employment_status i.income i.syear i.birthregion, fe vce(cl pid)

outreg2 using "${TAB}soep_channel.xls", excel dec(3) ctitle("Panel FE") lab text ///
addn("Federal States and year FE are included but not reported.") ///
append


