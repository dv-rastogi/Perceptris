 #define outputA 2
#define outputB 3

int trigPinU = 15;    
int echoPinU = 16;   
int trigPinR = 7;
int echoPinR = 8;
int trigPinL = 26;
int echoPinL = 28;

int ledleftinput=48;
int ledrotateinput=52;
int ledrightinput=50;

int ledleft=43;
int ledrotate=41;

int ledright=39;

int buzzer=53;

int movecheck=0;


int counter = 0; 
int level;
int aState;
int aLastState;  
int var;
int prelevel;

int touch=11;
int signalrec=12;

int n=200;
long durationU, cmU, inchesU, durationL, cmL, inchesL, durationR, cmR, inchesR;
 
void setup() {
  
  //Serial Port begin
  Serial.begin (9600);
  //Define inputs and outputs
  pinMode(trigPinU, OUTPUT);
  pinMode(echoPinU, INPUT);
  pinMode(trigPinL, OUTPUT);
  pinMode(echoPinL, INPUT);
  pinMode(trigPinR, OUTPUT);
  pinMode(echoPinR, INPUT);

  pinMode(ledleftinput, INPUT);
  pinMode(ledrotateinput, INPUT);
  pinMode(ledrightinput, INPUT);

  pinMode(ledleft, OUTPUT);
  pinMode(ledrotate, OUTPUT);
  pinMode(ledright, OUTPUT);

  pinMode(buzzer,OUTPUT);

  pinMode (outputA,INPUT);
  pinMode (outputB,INPUT);
  aLastState = digitalRead(outputA); 
  
  pinMode (touch,INPUT);
  
  pinMode (signalrec,OUTPUT);
}
 
void loop() {
  
  aState = digitalRead(outputA); // Reads the "current" state of the outputA
   // If the previous and the current state of the outputA are different, that means a Pulse has occured
   if (aState != aLastState){     
     // If the outputB state is different to the outputA state, that means the encoder is rotating clockwise
     if (digitalRead(outputB) != aState) { 
       counter ++;
     } else {
       counter --;
     }
     if(counter<0)
      counter=counter+30;
      var=counter%5;
     if((0<=var)&&(var<=1))
      level=3;
     else if((1<var)&&(var<=3))
      level=2;
     else 
      level=1;

      //Serial.println(var);
      if(level!=prelevel)
      {
        if(level==1)
        Serial.println("O");
        if(level==2)
        Serial.println("Tw");
        if(level==3)
        Serial.println("Thr");
        delay(n); 
      }
      } 
   aLastState = aState; // Updates the previous state of the outputA with the current state
   prelevel=level;
  
  if(digitalRead(touch)==HIGH)
  {
  Serial.println("CapTouch");
  digitalWrite(signalrec,HIGH); 
  delay(n); 
  }
  
  
  // The sensor is triggered by a HIGH pulse of 10 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
 
  digitalWrite(trigPinU, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPinU, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPinU, LOW);
 
  // Read the signal from the sensor: a HIGH pulse whose
  // duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(echoPinU, INPUT);
  durationU = pulseIn(echoPinU, HIGH);
 
  // Convert the time into a distance
  cmU = (durationU/2) / 29.1;     // Divide by 29.1 or multiply by 0.0343
  inchesU = (durationU/2) / 74;   // Divide by 74 or multiply by 0.0135
  
  if(inchesU<=5)
  {
    if((movecheck==1)||(movecheck==3))
    digitalWrite(buzzer,HIGH);
    else 
    {
     Serial.println("ROTATE");  
     digitalWrite(signalrec,HIGH); 
    }
    delay(n); 
  }
  
  digitalWrite(trigPinL, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPinL, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPinL, LOW);

  pinMode(echoPinL, INPUT);
  durationL= pulseIn(echoPinL, HIGH);

  cmL= (durationL/2) / 29.1;
  inchesL= (durationL/2) / 74;
   
  if(inchesL<=3)
  {
    if((movecheck==3)||(movecheck==2))
    digitalWrite(buzzer,HIGH);
    else 
    {
      Serial.println("LEFT");
      digitalWrite(signalrec,HIGH);
    }
    delay(n); 
  }

  digitalWrite(trigPinR, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPinR, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPinR, LOW);

  pinMode(echoPinR, INPUT);
  durationR= pulseIn(echoPinR, HIGH);

  cmR= (durationR/2) / 29.1;
  inchesR= (durationR/2) / 74;
   
  if(inchesR<=3)
  {
    if((movecheck==1)||(movecheck==2))
    digitalWrite(buzzer,HIGH);
    else 
    {
      Serial.println("RIGHT"); 
      digitalWrite(signalrec,HIGH);
    }
    delay(n); 
  }

  //left
  if(digitalRead(ledleftinput)==HIGH)
  {
    movecheck=1; //left
    digitalWrite(ledleft, LOW);
    delay(n); 
  //  delay(200);
   
  }

  //rotate
  if(digitalRead(ledrotateinput)==HIGH)
  {
     movecheck=2; //rotate    
     digitalWrite(ledrotate, LOW);
     delay(n); 
   //  delay(200);  
     
  }

  //right
  
  if(digitalRead(ledrightinput)==HIGH)
  {
    movecheck=3; //right
    digitalWrite(ledright, LOW);
    delay(n); 
   // delay(200);
    
  }
  
digitalWrite(ledleft, HIGH);
digitalWrite(ledrotate, HIGH);
digitalWrite(ledright, HIGH);
digitalWrite(buzzer,LOW);
digitalWrite(signalrec,LOW);
}
