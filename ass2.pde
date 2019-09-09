/*
HD Functionality
- keyboard mode: can use arrow keys to control Bill (activated by pressing K)
- bill can jump
- multiplier ball: a ball that random appears every 10 to 15 seconds. Every time it bounces off bill's hat, it's score when placed in the basket is multiplied by 2, for a maximum limit of 32
- game can be paused by pressing P
- after a score of 45 is reached, HD mode can be activated by pressing H
- game can be restarted with a clean score by pressing any key

//it is possible to move the basket around by pressing ALT *BUT* full intended functionality was not implemented and thus will cause the game to break down (please dont count this as an error)

function list
- setup
- draw
- mousePressed - jumping, prompt
- keyPressed - restart, P, H, k, arrows, (TAB, q - functionality not added)

- drawBill - draws normal bill

- drawScenery - draws normal scenery
- gameOver - ends game
- help screen - generic screen for instructions

- drawHDbill - draws HD bill
- jumping - makes bill jump

- modeHD - includes all processes in HD mode
- sun - draws sun in HD mode
- moon - draws moon in HD mode
- back - changes background colour depending on timer
- star - stars appear during the moon phase

- scoreKeep - for keeping the score


Classes list
- Basket - sketch, HDmove
- Pudding - sketch, move, inBasket, resetThing, goAway, change, multiplySketch
- Timer - update, showTime, reset, release, next, time, showOtherTime
*/


Pudding [] gateau = new Pudding[5]; //for pudding array
Basket basket; //creates basket
int score = 0; //to count score
boolean goAwayScore = false; //goAway score when game ends
boolean restart = false; //restarts the game if continue
boolean endpause = false; //ends the pause
boolean keyboard = false; //keyboard mode


boolean triggerHD = false; //activates HD mode
float p; //person throwing puddings starts spreading them out

//jumping mechanism
boolean jump = false; // makes Bill jump
boolean landing = false; //landing for Bill
float jumpheight = 9; //movement per frame of jump
PVector billLocation; //coordinates for bill both hd and normal
boolean dontstop = false; //stops bill from moving while jumping

//timing mechanism variables
boolean start = false; //starts timer
boolean stopTimer = true; //stops timer after condition has been reached

// multiplier ball mechanism
Pudding joker; //pudding object
Timer newMultiplier; //timer for the multiplier pudding
boolean reveal = false; //triggers pudding initialisation
int multiplier = 1; //initial value of the multiplier
color d; //random color for multiplier vscore text
color m; //random colour for mulitplier ball

//prompt mechanism
boolean ask = false; //triggers mouse controls when screen appears
boolean triggerPrompt = false; //triggers the screen after score is > 45

//HD sky mechanism
Timer sunAndMoon; //timer for movement of sun and moon
float a; //controls speed of background change
color c; //background colour

boolean test = true; //test parameters when implementing

void setup(){
  size(640,480);
  background(0);
  frameRate(30);
  for(int i = 0; i < gateau.length; i++){ //initialise pudding
    gateau[i] = new Pudding(15,15,random(1.15,1.2),random(0.2,1.2));
    gateau[i].sketch(); //draws puddings at initial location
  };
  joker = new Pudding(-50,-50,0,0);
  newMultiplier = new Timer((int)random(10,20));
  sunAndMoon = new Timer(5);
  billLocation = new PVector(width/2,height - 80);
  basket = new Basket(width - 65, height - 75);
};

void draw(){
  background(0);
  if(!triggerHD){
    drawScenery();
    basket.sketch();
    drawBill();
    scoreKeep();
    for(int i = 0; i < gateau.length; i++){
      gateau[i].inBasket(0); //check if in basket
      gateau[i].move(0); //moves puddings
      gateau[i].sketch(); //draws pudding
    };
  } else if(triggerHD){
    modeHD();
  }
  else{
  };
};

void keyPressed(){ 
  if(restart){ //restart game
    loop();
    goAwayScore = !goAwayScore;
    for(int i = 0; i < gateau.length; i++){
      gateau[i].resetThing();
    };
  restart = false;
  score = 0;
  triggerHD = false;
  stopTimer = true;
  }
  else{
    if(keyCode == 'P'){ //p pauses and unpause game
      if(endpause){
        loop();
        endpause = !endpause;
      }
      else if(!endpause){
        noLoop();
        fill(0);
        textAlign(CENTER);
        textSize(75);
        text("Game Paused", width/2, height/2);
        endpause = !endpause;
      }
      else{
      }
    }
  }
  //HD stuff
  if(keyCode == 'H'){
    if(score >= 45 && (!triggerHD)){
      helpScreen();
    }
  }
  if(triggerHD){
    if(key == ENTER) {
      if(!dontstop){
        jump = !jump;
        dontstop = !dontstop;
      }
    }
    if(keyCode == 'K'){
      keyboard = !keyboard;
    }
    if(keyboard){
      if(keyCode == UP){
        if(!dontstop){
          jump = !jump;
          dontstop = !dontstop;
        }
      } 
      if(keyCode == LEFT){
        billLocation.x -= 15;
      }
      if(keyCode == RIGHT){
        billLocation.x += 15;
      };
    }
    
    
    if(keyCode == TAB){
      basket.HDmove();
    }
  }
}

void mousePressed(){
  if(triggerHD && !ask){
    jumping();
  }
  if(ask){
    if((width/2 - 225 < mouseX) && (mouseX < width/2 - 25)){
      if((height/2 + 100 < mouseY) && (mouseY < height + 180)) {
        triggerHD = true;
        ask = !ask;
        sunAndMoon.next();
        newMultiplier.reset();
        stopTimer = false;
        for(int i = 0; i < gateau.length; i++){
          gateau[i].resetThing();
        }
        joker.goAway();
        loop();
      }
    }
    if((width/2 + 25 < mouseX) && (mouseX < width/2 + 225)){
      ask = !ask;
      for(int i = 0; i < gateau.length; i ++){
        gateau[i].resetThing();
        triggerHD = false;
      }
      loop();
    };
  }
}

void drawBill(){
  billLocation.x = mouseX;
  if(billLocation.x > width - 180){ //bill does not go into box
    billLocation.x = width - 180;
  };
  strokeWeight(0);
  noStroke();
  fill(204,0,102);
  rectMode(CENTER);
  rect(billLocation.x,height - 60, 45, 50); //body
  rect(billLocation.x, height - 100, 60, 50); //head
  rect(billLocation.x - 10, height - 30, 10, 10); //legs
  rect(billLocation.x + 10, height - 30, 10, 10); //legs
  fill(255,102,255);
  rect(billLocation.x - 15, billLocation.y - 20, 15,25);
  rect(billLocation.x + 15, billLocation.y - 20, 15, 25);
  fill(255,51,255);
  strokeWeight(10);
  stroke(0);
  line(billLocation.x - 50, height - 124, billLocation.x + 50,height - 124); //hat
};

void drawScenery(){
  rectMode(CORNER); //gradiented sky
  int sky = 135;
  for(int i = 0;i < height ; i+= 50){
    noStroke();
    fill(60, 60, sky);
    rect(0,i,width,50);
    sky += 15;
  };
  
  rectMode(CENTER);
  noStroke();
  fill(0,250,145);
  rect(width/2,height - 20, width, 40); //ground
  
  if(score >= 45){
    textSize(25);
    textAlign(CENTER);
    fill(50,255,50);
    text("You have unlocked HD mode!", width/2 - 20, 85);
    text("Press H to activate HD mode!", width /2 - 20, 120);
  }
};

void scoreKeep(){ //displays score
  if(!goAwayScore){
    fill(153,255,153);
    textAlign(RIGHT);
    textSize(30);
    text("$" + score, width - 50,50);
  };
};

void gameOver(){ //ends the game
  for( int i = 0; i < gateau.length; i++){
    gateau[i].goAway();
  };
  joker.goAway();
  goAwayScore = !goAwayScore;
  background(0);
  textSize(100);
  textAlign(CENTER);
  fill(250,50,50);
  text("GAME",width/2,height/2- 50);
  text("OVER",width/2, height/2 + 50);
  textSize(30); 
  fill(200);
  text("Your final score is: " + score,width/2, height/2 + 100);
  text("press any key to restart",width/2, height/2 + 150);
  restart = true;
  noLoop();
};

void helpScreen(){
  ask = !ask;
  rectMode(CENTER);
  fill(200,200,200,100);
  stroke(0);
  strokeWeight(15);
  rect(width/2, height/2 , width, height);
  fill(220,220,220,250);
  strokeWeight(2);
  rect(width/2,height/2,500,400,6); 
  fill(200);
  rect(width/2 - 125,height/2 + 140, 200,80);
  rect(width/2 + 125, height/2 + 140, 200, 80);
  fill(50,250,50);
  textSize(70);
  textAlign(CENTER);
  text("Y",width/2 - 125, height/2 + 170);
  fill(50,50,250);
  text("N", width/2 + 125, height/2 + 170);
  textSize(40);
  fill(0);
  text("Welcome to HD mode!",width/2,height - 380);
  textSize(35);
  text("Featuring: ",width/2, height - 340);
  textSize(30);
  fill(255,255,0);
  text("Jumping - Press Mouse To Jump",width/2 ,height - 300);
  fill(218,112,214);
  text("Keyboard - Use Arrow Keys",width/2, height - 260);
  fill(255,153,51);
  text("Multiplier Ball - A Ball That \n Multiplies Your Score", width/2, height - 215);
  noLoop();
}

void modeHD (){
  back();
  sunAndMoon.time();
  basket.sketch();
  if(keyboard){
    fill(255);
    textSize(20);
    textAlign(CENTER);
    text("Mode: Keyboard", width/2, height - 15);
  } else if(!keyboard){
    fill(255);
    textSize(25);
    textAlign(CENTER);
    text("Mode: Mouse",width/2,height - 15);
  }
  drawHDbill();
  if(!stopTimer){
    newMultiplier.update();
    newMultiplier.showTime();
  }
  if(reveal){
    joker.multiplySketch();
    joker.move(1);
    joker.inBasket(1);
  }
  for(int i = 0; i < gateau.length; i++){
    gateau[i].sketch();
    gateau[i].move(0);
    gateau[i].inBasket(0);
  }
  scoreKeep();
}


void moon(int x, int y){
  pushMatrix();
  translate(x,y);
  noStroke();
  fill(244,241,201);
  ellipse(width/2,height - 50,100,100);
  fill(c);
  ellipse(width/2 + 20, height - 50, 75,75);
  popMatrix();
}

void sun(int l, int p){
  pushMatrix();
  translate(l,p);
  fill(252,212,64);
  ellipse(width/2,height - 50,100,100);
  popMatrix();
}

void back(){
  color ending = color(76,203,255);
  color beginning = color(64, 56, 123);
  c = lerpColor(beginning,ending,a);
  background(c);
  rectMode(CENTER);
  noStroke();
  fill(0,250,145);
  rect(width/2,height - 25, width, 50);
}

void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  fill(244,241,201);
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void drawHDbill(){
  if(!keyboard){
    billLocation.x = mouseX;
  }
  else if(billLocation.x < 54){
    billLocation.x = 54;
  }
  if(billLocation.x > width - 180){ //bill does not go into box
    billLocation.x = width - 180;
  };
  strokeWeight(0);
  noStroke();
  fill(255,128,114);
  rectMode(CENTER);
  rect(billLocation.x,billLocation.y, 45, 50); //body is center of location.y
  rect(billLocation.x, billLocation.y - 40, 60, 50); //head
  rect(billLocation.x - 10, billLocation.y + 30, 10, 10); //legs
  rect(billLocation.x + 10, billLocation.y + 30, 10, 10); //legs
  fill(50,250,50);
  strokeWeight(10);
  stroke(0);
  
  line(billLocation.x - 50, billLocation.y - 64, billLocation.x + 50,billLocation.y - 64); //hat
  if(jump){
    billLocation.y -= jumpheight;
    if(billLocation.y < height - 120){
      jumpheight *= -1;
      landing = !landing;
    };
    if(billLocation.y >= height - 80){
      if(landing){
        billLocation.y = height - 80;
        landing = !landing;
        jumpheight *= -1;
        jump = !jump;
        dontstop = !dontstop;
      };
    };
  };
};

void jumping(){
  if(!dontstop){
    jump = !jump;
    dontstop = !dontstop;
  }
}

class Basket{
  PVector location;
  
  Basket(float tempX, float tempY){
    location = new PVector(tempX, tempY);
  }
  
  void sketch(){
    fill(156,50,60);
    stroke(0);
    strokeWeight(2);
    rect(location.x,location.y,130,130); //basket
    fill(204,204,0);
    rect(location.x - 35, location.y, 20, 130); //gold band
    rect(location.x + 35, location.y, 20, 130);
    fill(255,255,0);
    rect(location.x, location.y, 35,60); //gold plate
    fill(0);
    ellipse(location.x, location.y - 10, 20,20); //keyhole
    triangle(location.x, location.y -10, location.x - 10, location.y + 20, location.x + 10, location.y + 20);
  }
  
  void HDmove(){
    location.x = random(65,width-65);
  }
}

class Pudding{
  PVector location;
  PVector velocity;
  PVector gravity;
  int design; //randomises which pudding comes next
  
  Pudding(float tempX,float tempY, float tempXspeed, float tempYspeed){
    location = new PVector(tempX,tempY);
    velocity = new PVector(tempXspeed, tempYspeed);
    gravity = new PVector(0,0.1);
    design = 1;
  };
  
  void sketch(){
    if(design == 1){
      noStroke();
      fill(225,139,152);
      ellipse(location.x,location.y,30,30);
    };
    if(design == 2){
      noStroke();
      fill(255,212,127);
      rectMode(CENTER);
      rect(location.x,location.y,30,30,12);
    }
  };
  
  void multiplySketch(){
    noStroke();
    fill(m);
    ellipse(location.x,location.y - 10,50,50);
    textAlign(CENTER);
    fill(d);
    textSize(25);
    text("X" + multiplier,location.x,location.y);
  }
  
  void move(int check){ //moves pudding
    location.add(velocity);
    velocity.add(gravity);
    if(location.x > width - 15 || location.x < 15){
      velocity.x *= - 1;
    };
    if(location.y < 12){
      location.y += 1;
      velocity.y *= -1;
    };
    if(location.y > height-140 && location.y < height - 130 && location.x < billLocation.x + 50 && location.x > billLocation.x - 50){
      location.y = billLocation.y - 80;
      velocity.y *= -0.9;
      if(check == 1 && multiplier < 32){
        multiplier *= 2;
        d = color(100,100,random(100,250));
      }
    };
    if(location.y > height - 135 && location.x < billLocation.x + 30 && location.x > billLocation.x - 30){
      if(location.x < billLocation.x){
        location.x = billLocation.x - 35;
        velocity.x *= -1;
      }
      else if(location.x > billLocation.x){
        location.x = billLocation.x + 35;
        velocity.x *= -1;
      }
      else{
      }
    };
    if(location.y > height - 47){
      sketch();
      gameOver();
    };
  };
  
  void inBasket(int check){ //checks if pudding is in the basket
    if(location.x > width - 115 && location.y > height -155){
      sketch();
      p += 0.01;
      if(triggerHD){
        change();
      }
      if(check == 1){
        score = score + multiplier;
        multiplier =1;
        goAway();
        newMultiplier.reset();
        reveal = false;
        stopTimer = false;
      }
      else{
        resetThing();
        score += 6;
      }
    };
  };
  
  void change(){
    design = (int)random(1,3);
  }
  
  void resetThing(){ //resets the pudding after basket and if continue
    location.x = 15;
    location.y = 15;
    velocity.x = random(1.15,1.2);
    velocity.y = random(0.2,1.2);
    if(triggerHD){
      velocity.x += random(p);
      velocity.y = random(0.1,0.5);
    }
    gravity.y = 0.1;
  }

  
  void goAway(){ //goAways the puddings after game ends
    fill(0);
    location.x = -50;
    location.y = -50;
    velocity.x = 0; 
    velocity.y = 0;
    gravity.y = 0;
  }
};

class Timer {
  int wait; //only initiates a function after the time needed has been reached
  int check; //only increments elapsed every second
  int timer; //resets the time elapsed to 0 once triggered
  int elapsed; //shows the seconds that have elapsed since timer was triggered
  boolean release; //releases multiplier after timer stops
  float t; //timing sun and moon
  int x; // sun so-ordinate
  int y; // sun co-ordinate
  int r; //radius of the circle sun and moon travels on
  int l; //inverse x (moon)
  int p; //inverse y (moon)
  float start; //resets sun and moon timer after 2 pi (1 revolution)
  boolean swap; //swaps the a integer *= -1
  
  Timer(int tempStart){
    wait = tempStart;
    stopTimer = false;
    t = millis()/1000.0;
    r = width/2 + 50;
  }
  
  void update(){
    elapsed = (int)((millis()/1000) - timer +1);
    if(check != elapsed){
      if(elapsed < wait){
        check = elapsed;
      }
      else if(elapsed >= wait){
        release();
        elapsed = 0;
        stopTimer = true;
        m = color(random(255),random(255),random(255));
      }
      else{
      }
    }
  }
  
  void showTime(){
    textSize(25);
    fill(250,250,50);
    textAlign(CENTER);
    if(!stopTimer){
      text("Multiplier: " + (wait - elapsed), 100, height - 15);
    }
  }
  
  void reset(){
    joker.goAway();
    timer = (int)millis()/1000;
    wait = (int)random(10,16);
  };
  
  void showOtherTime(){
    textSize(50);
    fill(250,250,50);
    textAlign(CENTER);
    if(!stopTimer){
      text(wait - elapsed,2*width/3,2*height/3);
    }
  }
  
  void release(){
    joker.resetThing();
    reveal = true;
  };
  
  void time(){  
    t = millis()/3000.0 - start;
    if(t > 2* PI){
      next();
    }
    if(t > 3){
      swap = true;
      if(swap && a > 1){
        a = 1;
        swap = !swap;
      }
      a -= 0.0075;
    }
    else if (t <3){
      swap = false;
      if(!swap && a < 0){
        a = 0;
        swap = !swap;
      }
      a += 0.0075;
    }
    
    x = (int)(r*cos(t)); 
    y = (int)(r*sin(t));
    l = x * -1;
    p = y * -1;
    
    moon(x,y);
    sun(l,p);
    if(a <= 0.3){
      fill(244,241,201);
      pushMatrix();
      translate(width*0.2, height*0.35);
      rotate(frameCount / -100.0);
      star(0, 0, 15.0, 30.0, 5); 
      popMatrix();
      pushMatrix();
      translate(width*0.75, height*0.25);
      rotate(frameCount / -100.0);
      star(0, 0, 20.0, 35.0, 5); 
      popMatrix();
      pushMatrix();
      translate(width*0.55, height*0.4);
      rotate(frameCount / -100.0);
      star(0, 0, 25.0, 40.0, 5); 
      popMatrix();
    }
  }
  
  void next(){
    start = millis()/3000.0;
  }
}
