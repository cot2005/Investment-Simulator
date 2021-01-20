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
    if (buytype == "rf") {   # add new buy functions here
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



################################################
#Function for Master Simulator
################################################

# v2.0 simulator to simulate a trade after a designated buy date and price. It will then simulate the
# selling/holding duration based on the sell function.
#
# the simulator will return a dataframe row with columns: Ticker, buy date, buy price, sell date, sell price.
#

sim.tradev2.0<-function(ticker, buydate, predDF, sellfunction = "simple", dayhold = 10, sell.ceiling = 0.2, sell.floor = -0.1,
                        sell.rf = 0.85, sell.relprob = 0, sell.reldiff = 0.1, sell.nn = -5) {
  stkfile <- paste(ticker , ".txt", sep = "")
  stk <- read.table(stkfile, header = FALSE, sep = "\t")
  buyRow <- which(stk[,1] == as.character(buydate))
  # calls sell functions
  if (sellfunction == "simple") {   # add new sell functions here
    sellData <- sell.simple(tickerdf = stk, buyRow = buyRow, dayhold = dayhold, sellceiling = sell.ceiling, sellfloor = sell.floor)
  } else if (sellfunction == "sls") {
    sellData <- sell.trailing.sls(tickerdf = stk, buyRow = buyRow, dayhold = dayhold, sellfloor = sell.floor, sellceiling = sell.ceiling)
  }
  sim.sell <- data.frame(SellDate = sellData[1,1], SellPrice = sellData[1,2])
  return(sim.sell)
}
