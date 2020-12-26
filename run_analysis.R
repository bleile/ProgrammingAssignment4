# Getting and Cleaning Data Final Project
# By C. Bleile

# Assignment instructions are in the ReADME.md file on Git
# Useage directions and Data source/Data description from the same source are in the CodeBook.md on Git

# General outline of code below is:
# 1. Set the environment
# 2. Get the datasets and unzip
# 3. Gather the column names, etc. to tidy the data
# 4. Load and merge the datasets
# 5. Relabel data fields 
# 6. Calculate means and standard deviations 
# 7. Make a tidy data set with the averages for each activity and subject.

## Code begins here...
# 1. Set the environment
# a. Load required packages
library("data.table", quietly=TRUE)
library("reshape2", quietly=TRUE)

# b. Set working directory in variable "wd" for data save location, 
# set "wd" to default user directory "~" for POSIX, not sure where this goes for Windows.You can replace the ~ with your WD.
wd <- "~"
setwd(wd)

# 2a. download Data Set to working directory
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", file.path(wd, "dataset.zip"))
# b. unzip it
unzip(zipfile = "dataset.zip")

# 3. Gather the column names, etc. needed to tidy the data from the Data Set description files
activity_labels <- fread(file.path(wd, "UCI HAR Dataset/activity_labels.txt"), col.names = c("class_ID", "activity_name"))
features <- fread(file.path(wd, "UCI HAR Dataset/features.txt"), col.names = c("idx", "feature_names"))
keepers <- grep("(mean|std)\\(\\)", features[, feature_names]) #find mean|std feature data
kept_features <- features[keepers, feature_names] #create list of feature_names to keep
kept_features <- gsub('[()]', '', kept_features) #filter for kept features

# 4.a. Load and merge the datasets, load train_dataset
train_dataset <- fread(file.path(wd, "UCI HAR Dataset/train/X_train.txt"))[, keepers, with = FALSE]
data.table::setnames(train_dataset, colnames(train_dataset), kept_features)
train_labels <- fread(file.path(wd, "UCI HAR Dataset/train/Y_train.txt")
                       , col.names = c("activity_type"))
train_subjects <- fread(file.path(wd, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("subject_ID"))
train_dataset <- cbind(train_subjects, train_labels, train_dataset)

# 4.b. Same as 4.a. but for the test_dataset
test_dataset <- fread(file.path(wd, "UCI HAR Dataset/test/X_test.txt"))[, keepers, with = FALSE]
data.table::setnames(test_dataset, colnames(test_dataset), kept_features)
test_labels <- fread(file.path(wd, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("activity_type"))
test_subjects <- fread(file.path(wd, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("subject_ID"))
test_dataset <- cbind(test_subjects, test_labels, test_dataset)

# 4.c. Merge datasets
all_dataset <- rbind(train_dataset, test_dataset)

# 5. Label merged dataset. 
all_dataset[["activity_type"]] <- factor(all_dataset[, activity_type]
                              , levels = activity_labels[["class_ID"]]
                              , labels = activity_labels[["activity_name"]])

all_dataset[["subject_ID"]] <- as.factor(all_dataset[, subject_ID])
all_dataset <- reshape2::melt(data = all_dataset, id = c("subject_ID", "activity_type"))

# 6. Calculate means and standard deviations
all_dataset <- reshape2::dcast(data = all_dataset, subject_ID + activity_type ~ variable, fun.aggregate = mean)

# 7. Write the tidy dataset with the averages for each activity and subject to file.
data.table::fwrite(x = all_dataset, file = "tidy_dataset.txt", quote = FALSE)

## Grading rubric
#1. Merges the train and the test sets to create one data set; see part 4 above.
#2. Extracts only the measurements on the mean and standard deviation for each measurement; see part 6 above
#3. Uses descriptive activity names to name the activities in the data set; see part 5 above
#4. Appropriately labels the data set with descriptive variable names; see part 5 above 
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject; see part 7 above

#  THE END