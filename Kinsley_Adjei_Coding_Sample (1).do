* ==============================================================================
* Agribusiness Analysis in Ghana
* For Dr. Abigail A. Adaku
* Author: Kinsley Delanyo Adjei
* Date: July 2025
* 
* Description: Structural and performance analysis of Ghana's agribusiness sector
* using three data sources:
*   (1) IBES 2024 - Integrated Business Establishment Survey (Ghana Statistical Service)
*   (2) IBES 2014 - Earlier wave for trend comparison
*   (3) GSEPS Wave 3 (2018/19) - Ghana Socioeconomic Panel Survey
*
* Key outputs:
*   - Agribusiness structure by region, district, ownership, size, and value chain
*   - Revenue, cost, and profit by ISIC sub-sector
*   - Revenue-per-employee ratios across agribusiness value chains
* ==============================================================================

* ==============================================================================
* SETUP
* ==============================================================================

clear all
set more off

* Set working directory (update path as needed)
cd "/Users/kingdela/Desktop/Academics/Dr Adaku/IBES"

* ==============================================================================
* SECTION 0: DEFINE ISIC LABELS (shared across all datasets)
* ==============================================================================

* Standard ISIC Rev. 4 labels for agribusiness codes used throughout this script
label define ISIC ///
	111 "Growing cereals (except rice), legumes & oilseeds" ///
	112 "Growing of rice" ///
	113 "Growing vegetables, melons, roots & tubers" ///
	114 "Growing of sugarcane" ///
	115 "Growing of tobacco" ///
	116 "Growing of fibre crops" ///
	119 "Growing other non-perennial crops" ///
	121 "Growing of grapes" ///
	122 "Growing tropical & subtropical fruits" ///
	123 "Growing of citrus fruits" ///
	124 "Growing pome & stone fruits" ///
	125 "Growing other tree & bush fruits & nuts" ///
	126 "Growing of oleaginous fruits" ///
	127 "Growing of beverage crops" ///
	128 "Growing spices, aromatic, drug & pharmaceutical crops" ///
	129 "Growing other perennial crops" ///
	130 "Plant propagation" ///
	141 "Raising of cattle and buffaloes" ///
	142 "Raising of horses & other equines" ///
	143 "Raising of camels & camelids" ///
	144 "Raising of sheep & goats" ///
	145 "Raising of swine and pigs" ///
	146 "Raising of poultry" ///
	149 "Raising of other animals" ///
	150 "Mixed farming" ///
	161 "Support activities for crop production" ///
	162 "Support activities for animal production" ///
	163 "Post-harvest crop activities" ///
	164 "Seed processing for propagation" ///
	170 "Hunting, trapping and related service activities" ///
	210 "Silviculture and other forestry activities" ///
	220 "Logging" ///
	230 "Gathering of non-wood forest products" ///
	240 "Support services to forestry" ///
	311 "Marine fishing" ///
	312 "Freshwater fishing" ///
	321 "Marine aquaculture" ///
	322 "Freshwater aquaculture" ///
	330 "Support activities for fishing & aquaculture" ///
	1020 "Processing & preservation of fish, crustaceans & molluscs" ///
	1030 "Processing & preservation of fruit & vegetables" ///
	1040 "Manufacture of vegetable & animal oils & fats" ///
	1050 "Manufacture of dairy products" ///
	1061 "Manufacture of grain mill products" ///
	1062 "Manufacture of starches & starch products" ///
	1071 "Manufacture of bakery products" ///
	1072 "Manufacture of sugar" ///
	1073 "Manufacture of cocoa, chocolate & sugar confectionery" ///
	1076 "Processing of coffee & tea" ///
	1079 "Manufacture of other food products n.e.c." ///
	1080 "Manufacture of prepared animal feeds" ///
	1104 "Manufacture of malt" ///
	1200 "Manufacture of tobacco products" ///
	2012 "Manufacture of fertilisers & nitrogen compounds" ///
	2021 "Manufacture of pesticides & other agrochemical products" ///
	2821 "Manufacture of agricultural & forestry machinery" ///
	4620 "Wholesale of agricultural raw materials & live animals" ///
	4653 "Wholesale of agricultural machinery, equipment & supplies" ///
	4711 "Non-specialised retail sale (food, beverages or tobacco)" ///
	4721 "Retail sale of food" ///
	4722 "Retail sale of beverages" ///
	4723 "Retail sale of tobacco products"

* Local macro listing all agribusiness ISIC codes (reused in keep/inlist statements)
local agri_isic 111 112 113 114 115 116 119 121 122 123 124 125 126 127 128 129 ///
	130 141 142 143 144 145 146 149 150 161 162 163 164 170 210 220 230 240 ///
	311 312 321 322 330 1020 1030 1040 1050 1061 1062 1071 1072 1073 1076 ///
	1079 1080 1104 1200 2012 2021 2821 4620 4653 4711 4721 4722 4723

* ==============================================================================
* HELPER PROGRAM: assign_categories
* Assigns value chain (vchain_cat) and sector (sector_cat) variables
* Arguments: varname = ISIC variable to classify on
* ==============================================================================

capture program drop assign_categories
program define assign_categories
	args varname

	* Value chain classification
	gen vchain_cat = ""
	replace vchain_cat = "Input Supply"     if inlist(`varname', 130, 141, 164, 2012, 2021, 2821, 4653)
	replace vchain_cat = "Farming"          if inlist(`varname', 111, 112, 113, 114, 115, 116, 119, ///
		121, 122, 123, 124, 125, 126, 127, 128, 129, 142, 143, 144, 145, 146, 149, 150, ///
		170, 210, 311, 312, 321, 322)
	replace vchain_cat = "Support Services" if inlist(`varname', 161, 162, 220, 230, 240, 330)
	replace vchain_cat = "Processing"       if inlist(`varname', 163, 1020, 1030, 1040, 1050, ///
		1061, 1062, 1071, 1072, 1073, 1076, 1079, 1080, 1104, 1200)
	replace vchain_cat = "Wholesale"        if inlist(`varname', 4620)
	replace vchain_cat = "Retail"           if inlist(`varname', 4711, 4721, 4722, 4723)
	label variable vchain_cat "Value Chain Category"

	* Sub-sector classification
	gen sector_cat = ""
	replace sector_cat = "Input Supply"      if inlist(`varname', 130, 141, 164, 2012, 2021, 2821, 4653)
	replace sector_cat = "Crops"             if inlist(`varname', 111, 112, 113, 114, 115, 116, 119, ///
		121, 122, 123, 124, 125, 126, 127, 128, 129)
	replace sector_cat = "Livestock"         if inlist(`varname', 142, 143, 144, 145, 146, 149, 170)
	replace sector_cat = "Mixed Farming"     if inlist(`varname', 150)
	replace sector_cat = "Forestry & Logging" if inlist(`varname', 210, 220, 230)
	replace sector_cat = "Fishing"           if inlist(`varname', 311, 312)
	replace sector_cat = "Aquaculture"       if inlist(`varname', 321, 322)
	replace sector_cat = "Support Services"  if inlist(`varname', 161, 162, 240, 330)
	replace sector_cat = "Agro-processing"   if inlist(`varname', 163, 1020, 1030, 1040, 1050, ///
		1061, 1062, 1071, 1072, 1073, 1076, 1079, 1080, 1104, 1200)
	replace sector_cat = "Wholesale"         if inlist(`varname', 4620)
	replace sector_cat = "Retail"            if inlist(`varname', 4711, 4721, 4722, 4723)
	label variable sector_cat "Agribusiness Sub-Sector"
end

* ==============================================================================
* SECTION 1: IBES 2024 ANALYSIS
* ==============================================================================

use "IBES 2024.dta", clear

* ------------------------------------------------------------------------------
* 1.1 Data cleaning
* ------------------------------------------------------------------------------

* ssc install mdesc  // uncomment on first run
mdesc

* Flag and drop observations missing key analysis variables (0.2% of data)
egen nmis = rmiss(c16a c18 c19 e21 f1 f4 f6 h1 j1a region)
drop if nmis > 0
drop nmis

count  // Expected: ~650,223 observations

* ------------------------------------------------------------------------------
* 1.2 Apply ISIC labels and classify into value chains / sectors
* ------------------------------------------------------------------------------

label values fin_isic4p ISIC
assign_categories fin_isic4p

* ------------------------------------------------------------------------------
* 1.3 Business size classification (by total employment)
* ------------------------------------------------------------------------------

* e21 = total number of employees
gen size_cat = ""
replace size_cat = "Micro"  if e21 >= 1   & e21 <= 5
replace size_cat = "Small"  if e21 >= 6   & e21 <= 30
replace size_cat = "Medium" if e21 >= 31  & e21 <= 100
replace size_cat = "Large"  if e21 > 100  & !missing(e21)
label variable size_cat "Business Size Category"

label define size_lbl 1 "Micro (1-5)" 2 "Small (6-30)" 3 "Medium (31-100)" 4 "Large (>100)"
encode size_cat, gen(size_cat_encoded) label(size_lbl)

* ------------------------------------------------------------------------------
* 1.4 Region labels (16-region structure)
* ------------------------------------------------------------------------------

label define region_lbl 1 "Western" 2 "Central" 3 "Greater Accra" 4 "Volta" ///
	5 "Eastern" 6 "Ashanti" 7 "Western North" 8 "Ahafo" 9 "Bono" 10 "Bono East" ///
	11 "Oti" 12 "Northern" 13 "Savannah" 14 "North East" 15 "Upper East" 16 "Upper West"
label values region region_lbl

* ------------------------------------------------------------------------------
* 1.5 Structure analysis
* ------------------------------------------------------------------------------

* Distribution by ISIC, region, and district
tab fin_isic4p, sort
tab region, sort
tab district, sort

* Ownership: local vs. foreign
tab c19, sort
tab region c19, row

* Ownership type: sole proprietorship vs. corporate
tab c18, sort
tab c18 size_cat

* Revenue brackets by ISIC
tab fin_isic4p j1a, row

* Employment statistics by business size
tabstat e21, by(size_cat) statistics(mean p50 sd min max) columns(statistics)

* Value chain and sector distribution
tab vchain_cat sector_cat
tab vchain_cat region
tab sector_cat region

* ------------------------------------------------------------------------------
* 1.6 Performance analysis: revenue per employee
* ------------------------------------------------------------------------------

preserve

	* Validate required variables
	capture confirm variable j1a e21
	if _rc {
		display as error "Variables j1a and/or e21 not found."
		exit 111
	}

	* Clean employment and revenue bracket variables
	replace e21  = . if e21 < 0
	replace j1a  = . if j1a < 1 | j1a > 13

	* Revenue band bounds (GHS) — j1a is a categorical revenue bracket variable
	collapse (mean) e21, by(j1a)
	drop if missing(j1a)

	* Define revenue band labels and bounds
	gen str25  revenue_band = ""
	gen double rev_lower    = .
	gen double rev_upper    = .

	local codes  1     2      3      4       5       6       7        8        9        10        11         12         13
	local labels `""1–10,000" "10,001–30,000" "30,001–50,000" "50,001–100,000" "100,001–200,000" "200,001–500,000" "500,001–1,000,000" "1,000,001–5,000,000" "5,000,001–6,000,000" "6,000,001–10,000,000" "10,000,001–20,000,000" "20,000,001+" "0"'
	local lowers 1     10001  30001  50001   100001  200001  500001   1000001  5000001  6000001   10000001   20000001   0
	local uppers 10000 30000  50000  100000  200000  500000  1000000  5000000  6000000  10000000  20000000   .          0

	local n : word count `codes'
	forvalues i = 1/`n' {
		local c : word `i' of `codes'
		local l : word `i' of `lowers'
		local u : word `i' of `uppers'
		replace revenue_band = "`: word `i' of `labels''" if j1a == `c'
		replace rev_lower    = `l'                         if j1a == `c'
		replace rev_upper    = `u'                         if j1a == `c' & `c' != 12
	}

	* Revenue per employee (lower and upper bounds)
	gen double lower_rpe = rev_lower / e21 if e21 > 0
	gen double upper_rpe = rev_upper / e21 if e21 > 0 & !missing(rev_upper)

	label variable revenue_band "Revenue Band (GHS)"
	label variable rev_lower    "Revenue Lower Bound (GHS)"
	label variable rev_upper    "Revenue Upper Bound (GHS)"
	label variable e21          "Mean Employees"
	label variable lower_rpe    "Revenue per Employee — Lower (GHS)"
	label variable upper_rpe    "Revenue per Employee — Upper (GHS)"

	sort j1a
	list revenue_band rev_lower rev_upper e21 lower_rpe upper_rpe, noobs clean separator(0)

	* Save for merge
	keep revenue_band rev_lower rev_upper e21 lower_rpe upper_rpe j1a
	tempfile revenue_summary
	save `revenue_summary'

restore

merge m:1 j1a using `revenue_summary', keep(master match) nogen

* Revenue per employee by sub-sector
preserve
	collapse (mean) rev_lower rev_upper lower_rpe upper_rpe, by(sector_cat)
	list sector_cat rev_lower rev_upper lower_rpe upper_rpe, noobs clean
restore

* ------------------------------------------------------------------------------
* 1.7 Additional performance indicators
* ------------------------------------------------------------------------------

* Revenue by registration status
tab j1a c16a, missing row

* Export participation
gen export_part = (f6 >= 2 & f6 <= 5) if !missing(f6)
label define yesno 0 "No" 1 "Yes"
label values export_part yesno
label variable export_part "Export Participation"

tab export_part
tab f6
tab export_part sector_cat, row
tab f6 sector_cat, row

* Digital finance adoption
gen digifinance = (h1 != "" & h1 != "0")
label variable digifinance "Uses Digital Finance"
label values digifinance yesno

tab digifinance sector_cat, row

* Sustainable practices adoption
tab g4
tab g4 sector_cat, row

* Districts with limited wholesale and agro-processing
tab district if sector_cat == "Wholesale",      sort
tab district if sector_cat == "Agro-processing", sort

* Business establishment dates
tab f1, sort

* Multi-agency registration
gen num_agencies = strlen(c16b)
gen multi_reg    = (num_agencies > 1)
label variable num_agencies "Number of Agencies Registered With"
label variable multi_reg    "Registered With >1 Agency"
tab num_agencies
tab num_agencies size_cat
tab multi_reg

* ==============================================================================
* SECTION 2: IBES 2014 — TREND COMPARISON
* ==============================================================================

use "IBES 2014_V2.dta", clear

* ------------------------------------------------------------------------------
* 2.1 Data cleaning
* ------------------------------------------------------------------------------

mdesc

egen nmis2 = rmiss(sdq1 scq14a scq14b scq14c shq2)
drop if nmis2 > 0
drop nmis2

count  // Expected: ~141,353 observations

* Keep only agribusiness ISIC codes
keep if inlist(sdq2, 111, 112, 113, 114, 115, 116, 119, 121, 122, 123, 124, 125, ///
	126, 127, 128, 129, 130, 141, 142, 143, 144, 145, 146, 149, 150, 161, 162, ///
	163, 164, 170, 210, 220, 230, 240, 311, 312, 321, 322, 330, 1020, 1030, 1040, ///
	1050, 1061, 1062, 1071, 1072, 1073, 1076, 1079, 1080, 1104, 1200, 2012, 2021, ///
	2821, 4620, 4653, 4711, 4721, 4722, 4723)

* ------------------------------------------------------------------------------
* 2.2 Apply ISIC labels, classify value chain and sector
* ------------------------------------------------------------------------------

label values sdq2 ISIC
assign_categories sdq2

* ------------------------------------------------------------------------------
* 2.3 Business size (seq1tot = total employment in 2014 survey)
* ------------------------------------------------------------------------------

gen size_cat = ""
replace size_cat = "Micro"  if seq1tot >= 1  & seq1tot <= 5
replace size_cat = "Small"  if seq1tot >= 6  & seq1tot <= 30
replace size_cat = "Medium" if seq1tot >= 31 & seq1tot <= 100
replace size_cat = "Large"  if seq1tot > 100 & !missing(seq1tot)
label variable size_cat "Business Size Category"

label define size_lbl2 1 "Micro (1-5)" 2 "Small (6-30)" 3 "Medium (31-100)" 4 "Large (>100)"
encode size_cat, gen(size_cat_encoded) label(size_lbl2)

* ------------------------------------------------------------------------------
* 2.4 Recode 2014 districts to 16-region structure
* (Ghana's region boundaries were redrawn in 2019; IBES 2014 uses 10-region codes)
* ------------------------------------------------------------------------------

gen region16 = ""
replace region16 = "Western"      if inlist(dist_code, 101,102,103,104,105,106,107,108,109,110,111,118,119)
replace region16 = "Western North" if inlist(dist_code, 112,113,114,115,116,117,120,121,122)
replace region16 = "Central"      if inrange(dist_code, 201, 220)
replace region16 = "Greater Accra" if inrange(dist_code, 301, 316)
replace region16 = "Volta"        if inlist(dist_code, 401,402,403,404,405,406,407,408,409,410,411,415,416,419,420,421,422,423,424)
replace region16 = "Oti"          if inlist(dist_code, 412,413,414,417,418,425)
replace region16 = "Eastern"      if inrange(dist_code, 501, 526)
replace region16 = "Ashanti"      if inrange(dist_code, 601, 630)
replace region16 = "Ahafo"        if inlist(dist_code, 701,702,703,706,707,723)
replace region16 = "Bono"         if inlist(dist_code, 704,705,708,709,710,711,712,713,714,724,726)
replace region16 = "Bono East"    if inlist(dist_code, 715,716,717,718,719,720,721,722,725,727)
replace region16 = "Savannah"     if inlist(dist_code, 801,802,803,804,805,821)
replace region16 = "Northern"     if inlist(dist_code, 806,807,808,809,810,811,812,813,814,815,816,822,823,824,825)
replace region16 = "North East"   if inlist(dist_code, 817,818,819,820,826)
replace region16 = "Upper East"   if inrange(dist_code, 901, 913)
replace region16 = "Upper West"   if inrange(dist_code, 1001, 1011)

encode region16, gen(region16_num)
label values region16_num region_lbl

* ------------------------------------------------------------------------------
* 2.5 Structure analysis (mirrors Section 1 for comparability)
* ------------------------------------------------------------------------------

tab sdq2, sort
tab region16_num, sort
tab dist_code, sort

tab scq13a, sort           // Ownership: local vs. foreign
tab region16_num scq13a, row

tab scq12, sort            // Ownership type
tab scq12 size_cat

tabstat seq1tot, by(size_cat) statistics(mean p50 sd min max) columns(statistics)

tab vchain_cat region16_num
tab sector_cat region16_num
tab sdq4 vchain_cat, row   // Secondary activities

* Registration and compliance
tab c16a size_cat, missing row
gen num_agencies = strlen(c16b)
gen multi_reg    = (num_agencies > 1)
tab num_agencies size_cat
tab multi_reg

* Digital finance adoption (2014)
gen digifinance = (h2a != "" & h2a != "0")
label variable digifinance "Uses Digital Finance"
label values digifinance yesno
tab digifinance sector_cat, row

* Sustainable practices
tab g4
tab g4 sector_cat, row

* Establishment dates
tab shq1, sort

* ==============================================================================
* SECTION 3: GSEPS WAVE 3 (2018/19) — INCOME, REVENUE & PROFIT BY ISIC
* ==============================================================================

cd "/Users/kingdela/Desktop/Academics/Dr Adaku/IBES/gseps-w3-2018-2019-v1-stata/gseps-w3-2018-2019-v1-stata"

* ==============================================================================
* SECTION 3A: EMPLOYMENT INCOME BY ISIC (paid employment)
* ==============================================================================

use "01fa_employmentscreener.dta", clear
merge 1:1 hhmid FPrimary using "01fi_employmentmain.dta"
tab _merge
drop _merge

mdesc

* Drop observations missing occupation code or pay amount
egen nmis3 = rmiss(paidamount tradecode)
drop if nmis3 > 0
drop nmis3

* Convert trade code to numeric if stored as string
capture confirm numeric variable tradecode
if _rc destring tradecode, replace

* Keep agribusiness ISIC codes
keep if inlist(tradecode, 111, 112, 113, 114, 115, 116, 119, 121, 122, 123, 124, ///
	125, 126, 127, 128, 129, 130, 141, 142, 143, 144, 145, 146, 149, 150, 161, ///
	162, 163, 164, 170, 210, 220, 230, 240, 311, 312, 321, 322, 330, 1020, 1030, ///
	1040, 1050, 1061, 1062, 1071, 1072, 1073, 1076, 1079, 1080, 1104, 1200, 2012, ///
	2021, 2821, 4620, 4653, 4711, 4721, 4722, 4723)

label values tradecode ISIC

* Mean paid income by ISIC — farm owners and business owners separately
preserve
	collapse (mean) paidamount, by(tradecode farmowner paidperiod)
	keep if farmowner == 1
	list tradecode paidperiod paidamount, noobs clean sep(5)
restore

preserve
	collapse (mean) paidamount, by(tradecode businessowner paidperiod)
	keep if businessowner == 1
	list tradecode paidperiod paidamount, noobs clean sep(5)
restore

* ==============================================================================
* SECTION 3B: BUSINESS REVENUE, COST & PROFIT BY ISIC
* ==============================================================================

use "05_bizsection.dta", clear
sort FPrimary enterpriseid
merge 1:1 FPrimary enterpriseid using "05ai_basicinfo.dta"
tab _merge
drop _merge

mdesc

* Drop observations missing key financial variables
egen nmis4 = rmiss(profit timeperiod averagesalesaverage averagesaleshigh ///
	averagesaleslow averagecostsaverage averagecostshigh averagecostslow)
drop if nmis4 > 0
drop nmis4

* Keep agribusiness ISIC codes
keep if inlist(mainindustrycode, 111, 112, 113, 114, 115, 116, 119, 121, 122, 123, ///
	124, 125, 126, 127, 128, 129, 130, 141, 142, 143, 144, 145, 146, 149, 150, ///
	161, 162, 163, 164, 170, 210, 220, 230, 240, 311, 312, 321, 322, 330, 1020, ///
	1030, 1040, 1050, 1061, 1062, 1071, 1072, 1073, 1076, 1079, 1080, 1104, 1200, ///
	2012, 2021, 2821, 4620, 4653, 4711, 4721, 4722, 4723)

label values mainindustrycode ISIC

* Annualise profit (reported over varying time periods)
* timeperiod: 1=daily, 2=weekly, 3=fortnightly, 4=monthly, 5=annual
gen multiplier = .
replace multiplier = 365 if timeperiod == 1
replace multiplier = 52  if timeperiod == 2
replace multiplier = 26  if timeperiod == 3
replace multiplier = 12  if timeperiod == 4
replace multiplier = 1   if timeperiod == 5
replace multiplier = .   if inrange(timeperiod, -999, -666)  // flag invalid codes

gen annual_profit = profit * multiplier
label variable annual_profit "Annualised Profit (GHS)"

* Annualise revenue and costs (all reported monthly)
gen annual_arevenue = averagesalesaverage * 12
gen annual_hrevenue = averagesaleshigh    * 12
gen annual_lrevenue = averagesaleslow     * 12
gen annual_acost    = averagecostsaverage * 12
gen annual_hcost    = averagecostshigh    * 12
gen annual_lcost    = averagecostslow     * 12

save "05_merged_bizinfo.dta", replace

* Summary: mean profit, revenue and cost by ISIC
preserve
	collapse (mean) annual_profit annual_arevenue annual_acost, by(mainindustrycode)
	format annual_profit annual_arevenue annual_acost %12.0f
	list mainindustrycode annual_profit annual_arevenue annual_acost, noobs clean sep(5)
restore

* ==============================================================================
* SECTION 3C: REVENUE PER EMPLOYEE (business sector)
* ==============================================================================

use "05bi_allemployees.dta", clear
sort FPrimary enterpriseid
merge 1:1 FPrimary enterpriseid using "05_merged_bizinfo.dta"
tab _merge
drop _merge

* Total employees (handle cases where one gender count is missing)
egen total_employees = rowtotal(currentworkers_m currentworkers_f)
replace total_employees = . if total_employees == 0  // avoid division by zero

gen rev_per_emp = annual_arevenue / total_employees
label variable total_employees "Total Current Employees"
label variable rev_per_emp     "Revenue per Employee (GHS)"

assign_categories mainindustrycode

* Size classification
gen size_cat = ""
replace size_cat = "Micro"  if total_employees >= 1  & total_employees <= 5
replace size_cat = "Small"  if total_employees >= 6  & total_employees <= 30
replace size_cat = "Medium" if total_employees >= 31 & total_employees <= 100
replace size_cat = "Large"  if total_employees > 100 & !missing(total_employees)

encode size_cat, gen(size_cat_encoded) label(size_lbl)

* Revenue per employee by ISIC and sector
preserve
	collapse (mean) annual_arevenue total_employees rev_per_emp, by(mainindustrycode)
	format annual_arevenue rev_per_emp %12.0f
	list mainindustrycode annual_arevenue total_employees rev_per_emp, noobs clean sep(5)
restore

* Revenue by business size
preserve
	collapse (mean) annual_arevenue, by(size_cat_encoded)
	list size_cat_encoded annual_arevenue, noobs clean
restore

* Keep variables needed for final combined dataset
keep mainindustrycode annual_profit annual_arevenue annual_acost ///
	total_employees rev_per_emp sector_cat size_cat size_cat_encoded
gen business_type = "business"

save "final_biz_metrics.dta", replace

* ==============================================================================
* SECTION 3D: AGRICULTURAL REVENUE, COST & PROFIT (crop-level panel)
* ==============================================================================

* --- Revenue from crop sales ---

use "04o_cropsalesstoresquestions.dta", clear

* Map crop codes to ISIC codes
gen mainindustrycode = .
replace mainindustrycode = 111 if inlist(cropcode, 19, 21, 15, 3, 14, 44)   // Cereals & legumes
replace mainindustrycode = 112 if cropcode == 31                              // Rice
replace mainindustrycode = 113 if inlist(cropcode, 5, 40, 30, 8, 37, 24, 23, 17, 12, 38, 43) // Vegetables/roots
replace mainindustrycode = 114 if cropcode == 34                              // Sugarcane
replace mainindustrycode = 116 if inlist(cropcode, 11, 16)                    // Fibre crops
replace mainindustrycode = 119 if inlist(cropcode, 35, 13)                    // Other non-perennial
replace mainindustrycode = 122 if inlist(cropcode, 1, 2, 20, 26, 28, 42)     // Tropical fruits
replace mainindustrycode = 123 if inlist(cropcode, 18, 25)                    // Citrus fruits
replace mainindustrycode = 125 if inlist(cropcode, 4, 7, 32, 33)             // Tree nuts
replace mainindustrycode = 126 if cropcode == 22                              // Oil palm
replace mainindustrycode = 127 if inlist(cropcode, 6, 9, 10)                 // Beverage crops (cocoa, coffee, cola)
replace mainindustrycode = 128 if cropcode == 27                              // Spices
replace mainindustrycode = 129 if cropcode == 29                              // Plantain

label values mainindustrycode ISIC

* Compute revenue from each buyer channel (quantity × price)
* Replace missing values with 0 before multiplication
foreach var of varlist *soldquantity *soldprice {
	replace `var' = 0 if missing(`var')
}

gen rev_samecomm  = samecommsoldquantity  * samecommsoldprice
gen rev_othercomm = othercommsoldquantity * othercommsoldprice
gen rev_trader    = traderssoldquantity   * traderssoldprice
gen rev_contractor = contractorssoldquantity * contractorssoldprice
gen rev_org       = orgssoldquantity      * orgssoldprice
gen rev_agg       = aggsoldquantity       * aggsoldprice
gen rev_outgrow   = outgrowsoldquantity   * outgrowsoldprice
gen rev_coop      = coopsoldquantity      * coopsoldprice
gen rev_other     = othersoldquantity     * othersoldprice

gen total_revenue = rev_samecomm + rev_othercomm + rev_trader + rev_contractor + ///
	rev_org + rev_agg + rev_outgrow + rev_coop + rev_other

* Mean revenue by ISIC
preserve
	collapse (mean) total_revenue, by(mainindustrycode)
	format total_revenue %12.2f
	list mainindustrycode total_revenue, sep(5) noobs clean
restore

* Collapse to plot level for merging
collapse (sum) total_revenue rev_samecomm rev_othercomm rev_trader rev_contractor ///
	rev_org rev_agg rev_outgrow rev_coop rev_other ///
	(firstnm) mainindustrycode, by(FPrimary plotid)

save "ag_revenue_sale.dta", replace

* --- Labour costs ---

use "labor_cost.dta", clear

gen lcostman   = hiredmen   * hiredavgpayman
gen lcostwoman = hiredwomen * hiredavgpaywoman
replace lcostman   = 0 if missing(lcostman)
replace lcostwoman = 0 if missing(lcostwoman)
gen ag_labor = hiredmen + hiredwomen

collapse (sum) hiredmen hiredwomen lcostman lcostwoman ag_labor, by(FPrimary plotid)
save "labor_cost_collapsed.dta", replace

* --- Input costs (land, ploughing, seed) ---

use "land_plough_seed_cost.dta", clear

* Convert in-kind plough payments to cash equivalents
* Assumed unit prices: maize=80 GHS/bag, millet=140 GHS/bag, soya=84 GHS/bag
local p_maize  = 80
local p_millet = 140
local p_soya   = 84

replace ploughpaymentcash = 1*`p_maize' + 2*`p_millet' if ploughpaymentinkind == "1 beg of maize and 2 begs of millet"
replace ploughpaymentcash = 10*`p_maize'  if ploughpaymentinkind == "10 bags maxi of maize"
replace ploughpaymentcash = 10*`p_maize'  if ploughpaymentinkind == "10 maxi bags of his maize harvest"
replace ploughpaymentcash = 17*`p_maize'  if ploughpaymentinkind == "17 bags of maize for the 20 acres of land ploughed"
replace ploughpaymentcash = 2*`p_soya'    if ploughpaymentinkind == "2 Soya beans"
replace ploughpaymentcash = 2*`p_maize'   if ploughpaymentinkind == "2 bags of maize"
replace ploughpaymentcash = 80            if ploughpaymentinkind == "80"
replace ploughpaymentcash = 4*`p_maize'   if ploughpaymentinkind == "Four bags of maize"
replace ploughpaymentcash = 1*`p_maize'   if inlist(ploughpaymentinkind, "Maize", "One beg of maize for each acra", "One maxi bag of maize")
replace ploughpaymentcash = 3*`p_millet'  if ploughpaymentinkind == "Three begs of millet"

gen land_cost  = rentcashannualvalue + scroppedinkindvalue
gen plough_cost = ploughpaymentcash
gen seed_cost  = seedpaid

foreach var in land_cost plough_cost seed_cost {
	replace `var' = 0 if missing(`var')
}

gen total_input_cost = land_cost + plough_cost + seed_cost
collapse (sum) land_cost plough_cost seed_cost total_input_cost, by(FPrimary plotid)
save "plot_input_costs.dta", replace

* --- Merge labour and input costs ---

use "labor_cost_collapsed.dta", clear
merge 1:1 FPrimary plotid using "plot_input_costs.dta"
tab _merge
drop _merge

egen total_ag_cost = rowtotal(ag_labor total_input_cost)
save "input_labor_costs.dta", replace

* --- Merge revenue and compute profit ---

use "input_labor_costs.dta", clear
merge 1:1 FPrimary plotid using "ag_revenue_sale.dta", nogen

gen ag_profit = total_revenue - total_ag_cost
gen ag_revenue_labor = total_revenue / ag_labor if ag_labor > 0

preserve
	collapse (mean) ag_profit ag_revenue_labor, by(mainindustrycode)
	list mainindustrycode ag_profit ag_revenue_labor, noobs clean sep(5)
restore

save "revenue_labor.dta", replace

* ==============================================================================
* SECTION 3E: COMBINE BUSINESS AND AGRICULTURE DATASETS
* ==============================================================================

* --- Prepare agriculture metrics ---

use "input_labor_costs.dta", clear
merge 1:1 FPrimary plotid using "revenue_labor.dta", nogen

gen annual_profit      = ag_profit
gen annual_arevenue    = total_revenue
gen annual_acost       = total_ag_cost
gen total_employees    = ag_labor
gen rev_per_emp        = ag_revenue_labor
gen business_type      = "agriculture"

assign_categories mainindustrycode

keep mainindustrycode annual_profit annual_arevenue annual_acost ///
	total_employees rev_per_emp sector_cat business_type
save "final_ag_metrics.dta", replace

* --- Append business and agriculture datasets ---

use "final_ag_metrics.dta", clear
append using "final_biz_metrics.dta"

label variable mainindustrycode  "ISIC Industry Code"
label variable annual_profit     "Annual Profit (GHS)"
label variable annual_arevenue   "Annual Revenue (GHS)"
label variable annual_acost      "Annual Total Cost (GHS)"
label variable total_employees   "Number of Employees"
label variable rev_per_emp       "Revenue per Employee (GHS)"
label variable sector_cat        "Agribusiness Sub-Sector"
label variable business_type     "Source: agriculture or business"

* Drop observations missing key metrics
egen nmis6 = rmiss(annual_profit annual_arevenue total_employees rev_per_emp mainindustrycode sector_cat)
drop if nmis6 > 0
drop nmis6

save "combined_ag_biz_metrics.dta", replace

* ==============================================================================
* SECTION 3F: FINAL SUMMARY TABLES
* ==============================================================================

* Mean metrics by ISIC code and sector
preserve
	collapse (mean) annual_profit annual_arevenue annual_acost total_employees rev_per_emp ///
		(count) n_obs = annual_profit, by(mainindustrycode sector_cat)
	format annual_profit annual_arevenue annual_acost rev_per_emp %12.0f
	list mainindustrycode sector_cat annual_profit annual_arevenue rev_per_emp n_obs, noobs clean sep(5)
restore

* Summary statistics (mean, median, SD, min, max, N) by sector
tabstat annual_profit annual_arevenue annual_acost total_employees rev_per_emp, ///
	by(sector_cat) statistics(mean p50 sd min max n) columns(statistics) long

* Summary statistics by ISIC code
tabstat annual_profit annual_arevenue annual_acost total_employees rev_per_emp, ///
	by(mainindustrycode) statistics(mean n) columns(statistics) long

* ==============================================================================
* END OF DO-FILE
* ==============================================================================
