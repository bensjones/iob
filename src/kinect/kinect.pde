//  version 4: sent bucketArray to zero (off lights) after 1/2 seconds of  beeing present...


import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import http.requests.*;

Kinect kinect;
PImage display;
int[] depth;


float[] yArray = {0,100,200, 300, 400,520};
float[] xArray = {0,65,130,195,260,325,390,455,520,580,640};

int[] bucketArrayCurrent = new int[52]; //holds all the current skeletons
int[] bucketArray = new int[52];  //holds hand positions for each bucket
int[] lastArray = new int[52];
long[] bucketArrayTime = new long[52];
int[] bucketArrayTemp = new int[52];
int[] lastBucketArraySent = new int[52];
int[] preBucketArray = new int[52];  //holds hand positions for each bucket

int bucketPosition = 0;
int[] bucketAddress = new int[55];
int colors = 10;
int colorRed = 0;
int colorGreen = 0;
int colorBlue = 0;
int colorJ = 0;
int wheelPos = 0;

int colorJ2 = 0;
int sendCounter = 0;
int bucketNumber = 0;

int programIncrement = 0;
int playingProgram = 0;
int programPlayTime = 10000;

String[] program = {"ocean", "vapor", "spinner", "rainbow", "bonfire", "ctrlh", "circle", "tron"};
int increment = 0;
String tempURL;

int waitTime = 200;
long lastTime = 0;

long currentStartTime = 0;
int runKinect = 1;
int runColorWheel1 = 0;
int runColorWheel2 = 0;


void setup() {
  size(640, 520);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.enableMirror(true);

}

void draw() {

  if(currentStartTime == 0){
    currentStartTime = millis();
  }
  
  if(runKinect == 1){
    if(millis() - currentStartTime > 15000){ // if 10  seconds have passsed
      runKinect = 0;
      playingProgram = 1;
      programIncrement++;
      print(programIncrement);
      delay(500);
      if(programIncrement == 4){  //bonfire gets 60 seconds
        programPlayTime = 60000;
      } else {
        programPlayTime = 10000;
      }
      sendCounter = 0;
      if(programIncrement == 8){
        programIncrement = 0;
      }
      //runColorWheel2 = 1;
      //colorJ2 = (int)random(0,255);
      currentStartTime = millis();
      //print("starting colorwheel");
    }
  }
  
  if(playingProgram == 1 && programIncrement != 8){
      if(sendCounter < 2){ //send x amount of times 
        //println(colors);
        sendGet2(bucketNumber, colors, colors, colors, program[programIncrement]);
        bucketNumber++;
        if(bucketNumber == 51){  //completed sending to all 50 buckets
          if(sendCounter < 5){ //sendcounter goes to 5 and we stop sending
            sendCounter++;
            }
          bucketNumber = 0; 
         }
      }
      if(millis() - currentStartTime > programPlayTime){
        playingProgram = 0;
        runKinect =  1;
        currentStartTime = millis();
        print("starting kinnect");
        for(int i = 0; i < 50; i++){ //gets the kinext function to zero out all the buckets
          bucketArray[i] = 0;
          lastArray[i] = 0;
          lastBucketArraySent[i] = 1;
        }
            
    }
  }
  
  
  
  if(programIncrement == 8 && playingProgram == 1){
    if(millis() - currentStartTime > 10000){
      playingProgram = 0;
      runKinect =  1;
      currentStartTime = millis();
      print("starting kinnect");
      for(int i = 0; i < 50; i++){ //gets the kinext function to zero out all the buckets
        bucketArray[i] = 0;
        lastArray[i] = 0;
        lastBucketArraySent[i] = 1;
      }
            
    }
  }
  
  
  
  
  /////-------------------------------------------------------- RUN Kinect
  
  if(runKinect == 1){
    background(255);
    display = createImage(kinect.width, kinect.height, RGB);
    depth = kinect.getRawDepth();
    
    PImage img = kinect.getDepthImage();
  
    // Being overly cautious here
    if (depth == null || img == null) return;
    
    for(int i = 0; i < 50; i++){
      bucketArray[i] = 0;
      preBucketArray[i] = 0;
    }

    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {
  
        int offset = x + y * kinect.width;
        // Raw depth
        int rawDepth = depth[offset];
        int pix = x + y * display.width;
        if (rawDepth > 500 && rawDepth < 950) {
          // A red color instead
          display.pixels[pix] = color(150, 150, 150);
          bucketPosition = findBucket(x,y);
          preBucketArray[bucketPosition]++;
        } else {
          display.pixels[pix] = color(0, 0, 0);
          }
      }
    }
    //display.updatePixels();
  
    // Draw the image
    //image(display, 0, 0);
    
    //see if the threshold of pixels is good
    for(int i = 0; i < 50; i++){
      if(preBucketArray[i] > 1000){
        bucketArray[i] = 1;

//          print(i);
//          print(", ");
//          println(preBucketArray[i]);   

      } else{
        bucketArray[i] = 0;
      }
    }
  
  
    for(int i = 0; i < 50; i++){
      if(bucketArray[i] != lastArray[i]){
        bucketArrayTime[i] = millis();
        lastArray[i] = bucketArray[i];
        //bucketArrayTime[i] = millis() - 70;
      }
    }
  
  for(int i = 0; i < 50; i++){
    if(millis() - bucketArrayTime[i] > 20){  //debounce delay
      if(bucketArray[i] != lastBucketArraySent[i]){
        lastBucketArraySent[i] = bucketArray[i];
        if(bucketArray[i] == 1){
          if(millis() - bucketArrayTime[i] < 500){
            //print(i);
            //print(",");
             wheelPos = 255 - ((colorJ+i) & 255);
      
            if(wheelPos < 85) {
              colorRed = 255 - wheelPos * 3;
              colorGreen = 0;
              colorBlue = wheelPos * 3;
              }
            if(wheelPos > 85 && wheelPos < 170) {
              wheelPos -= 85;
              colorRed = 0;
              colorGreen = wheelPos * 3;
              colorBlue = 255 - wheelPos * 3;
              }
            if(wheelPos > 170){
              wheelPos -= 170;
              colorRed = wheelPos * 3;
              colorGreen = 255 - wheelPos * 3;
              colorBlue = 0;
              }
            colorJ= colorJ+1;
            if(colorJ > 255){
              colorJ = 0;
              }
            } else{
              colorRed = 0;
              colorGreen = 0;
              colorBlue = 0;
              }
          }
        if(bucketArray[i] == 0){
          colorRed = 20;
          colorGreen = 20;
          colorBlue = 20;
          }
      sendGet(i, colorRed, colorGreen, colorBlue, program[increment]);
      delay(5);
      } else{ //last bucketArray == last bucketArraySent ie nothing has changed
        //if(bucketArray[i] == 1 && millis() - bucketArrayTime[i] > 100){ //someone's there and its been 40ms sent the last send (100 - 40).. lets trigger it again
        //  bucketArrayTime[i] = millis();
        //  lastBucketArraySent[i] = 0;
        //}
         if(bucketArray[i] == 0 && millis() - bucketArrayTime[i] > 1000){ //delete buckets that didn't get deleted
          bucketArrayTime[i] = millis();
          lastBucketArraySent[i] = 1;
        }
      }
    }
    //if(millis() - bucketArrayTime[i] > 500){
    //  colorRed = 20;
    //  colorGreen = 20;
    //  colorBlue = 20;
    //  sendGet(i, colorRed, colorGreen, colorBlue, program[increment]);
    //}
    }
  
    
  }

  ///------------------------------------------run Color Wheel
  if(runColorWheel2 == 1){
    background(0);
  
    if(sendCounter < 1){ //send x amount of times 
      //println(colors);
      sendGet(bucketNumber, colorRed, colorGreen, colorBlue, program[increment]);
      delay(5);
      bucketNumber++;
      if(bucketNumber == 51){  //completed sending to all 50 buckets
        sendCounter = 0;
        colorJ2 = colorJ2+2;
        //if(sendCounter < 5){ //sendcounter goes to 5 and we stop sending
        //  sendCounter++;
        //}
        bucketNumber = 0; 
      }
      
      //wheelPos = 255 - ((colorJ+bucketNumber) & 255);  color1
      
      wheelPos = ((bucketNumber*256/50)+colorJ2)&255;  //rainbow cycle
      
      if(colorJ2 == 256){
        colorJ2 = 0;
      }
      
      if(wheelPos < 85) {
        colorRed = 255 - wheelPos * 3;
        colorGreen = 0;
        colorBlue = wheelPos * 3;
      }
      if(wheelPos > 85 && wheelPos < 170) {
        wheelPos -= 85;
        colorRed = 0;
        colorGreen = wheelPos * 3;
        colorBlue = 255 - wheelPos * 3;
      }
      if(wheelPos > 170){
        wheelPos -= 170;
        colorRed = wheelPos * 3;
        colorGreen = 255 - wheelPos * 3;
        colorBlue = 0;
      }
      colorJ++;
      if(colorJ > 255){
        colorJ = 0;
      }
      
    }
  }
}
  
  


//find out which bucket the hand refers too
int findBucket(float xPosition, float yPosition){
  //print(xPosition, ", ", yPosition, ", ");
  int bucketPosition = 51;  //51 means no buckets were found...
  for(int i=0; i<10; i++){
    if(xPosition >= xArray[i] && xPosition <= xArray[i+1]){
      //print(i); print(", "); println(xArray[i]);
      for(int j=0; j<5; j++){
        if(yPosition >= yArray[j] && yPosition <= yArray[j+1]){
          //print(j); print(", "); println(yArray[j]);
          //println(i + j*10);
          bucketPosition = i + j*10;
          
          
        } else {
          //println("no J");
        //return 51;  //just in case no matching bucket postions are found
      }
      }
    } else{
        //println("no I");
      //return 0; //just in case no matching bucket postions are found
    }
  }
  //println(bucketPosition);
  
  return bucketPosition;
}


  //send get post
void sendGet(int bucketPos, int red, int green, int blue, String currentProgram){
 
 //for(int j=201; j<251; j++){  //add addresses to all the buckets
  int j = 201;
  for(int i=0; i<51; i++){
    bucketAddress[i] = j;
    j++;
  }
//}
  
  
  String common = "http://192.168.16."; // answer text
  int bucketUniqueAddress = bucketAddress[bucketPos];
  
  //String URL = common + bucketUniqueAddress + "/?" + "sequence=" + currentProgram;
  
  String URL = common + bucketUniqueAddress + "/?" + "r=" + red + "&g=" + green + "&b=" + blue; 
  
  //println(URL);
  
  tempURL = URL;
  thread("sendGetRequest");
}

  //send get post
void sendGet2(int bucketPos, int red, int green, int blue, String currentProgram){
 
 //for(int j=201; j<251; j++){  //add addresses to all the buckets
  int j = 201;
  for(int i=0; i<51; i++){
    bucketAddress[i] = j;
    j++;
  }
//}
  
  
  String common = "http://192.168.16."; // answer text
  int bucketUniqueAddress = bucketAddress[bucketPos];
  
  String URL = common + bucketUniqueAddress + "/?" + "sequence=" + currentProgram;
  
  //String URL = common + bucketUniqueAddress + "/?" + "r=" + red + "&g=" + green + "&b=" + blue; 
  
  //println(URL);
  
  tempURL = URL;
  thread("sendGetRequest");
}


void sendGetRequest(){
  try {
    GetRequest get = new GetRequest(tempURL);
    get.send();
  } catch (Exception err) {
    // don't care lol
  }
}