*-------------------------------------------------------------------------------

* 1. Distribution of Chinese imports

cd "D:\Project G"
use customs_0015\imp\customs_0015_imp_cty_HS6,clear
merge n:1 countrycode coun_aim using customs_0015\customs_0015_top50,nogen keep(matched)
gen num=1
collapse (sum) value_HS6_imp=value (count) num_cty=num, by(HS6 HS2 HS4 year)
collapse (mean) num_cty, by(HS6)
hist num_cty, width(1) start(0) frequency ytitle(Number of HS6 products) xtitle(Average number of sources per HS6 product) 
*kdensity kdenopts(width(1))
graph export figures\import_distribution_HS6.png, as(png) replace

cd "D:\Project G"
use customs_0015\imp\customs_0015_imp_firm_cty_top50,clear
gen num=1
collapse (sum) value_firm_imp=value (count) num_cty=num, by(party_id year)
collapse (mean) num_cty, by(party_id)
keep if num_cty>1
hist num_cty, width(1) start(1) ytitle(Percentage of firms) xtitle(Average number of sources per firm) 
*kdensity kdenopts(width(0.5))
graph export figures\import_distribution_firm.png, as(png) replace

*-------------------------------------------------------------------------------

* 2. Overall trend of global sourcing

cd "D:\Project G"
use samples\samples_0015_imp_firm_num,clear

gen imp=1 if imp_f>0
replace imp=0 if imp_f==0
collapse (sum) imp imp_f, by(year)
gen num_cty_f=imp_f/imp
merge 1:1 year using ER\PWT_CHN,nogen keep(matched)
replace rgdpna=rgdpna/1000
sort year

twoway (line imp year, legend(label(1 "Importing firms"))) (line rgdpna year, legend(label(2 "Real GDP")) yaxis(2)), ytitle(Number of importing firms) ytitle(Real GDP in billion USD, axis(2))

twoway (bar num_cty_f year), ytitle(Number of importing firms)

*-------------------------------------------------------------------------------

* 2. Correlation of entry and exit

cd "D:\Project G"
use samples\samples_0015_imp_firm_num,clear
collapse (mean) entry_f exit_f imp_f, by(year)
twoway (scatter entry_f exit_f, legend(label(1 "Years")) ) (lfit entry_f exit_f), ytitle(Average number of market entries per firm) xtitle(Average number of market exits per firm)
graph export figures\corr_entry_exit_firm_avg.png, as(png) replace

cd "D:\Project G"
use samples\samples_0015_imp_cty_num,clear

preserve
collapse (mean) entry_c exit_c imp_c, by(countrycode year)
gen lgentry_c=log10(entry_c)
gen lgexit_c=log10(exit_c)
twoway (scatter lgentry_c lgexit_c, legend(label(1 "Country-Year pairs")) msize(vsmall)) (lfit lgentry_c lgexit_c), ytitle(Average (log10) number of firm entries per market) xtitle(Average (log10) number of firm exits per market)
graph export figures\corr_entry_exit_cty_year.png, as(png) replace
restore

preserve
collapse (mean) entry_c exit_c imp_c, by(year)
twoway (scatter entry_c exit_c, legend(label(1 "Years"))) (lfit entry_c exit_c), ytitle(Average number of firm entries per market) xtitle(Average number of firm exits per market)
graph export figures\corr_entry_exit_cty_avg.png, as(png) replace
restore

preserve
keep if countrycode=="USA"
tsset year
twoway (tsline exit_c) (tsline imp_c) (tsline dlnRER, recast(spike) yaxis(2))
restore

*-------------------------------------------------------------------------------

* 3. Exchange rate fluctuations

cd "D:\Project G\ER"
use RER_99_19_dev,clear

twoway (dropline dlnRER year if countrycode=="USA", legend(label(1 "USA (Dollar)"))) (dropline dlnRER year if countrycode=="DEU", legend(label(2 "Germany (Euro)")))

twoway (dropline dlnRER year if countrycode=="JPN", legend(label(1 "Japan (Yen)"))) (dropline dlnRER year if countrycode=="KOR", legend(label(2 "South Korea (Won)")))
