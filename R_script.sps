* Encoding: UTF-8.
* Encoding: UTF-8

BEGIN PROGRAM    R.

# Get data into dataFrame
train = spssdata.GetDataFromSPSS()
#print(train)

# Type des variables 
lapply(train, class)

#Tranformation node R transformer
str(train)

# Dimension 
dim(train) 
# names columns
name_colum <- colnames(train)
name_colum
length(name_colum)
# Missing values
is.na(train)
# nombre de données manquantes
print ("Le nombre de valeurs manquantes est")
sum(is.na(train)) 
# Nombre de donnÃ©es manquantes par Colonne
colSums(is.na(train))
# Satstique descriptive
summary(train)
# list rows of data that have missing values 
missing <- train[!complete.cases(train),]

#---------------------------------------------------------------------------
# Traitement des valeurs manquantes (Impuation)
# Liste predictor without variable cible
predictor <- name_colum[name_colum != "VARIABLE_CIBLE"]
length(predictor)

#data_clean <- initialise(train, mixed = predictor, method = "kNN", mixed.constant = NULL)


# Selection des variables quantitatives
numeric <- sapply(train, is.numeric)
quanti_data <- train[,numeric]
# Selection des variables qualitatives
quali <- sapply(train, is.factor)
quali_data <- train[,quali]
# Delete cible
quali_data$VARIABLE_CIBLE <- NULL

#---------------------------------------------------------------------------
# Traitement des valeurs manquantes (Impuation)

# ----- quanti_data
#df = data.frame(x = 1:20, y = c(1:10,rep(NA,10)))
#df$y[is.na(df$y)] = mean(df$y, na.rm=TRUE)
#---- Représentation graphique valeur manquantes
aggr_plot <- aggr(quanti_data, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(quanti_data), cex.axis=.7, gap=3,ylab=c("Histogram of missing data","Pattern"))
marginplot(quanti_data[c(1,2)])

#quanti_clean <- impute(quanti_data,mean)
quanti_clean <- meanimp(quanti_data)

#---- Représentation graphique : distribution des variables

for (var in colnames(quanti_data)){
  print (var)
  hist(quanti_data[var], main = var, xlab = "Variable", ylab = "Effectif",
       col = "bleu")
  boxplot(quanti_data[var], main = "Boxplot",ylab = var,col = grey(0.8))
}

# ----- quali_data
quali_clean <- modeimp(quali_data)
sum(is.na(quali_clean)) 

colnames(quali_clean)

# --Statistique descrpitives variables qualitatives
for (var in colnames(quali_data)) {
  print (var)
  plot(table(quali_data[var]), main = "Diagramme",ylab = var, col = "blue")
}
pie(table(quali_data[var]))
barplot(table(quali_data[var]))
# --- Get dummy
# Selection of some categorial variable
quali_cl <- quali_clean[,c("FISRT_APP_COUNTRY","FISRT_INV_COUNTRY")]

data_dummies <- dummy.data.frame(quali_cl)
data_dummy <- get.dummy(data_dummies) 

data_dummies <- dummy.data.frame(quali_clean, names = c("FISRT_APP_COUNTRY","FISRT_INV_COUNTRY"))

data_dummies <- dummy.data.frame(quali_clean, names = "FISRT_APP_COUNTRY")
data_dummy <- get.dummy(data_dummies, name = "FISRT_APP_COUNTRY") 

data_dummy <- get.dummy(data_dummies, name = c("FISRT_APP_COUNTRY","FISRT_INV_COUNTRY")) 
data_dummy <- which.dummy(data_dummies, name=c("FISRT_APP_COUNTRY","FISRT_INV_COUNTRY"))


final_data <- quanti_clean
for(var in (c("FISRT_APP_COUNTRY","FISRT_INV_COUNTRY")))
{ print (var)
  data_dummies <- dummy.data.frame(quali_clean, names = var)
  data_dummy <- get.dummy(data_dummies, name = var) 
  final_data <- cbind(final_data, data_dummy)
}

# ------------------- Concatenant for obtain final data
#data_final <- cbind(quanti_clean, quali_clean)
data_final <- cbind(quanti_clean, data_dummy)
data_final$VARIABLE_CIBLE <- train$VARIABLE_CIBLE
#combined <- data.frame(final_data, data_dummy)
dim(data_final)


# empty dataframe
#-- collect1 <- data.frame(id = character(0), max1 = numeric(0), max2 = numeric(0))

# merge two data frames by ID
#total <- merge(data frameA,data frameB,by="ID")
# merge two data frames by ID and Country
#total <- merge(data frameA,data frameB,by=c("ID","Country"))

# --- Split train and test 
## 75% of the sample size
smp_size <- floor(0.75 * nrow(data_final))

## set the seed to make your partition reproductible
set.seed(123)
train_ind <- sample(seq_len(nrow(data_final)), size = smp_size)
train_ind
training <- data_final[train_ind, ]
testing <- data_final[-train_ind, ]

#-- Function to split data in train and test
split_train_test <- function(data_initial, proportion)
  { 
  smp_size <- floor(proportion * nrow(data_initial))
  
  ## set the seed to make your partition reproductible
  set.seed(123)
  train_ind <- sample(seq_len(nrow(data_initial)), size = smp_size)
  train <- data_initial[train_ind, ]
  test <- data_initial[-train_ind, ]
  list(trainset=train,testset=test)
}

splits <- split_train_test(quanti_clean, proportion=0.75)
# save the training and testing sets as data frames
training <- splits$trainset
testing <- splits$testset

#trainTest(quanti_clean, trainpart = 0.75, stratify = FALSE)

#----------------------------------------------------------------------
# -------------- Modelisation / ML Algo
#----------------------------------------------------------------------
# Liste predictor without variable cible
name_var <- colnames(training)
predictor <- name_var[name_var != "VARIABLE_CIBLE"]
length(predictor)
ytrain <- training$VARIABLE_CIBLE
ytest <- testing$VARIABLE_CIBLE
name_var
# --- Regression logistique
# Variable cible
# formala <- ""
# paste("a","+","b","+","c")
# for (var in predictor){
#   formala <- paste(formala, "+", var)
# }
# formala
# formala1 <- substring(formala, 4)
# formala1

logistique_reg <-glm(ytrain~APP_NB_PAYS	+ APP_NB_TYPE+	NB_CLASSES+	NB_ROOT_CLASSES+	NB_SECTORS +NB_FIELDS+	INV_NB	+ INV_NB_TYPE	+ cited_age_min +	cited_age_median	+ cited_age_max + cited_age_mean	+ cited_age_std + 	NB_BACKWARD_NPL,family=binomial,data=training)
summary(logistique_reg)
names(logistique_reg)
logistique_reg$coefficients
# ------------ Evaluation
ypred <- predict(logistique_reg, newdata=testing,type = "response")

# auc
pred <- prediction(ypred, ytest)
#Calcul de l'auc
performance(pred,"auc")@y.values[[1]]
# Courbe de ROC
roc<- performance(pred,"tpr","fpr")
plot(roc, main='Roc curve', col="blue")
# Courbe lift : represente taux de vrai positifs en fonction du taux de prédits 
#positifs 
lift <- performance(pred, "tpr","rpp")
plot(lift, main = 'Courbe lift', col = "green")

# --- Random Forest
# ------------ Evaluation
ytest <- testing$VARIABLE_CIBLE 
print(ytest)

END PROGRAM. 
