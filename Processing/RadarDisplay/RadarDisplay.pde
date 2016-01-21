
// Stable Version

import processing.serial.*;
Serial Radar;
boolean firstContact = false;
boolean RadarOn = false;
boolean ScanStart = false;

boolean debugging = true;

boolean GlobalClick = true;

float AngleMin = 22.5;
float AngleMax = 157.5;
int RangeMax = 5000;
int Deadzone = 300;
int ScaleFactor = 50;

int posisionCurrent = round(AngleMin);
boolean scanDirection = true;
boolean fastScan = false;
int validRange = 0;

int[] serialInArray = new int[5];   
int serialCount = 0;                 

int[] currentValues = new int[136];

void setup () {
  size (1000,600);
  frameRate(15); 
  
  //println(Serial.list());
  String portName = Serial.list()[0];
  Radar = new Serial(this, portName, 19200);
  
}

void draw () {
  background (0,0,0);
  textFont(createFont("Helvetica", 24));
  
  RadarControl ();
  DirectionControl ();
  SpeednControl ();

  // draw the range arcs
  for (int i = 0; i <= (RangeMax/(ScaleFactor*10)) ; i++){
    noFill();
    strokeWeight(1);
    stroke(0,128,0);
    arc(width/2, height, i*(RangeMax/ScaleFactor),  i*(RangeMax/ScaleFactor) , radians(AngleMin) + PI, radians(AngleMax)+PI);
  }
  
  // draw grid in the arcs
  for (int i = 1; i <= 7 ; i++){
    strokeWeight(1);
    stroke(0,128,0);
    line(width/2, height, (width/2) + cos(radians(AngleMin*i) + PI)*(RangeMax/(ScaleFactor/5)), height + sin(radians(AngleMin*i) + PI)*(RangeMax/(ScaleFactor/5)));
  }
  
  // draw the deadzone arc
  fill (0,64,0);
  strokeWeight(1);
  stroke(0,128,0);
  arc(width/2, height, (Deadzone/(ScaleFactor/10)) ,  (Deadzone/(ScaleFactor/10))   , radians(AngleMin) + PI, radians(AngleMax)+PI);
  
  // draw the current position line
  strokeWeight(1);
  noFill();
  stroke(255);
  line(width/2, height, (width/2) + cos(radians(posisionCurrent-.5) + PI)*(RangeMax/(ScaleFactor/5)), height + sin(radians(posisionCurrent-.5) + PI)*(RangeMax/(ScaleFactor/5)));
  
  //display sensor values on the radar screen and putting 
  stroke (255);
  strokeWeight(4);
  arc(width/2, height, (currentValues [posisionCurrent-round(AngleMin)]/(ScaleFactor/10)) ,  (currentValues [posisionCurrent-round(AngleMin)]/(ScaleFactor/10))   , radians(posisionCurrent-.5-.5) + PI, radians(posisionCurrent-.5+.5)+PI);

   // draw all current values
  for (int i = 0; (round(AngleMax)-round(AngleMin)) >= i ; i++) {
    if ( currentValues [i] >= 300) {
      arc(width/2, height, (currentValues [i]/(ScaleFactor/10)) ,  (currentValues [i]/(ScaleFactor/10))   , radians((i+23)-.5-.5) + PI, radians((i+23)-.5+.5)+PI);
    }
  }
  
  
  
  
  if (ScanStart == false && RadarOn == true) {
    if (debugging) {
      print ("ScanStart is false, requesting new position of ");
    }
    if ( posisionCurrent > round(AngleMin) && posisionCurrent < round(AngleMax) && scanDirection == false) {
      posisionCurrent++;
    } else if ( posisionCurrent == round(AngleMax) && scanDirection == false) {
      posisionCurrent--;
      scanDirection = true;
    } else if ( posisionCurrent > round(AngleMin) && posisionCurrent < round(AngleMax) && scanDirection == true) {
      posisionCurrent--;
    } else if ( posisionCurrent == round(AngleMin) && scanDirection == true) {
      posisionCurrent++;
      scanDirection = false;
    }
    if (fastScan) {
      Radar.write("f");
    } else {
      Radar.write("p");
    }
    Radar.write(nf(posisionCurrent,3));       // request first position
    ScanStart = true;
    if (debugging) {
      println (nf(posisionCurrent,3));
    }
  }



} // END DRAW


void SpeednControl () {
  int w = 50;
  int h = 30;
  int x = (width-w-10-100);
  int y = 10;
  int fontSize = 13;
  textAlign(CENTER);
  textSize(fontSize);
  stroke(0);
  if (fastScan) {
    fill(255,255,0);
    rect(x,y,w,h);
    fill(0);
    text("FAST", x+(w/2), y+(h/2)+(fontSize/2)-1);
  } else {
    fill(100,149,237);
    rect(x,y,w,h);
    fill(0);
    text("slow", x+(w/2), y+(h/2)+(fontSize/2)-1);
  }
  if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h && mousePressed && GlobalClick) {
    fastScan = !fastScan;
    GlobalClick = false;
  }
}


void DirectionControl () {
  int w = 30;
  int h = 30;
  int x = (width-w-10-65);
  int y = 10;
  int fontSize = 13;
  textAlign(CENTER);
  textSize(fontSize);
  stroke(0);
  if (scanDirection) {
    fill(100,149,237);
    rect(x,y,w,h);
    fill(0);
    text("DN", x+(w/2), y+(h/2)+(fontSize/2)-1);

  } else {
    fill(255,255,0);
    rect(x,y,w,h);
    fill(0);
    text("UP", x+(w/2), y+(h/2)+(fontSize/2)-1);
  }
  if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h && mousePressed && GlobalClick) {
    scanDirection = !scanDirection;
    GlobalClick = false;
  }
}



void RadarControl () {
  int w = 60;
  int h = 30;
  int x = (width-w-10);
  int y = 10;
  int fontSize = 14;
  stroke(0);
  if (RadarOn) {
    fill(0,255,0);
  } else {
    fill(255,0,0);
  }
  rect(x,y,w,h);
  textAlign(CENTER);
  textSize(fontSize);
  fill(0);
  text("Radar", x+(w/2), y+(h/2)+(fontSize/2)-1);
  if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h && mousePressed && GlobalClick) {
    RadarOn = !RadarOn;
    GlobalClick = false;
  }
}
  





void serialEvent(Serial Radar) {
  int arrayIndex = posisionCurrent-round(AngleMin);
  
  if (firstContact == false) {
    if (Radar.read() == '5') {     
      if (debugging) {
        println ("We have a valid connection with V4 of the Radar");
      }
      firstContact = true;
    } else{
      Radar.clear();
    } 
  }
  
  int inByte = Radar.read();
  if (debugging) {
    print ("recieved byte ");
    println (inByte);
  }

  if (ScanStart == true && firstContact == true) {  // we parse the data recieved from the radar
  
    if (serialCount == 0) {
      if (inByte == 82) {
        serialInArray[serialCount] = inByte;
        serialCount++;
        if (debugging) {
          print ("just recorded a starting R as ");
          print (inByte);
          print (" in index ");
          println (serialCount);
        }
      } else{
        Radar.clear();
      }
    } else {
      serialInArray[serialCount] = inByte;
          if (debugging) {
          print ("just recorded ");
          print (inByte);
          print (" in index ");
          println (serialCount);
        }
      serialCount++;
    }
  
    // If 5 bytes are recorded, we might have a valid position from the radar, lets see.....
    if (serialCount > 4 ) {
      if (debugging) {
        print ("we have 5 bytes....");
      }
      if (serialInArray[0] == 82) {
        if (debugging) {
          println ("and a valid range!");
        }
        // convert ascii to digits and construct an int that contains the valid range
        int multiple = 1000;
        for (int i = 1 ; i < 5 ; i++ ) {
          validRange = validRange + (serialInArray[i] - 48 ) * multiple;  // the -48 converts ascii to numbers
          multiple = multiple/10;
        }
        if (debugging) {
          print ("current valid range is ");
          println (validRange);
        }
        
        currentValues[arrayIndex]= validRange;
        
        serialCount = 0;
        validRange = 0;
        ScanStart = false;
      }
      else {
        if (debugging) {
          println ("but the range is invalid.  BUMMER!");
        }
        validRange = 0;
        ScanStart = false;
        serialCount = 0;
      }
    }
  }
 
} // END Serial Event



void mouseReleased() {
  GlobalClick = true;
}

