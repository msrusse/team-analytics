
# assuming df is the name of the data frame
# this will show the names of columns in the data frame
names(df)

#this will show the columnname s
colnames(df)

# this will show the type of variables and data dictionary of the various variables

str(df)

# this will show the first few rows of the data frame
print(head(df))

#this will show the summary statistics of the data frame
summary(df)

# this will show box plot of the numeric parts of the dataframe

boxplot(df)

# this will show correlation among the numeric features of the data frame
cor(df)

# this will make plots of variables in df
plot(df)


