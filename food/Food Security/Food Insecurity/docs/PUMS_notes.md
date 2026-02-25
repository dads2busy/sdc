---
title: "PUMS Notes"
author: "Joanna Schroeder"
date: "9/21/2022"
output: html_document
---

# Question 1. What is the definition of income in PUMS data? Does it include SNAP?
# Answer: In IPUMS USA, household income is the sum of pre-tax personal income and losses from all sources over a year for all household members. It does not include government subsidies, which are reported in other variables.

[Variable definitions in PUMS data catalog](https://sda.usa.ipums.org/sdaweb/docs/all_acs_samples/DOC/nes.htm;jsessionid=F5674522D0C8B3FEE46BB0A6D6DA64DA)

[Variable `HHINCOME` description](https://usa.ipums.org/usa-action//variables/HHINCOME#description_section)
HHINCOME reports the total money income of all household members age 15+ during the previous year. The amount should equal the sum of all household members' individual incomes, as recorded in the person-record variable INCTOT. The persons included were those present in the household at the time of the census or survey. People who lived in the household during the previous year but who were no longer present at census time are not included, and members who did not live in the household during the previous year but who had joined the household by the time of the census or survey, are included. For the census, the reference period is the previous calendar year; for the ACS and the PRCS, it is the previous 12 months.

[Variable `INCTOT` description](https://usa.ipums.org/usa-action/variables/INCTOT#description_section)
INCTOT reports each respondent's total pre-tax personal income or losses from all sources for the previous year. The censuses collected information on income received from these sources during the previous calendar year; for the ACS and the PRCS, the reference period was the past 12 months. Amounts are expressed in contemporary dollars, and users studying change over time must adjust for inflation.

[Variable `FDSTPAMT description`](https://sda.usa.ipums.org/sdaweb/docs/all_acs_samples/DOC/nes.htm;jsessionid=F5674522D0C8B3FEE46BB0A6D6DA64DA)
FDSTPAMT indicates the value of Food Stamps received during the past 12 months for all FOODSTMP recipients.

Amounts are expressed in contemporary dollars, and users studying change over time must adjust for inflation. See INCTOT for Consumer Price Index adjustment factors. The exception is the ACS/PRCS multi-year files, where all dollar amounts have been standardized to dollars as valued in the final year of data included in the file (e.g., 2007 dollars for the 2005-2007 3-year file). Additionally, more detail may be available than exists in the original ACS samples.

# Question 2: Can we get monthly estimates of income?
# Answer: IPUMS USA does not provide monthly estimates, while IPUMS CPS does.

IPUMS USA Codebook
https://sda.usa.ipums.org/sdaweb/docs/all_acs_samples/DOC/nes.htm;jsessionid=F5674522D0C8B3FEE46BB0A6D6DA64DA

IPUMS CPS Codebook
https://sda.cps.ipums.org/sdaweb/docs/all_march_samples/DOC/nes.htm
