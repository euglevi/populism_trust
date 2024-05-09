clear
clear frames
set more off
qui cd "/home/eugenio/Dropbox/Hostility/data"

use ess_final.dta, replace

do globals


*  ╭──────────────────────╮
*  │ T: main analysis
*  ╰──────────────────────╯

** populist vote

reg poplist_vote std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_voting.xls, label excel replace addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 poplist_vote $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 poplist_vote std_inst_trst $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

** left populist

reg farleftpop_vote std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_voting.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 farleftpop_vote $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 farleftpop_vote std_inst_trst $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)


** right populist

reg farrightpop_vote std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_voting.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 farrightpop_vote $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 farrightpop_vote std_inst_trst $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)


** Satisfaction with democracy

reg std_stfdem std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_democracy.xls, label excel replace addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 std_stfdem $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_democracy.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)


** Hostility towards immigrants

reg std_hostility std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_immig.xls, label excel replace addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 std_hostility $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_immig.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

** Civil participation

reg wrkprty std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_participation.xls, label excel replace addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 wrkprty $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_participation.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)


reg wrkorg std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_participation.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 wrkorg $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_participation.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

reg contplt std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_participation.xls, label excel append addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 contplt $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_participation.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)


* ╭───────────────╮
* │ T: ROBUSTNESS
* ╰───────────────╯


** populist vote

reg poplist_vote std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_voting.xls, label excel replace addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 poplist_vote $controls (std_trust = coeff_happyedu ) [aw = weight] if sample_populism, first cluster(cluster_happyedu)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 poplist_vote $controls (std_trust = coeff_healthedu ) [aw = weight] if sample_populism, first cluster(cluster_healthedu ) 
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 poplist_vote $controls (std_trust = coeff_happyedu coeff_healthedu) [aw = weight] if sample_populism, first cluster(cluster_happyedu cluster_healthedu)
outreg2 using ESS_voting.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

************ T: ROBUSTNESS WITH CHS LIST

** populist vote

reg populist_vote std_trust $controls [aw = weight] if sample_populism
outreg2 using ESS_ches.xls, label excel replace addtext(Country*Year FE, yes) drop(cntry*_year*)

ivreg2 populist_vote $controls (std_trust = std_pred_trust ) [aw = weight] if sample_populism, first cluster(clust_pred)
outreg2 using ESS_ches.xls, label excel append adds(Num clusters, e(N_clust), F Stat, e(widstat)) addtext(Country*Year FE, yes) drop(cntry*_year*)

