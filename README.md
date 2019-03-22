# Time-Series-Forecast

Problem Statement:-
----------------
To estimate number of customer coming to a resort every month, along with predict the quantity of gaming or non gaming customer and estimate the revenue generated, number of room nights booked and card type of a customer.

## Methodology ##
We used Hierarchical time series, top-down approach to make our prediction

* We aggregated the data into monthyear for all the metrics and dimension we want to add in our model

* In total, we used 5 year (Jan'13- Dec'17) of historical data to train our model and kept Jan'18 - Feb'19 to test the model  

* Our first model was trained with monthyear and number of customer visited to predict the count of the customer visited in 2018. Even though we did not did any breakdown, the model performed decently and had a error rate of 8% in test set. We kept this model as our baseline model so that when we do top - down method our final error rate should be less than 8%.

### Creating multiple cohorts 

* We divided the data into New customer and Returning customer. As we would not have any past data for new customer it would be best to make a separate cohort and predict them.

* Then we divided Returning customer into gaming customer and non gaming customer. Then these two group were further divided based on their spending behaiviour by making 4 cohort in each group

* So in total there were 9 cohort (4-Returning and gaming customer, 4-Returning and non- gaming customer and 1-New customer)

* We ran Seasonal ARIMA model in each cohort and then summed up each group to generate the prediction for the month. We ran this process for every metrics we wanted to predict.

For Example <br />
Metrics:- Visitor <br />
Error rate in Test data when there was no division = 8% <br />
Error rate in Test data after summing up all the cohorts = 3% <br />

### Note:-

* I have uploaded the code for the model when there was no segmenting done. I have mentioned all the process required to do a forecast through ARIMA. For doing the forecasting in each cohort the codes would be same

* All the cleaning and segmentation of the data is done in Redshift. We have an active customer base of 50 Million customer and require multiple tables to extract and transform the data as per our requirement, whixh is a huge task by its own.

