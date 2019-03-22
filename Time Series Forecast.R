library(ggplot2)
library(forecast)
library(tseries)
library(TTR)
library(dplyr)

Overall_data2 <- read.csv("Overall_level_data2.csv", stringsAsFactors=FALSE)
train <- Overall_data2[1:48,]
test <- Overall_data2[49:60,]

#plotting the data
Overall_data$Date <- as.Date(Overall_data$Date, "%d/%m/%Y")
count_ts <- ts(train[, c('count')], frequency = 12, start = c(2014,1))
plot.ts(count_ts)

# if the variance vary with time we can use log  
logs_count <- log(count_ts)
plot.ts(logs_count)

#trend, seasonal and random components
#yearly seasonality
decompose_count_ts <- decompose(count_ts)
plot(decompose_count_ts)


#to remove the seasonality minus it with the season components
#Jan has the lowest seasonlity value and Dec had the highest value
decompose_count_ts$seasonal
decompose_count_ts_adj <- count_ts - decompose_count_ts$seasonal
plot(decompose_count_ts_adj)


#Augmented Dickey- Fuller test
#H0 - Data is not stationary 
#pvalue = 0.25 we cannot reject null hypothesis 
adf.test(count_ts, alternative = "stationary")

#Lets convert the data in stationary series
count_ts_diff12 <- diff(count_ts, differences = 12)
plot.ts(count_ts_diff12)

count_ts_diff1 <- diff(count_ts, differences = 1)
plot.ts(count_ts_diff1)

#p-value = 0.01, the series becomes stationary when differencing with order 1 & 12
adf.test(count_ts_diff1, alternative = "stationary")

#check acf and pacf of differenced to get the values of p, q
Acf(count_ts_diff1,lag.max=20, main='ACF for Differenced Series')
Acf(count_ts_diff1,lag.max=20, plot = F)
Pacf(count_ts_diff1, lag.max=20, main='PACF for Differenced Series')
Pacf(count_ts_diff1,lag.max=20, plot = F)

#ACF shows significance in lag 11 and 12 (which shows there is seasonality in the data)
#PACF shows significance in lag 2,11

#lets check with auto.arima
arima2 <- auto.arima(count_ts, seasonal = T)

#after running multiple combination of arima by checking minimum value of AIC and BIC
arima3 <- arima(log(count_ts), order = c(1,1,1), seasonal = list(order = c(0,1,1), period = 12))
summary(arima2)
summary(arima3)

# make a histogram of the forecast errors:
plotForecastErrors <- function(forecasterrors)
{
  mybinsize <- IQR(forecasterrors)/4
  mysd   <- sd(forecasterrors)
  mymin  <- min(forecasterrors) - mysd*5
  mymax  <- max(forecasterrors) + mysd*3
  mynorm <- rnorm(10000, mean=0, sd=mysd)
  mymin2 <- min(mynorm)
  mymax2 <- max(mynorm)
  if (mymin2 < mymin) { mymin <- mymin2 }
  if (mymax2 > mymax) { mymax <- mymax2 }
  mybins <- seq(mymin, mymax, mybinsize)
  hist(forecasterrors, col="red", freq=FALSE, breaks=mybins)
  myhist <- hist(mynorm, plot=FALSE, breaks=mybins)
  points(myhist$mids, myhist$density, type="l", col="blue", lwd=2)
}

#Ljung-Box test
#H0- The model does not exhibit lack of fit.
#p-value = 0.25, we cannot reject the null hyphthesis
Box.test(arima3$residuals, lag=20, type="Ljung-Box")

#residual analysis
#no line crosses the significance line in acf and pacf plot
acf(arima3$residuals, lag.max = 20)
pacf(arima3$residuals, lag.max = 20)

#Residual are randomly distributed and plot follows a normal distribution
plot.ts(arima3$residuals)
plotForecastErrors(arima3$residuals)
mean(arima3$residuals)

#qq plot
qqnorm(arima3$residuals)
qqline(arima3$residuals)

#transforming log to x
t <- forecast(arima3,n.ahead = 3)
t$x <- exp(t$x)
t$mean <- exp(t$mean)
t$upper <- exp(t$upper)
t$lower <- exp(t$lower)
t$residuals <- exp(t$residuals)
mean(t$residuals)

#Visualize the data
plot(t)

#RMSE
RMSE <- function(m, o){
  sqrt(mean((m - o)^2))
}

#Error percent is about 6% in test set
count_test <- ts(test[, c('count')], frequency = 12, start = c(2018,1))
RMSE(t$mean,count_test )


