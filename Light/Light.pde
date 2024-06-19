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
  int colorIntensity = (int)map(smoothedSum, 0, 0.05, 0, 255);
  colorIntensity = constrain(colorIntensity, 0, 255);
  
  // Set the background color based on the smoothed amplitude
  background(colorIntensity, 0, 0);
}


//code to still test

//import processing.sound.*;

// Global variables
//FFT fft;
//AudioIn in;
//float[] spectrum = new float[512];
//float smoothedSum = 0.0;
//float smoothingFactor = 0.9;
//float maxAmplitude = 0.0;
//float emphasisThreshold = 0.2; // Adjust this threshold as necessary
//float blendFactor = 0.0;
//float blendSmoothing = 0.1; // Adjust this value for smoother transitions

//void setup() {
//  size(800, 600); // Adjust the size as needed
//  initializeAudio();
//}

//void draw() {
//  analyzeAudio();
//  float sum = calculateSpectrumSum();
//  updateSmoothedSum(sum);
//  updateMaxAmplitude();
//  int colorIntensity = calculateColorIntensity();
//  updateBlendFactor();
//  int finalColor = calculateFinalColor(colorIntensity);
//  setBackgroundColor(finalColor);
//}

//// Initialize audio input and FFT
//void initializeAudio() {
//  fft = new FFT(this, spectrum.length);
//  in = new AudioIn(this, 0); // Use the default microphone input
//  in.start();
//  fft.input(in);
//}

//// Analyze the audio spectrum
//void analyzeAudio() {
//  fft.analyze(spectrum);
//}

//// Calculate the sum of the spectrum
//float calculateSpectrumSum() {
//  float sum = 0;
//  for (int i = 0; i < spectrum.length; i++) {
//    sum += spectrum[i];
//  }
//  return sum;
//}

//// Update the smoothed sum of the spectrum
//void updateSmoothedSum(float sum) {
//  smoothedSum = smoothingFactor * smoothedSum + (1 - smoothingFactor) * sum;
//}

//// Update the maximum amplitude for dynamic range adjustment
//void updateMaxAmplitude() {
//  if (smoothedSum > maxAmplitude) {
//    maxAmplitude = smoothedSum;
//  }
//  maxAmplitude *= 0.99;
//}

//// Calculate the color intensity based on the smoothed sum and max amplitude
//int calculateColorIntensity() {
//  int colorIntensity = (int) map(smoothedSum, 0, maxAmplitude, 0, 255);
//  return constrain(colorIntensity, 0, 255);
//}

//// Update the blend factor based on emphasis detection
//void updateBlendFactor() {
//  if (smoothedSum > emphasisThreshold * maxAmplitude) {
//    blendFactor = lerp(blendFactor, 1.0, blendSmoothing);
//  } else {
//    blendFactor = lerp(blendFactor, 0.0, blendSmoothing);
//  }
//}

//// Calculate the final color with emphasis effect
//int calculateFinalColor(int colorIntensity) {
//  int normalRed = colorIntensity;
//  int emphasizedRed = (int) (colorIntensity * 1.2); // More intense version of the same color
//  emphasizedRed = constrain(emphasizedRed, 0, 255);
//  float easedBlendFactor = easeInOutQuad(blendFactor);
//  return (int) lerp(normalRed, emphasizedRed, easedBlendFactor);
//}

//// Set the background color
//void setBackgroundColor(int finalColor) {
//  background(finalColor, 0, 0);
//}

//// Ease in-out quadratic function
//float easeInOutQuad(float t) {
//  return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
//}
