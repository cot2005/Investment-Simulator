MasterSimulatorv2.0<-function(simreportOutput = "simResults.txt", dayhold = 20,
                              buytype = "rf", buy.rf = 0.9, buy.relprob = 0, buy.reldiff = 0.1, buy.nn = -5,
                              selltype = "simple", sell.rf = 0.55, sell.relprob = 0, sell.reldiff = -0.14,
                              sell.ceiling = 0.3, sell.floor = -0.2) {
  #gets list of stks to perform simulation with
  tickerfiles <- list.files(pattern = ".txt")
  tickertable <- data.frame(Files = tickerfiles, Tickers = gsub(".txt", "",tickerfiles), stringsAsFactors = F)
  
  # calculates the prediction metrics for all the stks
  stkPredData <- read.table("simulationRef.txt", sep = "\t", header = T)
  
  tickerList <- data.frame(Tickers = levels(stkPredData$Ticker))
  tickerList$filenames <- paste(tickerList$Tickers, ".stk", sep = "")
  numtickers <- nrow(tickerList)
  
  #Begins Simulating each of the stks
  tradingLog <- data.frame()
  for (i in 1:numtickers) {   #loops through each stk
    stkdata <- read.table(tickerList$filenames[i], sep = "\t", header = T, stringsAsFactors = F)
    tempPred <- stkPredData[which(stkPredData$Ticker == tickerList$Tickers[i]),]
    # Calls the buying function to find entry points.
    if (buytype == "rf") {
      tempTrades <- buy.RF.simple(tickerdf = stkdata, stkPredDF = tempPred, dayhold = dayhold, rfProb = buy.rf, RelProb = buy.relprob, RelDiff = buy.reldiff)
    } else if (buytype == "nn") {
      tempTrades <- buy.NN.simple(tickerdf = stkdata, stkPredDF = tempPred, dayhold = dayhold, nnProb = buy.nn)
    } 
    tempSells <- data.frame()
    if (nrow(tempTrades) > 0) {   # If entry points exist they will be simmed otherwise skip ticker
      for (j in 1:nrow(tempTrades)) {
        tradeResults <- sim.tradev2.0(ticker = tickerList$Tickers[i], buydate = tempTrades[j,1], predDF = tempPred, dayhold = dayhold, sell.ceiling = sell.ceiling,
                                      sellfunction = selltype, sell.rf = sell.rf, sell.relprob = sell.relprob, sell.reldiff = sell.reldiff, 
                                      sell.floor = sell.floor)
        tempSells <- rbind(tempSells, tradeResults)
      }
      tempTrades <- cbind(Ticker = tickerList$Tickers[i], tempTrades, tempSells)
      tradingLog <- rbind(tradingLog, tempTrades)
    }
  }
  tradingLog$pctChange = (tradingLog[,5] - tradingLog[,3])/tradingLog[,3]
  write.table(tradingLog, simreportOutput, sep = "\t", col.names = T, row.names = F, quote = F)
}
