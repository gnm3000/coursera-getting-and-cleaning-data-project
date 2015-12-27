setwd("~/R/course_project/project")

library(plyr)
library(knitr)
#Download Data
if(!file.exists("./data")){dir.create("./data")
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
  
  #Unzip
  unzip(zipfile="./data/Dataset.zip",exdir="./data")
  
}
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
#Read Activities Files
dataActivityTest  <- read.table("data/UCI HAR Dataset/test/y_test.txt",header = FALSE)
dataActivityTrain <- read.table("data/UCI HAR Dataset/train/y_train.txt",header = FALSE)

#Read Subject Files
dataSubjectTrain <- read.table("data/UCI HAR Dataset/train/subject_train.txt",header = FALSE)
dataSubjectTest  <- read.table("data/UCI HAR Dataset/test/subject_test.txt",header = FALSE)

#Read Features files
dataFeaturesTest  <- read.table("data/UCI HAR Dataset/test/X_test.txt",header = FALSE)
dataFeaturesTrain <- read.table("data/UCI HAR Dataset/train/X_train.txt",header = FALSE)

#Merges the training and the test sets to create one data set

#Data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

# set names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#merge columns
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

# mean and standard deviation for each measurement

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
#descriptive activity names
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
#columns names

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#Tidydata
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

#Cookbook
knit2html("codebook.Rmd")
