library(tidyverse)
library(skimr)
library(rlist)
library(recipes)

credit <- read_csv("application.csv")
head(credit)
skim_to_list(credit)

#missings
na_count <-sapply(credit, function(y) sum(length(which(is.na(y)))))
na_count <- data.frame(na_count)
na_count

missing_tbl <- credit %>%
     summarize_all(.funs = ~ sum(is.na(.)) / length(.)) %>%
     gather() %>%
     arrange(desc(value)) %>%
     filter(value > 0)
                  
print(head(missing_tbl))           
dim(credit)

target = 'TARGET'
x_train <- credit[ , !(names(credit) %in% target)]
y_train <- credit[target] 
                  
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

y_train_processed <- y_train %>%
     mutate(TARGET = TARGET %>% as.character() %>% as.factor())

#H2o 
library(h2o)
h2o.init(nthreads=-1)
#create an h2o dataset and train test val
data_h2o <- as.h2o(bind_cols(y_train_processed, x_train_processed))
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
