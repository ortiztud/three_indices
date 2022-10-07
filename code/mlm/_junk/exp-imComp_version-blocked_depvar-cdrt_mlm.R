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
data_dir <- paste(main_dir , "versions/sparseVScluttered/Blocked/", sep="/")

## Which subs?
which_subs = c(1:20)

#### Read-in the data ####
for (c_sub in which_subs){
  # Get subject code
  sub_code <- paste("sub-", sprintf("%02d", c_sub), sep="")
  
  # Read data
  filename = paste(sub_code, "_task-sparseVScluttered_merged.csv", sep="")
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
full_data$cd_acc <- as.numeric(levels(full_data$cd_acc))[full_data$cd_acc]
full_data$cd_rt <- as.numeric(levels(full_data$cd_rt))[full_data$cd_rt]
full_data$cd_id <- as.numeric(levels(full_data$cd_id))[full_data$cd_id]
full_data$clutter[full_data$scn_type == "cluttered"] <- "cluttered"
full_data$clutter[full_data$scn_type != "cluttered"] <- "sparse"

# Remove no-change trials
full_data <- full_data %>% filter(changeness == "change")

#### Stats ####
# Run GLMM
# Maximal model
max_model<-lmer(cd_rt ~ congruity * clutter + 
                   (congruity * clutter | participant) +
                   (1 | obj_file), 
                 data = full_data,
                 control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Reduced model (-1)
#red_model1a<- update(max_model, .~. - (1 | obj_file)) # Alternative to shorten but sacrifices readability
red_model1 <-lmer(cd_rt ~ congruity * clutter + 
                      (congruity * clutter | participant), 
                    data = full_data,
                    control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(max_model, red_model1)

# There is a significant decrease in fit here, thus we keep in individual 
# variability in our stimuli's overall rt scores.
# Now we continue reducing the random effects on the participants side.
red_model2 <-lmer(cd_rt ~ congruity * clutter + 
                      (congruity + clutter | participant) +
                     (1 | obj_file), 
                    data = full_data,
                    control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(max_model, red_model2)

# As there is no significant decrease in fit, we discard individual variability 
# in our participant's reaction to the interaction between clutter and congruity.
# And we continue reducing
red_model3a <-lmer(cd_rt ~ congruity * clutter + 
                     (congruity | participant) +
                      (1 | obj_file), 
                   data = full_data,
                   control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(red_model2, red_model3a)

# As there is a significant decrease in fit, we keep individual variability 
# in our participants' response to the clutter manipulation. Let's check congruity.
red_model3b <-lmer(cd_rt ~ congruity * clutter + 
                      (clutter | participant) +
                      (1 | obj_file),  
                    data = full_data,
                    control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(red_model2, red_model3b)

# There is no significant decrease in fit, thus we discard individual variability 
# in our participant's reaction to the congruity manipulation. Since there are 
# no more random effects to reduce, we keep red_model3b
# Create summary table for the model selection process
source('/home/javier/git_repos/premup/analysis/report_LMM.R')
tested_models <- c(max_model,red_model1,red_model2,red_model3a,red_model3b)
model_names <- c("Maximal model","Reduced 1","Reduced 2","Reduced 2a","Reduced 3b")
against_models <- c(1,2,3,3)
report_title <- "Experiment 1a. Change detection (RT)"
report_table <- report_LMM(tested_models, model_names,against_models,report_title)

# We can explore this model with "Anova" (capital A)
Anova(red_model3b)
#summary(red_model3b)

#### Aggregate across subjects ####
agg_data <- full_data %>% 
  group_by(participant, clutter, congruity) %>% 
  summarise(cd_rt = mean(cd_rt))

#### Box plot ####
agg_data$congruity <- as.factor(agg_data$congruity)
ggplot(data = agg_data,
       aes(x = clutter, y = cd_rt, color = congruity)) +
  geom_boxplot() + 
  geom_jitter(shape=10, position=position_jitter(0.2)) +
  ylab("CD RT") + 
  xlab("Congruity") +
  theme(legend.position = "top")
