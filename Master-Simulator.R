MasterSimulatorv2.0<-function(simReference = "simulationRef.txt", simreportOutput = "simResults.txt", dayhold = 20,
                              buytype = "nn", buy.m1 = 0.9, buy.m2 = 0, buy.m3 = 0,
                              selltype = "simple", sell.ceiling = 0.3, sell.floor = -0.2) {
  #gets list of stks to perform simulation with
  tickerfiles <- list.files(pattern = ".txt")
  tickerfiles <- tickerfiles[-which(tickerfiles == simReference)]   # removes simulation reference file from list
  tickertable <- data.frame(Files = tickerfiles, Tickers = gsub(".txt", "",tickerfiles), stringsAsFactors = F)
  
  # imports prediction reference data for simulation
  stkPredData <- read.table(simReference, sep = "\t", header = T)
  
  tickerList <- data.frame(Tickers = levels(stkPredData$Ticker))
  tickerList$filenames <- paste(tickerList$Tickers, ".txt", sep = "")
  numtickers <- nrow(tickerList)
  
  #Begins Simulating each of the stocks
  tradingLog <- data.frame()
  for (i in 1:numtickers) {   #loops through each stk
    stkdata <- read.table(tickerList$filenames[i], sep = "\t", header = T, stringsAsFactors = F)
    tempPred <- stkPredData[which(stkPredData$Ticker == tickerList$Tickers[i]),]
    # Calls the buying function to find entry points.
    if (buytype == "rf") {
      tempTrades <- buy.RF.simple(tickerdf = stkdata, stkPredDF = tempPred, dayhold = dayhold, rfProb = buy.m1, RelProb = buy.m2, RelDiff = buy.m3)
    } else if (buytype == "nn") {
      tempTrades <- buy.NN.simple(tickerdf = stkdata, stkPredDF = tempPred, dayhold = dayhold, nnProb = buy.m1)
    }
    tempSells <- data.frame()
    if (nrow(tempTrades) > 0) {   # If entry points exist they will be simmed otherwise skip ticker
      for (j in 1:nrow(tempTrades)) {
        tradeResults <- sim.tradev2.0(ticker = tickerList$Tickers[i], buydate = tempTrades[j,1], predDF = tempPred, dayhold = dayhold,
                                      sellfunction = selltype, sell.ceiling = sell.ceiling, sell.floor = sell.floor)
        tempSells <- rbind(tempSells, tradeResults)
      }
      tempTrades <- cbind(Ticker = tickerList$Tickers[i], tempTrades, tempSells)
      tradingLog <- rbind(tradingLog, tempTrades)
    }
  }
  tradingLog$pctChange = (tradingLog[,5] - tradingLog[,3])/tradingLog[,3]
  write.table(tradingLog, simreportOutput, sep = "\t", col.names = T, row.names = F, quote = F)
}
