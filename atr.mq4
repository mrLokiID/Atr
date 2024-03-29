//+------------------------------------------------------------------+
//|                                                          atr.mq4 |
//|                                                          mr.Loki |
//|                                                                @ |
//+------------------------------------------------------------------+
#property copyright "mr.Loki"
#property link      "@"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--Настройки для расчета ATR
extern int atr_day=10; //Дневной ATR
extern int atr_week = 10; //Недельный ATR
extern int atr_month = 10; //Месячный ATR
//--конец настроек для расчета ATR

//--Клаыиши для постраяения ATR
extern int Key1 = 49;             //Клавиша для отрисовки дневного ATR
extern int Key2 = 50;             //Клавиша для отрисовки недельного ATR
extern int Key3 = 51;             //Клавиша для отрисовки месячного ATR
//--конец клавишь для постраения ATR

double price;
datetime time_mouse;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(UninitializeReason()!=REASON_CHARTCHANGE) // При смене таймфрэйма не выполняем
     {
      //--- включение сообщений о перемещении мыши по окну чарта
      ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_MOUSE_MOVE) //отслеживание мыши
     {
      int SubWindow;
      ChartXYToTimePrice(0,(int)lparam,(int)dparam,SubWindow,time_mouse,price);
     }
   if(id==CHARTEVENT_KEYDOWN) // отслеживание нажатия клавиатуры
     {
      if(lparam==Key1)
        {
         Create_Atr(atr_day, PERIOD_D1, time_mouse, "дневного", clrRed);
        }
      if(lparam==Key2)
        {
         Create_Atr(atr_day, PERIOD_W1, time_mouse, "недельного", clrMediumBlue);
        }
      if(lparam==Key3)
        {
         Create_Atr(atr_day, PERIOD_MN1, time_mouse, "месячного", clrDarkOrchid);
        }
     }
  }

//+------------------------------------------------------------------+
/*
В метод Create_Atr передаются следующие параметры:
periyd_atr - количество дней которые берется для расчета их можно задавать в настройках индикатора
time_frame - тайм фрейм на котором происходит расчет и создание зон
time - значение времени берется исходят из положения курсора на графике
name - имя зоны
color_zon - цвет зоны
*/
void Create_Atr(int periyd_atr, int time_frame, datetime time, string name, color color_zon)
  {
   double open_price=0,    // Цена отрытия
          summ=0,          // Сумматор
          price_high=0,    // Цена максимума
          price_low=0;     // Цена минемума
   datetime time_zon_end;  // Время окончния зоны

   int bar_shift=iBarShift(_Symbol,time_frame,time); // Определям номер бара под курсором мыши
   if(bar_shift==-1) // Если бар не найден
     {
      Alert("Бар не найден");
     }
   for(int i=bar_shift+1; i<bar_shift+periyd_atr+1; i++) //Цикл расчета среднего значения
     {
      summ+=MathAbs(iLow(_Symbol,time_frame,i)-iHigh(_Symbol,time_frame,i));
     }
   open_price=iOpen(_Symbol,time_frame,bar_shift);
   price_high=NormalizeDouble(open_price+(summ/periyd_atr)/2,SYMBOL_DIGITS);
   price_low=NormalizeDouble(open_price-(summ/periyd_atr)/2,SYMBOL_DIGITS);
   if(bar_shift==0)
     {
      time_zon_end=iTime(_Symbol,time_frame,bar_shift)+PeriodSeconds(time_frame);
     }
   else
     {
      time_zon_end=iTime(_Symbol,time_frame,bar_shift-1);
     }
   if(ObjectFind(0,"АТР открытие"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr)==-1 ||
      ObjectFind(0,"АТР верхняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr)==-1 ||
      ObjectFind(0,"АТР нижняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr)==-1)
     {
      // Отрисовка линии открытия дня
      ObjectCreate(0,"АТР открытие"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,OBJ_TREND,0,iTime(_Symbol,time_frame,bar_shift),open_price,time_zon_end,open_price);
      ObjectSetInteger(0,"АТР открытие"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(0,"АТР открытие"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,OBJPROP_COLOR,color_zon);

      // Отрисовка зон
      ObjectCreate(0,"АТР верхняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,OBJ_RECTANGLE,0,iTime(_Symbol,time_frame,bar_shift),price_high,time_zon_end,price_high-(price_high*0.0001));
      ObjectSetInteger(0,"АТР верхняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,OBJPROP_COLOR,color_zon);

      ObjectCreate(0,"АТР нижняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,OBJ_RECTANGLE,0,iTime(_Symbol,time_frame,bar_shift),price_low,time_zon_end,price_low+(price_low*0.0001));
      ObjectSetInteger(0,"АТР нижняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,OBJPROP_COLOR,color_zon);
      ObjectSetText("АТР нижняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr,"  "+NormalizeDouble((summ/periyd_atr)/_Point,0));
     }
   else
     {
      ObjectDelete(0,"АТР открытие"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr);
      ObjectDelete(0,"АТР верхняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr);
      ObjectDelete(0,"АТР нижняя зона"+" "+name+" "+TimeToString(iTime(_Symbol,time_frame,bar_shift))+" "+periyd_atr);
     }

  }

//+------------------------------------------------------------------+
