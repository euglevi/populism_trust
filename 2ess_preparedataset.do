clear

set more off

cd "/home/eugenio/Dropbox/Hostility/data"

use ESS9e01_2, replace
qui do ESS9e01_2_formats_unicode

qui append using ESS1-8e01 

sort cntry
encode cntry, gen(d_cntry)

gen year = .
replace year = inwyr if year==.
replace year = inwyys if year==.|year==.a
replace year = supqyr if year==.|year==.a
replace year = 2003 if (year==.|year==.a)&edition=="6.6"
replace year = 2016 if (year==.|year==.a)&edition=="2.1"

gen weight = dweight*pweight

rename iscoco isco88
rename isco08 isco08b
merge m:m isco88 using "onetsoc_to_isco_cws_ibs/isco88_soc00.dta"
drop if _merge==2
drop _merge
merge m:m soc00 using "onetsoc_to_isco_cws_ibs/soc00_soc10.dta"
drop if _merge==2
drop _merge
merge m:m soc10 using "onetsoc_to_isco_cws_ibs/soc10_isco08.dta"
drop if _merge==2
drop _merge
replace isco08 = isco08b if isco08==.&isco08b!=.

gen iscom = 0
replace iscom = round((isco08-500)/1000)

drop isco08b isco88 soc00 soc10
recode mbtru (1 = 1 "yes") (2 3 = 0 "no"), gen(union)

label define jobs 1 "managers" 2 "professionals" 3 "technicians and associate professionals" 4 "clerical support workers" 5 "services and sales workers" 6 "skilled agricultural, forestry and fishery workers" 7 "craft and related trades workers" 8 "plant and machine operators and assemblers" 9 "elementary occupations" 0 "armed forces occupations", replace

label values iscom jobs


***** build variables for clustering *******

recode iscom (1 2 3  = 0 "high skill") (0 4 5 6 7 8 9 = 1 "low skill") (. = 2 "other or not working"), gen(job)
recode hinctnt (11 12 = 10) 
replace hinctnta = hinctnt if missing(hinctnta)
replace hinctnta = floor((10)*runiform() + 1) if missing(hinctnta)
recode hinctnta (1/5 = 1 "low income") (6/10 = 0 "high income"), gen(income)
recode gndr (1 = 0 "male") (2 = 1 "female"), gen(female)
recode eduyrs (0/12 = 0 "low education") (13/max = 1 "high education"), gen(education)
recode agea (0/35 = 1 "under 35") (36/64 = 0 "middle age") (65/max = 2 "over 65"), gen(age)
recode mnactic (1 = 0 "working") (3 = 2 "unemployed") (2 4/9 = 1 "nilf"), gen(employment_status)
recode iscom (1 = 1 "managers") (2 = 2 "professionals") (3 = 3 "technicians and associate professionals") (4 5 = 4 "non-manual workers") (6 = 5 "skilled agricultural, forestry and fishery workers") (7 8 = 6 "skilled and semi-skilled industry workers") (9 11 = 7 "elementary occupations") (12 = 0 "armed forces occupations") (. = 8 "other or not working"), gen(occupation)
recode domicil (1 2 = 1 "big city") (3 = 2 "small city or town") (4 5 = 3 "rural"), gen(living)
recode marital (1 4 = 1 "married") (2 3 = 2 "divorced") (5 = 0 "single"), gen(marital_status1) label(marr)
recode maritalb (1 2 5 = 1 "married") (2 3 4 = 2 "divorced") (6 = 0 "single"), gen(marital_status2)
recode maritala (1 2 6 8 = 1 "married") (3 4 5 7  = 2 "divorced") (9 = 0 "single"), gen(marital_status3)
recode happy (10 9 = 1) (8 7 6 = 2) (5 4 3 = 3) (2 1 0 = 4), gen(happy_index)
recode crmvct (1 = 1 "yes") (2 = 0 "no"), gen(victim)

gen marital_status = marital_status1
replace marital_status = marital_status2 if missing(marital_status)
replace marital_status = marital_status3 if missing(marital_status)
label values marital_status marr

rename health health_index

recode lrscale (0 1 = 0 "Far left") (2/4 = 1 "Left") (5 = 2 "Center") (6/8 = 3 "Right") (9 10 = 4 "Far right"), gen(lrscale5)

rename ppltrst trust
rename impcntr hostility
recode brncntr (1 = 0) (2 = 1 "immigrant"), gen(immigrant)
revrs stfdem, replace

recode wrkprty (2 = 1) (1 = 0)
recode wrkorg (2 = 1) (1 = 0)
recode contplt (2 = 1) (1 = 0)

************* coding voting for populist parties ******************

gen populist_vote = 0
gen poplist_vote = 0
gen farleft_vote = 0
gen farright_vote = 0

label variable populist_vote "Populist vote"
label variable poplist_vote "Populist vote"
label variable farleft_vote "Far left vote"
label variable farright_vote "Far right vote"

	**** Germany

	replace populist_vote = 1 if inlist(prtvdde1, 7, 8) 
	replace populist_vote = 1 if inlist(prtvade1, 7)
	replace populist_vote = 1 if inlist(prtvbde1, 7)
	replace populist_vote = 1 if inlist(prtvcde1, 7)
	replace populist_vote = 1 if inlist(prtvede1, 7, 6, 8)

	replace poplist_vote = 1 if inlist(prtvdde1, 5)
	replace farleft_vote = 1 if inlist(prtvdde1, 5)
	replace poplist_vote = 1 if inlist(prtvbde1, 5)
	replace farleft_vote = 1 if inlist(prtvbde1, 5)
	replace poplist_vote = 1 if inlist(prtvcde1, 5)
	replace farleft_vote = 1 if inlist(prtvcde1, 5)
	replace poplist_vote = 1 if inlist(prtvede1, 3, 6)
	replace farleft_vote = 1 if inlist(prtvede1, 3)
	replace farright_vote = 1 if inlist(prtvede1, 6)


	**** Austria

	replace populist_vote = 1 if inlist(prtvtat, 3)
	replace populist_vote = 1 if inlist(prtvtaat, 3)
	replace populist_vote = 1 if inlist(prtvtbat, 3, 9)
	replace populist_vote = 1 if inlist(prtvtcat, 3)

	replace poplist_vote = 1 if inlist(prtvtat, 3)
	replace poplist_vote = 1 if inlist(prtvtaat, 3, 4)
	replace poplist_vote = 1 if inlist(prtvtbat, 3, 4, 9)
	replace poplist_vote = 1 if inlist(prtvtcat, 3)

	replace farright_vote = 1 if inlist(prtvtat, 3)
	replace farright_vote = 1 if inlist(prtvtaat, 3, 4)
	replace farright_vote = 1 if inlist(prtvtbat, 3, 4)
	replace farright_vote = 1 if inlist(prtvtcat, 3)

	**** Belgium

	replace populist_vote = 1 if inlist(prtvtbe, 7, 8, 16) 
	replace populist_vote = 1 if inlist(prtvtcbe, 7, 6) 
	replace populist_vote = 1 if inlist(prtvtbbe, 7) 
	replace populist_vote = 1 if inlist(prtvtabe, 7) 
	replace populist_vote = 1 if inlist(prtvtdbe, 7, 6) 

	replace poplist_vote = 1 if inlist(prtvtbe, 8, 15) 
	replace farright_vote = 1 if inlist(prtvtbe, 8, 15) 
	replace farleft_vote = 1 if inlist(prtvtbe, 7, 16)
	replace poplist_vote = 1 if inlist(prtvtcbe, 7, 11, 15) 
	replace farright_vote = 1 if inlist(prtvtcbe, 7, 11, 15) 
	replace farleft_vote = 1 if inlist(prtvtcbe, 6, 14)
	replace poplist_vote = 1 if inlist(prtvtbbe, 7, 11) 
	replace farright_vote = 1 if inlist(prtvtbbe, 7, 11) 
	replace poplist_vote = 1 if inlist(prtvtabe, 7, 11) 
	replace farright_vote = 1 if inlist(prtvtabe, 7, 11) 
	replace poplist_vote = 1 if inlist(prtvtdbe, 7, 11, 15) 
	replace farright_vote = 1 if inlist(prtvtdbe, 7, 11, 15) 
	replace farleft_vote = 1 if inlist(prtvtdbe, 6, 14)


	**** Bulgaria

	replace populist_vote = 1 if inlist(prtvtbg, 10)
	replace populist_vote = 1 if inlist(prtvtabg, 10)
	replace populist_vote = 1 if inlist(prtvtbbg, 5)
	replace populist_vote = 1 if inlist(prtvtcbg, 3, 5, 7)
	replace populist_vote = 1 if inlist(prtvtdbg, 3, 5, 7)

	replace poplist_vote = 1 if inlist(prtvtbg, 5, 10)
	replace farright_vote = 1 if inlist(prtvtbg, 10)
	replace poplist_vote = 1 if inlist(prtvtabg, 5, 10)
	replace farright_vote = 1 if inlist(prtvtabg, 10)
	replace poplist_vote = 1 if inlist(prtvtbbg, 1, 5, 6, 7)
	replace farright_vote = 1 if inlist(prtvtbbg, 5, 6)
	replace poplist_vote = 1 if inlist(prtvtcbg, 1, 3, 4, 7)
	replace farright_vote = 1 if inlist(prtvtcbg, 3, 4, 7)
	replace poplist_vote = 1 if inlist(prtvtdbg, 1, 3, 5)
	replace farright_vote = 1 if inlist(prtvtdbg, 3, 5)


	**** Cyprus

	replace populist_vote = 1 if inlist(prtvtcy, 5) 
	replace populist_vote = 1 if inlist(prtvtacy, 5) 
	replace populist_vote = 1 if inlist(prtvtbcy, 6) 

	replace farleft_vote = 1 if inlist(prtvtcy, 1)
	replace farleft_vote = 1 if inlist(prtvtacy, 1)
	replace poplist_vote = 1 if inlist(prtvtbcy, 7) 
	replace farleft_vote = 1 if inlist(prtvtbcy, 1, 7) 
	replace farright_vote = 1 if inlist(prtvtbcy, 4)

	**** Czechia

	replace populist_vote = 1 if inlist(prtvtdcz, 4, 7) 
	replace populist_vote = 1 if inlist(prtvtecz, 4) 

	replace farleft_vote = 1 if inlist(prtvtcz, 9)
	replace farleft_vote = 1 if inlist(prtvtacz, 1)
	replace poplist_vote = 1 if inlist(prtvtbcz, 6)
	replace farleft_vote = 1 if inlist(prtvtbcz, 1)
	replace poplist_vote = 1 if inlist(prtvtccz, 4)
	replace farleft_vote = 1 if inlist(prtvtccz, 1)
	replace poplist_vote = 1 if inlist(prtvtdcz, 4, 7)
	replace farright_vote = 1 if inlist(prtvtdcz, 7)
	replace farleft_vote = 1 if inlist(prtvtdcz, 1)
	replace poplist_vote = 1 if inlist(prtvtecz, 4, 8)
	replace farright_vote = 1 if inlist(prtvtecz, 8)
	replace farleft_vote = 1 if inlist(prtvtecz, 1)

	**** Denmark

	replace populist_vote = 1 if inlist(prtvtdk, 6)
	replace populist_vote = 1 if inlist(prtvtadk, 6)
	replace populist_vote = 1 if inlist(prtvtbdk, 5)
	replace populist_vote = 1 if inlist(prtvtcdk, 5)

	replace poplist_vote = 1 if inlist(prtvtdk, 6, 9)
	replace farright_vote = 1 if inlist(prtvtdk, 6, 9)
	replace farleft_vote = 1 if inlist(prtvtdk, 5)
	replace poplist_vote = 1 if inlist(prtvtadk, 6, 9)
	replace farright_vote = 1 if inlist(prtvtadk, 6, 9)
	replace farleft_vote = 1 if inlist(prtvtadk, 5)
	replace poplist_vote = 1 if inlist(prtvtbdk, 5)
	replace farright_vote = 1 if inlist(prtvtbdk, 5)
	replace farleft_vote = 1 if inlist(prtvtbdk, 4, 9)
	replace poplist_vote = 1 if inlist(prtvtcdk, 5)
	replace farright_vote = 1 if inlist(prtvtcdk, 5)
	replace farleft_vote = 1 if inlist(prtvtcdk, 4, 9)

	**** Estonia

	replace populist_vote = 1 if inlist(prtvtbee, 6)
	replace populist_vote = 1 if inlist(prtvtcee, 6)
	replace populist_vote = 1 if inlist(prtvtdee, 4, 6, 10)
	replace populist_vote = 1 if inlist(prtvteee, 5, 6)
	replace populist_vote = 1 if inlist(prtvtfee, 5, 6, 11)
	replace populist_vote = 1 if inlist(prtvtgee, 5, 6, 11)

	replace poplist_vote = 1 if inlist(prtvtdee, 4)
	replace farright_vote = 1 if inlist(prtvtdee, 4)
	replace poplist_vote = 1 if inlist(prtvteee, 6)
	replace farright_vote = 1 if inlist(prtvteee, 6)
	replace poplist_vote = 1 if inlist(prtvtfee, 6)
	replace farright_vote = 1 if inlist(prtvtfee, 6)
	replace poplist_vote = 1 if inlist(prtvtgee, 6)
	replace farright_vote = 1 if inlist(prtvtgee, 6)

	**** Spain

	replace populist_vote = 1 if inlist(prtvtdes, 3, 7, 8)
	
	replace farleft_vote = 1 if inlist(prtvtes, 3, 9, 12)
	replace farleft_vote = 1 if inlist(prtvtaes, 3, 9, 12)
	replace farleft_vote = 1 if inlist(prtvtbes, 3, 7)
	replace farleft_vote = 1 if inlist(prtvtces, 4, 9, 11)
	replace poplist_vote = 1 if inlist(prtvtdes, 3, 7, 8)
	replace farleft_vote = 1 if inlist(prtvtdes, 3, 7, 8, 14)

	**** Finland

	replace populist_vote = 1 if inlist(prtvtfi, 5)
	replace populist_vote = 1 if inlist(prtvtafi, 5)
	replace populist_vote = 1 if inlist(prtvtbfi, 5)
	replace populist_vote = 1 if inlist(prtvtcfi, 4)
	replace populist_vote = 1 if inlist(prtvtdfi, 4)

	replace poplist_vote = 1 if inlist(prtvtfi, 5)
	replace farright_vote = 1 if inlist(prtvtfi, 5)
	replace farleft_vote = 1 if inlist(prtvtfi, 10)
	replace poplist_vote = 1 if inlist(prtvtafi, 5)
	replace farright_vote = 1 if inlist(prtvtafi, 5)
	replace farleft_vote = 1 if inlist(prtvtafi, 9)
	replace poplist_vote = 1 if inlist(prtvtbfi, 5)
	replace farright_vote = 1 if inlist(prtvtbfi, 5)
	replace farleft_vote = 1 if inlist(prtvtbfi, 15)
	replace poplist_vote = 1 if inlist(prtvtcfi, 4)
	replace farright_vote = 1 if inlist(prtvtcfi, 4)
	replace farleft_vote = 1 if inlist(prtvtcfi, 14)
	replace poplist_vote = 1 if inlist(prtvtdfi, 4)
	replace farright_vote = 1 if inlist(prtvtdfi, 4)
	replace farleft_vote = 1 if inlist(prtvtdfi, 12)

	**** France

	replace populist_vote = 1 if inlist(prtvtfr, 3, 8)
	replace populist_vote = 1 if inlist(prtvtafr, 3, 8)
	replace populist_vote = 1 if inlist(prtvtbfr, 2, 5, 9)
	replace populist_vote = 1 if inlist(prtvtcfr, 2, 6, 7, 8)
	replace populist_vote = 1 if inlist(prtvtdfr, 4, 11)

	replace poplist_vote = 1 if inlist(prtvtfr, 3)	
	replace farright_vote = 1 if inlist(prtvtfr, 3, 11)
	replace farleft_vote = 1 if inlist(prtvtfr, 4, 5, 9)
	replace poplist_vote = 1 if inlist(prtvtafr, 3)	
	replace farright_vote = 1 if inlist(prtvtafr, 3, 11)
	replace farleft_vote = 1 if inlist(prtvtafr, 4, 5, 9)
	replace poplist_vote = 1 if inlist(prtvtbfr, 2)	
	replace farright_vote = 1 if inlist(prtvtbfr, 2)
	replace farleft_vote = 1 if inlist(prtvtbfr, 3, 4, 7)
	replace poplist_vote = 1 if inlist(prtvtcfr, 2)	
	replace farright_vote = 1 if inlist(prtvtcfr, 2)
	replace farleft_vote = 1 if inlist(prtvtcfr, 4, 5, 6)
	replace poplist_vote = 1 if inlist(prtvtdfr, 4, 11)	
	replace farleft_vote = 1 if inlist(prtvtdfr, 2, 3, 4)
	replace farright_vote = 1 if inlist(prtvtdfr, 11)

	**** UK

	replace populist_vote = 1 if inlist(prtvtgb, 4, 6, 13)
	replace populist_vote = 1 if inlist(prtvtagb, 4, 6, 7, 8, 13)
	replace populist_vote = 1 if inlist(prtvtbgb, 4, 6, 7, 11)
	replace populist_vote = 1 if inlist(prtvtcgb, 4, 6, 7, 11, 15)

	replace poplist_vote = 1 if inlist(prtvtgb, 13)
	replace farleft_vote = 1 if inlist(prtvtgb, 13)
	replace poplist_vote = 1 if inlist(prtvtagb, 8, 13)
	replace farleft_vote = 1 if inlist(prtvtagb, 13)
	replace farright_vote = 1 if inlist(prtvtagb, 8)
	replace poplist_vote = 1 if inlist(prtvtbgb, 7, 11)
	replace farleft_vote = 1 if inlist(prtvtbgb, 11)
	replace farright_vote = 1 if inlist(prtvtbgb, 7)
	replace poplist_vote = 1 if inlist(prtvtcgb, 7, 11)
	replace farleft_vote = 1 if inlist(prtvtcgb, 11)
	replace farright_vote = 1 if inlist(prtvtcgb, 7)

	**** Greece

	replace populist_vote = 1 if inlist(prtvtgr, 3, 4)
	replace populist_vote = 1 if inlist(prtvtagr, 3, 4, 6)
	replace populist_vote = 1 if inlist(prtvtbgr, 3, 4, 5)
	replace populist_vote = 1 if inlist(prtvtcgr, 3, 4, 5, 10)

	replace poplist_vote = 1 if inlist(prtvtgr, 4, 5)
	replace farleft_vote = 1 if inlist(prtvtgr, 3, 4, 5)
	replace poplist_vote = 1 if inlist(prtvtagr, 4, 5, 6)
	replace farleft_vote = 1 if inlist(prtvtagr, 3, 4, 5)
	replace farright_vote = 1 if inlist(prtvtagr, 6)
	replace poplist_vote = 1 if inlist(prtvtbgr, 4, 5)
	replace farleft_vote = 1 if inlist(prtvtbgr, 3, 4)
	replace farright_vote = 1 if inlist(prtvtbgr, 5)
	replace poplist_vote = 1 if inlist(prtvtcgr, 4, 5)
	replace farleft_vote = 1 if inlist(prtvtcgr, 3, 5, 12)
	replace farright_vote = 1 if inlist(prtvtcgr, 4, 10)

	**** Croatia

	replace populist_vote = 1 if inlist(prtvthr, 9)

	replace poplist_vote = 1 if inlist(prtvthr, 7)
	replace farright_vote = 1 if inlist(prtvthr, 7, 9)

	**** Hungary

	replace populist_vote = 1 if inlist(prtvtahu, 3)
	replace populist_vote = 1 if inlist(prtvtbhu, 3)
	replace populist_vote = 1 if inlist(prtvtchu, 11, 13)
	replace populist_vote = 1 if inlist(prtvtdhu, 4, 5)
	replace populist_vote = 1 if inlist(prtvtehu, 2, 3)
	replace populist_vote = 1 if inlist(prtvtfhu, 4, 6)

	replace farleft_vote = 1 if inlist(prtvthu, 6)
	replace poplist_vote = 1 if inlist(prtvtahu, 1, 3)
	replace farright_vote = 1 if inlist(prtvtahu, 1, 3)
	replace farleft_vote = 1 if inlist(prtvtahu, 5)
	replace poplist_vote = 1 if inlist(prtvtbhu, 1, 3)
	replace farright_vote = 1 if inlist(prtvtbhu, 1, 3)
	replace farleft_vote = 1 if inlist(prtvtbhu, 5)
	replace poplist_vote = 1 if inlist(prtvtchu, 1, 11)
	replace farright_vote = 1 if inlist(prtvtchu, 1, 11)
	replace farleft_vote = 1 if inlist(prtvtchu, 5)
	replace poplist_vote = 1 if inlist(prtvtdhu, 3, 4, 7)
	replace farright_vote = 1 if inlist(prtvtdhu, 3, 4, 7)
	replace farleft_vote = 1 if inlist(prtvtdhu, 10)
	replace poplist_vote = 1 if inlist(prtvtehu, 1, 2)
	replace farright_vote = 1 if inlist(prtvtehu, 1, 2)
	replace farleft_vote = 1 if inlist(prtvtehu, 5)
	replace poplist_vote = 1 if inlist(prtvtfhu, 3, 4)
	replace farright_vote = 1 if inlist(prtvtfhu, 3, 4, 5)
	replace farleft_vote = 1 if inlist(prtvtfhu, 8)

	**** Ireland

	replace populist_vote = 1 if inlist(prtvtie, 6)
	replace populist_vote = 1 if inlist(prtvtaie, 6, 7, 8)
	replace populist_vote = 1 if inlist(prtvtbie, 1, 7, 9)
	replace populist_vote = 1 if inlist(prtvtcie, 1, 7, 9)

	replace poplist_vote = 1 if inlist(prtvtie, 6)
	replace farleft_vote = 1 if inlist(prtvtie, 6)
	replace poplist_vote = 1 if inlist(prtvtaie, 7)
	replace farleft_vote = 1 if inlist(prtvtaie, 6, 7, 8)
	replace poplist_vote = 1 if inlist(prtvtbie, 7)
	replace farleft_vote = 1 if inlist(prtvtbie, 1, 7, 9)
	replace poplist_vote = 1 if inlist(prtvtcie, 7)
	replace farleft_vote = 1 if inlist(prtvtcie, 1, 7, 9)

	**** Italy

	replace populist_vote = 1 if inlist(prtvtit, 7, 11)
	replace populist_vote = 1 if inlist(prtvtbit, 9, 10)
	replace populist_vote = 1 if inlist(prtvtcit, 7, 9, 10)

	replace poplist_vote = 1 if inlist(prtvtit, 8, 11)
	replace farright_vote = 1 if inlist(prtvtit, 11, 16)
	replace farleft_vote = 1 if inlist(prtvtit, 3, 7)
	replace poplist_vote = 1 if inlist(prtvtbit, 4, 8, 9, 10)
	replace farright_vote = 1 if inlist(prtvtbit, 9, 10, 13)
	replace farleft_vote = 1 if inlist(prtvtbit, 2)
	replace poplist_vote = 1 if inlist(prtvtcit, 7, 8, 9, 10)
	replace farright_vote = 1 if inlist(prtvtcit, 9, 10, 13)
	replace farleft_vote = 1 if inlist(prtvtcit, 6, 12)

	**** Lithuania

	replace populist_vote = 1 if inlist(prtvlt1, 4, 13)
	replace populist_vote = 1 if inlist(prtvalt1, 6, 9)
	replace populist_vote = 1 if inlist(prtvblt1, 5, 9, 14)

	replace poplist_vote = 1 if inlist(prtvlt1, 4, 9, 10, 13, 15)
	replace farright_vote = 1 if inlist(prtvlt1, 15)
	replace poplist_vote = 1 if inlist(prtvalt1, 3, 6, 9, 13, 15)
	replace farright_vote = 1 if inlist(prtvalt1, 15)
	replace farleft_vote = 1 if inlist(prtvalt1, 13)
	replace poplist_vote = 1 if inlist(prtvblt1, 3, 4, 5, 8, 9)
	replace farright_vote = 1 if inlist(prtvblt1, 4)

	**** Luxembourg

	replace populist_vote = 1 if inlist(prtvtlu, 5)

	replace farleft_vote = 1 if inlist(prtvtlu, 5)

	**** The Netherlands		

	replace populist_vote = 1 if inlist(prtvtnl, 4)
	replace populist_vote = 1 if inlist(prtvtanl, 4)
	replace populist_vote = 1 if inlist(prtvtbnl, 4)
	replace populist_vote = 1 if inlist(prtvtcnl, 4, 11)
	replace populist_vote = 1 if inlist(prtvtdnl, 3)
	replace populist_vote = 1 if inlist(prtvtenl, 3)
	replace populist_vote = 1 if inlist(prtvtfnl, 3)
	replace populist_vote = 1 if inlist(prtvtgnl, 3, 13)

	replace poplist_vote = 1 if inlist(prtvtnl, 4, 7, 9)
	replace farright_vote = 1 if inlist(prtvtnl, 4)
	replace farleft_vote = 1 if inlist(prtvtnl, 7)
	replace poplist_vote = 1 if inlist(prtvtanl, 4,7, 9)
	replace farright_vote = 1 if inlist(prtvtanl, 4)
	replace farleft_vote = 1 if inlist(prtvtanl, 7)
	replace poplist_vote = 1 if inlist(prtvtbnl, 4, 7, 9)
	replace farright_vote = 1 if inlist(prtvtbnl, 4)
	replace farleft_vote = 1 if inlist(prtvtbnl, 7)
	replace poplist_vote = 1 if inlist(prtvtcnl, 4, 7, 9, 11)
	replace farright_vote = 1 if inlist(prtvtcnl, 4, 11)
	replace farleft_vote = 1 if inlist(prtvtcnl, 7)
	replace poplist_vote = 1 if inlist(prtvtdnl, 3, 5)
	replace farright_vote = 1 if inlist(prtvtdnl, 3)
	replace farleft_vote = 1 if inlist(prtvtdnl, 5)
	replace poplist_vote = 1 if inlist(prtvtenl, 3, 5)
	replace farright_vote = 1 if inlist(prtvtenl, 3)
	replace farleft_vote = 1 if inlist(prtvtenl, 5)
	replace poplist_vote = 1 if inlist(prtvtfnl, 3, 4)
	replace farright_vote = 1 if inlist(prtvtfnl, 3)
	replace farleft_vote = 1 if inlist(prtvtfnl, 4)
	replace poplist_vote = 1 if inlist(prtvtgnl, 3, 4, 13)
	replace farright_vote = 1 if inlist(prtvtgnl, 3, 13)
	replace farleft_vote = 1 if inlist(prtvtgnl, 4)

	**** Poland

	replace populist_vote = 1 if inlist(prtvtpl, 5)
	replace populist_vote = 1 if inlist(prtvtapl, 14)
	replace populist_vote = 1 if inlist(prtvtbpl, 6)
	replace populist_vote = 1 if inlist(prtvtcpl, 1, 6)
	replace populist_vote = 1 if inlist(prtvtdpl, 2, 6)

	replace poplist_vote = 1 if inlist(prtvtpl, 4, 5, 10)
	replace farright_vote = 1 if inlist(prtvtpl, 5, 10)
	replace poplist_vote = 1 if inlist(prtvtapl, 3, 14, 16)
	replace farright_vote = 1 if inlist(prtvtapl, 3, 8, 14)
	replace poplist_vote = 1 if inlist(prtvtbpl, 2, 6, 7)
	replace farright_vote = 1 if inlist(prtvtbpl, 2, 6)
	replace poplist_vote = 1 if inlist(prtvtcpl, 6)
	replace farright_vote = 1 if inlist(prtvtcpl, 6, 1, 3)
	replace poplist_vote = 1 if inlist(prtvtdpl, 2, 6)
	replace farright_vote = 1 if inlist(prtvtdpl, 1, 2, 6)

	**** Portugal

	replace populist_vote = 1 if inlist(prtvtpt, 1, 3, 5)
	replace populist_vote = 1 if inlist(prtvtapt, 1, 3)
	replace populist_vote = 1 if inlist(prtvtbpt, 1, 3)
	replace populist_vote = 1 if inlist(prtvtcpt, 2, 3, 9, 15)

	replace farleft_vote = 1 if inlist(prtvtpt, 1, 5, 6)
	replace farleft_vote = 1 if inlist(prtvtapt, 1, 3, 4)
	replace farleft_vote = 1 if inlist(prtvtbpt, 1, 3, 4)
	replace farleft_vote = 1 if inlist(prtvtcpt, 2, 3, 8)

	**** Sweden

	replace populist_vote = 1 if inlist(prtvtase, 10) 
	replace populist_vote = 1 if inlist(prtvtbse, 9, 10) 

	replace farleft_vote = 1 if inlist(prtvtse, 7)
	replace poplist_vote = 1 if inlist(prtvtase, 10) 
	replace farright_vote = 1 if inlist(prtvtase, 10) 
	replace farleft_vote = 1 if inlist(prtvtase, 7)
	replace poplist_vote = 1 if inlist(prtvtbse, 10) 
	replace farright_vote = 1 if inlist(prtvtbse, 10) 
	replace farleft_vote = 1 if inlist(prtvtbse, 7)

	**** Slovenia

	replace populist_vote = 1 if inlist(prtvtesi, 11)
	replace populist_vote = 1 if inlist(prtvtfsi, 2)

	replace poplist_vote = 1 if inlist(prtvtsi, 4, 5)
	replace farright_vote = 1 if inlist(prtvtsi, 4, 5)
	replace poplist_vote = 1 if inlist(prtvtasi, 1, 6)
	replace farright_vote = 1 if inlist(prtvtasi, 1, 6)
	replace poplist_vote = 1 if inlist(prtvtbsi, 4, 5)
	replace farright_vote = 1 if inlist(prtvtbsi, 4, 5)
	replace poplist_vote = 1 if inlist(prtvtcsi, 5, 7)
	replace farright_vote = 1 if inlist(prtvtcsi, 5, 7)
	replace poplist_vote = 1 if inlist(prtvtdsi, 1, 10)
	replace farright_vote = 1 if inlist(prtvtdsi, 1, 10)
	replace poplist_vote = 1 if inlist(prtvtesi, 6)
	replace farright_vote = 1 if inlist(prtvtesi, 6)
	replace poplist_vote = 1 if inlist(prtvtfsi, 3, 8, 11)
	replace farright_vote = 1 if inlist(prtvtfsi, 8, 11)

	**** Slovakia

	replace populist_vote = 1 if inlist(prtvtask, 6)
	replace populist_vote = 1 if inlist(prtvtbsk, 1)
	replace populist_vote = 1 if inlist(prtvtcsk, 1)

	replace poplist_vote = 1 if inlist(prtvtsk, 3, 6)
	replace farleft_vote = 1 if inlist(prtvtsk, 7)
	replace poplist_vote = 1 if inlist(prtvtask, 3, 6)
	replace farright_vote = 1 if inlist(prtvtask, 6)
	replace poplist_vote = 1 if inlist(prtvtbsk, 1, 3)
	replace farright_vote = 1 if inlist(prtvtbsk, 1)
	replace poplist_vote = 1 if inlist(prtvtcsk, 1, 3)

	**** Switzerland

	replace populist_vote = 1 if inlist(prtvtch, 4)
	replace populist_vote = 1 if inlist(prtvtach, 4)
	replace populist_vote = 1 if inlist(prtvtbch, 4)
	replace populist_vote = 1 if inlist(prtvtcch, 4)
	replace populist_vote = 1 if inlist(prtvtdch, 1)
	replace populist_vote = 1 if inlist(prtvtech, 1)
	replace populist_vote = 1 if inlist(prtvtfch, 1)
	replace populist_vote = 1 if inlist(prtvtgch, 1)

	replace poplist_vote = 1 if inlist(prtvtch, 4, 12, 13, 15)
	replace farright_vote = 1 if inlist(prtvtch, 4, 11, 13, 15)
	replace farleft_vote = 1 if inlist(prtvtch, 9)
	replace poplist_vote = 1 if inlist(prtvtach, 4, 12, 13, 15)
	replace farright_vote = 1 if inlist(prtvtach, 4, 11, 13, 15)
	replace farleft_vote = 1 if inlist(prtvtach, 9)
	replace poplist_vote = 1 if inlist(prtvtbch, 4, 11, 13)
	replace farright_vote = 1 if inlist(prtvtbch, 4, 10, 13)
	replace farleft_vote = 1 if inlist(prtvtbch, 7)
	replace poplist_vote = 1 if inlist(prtvtcch, 4, 11, 13)
	replace farright_vote = 1 if inlist(prtvtcch, 4, 10, 13)
	replace farleft_vote = 1 if inlist(prtvtcch, 7)
	replace poplist_vote = 1 if inlist(prtvtdch, 1, 9)
	replace farright_vote = 1 if inlist(prtvtdch, 1, 15)
	replace farleft_vote = 1 if inlist(prtvtdch, 11)
	replace poplist_vote = 1 if inlist(prtvtech, 1, 9, 10)
	replace farright_vote = 1 if inlist(prtvtech, 1, 10)
	replace farleft_vote = 1 if inlist(prtvtech, 11)
	replace poplist_vote = 1 if inlist(prtvtfch, 1, 9, 10)
	replace farright_vote = 1 if inlist(prtvtfch, 1, 10)
	replace farleft_vote = 1 if inlist(prtvtfch, 11)
	replace poplist_vote = 1 if inlist(prtvtgch, 1, 9, 10)
	replace farright_vote = 1 if inlist(prtvtgch, 1, 10)

	**** Norway 

	replace populist_vote = 1 if inlist(prtvtno, 8)
	replace populist_vote = 1 if inlist(prtvtano, 8)
	replace populist_vote = 1 if inlist(prtvtbno, 8)
	
	replace poplist_vote = 1 if inlist(prtvtno, 8, 9)
	replace farright_vote = 1 if inlist(prtvtno, 8)
	replace farleft_vote = 1 if inlist(prtvtno, 1, 2)
	replace poplist_vote = 1 if inlist(prtvtano, 8, 9)
	replace farright_vote = 1 if inlist(prtvtano, 8)
	replace farleft_vote = 1 if inlist(prtvtano, 1, 2)
	replace poplist_vote = 1 if inlist(prtvtbno, 8, 9)
	replace farright_vote = 1 if inlist(prtvtbno, 8)
	replace farleft_vote = 1 if inlist(prtvtbno, 1, 2)

	**** Serbia

	replace populist_vote = 1 if inlist(prtvtrs, 6) 

	**** Iceland

	replace populist_vote = 1 if inlist(prtvtbis, 4)

	replace poplist_vote = 1 if inlist(prtvtais, 6)
	replace poplist_vote = 1 if inlist(prtvtbis, 4)
	replace farleft_vote = 1 if inlist(prtvtbis, 7)

keep year d_cntry cntry weight female age living marital_status happy_index health_index lrscale5 education occupation job employment_status income living trust hostility trst* immigrant stfdem lrscale populist_vote poplist_vote farright_vote farleft_vote contplt wrkorg wrkprty


****** correlates of trust ****************

*reg trust female education job i.employment_status income i.living i.d_cntry i.year [aw=weight] if year>=2015, vce(robust)

*reg trust female i.age i.marital_status i.d_cntry##i.year [aw=weight] if year>=2004, vce(robust)


****** build clusters ************************


save ess_clusters, replace

