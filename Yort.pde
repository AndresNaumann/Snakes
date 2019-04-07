/////////////////////////////////////////////IMPORT LIBRARYS////////////////////////////////////////////////
import themidibus.*;
import dmxP512.*;
import processing.serial.*;

//////dmx  
DmxP512 dmxOutput;
//////pixelMapping
PixelMapping mapping;
////// The MidiBus
MidiBus myBus; 


//DMX VARIABLES

int universeSize=300; 
boolean DMXPRO=true;
String DMXPRO_PORT="COM6";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115000;

//MIDI VARIABLES

int ccChannel;
int ccNumber;
int ccValue;

Snake snake = new Snake();
int count;
Apple apple = new Apple();
Snake1 snake1 = new Snake1();
Snake2 snake2 = new Snake2();

void setup() {
  //////dmx  
    dmxOutput=new DmxP512(this,universeSize,false);
    dmxOutput.setupDmxPro(DMXPRO_PORT,DMXPRO_BAUDRATE);
  //////pixelMapping
  mapping = new PixelMapping(this);
  mapping.SetData();
  //////midi 
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  //                   Parent In Out
  //                     |    |  |
  myBus = new MidiBus(this,0, 3); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.
   // Map an 8x8 grid of LEDs to the center of the window, scaled to take up most of the space
  mapping.ledGrid(0, 5, 20, width/2, height/2, 100, 100, 3.14/2, false, false);
  
  size(1600,500);
  background(51);
  frameRate(60);
  
}

void draw() {
  
  for(int i = 0; i < width; i += 100) {
    for (int j = 0; j < height; j += 100) {
      fill(0);
      rect(i,j,100,100);
    }
  }
  
  fill(200);
  //snake.display();
  //snake.move();
  apple.display();
  apple.move();
  fill(0,200,0);
  snake.display();
  snake.move();
  snake1.display();
  snake1.move();
  apple.boom();
  
   ////////////////////////////////////////////////  SEND DMX DATA //////////////////////////////////////////
  
  int nbChannel=2;  
  //background(0);
  for(int i=0;i<nbChannel;i++){
    dmxOutput.set(i, mapping.packetData);
  }
}

class Snake {
   float x;
   float y;
   float distance;
 
   Snake() {
   
     x = round(random(0, 24)) * 100;
     y = round(random(0, 14)) * 100;
     
   }
   
   void getDistance() {
     distance = sqrt(pow((apple.x - snake.x), 2) + pow((apple.y - snake.y), 2));
   }
 
   void display() {
     rect(x,y,100,100);
   }
 
   void move() {
     float dy = floor((apple.y - snake.y)/100) * 100;
     float dx = floor((apple.x - snake.x)/100) * 100;
     
     getDistance();
     
     float sin = dy/distance;
     float cos = dx/distance;
     
     float speedX = round(cos) * 100;
     float speedY = round(sin) * 100;
     
     x += speedX;
     y += speedY;
     
   }
}

class Snake1 {
   float x;
   float y;
   float distance;
 
   Snake1() {
   
     x = round(random(0, 24)) * 100;
     y = round(random(0, 14)) * 100;
     
   }
   
   void getDistance() {
     distance = sqrt(pow((apple.x - snake1.x), 2) + pow((apple.y - snake1.y), 2));
   }
 
   void display() {
     fill(50,50,255);
     rect(x,y,100,100);
   }
 
   void move() {
     float dy = floor((apple.y - snake1.y)/100) * 100;
     float dx = floor((apple.x - snake1.x)/100) * 100;
     
     getDistance();
     
     float sin = dy/distance;
     float cos = dx/distance;
     
     float speedX = round(cos) * 100;
     float speedY = round(sin) * 100;
     
     x += speedX;
     y += speedY;
     
   }
}

class Snake2 {
   float x;
   float y;
   float distance;
 
   Snake2() {
   
     x = round(random(0, 24)) * 100;
     y = round(random(0, 14)) * 100;
     
   }
   
   void getDistance() {
     distance = sqrt(pow((apple.x - snake2.x), 2) + pow((apple.y - snake2.y), 2));
   }
 
   void display() {
     fill(230,100,205);
     rect(x,y,100,100);
   }
 
   void move() {
     float dy = floor((apple.y - snake2.y)/100) * 100;
     float dx = floor((apple.x - snake2.x)/100) * 100;
     
     getDistance();
     
     float sin = dy/distance;
     float cos = dx/distance;
     
     float speedX = round(cos) * 100;
     float speedY = round(sin) * 100;
     
     x += speedX;
     y += speedY;
     
   }
}

class Apple {
  float x;
  float y;
  float r;
  float g;
  float b;
  float a;
  float a1;
  boolean dead;
  
  Apple() {
    x = round(random(0,4)) * 100;
    y = round(random(0,4)) * 100;
    r = 255;
    g = 100;
    b = 100;
    a = 255;
    a1 = 255;
    dead = false;

  }
  
  void display() {
    fill(r,g,b,a);
    rect(x,y,100,100);
  }
  
  void move() {
    x = floor(mouseX/100) * 100;
    y = floor(mouseY/100) * 100;
  }
  
  void boom() {
    if (snake.x == apple.x && snake.y == apple.y) {
      snake.x = round(random(0, 24)) * 100;
      snake.y = round(random(0, 4)) * 100;
      a -= 10;
    }
    
    if (snake1.x == apple.x && snake1.y == apple.y) {
      snake1.x = round(random(0, 24)) * 100;
      snake1.y = round(random(0, 14)) * 100;
      a -= 10;
    } 
    if (snake2.x == apple.x && snake2.y == apple.y) {
      snake2.x = round(random(0, 24)) * 100;
      snake2.y = round(random(0, 14)) * 100;
      a -= 10;
    } 
    
    if (a <= 0) {
      a1 = 255;
      a = 255;
      r = random(0,255);
      g = random(0,255);
      b = random(0,255);
      
    } 
  }
}
