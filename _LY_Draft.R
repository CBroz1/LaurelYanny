
# Packages ----------------------------------------------------------------
install.packages('reshape2');install.packages('plyr');install.packages('dplyr')
install.packages('tidyverse');install.packages('ggpubr');install.packages('rstatix');install.packages('datarium')
library(reshape2);library(plyr);library(dplyr)
library(tidyverse);library(ggpubr);library(rstatix);library(datarium)
# Data --------------------------------------------------------------------
  setwd("{Redacted}/LaurelYanny")
  load("{Redacted}/LaurelYanny/.RData")
  char_data <- read.csv('LaurelYannyData_Raw.csv', stringsAsFactors = F)
  num_data <- data.frame(data.matrix(char_data))
  numeric_columns <- sapply(num_data,function(x){mean(as.numeric(is.na(x)))<0.5})
  formatted_data <- data.frame(num_data[,numeric_columns], char_data[,!numeric_columns])
  df0 <- formatted_data
  cat(colnames(df0), sep="\n")
  names(df0)=c("NumUp", "NumDn", "TStamp", "Orig", "ChangeUp", "ChangeDn",
               "Gender", "Age", "Loc", "LocUS")
  df0$ChangeUp <- ifelse(df0$ChangeUp=='Yes',1,0)
  df0$ChangeDn <- ifelse(df0$ChangeDn=='Yes',1,0)
  df0$NumUp <- ifelse(df0$ChangeUp==0,NA,df0$NumUp)
  df0$NumDn <- ifelse(df0$ChangeDn==0,NA,df0$NumDn)
  df0$NumUp <- ifelse(df0$NumUp==30,NA,df0$NumUp)
  df0$Age <- mapvalues(df0$Age, from=c("<18", "18-25", "25-30", "30-35", "35-40",
                                         "40-45", "45-50", "50-55", "55-60", ">60"),
                        to=c(18, 25, 30, 35, 40, 45, 50, 55, 60, 65))
  df0$Gender<-mapvalues(df0$Gender,from=c("Male","Female"),to=c("M","F"))
  df0$NumAv<-rowMeans(df0[,c("NumDn", "NumUp")], na.rm=FALSE)
  Locs <- unique(df0$Loc)
  #dropping values with joke entries
  DropLocs <- c(".", "956", "Big", "Did you just categorise my gender with gender-fluid and non-binary?", "Earth", "gkjhg", "Huh?", "Lol", "Mars", "My mom", "sneep snop", "The land of klepto	", "Ur mom", "Ur mom gay", "x", "X", "Your Moms Vagina", "z")
  df1 <- df0[!(df0$Loc %in% DropLocs),]
  df1$ID <- sprintf("%04s",rownames(df1))
  df1$ChangeBt <- as.integer(df1$ChangeUp & df1$ChangeDn)
  df<-df1[c("ID","Orig", "NumAv", "NumUp", "NumDn", "ChangeUp", "ChangeDn", "ChangeBt", "Gender", "Age", "LocUS")]
  write.csv(df,file="LaurelYannyData_Clean.csv",na="")
  rm(list=setdiff(ls(), "df"))
  
# Stats -------------------------------------------------------------------
  df %>% group_by(Gender) %>%
    summarise(n = n()) %>%
    mutate(freq = n / sum(n))
  
  binary <- c("M", "F")
  dfb <- df[!(df$Gender %in% binary),] #only M and F

# Graphs ------------------------------------------------------------------

  st.err <- function(x) {sd(x)/sqrt(length(x))}
  
  hist(df$NumDn, col=rgb(0,0,1,0.5),breaks=18,add=F)
  hist(df$NumUp, col=rgb(1,0,0,0.5),breaks=18,add=T)
  box()
  
# SPSS Code -----------------------------------------------------------------
  # * Encoding: UTF-8.
  # 
  # *Inflection point and likelihood of change by Gender and orig 
  # 
  # USE ALL.
  # COMPUTE filter_$=((Gender = "M" | Gender = "F") & (Orig = "Laurel" | Orig="Yanney")).
  # VARIABLE LABELS filter_$ '(Gender = "M" | Gender = "F") & (Orig = "Laurel" | Orig="Yanney") '+
  #   '(FILTER)'.
  # VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
  # FORMATS filter_$ (f1.0).
  # FILTER BY filter_$.
  # EXECUTE.
  # GLM NumUp NumDn BY Orig Gender WITH Age
  # /WSFACTOR=UpDn 2 Polynomial 
  # /METHOD=SSTYPE(3)
  # /EMMEANS=TABLES(UpDn) WITH(Age=MEAN)
  # /PRINT=DESCRIPTIVE 
  # /CRITERIA=ALPHA(.05)
  # /WSDESIGN=UpDn 
  # /DESIGN=Age Orig Gender Orig*Gender.
  # 
  # MEANS TABLES=NumUp NumDn ChangeUp ChangeDn Age BY Orig BY Gender
  # /CELLS=MEAN SEMEAN.
  # 
  # GLM ChangeUp ChangeDn BY Orig Gender
  # /WSFACTOR=UpDn 2 Polynomial 
  # /METHOD=SSTYPE(3)
  # /EMMEANS=TABLES(UpDn) 
  # /PRINT=DESCRIPTIVE 
  # /CRITERIA=ALPHA(.05)
  # /WSDESIGN=UpDn 
  # /DESIGN=Orig Gender Orig*Gender.
  # 
  # USE ALL.
  # 
  # *Age is weird
  # 
  # CORRELATIONS 
  # /VARIABLES=Age NumAv NumUp NumDn ChangeUp ChangeDn 
  # /PRINT=TWOTAIL NOSIG 
  # /MISSING=PAIRWISE.
  # 
  # MEANS TABLES=NumAv NumUp NumDn ChangeUp ChangeDn BY Age
  # /CELLS=MEAN SEMEAN.