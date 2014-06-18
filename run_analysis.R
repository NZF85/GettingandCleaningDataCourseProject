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

prepare_source_files()

# Combine train and test data
measures <- combine_train_test('X_', 'numeric')
activities <- combine_train_test('y_', 'integer')
subjects <- combine_train_test('subject_', 'integer')

# Features
features <- read.table('UCI HAR Dataset//features.txt',
                       col.names=c('colIndex', 'feature'),
                       stringsAsFactors=FALSE)
features$is_mean_std <- grepl('(mean|std)\\(\\)',
                              features$feature,
                              perl=TRUE)
colIndex_mean_std <- features[features$is_mean_std, ]$colIndex
col_clean_names <- gsub('\\(|\\)', '',
                        features[colIndex_mean_std, ]$feature,
                        perl=TRUE)

measures <- measures[, colIndex_mean_std]
names(measures) <- col_clean_names