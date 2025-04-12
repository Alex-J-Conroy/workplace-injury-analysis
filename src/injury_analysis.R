# ---- Modular R Analysis Script Extracted from RMarkdown ----



# ---- Code Blocks ----

knitr::opts_chunk$set(echo = FALSE, fig.align = "center", fig.width=8)

# ----

library(ggstatsplot)
library(tidyverse)
library(MASS)
library(ggpubr)
library(DHARMa)
library(AER)
library(GGally)
library(kableExtra)

# ----

## Loading Data
injury_original <- read.csv(file = "injury.csv")
## Suppression of double index
injury <- injury_original[,2:5]

head(injury) %>%
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)

# ----

summary(injury) %>%
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)

# ----

## Initial plot to view data interactions
ggpairs(injury)+
 labs(title="Data Correlation Matrix")

# ----

injury_data_recoded <- injury[,c("Injuries","Hours")]
#Convert variables to factors:
injury_data_recoded$Experience <- factor(injury$Experience,labels=c("None","Little","Some","Lots"))
injury_data_recoded$Safety <- factor(injury$Safety,labels=c("Type1","Type2","Type3","Type4"))
summary(injury_data_recoded) %>%
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)

# ----

## Experience v Injuries
p1 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Experience,
 y = Injuries,
 )) +
 geom_boxplot() +
 theme(axis.text.x = element_text(angle = -45,vjust = 0,hjust = 0)) +
 labs(title="Injuries by Experience", x = "Levels of Experience",y = "Number of Injuries")

## Safety v Injuries
p2 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Safety,
 y = Injuries,
 )) +
 geom_boxplot() +
 theme(axis.text.x = element_text(angle = -45,vjust = 0,hjust = 0)) +
 labs(title="Injuries by Safety Program", x = "Safety Program",y = "Number of Injuries")

## Injuries v Hours w/ Experience
p3 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Hours,
 y = Injuries,
 ))+geom_point(aes( color = Experience)) +
  scale_color_manual(values = c("#00AFBB", "#E7B800", "#FC4E07","#52854C"))+geom_smooth(method = "lm", se = FALSE)+labs(title="Injuries by Time Worked with Experience")

## Injuries v Hours w/ Safety
p4 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Hours,
 y = Injuries,
 ))+geom_point(aes( color = Safety)) +
  scale_color_manual(values = c("#00AFBB", "#E7B800", "#FC4E07","#52854C"))+geom_smooth(method = "lm", se = FALSE)+labs(title="Injuries by Time Worked with Safety")

 ggarrange(
 ggarrange(p1,p2,ncol = 1, nrow = 2),
 ggarrange(p3,p4, ncol = 1, nrow = 2),
 ncol = 2
 )

# ----

injury_data_recoded$InjuryPHour <- as.integer((injury_data_recoded$Injuries/injury_data_recoded$Hours)*100000)
injury_data_recoded <- injury_data_recoded[c(3,4,5)]
head(injury_data_recoded) %>%
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)

# ----

## Experience v Injuries
p1 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Experience,
 y = log(InjuryPHour),
 )) +
 geom_boxplot() +
 theme(axis.text.x = element_text(angle = -45,vjust = 0,hjust = 0)) +
 labs(title="Injuries Per Hour by Experience", x = "Levels of Experience",y = "Log Injuries per 100,000 Hour Worked")

## Safety v Injuries
p2 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Safety,
 y = log(InjuryPHour),
 )) +
 geom_boxplot() +
 theme(axis.text.x = element_text(angle = -45,vjust = 0,hjust = 0)) +
 labs(title="Injuries Per Hour by Safety Program", x = "Safety Program",y = "Log Injuries per 100,000 Hour Worked")

ggarrange(p1,p2,ncol = 2, nrow =1)

# ----

outliers <- boxplot(injury_data_recoded$InjuryPHour ~ injury_data_recoded$Experience, plot=FALSE)$out

injury_data_recoded <- injury_data_recoded[-which(injury_data_recoded$InjuryPHour %in% outliers),]

# ----

boxplot(injury_data_recoded$InjuryPHour ~ injury_data_recoded$Experience, main="Injuries by Experience Type with outlier handled ",
   xlab="Levels of Experience", ylab="Injuries per 100,000 Hour Worked")

# ----

#Full model with all possible interactions for backwards selection:
full_interaction_model <- glm(data = injury_data_recoded,
 formula = InjuryPHour ~ Safety * Experience,
 family = poisson(link = "log"))

#Model with no variables present for forwards selection:
null_model <- glm(data = injury_data_recoded,
 formula = InjuryPHour ~ .,
 family = poisson(link = "log"))

#Perform backward and forward selection:
backward_sel_model <- stepAIC(
 full_interaction_model,direction = "backward",trace = 0)
forward_sel_model <- stepAIC(
 null_model,
 scope = . ~ .^3, ## Allows forward selection to propose up to 3-way interaction.
 direction = "forward",
 trace = 0) ## trace = 0 prevents automatic output of step AIC function.

#Inspect models:
backward_sel_model$formula
## InjuryPHour ~ Safety + Experience
forward_sel_model$formula
## InjuryPHour ~ Experience + Safety
AIC(backward_sel_model)
## 411.8331
AIC(forward_sel_model)
## 411.8331

# ----

#Simulate residuals from the model:
poisson_residuals = simulateResiduals(backward_sel_model)
#Plot observed quantile versus expected quantile to assess distribution fit, and predicted value versus standardised residuals for unmodelled pattern in the residuals.
plot(poisson_residuals)

# ----

disp_result <- dispersiontest(backward_sel_model)
print(disp_result)

# ----

#Adjust p-values for multiple testing:
adjusted_p_values_pois <- p.adjust(summary(backward_sel_model)$coefficients[,4])

adjusted_p_values_pois <- format(adjusted_p_values_pois, digits = 3)
adjusted_p_values_pois%>%
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)

# ----

#Specify full and null models:
NB_full_model <- glm.nb(data = injury_data_recoded,
 formula = InjuryPHour ~ Safety * Experience,
 link = "log")
NB_null_model <- glm.nb(data = injury_data_recoded,
 formula = InjuryPHour ~ .,
 link = "log")
#Perform backward and forward selection:
NB_backward_sel_model <- stepAIC(object = NB_full_model,direction = "backward",trace = 0)
NB_forward_sel_model <- stepAIC(NB_null_model,scope = . ~ .^3, direction = "forward",trace =
0)
#Inspect models:
formula(NB_backward_sel_model)
## InjuryPHour ~ Safety + Experience
formula(NB_forward_sel_model)
## InjuryPHour ~ Experience + Safety
AIC(NB_backward_sel_model) #[1] 400.3561
AIC(NB_forward_sel_model) #[1] 400.3561

# ----

#Simulate residuals from the model:
NB_residuals = simulateResiduals(NB_backward_sel_model)
#Plot observed quantile versus expected quantile to assess distribution fit, and predicted value versus standardised residuals for unmodeled pattern in the residuals.
plot(NB_residuals)

# ----

summary(NB_backward_sel_model)

# ----

#Adjust p-values for multiple testing:
adjusted_p_values <- p.adjust(summary(NB_backward_sel_model)$coefficients[,4])

adjusted_p_values <- format(adjusted_p_values, digits = 3)
adjusted_p_values%>%
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)

# ----

knitr::opts_chunk$set(echo = FALSE, fig.align = "center", fig.width=8)

# ----

library(ggstatsplot)
library(tidyverse)
library(MASS)
library(ggpubr)
library(DHARMa)
library(AER)
library(GGally)
library(kableExtra)

# ----

## Loading Data
injury_original <- read.csv(file = "injury.csv")
## Suppression of double index
injury <- injury_original[,2:5]

injury_data_recoded <- injury[,c("Injuries","Hours")]
#Convert variables to factors:
injury_data_recoded$Experience <- factor(injury$Experience,labels=c("None","Little","Some","Lots"))
injury_data_recoded$Safety <- factor(injury$Safety,labels=c("Type1","Type2","Type3","Type4"))

# ----

injury_data_recoded$InjuryPHour <- as.integer((injury_data_recoded$Injuries/injury_data_recoded$Hours)*100000)
injury_data_recoded <- injury_data_recoded[c(3,4,5)]
head(injury_data_recoded) %>%
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)

# ----

## Experience v Injuries
p1 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Experience,
 y = log(InjuryPHour),
 )) +
 geom_boxplot(outlier.shape=NA) +
 theme(axis.text.x = element_text(angle = -45,vjust = 0,hjust = 0)) +
 labs(title="Injuries Per Hour by Experience", x = "Levels of Experience",y = "Log Injuries per 100,000 Hour Worked")

## Safety v Injuries
p2 <- ggplot(data = injury_data_recoded,
 mapping = aes(
 x = Safety,
 y = log(InjuryPHour),
 )) +
 geom_boxplot(outlier.shape=NA) +
 theme(axis.text.x = element_text(angle = -45,vjust = 0,hjust = 0)) +
 labs(title="Injuries Per Hour by Safety Program", x = "Safety Program",y = "Log Injuries per 100,000 Hour Worked")

ggarrange(p1,p2,ncol = 2, nrow =1)