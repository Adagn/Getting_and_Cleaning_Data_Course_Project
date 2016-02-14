### Download and unzip data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./projectData/Dataset.zip", method="curl")
unzip(zipfile="./projectData/Dataset.zip", exdir="./projectData")


###Load required packages
library(dplyr)
library(data.table)
library(tidyr)

### Read data and create data tables
subjectTrainData <- tbl_df(read.table("./train/subject_train.txt"))
subjectTestData <- tbl_df(read.table("./test/subject_test.txt"))
                    
### Read activity and data files
dataActivityTrian <- tbl_df(read.table("./train/Y_train.txt"))
dataActivityTest <- tbl_df(read.table("./test/Y_test.txt"))
dataTrain <- tbl_df(read.table("./train/X_train.txt"))
dataTest <- tbl_df(read.table("./test/X_test.txt"))

### Merging the training and test data-- row binding
combinedDataSubject <- rbind(subjectTrainData, subjectTestData)
setnames(combinedDataSubject, "V1", "subject")
combinedActivity <- rbind(dataActivityTrian, dataActivityTest)
setnames(combinedActivity, "V1", "activityNum")

# Combine training and test data files
dataFileTable <- rbind(dataTrain, dataTest)

# Name variabes based on their features
dataFeatures <- tbl_df(read.table("./features.txt"))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(dataFileTable) <- dataFeatures$featureName

# set column names for activity lables
activityLables <- tbl_df(read.table("./activity_labels.txt"))
setnames(activityLables, names(activityLables), c("activityNum", "activityName"))

# Merging columns
allDataSubject <- cbind(combinedDataSubject, combinedActivity)
dataFileTable <- cbind(allDataSubject, dataFileTable)

### Extract mean and std of measurments
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)", dataFeatures$featureName,value=TRUE)
dataFeaturesMeanStd <- union(c("subject", "activityNum"), dataFeaturesMeanStd)
dataFileTable <- subset(dataFileTable, select=dataFeaturesMeanStd)

### Discriptive activity names to the data set
dataFileTable <- merge(activityLables, dataFileTable, by="activityNum", all.x=TRUE)
dataFileTable$activityName <- as.character(dataFileTable$activityName)

## create data table with variables mean and sorting by subject and activity
dataAggregate <- aggregate(. ~ subject - activityName, data = dataFileTable, mean)
dataTable <- tbl_df(arrange(dataAggregate, subject, activityName)) 

## Lable data set with discriptive cariable names
#head(str(dataTable), 2)
names(dataTable) <- gsub("std()", "SD", names(dataTable))
names(dataTable) <- gsub("mean()", "MEAN", names(dataTable))
names(dataTable) <- gsub("^t", "time", names(dataTable))
names(dataTable) <- gsub("^f", "frequency", names(dataTable))
names(dataTable) <- gsub("Acc", "Accelerometer", names(dataTable))
names(dataTable) <- gsub("Gyro", "Gyroscope", names(dataTable))
names(dataTable) <- gsub("Mag", "Magnitude", names(dataTable))
names(dataTable) <- gsub("BodyBody", "Body", names(dataTable))

#head(str(dataTable),6)
### Create tidy data
write.table(dataTable, "TidyData.txt", row.name=FALSE)


























