cd "D:\Project G"
use SD\sd_adj1_0716,clear
drop if id=="" | frdm=="" | frdm=="000000000" | qymc==""
keep frdm qymc id year
gen strlen_id=strlen(id)
drop if strlen_id>18
gen id_15=id if strlen_id==15
replace id_15=substr(id,3,15) if strlen_id==18
replace id_15=substr(id,1,15) if frdm==substr(id,7,9)
drop id strlen*
gen region_full=substr(id_15,1,6)
destring region_full,replace force
drop if region_full==.| substr(id_15,1,1)=="0"
foreach word in " " "0" "()" "*"{
replace qymc=subinstr(qymc,"`word'","",.)
}
duplicates drop
format qymc %40s
sort id_15 qymc year
save SD\sd_id_0716,replace

keep if year<=2015
by id_15 qymc: egen year_count=count(year)

cd "D:\Project G"
use SD\sd_index_0716,clear
duplicates report frdm year
keep frdm year
duplicates drop
sort frdm year
save SD\sd_frdm_0716,replace

