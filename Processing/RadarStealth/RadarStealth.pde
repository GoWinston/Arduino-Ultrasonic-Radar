
// Stable Version

import processing.serial.*;
Serial Radar;
boolean firstContact = false;
boolean RadarOn = false;
boolean ScanStart = false;
int[] serialInArray = new int[5];   
int serialCount = 0; 
int validRange = 0;
boolean newscan = false;  // ******************

boolean debugging = true;

int RangeMax = 5000;
int RangeMin = 300;
int CurrentRange = 4991;

boolean GlobalClick = true;

boolean GameStart = false;
int TimeStart = 0;
int TimeEnd = 0;
int GomeScore = round(map(CurrentRange, RangeMin,RangeMax, 100, 0));
int strikes = 0;
int strikeRange [] = {0,0,0,0};

int dificulty = 0;




void setup () {
  size (640,360);
  background(128);
  //println(Serial.list());
  String portName = Serial.list()[0];
  Radar = new Serial(this, portName, 19200);
  textFont(createFont("Helvetica", 14)); 
  
}

void draw () {
  background(200);
  fill (0);
  textSize (72);
  textAlign(CENTER);
  text("Stealth Game", (width/2)-50, 80);
  
  GameControl ();
  if (!GameStart) {
    SetMaxRange ();
    SetDificulty ();
  }
  gradientDisplay(50, 200, 540, 80, CurrentRange); 
  
  if (GameStart == false) {
    //textSize(12); 
    textAlign(LEFT);
    text("Seconds: ", 10, height-10);
    text(((TimeEnd - TimeStart)/1000), 70, height-10);
    
    textSize(72); 
    textAlign(LEFT);
    text("Score:", 125, (height/2)-15);
    text(GomeScore, 360, (height/2)-15);
    
    
   
  } else {
    //textSize(12); 
    textAlign(LEFT);
    text("Seconds: ", 10, height-10);
    text(((millis() - TimeStart)/1000), 70, height-10);
    
    textSize(72); 
    textAlign(LEFT);
    text("Strike:", 60, (height/2)-15);
    
    if (strikes <= 0) {
     fill (160,0,0);
    } else{
     fill (255,0,0);
    }
    ellipse(320, (height/2)-40, 60, 60);
    
    if (strikes <= 1) {
      fill (160,0,0);
    } else{
     fill (255,0,0);
    }
    ellipse(390, (height/2)-40, 60, 60);
    
    if (strikes <= 2) {
      fill (160,0,0);
    } else{
     fill (255,0,0);
    }
    ellipse(460, (height/2)-40, 60, 60);
    
    
  }



  if (ScanStart == false && RadarOn == true) {
    if (debugging) {
      print ("ScanStart is false, requesting new scan ");
    }
    Radar.write("p090");
    ScanStart = true;
    if (debugging) {
      println (nf(90,3));
    }
  }



} // END DRAW

void SetDificulty () {
  int w = 100;
  int h = 40;
  int x = (width-w-10);
  int y = 140;
  int fontSize = 14;
  //stroke(0); 
  switch (dificulty) {
    case 0:
    fill(0,255,255);
    rect(x,y,w,h);
    textAlign(CENTER);
    textSize(fontSize);
    fill(0);
    text("Easy", x+(w/2), y+(h/2)+(fontSize/2)-1);
    break;
    case 1:
    fill(255,255,0);
    rect(x,y,w,h);
    textAlign(CENTER);
    textSize(fontSize);
    fill(0);
    text("Medium", x+(w/2), y+(h/2)+(fontSize/2)-1);
    break;
    case 2:
    fill(255,0,0);
    rect(x,y,w,h);
    textAlign(CENTER);
    textSize(fontSize);
    fill(0);
    text("Hard", x+(w/2), y+(h/2)+(fontSize/2)-1);
    break;
  }
  
  if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h && mousePressed && GlobalClick) {
    if (!GameStart) {
      dificulty++;
      if (dificulty >=3) {
        dificulty=0;
      }
    }
    GlobalClick = false;
  }
}


void SetMaxRange () {
  int w = 100;
  int h = 40;
  int x = (width-w-10);
  int y = 100;
  int fontSize = 14;
  stroke(0);
  fill(128,150,235);
  rect(x,y,w,h);
  if (RangeMax >= 5000) {
    textAlign(CENTER);
    textSize(fontSize);
    fill(0);
    text("Set New Max", x+(w/2), y+(h/2)+(fontSize/2)-1);
  } else {
    textAlign(CENTER);
    textSize(fontSize);
    fill(0);
    text("Reset Max", x+(w/2), y+(h/2)+(fontSize/2)-1);
  }
  if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h && mousePressed && GlobalClick) {
    if (!GameStart) {
      if (RangeMax >= 5000) {
        RangeMax = CurrentRange;
        Radar.write("p090");
        ScanStart = true;
      } else {
        RangeMax = 5000;
      }
    }
    GlobalClick = false;
  }
}

void gradientDisplay(int x, int y, float w, float h, int dist) {
  color c1 = color(0, 255, 0);
  color c2 = color(255, 0, 0);
  float mapScore = map(dist, RangeMin,RangeMax, x, x+w);
  
  noFill();
  for (int i = x; i <= x+w; i++) {
  //for (int i = x; i <= mapScore; i++) {
    float inter = map(i, x, x+w, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(i, y, i, y+h);
  }
    
  stroke (0);
  noFill();
  rect ( x, y, w, h);
  
  int LineWidth = 2;
  
  // SHOWS STRIKE READINGS
  for (int i = 0; i < 3; i++) {
    if ( strikeRange[i] >= RangeMin ) {
      stroke (255,255,0);
      fill (255,255,0);
      float strikePlot = map(strikeRange[i], RangeMin,RangeMax, x, x+w);
      rect( strikePlot , y , LineWidth*2 , h );
    }
  }
    
  // SHOWS CURRENT READING
  fill (0);
  stroke (0);
  rect( mapScore , y , LineWidth , h );
  

  
  textAlign (LEFT);
  text (RangeMin, x , y+h+13 );
  textAlign (CENTER);
  text ("Range In Millimeters", x+(w/2) , y+h+13 );
  textAlign (RIGHT);
  text (RangeMax, x+w , y+h+13 );
}

void GameControl () {
  int w = 100;
  int h = 90;
  int x = (width-w-10);
  int y = 10;
  int fontSize = 13;
  textAlign(CENTER);
  textSize(fontSize);
  stroke(0);
  if (GameStart) {
    fill(255,0,0);
    rect(x,y,w,h);
    fill(0);
    text("STOP", x+(w/2), y+(h/2)+(fontSize/2)-1);
    
    if (CurrentRange < RangeMax - 10 && newscan ) { 
      strikes++;
      strikeRange [strikes] = CurrentRange;
      newscan = false;
    }
    if (strikes >= 3) {
      GameStart = !GameStart;
      RadarOn = !RadarOn;
      TimeEnd = millis();
      GomeScore = round(map(CurrentRange, RangeMin,RangeMax, 100, 0));
      strikes = 0;
    }
      
  } else {
    fill(0,255,0);
    rect(x,y,w,h);
    fill(0);
    text("START", x+(w/2), y+(h/2)+(fontSize/2)-1);
  }
  if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h && mousePressed && GlobalClick) {
    if (GameStart) {
      TimeEnd = millis();
    } else {
      TimeStart = millis();
      strikes = dificulty;
      CurrentRange = RangeMax;
      strikeRange [0] = 0;
      strikeRange [1] = 0;
      strikeRange [2] = 0;
    }
    GameStart = !GameStart;
    RadarOn = !RadarOn;
    GlobalClick = false;
  }
}





void serialEvent(Serial Radar) {
  if (firstContact == false) {
    if (Radar.read() == '5') {     
      if (debugging) {
        println ("We have a valid connection with V5 of the Radar");
      }
      firstContact = true;
      Radar.write("p090");
      ScanStart = true;
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
        
        CurrentRange = validRange;
        newscan = true; 
        
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

