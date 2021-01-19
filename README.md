# Investment-Simulator
This repository contains functions to simulate investments based on pre-calculated probability metrics. This set of functions is highly customizable to simulate any desired investment strategy. The master simulator imports the prediction and price data (all files must be in the working directory with .txt extension) then calls desired buy functions and sell functions to simulate the buy and sell prices within a time frame (days).

The buy functions must be sourced in the session and defines how/when to enter a trade. It then returns a 2 column dataframe containing the buy date and the buy price for one stock.

The sell functions define to sell after the buy date based on prediction metrics or price points.

The repository includes example buy function to simulate buy orders based on prediction metrics. It also includes simple sell functions to simulate stop loss sell orders and stop loss limit/limit orders.


Input reference prediction data format:
```
Ticker  Date  Close Prediction1 Prediction2 ... PredictionN
AAPL	2018-10-26	50.98	0.3876	0.648239497
AAPL	2018-09-23	52.48	0.23516	-0.036229508
AZN	2019-10-26	53.07	0.244	0.002629849
AZN	2019-10-23	52	0.24336	0.250308261
AZN	2019-08-22	51.96	0.19464	-0.196764609
AZN	2019-08-21	51.57	0.24232	-0.054914197
...
```

Output trading log and results:
```
Ticker	buyDate	buyPrice	SellDate	SellPrice	pctChange
AAPL	2020-11-06	2.57	2020-12-04	3	0.167315175097276
AZN	2020-10-14	2.08	2020-10-15	1.8	-0.134615384615385
AMZN	2020-11-03	2.04	2020-12-01	2.42	0.186274509803922
TSLA	2020-10-21	0.9788	2020-11-05	0.856	-0.125459746628525
RCON	2020-10-20	1.33	2020-10-20	1.344	0.0105263157894737
TOPS	2020-11-11	1.18	2020-12-04	1.376	0.166101694915254
```
