********************************************************************************

clear all
use "C:\metaptyxiako\mikrooikonomikh\ergasia8\ESS-Data-Wizard-subset-2022-12-13.dta"
keep if cntry=="GR"

keep agea gndr brncntr rshpsts edulvlb mnactic wkhct netusoft chldo12 acchome accwrk region rlgatnd lrscale
des agea gndr brncntr rshpsts edulvlb mnactic wkhct netusoft chldo12 acchome accwrk region rlgatnd lrscale

********************************************************************************
*definition of variables
********************************************************************************
gen empstatus =.
replace empstatus = 1 if mnactic==1 /*employed*/
replace empstatus = 2 if mnactic==3 /*unemployed*/
replace empstatus = 2 if mnactic==4 /*unemployed*/
replace empstatus = 3 if mnactic==2 /*inactive*/
replace empstatus = 3 if mnactic==5 /*inactive*/
replace empstatus = 3 if mnactic==6 /*inactive*/
replace empstatus = 3 if mnactic==7 /*inactive*/
replace empstatus = 3 if mnactic==8 /*inactive*/
replace empstatus = 3 if mnactic==9 /*inactive*/

gen hours = 0
replace hours = wkhct if empstatus==1 & wkhct>=0 & wkhct<=1000
recode hours (0=0) (1/29=1) (30/1000=2)

gen female = (gndr==2)

gen married = (rshpsts>1 & rshpsts<=6)

gen foreign = (brncntr==2)

gen university = .
replace university = 0 if edulvlb>=0 & edulvlb<=421
replace university = 1 if edulvlb>=610 & edulvlb<=800

encode region, gen(nuts2)

gen internetuse_high = .
replace internetuse_high = 0 if netusoft>=1 & netusoft<=3
replace internetuse_high = 1 if netusoft>=4 & netusoft<=5

gen internetaccess = .
replace internetaccess = 1 if accwrk==0 & acchome==0
replace internetaccess = 2 if accwrk==1 & acchome==0
replace internetaccess = 3 if accwrk==0 & acchome==1
replace internetaccess = 4 if accwrk==1 & acchome==1

gen religattend =.
replace religattend = 1 if rlgatnd>=1 & rlgatnd<=4
replace religattend = 0 if rlgatnd>=5 & rlgatnd<=7
********************************************************************************
*select sample
********************************************************************************
keep if agea>=25 & agea<=54
keep if edulvlb>=0 & edulvlb<=800
keep if chldo12>=0 & chldo12<=20
keep if netusoft>=1 & netusoft<=5
keep if acchome>=0 & acchome<=1
keep if region!=""
keep if rlgatnd>=1 & rlgatnd<=7
keep if lrscale>=0 & lrscale<=10


********************************************************************************
*Analysis
********************************************************************************

*Summary statistics
*Dependent variables
tab empstatus
tab hours
*Independent variables
sum age
tab female
tab married
tab foreign
tab university
tab internetuse_high
tab chldo12
tab internetaccess
tab religattend
tab lrscale
tab nuts2

*section 1. Employment status
*Multinomial Logit
mlogit empstatus c.age i.female i.married i.foreign i.university i.internetuse_high c.chldo12 i.internetaccess i.religattend c.lrscale i.nuts2, rob base(3)
margins, dydx(*) atmeans

*section 2. Labor supply
*Ordered Probit
oprobit hours c.age i.female i.married i.foreign i.university i.internetuse_high c.chldo12 i.internetaccess i.religattend c.lrscale i.nuts2, rob
margins, dydx(*) atmeans

*Ordered Logit
ologit hours c.age i.female i.married i.foreign i.university i.internetuse_high c.chldo12 i.internetaccess i.religattend c.lrscale i.nuts2, rob
margins, dydx(*) atmeans

********************************************************************************