import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;

Movie video;
OpenCV opencv;
ControlP5 cp5;

int strokeWeight = 3;
color contourStroke = color(0, 255, 0); 
color boxStroke     = color(255, 0, 0);
color boxFill      = color(255, 0, 0, 125); // rgba 0-255
color contourFill  = color(0, 255, 0, 125);

int min_width = 12;
int max_width = 125;
int min_height = 28;
int max_height = 220;

boolean run = false;
boolean showVideo = true;
boolean showCV = true;

boolean paused = false;
boolean fillBox = false;
boolean drawBox = true;
boolean drawContour = true;
boolean fillContour = false;
boolean showCoordinates = true;

int fontSize = 12;
PFont font;

int newFrame = 0;
PImage thisFrame;
int videoLengthFrames = 0;
float videoFrameRate = 24.0;


void setup() {
  // 50 pixel padding @ bottom for controls
  size(1920, 1130);
  
  initGUI();
  font = loadFont("AndaleMono-20.vlw");
  textFont(font);
  
  opencv = new OpenCV(this, 1920, 1080);
  opencv.startBackgroundSubtraction(5, 3, 0.5);
  
  video = new Movie(this, "video1x.mov");
  // video.loop();
  video.play();
  videoLengthFrames = getLength();
}

void draw() {
  if(!paused) {
    if (run) {
      setFrame(newFrame);
      println(getFrame() + " / " + (getLength() - 1), 10, 30);
    } else {
      if (video.available() == true) {
        video.read(); 
      }
    }
    
    if(showVideo) {
      image(video, 0, 0);  
    } else {
      background(0); 
    }
    opencv.loadImage(video);
    opencv.updateBackground();
    
    // ** opencv setting adjustments go here
    //opencv.dilate();
    //opencv.erode();
  
    if(showCV) {
      strokeWeight(strokeWeight);
      ArrayList<Contour> allContours = opencv.findContours();
      for(int i = 0; i < allContours.size(); i++) {
        Contour c = allContours.get(i);
        Rectangle box = c.getBoundingBox(); 
        if(box.width > min_width && box.height > min_height){
          if(box.width < max_width && box.height < max_height) {
            if(drawContour) {
              if(fillContour) fill(contourFill); else noFill();
              stroke(contourStroke); 
              c.draw(); 
            }
            if(drawBox) {
              if(fillBox) fill(boxFill); else noFill();
              stroke(boxStroke);
              rect(box.x, box.y, box.width, box.height); 
            }
            if(showCoordinates) {
              int crossSize = 5;
              float boxCenterX = box.x + (box.width/2);
              float boxCenterY = box.y + (box.height/2);
              
              // font properties
              textSize(fontSize);
              
              // cross-hairs properties
              stroke(255);
              strokeWeight(2);
              
              // cross-hairs
              line(boxCenterX - crossSize, boxCenterY, boxCenterX + crossSize, boxCenterY);
              line(boxCenterX, boxCenterY - crossSize, boxCenterX, boxCenterY + crossSize);
              
              // coordinates (String, x, y)
              text(" " + box.x + ", " + box.y, boxCenterX + box.width/2, boxCenterY + crossSize);
            }
          }
        } 
      }
    }
    
    // -- text on right side --
    //pushMatrix();
    //translate(width - 175, 150);
    //fill(255);
    //textSize(fontSize);
    //int spacer = fontSize;
    //if(showCoordinates) {
    //  ArrayList<Contour> allContours = opencv.findContours();
    //  for(int i = 0; i < allContours.size(); i++) {
    //    Contour c = allContours.get(i);
    //    Rectangle box = c.getBoundingBox();
    //    translate(0, spacer);
    //    text(nf(i,2) + " : " + box.x + " , " + box.y, 0, 0);
    //  }
    //}
    //popMatrix();
    
    if(run) {
        saveFrame("output/frame-######.png");
        println("frame saved");
    }
  }
}


int getFrame() {    
  return ceil(video.time() * 30) - 1;
}


void setFrame(int n) {
  video.play();
  video.read();
  // The duration of a single frame:
  float frameDuration = 1.0 / videoFrameRate;
    
  // We move to the middle of the frame by adding 0.5:
  float where = (n + 0.5) * frameDuration; 
    
  // Taking into account border effects:
  float diff = video.duration() - where;
  if (diff < 0) {
    where += diff - 0.25 * frameDuration;
  }
    
  video.jump(where);
  video.pause();  
  
  newFrame++;
}  

int getLength() {
  println("duration = " + video.duration());
  println("videoFrameRate = " + videoFrameRate);
  return floor(video.duration() * videoFrameRate);
}


void initGUI() {
  cp5 = new ControlP5(this);
  fill(30);
  noStroke();
  rect(0, 0, width, 50);
  
  
  // *** SET SLIDER RANGES HERE ***
  cp5.addSlider("min_width")
    .setPosition(10,25)
    .setRange(0,20)
    .setValue(8);
    
  cp5.addSlider("max_width")
    .setPosition(180, 25)
    .setRange(0,300)
    .setValue(78);
    
  cp5.addSlider("min_height")
    .setPosition(350, 25)
    .setRange(0,100)
    .setValue(14);
    
  cp5.addSlider("max_height")
    .setPosition(520, 25)
    .setRange(0,400)
    .setValue(157);
    
  cp5.addBang("runBang")
    .setPosition(width - 100, 15)
    .setSize(75, 25)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("run");
    
  cp5.addBang("restart")
    .setPosition(width - 250, 15)
    .setSize(20, 20)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("restart");
    
  cp5.addToggle("pause")
    .setPosition(width - 200, 15)
    .setSize(20, 20)
    .setLabel("pause");
    
  cp5.addToggle("showVideo")
    .setPosition(width - 400, 15)
    .setSize(20, 20)
    .setLabel("video");

  cp5.addToggle("showCV")
    .setPosition(width - 450, 15)
    .setSize(20, 20)
    .setLabel("CV");
    
  cp5.addToggle("fillContourToggle")
    .setPosition(width - 550, 15)
    .setSize(20, 20)
    .setLabel("fill contour");
    
  cp5.addToggle("fillBoxToggle")
    .setPosition(width - 600, 15)
    .setSize(20, 20)
    .setLabel("fill box");
    
  cp5.addToggle("drawBoxToggle")
    .setPosition(width - 650, 15)
    .setSize(20, 20)
    .setLabel("draw box"); 
    
  cp5.addToggle("drawContourToggle")
    .setPosition(width - 725, 15)
    .setSize(20, 20)
    .setLabel("draw countour"); 
    
  cp5.addToggle("showCoordinatesToggle")
    .setPosition(width - 825, 15)
    .setSize(20, 20)
    .setLabel("coordinates");
     
}

void restart() {
   video.jump(0.0);
   video.play(); 
}

void showCoordinatesToggle() {
  showCoordinates = !showCoordinates;
}

void fillContourToggle() {
   fillContour = !fillContour; 
}

void drawContourToggle() {
  drawContour = !drawContour; 
}

void drawBoxToggle() {
  drawBox = !drawBox;
}

void fillBoxToggle() {
   fillBox = !fillBox; 
}

void pause() {
   paused = !paused; 
}

void runBang() {
   video.jump(0.0);
   run = !run; 
}