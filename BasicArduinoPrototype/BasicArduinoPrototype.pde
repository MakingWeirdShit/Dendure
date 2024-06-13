import processing.serial.Serial;
import processing.video.*;

Serial myPort;
Movie cardMovie;
Movie tagMovie;
Movie currentMovie;
boolean isPlaying = false;
String myString = "";

void setup() {
  size(720, 1280);
  frameRate(25);

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');

  // Initialize videos
  cardMovie = new Movie(this, "SutamentuDiCatibu.mp4");
  tagMovie = new Movie(this, "DiaDiLibertat.mp4");

  // Ensure movies are loaded by briefly playing and pausing them
  cardMovie.play();
  cardMovie.pause();
  println("Loaded video CARD with duration: " + cardMovie.duration());

  tagMovie.play();
  tagMovie.pause();
  println("Loaded video TAG with duration: " + tagMovie.duration());

  println("Video paths initialized");
}

void draw() {
  if (isPlaying && currentMovie != null) {
    displayVideo(currentMovie);
  } else {
    background(255, 0, 0); // Draw background only if no video is playing
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
      if (myString.equals("CARD")) {
        playVideo("CARD");
      } else if (myString.equals("TAG")) {
        playVideo("TAG");
      } else {
        println("No video mapped for identifier: " + myString);
      }
    }
  }
  
  
}

void playVideo(String identifier) {
  if (identifier.equals("CARD")) {
    currentMovie = cardMovie;
  } else if (identifier.equals("TAG")) {
    currentMovie = tagMovie;
  } else {
    println("No video found for identifier: " + identifier);
    return;
  }

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
  
}
