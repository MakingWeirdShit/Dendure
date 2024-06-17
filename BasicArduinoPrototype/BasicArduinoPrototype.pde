import processing.serial.*;
import processing.video.*;
import java.util.HashMap;
import java.util.Map;

Serial myPort;
Map<String, VideoData> videoMap;
Movie currentMovie;
boolean isPlaying = false;
String myString = "";
int secondDisplay = 2;
long videoEndTime = 0;
boolean waitingForRemoval = false;
boolean setupComplete = false;
boolean serialReady = false; // Flag to track if serial port is ready
boolean canScanNFC = true; // Flag to allow or disallow NFC scanning

//issues, flickers like a mf, the first time gstreamer need to be scanned and then it plays so it takes like 10 seconds to play first try


class VideoData {
  String videoPath;
  int[] lightColor;

  VideoData(String videoPath, int[] lightColor) {
    this.videoPath = videoPath;
    this.lightColor = lightColor;
  }
}

void settings() {
  // Set to fullscreen on the second display
  fullScreen(P2D, secondDisplay);
}

void setup() {
  String[] ports = Serial.list();
  if (ports.length > 0) {
    myPort = new Serial(this, ports[0], 9600);
    myPort.bufferUntil('\n');
    serialReady = true;
    println("Serial port opened: " + ports[0]);
  } else {
    println("No serial ports available. Check connections.");
    exit();
  }

  videoMap = new HashMap<String, VideoData>();
  loadHardcodedData();

  println("Video paths initialized");

  // Set a flag indicating setup is complete
  setupComplete = true;
}

void draw() {
  background(0);

  if (isPlaying) {
    drawVideoState();
  } else if (waitingForRemoval) {
    drawWaitingState();
  } else {
    drawIdleState();
  }
}

void drawVideoState() {
  if (currentMovie != null) {
    if (currentMovie.available()) {
      currentMovie.read();
      image(currentMovie, 0, 0, width, height); // Draw the current frame
    }

    // Check if the movie has reached the end
    if (currentMovie.time() >= currentMovie.duration() - 0.1 && !currentMovie.isPlaying()) {
      println("Ending video");
      endVideoPlayback();
    }
  }
}

void drawWaitingState() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Remove tape and wait", width / 2, height / 2);

  // Check if 10 seconds have passed
  if (millis() - videoEndTime > 10000) {
    waitingForRemoval = false;
    myPort.bufferUntil('\n'); // Re-enable serial reading
    canScanNFC = true; // Allow NFC scanning again
    println("Ready for next tape");
  }
}

void drawIdleState() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Please put tape in tape recorder", width / 2, height / 2);
}

void serialEvent(Serial myPort) {
  try {
    myString = myPort.readStringUntil('\n');
    if (myString != null && canScanNFC) { // Check if NFC scanning is allowed
      myString = trim(myString);
      println("Received: " + myString);
      if (videoMap.containsKey(myString)) {
        if (!isPlaying) { // Check if a video is already playing
          playVideo(myString);
        } else {
          println("A video is already playing. Wait for it to finish.");
        }
      } else {
        println("No video mapped for identifier: " + myString);
      }
    }
  } catch (RuntimeException e) {
    println("Error reading from serial port: " + e.getMessage());
    e.printStackTrace(); // Print stack trace for detailed error analysis
  }
}

void playVideo(String identifier) {
  if (videoMap.containsKey(identifier)) {
    VideoData videoData = videoMap.get(identifier);
    currentMovie = new Movie(this, videoData.videoPath);
    currentMovie.play();
    currentMovie.pause(); // Ensure the movie is loaded
    isPlaying = true;
    println("Playing video for identifier: " + identifier);
    currentMovie.jump(0); // Jump to the start of the video
    currentMovie.play();
    currentMovie.speed(1); // Ensure normal speed playback
    setLighting(videoData.lightColor); // Set lighting color
    println("Current time after jump: " + currentMovie.time());
    println("Duration of video: " + currentMovie.duration());
  } else {
    println("No video found for identifier: " + identifier);
  }
}

void endVideoPlayback() {
  if (isPlaying) {
    isPlaying = false;
    currentMovie.stop();
    videoEndTime = millis();
    waitingForRemoval = true;
    canScanNFC = false; // Disable NFC scanning during waiting state
    println("Video finished playing");
  } else {
    println("endVideoPlayback called when no video was playing.");
  }
}

void loadHardcodedData() {
  videoMap.put("04 EA E1 04 BC 2A 81", new VideoData("Sutamentu Di Catibu No Subtitles.mp4", new int[]{255, 0, 0}));
  videoMap.put("04 FD EB 04 BC 2A 81", new VideoData("SinjaHorta.mp4", new int[]{255, 165, 0}));
  videoMap.put("04 AE F5 22 B7 2A 81", new VideoData("AjoZusternan.mp4", new int[]{255, 165, 0}));
  // Add additional hardcoded mappings as needed
}

void setLighting(int[] rgb) {
  // Placeholder for setting lighting color
  println("Setting lighting color to: " + rgb[0] + ", " + rgb[1] + ", " + rgb[2]);
}
