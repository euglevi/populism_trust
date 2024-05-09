clear
clear frames

set more off

cd "/home/eugenio/Dropbox/Hostility/data"

use WVS_Longitudinal_1981_2016_stata_v20180912.dta, replace

rename S020 year

drop if year>=2000

***** build variables for clustering *******

recode X001 (1 = 0 "male") (2 = 1 "female") (-5/-1 = .), gen(female)
recode X003 (0/35 = 1 "under 35") (36/64 = 0 "middle age") (65/max = 2 "over 65") (-5/-1 = .), gen(age)
recode X007 (1 2 5 = 1 "married") (3 4 = 2 "divorced") (6 = 0 "single") (-5/-1 = .), gen(marital_status)
recode A009 (1 2 = 1 "good") (3 4 5 = 0 "not good") (-5/-1 = .), gen(health)
recode A009 (-5/-1 = .), gen(health_index) 

recode A008 (-5/-1 = .), gen(happy_index)

recode X028 (1 2 3 = 0 "working") (7 = 2 "unemployed") (4 5 6 8 = 1 "nilf") (-5/-1 = .), gen(employment_status)
replace X047 = floor((10)*runiform() + 1) if inrange(X047, -5, -1)
recode X047 (1/5 = 1 "low income") (6/10 = 0 "high income"), gen(income)
recode X023 (1/18 = 0 "low education") (19/max = 1 "high education") (-5/-1 = .), gen(education)
replace education = 0 if inrange(X023R, 1, 7)
replace education = 1 if inrange(X023R, 8, 10)
replace education = 0 if inrange(X025, 1, 5)
replace education = 1 if X025>=6
recode X036 (13 16 = 1 "managers") (21 = 2 "professionals") (23 22 = 3 "technicians and associate professionals") (24 25 = 4 "non-manual workers") (41 = 5 "skilled agricultural, forestry and fishery workers") (31 32 33 = 6 "skilled and semi-skilled industry workers") (34 42 = 7 "elementary occupations") (51 = 0 "armed forces occupations") (-5/-1 61 81 = 8 "other or not working"), gen(occupation)
recode occupation (1 2 3  = 0 "high skill") (0 4 5 6 7 8 = 1 "low skill") (-5/-1 = .), gen(job)
recode X050 (1 = 1 "big city") (2 = 2 "small city or town") (3 = 3 "rural") (-5/-1 = .), gen(living)
replace living = 1 if X049>=7
replace living = 2 if inrange(X049, 3, 6)
replace living = 3 if inrange(X049, 1, 2)
replace living = 1 if X049CS==392001|X049CS==392001|X049CS==410004|X049CS==410005|inlist(X049CS, 31001, 31002, 32001, 32003, 32004, 51001, 51002, 51003, 233003, 233004, 268003, 268004, 268005, 554006, 554007)|X049CS>=604007
replace living = 2 if X049CS==392003|X049CS==392004|X049CS==410003|inlist(X049CS, 31004, 32005, 51004, 233002, 268002, 554004, 554005, 554003)
replace living = 3 if X049CS==392005|X049CS==410001|X049CS==410002|inlist(X049CS, 31005, 51005, 233001, 268001, 554001, 554002, 554003)

rename S017 weight
rename A165 trust
recode trust (-5/-1 = .)
revrs trust, replace

rename S003 d_cntry

drop if inlist(d_cntry, 8, 36, 100, 101, 191, 203, 233, 246, 276, 348, 428, 440, 554, 578, 616, 642, 688, 703, 705, 724, 752, 756, 807, 826, 840, 914)
drop if inlist(d_cntry, 32, 76, 152, 170, 214, 222, 484, 604, 630, 858, 862) 
replace trust = trust - 1
gen std_trust = (trust - .4998384)/.2941191
recode E143 (-5/-1 = .), gen(hostility)

**** lasso regressions

local vlist female i.age i.happy_index i.living 

local quadratic_monomials
local cubic_monomials
foreach v of local vlist {
    local quadratic_monomials `quadratic_monomials' `v'#`v'
    local cubic_monomials `cubic_monomials' `v'#`v'#`v'
}

display `"`quadratic_monomials'"'
display `"`cubic_monomials'"'

local interactions_2
local interactions_3
local nvars: word count `vlist'
forvalues i = 1/`nvars' {
    local u: word `i' of `vlist'
    forvalues j = `=`i'+1'/`nvars' {
        local v: word `j' of `vlist'
        local interactions_2 `interactions_2' `u'#`v'
        forvalues k = `=`j'+1'/`nvars' {
            local w: word `k' of `vlist'
            local interactions_3 `interactions_3' `u'#`v'#`w'
        }
    }
}

display `"`interactions_2'"'
display `"`interactions_3'"'


lasso linear std_trust `vlist' `interactions_2' `interactions_3', rseed(42)
lassocoef, display(coef, postselection)

estimates save lasso_interpersonal, replace


***** robustness -  coefficients **************

**** happyedu

frame copy default happyedu_coef

frame change happyedu_coef
levelsof happy_index, local(happy)
levelsof education, local(edu)

gen clust = 0
gen ind = 0

foreach i of local happy {
	foreach l of local edu {
			replace clust = ind if happy_index==`i'&education==`l' 
			replace ind = ind + 1
	}
}

reg trust i.clust i.age female education i.marital_status i.occupation i.employment_status income i.living i.d_cntry i.year [aw=weight], vce(robust)
matrix coef = e(b)

collapse (mean) trust, by(happy_index education)

drop if missing(happy_index, education)

gen cluster_happyedu = 0
local ind = 1
gen coeff_happyedu = 0

foreach i of local happy {
	foreach l of local edu {
			replace cluster_happyedu = `ind' if happy_index==`i'&education==`l' 
			replace coeff_happyedu = coef[1,`ind'] if happy_index==`i'&education==`l'
			local ind = `ind' + 1
	}
}

drop trust

save wvs_clusters_coef_happyedu, replace


**** healthedu

frame copy default healthedu_coef

frame change healthedu_coef
levelsof health_index, local(health)
levelsof education, local(edu)

gen clust = 0
gen ind = 0

foreach i of local health {
	foreach l of local edu {
			replace clust = ind if health_index==`i'&education==`l' 
			replace ind = ind + 1
	}
}

reg trust i.clust i.age female education i.marital_status i.occupation i.employment_status income i.living i.d_cntry i.year [aw=weight], vce(robust)
matrix coef = e(b)

collapse (mean) trust, by(health_index education)

drop if missing(health_index, education)

gen cluster_healthedu = 0
local ind = 1
gen coeff_healthedu = 0

foreach i of local health {
	foreach l of local edu {
			replace cluster_healthedu = `ind' if health_index==`i'&education==`l' 
			replace coeff_healthedu = coef[1,`ind'] if health_index==`i'&education==`l'
			local ind = `ind' + 1
	}
}

drop trust

save wvs_clusters_coef_healthedu, replace

