#Grid Seach

#Kernel S V M

# Importing the dataset
dataset = read.csv('Social_Network_Ads.csv')
dataset=dataset[,3:5]

# Encoding the target feature as factor
dataset$Purchased = factor(dataset$Purchased, levels = c(0, 1))

# Splitting the dataset into the Training set and Test set
# install.packages('caTools')
library(caTools)
set.seed(123)
split = sample.split(dataset$Purchased, SplitRatio = 0.75)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)

# Feature Scaling
training_set[,1:2]=scale(training_set[,1:2])
test_set[,1:2]=scale(test_set[,1:2])

#Fitting the Classifier to the training set
library(e1071)
classifier2=svm(formula=Purchased~.,
               data=training_set,
               type='C-classification',
               kernel='radial')

#Predicting the test set result
y_predict=predict(classifier2,newdata = test_set)

#maiking the confusion matrix
cm=table(test_set[,3],y_predict)

#Applying k-fold cross validation
#install.packages('caret')
library(caret)
folds = createFolds(training_set$Purchased,k = 10)
cv = lapply(folds, function(x){
  training_fold=training_set[-x,]
  test_fold = training_set[x,]
  classifier=svm(formula=Purchased~.,
                 data=training_fold,
                 type='C-classification',
                 kernel='radial')
  y_predict=predict(classifier,newdata = test_fold[-3])
  cm=table(test_fold[,3],y_predict)
  accuracy = (cm[1,1]+cm[2,2])/(cm[1,1]+cm[1,2]+cm[2,1]+cm[2,2])
  return(accuracy)
})

accuracy=mean(as.numeric(cv))

#Appying grid search to find the best model
#install.packages('caret')
library(caret)
classifier = train(form=Purchased~.,data=training_set,method = 'svmRadial')
classifier
classifier$bestTune

#Visualizing the training set results
#install.packages('ElemStatLearn')
library(ElemStatLearn)
set = training_set
X1 = seq(min(set[, 1]) - 1, max(set[, 1]) + 1, by = 0.01)
X2 = seq(min(set[, 2]) - 1, max(set[, 2]) + 1, by = 0.01)
grid_set = expand.grid(X1, X2)
colnames(grid_set) = c('Age', 'EstimatedSalary')
y_grid = predict(classifier,newdata = test_set[-3])
plot(set[, -3],
     main = 'Kernel SVM (Training set)',
     xlab = 'Age', ylab = 'Estimated Salary',
     xlim = range(X1), ylim = range(X2))
contour(X1, X2, matrix(as.numeric(y_grid), length(X1), length(X2)), add = TRUE)
points(grid_set, pch = '.', col = ifelse(y_grid == 1, 'springgreen3', 'tomato'))
points(set, pch = 21, bg = ifelse(set[, 3] == 1, 'green4', 'red3'))

# Visualising the Test set results
library(ElemStatLearn)
set = test_set
X1 = seq(min(set[, 1]) - 1, max(set[, 1]) + 1, by = 0.01)
X2 = seq(min(set[, 2]) - 1, max(set[, 2]) + 1, by = 0.01)
grid_set = expand.grid(X1, X2)
colnames(grid_set) = c('Age', 'EstimatedSalary')
y_grid = predict(classifier,newdata = test_set[-3])
plot(set[, -3],
     main = 'Kernel SVM (Test set)',
     xlab = 'Age', ylab = 'Estimated Salary',
     xlim = range(X1), ylim = range(X2))
contour(X1, X2, matrix(as.numeric(y_grid), length(X1), length(X2)), add = TRUE)
points(grid_set, pch = '.', col = ifelse(y_grid == 1, 'springgreen3', 'tomato'))
points(set, pch = 21, bg = ifelse(set[, 3] == 1, 'green4', 'red3'))