
#include <OneWire.h>

OneWire  ds(13);  // 连接arduino10引脚
int f;
int x;               //小数点位置
int x1;
int x2;
int x3;
int x4;
int de;
float val;
float celsius;       //温度
//设置阴极接口
int d1 = A3;
int d2 = 2;
int d3 = 3;
int d4 = 4;
int d5 = 5;
int d6 = 6;
int d7 = 7;
int d8 = 8;
//设置阳极接口
int a = 9;
int b = 10;
int c = 11;
int d = 12;

byte gyang[4] = { a, b, c, d };
byte gyin[8] = { d1, d2, d3, d4, d5, d6, d7, d8 };
 
byte gong_yin[12][8] = {                      //数组名[行][位]
                          { 1,1,1,1,1,1,0,0 },  // 0
                          { 0,1,1,0,0,0,0,0 },  // 1
                          { 1,1,0,1,1,0,1,0 },  // 2
                          { 1,1,1,1,0,0,1,0 },  // 3
                          { 0,1,1,0,0,1,1,0 },  // 4
                          { 1,0,1,1,0,1,1,0 },  // 5
                          { 1,0,1,1,1,1,1,0 },  // 6
                          { 1,1,1,0,0,0,0,0 },  // 7
                          { 1,1,1,1,1,1,1,0 },  // 8
                          { 1,1,1,1,0,1,1,0 },  // 9
                          { 0,0,0,0,0,0,1,0 },  // 10-负号
                          { 0,0,0,0,0,0,0,1 },  // 11-负号
                        }; 
                        
byte gong_yang[4][4] = {                //数组名[行][位]
                          { 0,1,1,1 },  // 0-右1位
                          { 1,0,1,1 },  // 1-右2位
                          { 1,1,0,1 },  // 2-右3位
                          { 1,1,1,0 },  // 3-右4位
                        }; 
void setup(void)
{
Serial.begin(9600);
pinMode(d1, OUTPUT);
pinMode(d2, OUTPUT);
pinMode(d3, OUTPUT);

pinMode(d4, OUTPUT);
pinMode(d5, OUTPUT);
pinMode(d6, OUTPUT);
pinMode(d7, OUTPUT);
pinMode(d8, OUTPUT);
pinMode(a, OUTPUT);
pinMode(b, OUTPUT);
pinMode(c, OUTPUT);
pinMode(d, OUTPUT);
digitalWrite(a,HIGH);
digitalWrite(b,HIGH);
digitalWrite(c,HIGH);
digitalWrite(d,HIGH);
}

void loop(void)
{
  
  byte i;
  byte present = 0;
  byte type_s;
  byte data[12];
  byte addr[8];
  float celsius, fahrenheit;
   
  if ( !ds.search(addr)) {
    Serial.println("No more addresses.");
    Serial.println();
    ds.reset_search();
    delay(1);
    return;
  }
   
  Serial.print("ROM =");
  for( i = 0; i < 8; i++) {
    Serial.write(' ');
    Serial.print(addr[i], HEX);
  }
 
  if (OneWire::crc8(addr, 7) != addr[7]) {
      Serial.println("CRC is not valid!");
      return;
  }
  Serial.println();
  
  // the first ROM byte indicates which chip
  switch (addr[0]) {
    case 0x10:
      Serial.println("  Chip = DS18S20");  // or old DS1820
      type_s = 1;
      break;
    case 0x28:
      Serial.println("  Chip = DS18B20");
      type_s = 0;
      
      break;
    case 0x22:
      Serial.println("  Chip = DS1822");
      type_s = 0;
      break;
    default:
      Serial.println("Device is not a DS18x20 family device.");
      return;
  } 
 
  ds.reset();
  ds.select(addr);
  ds.write(0x44,1);         // start conversion, with parasite power on at the end
  delay(1);                 // maybe 750ms is enough, maybe not
  // we might do a ds.depower() here, but the reset will take care of it.
   
  present = ds.reset();
  ds.select(addr);    
  ds.write(0xBE);         // Read Scratchpad
 
  Serial.print("  Data = ");
  Serial.print(present,HEX);
  Serial.print(" ");
  for ( i = 0; i < 9; i++) {           // we need 9 bytes
    data[i] = ds.read();
    Serial.print(data[i], HEX);
    Serial.print(" ");
  }
  Serial.print(" CRC=");
  Serial.print(OneWire::crc8(data, 8), HEX);
  Serial.println();
 
  // convert the data to actual temperature
 
  unsigned int raw = (data[1] << 8) | data[0];
  if (type_s) {
    raw = raw << 3;              // 9 bit resolution default
    if (data[7] == 0x10) {       // count remain gives full 12 bit resolution
      raw = (raw & 0xFFF0) + 12 - data[6];
    }
  } else {
    byte cfg = (data[4] & 0x60);
    if (cfg == 0x00) raw = raw << 3;  // 9 bit resolution, 93.75 ms
    else if (cfg == 0x20) raw = raw << 2; // 10 bit res, 187.5 ms
    else if (cfg == 0x40) raw = raw << 1; // 11 bit res, 375 ms
    // default is 12 bit resolution, 750 ms conversion time
  }
  celsius = (float)raw / 16.0;
  fahrenheit = celsius * 1.8 + 32.0;
  Serial.print("  Temperature = ");
  Serial.print(celsius);
  Serial.print(" Celsius, ");   
  Serial.print(fahrenheit);
  Serial.println(" Fahrenheit");
  
  
//************************************************************上面是传感器部分
de=2;
if(celsius==85.00)
{val=val;}
else
{val=celsius;
//检测当前要显示的数字
if(val<0)
{
f=0;
val*=(val,-10);
}
else{
f=1;
val*=(val,100);
}
if(f==1)
{x4=int(val/1000);
 x3=int(val/100)-x4*10;
 x2=int(val/10)-x4*100-x3*10;
 x1=int(val)-x4*1000-x3*100-x2*10;
 x=2;
 }
else
{x4=10;
 x3=int(val/100);
 x2=int(val/10)-x3*10;
 x1=int(val)-x3*100-x2*10;
 x=1;
}

for (int w = 0; w < 1000; w++)

{
  GongYin(x1);
  GongYang(0);
  delay(de);
  GongYin(x2);
  GongYang(1);
  delay(de);
  GongYin(x3);
  GongYang(2);
  delay(de);
  GongYin(x4);
  GongYang(3);
  delay(de);
  GongYin(11);
  GongYang(x);
  delay(de);
}
}
}
void GongYang(int x)
{
  for (int i = 0; i < 4; i++)           //4为数组'gong_yang'的位数,不同会出错
  {
    digitalWrite(gyang[i], gong_yang[x][i]);
  }
}

void GongYin(int y)
{
  for (int i = 0; i < 8; i++)           //8为数组'gong_yin'的位数,不同会出错
  {
    digitalWrite(gyin[i], gong_yin[y][i]);
  }
}
