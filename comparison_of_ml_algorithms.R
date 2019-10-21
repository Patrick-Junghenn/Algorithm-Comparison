# General 
library(tidyverse)
library(skimr)
library(rlist)
# Preprocessing
library(recipes)

credit <- read_csv("application.csv")
head(credit)

#view
skim_to_list(credit)

#counts of missing value in each column
na_count <-sapply(credit, function(y) sum(length(which(is.na(y)))))
na_count <- data.frame(na_count)
na_count

#percentage of missing value
missing_tbl <- credit %>%
     summarize_all(.funs = ~ sum(is.na(.)) / length(.)) %>%
     gather() %>%
     arrange(desc(value)) %>%
     filter(value > 0)
print(head(missing_tbl))

#Shape: 65499 X 122
dim(credit)

# response varible "TARGET"
target = 'TARGET'

#Train predictors--exclude response
x_train <- credit[ , !(names(credit) %in% target)]
y_train <- credit[target] 

#get the column name of char features
character_col_name <- colnames(x_train[, sapply(x_train, class) == 'character'])

#get the column name of numeric features whose unique counts less than 7
unique_val <- x_train %>%
     select_if(is.numeric) %>%
     map_df(~ unique(.) %>% length()) %>%
     gather() %>%
     arrange(value) %>%
     mutate(key = as_factor(key))
factor_limit <- 7
num_col_name <- unique_val %>%
     filter(value < factor_limit) %>%
     arrange(desc(value)) %>%
     pull(key) %>%
     as.character()

# gather functions for baking
recipe_step <- recipe(~ ., data = x_train) %>%
     step_string2factor(character_col_name) %>%
     step_num2factor(num_col_name) %>%
     step_meanimpute(all_numeric()) %>%
     step_modeimpute(all_nominal()) %>%
     prep(stringsAsFactors = FALSE)
recipe_step

#cleaned data
x_train_processed <- bake(recipe_step, x_train) 

#Process target training set
y_train_processed <- y_train %>%
     mutate(TARGET = TARGET %>% as.character() %>% as.factor())

#initialize h2o, and make train, validation, and test datasets
library(h2o)

#starts h2o using all CPUs
h2o.init(nthreads=-1)

#create an h2o dataset
data_h2o <- as.h2o(bind_cols(y_train_processed, x_train_processed))

#split data training, validation, and testing.
splits_h2o <- h2o.splitFrame(data_h2o, ratios = c(0.7, 0.15), seed = 1234)
train_h2o <- splits_h2o[[1]]
valid_h2o <- splits_h2o[[2]]
test_h2o  <- splits_h2o[[3]]

y <- "TARGET"
x <- setdiff(names(train_h2o), y)
#AutoML from h2o that will create the ML models. 
automl_models_h2o <- h2o.automl(
     x = x ,
     y = y,
     training_frame    = train_h2o,
     validation_frame = test_h2o,
     max_models=5,
     seed=123
)

automl_models_h2o