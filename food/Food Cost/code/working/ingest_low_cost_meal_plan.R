library(rJava)
library(tabulizer)

download.file("https://fns-prod.azureedge.us/sites/default/files/media/file/CostofFoodSep2022LowModLib.pdf", destfile = "/tmp/CostofFoodSep2022LowModLib.pdf")

usda_meal_plan_sep2022 <- extract_tables(
  file   = "/tmp/CostofFoodSep2022LowModLib.pdf", 
  method = "decide", 
  output = "data.frame")

usda_meal_plan_sep2022 <- usda_meal_plan_sep2022[[1]]

write.csv(usda_meal_plan_sep2022, "~/git/cost-living/Food cost/data/Original/usda_meal_plan_sep2022.csv")