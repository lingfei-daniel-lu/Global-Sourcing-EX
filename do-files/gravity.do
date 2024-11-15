* Gravity
cd "D:\Project G\gravity"
use "E:\Data\Gravity\Gravity_V202202.dta",clear
keep if iso3_d == "CHN" & year>=1999 & year<=2019
rename iso3_o countrycode
merge m:1 countrycode using "D:\Project C\customs data\customs_country_namecode",nogen keep(matched)
gen wto=min(wto_o,wto_d)
collapse (mean) distw=distw_harmonic contig comlang=comlang_off diplo_dis=diplo_disagreement wto rta (sum) gdpcap=gdpcap_o, by (countrycode year)
gen g_distw=1/distw*1000
replace gdpcap=gdpcap/10
save gravity_CHN_imp, replace

* Large Devaluation and Revaluation
cd "D:\Project G\ER"
use RER_99_19,clear
gen lnrgdp=ln(rgdpna)
drop if dlnRER==.
gen dev_large=0
replace dev_large=1 if dlnRER<-0.2
gen rev_large=0
replace rev_large=1 if dlnRER>0.2
save RER_99_19_dev,replace

* Macro Trend of China
cd "D:\Project G\ER"
use PWT1001_80_19,clear
keep if countrycode=="CHN"
save PWT_CHN,replace
