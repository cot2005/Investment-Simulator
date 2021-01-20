################################
#Buying/Selling Functions
################################

# function to return a data frame with the buy date and price (Open) following a buy signal.
# requires the price data for the stk and the predictions data for the stock.

buy.RF.simple<-function(tickerdf, stkPredDF, dayhold = 10, rfProb = 0.85, RelProb = 0, RelDiff = 0.1) {
  buydates <- as.character(stkPredDF[which(stkPredDF[,4] > rfProb  & stkPredDF[,5] > RelProb & stkPredDF[,6] > RelDiff),2])
  buyrows <- match(buydates, tickerdf[,1]) - 1
  buyrows <- buyrows[buyrows >= dayhold]
  buyData <- data.frame(buyDate = tickerdf[buyrows,1], buyPrice = tickerdf[buyrows,2])
  buyData <- na.omit(buyData)
  return(buyData)
}

buy.NN.simple<-function(tickerdf, stkPredDF, dayhold = 10, nnProb = -6) {
  buydates <- as.character(stkPredDF[which(stkPredDF[,8] > nnProb),2])
  buyrows <- match(buydates, tickerdf[,1]) - 1
  buyrows <- buyrows[buyrows >= dayhold]
  buyData <- data.frame(buyDate = tickerdf[buyrows,1], buyPrice = tickerdf[buyrows,2])
  buyData <- na.omit(buyData)
  return(buyData)
}


####Sell Functions####
#inputs are ticker dataframe, buy date, and day limit.
#Simple selling ceiling/floor function
sell.simple<-function(tickerdf, buyRow, dayhold, sellceiling = 0.15, sellfloor = -0.15) {
  ceilingPrice = (1 + sellceiling) * tickerdf[buyRow,2]
  floorPrice = (1 + sellfloor) * tickerdf[buyRow,2]
  
  trimdf <- tickerdf[(buyRow - dayhold + 1):buyRow,]
  ceilingList <-  trimdf[,4] >= ceilingPrice
  floorList <- trimdf[,5] <= floorPrice
  if (TRUE %in% ceilingList || TRUE %in% floorList) {   # enters if either limit has been surpassed
    ceilingBreak <- which(ceilingList == TRUE)
    floorBreak <- which(floorList == TRUE)
    if (length(ceilingBreak) > 0) {   #ceiling 
      maxceiling <- max(ceilingBreak)
    } else {
      maxceiling <- 0
    }
    if (length(floorBreak) > 0) {
      maxfloor <- max(floorBreak)
    } else {
      maxfloor <- 0
    }
    if (maxceiling >= maxfloor) {
      sellData <- data.frame(SellDate = trimdf[maxceiling,1], SellPrice = ceilingPrice)
    } else {
      sellData <- data.frame(SellDate = trimdf[maxfloor,1], SellPrice = floorPrice)
    }
  } else {  # if price does not surpass the ceiling or floor
    sellData <- data.frame(SellDate = trimdf[1,1], SellPrice = trimdf[1,3])
  }
  return(sellData)
}

# trailing stop loss sell function that triggers sell when day price swing exceeds
# ceiling of floor percentage changes from highest price.
# Ties go to ceiling sell.
# 
sell.trailing.sls<-function(tickerdf, buyRow, dayhold, sellfloor = -0.15, sellceiling = 0.2) {
  ceilingprice <- tickerdf[buyRow,2] * (sellceiling + 1)
  trimdf <- tickerdf[(buyRow - dayhold + 1):buyRow,]
  slsList <- c(trimdf[nrow(trimdf),4])
  for (i in (nrow(trimdf)-1):1) {   # calculates sls prices
    maxPrice <- max(trimdf[i,4], slsList[1])
    slsList <- append(maxPrice, slsList)
  }
  trimdf$sls <- slsList * (1 + sellfloor)
  trimdf$slstrigger <- trimdf[,3] < trimdf$sls   # if sls is triggered if close is below sls
  trimdf$ceilingtrigger <- trimdf[,4] >= ceilingprice
  slsRow <- which(trimdf$slstrigger == TRUE)
  if (length(slsRow) == 0) {slsRow <- 0}
  ceilingRow <- which(trimdf$ceilingtrigger == TRUE)
  if (length(ceilingRow) == 0) {ceilingRow <- 0}
  if (slsRow == 0 && ceilingRow == 0) {   #if no sls or ceiling is triggered then closing price of last day
    sellData <- data.frame(SellDate = trimdf[1,1], SellPrice = trimdf[1,3])
  } else {   # if sls or ceiling is triggered
    if (max(ceilingRow) >= max(slsRow)) {  #if ceiling is triggered
      sellData <- data.frame(SellDate = trimdf[max(ceilingRow),1], SellPrice = ceilingprice)
    } else {   # if ceiling is not triggered then sls price.
      sellData <- data.frame(SellDate = trimdf[max(slsRow),1], SellPrice = trimdf[max(slsRow),7])
    }
  }
  return(sellData)
}
