import processing.serial.*;
import processing.video.*;
import java.util.HashMap;

Serial myPort;
HashMap<String, Movie> videoMap;
Movie currentMovie;
boolean isPlaying = false;
String myString = "";
int secondDisplay = 2;

void settings() {
  // Set to fullscreen on the second display
  fullScreen(P2D, secondDisplay);
}
void setup() {
  
  frameRate(25);

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');

  videoMap = new HashMap<String, Movie>();

  // Initialize videos and add to the map
  videoMap.put("CARD", new Movie(this, "Sutamentu Di Catibu No Subtitles.mp4"));
  videoMap.put("TAG", new Movie(this, "DiaDiLibertat.mp4"));

  // Ensure movies are loaded by briefly playing and pausing them
  for (String key : videoMap.keySet()) {
    Movie movie = videoMap.get(key);
    movie.play();
    movie.pause();
    println("Loaded video for identifier: " + key + " with duration: " + movie.duration());
  }

  println("Video paths initialized");
}

void draw() {
  if (isPlaying && currentMovie != null) {
    displayVideo(currentMovie);
  } else {
    background(0, 0, 0); // Draw background only if no video is playing
  }
}

void displayVideo(Movie movie) {
  if (movie.available()) {
    movie.read();
    image(movie, 0, 0, width, height); // Draw the current frame
  }

  // Check if the movie has reached the end
  if (movie.time() >= movie.duration()) {
    isPlaying = false;
    movie.stop();
    background(0); // Reset to background
    myPort.bufferUntil('\n'); // Re-enable serial reading
    println("Video finished playing");
  }
}

void serialEvent(Serial myPort) {
  if (!isPlaying) { // Only read serial if no video is playing
    myString = myPort.readStringUntil('\n');
    if (myString != null) {
      myString = trim(myString);
      println("Received: " + myString);
      if (videoMap.containsKey(myString)) {
        playVideo(myString);
      } else {
        println("No video mapped for identifier: " + myString);
      }
    }
  }
}

void playVideo(String identifier) {
  if (videoMap.containsKey(identifier)) {
    currentMovie = videoMap.get(identifier);
    isPlaying = true;
    println("Playing video for identifier: " + identifier);
    if (currentMovie.isPlaying()) {
      currentMovie.stop();
    }
    currentMovie.jump(0); // Jump to the start of the video
    currentMovie.play();
    currentMovie.speed(1); // Ensure normal speed playback
    println("Current time after jump: " + currentMovie.time());
    println("Duration of video: " + currentMovie.duration());
  } else {
    println("No video found for identifier: " + identifier);
  }
}
