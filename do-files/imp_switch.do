set processor 12

global gravity "g_distw contig comlang diplo_dis wto rta gdpcap"
global firm_control "l.age_imp l.lnvalue_f_imp l.lnnum_cty_imp"

*-------------------------------------------------------------------------------

* 1. Import Status

cd "D:\Project G"
use samples\samples_0015_imp_firm_ext,clear

** Probability of importing (static panel)

eststo imp_static_LPM: reghdfe imp_fc dlnRER dlnrgdp $gravity $firm_control i.year, a(party_id) vce(cluster party_id)
eststo imp_static_probit: probit imp_fc dlnRER dlnrgdp $gravity $firm_control i.year, vce(cluster party_id)
eststo imp_static_logit: logit imp_fc dlnRER dlnrgdp $gravity $firm_control i.year, vce(cluster party_id)

estfe imp_static_*, labels(party_id "Firm FE" i.year "Year FE")
esttab imp_static_* using tables\import_static.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit")

** Probability of importing (dynamic panel)

eststo imp_dynamic_LPM: reghdfe imp_fc dlnRER dlnrgdp l.imp_fc $gravity $firm_control i.year, a(party_id) vce(cluster party_id)
eststo imp_dynamic_probit: probit imp_fc dlnRER dlnrgdp l.imp_fc $gravity $firm_control i.year, vce(cluster party_id)
eststo imp_dynamic_logit: logit imp_fc dlnRER dlnrgdp l.imp_fc $gravity $firm_control i.year, vce(cluster party_id)
eststo imp_dynamic_ab: xtabond imp_fc dlnRER dlnrgdp g_distw diplo_dis wto rta gdpcap $firm_control, lags(1) twostep vce(robust)
eststo imp_dynamic_sys: xtdpdsys imp_fc dlnRER dlnrgdp g_distw diplo_dis wto rta gdpcap $firm_control, lags(1) twostep vce(robust)

estfe imp_dynamic_*, labels(i.year "Year FE")
esttab imp_dynamic_* using tables\import_dynamic.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit" "Diff GMM" "System GMM")

*-------------------------------------------------------------------------------

* 2. Entry & Exit

cd "D:\Project G"
use samples\samples_0015_imp_firm_ext,clear

** Probability of entry

eststo entry_LPM: reghdfe entry_fc dlnRER dlnrgdp $gravity $firm_control i.year if l.imp_fc==0, a(party_id) vce(cluster party_id)
eststo entry_probit: probit entry_fc dlnRER dlnrgdp $gravity $firm_control i.year if l.imp_fc==0, vce(cluster party_id)
eststo entry_logit: logit entry_fc dlnRER dlnrgdp $gravity $firm_control i.year if l.imp_fc==0, vce(cluster party_id)

estfe entry_*, labels(i.year "Year FE")
esttab entry_* using tables\import_entry.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit")

** Probability of exit

eststo exit_LPM: reghdfe exit_fc dlnRER dlnrgdp $gravity $firm_control i.year if l.imp_fc==1, a(party_id) vce(cluster party_id)
eststo exit_probit: probit exit_fc dlnRER dlnrgdp $gravity $firm_control i.year if l.imp_fc==1, vce(cluster party_id)
eststo exit_logit: logit exit_fc dlnRER dlnrgdp $gravity $firm_control i.year if l.imp_fc==1, vce(cluster party_id)

estfe exit_*, labels(i.year "Year FE")
esttab exit_* using tables\import_exit.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit")

*-------------------------------------------------------------------------------

* 3. Import Status (Other countries)

cd "D:\Project G"
use samples\samples_0015_imp_firm_ext,clear

** Probability of importing (static panel)

eststo other_imp_static_LPM: reghdfe imp_fc dlnRER_other dlnrgdp $gravity $firm_control i.year, a(party_id) vce(cluster party_id)
eststo other_imp_static_probit: probit imp_fc dlnRER_other dlnrgdp $gravity $firm_control i.year, vce(cluster party_id)
eststo other_imp_static_logit: logit imp_fc dlnRER_other dlnrgdp $gravity $firm_control i.year, vce(cluster party_id)

estfe other_imp_static_*, labels(party_id "Firm FE" i.year "Year FE")
esttab other_imp_static_* using tables\import_static_other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit")

** Probability of importing (dynamic panel)

eststo other_imp_dynamic_LPM: reghdfe imp_fc dlnRER_other dlnrgdp l.imp_fc $gravity $firm_control i.year, a(party_id) vce(cluster party_id)
eststo other_imp_dynamic_probit: probit imp_fc dlnRER_other dlnrgdp l.imp_fc $gravity $firm_control i.year, vce(cluster party_id)
eststo other_imp_dynamic_logit: logit imp_fc dlnRER_other dlnrgdp l.imp_fc $gravity $firm_control i.year, vce(cluster party_id)
eststo other_imp_dynamic_ab: xtabond imp_fc dlnRER_other dlnrgdp g_distw diplo_dis wto rta gdpcap $firm_control, lags(1) vce(robust)
eststo other_imp_dynamic_sys: xtdpdsys imp_fc dlnRER_other dlnrgdp g_distw diplo_dis wto rta gdpcap $firm_control, lags(1) vce(robust)

estfe other_imp_dynamic_*, labels(i.year "Year FE")
esttab other_imp_dynamic_* using tables\import_dynamic_other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit" "Diff GMM" "System GMM")

*-------------------------------------------------------------------------------

* 4. Entry & Exit (Other countries)

cd "D:\Project G"
use samples\samples_0015_imp_firm_ext,clear

** Probability of entry

eststo other_entry_LPM: reghdfe entry_fc dlnRER_other dlnrgdp $gravity $firm_control i.year if l.imp_fc==0, a(party_id) vce(cluster party_id)
eststo other_entry_probit: probit entry_fc dlnRER_other dlnrgdp $gravity $firm_control i.year if l.imp_fc==0, vce(cluster party_id)
eststo other_entry_logit: logit entry_fc dlnRER_other dlnrgdp $gravity $firm_control i.year if l.imp_fc==0, vce(cluster party_id)

estfe other_entry_*, labels(i.year "Year FE")
esttab other_entry_* using tables\import_entry_other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit")

** Probability of exit

eststo other_exit_LPM: reghdfe exit_fc dlnRER_other dlnrgdp $gravity $firm_control i.year if l.imp_fc==1, a(party_id) vce(cluster party_id)
eststo other_exit_probit: probit exit_fc dlnRER_other dlnrgdp $gravity $firm_control i.year if l.imp_fc==1, vce(cluster party_id)
eststo other_exit_logit: logit exit_fc dlnRER_other dlnrgdp $gravity $firm_control i.year if l.imp_fc==1, vce(cluster party_id)

estfe other_exit_*, labels(i.year "Year FE")
esttab other_exit_* using tables\import_exit_other.csv, replace b(3) se(3) noconstant star(* 0.1 ** 0.05 *** 0.01) indicate("Year FE =*.year") compress nogaps mtitle("LPM" "Probit" "Logit")
