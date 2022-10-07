## MLM analysis of the cd detection task
# Author: Javier Ortiz-Tudela (Goethe Uni)
# Started on: 22.09.22
# Last updated on: 22.09.22

## Load libraries
library(ggpubr)
library(rstatix)
library(lme4)
#library(lmerTest)
#library(gridExtra)
library(dplyr)
# library(tidyr)

#### Set directories ####
if(Sys.info()["sysname"]=="Linux"){
  main_dir <- "/home/javier/PowerFolders/CD_restart/"
}else{
  data_dir <- "/Users/javierortiz/PowerFolders/CD_restart"
}
data_dir <- paste(main_dir , "versions/elliot/", sep="/")

## Which subs?
which_subs = c(1:20)

#### Read-in the data ####
for (c_sub in which_subs){
  # Get subject code
  sub_code <- paste("sub-", sprintf("%02d", c_sub), sep="")
  
  # Since the data is in a CSV file, you can read it with the csvread functi
  filename = paste(sub_code, "_task-elliot_merged.csv", sep="")
  temp <- read.csv2(paste(data_dir,  "data/beh", sub_code,filename, sep="/"), sep=",")
  
  if (c_sub == 1){
    full_data <- temp
  } else{
    full_data <- rbind(full_data, temp)
  }
}

#### Re-code stuff ####
# First convert the categorical variable into a factors and numeric variables 
# into integers. This is R terminology.
full_data <- full_data %>% filter(OvsN == "old")
full_data$congruity<- as.factor(full_data$congruity)
full_data$changeness <- as.factor(full_data$changeness)
# full_data$id_acc <- as.numeric(full_data$id_acc)
# full_data$cd_acc <- as.numeric(levels(full_data$cd_acc))[full_data$cd_acc]
# full_data$cd_rt <- as.numeric(levels(full_data$cd_rt))[full_data$cd_rt]
# full_data$cd_id <- as.numeric(levels(full_data$cd_id))[full_data$cd_id]
# full_data$clutter[full_data$scn_type == "cluttered"] <- "cluttered"
# full_data$clutter[full_data$scn_type != "cluttered"] <- "sparse"

# Remove no-change trials
full_data <- full_data %>% filter(changeness == "change")

#### Stats ####
# Run GLMM
# Maximal model
max_model<-glmer(cd_acc ~ congruity + 
                   (congruity | participant) +
                   (congruity | obj_file), 
                 data = full_data, family = binomial, 
                 control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
#red_model1<- update(max_model, .~. -   (congruity | obj_file) + (1 | obj_file)) # Alternative to shorten but sacrifices readability
# Reduced model (-1)
red_model1 <-glmer(cd_acc ~ congruity + 
                      (congruity | participant) +
                      (1 | obj_file), 
                    data = full_data, family = binomial, 
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(max_model, red_model1)

# As there is a significant decrease in fit, we keep individual variability 
# in our stimuli's reaction to congruity.
# And we continue reducing the random effects on the participants side.
red_model2 <-glmer(cd_acc ~ congruity + 
                      (1 | participant) +
                      (congruity | obj_file), 
                    data = full_data, family = binomial, 
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(max_model, red_model2)

# As there is no significant decrease in fit, we discard individual variability 
# in our participant's reaction to the congruity manipulation. We reduce keep red_model1
# Create summary table for the model selection process
source('/home/javier/git_repos/premup/analysis/report_LMM.R')
tested_models <- c(max_model,red_model1,red_model2)
model_names <- c("Maximal model","Reduced 1","Reduced 2")
against_models <- c(1,1)
report_title <- "Experiment 3. Change detection"
report_table <- report_LMM(tested_models, model_names,against_models,report_title)

# We can explore this model with "Anova" (capital A)
Anova(red_model1)
#summary(red_model1)

#### Aggregate across subjects ####
agg_data <- full_data %>% 
  group_by(participant, congruity) %>% 
  summarise(cd_acc = mean(cd_acc))

#### Box plot ####
agg_data$congruity <- as.factor(agg_data$congruity)
ggplot(data = agg_data,
       aes(x = 1, y = cd_acc, color = congruity)) +
  geom_boxplot() + 
  geom_jitter(shape=10, position=position_jitter(0.2)) +
  ylab("CD acc") + 
  ylim(c(0,1.1)) +
  xlab("Congruity") +
  theme(legend.position = "top")
