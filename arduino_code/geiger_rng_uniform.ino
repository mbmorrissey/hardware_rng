// geiger_rng_uniform.ino
// Michael Morrissey
// 12 March 2023
// part of a light-hearted project to use a DIY Geiger counter kit to
// make a hardware random number generator
// https://github.com/mbmorrissey/hardware_rng

// interrupt pin
#define geigerPin 2

byte p=0;     // has a new pulse happened
byte n = 0;   // number of pulses accumulated toward triplets
long a;       // time of twice-previous, previous, and most recent pulses
long b;
long c;
long t;       // current time variable
float r;      // uniform random number

void setup() {
  Serial.begin(9600);
  delay(100);
  attachInterrupt(digitalPinToInterrupt(geigerPin),record_pulse, RISING);
}

void loop() {

  // if an interrupt has occurred, record the time and shift previous times
  if(p==1){
    t=micros();

    a = b;
    b = c;
    c = t;
    n++;
    p=0;
  }

  // every other pulse, we can use the triplet of the there previous times
  // to calculate an independent approximately uniform random number
  if(n>1){
    r = ((float)(b-a))/((float)(c-a));

    // print to serial with reasonable precision
    Serial.println(r,6);
    n=0;
  }

}

void record_pulse(){
  p++;
}

