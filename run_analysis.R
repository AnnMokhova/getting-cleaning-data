library(reshape2)
library(dplyr)

# gets and unzips data

fileUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

download.file(fileUrl, destfile = 'project.zip')

if (!file.exists('./data')){
  unzip('project.zip')
}

# 1. merges data set

subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt')
x_test <- read.table('UCI HAR Dataset/test/X_test.txt')
y_test <- read.table('UCI HAR Dataset/test/y_test.txt')

subject_train <- read.table('UCI HAR Dataset/train/subject_train.txt')
x_train <- read.table('UCI HAR Dataset/train/X_train.txt')
y_train <- read.table('UCI HAR Dataset/train/y_train.txt')

subject_data <- rbind(subject_test, subject_train)
x_data <- rbind(x_test, x_train)
y_data <- rbind(y_test, y_train)

# 2. extracts the measurements on the mean and standard deviation

labels <- read.table('UCI HAR Dataset/activity_labels.txt')
labels[,2] <- as.character(labels[,2])

features <- read.table('UCI HAR Dataset/features.txt')
features[,2] <- as.character(features[,2])

selectedFeatures <- grep('-(mean|std).*', as.character(features[,2]))
columns <- features[selectedFeatures, 2]

# 3. uses descriptive activity names and labels the data set with descriptive variable names

x_data <- x_data[selectedFeatures]
all_data <- cbind(subject_data, y_data, x_data)
colnames(all_data) <- c('subject', 'activity', columns)

all_data$activity <- factor(all_data$activity, levels = labels[,1], labels = labels[,2])
all_data$subject <- as.factor(all_data$subject)

#4. creates independent tidy data set
melted <- melt(all_data, id = c('subject', 'activity'))
tidy <- dcast(melted, subject + activity ~ variable, mean)

write.table(tidy, './tidy.txt', row.names = FALSE, quote = FALSE)

