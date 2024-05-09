clear
clear frames
set more off
qui cd "/home/eugenio/Dropbox/Hostility/data"

use ess_final.dta, replace
do globals

* ╭───────────────╮
* │ T: HETEROGENEITY │
* ╰───────────────╯

***** heterogeneity analysis ***********

recode occupation (0 1 2 3 4 8 = 0 "other") (5 6 7 = 1 "blue collar"), gen(blue_collar)
recode age (0 2 = 0) (1 = 1), gen(young)
recode age (0 1 = 0) (2 = 1), gen(old)
recode living (1 2 = 0) (3 = 1), gen(rural)
recode lrscale5 (0 1 = 1 "left") (2 = 0 "center") (3 4 = 2 "right"), gen(lrscale3)
gen left = lrscale<5
gen right = lrscale>5
recode education (1 = 0) (0 = 1)

reg std_poplist_vote std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_IVinteractions_coef.xls, label excel replace drop(cntry*_year*)

foreach v of varlist female young old blue_collar {
	ivreg2 poplist_vote $controls (c.std_trust##i.`v' = c.std_pred_trust##i.`v') [aw = weight] if sample_populism, cluster(clust_pred ) 
	outreg2 using ESS_IVinteractions_coef.xls, label excel append adds(Num clusters, e(N_clust)) addtext(Country*Year FE, yes) drop(cntry*_year*)
	} 

foreach v of varlist income education {
	ivreg2 poplist_vote $controls (c.std_trust##i.`v' = c.std_pred_trust##i.`v') [aw = weight] if sample_populism, cluster(clust_pred ) 
	outreg2 using ESS_IVinteractions_coef.xls, label excel append adds(Num clusters, e(N_clust)) addtext(Country*Year FE, yes) drop(cntry*_year*)
	} 

foreach v of varlist right { 
	ivreg2 poplist_vote $controls i.`v' (c.std_trust##i.`v' = c.std_pred_trust##i.`v') [aw = weight] if sample_populism, cluster(clust_pred ) 
	outreg2 using ESS_IVinteractions_coef.xls, label excel append adds(Num clusters, e(N_clust)) addtext(Country*Year FE, yes) drop(cntry*_year*)
	} 

foreach v of varlist rural {
	ivreg2 poplist_vote $controls (c.std_trust##i.`v' = c.std_pred_trust##i.`v') [aw = weight] if sample_populism, cluster(clust_pred ) 
	outreg2 using ESS_IVinteractions_coef.xls, label excel append adds(Num clusters, e(N_clust)) addtext(Country*Year FE, yes) drop(cntry*_year*)
	} 
