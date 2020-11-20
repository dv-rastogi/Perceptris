//game logic credits: https://www.openprocessing.org/sketch/313016/

float xoff1 = 0;
float xoff2 = 100;

import processing.sound.*;
SoundFile file;
SoundFile lose;
SoundFile linevanish;
SoundFile levelchange;

float scale=1.5;//*******
import processing.serial.*;
Serial myport;
String data="";

int countlose=0;
int w = int(10*scale); //*******
int h = int(20*scale); //*******
int q = int(20*scale);//blocks width and height//*******
int dt;// delay between each move
int currentTime;
int finalscore;
Grid grid;
Piece piece;
Piece nextPiece;
Pieces pieces;
Score score;
int r = 0;//rotation status, from 0 to 3
int level = 1;
int nbLines = 0;
int count =0;
int countlinevanish=0;
int prelevel=0;
int txtSize = 20;
int textColor = color(34, 230, 190);
Boolean gameOver = false;
Boolean gameOn = false;


void setup()
{
  size(600, 480, P2D);
  textSize(20);
  
  file=new SoundFile(this,"gg1.mp3");
  lose=new SoundFile(this,"lose.mp3");
  linevanish= new SoundFile(this,"linevanish.mp3"); 
  levelchange= new SoundFile(this, "levelup.mp3");
  myport = new Serial(this, "COM9", 9600);
  myport.bufferUntil('\n');
}

void serialEvent(Serial myPort)
{ 
  data=myPort.readStringUntil('\n');
  if(data.length()==2)
  {
  data="";
  }
}

void initialize() 
{
  xoff1 = 0;
  xoff2 = 100;
  file.amp(0.6);
  file.play();
  countlose=0;
  countlinevanish=0;
  level = 1;
  nbLines = 0;
  dt = 500;
  currentTime = millis();
  score = new Score();
  grid = new Grid();
  pieces = new Pieces();
  piece = new Piece(-1);
  nextPiece = new Piece(-1);
  prelevel=0;
}



void draw()
{
  translate(300,50);
  strokeWeight(2);
  background(0); 
  if(prelevel!=level)
  {
  levelchange.play();
  }
  
  
  if((grid != null)&(!gameOver))
  {  
    
  noFill();
  beginShape();
  strokeWeight(2+random(5));
  stroke(random(255),random(255),random(255));
  for (float y = 0; y < 2400; y++) 
  {
    
    //float y = random(height);
    float x = noise(xoff2)*height*0.3;
    vertex(x-150, y-150);
    xoff2 += 0.001; 
  }
  endShape();
  
  beginShape();
  strokeWeight(2+random(5));
  stroke(random(255),random(255),random(255));
  for (float y = 0; y < 2400; y++) 
  {
    
    //float y = random(height);
    float x = noise(xoff2)*height*0.4;
    vertex(x+1200, y-150);
    xoff2 += 0.001;
  }
  endShape();
  
  strokeWeight(2);
    
    
    translate(300,-10); //*******
    grid.drawGrid();
    int now = millis();
    if (gameOn) 
    {
      if (now - currentTime > dt) 
      {
        currentTime = now;
        piece.oneStepDown();
      }
    }
    piece.display(false);
    score.display();
  }
  
  if (gameOver) 
  {
    fill(255);
    rect(110, 195-20, 240, 3*txtSize, 3);
    fill(0);
    text("GAME OVER :(", 120, 220-20);
    text("Final Score: "+finalscore,120,245-20);
    while(countlose==0)
    {
     lose.play();
     file.stop();
     countlose++;
    }
  }
  
  if ((!gameOn)|(gameOver)) 
  {
  
    strokeWeight(5);
    stroke(255);
    translate(300,50);
    fill(100,200,255);
    rect(200,0,100,100);
    rect(300,0,100,100);
    rect(400,0,100,100);
    rect(500,0,100,100);
    
    fill(0,0,255);
    rect(200,300,100,100);
    rect(200,400,100,100);
    rect(200,500,100,100);
    rect(200,600,100,100);
    rect(300,300,100,100);
    
    fill(255,255,0);
    rect(500,100,100,100);
    rect(500,200,100,100);
    rect(500,300,100,100);
    rect(400,300,100,100);
    
    fill(255,0,0);
    rect(200,100,100,100);
    rect(200,200,100,100);

    PFont font;
    font = createFont("Dubai-Bold.ttf", 32);
    textFont(font);
    textSize(80);
    fill(255);
    strokeWeight(0);
    text("ERCEPTRIS",305,700); 
     
    fill(0);
    stroke(textColor);
    strokeWeight(4);
    rect(110+88, 250+475, 255, 2*txtSize+5, 3);
    fill(textColor);
    textSize(20);
    text("Press 'P' To Start Playing!", 120+88, 280+475);
  }
  
  if(data==null)
  {
  data="";
  }
  if(data.length()==7)
    {piece.inputKey(RIGHT);}
  if(data.length()==6)
    {piece.inputKey(LEFT);}
  if(data.length()==8)
    { /*++count;
      if(count%2==0)*/
      piece.inputKey(UP);
    }
   if(data.length()==3)
    { 
      dt=500;
      level=1;
    }
    if(data.length()==4)
    { 
      dt=400;
      level=2;
    }
    if(data.length()==5)
    { 
      dt=200;
      level=3;
    }
    if(data.length()==10)
    {
    piece.inputKey(DOWN);
    }
  data=""; 

prelevel=level;
}

void goToNextPiece()
{
  piece = new Piece(nextPiece.kind);
  nextPiece = new Piece(-1);
  r = 0;
}

void goToNextLevel() 
{
  score.addLevelPoints();
  level = 1 + int(nbLines/10);   
  dt *= .8;
}



void keyPressed() 
{
  if ((key == CODED && gameOn)) 
  {
    switch(keyCode)
    {
    case LEFT:
    case RIGHT:
    case DOWN:
    case UP:
    case SHIFT:
      piece.inputKey(keyCode);
      break;
    }
  }
  else if (keyCode == 80) 
  {
    if((!gameOn)|(gameOver))
    {
      initialize();
      gameOver = false;
      gameOn = true;
    }
  } 
 
  if(keyCode == ALT)
  {
  level+=1;
  dt*=0.8;
  }
  
}

class Grid 
{
  int [][] cells = new int[w][h];

  Grid() 
  {
    for (int i = 0; i < w; i ++) 
    {
      for (int j = 0; j < h; j ++) 
      {
        cells[i][j] = 0;
      }
    }
  }

  Boolean isFree(int x, int y)
  {
    if (x > -1 && x < w && y > -1 && y < h)
    {
      return cells[x][y] == 0;
    } else if (y < 0) {
      return true;
    }
    return false;
  }

  Boolean pieceFits() {
    int x = piece.x;
    int y = piece.y;
    int[][][] pos = piece.pos;
    Boolean pieceOneStepDownOk = true;
    for (int i = 0; i < 4; i ++) {
      int tmpx = pos[r][i][0]+x;
      int tmpy = pos[r][i][1]+y;
      if (tmpy >= h || !isFree(tmpx, tmpy)) {
        pieceOneStepDownOk = false;
        break;
      }
    }
    return pieceOneStepDownOk;
  }

  void addPieceToGrid() 
  {
   
    int x = piece.x;
    int y = piece.y;
    int[][][] pos = piece.pos;
    
    for (int i = 0; i < 4; i ++) 
     {
      if(pos[r][i][1]+y >= 0)
      {
        cells[pos[r][i][0]+x][pos[r][i][1]+y] = piece.c;
      }
      else
      {
        gameOn = false;
        gameOver = true;
        return;
      }
    int count=0;
    for (int p = 0; p < w; p++)
      {
      if(cells[p][0]==0)
      {
      count+=1;
      }
      }
     if(count<w)
     {
     gameOver=true;
     }
    }
    score.addPiecePoints();
    checkFullLines();
    goToNextPiece();
    drawGrid();
  }

  void checkFullLines()
  {
    int c=0;
    
    int nb = 0;//number of full lines
    for (int j = 0; j < h; j ++) {
      Boolean fullLine = true;
      for (int i = 0; i < w; i++) {
        fullLine = cells[i][j] != 0;
        if (!fullLine) {
          break;
        }
        else 
        {c++;}
        
      }
      if(c==w)
      {countlinevanish=0;}
      // this jth line if full, delete it
      if (fullLine) {
        nb++;
        for (int k = j; k > 0; k--) {
          for (int i = 0; i < w; i++) {
            cells[i][k] = cells[i][k-1];
            while(countlinevanish==0)
            {
            linevanish.play();
            countlinevanish++;
            }
        }
        }
        // top line will be empty
        for (int i = 0; i < w; i++) {
          cells[i][0] = 0;
        }
      }
    }
    deleteLines(nb);
  }

void deleteLines(int nb)
  {
    nbLines += nb;
    if (int(nbLines / 10) > level-1)
    {
      goToNextLevel();
    }
    score.addLinePoints(nb);
  }

  void setToBottom()
  {
    int j = 0;
    for (j = 0; j < h; j ++) {
      if (!pieceFits()) {
        break;
      } else {
        piece.y++;
      }
    }
    piece.y--;
    addPieceToGrid();
  }

  void drawGrid() 
  {  
    /*
    int R[]={128,230,12,9,230,230,12};
    int G[]={12,12,230,239,230,128,12};
    int B[]={128,12,12,230,9,9,230};
    */
    int rand=int(random(255));
    stroke(255);
    pushMatrix();
    translate(160, 40);
    for (int i = 0; i <= w; i ++) {
      line(i*q, 0, i*q, h*q);
    }
    for (int j = 0; j <= h; j ++) {
      line(0, j*q, w*q, j*q);
    }
    stroke(rand,rand,rand);
    for (int i = 0; i < w; i ++) {
      for (int j = 0; j < h; j ++) {
        if (cells[i][j] != 0) {
          fill(cells[i][j]);
          rect(i*q, j*q, q, q);
        }
      }
    }
    popMatrix();
  }

}

class Piece 
{
  final color[] colors = 
  {
    color(128, 12, 128), //purple
    color(230, 12, 12), //red
    color(12, 230, 12), //green
    color(9, 239, 230), //cyan 
    color(230, 230, 9), //yellow
    color(230, 128, 9), //orange
    color(12, 12, 230) //blue
  };

  // [rotation][block nb][x or y]
  final int[][][] pos;
  int x = int(w/2);
  int y = 0;
  int kind;
  int c;

  Piece(int k)
  {
    kind = k < 0 ? int(random(0, 7)) : k;
    c = colors[kind];
    r = 0;
    pos = pieces.pos[kind];
  }

  void display(Boolean still)
  {
    stroke(250);
    fill(c);
    pushMatrix();
    if (!still) {
      translate(160, 40);
      translate(x*q, y*q);
    }
    int rot = still ? 0 : r;
    for (int i = 0; i < 4; i++) {
      rect(pos[rot][i][0] * q, pos[rot][i][1] * q, 20*scale, 20*scale);  //*******    
    }
    popMatrix();
  }

  // returns true if the piece can go one step down
  void oneStepDown() 
  {
    y += 1;
    if(!grid.pieceFits())
    {
      piece.y -= 1;
      grid.addPieceToGrid();
    }
  }

  // try to go one step left
  void oneStepLeft() 
  {
    x -= 1;
  }

  // try to go one step right
  void oneStepRight()
  {
    x += 1;
  }

  void goToBottom() {
    grid.setToBottom();
  }

  void inputKey(int k) {
    switch(k) {
    case LEFT:
      x --;
      if(grid.pieceFits()){
      }else {
         x++; 
      }
      break;
    case RIGHT:
      x ++;
      if(grid.pieceFits()){
      }else{
         x--; 
      }
      break;
    case DOWN:
      oneStepDown();
      break;
    case UP:
      r = (r+1)%4;
      if(!grid.pieceFits()){
         r = r-1 < 0 ? 3 : r-1; 
      }
      break;
    case SHIFT:
      goToBottom();
      break;
    }
  }
}

class Pieces {
  int[][][][] pos = new int [7][4][4][2];

  Pieces() {
    ////   @   ////
    //// @ @ @ ////
    pos[0][0][0][0] = -1;//piece 0, rotation 0, point nb 0, x
    pos[0][0][0][1] = 0;// piece 0, rotation 0, point nb 0, y
    pos[0][0][1][0] = 0;
    pos[0][0][1][1] = 0;
    pos[0][0][2][0] = 1;
    pos[0][0][2][1] = 0;
    pos[0][0][3][0] = 0;
    pos[0][0][3][1] = 1;
    
    pos[0][1][0][0] = 0;
    pos[0][1][0][1] = 0;
    pos[0][1][1][0] = 1;
    pos[0][1][1][1] = 0;
    pos[0][1][2][0] = 0;
    pos[0][1][2][1] = -1;
    pos[0][1][3][0] = 0;
    pos[0][1][3][1] = 1;

    pos[0][2][0][0] = -1;
    pos[0][2][0][1] = 0;
    pos[0][2][1][0] = 0;
    pos[0][2][1][1] = 0;
    pos[0][2][2][0] = 1;
    pos[0][2][2][1] = 0;
    pos[0][2][3][0] = 0;
    pos[0][2][3][1] = -1;

    pos[0][3][0][0] = -1;
    pos[0][3][0][1] = 0;
    pos[0][3][1][0] = 0;
    pos[0][3][1][1] = 0;
    pos[0][3][2][0] = 0;
    pos[0][3][2][1] = -1;
    pos[0][3][3][0] = 0;
    pos[0][3][3][1] = 1;

    //// @ @   ////
    ////   @ @ ////
    pos[1][0][0][0] = pos[1][2][0][0] = -1;//piece 1, rotation 0, point nb 0, x
    pos[1][0][0][1] = pos[1][2][0][1] = 1;// piece 1, rotation 0, point nb 0, y
    pos[1][0][1][0] = pos[1][2][1][0] = 0;
    pos[1][0][1][1] = pos[1][2][1][1] = 1;
    pos[1][0][2][0] = pos[1][2][2][0] = 0;
    pos[1][0][2][1] = pos[1][2][2][1] = 0;
    pos[1][0][3][0] = pos[1][2][3][0] = 1;
    pos[1][0][3][1] = pos[1][2][3][1] = 0;

    pos[1][1][0][0] = pos[1][3][0][0] = -1;
    pos[1][1][0][1] = pos[1][3][0][1] = 0;
    pos[1][1][1][0] = pos[1][3][1][0] = 0;
    pos[1][1][1][1] = pos[1][3][1][1] = 0;
    pos[1][1][2][0] = pos[1][3][2][0] = -1;
    pos[1][1][2][1] = pos[1][3][2][1] = -1;
    pos[1][1][3][0] = pos[1][3][3][0] = 0;
    pos[1][1][3][1] = pos[1][3][3][1] = 1;
    
    ////   @ @ ////
    //// @ @   ////
    pos[2][0][0][0] = pos[2][2][0][0] = 0;//piece 2, rotation 0 and 2, point nb 0, x
    pos[2][0][0][1] = pos[2][2][0][1] = 1;//piece 2, rotation 0 and 2, point nb 0, y
    pos[2][0][1][0] = pos[2][2][1][0] = 1;
    pos[2][0][1][1] = pos[2][2][1][1] = 1;
    pos[2][0][2][0] = pos[2][2][2][0] = -1;
    pos[2][0][2][1] = pos[2][2][2][1] = 0;
    pos[2][0][3][0] = pos[2][2][3][0] = 0;
    pos[2][0][3][1] = pos[2][2][3][1] = 0;

    pos[2][1][0][0] = pos[2][3][0][0] = 0;
    pos[2][1][0][1] = pos[2][3][0][1] = 0;
    pos[2][1][1][0] = pos[2][3][1][0] = 1;
    pos[2][1][1][1] = pos[2][3][1][1] = 0;
    pos[2][1][2][0] = pos[2][3][2][0] = 1;
    pos[2][1][2][1] = pos[2][3][2][1] = -1;
    pos[2][1][3][0] = pos[2][3][3][0] = 0;
    pos[2][1][3][1] = pos[2][3][3][1] = 1;
    
    ////// @ //////
    ////// @ //////
    ////// @ //////
    ////// @ //////
    pos[3][0][0][0] = pos[3][2][0][0] = 0;//piece 3, rotation 0 and 2, point nb 0, x
    pos[3][0][0][1] = pos[3][2][0][1] = -1;//piece 3, rotation 0 and 2, point nb 0, y
    pos[3][0][1][0] = pos[3][2][1][0] = 0;
    pos[3][0][1][1] = pos[3][2][1][1] = 0;
    pos[3][0][2][0] = pos[3][2][2][0] = 0;
    pos[3][0][2][1] = pos[3][2][2][1] = 1;
    pos[3][0][3][0] = pos[3][2][3][0] = 0;
    pos[3][0][3][1] = pos[3][2][3][1] = 2;

    pos[3][1][0][0] = pos[3][3][0][0] = -1;
    pos[3][1][0][1] = pos[3][3][0][1] = 0;
    pos[3][1][1][0] = pos[3][3][1][0] = 0;
    pos[3][1][1][1] = pos[3][3][1][1] = 0;
    pos[3][1][2][0] = pos[3][3][2][0] = 1;
    pos[3][1][2][1] = pos[3][3][2][1] = 0;
    pos[3][1][3][0] = pos[3][3][3][0] = 2;
    pos[3][1][3][1] = pos[3][3][3][1] = 0;
    
    //// @ @ ////
    //// @ @ ////
    //piece 4, all rotations are the same
    pos[4][0][0][0] = pos[4][1][0][0] = pos[4][2][0][0] = pos[4][3][0][0] = 0;
    pos[4][0][0][1] = pos[4][1][0][1] = pos[4][2][0][1] = pos[4][3][0][1] = 0;
    pos[4][0][1][0] = pos[4][1][1][0] = pos[4][2][1][0] = pos[4][3][1][0] = 1;
    pos[4][0][1][1] = pos[4][1][1][1] = pos[4][2][1][1] = pos[4][3][1][1] = 0;
    pos[4][0][2][0] = pos[4][1][2][0] = pos[4][2][2][0] = pos[4][3][2][0] = 0;
    pos[4][0][2][1] = pos[4][1][2][1] = pos[4][2][2][1] = pos[4][3][2][1] = 1;
    pos[4][0][3][0] = pos[4][1][3][0] = pos[4][2][3][0] = pos[4][3][3][0] = 1;
    pos[4][0][3][1] = pos[4][1][3][1] = pos[4][2][3][1] = pos[4][3][3][1] = 1;

    ///// @   ////
    ///// @   ////
    ///// @ @ ////
    pos[5][0][0][0] = 0;//piece 5, rotation 0, point nb 0, x
    pos[5][0][0][1] = 1;//piece 5, rotation 0, point nb 0, y
    pos[5][0][1][0] = 1;
    pos[5][0][1][1] = 1;
    pos[5][0][2][0] = 0;
    pos[5][0][2][1] = 0;
    pos[5][0][3][0] = 0;
    pos[5][0][3][1] = -1;

    pos[5][1][0][0] = 0;
    pos[5][1][0][1] = 0;
    pos[5][1][1][0] = 1;
    pos[5][1][1][1] = 0;
    pos[5][1][2][0] = 2;
    pos[5][1][2][1] = 0;
    pos[5][1][3][0] = 2;
    pos[5][1][3][1] = -1;

    pos[5][2][0][0] = 0;
    pos[5][2][0][1] = -1;
    pos[5][2][1][0] = 1;
    pos[5][2][1][1] = -1;
    pos[5][2][2][0] = 1;
    pos[5][2][2][1] = 0;
    pos[5][2][3][0] = 1;
    pos[5][2][3][1] = 1;

    pos[5][3][0][0] = 0;
    pos[5][3][0][1] = 0;
    pos[5][3][1][0] = 1;
    pos[5][3][1][1] = 0;
    pos[5][3][2][0] = 2;
    pos[5][3][2][1] = 0;
    pos[5][3][3][0] = 0;
    pos[5][3][3][1] = 1;
    
    ////   @ ////
    ////   @ ////
    //// @ @ ////
    pos[6][0][0][0] = 0;//piece 6, rotation 0, point nb 0, x
    pos[6][0][0][1] = 1;//piece 6, rotation 0, point nb 0, y
    pos[6][0][1][0] = 1;
    pos[6][0][1][1] = 1;
    pos[6][0][2][0] = 1;
    pos[6][0][2][1] = 0;
    pos[6][0][3][0] = 1;
    pos[6][0][3][1] = -1;

    pos[6][1][0][0] = 0;
    pos[6][1][0][1] = 0;
    pos[6][1][1][0] = 1;
    pos[6][1][1][1] = 0;
    pos[6][1][2][0] = 2;
    pos[6][1][2][1] = 0;
    pos[6][1][3][0] = 2;
    pos[6][1][3][1] = 1;

    pos[6][2][0][0] = 0;
    pos[6][2][0][1] = -1;
    pos[6][2][1][0] = 1;
    pos[6][2][1][1] = -1;
    pos[6][2][2][0] = 0;
    pos[6][2][2][1] = 0;
    pos[6][2][3][0] = 0;
    pos[6][2][3][1] = 1;

    pos[6][3][0][0] = 0;
    pos[6][3][0][1] = 0;
    pos[6][3][1][0] = 1;
    pos[6][3][1][1] = 0;
    pos[6][3][2][0] = 2;
    pos[6][3][2][1] = 0;
    pos[6][3][3][0] = 0;
    pos[6][3][3][1] = -1;
  }
}

class Score {
  int points = 0;

  void addLinePoints(int nb) {
    if (nb == 4) {
      points += level * 10 * 20;
    } else {
      points += level * nb * 20;
    }
  }

  void addPiecePoints() {
    points += level * 5;
  }

  void addLevelPoints() {
    points += level * 100;
  }

  void display() {
    pushMatrix();
    translate(40, 60);
    textSize(25);
    //score
    fill(textColor);
    text("Score: ", 0, 0);
    fill(230, 230, 12);
    text(""+formatPoint(points), 0, txtSize+5);

    //level
    fill(textColor);
    text("Level: ", 0, 4*txtSize);
    fill(230, 230, 12);
    text("" + level, 0, 5*txtSize+5);
    
    //lines
    fill(textColor);
    text("Lines: ", 0, 8*txtSize);
    fill(230, 230, 12);
    text("" + nbLines, 0, 9*txtSize+5);
    popMatrix();


    pushMatrix();
    translate(400, 60);

    //score
    fill(textColor);
    text("Next: ", 230, 0); //*******

    translate(1.2*q+230, 1.5*q+txtSize); //*******
    nextPiece.display(true);
    popMatrix();
    finalscore=int(formatPoint(points));
  }

  String formatPoint(int p) {
    String txt = "";
    int qq = int(p/1000000);
    if (qq > 0) {
      txt += qq + ".";
      p -= qq * 1000000;
    }

    qq = int(p/1000);
    if (txt != "") {
      if (qq == 0) {
        txt += "000";
      } else if (qq < 10) {
        txt += "00";
      } else if (qq < 100) {
        txt += "0";
      }
    }
    if (qq > 0) {
      txt += qq;
      p -= qq * 1000;
    }
    if (txt != "") {
      txt += ".";
    }

    if (txt != "") {
      if (p == 0) {
        txt += "000";
      } else if (p < 10) {
        txt += "00" + p;
      } else if (p < 100) {
        txt += "0" + p;
      } else {
        txt += p;
      }
    } else {
      txt += p;
    }
    return txt;
  }
}
