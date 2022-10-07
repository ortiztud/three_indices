## MLM analysis of the cd detection task
# Author: Javier Ortiz-Tudela (Goethe Uni)
# Started on: 22.09.22
# Last updated on: 22.09.22

## Load libraries
# library(ggpubr)
# library(rstatix)
# library(lme4)
#library(lmerTest)
#library(gridExtra)
library(dplyr)
# library(tidyr)

#### Set directories ####
if(Sys.info()["sysname"]=="Linux"){
  main_dir <- "/home/javier/PowerFolders/CD_restart/"
}else{
  main_dir <- "/Users/javierortiz/PowerFolders/CD_restart"
}

# Initialize empty df
full_data <- data.frame(matrix(ncol = 17, nrow = 0))

#### Exp 1a ####

# Data dir
data_dir <- paste(main_dir , "versions/sparseVScluttered/Blocked/", sep="/")

# Which subs?
which_subs = c(1:20)

# Read-in the data 
for (c_sub in which_subs){
  # Get subject code
  sub_code <- paste("sub-", sprintf("%02d", c_sub), sep="")
  
  # Since the data is in a CSV file, you can read it with the csvread functi
  filename = paste(sub_code, "_task-sparseVScluttered_merged.csv", sep="")
  temp <- read.csv2(paste(data_dir,  "data/beh", sub_code,filename, sep="/"), sep=",")
  
  if (c_sub == 1){
    exp_data <- temp
  } else{
    exp_data <- rbind(exp_data, temp)
  }
}

# Add exp label
exp_data$exp <- rep("1a", length(exp_data$participant))

# Re-code
exp_data$cd_acc[exp_data$cd_acc == "new"] <- NA
exp_data$cd_acc <- as.numeric(exp_data$cd_acc)
exp_data$cd_rt[exp_data$cd_rt == "new"] <- NA
exp_data$cd_rt <- as.numeric(exp_data$cd_rt)
exp_data$rec_rt[exp_data$rec_rt == "new"] <- NA
exp_data$rec_rt <- as.numeric(exp_data$rec_rt)

# Store
full_data <- rbind(full_data, exp_data)

#### Exp 1b ####

# Data dir
data_dir <- paste(main_dir , "versions/sparseVScluttered/Random/", sep="/")

# Which subs?
which_subs = c(1:20)

# Read-in the data
for (c_sub in which_subs){
  # Get subject code
  sub_code <- paste("sub-", sprintf("%02d", c_sub), sep="")
  
  # Since the data is in a CSV file, you can read it with the csvread functi
  filename = paste(sub_code, "_task-sparseVScluttered_merged.csv", sep="")
  temp <- read.csv2(paste(data_dir,  "data/beh", sub_code,filename, sep="/"), sep=",")
  
  if (c_sub == 1){
    exp_data <- temp
  } else{
    exp_data <- rbind(exp_data, temp)
  }
}

# Add exp label
exp_data$exp <- rep("1b", length(exp_data$participant))

# Re-code
exp_data$cd_acc[exp_data$cd_acc == "new"] <- NA
exp_data$cd_acc <- as.numeric(exp_data$cd_acc)
exp_data$cd_rt[exp_data$cd_rt == "new"] <- NA
exp_data$cd_rt <- as.numeric(exp_data$cd_rt)
exp_data$rec_rt[exp_data$rec_rt == "new"] <- NA
exp_data$rec_rt <- as.numeric(exp_data$rec_rt)

# Store
full_data <- rbind(full_data, exp_data)

#### Exp 2 ####

# Data dir
data_dir <- paste(main_dir , "versions/no_id/", sep="/")

## Which subs?
which_subs = c(1:36)

## Read-in the data
for (c_sub in which_subs){
  # Get subject code
  sub_code <- paste("sub-", sprintf("%02d", c_sub), sep="")
  
  # Since the data is in a CSV file, you can read it with the csvread functi
  filename = paste(sub_code, "_task-noid_merged.csv", sep="")
  temp <- read.csv2(paste(data_dir,  "data/beh", sub_code,filename, sep="/"), sep=",")
  
  if (c_sub == 1){
    exp_data <- temp
  } else{
    exp_data <- rbind(exp_data, temp)
  }
}

# Re-code
exp_data$scn_name <- NA

# Add exp label
exp_data$exp <- rep("2", length(exp_data$participant))

# Store
full_data <- bind_rows(full_data, exp_data)

#### Exp 3 ####

# Data dir
data_dir <- paste(main_dir , "versions/elliot/", sep="/")

# Which subs?
which_subs = c(1:20)

# Read-in the data
for (c_sub in which_subs){
  # Get subject code
  sub_code <- paste("sub-", sprintf("%02d", c_sub), sep="")
  
  # Since the data is in a CSV file, you can read it with the csvread functi
  filename = paste(sub_code, "_task-elliot_merged.csv", sep="")
  temp <- read.csv2(paste(data_dir,  "data/beh", sub_code,filename, sep="/"), sep=",")
  
  if (c_sub == 1){
    exp_data <- temp
  } else{
    exp_data <- rbind(exp_data, temp)
  }
}

# Add exp label
exp_data$exp <- rep("3", length(exp_data$participant))

# Re-code
exp_data$scn_name <- NA

# Store
full_data <- bind_rows(full_data, exp_data)

#### Standardize variables ####
# Re-code participants ID to include the experiment number
full_data <- full_data %>% 
  mutate(sub_code = if_else(exp == "1a", participant+100, 
                            if_else(exp == "1b", participant+200,
                                    if_else(exp == "2", participant+300,
                                            participant+400))))

# Re-code scene type and changeness
full_data <- full_data %>% 
  mutate(scn_type = if_else(exp == "2", "cluttered", 
                            if_else(exp == "3", "cluttered",
                                    scn_type))) %>% 
  mutate(changeness = if_else(changeness == "no change", "no_change",
                              if_else(changeness == "NoChange", "no_change",
                                      if_else(changeness == "nochange", "no_change",
                                              if_else(changeness == "new", "new",
                                                      if_else(changeness == "Change", "change",
                                                              if_else(changeness == "change", "change",
                                                                      "cueck")))))))

# Re-code congruity
full_data <- full_data %>% 
  mutate(congruity = if_else(congruity == "Congruent", "con", 
                             if_else(congruity == "Incongruent", "inc",
                                     congruity)))

# Turn RT in seconds
full_data <- full_data %>% 
  mutate(cd_rt = if_else(exp == "2", cd_rt/1000, 
                         if_else(exp == "3", cd_rt/1000, 
                                 cd_rt)))

#### Save ####
write.csv2(full_data, file = paste(main_dir, "/versions/all_exps/data/group-level_task-all-exps_merged.csv", sep=""))
