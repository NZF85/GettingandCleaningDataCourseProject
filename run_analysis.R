library(reshape2)

SOURCE_URL = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
SOURCE_DEST = 'getdata_projectfiles_UCI_HAR_Dataset.zip'
SOURCE_MANIFEST <- c('UCI HAR Dataset/',
                     'UCI HAR Dataset/activity_labels.txt',
                     'UCI HAR Dataset/features.txt',
                     'UCI HAR Dataset/features_info.txt',
                     'UCI HAR Dataset/README.txt',
                     'UCI HAR Dataset/test',
                     'UCI HAR Dataset/test/Inertial Signals',
                     'UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/body_acc_y_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/body_acc_z_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/body_gyro_x_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/body_gyro_y_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/body_gyro_z_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/total_acc_x_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/total_acc_y_test.txt',
                     'UCI HAR Dataset/test/Inertial Signals/total_acc_z_test.txt',
                     'UCI HAR Dataset/test/subject_test.txt',
                     'UCI HAR Dataset/test/X_test.txt',
                     'UCI HAR Dataset/test/y_test.txt',
                     'UCI HAR Dataset/train',
                     'UCI HAR Dataset/train/Inertial Signals',
                     'UCI HAR Dataset/train/Inertial Signals/body_acc_x_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/body_acc_y_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/body_acc_z_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/body_gyro_x_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/body_gyro_y_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/body_gyro_z_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/total_acc_x_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/total_acc_y_train.txt',
                     'UCI HAR Dataset/train/Inertial Signals/total_acc_z_train.txt',
                     'UCI HAR Dataset/train/subject_train.txt',
                     'UCI HAR Dataset/train/X_train.txt',
                     'UCI HAR Dataset/train/y_train.txt')

### This function will download/unzip the files if necessary.
### It checks if all of the files exists.  If any is missing,
### it checks if the zip file exists.  If the zip file is missing
### it downloads the zip file and extracts the contents
prepare_source_files <- function() {
    if (!all(file.exists(SOURCE_MANIFEST))) {
        message("All files not in expected location")
        if (!file.exists(SOURCE_DEST)) {
            message("Source Zipfile missing, downloading: ", SOURCE_DEST)
            download.file(SOURCE_URL, SOURCE_DEST, method='curl')
        }
        message("Extracting ", SOURCE_DEST)
        unzip(SOURCE_DEST, overwrite=TRUE)
    }
    message("All files ready in: UCI HAR Dataset/")
    invisible()
}

### This function provides reusability for
### combining the training and test data
combine_train_test <- function(filename_prefix, colClasses) {
    train_filename <- paste('UCI HAR Dataset/',
                            'train/',
                            filename_prefix,
                            'train.txt', sep="")
    test_filename <- paste('UCI HAR Dataset/',
                            'test/',
                            filename_prefix,
                            'test.txt', sep="")
    message("Combining ", train_filename, " and ", test_filename)
    train_data <- read.table(train_filename, colClasses=colClasses)
    test_data <- read.table(train_filename, colClasses=colClasses)

    rbind(train_data, test_data)
}

message('--- Preparing original source data')
prepare_source_files()

####################################################################
### 1a. Merges the training and the test sets to create one data set.
####################################################################

message('--- Combining train and test data')
# Combine train and test data
measures <- combine_train_test('X_', 'numeric')
activities <- combine_train_test('y_', 'integer')
subjects <- combine_train_test('subject_', 'integer')

####################################################################
### 2. Extracts only the measurements on the mean and
###    standard deviation for each measurement.
####################################################################

message("--- Extracting only mean() and std() variables")
# Features
features <- read.table('UCI HAR Dataset//features.txt',
                       col.names=c('colIndex', 'feature'),
                       stringsAsFactors=FALSE)
# Assummed requirement is capture only measures
# that have mean() or std() in the name
features$is_mean_std <- grepl('(mean|std)\\(\\)',
                              features$feature,
                              perl=TRUE)
col_index_mean_std <- features[features$is_mean_std, ]$colIndex
measures <- measures[, col_index_mean_std]

####################################################################
### 4. Appropriately labels the data set with descriptive
###    variable names. 
####################################################################

message("--- Cleaning up variable names")
# Force to valid R names
col_clean_names <- make.names(features[col_index_mean_std, ]$feature)
# General name cleanup
col_clean_names <- gsub('\\.+', '.', col_clean_names, perl=TRUE)
col_clean_names <- gsub('\\.+$', '', col_clean_names, perl=TRUE)
# Swap axis and measure type
col_clean_names <- sub('(mean|std)\\.([XYZ])',
                       '\\2.\\1',
                       col_clean_names,
                       perl=TRUE)

names(measures) <- col_clean_names
names(activities) <- c("activity_id")
names(subjects) <- c("subject")

####################################################################
### 1b. Merges the training and the test sets to create one data set.
####################################################################

message("--- Final combination of subjects, activities and measures")
combined <- cbind(subjects, activities, measures)
# Make data long format
combined <- melt(combined, id.vars=c("activity_id", "subject"))

####################################################################
### 3. Uses descriptive activity names to name the activities
###    in the data set.
####################################################################
message("--- Merging in descriptive activity names.")
activity_names <- read.table('UCI HAR Dataset//activity_labels.txt')
names(activity_names) <- c("activity_id", "activity_description")

combined <- merge(combined, activity_names, by="activity_id")

####################################################################
### 5. Creates a second, independent tidy data set with the average
###    of each variable for each activity and each subject. 
####################################################################
message("--- Compute average by subject, activity, and variable")
tidy_data <- aggregate(combined['value'],
                       by=list(subject=combined$subject,
                               activity=combined$activity_description,
                               variable=combined$variable),
                       FUN=mean)
names(tidy_data) <- sub('value', 'average', names(tidy_data))

message("--- Writing to tidy_data.txt")
write.table(tidy_data, 'tidy_data.txt', row.names=FALSE)