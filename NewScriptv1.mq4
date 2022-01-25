//+------------------------------------------------------------------+
//|                                                  NewScriptv1.mq4 |
//|                                                           Artaya |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Artaya"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string BotName = "Demo Bot";
int Magic = 3625278;
int MaxTrades = 1;
double LotsToTrade = 1.2;
double StopLoss = -4500.00;
double ProfitTarget = 40.00;
int MaxCloseSpreadPips = 7;
double currentPrice = Close[0];
double lastPrice = Open[1];


int SMAFast = 145;
int SMASlow = 250;
bool LongSetup = False;


// Time Trade delay
int TradeDelayTimeSeconds = (1 * 24 * 60 * 60);// Delay next trade 5 hari
datetime LastTradePlacedTimestamp = 0;



int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
  


void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   double SlowMovingAverage = GetMovingAverage(0, SMASlow);
   double SlowMovingAverageOne = iMA(NULL, 0, SMASlow, 0, MODE_SMA, PRICE_CLOSE,3);
   double SlowMovingAverageTwo = iMA(NULL, 0, SMASlow, 0, MODE_SMA, PRICE_CLOSE,15);
   double SlowMovingAverageThree = iMA(NULL, 0, SMASlow, 0, MODE_SMA, PRICE_CLOSE,30);
 
 
   double FastMovingAverage = GetMovingAverage(0, SMAFast);
     double FastMovingAverageOne = iMA(NULL, 0, SMAFast, 0, MODE_SMA, PRICE_CLOSE,3);
       double FastMovingAverageTwo = iMA(NULL, 0, SMAFast, 0, MODE_SMA, PRICE_CLOSE,15);
         double FastMovingAverageThree = iMA(NULL, 0, SMAFast, 0, MODE_SMA, PRICE_CLOSE,30);
         
    
   Print("Waktu",TimeCurrent());
  
  //int Trades = GetTotalOpenTrades();
  //Print("total  trade = ",Trades);
  
  if(GetTotalOpenTrades() < MaxTrades)
    {
     //che for  long trade
     
     if((TimeCurrent() - LastTradePlacedTimestamp) < TradeDelayTimeSeconds) return;
        if((FastMovingAverage < SlowMovingAverage) && (currentPrice > lastPrice))
          {
         LongSetup = True;
          Print("Long Stup true");
          }

     if(LongSetup == True)
       {
          int OrderResult = OrderSend(Symbol(), OP_SELL, LotsToTrade, Bid, 10, 0, 0, "Buy order", Magic, 0,clrGreen);
    
          LastTradePlacedTimestamp = TimeCurrent();
       }else
          {
             int OrderResult = OrderSend(Symbol(), OP_BUY, LotsToTrade, Ask, 10, 0, 0, "Buy order", Magic, 0,clrGreen);
             LongSetup = False;
               LastTradePlacedTimestamp = TimeCurrent();
          }

    }
    
    if(GetTotalProfits() > ProfitTarget)CloseAllTrades();
    if(GetTotalProfits() < StopLoss) CloseAllTrades();

  }
  
  double GetMovingAverage(int Shift,  int SMA)
  {
  return iMA(NULL, 0, SMA, 0, MODE_SMA, PRICE_CLOSE,Shift);
  }
  
  //return totaal number open trades
  int GetTotalOpenTrades(){
   int TotalTrades = 0;
   for(int t=0;t<OrdersTotal();t++)
     {
      if(OrderSelect(t, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() != Symbol()) continue;
           if(OrderMagicNumber() != Magic) continue;
             if(OrderCloseTime() != 0) continue;
             
             TotalTrades = (TotalTrades + 1);
          
        }
     }
     
     return TotalTrades;
  }
  
  void CloseAllTrades(){
  
  int CloseResult = 0;
  
  for(int t=0;t<OrdersTotal();t++)
    {
    if(OrderSelect(t,SELECT_BY_POS, MODE_TRADES))
      {
        if(OrderMagicNumber() != Magic) continue;
  if(OrderSymbol() != Symbol()) continue;
  if(OrderType() == OP_BUY) CloseResult = OrderClose(OrderTicket(), OrderLots(), Bid, MaxCloseSpreadPips, clrRed);
  if(OrderType() == OP_SELL) CloseResult = OrderClose(OrderTicket(), OrderLots(), Bid, MaxCloseSpreadPips, clrRed);
  t--;
    }
      }
     
    return;
  }
  
 double GetTotalProfits()
 {
      double TotalProfits = 0.0;
      
      for(int t=0;t<OrdersTotal();t++)
    {
    if(OrderSelect(t,SELECT_BY_POS, MODE_TRADES))
      {
        if(OrderMagicNumber() != Magic) continue;
  if(OrderSymbol() != Symbol()) continue;
  if(OrderCloseTime() != 0) continue;
  
  TotalProfits = (TotalProfits + OrderProfit());

    }
      }
      return  TotalProfits;

 }
  
  
//+------------------------------------------------------------------+
