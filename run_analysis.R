library(reshape2)
setwd("~/coursera")

# 1. Get datasets
if (!file.exists("~/coursera")) {
  dir.create("~/coursera")
  download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = paste("~/coursera", "/", "raw_data.zip", sep = ""))
}

if (!file.exists("~/data")) {
  dir.create("~/data")
  unzip(zipfile = paste("~/coursera", "/", "raw_data.zip", sep = ""), exdir = "~/data")
}

# 2. Merge datasets
# Train data
x_train <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/train/y_train.txt"))
s_train <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/train/subject_train.txt"))

#Test data
x_test <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/test/y_test.txt"))
s_test <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/test/subject_test.txt"))

# Metge data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

summary(y_data)

#3. load feature & activity info
# Feature info
feature <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/features.txt"))

# Activity labels
act_label <- read.table(paste(sep = "", "~/data", "/UCI HAR Dataset/activity_labels.txt"))
act_label[ ,2] <- as.character(act_label[ ,2])

# Extract feature cols & names named 'mean, std'
selected_cols <- grep("-(mean|std).*", as.character(feature[ ,2]))
selected_col_names <- feature[selected_cols, 2]
selected_col_names <- gsub("-mean", "Mean", selected_col_names)
selected_col_names <- gsub("-std", "Std", selected_col_names)
selected_col_names <- gsub("[-()]", "", selected_col_names)

#4. Extract data by cols & using descriptive name
x_data <- x_data[selected_cols]
all_data <- cbind(s_data, y_data, x_data)
colnames(all_data) <- c("Subject", "Activity", selected_col_names)

all_data$Activity <- factor(all_data$Activity, levels = act_label[ ,1], labels = act_label[ ,2])
all_data$Subject <- as.factor(all_data$Subject)


#5. Generate tidy data set
melted_data <- melt(all_data, id = c("Subject", "Activity"))
tidy_data <- dcast(melted_data, Subject + Activity ~ variable, mean)

write.table(tidy_data, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)