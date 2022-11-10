# "Never spend 6 minutes doing something by hand
# when you can spend 2 days automating it"  (https://i.redd.it/8cgqicqyl4q51.jpg)
# Dumb function to generate a report of LMM model comparison.
# The function takes in:
# - tested_models: list of object models to be included in the report.
# - model_names: list of model names to designate each model in the report.
# - against_models: vector of numbers indicating the comparisons starting from the 
#                   first model in tested_models. The length of this vector is 
#                   usually length(tested_models)-1.
# - report_title: string with the header of the report table (also used for output file).
#
# And outputs an html file with the name given by report_title and an object that one can visualize
# in the viewer tab in RStudio.
# Author: Javier Ortiz-Tudela (Goethe Universitaet)
# 
report_LMM <- function(tested_models, model_names, against_models, report_title){

  # This the part that would consitute the call of the function
  # tested_models <- c(max_model, red_model2b, red_model_conf)
  # against_models <- c(1, 2, 2, 3)
  # model_names <- c("m_maximal", "m_reduced1", "m_reduced2a", "m_reduced2b")
 
  # Requisits
  #install.packages("kableExtra");install.packages("magick"); sudo apt-get install libmagick++-dev
  library(kableExtra);library(magick)

  ## Initialize output
  # Column names
  column_names <- c("Model_name", "Fixed_effects", "Random_slopes", "Random_intercepts", 
                    "AIC", "BIC", "LL", "df_model", "Tested_against", "df_comparison", "X2")
  
  # Create empty output table
  n_mods <- length(tested_models)
  out_table <- data.frame(matrix(ncol = length(column_names), nrow = n_mods))
  c_mod <- 1
  
  # Change col names
  colnames(out_table) <- column_names

  ## Here the loop starts
  for(c_mod in 1:n_mods){
  
    # Select this iteration's number of levels
    curr_model <- tested_models[[c_mod]]# No clear reason why the double brackets are needed here

    ## Getting model's components
    # Getting model's formula
    mod_formula <- as.character(curr_model@call[["formula"]])
    
    # Getting fixed effects
    temp <- strsplit(mod_formula[[3]], '+', fixed = T)
    mod_fix <- temp[[1]][1]
    # if(length(temp)==1){
    #   mod_fix <- temp
    # } else {
    #   mod_fix <- paste(temp[2], temp[1], temp[3])
    # }
    
    # Getting random effects
    temp <- strsplit(mod_formula[[3]], '+', fixed = T)
    mod_random <- paste(temp[[1]][2], temp[[1]][3])
    
    # Getting random slopes
    mod_slopes <- mod_random
    # if(length(temp)==1){
    #   mod_slopes <- temp
    # } else {
    #   mod_slopes <- paste(temp[2], temp[1], temp[3])
    # }
    
    # Getting random intercepts
    temp <- strsplit(mod_random, ' ', fixed = T)
    if(length(temp)==1){
      mod_intercepts <- temp
    } else {
      mod_intercepts <- paste(temp[[1]][1], temp[[1]][2], sep=",")
    }
    ## Getting model fit results
    # Create a results object
    res <- summary(curr_model)
    
    # BIC
    mod_BIC <- round(res[["AICtab"]][["BIC"]],1)
    
    # AIC
    mod_AIC <- round(res[["AICtab"]][["AIC"]],1)
    
    # LL
    mod_LL <- round(res[["AICtab"]][["logLik"]],1)
  
    # Put model info into the output table
    out_table$Model_name[c_mod] = model_names[c_mod]
    out_table$Fixed_effects[c_mod] = mod_fix
    out_table$Random_slopes[c_mod] = mod_slopes
    out_table$Random_intercepts[c_mod] = mod_intercepts
    out_table$AIC[c_mod] = mod_AIC 
    out_table$BIC[c_mod] = mod_BIC
    out_table$LL[c_mod] = mod_LL
    out_table$df_model[c_mod] = NA
  
    ## Getting model comparison results for all models other than the last one
    if(c_mod != 1){
      # Create a results object
      comp <- anova(curr_model, tested_models[[against_models[c_mod-1]]])

      # DF
      comp_df <- comp$Df[2]
      
      # ChiSq
      comp_chisq <- round(comp$Chisq[2],3)
      
      # Put comparison info into the output table
      out_table$Tested_against[c_mod] = model_names[against_models[c_mod-1]]
      out_table$df_comparison[c_mod] = comp_df
      out_table$X2[c_mod] = comp_chisq
    }
  }
  
## Format table and print it
# We need to put the title into a df. Just cause.
df <- data.frame(names = c(report_title, " "), cols = c(3,8))
df$names <- as.character(df$names)
formatted_table <- out_table %>%
  kbl() %>%
  kable_paper("striped") %>% 
  add_header_above(c("Model parameters" = 5, "Model fit" = 4, "Model comparison" = 2)) %>% 
  footnote(general = "Report of model selection and comparison.") %>% 
  add_header_above(df, align = "left") %>% 
  row_spec(0, bold = T, color = "black", background = "#b3c4c3") %>% 
  save_kable(file = paste(report_title,'_LMM.html', sep=""), self_contained = T)

return(formatted_table)
}
