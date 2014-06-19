# GettingandCleaningDataCourseProject

Course Project for Coursera Getting and Cleaning Data

The result of running the *run_analysis.R* script is the tidy_data.txt file, which
is a space delimited with header text file which can be read into R
```R
read.table('tidy_data.txt', header=TRUE)
```

## Objective:
Produce a tidy data set from the "Human Activity Recognition Using Smartphones Dataset"
Version 1.0.

> You should create one R script called run_analysis.R that does the following:
> 1. Merges the training and the test sets to create one data set.
> 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
> 3. Uses descriptive activity names to name the activities in the data set
> 4. Appropriately labels the data set with descriptive variable names. 
> 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

Note that since #5 is the only step that discusses the tidy data, the resulting tidy_data.txt
file is the one submitted for the course project.

## Producing the tidy data
From the repository, you can run:
```bash
Rscript run_analysis.R
```

The script will download the data file, unzip the file contents and process the data
to produce **tidy_data.txt**

This was tested on R version 3.1.0 on Mac OSX 10.9.3

Once produced, the data can be

## tidy_data.txt fulfills *Tidy Data* requirements

1. Each variable your measure should be in one column:
  * No single column in the tidy_data.txt file contains more than one variable.  See Long Format rationale.
2. Each different observation of that variable should be in a different row.
  * For purposes of the tidy_data.txt, each observation is considered for each subject, activity, and feature.
    Thus, having each row uniquely identified by the subject, activity and feature.
3. There should be one table for each "kind" of variable
  * This tidy data is only one table, as we're capturing the mean by subject, activity and feature
4. If you have multiple tables, they should include a column in the table that allows them to be linked
  * Not applicable, since there is only 1 table

## Rationale for long format (versus wide format)

The tidy data is in the long format, where each feature is identified as a separate row instead of being a
separate column header.  This allows for some scalability without dramatically altering the data format:

* If we decided to include more features, it would only add more rows to the data, not add more columns
* If we decided to measure the standard deviation with the mean of the features, the tidy data
  would only require an additional column.  The wide format would nearly double the number of columns
  required or require a separate table to fulfill #3 of the *Tidy Data* requirements

## Rationale for only including the mean() and std() features

The course assignment did not explicitly exclude features such as *tBodyAccJerkMean*, however
for parsimony, the script only includes the feature that end with mean() or std(), as these features
have both mean and standard deviation measures, where as the *tBodyAccJerkMean* has not standard deviation
analogue.

## Rationale for feature naming in tidy data

The feature names in the tidy data were altered as follows:

* only include characters for valid R names
* place the mean and std as the suffix so that feature names would sort and cluster naturally
