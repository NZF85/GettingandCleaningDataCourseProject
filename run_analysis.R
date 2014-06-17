combine_train_test <- function(filename_prefix, colClasses) {
    train_filename <- paste('UCI HAR Dataset/',
                            'train/',
                            filename_prefix,
                            'train.txt', sep="")
    test_filename <- paste('UCI HAR Dataset/',
                            'test/',
                            filename_prefix,
                            'test.txt', sep="")
    train_data <- read.table(train_filename, colClasses=colClasses)
    test_data <- read.table(train_filename, colClasses=colClasses)

    rbind(train_data, test_data)
}

# Combined train and test data
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