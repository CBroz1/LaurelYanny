
# Packages ----------------------------------------------------------------
install.packages('reshape2');install.packages('plyr');install.packages('dplyr')
install.packages('tidyverse');install.packages('ggpubr');install.packages('data.table')
install.packages('rstatix');install.packages('datarium')
library(reshape2);library(plyr);library(dplyr);library(data.table)
library(tidyverse);library(ggpubr);library(rstatix);library(datarium)
# Cleaning ----------------------------------------------------------------
  setwd("{Redacted}/LaurelYanny")
  load("{Redacted}/LaurelYanny/.RData")
  df0 <- read.csv('LaurelYannyData_Raw.csv')
  cat(colnames(df0), sep="\n")
  names(df0)=c("TStamp","Orig","ChangeUp","NumUp","ChangeDn","NumDn",
               "Gender", "Age", "Loc", "LocUS")
  #Change Y/N to binary
  df0$ChangeUp <- ifelse(df0$ChangeUp=='Yes',1,0)
  df0$ChangeDn <- ifelse(df0$ChangeDn=='Yes',1,0)
  #Set end of ranges to NA. Can't 'change' going up @0
  df0$NumUp <- ifelse(df0$ChangeUp==0,NA,df0$NumUp)
  df0$NumDn <- ifelse(df0$ChangeDn==0,NA,df0$NumDn)
  df0$NumUp <- ifelse(df0$NumUp==30,NA,df0$NumUp)
  #Set age to 'max' of range
  df0$Age <- mapvalues(df0$Age, from=c( "<18", "18-25", "25-30", "30-35", 
                                        "35-40", "40-45", "45-50", "50-55", "55-60",
                                        ">60","","Prefer not to say"),
                        to=c(18, 25, 30, 35, 40, 45, 50, 55, 60, 65,NA,NA))
  df0$Gender<-mapvalues(df0$Gender,from=c("Male","Female","Gender-fluid/Non-binary/Other",""),
                        to=c("M","F","NB",NA))
  df0$NumAv<-rowMeans(df0[,c("NumDn", "NumUp")], na.rm=FALSE)
  df0$Loc<-tolower(df0$Loc)
  ##Light cleaning of free entry location
  {
    ##This data is diverse. Some cities, some states, some countries.
    ##Would need a lot of hand-cleaning to one level of specificity
    
    #dropping values with joke entries, assuming poor data quality
    DropLocs <- c("gkjhg", "huh?", "lol", "mars", "my", "my mama", "my mom", 
                  "nigger", "sd153", "sneep snop", "the internet", "the land of klepto",
                  "ur mom gay", "ur mum", "your moms vagina", 
                  "did you just categorise my gender with gender-fluid and non-binary?")
    df0 <- df0[!(df0$Loc %in% DropLocs),]
    DropLocs <- c("", ".", "956", "choose not to answer", "h", "no where (military)", 
                  "prefer not to say", "secret", "somewhere in europe", "somewhere", 
                  "somwhere", "south", "x", "z","big","gh","na","n/a","not telling")
    df0[(df0$Loc %in% DropLocs),]$Loc<-NA
    DropLocs <- c("california, us","california, usa","ca","cali","california",
                  "california/arizona","californian","sd","san diego, ca, usa",
                  "san jose , ca","san jose, ca")
    df0[(df0$Loc %in% DropLocs),]$Loc<-"CA"
    DropLocs <- c("us","us - northeast originally", "usa", "usa.", "america",
                  "america!!!!!!", "us- there wasn't another place for input so i'll say it here: i originally hear laurel. the questions for the speed-up seem to assume that i'll continue to hear laurel until a certain number is hit, but for me as i heard yanny from 30-88 and laurel for 40+. it was the same as when i heard it in the opposite direction.")
    df0[(df0$Loc %in% DropLocs),]$Loc<-"USA"
    fwrite(as.list(sort(unique(df0$Loc))), file = "Locations_cleaner.txt")
  }
  df0$ID <- sprintf("%04s",rownames(df0))
  df0$ChangeBt <- as.integer(df0$ChangeUp & df0$ChangeDn) # Does it change for either?
  df<-df0[c("ID","Orig", "NumAv", "NumUp", "NumDn", "ChangeUp", "ChangeDn", "ChangeBt", "Gender", "Age", "LocUS")]
  write.csv(df,file="LaurelYannyData_Clean.csv",na="")
  #workspace cleanup 
  rm(list=setdiff(ls(), "df"))
  
# Stats -------------------------------------------------------------------
  # Treating initial interpretation as binary
  df$Orig_bin <- as.numeric(mapvalues(df$Orig, from=c( "Laurel","Yanney"),to=c(1,0)))
  
  # ~ 5% is NB or no response, only keeping M/F for 'dfb' binary
  df %>% group_by(Gender) %>% summarise(n = n()) %>% mutate(freq = n / sum(n))
  binary <- c("M", "F"); dfb <- df[(df$Gender %in% binary),] #only M and F
  rm(binary)
  
# Result 1 - Women are more likely to hear Yanney
  t.test(Orig_bin ~ Gender, data=dfb)
# Result 2 - Interpretations are preserved with pitch changes. 
#            Women have higher inflection points
#            Inflection points are higher when going up and lower coming down.
  #transform to long
  dfl<-(dfb %>% gather(key="Dir",value = "Pitch",NumUp,NumDn) %>% convert_as_factor(ID,Dir))
  # drop NA values, restricting to only for whom changed
  dfl<-dfl[!is.na(dfl$Pitch),]; df$Gender<- as.factor(df$Gender)
  #ordinal data not normally distributed, esp for Male respondents. 
  #not a great comparison given unbalanced N across cells
  ggqqplot(dfl,"Pitch")+facet_grid(Gender~Dir,labeller="label_both")
  res1.aov <- anova_test(data = dfl,dv=Pitch,wid=ID,
                         within = c(Dir),between = c(Gender))
  get_anova_table(res1.aov) # main effects, no interaction.
  ggboxplot(dfl,x="Dir",y="Pitch",color="Gender")
  t.test(Pitch ~ Dir, data=dfl) # Sig higher for NumUp
  t.test(Pitch ~ Gender, data=dfl) # Sig higher for Female
  
# Result 3 - Those who initially hear Yanney have much higher inflection points.
#            The distance between ascending and decending inflection points in
#            smaller for those who initally year Laurel.
  dfl<-dfl[!is.na(dfl$Orig_bin),] #For those who heard one the other initially
  res2.aov <- anova_test(data = dfl,dv=Pitch,wid=ID,
                         within = c(Dir),between = c(Gender,Orig_bin))
  get_anova_table(res2.aov) # main effects, Orig*Dir interaction
  t.test(Pitch ~ Dir, data=dfl) # Sig higher for NumUp
  t.test(Pitch ~ Gender, data=dfl) # Sig higher for Female
  
  dfl$Gender <- factor(dfl$Gender, levels=c("M", "F"), labels=c("Male", "Female"))
  dfl$Dir <- factor(dfl$Dir, levels=c("NumUp", "NumDn"), labels=c("Ascending", "Descending"))  
  
  ggboxplot(dfl,x="Gender",y="Pitch",color="Dir",facet.by="Orig")
  

# Result 4 - Age is not a significant predictor, but trends indicate greater 
#            perception of Laurel with age.
  # Treating age bin peak as continuous, despite ordinal rating.
  df$Age <- as.numeric(df$Age)
  cor.test(df$Age,df$Orig_bin)
  df %>% group_by(Age) %>% summarize(average=mean(Orig_bin))
  cor.test(df$Age,df$NumAv)
  df[!is.na(df$NumAv),] %>% group_by(Age) %>% summarize(average=mean(NumAv))
  


  
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