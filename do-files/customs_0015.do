cd "D:\Project G"

*-------------------------------------------------------------------------------

* Basic processing of customs data 2000-2015

global imp_exp "imp exp"

** Export data

use Tengyu_Transfer\custom_0015_exp,clear
rename (hs_2 hs_4 hs_6) (HS2 HS4 HS6)
merge n:1 country using "D:\Project C\customs data\customs_country_namecode",nogen keep(matched)
merge n:1 HS6 using customs_0015\intermediates\hs96_capital_intermediates,nogen keep(matched master)
replace intem=0 if intem==.
sort party_id HS6 coun_aim year
format coun_aim %20s
save customs_0015\exp\customs_0015_exp,replace

use customs_0015\exp\customs_0015_exp,clear
gen num=1
collapse (sum) value (count) num_HS6=num, by(party_id countrycode coun_aim year)
save customs_0015\exp\customs_0015_exp_firm_cty,replace

use customs_0015\exp\customs_0015_exp,clear
gen num=1
collapse (sum) value (count) num_cty=num, by(party_id HS6 HS2 HS4 year)
save customs_0015\exp\customs_0015_exp_firm_HS6,replace

use customs_0015\exp\customs_0015_exp,clear
collapse (sum) value, by(countrycode coun_aim HS6 HS2 HS4 year)
save customs_0015\exp\customs_0015_exp_cty_HS6,replace

use customs_0015\exp\customs_0015_exp_cty,clear
collapse (sum) value_cty_exp, by(countrycode coun_aim)
gsort -value
gen rank_exp=_n
gen top50_exp=1 if rank_exp<=50
replace top50_exp=0 if rank_exp>50
gen top30_exp=1 if rank_exp<=30
replace top30_exp=0 if rank_exp>30
save customs_0015\exp\customs_0015_exp_rank,replace

use customs_0015\customs_0015_exp,clear
collapse (sum) value_firm_exp=value, by(party_id year)
save customs_0015\exp\customs_0015_exp_firm,replace

*-------------------------------------------------------------------------------

** Import data

use Tengyu_Transfer\custom_0015_imp,clear
rename (hs_2 hs_4 hs_6) (HS2 HS4 HS6)
merge n:1 country using "D:\Project C\customs data\customs_country_namecode",nogen keep(matched)
merge n:1 HS6 using customs_0015\intermediates\hs96_capital_intermediates,nogen keep(matched master)
replace intem=0 if intem==.
sort party_id HS6 coun_aim year
format coun_aim %20s
save customs_0015\imp\customs_0015_imp,replace

use customs_0015\imp\customs_0015_imp,clear
drop if intem==0
gen num=1
collapse (sum) value (count) num_HS6_imp=num, by(party_id countrycode coun_aim year)
save customs_0015\imp\customs_0015_imp_firm_cty_nointem,replace

use customs_0015\imp\customs_0015_imp,clear
gen num=1
collapse (sum) value (count) num_cty_imp=num, by(party_id HS6 HS2 HS4 year intem)
save customs_0015\imp\customs_0015_imp_firm_HS6,replace

use customs_0015\imp\customs_0015_imp,clear
collapse (sum) value, by(countrycode coun_aim HS6 HS2 HS4 year intem)
save customs_0015\imp\customs_0015_imp_cty_HS6,replace

use customs_0015\imp\customs_0015_imp_cty_HS6,clear
collapse (sum) value, by(countrycode coun_aim)
gsort -value
gen rank_imp=_n
gen top50_imp=1 if rank_imp<=50
replace top50_imp=0 if rank_imp>50
gen top30_imp=1 if rank_imp<=30
replace top30_imp=0 if rank_imp>30
save customs_0015\imp\customs_0015_imp_rank,replace

use customs_0015\imp\customs_0015_imp_firm_HS6,clear
collapse (sum) value_f_imp=value num_cty_imp, by(party_id year)
save customs_0015\imp\customs_0015_imp_firm,replace

*===============================================================================

* Two-way trader firm list

cd "D:\Project G"
use customs_0015\imp\customs_0015_imp_firm,clear
merge 1:1 party_id year using customs_0015\exp\ustoms_0015_exp_firm,nogen keep(matched)
save customs_0015\customs_0015_twoway_firm,replace

* Top 50 export destinations and top 50 import sources

cd "D:\Project G"
use customs_0015\exp\customs_0015_exp_rank,clear
merge 1:1 countrycode coun_aim using customs_0015\imp\customs_0015_imp_rank,nogen
keep if top50_exp==1 | top50_imp==1
save customs_0015\customs_0015_top50,replace

*-------------------------------------------------------------------------------

* Keep top 50 trading (import or export) partners in the firm-country level sample

cd "D:\Project G"
use customs_0015\imp\customs_0015_imp_firm_cty_intem,clear
merge n:1 countrycode coun_aim using customs_0015\customs_0015_top50,nogen keep(matched) keepus(rank_*)
egen group_id=group(party_id countrycode)
xtset group_id year
by group_id: egen year_count=count(year)
by group_id: gen age_imp=_n
drop if year_count<=1
save customs_0015\imp\customs_0015_imp_firm_cty_top50,replace

*-------------------------------------------------------------------------------

* Construct a balanced panel with all years for each firm-country pair

cd "D:\Project G"
use customs_0015\imp\customs_0015_imp_firm_cty_top50,clear
** Create a complete dataset with all IDs
keep group_id party_id countrycode coun_aim year_count
duplicates drop
** Create a complete dataset with all ID and years
gen year=2000
expand 16
bys group_id: replace year=year+_n-1
** Merge with original data to fill in missing years
merge 1:1 group_id year using customs_0015\imp\customs_0015_imp_firm_cty_top50, nogen keep(matched master)
drop rank_*
merge n:1 countrycode coun_aim using customs_0015\customs_0015_top50,nogen keep(matched master) keepus(rank_*)
replace num_HS6=0 if num_HS6==.
xtset group_id year
by group_id: replace age_imp=age_imp[_n-1] if age_imp==. & age_imp[_n-1]!=.
by group_id: replace age_imp=0 if age_imp==.
replace value=0 if value==.
save customs_0015\imp\customs_0015_imp_firm_cty_balanced,replace

*-------------------------------------------------------------------------------

* Construct the extensive margin sample (firm-country level)

cd "D:\Project G"
use customs_0015\imp\customs_0015_imp_firm_cty_balanced,clear
** Denote firms' existence in the market
gen imp_fc=1 if value>0
replace imp_fc=0 if value==0
by group_id: gen entry_fc=1 if imp_fc[_n-1]==0 & imp_fc==1
by group_id: gen cont_fc=1 if imp_fc[_n-1]==1 & imp_fc==1 & imp_f[_n+1]==1
by group_id: gen exit_fc=1 if imp_fc[_n-1]==1 & imp_fc==0
bys party_id year: egen imp_f=max(imp_fc)
global status "entry cont exit"
foreach i of global status{
	replace `i'_fc=0 if `i'_fc==.
}
** Add firm-level controls
merge n:1 party_id year using customs_0015\imp\customs_0015_imp_firm,nogen keep(matched master)
gen lnvalue_f_imp=ln(value_f_imp)
replace lnvalue_f_imp=0 if lnvalue_f_imp==.
gen lnnum_cty_imp=ln(num_cty_imp)
replace lnnum_cty_imp=0 if lnnum_cty_imp==.
** Add country-level controls
egen cty_id=group(countrycode)
merge n:1 countrycode year using ER\RER_99_19_dev,nogen keep(matched) keepus(dlnNER dlnRER dlnrgdp lnrgdp dev_large rev_large)
merge n:1 countrycode year using gravity\gravity_CHN_imp,nogen keep(matched)
xtset group_id year
save samples\samples_0015_imp_firm_ext,replace

* Country-level numbers of entry and exit

cd "D:\Project G"
use samples\samples_0015_imp_firm_ext,clear
collapse (sum) entry_c=entry_fc exit_c=exit_fc imp_c=imp_fc, by(countrycode coun_aim cty_id year dlnNER dlnRER dlnrgdp $gravity dev_large rev_large)
xtset cty_id year
save samples\samples_0015_imp_cty_num,replace

* Firm-level numbers of entry and exit

cd "D:\Project G"
use samples\samples_0015_imp_firm_ext,clear
collapse (sum) entry_f=entry_fc exit_f=exit_fc imp_f=imp_fc, by(party_id year $firm_control)
gen switch_f=entry_f+exit_f
merge n:1 year using ER\US_NER_99_19,nogen keep(matched) keepus(NER_US dlnNER_US)
save samples\samples_0015_imp_firm_num,replace