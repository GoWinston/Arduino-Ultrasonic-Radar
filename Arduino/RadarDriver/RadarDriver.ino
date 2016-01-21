/*

ADDING FAST SCANNING!!

*/
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#include <SoftwareSerial.h>
SoftwareSerial rangeSerial(2, 3);

uint16_t SERVOMIN = 206;
uint16_t SERVOMAX = 580;

uint16_t ANGLEMIN = 23;
uint16_t ANGLEMAX = 158;

uint16_t ServoPosition = SERVOMIN; 
uint8_t SlewSpeed = 1;

static byte RangePin = 13;
static byte ServoPowerPin = 12;
static byte PulsePin = 1;

boolean static debugging = false;

void setup() {
  Serial.begin(19200);
  rangeSerial.begin (9600);
  
  pinMode(ServoPowerPin, OUTPUT);
  digitalWrite(ServoPowerPin, HIGH);
  
  pinMode(RangePin, OUTPUT);
  digitalWrite(RangePin, LOW); 
  
  pwm.begin();
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
  
  Serial.println("5");
  
  moveRadar (map (90,ANGLEMIN,ANGLEMAX,SERVOMIN,SERVOMAX));
  
}

void loop() {
  
 if (Serial.available() > 0) {
   switch (Serial.read ()) {
     /* START Calibration Functions
     case 49 : // 1
     moveRadar (SERVOMIN);
     Serial.print("Servo set to MIN position of ");
     Serial.println(SERVOMIN);
     break;
     case 50 :  // 2
     SERVOMIN --;
     moveRadar (SERVOMIN);
     Serial.print("Servo MIN Reduced to: ");
     Serial.println(SERVOMIN);
     break;
     case 51: // 3
     SERVOMIN ++;
     moveRadar (SERVOMIN);
     Serial.print("Servo MIN Increased to: ");
     Serial.println(SERVOMIN);
     break;
     case 52 :  // 4
     moveRadar (SERVOMAX);
     Serial.print("Servo set to MAX position of ");
     Serial.println(SERVOMAX);
     break;
     case 53 :  // 5
     SERVOMAX --;
     moveRadar (SERVOMAX);
     Serial.print("Servo MAX Reduced to: ");
     Serial.println(SERVOMAX);
     break;
     case 54: // 6
     SERVOMAX ++;
     moveRadar (SERVOMAX);
     Serial.print("Servo MAX Increased to: ");
     Serial.println(SERVOMAX);
     break;
     case 55: // 7
     moveRadar (map (90,ANGLEMIN,ANGLEMAX,SERVOMIN,SERVOMAX));
     Serial.println("This is center");
     break;
     END Calibration Functions */
     
     
     
     case 112: // p followed by three numbers for position
     {
     if (debugging) {
       Serial.print("Enter position to move to now ");
     }
     while ( Serial.available() < 3) {
       delay (5);
     } 
     int pos = ((Serial.read()-48)*100);
     pos = pos + ((Serial.read()-48)*10);
     pos = pos + ((Serial.read()-48));
     if (debugging) {
       Serial.print(pos);
       Serial.println(" will be input into goMeasure");
     }
     int rangeOut= goMeasure (pos);
     if (rangeOut == -1) {
       break;
     }
     Serial.print("R");
     if (rangeOut < 1000) {
       Serial.print ("0");
     }     
     Serial.println(rangeOut);
     }
     break;
     
     case 102: // f followed by three numbers for position ** FAST MODE **
     {
     if (debugging) {
       Serial.print("Enter FAST MODE position to move to now ");
     }
     while ( Serial.available() < 3) {
       delay (5);
     } 
     int pos = ((Serial.read()-48)*100);
     pos = pos + ((Serial.read()-48)*10);
     pos = pos + ((Serial.read()-48));
     if (debugging) {
       Serial.print(pos);
       Serial.println(" will be input into goMeasureFAST");
     }
     int rangeOut= goMeasureFAST (pos);
     if (rangeOut == -1) {
       break;
     }
     Serial.print("R");
     if (rangeOut < 1000) {
       Serial.print ("0");
     }     
     Serial.println(rangeOut);
     }
     break;
     
     
     
   } // END switch
 } // END if Serial Avail
} // END LOOP

int goMeasureFAST (int pos) {
  int range = 0;
  
  if (pos >= ANGLEMIN && pos <= ANGLEMAX) {
    if (debugging) {
      Serial.print("FastScan Moving to position ");
      Serial.println(pos);
    }
    moveRadar (map (pos,ANGLEMIN,ANGLEMAX,SERVOMIN,SERVOMAX));
    delay (30); // let the sensor become stable
  }
  else {
    Serial.println("E");
    range = -1;
    return range;
  }

  int readings[5] = {0,0,0,0,0};
  
    digitalWrite(RangePin, HIGH); 
    delay (30);
    digitalWrite(RangePin, LOW);
    delay (30);
    while (rangeSerial.available() < 1) {
      delay (10);
    }
    while (rangeSerial.peek() != 82 ) {
      rangeSerial.read();
    }
    if (rangeSerial.read() == 82) { // this is ascii R and a dirty ascii to dec conversion
      range = 0;
      range = range + ((rangeSerial.read()-48)*1000);
      range = range + ((rangeSerial.read()-48)*100);
      range = range + ((rangeSerial.read()-48)*10);
      range = range + (rangeSerial.read()-48);
      
      if (rangeSerial.read() == 13) {
        if (debugging) {
          Serial.print("Range: ");
          Serial.println(range);
        }
        return range; //*********
      }
      else {
        Serial.println("E");
      }
    }
    delay (70);
}



int goMeasure (int pos) {
  int range = 0;
  
  if (pos >= ANGLEMIN && pos <= ANGLEMAX) {
    if (debugging) {
      Serial.print("Moving to position ");
      Serial.println(pos);
    }
    moveRadar (map (pos,ANGLEMIN,ANGLEMAX,SERVOMIN,SERVOMAX));
    delay (30); // let the sensor become stable
  }
  else {
    Serial.println("E");
    range = -1;
    return range;
  }

  int readings[5] = {0,0,0,0,0};
  
  for (int a = 0 ; a < 5 ; a++) {
    digitalWrite(RangePin, HIGH); 
    delay (30);
    digitalWrite(RangePin, LOW);
    delay (30);
    while (rangeSerial.available() < 1) {
      delay (10);
    }
    while (rangeSerial.peek() != 82 ) {
      rangeSerial.read();
    }
    if (rangeSerial.read() == 82) { // this is ascii R and a dirty ascii to dec conversion
      range = 0;
      range = range + ((rangeSerial.read()-48)*1000);
      range = range + ((rangeSerial.read()-48)*100);
      range = range + ((rangeSerial.read()-48)*10);
      range = range + (rangeSerial.read()-48);
      
      if (rangeSerial.read() == 13) {
        if (debugging) {
          Serial.print("Range: ");
          Serial.println(range);
        }
        readings[a] = range;
      }
      else {
        Serial.println("E");
      }
    }
    delay (70);
  }
  
  if (debugging) {
    Serial.print("Values Array is: ");
    for ( int x = 0; x < 5; x++) {
          Serial.print (readings [x]);
          Serial.print(",");
        }
    Serial.println ();
  }
  
  int minValue = 10001;
  int minIndex = 0;
  for( int i = 0 ; i < 5 ; i++) {
    if(readings[i] < minValue) {
      minValue = readings[i];
      minIndex = i;
    }
  }
  if (debugging) {
    Serial.print ("Min: ");
    Serial.print (minValue);
    Serial.print (" at index ");
    Serial.println (minIndex);
  }
  readings[minIndex] = 0;
  
  int maxValue = 0;
  int maxIndex = 0;
  for( int i = 0 ; i < 5 ; i++) {
    if(readings[i] > maxValue) {
      maxValue = readings[i];
      maxIndex = i;
    }
  }
  if (debugging) {
    Serial.print ("Max: ");
    Serial.print (maxValue);
    Serial.print (" at index ");
    Serial.println (maxIndex);
  }
  readings[maxIndex] = 0;
    
  int avgValue = 0;
  for( int i = 0 ; i < 5 ; i++) {
    avgValue = avgValue + readings[i];
  }
  avgValue = avgValue / 3 ;
  if (debugging) {
    Serial.print ("Avg: ");
    Serial.println (avgValue);
  }
  return avgValue;
}

void moveRadar (uint16_t ending) {
  if (debugging) {
    Serial.println("Moving with moveRadar...");
  }
  for ((ServoPosition-ending)>0; ServoPosition > ending; ServoPosition--) {   //move backwards
    pwm.setPWM(0, 0, ServoPosition);       
    delay(SlewSpeed); 
  } 
  for ((ServoPosition-ending)<0; ServoPosition < ending; ServoPosition++) {   //move forwards
    pwm.setPWM(0, 0, ServoPosition); 
    delay(SlewSpeed); 
  }
}
  
  
 
  
  
  
  
  
  
  
