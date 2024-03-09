#------------------------------Analyzing the Relationship between Weight and Hypertension
#--------------------------------------------------through Linear Regression

#----------------------------------------------
# Data Management
#----------------------------------------------
# Read in data
args <- commandArgs(trailingOnly = TRUE)

heart<-read.csv(args[1],header=T)
names(weightdat) # List variable names

# Convert variables to factors and assign value labels
source('TransformVariable.R')
weightdat <- transform_variable(weightdat, "hbp", c('Yes', 'No'))
weightdat <- transform_variable(weightdat, "ethnicity", c('Other', 'Other', 'Other', 'Other', 'Latino', 'White'))
weightdat <- transform_variable(weightdat, "gender", c('Male', 'Female'))
weightdat <- transform_variable(weightdat, "smoke", c('Yes', 'No'))

attach(weightdat)
#-----------------------------------------------
# Data Analytics
#-----------------------------------------------
# Source the functions created
source('Commons.R')

# Descriptive statistics
freq(hbp)
freq(smoke)
freq(gender)
freq(ethnicity)
descript(wt)
descript(pa)
descript(age)
descript(ht)

#---------------------------------------------------
# Bivariate analysis
#---------------------------------------------------

# Bivariate relation of predictors with weight
means.grp(wt,hbp); means.grp(wt,gender); means.grp(wt,ethnicity)
means.grp(wt,smoke)

cor.test(wt,age)
cor.test(wt,ht)
cor.test(wt,pa)

# Examining all possible bivariate correlations
dummy_ethnicity<-model.matrix(~ethnicity-1)
dummy_gender<-model.matrix(~gender-1)
dummy_smoke<-model.matrix(~smoke-1)
cor(cbind(wt,age,pa,ht,dummy_ethnicity,dummy_gender,dummy_smoke),use='pairwise.complete.obs')

# Unadjusted associations that compliment the correlations 
u.model1<-lm(wt~hbp,data=weightdat)
u.model2<-lm(wt~age,data=weightdat)
u.model3<-lm(wt~pa,data=weightdat)
u.model4<-lm(wt~ht,data=weightdat)
u.model5<-lm(wt~ethnicity,data=weightdat)
u.model6<-lm(wt~gender,data=weightdat)
u.model7<-lm(wt~smoke,data=weightdat)

summary(u.model1)
summary(u.model2)
summary(u.model3)
summary(u.model4)
summary(u.model5)
summary(u.model6)
summary(u.model7)



#-------------------------------------------------------------------------
#  Model building 
#-------------------------------------------------------------------------

a.model1<-lm(wt~hbp,data=weightdat)
summary(a.model1)
a.model2<-lm(wt~hbp+ht,data=weightdat)
summary(a.model2)
a.model3<-lm(wt~hbp+ht+pa,data=weightdat)
summary(a.model3)
a.model4<-lm(wt~hbp+ht+pa+age,data=weightdat)
summary(a.model4)
a.model5<-lm(wt~hbp+ht+pa+age+ethnicity,data=weightdat)
summary(a.model5)
a.model6<-lm(wt~hbp+ht+pa+age+hbp*ethnicity,data=weightdat)
summary(a.model6)
a.model7<-lm(wt~hbp+ht+pa+age+gender,data=weightdat)
summary(a.model7)
a.model8<-lm(wt~hbp+ht+pa+age+smoke,data=weightdat)
summary(a.model8)


# Additional GLH tests
# install.packages("car")
if (!requireNamespace("car", quietly = TRUE)) {
  install.packages("car")
}
library("car")

Anova(a.model5,type='3')
Anova(a.model6,type='3')

#---------------------------------------------------------------------
#  Interpreting Findings
#---------------------------------------------------------------------
#  Run final model to get parameter estimates
summary(a.model7)
a.model7$coefficients


# Estimate the predicted values of weight setting other predictors to prototypical value
#  Let Pa = 3.2(mean Pa),Age=47.7(mean age), Gender=1(males)
weight1<-154.65-1.93 *(as.numeric(hbp)) + 4.89*ht -0.79*3.2+0.04*47.7-0.85*1


# Plot weight vs height by hbp
plot(ht[hbp=='Yes'],weight1[hbp=='Yes'],ylab='Predicted Weight',xlab='Height(inches)',col='red',type='l')
lines(ht[hbp=='No'],weight1[hbp=='No'],col='blue',type="l")
legend('topleft',inset=0.02,title='Hbp',legend=c('No Hbp','Hbp'),col=c('blue','red'),lty=1)
title(main=list("Figure 1. Fitted values of the weight versus height
                (in inches), by hbp, for males of average physical activity days/week (pa=3.2) and age(age=47.7yrs).",font=3))
