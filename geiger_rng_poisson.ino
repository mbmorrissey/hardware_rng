
// geiger_rng_poisson.ino
// Michael Morrissey
// 12 March 2023
// part of a light-hearted project to use a DIY Geiger counter kit to
// make a hardware random number generator
// https://github.com/mbmorrissey/hardware_rng

// interrupt pin
#define geigerPin 2

// interval length in ms
int interval = 5000;

// the number of pulses accumulated in each interval
long pulses;

void setup() {
  Serial.begin(9600);
}

void loop() {

  // set pulse counter to zero and start timer
  pulses = 0;
  long start = millis();

  // count pulses via interrupt for the interval
  attachInterrupt(digitalPinToInterrupt(geigerPin),count_pulses, FALLING);
  while(millis() < start+interval){}
  detachInterrupt(digitalPinToInterrupt(geigerPin));

  // report pulse count over serial
  Serial.println(pulses);
}

void count_pulses(){
  pulses++;
}
