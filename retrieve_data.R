# This script downloads and unzips the contents of the source
# data for the Getting and Cleaning Data Course Project
url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
dest = 'getdata_projectfiles_UCI_HAR_Dataset.zip'
download.file(url, dest, method='curl')
unzip(dest, overwrite=TRUE)
