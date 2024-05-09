clear
clear frames
set more off
qui cd "/home/eugenio/Dropbox/Hostility/data"

use ess_final.dta, replace

do globals

* ╭───────────────╮
* │ T: COUNTRY-LEVEL │
* ╰───────────────╯

gen sample_populism_cntry = sample_populism&std_trustgss_2000!=.

** populist vote at country level

reg poplist_vote trust_cntry $controls_cntry [aw = weight] if sample_populism_cntry
outreg2 using ESS_cntry.xls, label excel replace addtext(Country*Year FE, yes) drop(cntry*_year*)

reg farleftpop_vote trust_cntry $controls_cntry [aw = weight] if sample_populism_cntry
outreg2 using ESS_cntry.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

reg farrightpop_vote trust_cntry $controls_cntry [aw = weight] if sample_populism_cntry
outreg2 using ESS_cntry.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

reg poplist_vote std_trustgss_2000 $controls_cntry [aw = weight] if sample_populism_cntry
outreg2 using ESS_cntry.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

reg farleftpop_vote std_trustgss_2000 $controls_cntry [aw = weight] if sample_populism_cntry
outreg2 using ESS_cntry.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

reg farrightpop_vote std_trustgss_2000 $controls_cntry [aw = weight] if sample_populism_cntry
outreg2 using ESS_cntry.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

*** T: Graph on Algan and Cahuc

frame copy default graph, replace
frame change graph

collapse trust_cntry std_trustgss_2000, by(d_cntry)
drop if std_trustgss_2000==.

gen id = _n
labmask id, values(d_cntry) decode

label variable id "Country"
label variable trust_cntry "Std Individual Trust"
label variable std_trustgss_2000 "Std Inherited Trust"

gen distance = trust_cntry - std_trustgss_2000

graph twoway (scatter trust_cntry id) (scatter std_trustgss_2000 id), yline(0) xlabel(1(1)19, valuelabel) legend(position(1) ring(0))
graph export "algan_comparison.png", width(1000) replace

