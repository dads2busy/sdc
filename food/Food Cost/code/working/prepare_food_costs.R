"Data for food costs is taken from the USDA's Low Cost Food Plan. 
This is the second cheapest option out of the USDA's four proposed meal plans. 
The costs vary according to age and sex; however, to get a cost that varies only 
with age we averaged the different costs for men and women.

To derive county-level adjustments for this data, Feeding America's Map the Meal Gap tool was 
utilized. Map the Meal Gap provides information on the cost of the average meal in the US as 
well as in any specific county in the US. Thus to get meal costs in a specific county, 
the Low Cost Food Plan's value was adjusted according to the ratio of the county's meal 
cost to the country's meal cost. 

After calculating county costs, each tract in a county inherited the meal costs for the 
county it is located in."
library(readxl)
library(dplyr)
library(xlsx)
#Clean table from USDA Meal Plan document
usda_mealplan <- read.csv("~/git/cost-living/Food cost/data/Original/usda_meal_plan_sep2022.csv")
usda_mealplan <- usda_mealplan[5:21,c(2,6)]
colnames(usda_mealplan) <- c("Age Bracket", "Low Cost Meal Plan Cost")
usda_mealplan[c(7:11),1] <- c("12-13 years male","14-18 years male","19-50 years male","51-70 years male","71+ years male")
usda_mealplan[c(13:17),1] <- c("12-13 years female","14-18 years female","19-50 years female","51-70 years female","71+ years female")
usda_mealplan <- usda_mealplan[-c(6,12),]
usda_mealplan$`Low Cost Meal Plan Cost` <- substr(usda_mealplan$`Low Cost Meal Plan Cost`,2,7)
usda_mealplan$`Low Cost Meal Plan Cost` <- as.numeric(usda_mealplan$`Low Cost Meal Plan Cost`)
usda_mealplan[16:20,] <- c("12-13 years avg","14-18 years avg",
                           "19-50 years avg","51-70 years avg",
                           "71+ years avg",
                           (usda_mealplan[6,2]+usda_mealplan[11,2])/2,
                           (usda_mealplan[7,2]+usda_mealplan[12,2])/2, 
                           (usda_mealplan[8,2]+usda_mealplan[13,2])/2,
                           (usda_mealplan[9,2]+usda_mealplan[14,2])/2,
                           (usda_mealplan[10,2]+usda_mealplan[15,2])/2)

map_the_meal_gap_modifier <- read_excel("Food cost/data/Original/MMG2022_2020-2019Data_ToShare.xlsx", 
                      sheet = "County")
map_the_meal_gap_modifier <- map_the_meal_gap_modifier[,c(1,21)]
map_the_meal_gap_modifier <- map_the_meal_gap_modifier %>%
  filter(substr(as.character(FIPS),1,2) == '51')
map_the_meal_gap_modifier <- map_the_meal_gap_modifier %>%
  filter(FIPS > 10000)
map_the_meal_gap_modifier <- map_the_meal_gap_modifier[1:133,]

#3.25 is average cost nationwide, taken from https://map.feedingamerica.org/county/2020/overall/
map_the_meal_gap_modifier$modifier <- map_the_meal_gap_modifier$`Cost Per Meal (1 Year)`/3.25

write.xlsx(map_the_meal_gap_modifier, "~/git/cost-living/Food cost/data/Working/va_ct_fdam_2020_map_the_meal_gap_modifier.xlsx")

va_food_costs <- data.frame(matrix(ncol = 43, nrow = 133))
va_food_costs[,1:3] <- map_the_meal_gap_modifier 

for (i in 4:23){
  va_food_costs[,i] <- usda_mealplan[i-3,2]}

for (i in 24:43){
  va_food_costs[,i] <- usda_mealplan[i-23,2]}

for (i in 24:43){
  for(j in 1:133){
    va_food_costs[j,i] <- as.numeric(va_food_costs[j,i])*va_food_costs[j,3]
  }
}

colnames(va_food_costs) <- c("FIPS", "Cost Per Meal", "Map the Meal Gap Modifier", 
                             usda_mealplan$`Age Bracket`, 
                             paste(usda_mealplan$`Age Bracket`, "adjusted"))

write.xlsx(va_food_costs, "~/git/cost-living/Food cost/data/Working/va_ct_usda_sep22_adjusted_low_cost_meal_plan_costs.xlsx")

