# geiger_rng_seed.R
# Michael Morrissey
# 12 March 2023
# part of a light-hearted project to use a DIY Geiger counter kit to
# make a hardware random number generator
# https://github.com/mbmorrissey/hardware_rng

library(serial)

# see what ports are available
listPorts()

# will need to figure out from listPorts() what port
# the arduino is on
con <- serialConnection(name = "geiger",port = "cu.usbmodem1101"
       ,mode = "9600,n,8,2"
       ,newline = 1 )

open(con)

# number of random numbers to collect
n<-1000
vals<-array(dim=n)
reads <- 0

# inital read to clear input in case multiple data have 
# already been sent
a<-read.serialConnection(con)
a<-""

# discard first datum (if the first once the hardware is powered
# it will be NA) 
while(a=="") a<-read.serialConnection(con)

while(reads<n){
  d<-array(dim=3)
  m<-0
  while(m<3){
    a<-""
    while(a==""){
      Sys.sleep(0.1) # seems overkill to monitor for input constantly
      a<-read.serialConnection(con)
    }
    print(paste(reads,a))
    m<-m+1
    d[m]<-as.numeric(a)
  }
  reads<-reads+1
  vals[reads]<-round(d[1]*1000,0)*1e6 + round(d[2]*1000,0)*1e3 + round(d[3]*1000,0)
  print(vals[reads])

  h<-hist(vals,breaks=seq(0,1e9,by=1e5))
  text(5e11,max(h$counts)*1.05,xpd=TRUE,paste("n: ",reads,sep=""),adj=0)
}

