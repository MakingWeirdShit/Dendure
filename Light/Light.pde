import processing.sound.*;
import processing.sound.FFT;

FFT fft;
AudioIn in;
float[] spectrum = new float[512];
float smoothedAmplitude = 0.0;
float smoothedSum = 0.0;
float smoothingFactor = 0.9; // Adjust this value between 0.0 and 1.0 for different smoothing effects

void setup() {
  fullScreen();
  frameRate(25);
  background(0);
  
  // Create the FFT analyzer
  fft = new FFT(this, spectrum.length);
  
  // Create the AudioIn object
  in = new AudioIn(this, 0);
  
  // Start listening to the microphone
  in.start();
  
  // Patch the AudioIn
  fft.input(in);
}

void draw() {
  // Analyze the audio data
  fft.analyze(spectrum);
  
  // Calculate the average amplitude
  float sum = 0;
  for (int i = 0; i < spectrum.length; i++) {
    sum += spectrum[i];
  }
  
  
  
  // Smooth the amplitude using a simple low-pass filter
  
  smoothedSum = smoothingFactor * smoothedSum + (1 - smoothingFactor) * sum;
  
  println(smoothedSum);
  // Map the smoothed amplitude to a color intensity
  int colorIntensity = (int)map(smoothedSum, 0, 0.40, 0, 255);
  colorIntensity = constrain(colorIntensity, 0, 255);
  
  // Set the background color based on the smoothed amplitude
  background(colorIntensity, 0, 0);
}
