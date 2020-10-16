clear
clear matrix
clear mata
set maxvar 11000

set more off

global path = "C:\Users\rmheath\Dropbox\preexisting garment work\JDE replication data" /* desktop at office */
**global path = "C:\Users\Rachel Heath\Dropbox\preexisting garment work\JDE replication data" /* laptop */

***************************************************
*** TABLES
***************************************************

****** Table 1 -- summary stats
use "$path\JDE HM data -- individual level.dta", clear
gen sum1 = 1 if garment==1 & garmentvill==1
gen sum2 = 1 if garment==0 & work==1 & garmentvill==1
gen sum3 = 1 if work==0 & garmentvill==1
gen sum4 = 1 if garmentvill==1 & work!=.
gen sum5 = 1 if work==1 & garmentvill==0
gen sum6 = 1 if work==0 & garmentvill==0
gen sum7 = 1 if garmentvill==0  & work!=.

local i=1
foreach var of varlist age female /*wager exper*/ educ mothereduc cementfloor married{
	forvalues j=1/7{
		reg `var' if sum`j'==1
		local v`i'm`j' = _b[_cons]
		local v`i's`j' = _se[_cons]
	}
	local i=`i'+1
}
forvalues i=1/6{
di %9.3f `v`i'm1' _col(15) %9.3f `v`i'm2' _col(30) %9.3f `v`i'm3' _col(45) %9.3f `v`i'm4'  _col(60) %9.3f `v`i'm5' _col(75) %9.3f `v`i'm6' _col(90) %9.3f `v`i'm7'
di "[" %9.3f `v`i's1' "]"  _col(15)  "[" %9.3f `v`i's2'  "]"   _col(30)  "[" %9.3f `v`i's3'  "]"   _col(45)  "[" %9.3f `v`i's4' "]"  _col(60)  "[" %9.3f `v`i's5' "]"  _col(75)  "[" %9.3f `v`i's6'  "]"  _col(90)  "[" %9.3f `v`i's7' "]"  
}

** working
local i=1
foreach var of varlist wage exper{
	foreach j in 1 2 4 5 7{
		reg `var' if sum`j'==1
		local v`i'm`j' = _b[_cons]
		local v`i's`j' = _se[_cons]
	}
	local i=`i'+1
}
forvalues i=1/2{
di %9.0f `v`i'm1' _col(15) %9.0f `v`i'm2' _col(30) %9.0f `v`i'm4' _col(45) %9.0f `v`i'm5'  _col(60) %9.0f `v`i'm5' _col(75) %9.0f `v`i'm7' 
di "[" %9.0f `v`i's1' "]"  _col(15)  "[" %9.0f `v`i's2'  "]"   _col(30)  "[" %9.0f `v`i'm4'  "]"   _col(45)  "[" %9.0f `v`i's5' "]"  _col(60)  "[" %9.0f `v`i's7' "]" 
}

****** Table 2 -- garment villages
use "$path\JDE HM data -- village level.dta", replace
foreach var of varlist  dist_* {
	qui sum `var' if garmentvill==1
	local gmean = r(mean)
	qui sum `var' if garmentvill==0
	local ngmean = r(mean)
	qui ttest `var', by(garmentvill)
	di "`var'" _col(30)  %9.3f `gmean' _col(45)  %9.3f `ngmean'   _col(60) %9.3f r(p) _col(80) r(N_1) _col(85) r(N_2)
}

use "$path\JDE HM data -- individual level.dta", replace
gen femaleeduc = educ if female==1 & age>=50
gen maleeduc = educ if female==0 & age>=50
gen femalemarriageage = marriageage if female==1 & age>=50
gen femaleagefirstbirth = agefirstbirth if female==1 & age>=50
foreach var of varlist  femaleeduc maleeduc femalemarriageage femaleagefirstbirth{
	qui sum `var' if garmentvill==1
	local gmean = r(mean)
	qui sum `var' if garmentvill==0
	local ngmean = r(mean)
	qui ttest `var', by(garmentvill)
	di "`var'" _col(30)  %9.3f `gmean' _col(45)  %9.3f `ngmean'   _col(60) %9.3f r(p) _col(80) r(N_1) _col(85) r(N_2)
}


****** Table 3 -- work
*** 6-18-2014
use "$path\JDE HM data -- labor supply.dta", replace
reg worked garmentvill i.yearofbirth if female==1, cluster(sibgroup)
outreg2 using "working", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket replace
reg worked garmentvill dgarmentyears10to29 dgarmentyears30to39 i.yearofbirth if female==1, cluster(sibgroup)
outreg2 using "working", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append
reg worked garmentvill dgarmentyears10to23 dgarmentyears24to39 i.yearofbirth if female==1, cluster(sibgroup) /* up to 23 = 90th percentile of marriage ages */
outreg2 using "working", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

****** Table 4 -- marriage and childbearing
use "$path\JDE HM data -- marriage and childbearing.dta", clear
dprobit married_ yearsexposed age garmentvill garmentyear yeardum* if female==1, cluster(person)
outreg2 using "new marriage and childbearing", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket replace
dprobit married_ yearsexposed* age age2 garmentvill garmentyear yeardum* if female==1, cluster(person)
outreg2 using "new marriage and childbearing", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

dprobit firstbirth_ yearsexposed age garmentvill garmentyear yeardum* if female==1, cluster(person)
outreg2 using "new marriage and childbearing", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append
dprobit firstbirth_ yearsexposed* age age2 garmentvill garmentyear yeardum* if female==1, cluster(person)
outreg2 using "new marriage and childbearing", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

dprobit married_ yearsexposed age garmentvill garmentyear yeardum* if female==0, cluster(person)
outreg2 using "new marriage and childbearing", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append
dprobit firstbirth_ yearsexposed age garmentvill garmentyear yeardum* if female==0, cluster(person)
outreg2 using "new marriage and childbearing", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

****** Table 5 -- pretrends
use "$path\JDE HM data -- enrollment.dta", clear
xtreg enroll c.pregarmenttrend##female gfem female#age female##year if garmentvill==1 & pregarmenttrend<0, i(sibgroup) fe robust
outreg2 using "pretrend.txt", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket replace

use "$path\JDE HM data -- marriage and childbearing.dta", clear
dprobit married_ pregarmenttrend yeardum* age age2 garmentvill if female==1 & garmentvill==1, cluster(person)
outreg2 using "pretrend.txt", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

dprobit firstbirth_ pregarmenttrend yeardum* age age2 garmentvill if female==1 & garmentvill==1, cluster(person)
outreg2 using "pretrend.txt", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

****** Table 6 -- educational attainment
use "$path\JDE HM data -- educational attainment.dta", clear
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket replace
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if yearofbirth<=95, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if yearofbirth<=90, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if yearofbirth<=95, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if yearofbirth<=90, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append

****** Table 7 -- educational attainment, by mother or sister work status
use "$path\JDE HM data -- educational attainment.dta", clear
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==1, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket replace
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==0, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if oldersiswork==1, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if oldersiswork==0, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==1 | oldersiswork==1, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
xtreg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==0 & oldersiswork==0, i(sibgroup) fe robust
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append

reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==1, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket replace
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==0, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if oldersiswork==1, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if oldersiswork==0, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==1 | oldersiswork==1, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth if momwork==0 & oldersiswork==0, cluster(sibgroup)
outreg2 using "educ diff in diffs.csv", bdec(4) sdec(4) se sym(***,**,*) bracket append


****** Table 8 -- enrollment (now with and without family FEs, and also age FE's)
use "$path\JDE HM data -- enrollment.dta", clear
/*reg enroll gfem female##c.garmentyear postgarmentvill##female female##agec female##year, cluster(sibgroup)
outreg2 using "new enrollment", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket replace
reg enroll gfem female##c.garmentyear postgarmentvill##female##agec female##year, cluster(sibgroup)
outreg2 using "new enrollment", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append
xtreg enroll gfem female##c.garmentyear postgarmentvill##female female##agec female##year, i(sibgroup) fe robust
outreg2 using "new enrollment", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append
xtreg enroll gfem female##c.garmentyear postgarmentvill##female##agec female##year, i(sibgroup) fe robust
outreg2 using "new enrollment", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append*/

reg enroll gfem female##c.garmentyear postgarmentvill##female female##age female##year, cluster(sibgroup)
outreg2 using "new enrollment", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket replace
xtreg enroll gfem female##c.garmentyear postgarmentvill##female female##age female##year, i(sibgroup) fe robust
outreg2 using "new enrollment", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

****** Table 9 -- FSP (enrollment) -- now also with age FE's and with and without family FEs
use "$path\JDE HM data -- enrollment.dta", clear
xtreg enroll post94##post6##female female##year female##age,  i(sibgroup) fe robust
outreg2 using "new fsp.txt", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket replace
reg enroll post94##post6##female female##year female##age, cluster(sibgroup)
outreg2 using "new fsp.txt", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

****** Table 10 -- FSP (marriage and childbearing)
use "$path\JDE HM data -- marriage and childbearing.dta", clear
dprobit married_ exposed post6 age age2 yeardum* if female==1, cluster(person)
outreg2 exposed post6 using "fsp effects on marriage and childbearing.txt", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket replace
dprobit firstbirth_ exposed post6 age age2 yeardum* if female==1, cluster(person)
outreg2 exposed post6 using "fsp effects on marriage and childbearing.txt", bdec(`dec') sdec(`dec') se sym(***,**,*) bracket append

***************************************************
*** FIGURES
***************************************************

****** Figure 1 -- nationwide trends in enrollment, marriage and childbearing
use "$path\JDE HM data -- enrollment trends.dta", clear
line boys girls year, graphregion(fcolor(white) color(white)) plotregion(style(none)) lcolor(black black) lpattern(solid dash) xtitle(year) ytitle("percent enrolled") title("School Enrollment in Bangladesh, ages 5 to 18") legend(label(1 "Male") label (2 "Female"))

use "$path\JDE HM data -- marriage and childbearing trends.dta", clear
label var fertility "births per woman"
twoway (line avgmarriageage year, yaxis(1) ytitle(bob) sort lcolor(black)) (line fertility year, yaxis(2) sort ytitle("age at marriage") lcolor(black) lpattern(dash)), ///
graphregion(fcolor(white) color(white)) legend(label(1 "Marriage Age") label(2 "Fertility")) title("Female Marriage Age and Fertility", color(black))

****** Figure 2 -- employment growth in the garment industry
use "$path\JDE HM data -- garment employment growth.dta", replace
line workers year, graphregion(fcolor(white) color(white)) plotregion(style(none)) lcolor(black)  xtitle(year) ytitle("millions of workers") title("Nation-wide Employment in the Garment Industry")

****** Figure 3 -- characteristics of sampled garment workers
use "$path\JDE HM data -- individual level.dta", clear
capture graph drop _all
hist age if female==1 & garment==1, graphregion(fcolor(white) color(white))  fcolor(gs8) lcolor(gs5) discrete name(agedist) title("Age", color(black)) xtitle(years) percent
hist educ if female==1 & garment==1, graphregion(fcolor(white) color(white))  fcolor(gs8) lcolor(gs5) discrete name(educdist) title("Education", color(black)) xtitle(years) percent
graph combine agedist educdist, graphregion(fcolor(white) color(white)) title("Age and Education of Female Garment Workers", color(black)) ///
note("From 2009 survey of resident workers in Savar, Dhamrai, Gazipur Sadar and Kaliakur subdistricts")

****** Figure 4 -- distribution of the year in which people in a village first began working in each factory
use "$path\JDE HM data -- village level.dta", replace
hist firstyear, discrete


****** Figure 5 -- identifying variation in garment exposure
use "$path\JDE HM data -- educational attainment.dta", clear
capture graph drop _all
reg educ gfem female##c.garmentvill##c.yearofbirth female##c.garmentyears female##c.yearofbirth##c.yearofbirth, cluster(sibgroup)
hist garmentyears if garmentvill & e(sample), xlabel(0(1)12)discrete width(1) fcolor(gs8) lcolor(black) lwidth(vthin) graphregion(fcolor(white) color(white)) ///
frac xtitle("years of garment exposure") name(exposure_educ) title("Educational attainment sample", color(black))
use "$path\JDE HM data -- marriage and childbearing.dta", clear
dprobit married_ yearsexposed age garmentvill garmentyear yeardum* if female==1, cluster(person)
hist yearsexposed if garmentvill & e(sample), discrete width(1) fcolor(gs8) lcolor(black) lwidth(vthin) graphregion(fcolor(white) color(white)) ///
 frac xtitle("years of garment exposure") name(exposure_marriage)  title("Marriage sample", color(black))

graph combine exposure_educ exposure_marriage, title("Distribution of years of garment exposure", color(black)) subtitle("among sample in garment-proximate villages", color(black)) ///
  graphregion(fcolor(white) color(white)) 
  
****** Figure 6 -- marginal effects, marriage and childbearing regressions
use "$path\JDE HM data -- marriage and childbearing.dta", clear
dprobit married_ yearsexposed* age age2 garmentyear garmentvill yeardum* if female==1, cluster(person)
***** quadratic effects by age
gen agemarr = .
gen me_marriage = .
gen me_marriagelow = .
gen me_marriagehigh = .
forvalues j=12/23{
	local fill = `j'-9
	replace agemarr = `j' in `fill'
	lincom yearsexposed+`j'*yearsexposedage + `j'*`j'*yearsexposedage2
	replace me_marriage = r(estimate) in `fill'
	replace me_marriagelow = r(estimate)-1.96*r(se) in `fill'
	replace me_marriagehigh = r(estimate)+1.96*r(se) in `fill'
}

forvalues j=12(2)20{
	lincom yearsexposed+`j'*yearsexposedage + `j'*`j'*yearsexposedage2
	di %9.4f r(estimate)
	di "[" %9.4f r(se) "]"
}

line me_marriagehigh me_marriage me_marriagelow agemarr, graphregion(fcolor(white) color(white)) xlabel(12(1)23)  ///
lcolor(black black black) lwidth(thin medium thin) lpattern(dash solid dash) xtitle(age) ytitle("change in probability") title("Marginal effects of a year of garment" "exposure on the probability of marriage", color(black)) legend(off) ///
note("ages shown are the 10th and 90th percentile of age at marriage")

gen agefb = .
gen me_firstbirth = .
gen me_firstbirthlow = .
gen me_firstbirthhigh = .
dprobit firstbirth_ yearsexposed* age age2 garmentvill garmentyear yeardum* if female==1, cluster(person)
***** quadratic effects by age
forvalues j=16/22{
	local fill = `j'-15
	replace agefb = `j' in `fill'	
	qui lincom yearsexposed+`j'*yearsexposedage + `j'*`j'*yearsexposedage2
	replace me_firstbirth = r(estimate) in `fill'
	replace me_firstbirthlow = r(estimate)-1.96*r(se) in `fill'
	replace me_firstbirthhigh = r(estimate)+1.96*r(se) in `fill'
}
forvalues j=12(2)20{
	qui lincom yearsexposed+`j'*yearsexposedage + `j'*`j'*yearsexposedage2
	di %9.4f r(estimate)
	di "[" %9.4f r(se) "]"
}

line me_firstbirthhigh me_firstbirth me_firstbirthlow agefb, graphregion(fcolor(white) color(white)) xlabel(16(1)22)  ///
lcolor(black black black) lwidth(thin medium thin) lpattern(dash solid dash) xtitle(age) ytitle("change in probability") title("Marginal effects of a year of garment" "exposure on the probability of first birth", color(black)) legend(off) ///
note("ages shown are the 10th and 90th percentile of age at first birth")
  
****** Figure 7 -- marginal effects, enrollment regressions
use "$path\JDE HM data -- enrollment.dta", clear
xtreg enroll gfem female##c.garmentyear postgarmentvill##female##agepos female##agepos female##year, i(sibgroup) fe robust
gen meage = .
gen meagelow = .
gen meagehigh = .
gen agegraph = .

forvalues j=5/18{
	local jfill = `j'-4
	qui lincom 1.postgarmentvill+1.postgarmentvill#`j'.agepos + 1.postgarmentvill#1.female + 1.postgarmentvill#1.female#`j'.agepos
	di `j' _col(10) r(estimate) _col(30) r(se)
	replace meage = r(estimate) in `jfill' 
	replace meagelow = r(estimate) - 1.96*r(se) in `jfill'
	replace meagehigh = r(estimate)+ 1.96*r(se) in `jfill'
	replace agegraph = `j' in `jfill'
}


line meagehigh meage meagelow agegraph, graphregion(fcolor(white) color(white)) xlabel(5(1)18) lcolor(black black black) lwidth(thin medium thin) ///
lpattern(dash solid dash) xtitle(Age) ytitle("Percentage Point Change in Enrollment") title("Marginal Effects of Garment Jobs on Girls' Enrollment", color(black)) legend(off)

line meagehigh meage meagelow agegraph, graphregion(fcolor(white) color(white)) xlabel(5(1)18) lcolor(black black black) lwidth(thin medium thin) ///
lpattern(dash solid dash) xtitle(Age) ytitle("Percentage Point Change in Enrollment") title("Sibling fixed effects", color(black)) legend(off) name(fe)


reg enroll gfem female##c.garmentyear postgarmentvill##female##agepos female##agepos female##year, cluster(sibgroup)

gen meageo = .
gen meagelowo = .
gen meagehigho = .

forvalues j=5/18{
	local jfill = `j'-4
	qui lincom 1.postgarmentvill+1.postgarmentvill#`j'.agepos + 1.postgarmentvill#1.female + 1.postgarmentvill#1.female#`j'.agepos
	di `j' _col(10) r(estimate) _col(30) r(se)
	replace meageo = r(estimate) in `jfill' 
	replace meagelowo = r(estimate) - 1.96*r(se) in `jfill'
	replace meagehigho = r(estimate)+ 1.96*r(se) in `jfill'
}


line meagehigho meageo meagelowo agegraph, graphregion(fcolor(white) color(white)) xlabel(5(1)18) lcolor(black black black) lwidth(thin medium thin) ///
lpattern(dash solid dash) xtitle(Age) ytitle("Percentage Point Change in Enrollment") title("OLS", color(black)) legend(off) name(ols)

graph combine ols fe, ycommon title("Effects of the garment industry on girls' enrollment", color(black)) subtitle("By age", color(black)) graphregion(fcolor(white) color(white)) 


 

