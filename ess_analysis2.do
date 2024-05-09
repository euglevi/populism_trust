clear
clear frames
set more off
qui cd "/home/eugenio/Dropbox/Hostility/data"

use ess_final.dta, replace

do globals

* ╭───────────────╮
* │ T: BY YEAR       │
* ╰───────────────╯

frame change default

gen i = 0
gen time2 = 0
forvalues year = 2004(2)2018{
    local year1 = `year' + 1
    qui replace time2 = i + 1 if inrange(year,`year',`year1')
    qui replace i = i + 1
}
drop i

ivreg2 poplist_vote $controls (c.std_trust#i.time2 = c.std_pred_trust#i.time2 ) [aw = weight] if sample_populism, cluster(clust_pred)
parmest, saving(years, replace) idstr(vote) label

ivreg2 std_stfdem $controls (c.std_trust#i.time2 = c.std_pred_trust#i.time2 ) [aw = weight] if sample_populism, cluster(clust_pred)
parmest, saving(dem, replace) idstr(dem) label

ivreg2 std_hostility $controls (c.std_trust#i.time2 = c.std_pred_trust#i.time2 ) [aw = weight] if sample_populism, cluster(clust_pred)
parmest, saving(host, replace) idstr(host) label

frame create results
frame change results
clear

use years, replace
append using dem host

keep if ustrrpos(parm,"std_trust")!=0

gen idnum = _n 
replace idnum = idnum - 8 if idstr=="dem"
replace idnum = idnum - 16 if idstr=="host"

label define year 1 "2004-2005" 2 "2006-2007" 3 "2008-2009" 4 "2010-2011" 5 "2012-2013" 6 "2014-2015" 7 "2016-2017" 8 "2018-2019" 
label values idnum year

graph twoway (line estimate idnum if idstr=="vote", yaxis(1)) (line estimate idnum if idstr=="dem", yaxis(2)) (line estimate idnum if idstr=="host", yaxis(2)) (rcap max95 min95 idnum if idstr=="vote", yaxis(1)) (rcap max95 min95 idnum if idstr=="dem", yaxis(2)) (rcap max95 min95 idnum if idstr=="host", yaxis(2)), yline(0, axis(1)) xtitle(Year) graphregion(color(white)) xticks(1(1)8) xlabel(1(2)8, valuelabel) legend(order(1 "Pop. votes" 3 "Satisfaction with democracy" 4 "Hostility towards migrants") position(6) size(small) rows(1)) ytitle(Coefficients associated to opinions, size(small) axis(2)) ytitle(Coefficients associated to voting, size(small) axis(1)) ylabel(-2.1(0.7)0.7, axis(2)) ylabel(-0.18(0.06)0.06, axis(1))
graph export "byyear.png", replace width(1000) 


* ╭───────────────╮
* │ T: BY COUNTRY       │
* ╰───────────────╯

gen g_cntry = 0
replace g_cntry = 1 if inlist(d_cntry,3,6,9,15,16,21,25,27,31)
replace g_cntry = 2 if inlist(d_cntry,5,10,14,20,26)
replace g_cntry = 3 if inlist(d_cntry,2,12,22,23)
replace g_cntry = 4 if inlist(d_cntry,1,4,7,30)
replace g_cntry = 5 if inlist(d_cntry,13,17)
replace g_cntry = 6 if inlist(d_cntry,8,29,11,24)

ivreg2 poplist_vote i.age female i.marital_status immigrant education i.occupation i.employment_status income i.living cntry*_year* (c.std_trust#i.g_cntry = c.std_pred_trust#i.g_cntry) [aw = weight] if sample_populism, cluster(clust_pred )
parmest, saving(cntry, replace) label

frame copy default temp, replace
frame change temp
collapse trust_cntry [aw=weight], by(g_cntry)

frame create results
frame change results
clear

use cntry, replace
keep in 1/6

gen g_cntry = _n

label define country_label 1 "Eastern" 2 "Southern" 3 "Benelux + France" 4 "Central" 5 "Anglo-Saxon" 6 "Scandinavian", modify
label values g_cntry country_label


frlink 1:1 g_cntry, frame(temp)
frget trust_cntry, from(temp)

graph twoway (rcap max95 min95 g_cntry) (scatter estimate g_cntry) (scatter trust_cntry g_cntry), yline(0) xtitle(Group of countries) xlabel(1(1)6, valuelabel) legend(position(6) rows(1) order(2 "Trust coeff" 3 "Av. country trust")) ylabel(-0.3(0.10)0.5) ytitle(Coefficients) graphregion(margin(5 10 5 5))
graph export "bycntry.png", replace width(1000) 
