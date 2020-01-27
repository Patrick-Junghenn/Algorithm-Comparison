## The Effectiveness of Logistic Regression When Applied to High Dimensional Data
This repository contains the code written to analyze the computational complexity of various machine learning algorithms when applied to credit loan data. It also contains an R Markdown file that delivers the analysis. The analysis shown below is taken directly from the analysis conducted in the R Markdown file.

##### The purpose of this article is to demonstrate the effectiveness of using Logistic Regression when confronted with high dimensional data

### Introduction
Although sophisticated machine learning models, such as Deep Neural Networks, Random Forests, and Gradient Boosted Machines, are known for their ability to achieve highly accurate results, they are not always the best option when working with high dimensional data. Logistic Regression is a powerful contender to some of the more advanced machine learning algorithms available when applied toward high dimensional data. Logistic regression belongs to a broader class of models called *Generalized Linear Models*, or, GLMs. GLMs have become the algorithm of choice for credit modeling.

To gain a better understanding of the capability of a Logistic Regression model, we utilized a credit default dataset taken from kaggle.com. We then created numerous machine learning models to compare their AUC score to that of the Logistic Regression model. To efficiently create a wide variety of machine learning models, we used the AutoML function offered through H2O.

### Data Exploration & Preprocessing
Using the skim_to_list() function located in the skimr library, essential characteristics of the data (missing values and brief descriptive statistics) were displayed. The dataset contained 65,499 observations, 121 features, and one target variable. Many features were missing over 60% of their instances. To preprocess the data, the recipe() function was used. This function, upon execution, performed all of the necessary preprocessing operations to the dataset. This ensured that the data was in agreement with H2O's data requirements.

### Modeling Process and Evaluation  
Credit analysts exhaust all available resources when it comes to risk mitigation. However, factors such as turnover rate and profitability often force modelers to make compromises. Complex machine learning algorithms are too computationally expensive for repeated training and testing. Logistic Regression is a less complex algorithm but it still achieves very satisfying results.  

To see how strong Logistic Regression performed against other machine learning algorithms, we created 10 different models. We used the AutoML function available in H2O to generate the models. Using the held-out validation set, we computed the AUC for each of the models. The AutoML function generated, cross-validated, and tested various kinds of machine learning algorithms. The logistic regression model performed remarkably well. Other than the models that utilized stacking methods, the logistic regression achieved the highest AUC score.

### Concluding Analysis
In conclusion, we observed how a Logistic Regression model can be highly effective when used for the appropriate task. It grossly outperformed more complex algorithms when applied to the same dataset. The interpretability of a Logistic Regression model is superior to that of complex black-box-algorithms. A Logistic Regression model is a desirable choice when feature selection is essential. The confusion matrix showed that the error rate is lower for individuals denied loans. The extension of a loan to a questionable applicant is more detrimental, and risky to a business than incorrectly denying the loan to qualified applicants. Newer models, such as Extremely Randomized Trees and Deep Random Forests, performed poorly compared to Logistic Regression. The Stacked Ensemble model achieved the highest AUC, but it was only .200285% larger than the Logistic Regression model's AUC.
