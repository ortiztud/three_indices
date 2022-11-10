## MLM analysis of the cd detection task
# Author: Javier Ortiz-Tudela (Goethe Uni)
# Started on: 22.09.22
# Last updated on: 22.09.22

## Load libraries
library(ggpubr)
library(rstatix)
library(lme4)
library(dplyr)

#### Set directories ####
if(Sys.info()["sysname"]=="Linux"){
  main_dir <- "/home/javier/PowerFolders/CD_restart/"
}else{
  main_dir <- "/Users/javierortiz/PowerFolders/CD_restart"
}
data_dir <- paste(main_dir , "versions/all_exps/", sep="/")
func_dir <- paste("/Users/javierortiz/github_repos/three_indices/" , "code/_functions/", sep="/")

#### Prepare data ####
# Read in
filename = paste("group-level_task-all-exps_merged.csv", sep="")
full_data <- read.csv2(paste(data_dir,  "data",filename, sep="/"))

# Remove sparse trials
full_data <- full_data %>% 
  filter(scn_type == "cluttered")

# Remove no-change trials
full_data <- full_data %>% 
  filter(changeness == "change")

# Remove errors
full_data <- full_data %>% 
  filter(cd_acc == 1)

#### Stats LMM####
# Maximal model
max_model<-glmer(rec_acc ~ congruity + 
                   (congruity | sub_code ) +
                   (congruity | obj_file), 
                 data = full_data, family = binomial, 
                 control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
# max_model2<-glmer(rec_acc ~ congruity + exp + 
#                    (congruity | sub_code ) +
#                    (congruity | obj_file), 
#                  data = full_data, family = binomial, 
#                  control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
# Reduced model (-1)
red_model1a <-glmer(rec_acc ~ congruity + 
                      (congruity | sub_code) +
                      (1 | obj_file), 
                    data = full_data, family = binomial, 
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(max_model, red_model1a)

# As there is no significant decrease in fit, we discard individual variability 
# in our stimuli's reaction to the congruity manipulation
# Let's check what happens with congruity.
red_model1b <-glmer(rec_acc ~ congruity + 
                      (1 | sub_code) +
                      (congruity | obj_file), 
                    data = full_data, family = binomial, 
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(max_model, red_model1b)

# As there is no significant decrease in fit, we discard individual variability 
# in our participants' response to the congruity manipulation. We keep the model with
# random intercepts only.
red_model1 <-glmer(rec_acc ~ congruity + 
                      (1 | sub_code) +
                      (1 | obj_file), 
                    data = full_data, family = binomial, 
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# and continue reducing further
red_model2a<-glmer(rec_acc ~ congruity + 
                    (1 | sub_code), 
                  data = full_data, family = binomial, 
                  control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(red_model1, red_model2a)
  
# As there's a significant decreaese in fit, we keep the individual variability 
# in our stimuli's overall memorability. Let's see what happens for participants
red_model2b<-glmer(rec_acc ~ congruity + 
                     (1 | obj_file), 
                   data = full_data, family = binomial, 
                   control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Now we can compare the models. 
anova(red_model1, red_model2b)

# As there's a significant decraese in fit, we keep the individual variability 
# in our particiapnts' overall memory. We accept red_model1 
source(paste(func_dir, '/report_LMM.R', sep=""))
tested_models <- c(max_model,red_model1a,red_model1b,red_model1,red_model2a,red_model2b)
model_names <- c("Maximal model","Reduced 1a","Reduced 1b","Reduced 1","Reduced 2a","Reduced 2b")
against_models <- c(1,1,1,4,4)
report_title <- "Combined analysis. DV = Recognition accuracy"
report_table <- report_LMM(tested_models, model_names,against_models,report_title)

# We can explore this model with "Anova" (capital A)
Anova(red_model1)
#summary(max_model)

#### Aggregate across subjects ####
agg_data <- full_data %>% 
  group_by(exp, participant, congruity) %>% 
  summarise(rec_acc = mean(rec_acc, na.rm=TRUE))

#### Box plot ####
agg_data$congruity <- as.factor(agg_data$congruity)
ggplot(data = agg_data,
       aes(x = exp, y = rec_acc, color = congruity)) +
  geom_boxplot() +
  geom_jitter(shape=10, position=position_jitter(0.2)) +
  ylab("CD acc") + 
  xlab("Experiment") +
  theme(legend.position = "top")
