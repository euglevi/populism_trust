
set more off
clear frames
clear
clear matrix


cd "/home/eugenio/Dropbox/Hostility/data"

use BES2019_W19_Panel_v0.5.dta, replace

forvalues i = 1(1)5 {
	rename lr`i'W16 lr`i'W15
	rename lr`i'W6 lr`i'W7
}

keep p_past_vote_* id wave7 wave15 wave17 wave19 *W7 *W15 *W17 *W19 *CitizenW8 wt_new* gender


keep p_past_vote_* id wave7 wave15 wave17 wave19 satDemUK* oslaua* wt_new* *Citizen* gender age* p_edlevel* p_work_stat* p_socgrade* p_gross_household* p_gross_personal* p_marital* pcon* gor* jobzone* country* genTrust* immigSelf* 

drop if wave7==0&wave15==0&wave17==0&wave19==0

rename *CitizenW8 *CitizenW7
rename p_gross_personal* p_pincome*
rename p_gross_household* p_hincome*

reshape long oslauaW satDemUKW immigSelfW genTrustW ukCitizenW euCitizenW commonwealthCitizenW otherCitizenW countryW ageW gorW pconW p_pincomeW p_hincomeW p_housingW p_maritalW p_socgradeW p_work_statW p_edlevelW, i(id) j(wv)

rename *W *

levelsof wv, local(levels)
gen indicator = 0

foreach i of local levels {
  replace indicator = 1 if wv==`i'&wave`i'==1
}

drop if indicator==0
drop indicator

xtset id wv
drop wave*

recode immigSelf (9999 = .), gen(hostility)
recode genTrust (2 = 0) (9999 = 0.5), gen(trust)
revrs hostility, replace

gen weight = .
foreach var of varlist wt_new_W10-wt_newW17W19 {
  qui replace weight = `var' if weight==.
}

drop wt_new_W10-wt_newW17W19
drop if weight==.

recode age (0/35 = 1 "under 35") (36/64 = 0 "middle age") (65/max = 2 "over 65"), gen(age2)
rename age age_c
rename age2 age

recode gender (2 = 1) (1 = 0), gen(female)
recode p_marital (1 2 = 1 "married") (3 7 = 2 "divorced") (5 6 8 4 = 0 "single") (. = 3 "missing"), gen(marital_status)
recode p_edlevel (1 2 3 = 0) (4 5 = 1 "high education") (. = 2 "missing"), gen(education)

gsort id -ukCitizen
by id: replace ukCitizen = ukCitizen[_n - 1] if missing(ukCitizen)
recode ukCitizen (0 = 1 "immigrant") (1 = 0), gen(immigrant)
recode p_work_stat (1 2 3 = 0 "employed") (4 5 7 8 = 2 "nilf") (6 = 1 "unemployed") (. = 3 "missing"), gen(employment_status)
rename p_socgrade occupation
recode occupation (7 8 . = 7)
recode p_pincome (1/5 = 1 "low income") (6/14 = 0 "high income") (15/max . = 2 "do not know"), gen(income)

gen vote = .
replace vote = p_past_vote_2015 if wv==7
replace vote = p_past_vote_2017 if wv==15
replace vote = p_past_vote_2019 if wv==19

recode vote (6 12 = 1 "yes") (1/5 7/9999 = 0 "no"), gen(ukip)
sum ukip
gen std_ukip = (ukip - r(mean))/r(sd)

recode satDemUK (9999 = .), gen(democracy)
revrs democracy, replace

************ standardize variables

gen std_trust = (trust - .4998384)/.2941191

replace hostility = (hostility-1)/10
replace democracy = (democracy-1)/3

gen std_hostility = (hostility - .5410336)/.3184543
gen std_democracy = (democracy - .4986601)/.2644387


save bes_reduced, replace

*************** ANALYSIS ***********

use bes_reduced, replace

reg ukip std_trust i.age i.marital_status i.education i.occupation i.employment_status i.income i.gor i.pcon i.wv [aw = weight], cluster(id)
outreg2 using BES.xls, excel replace label drop(i.gor i.pcon i.wv)

xtreg ukip std_trust i.age i.marital_status i.education i.occupation i.employment_status i.income i.gor i.pcon i.wv [aw = weight], cluster(id) fe
outreg2 using BES.xls, excel append label drop(i.gor i.pcon i.wv)

reg std_democracy std_trust i.age i.marital_status i.education i.occupation i.employment_status i.income i.gor i.pcon i.wv [aw = weight], cluster(id)
outreg2 using BES.xls, excel append label drop(i.gor i.pcon i.wv)

xtreg std_democracy std_trust i.age i.marital_status i.education i.occupation i.employment_status i.income i.gor i.pcon i.wv [aw = weight], cluster(id) fe
outreg2 using BES.xls, excel append label drop(i.gor i.pcon i.wv)

reg std_hostility std_trust i.age i.marital_status i.education i.occupation i.employment_status i.income i.gor i.pcon i.wv [aw = weight], cluster(id)
outreg2 using BES.xls, excel append label drop(i.gor i.pcon i.wv)

xtreg std_hostility std_trust i.age i.marital_status i.education i.occupation i.employment_status i.income i.gor i.pcon i.wv [aw = weight], cluster(id) fe
outreg2 using BES.xls, excel append label drop(i.gor i.pcon i.wv)


