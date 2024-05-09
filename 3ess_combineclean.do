clear
clear frames
set more off
qui cd "/home/eugenio/Dropbox/Hostility/data"

******** merging trust from clusters **************

qui use ess_clusters, replace
qui merge m:1 health_index education using wvs_clusters_healthedu, nolabel
qui drop _merge

merge m:1 health_index education using wvs_clusters_coef_healthedu, nolabel
drop _merge

qui merge m:1 happy_index education using wvs_clusters_happyedu, nolabel
qui drop _merge

merge m:1 happy_index education using wvs_clusters_coef_happyedu, nolabel
drop _merge

merge m:1 d_cntry using trust_2000.dta, keepusing(*_2000)
drop if _merge==2
drop _merge

********labelling variables***************

label variable trust "Trust"
label variable female "Female"
label variable marital_status "Marital status"
label define ms 1 "Married" 2 "Divorced"
label values marital_status ms
label variable education "High education"
label variable immigrant "Immigrant"
label variable age "Age"
label variable occupation "Occupation"
label define occ 0 "Managers" 2 "Professionals" 3 "Technicians" 4 "Non-manual workers" 5 "Agricultural workers" 6 "Industry workers" 7 "Elementary occupations" 1 "Armed forces" 8 "Other or not working", replace
recode occupation (1 = 0) (0 = 1)
label values occupation occ
label variable employment_status "Employment Status"
label define empl 0 "Working" 1 "Nilf" 2 "Unemployed", replace
label values employment_status empl
label variable income "Low income"
label variable living "Type of habitat"
label define habitat 1 "Big city" 2 "Small city" 3 "Rural", replace
label values living habitat
label define health_label 1 "Health very good" 2 "Health good" 3 "Health fair" 4 "Health poor" 5 "Health very poor"
label values health_index health_label
label define happy_label 1 "Very happy" 2 "Quite happy" 3 "Not very happy" 4 "Not at all happy"
label values happy_index happy_label
label variable happy_index "Happiness"

******building clusters********

gen sample = !missing(hostility, trust, age, female, marital_status, immigrant, education, occupation, employment_status, income, living, d_cntry, year, weight)
qui keep if sample

qui levelsof d_cntry, local(countries)
qui levelsof year, local(years)

foreach country of local countries {
    foreach year of local years {
        gen cntry`country'_year`year' = d_cntry==`country'&year==`year'
        qui sum cntry`country'_year`year'
        if r(max)==0 {
            drop cntry`country'_year`year' 
        }
    }
}


******** standardize variables ******************

recast float trust
recast float hostility
recast float stfdem
format trust %9.0g
format hostility %9.0g
format stfdem %9.0g

replace trust = trust/10
replace hostility = (hostility-1)/3
replace stfdem = (stfdem - 1)/10

gen std_hostility = (hostility-.5410336)/.3184543

label variable std_hostility "Hostility toward migration"

gen std_trust = (trust - .4998384)/.2941191

label variable std_trust "Trust"

gen std_stfdem = (stfdem - .4986601)/.2644387

foreach var of varlist trst* {
	sum `var'
	gen std_`var' = (`var' - r(mean))/r(sd)
	_crcslbl std_`var' `var'
    }

label variable std_stfdem "Bad quality of democracy"

******** level of trust at country level ************

bys d_cntry: egen trust_cntry = mean(std_trust)
label variable trust_cntry "Trust at country level"

******** sample populist vote **************

gen sample_populism = !inlist(d_cntry, 18, 19, 28, 32, 33)

gen farleftpop_vote = poplist_vote&farleft_vote
gen farrightpop_vote = poplist_vote&farright_vote

********* saving the dataset ***** 

replace sample_populism = 0 if missing(std_poplist_vote,std_trust,age,female,marital_status,immigrant,education,occupation,employment_status,income,living,std_farleftpop_vote,std_farrightpop_vote,std_stfdem,std_hostility,coeff_happyedu,coeff_healthedu,weight)

foreach var of varlist cntry*_year* std_trst* {
	qui replace sample_populism = 0 if `var'==.
    }

estimates use lasso_interpersonal
predict std_pred_trust, xb postselection

egen clust_pred = group(std_pred_trust)

pca std_trst* 
predict inst_trst, score
sum inst_trst
gen std_inst_trst = (inst_trst - r(mean))/r(sd)

keep if sample_populism

foreach var of varlist cntry*_year* {
    qui sum `var'
    if r(mean)==0 {
	drop `var'
    }
}

save ess_final.dta, replace

