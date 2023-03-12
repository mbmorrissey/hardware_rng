# geiger_rng_gaussian.R
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
b<-""

# discard first datum (if the first once the hardware is powered
# it will be NA) 
while(a=="") a<-read.serialConnection(con)

#plot(NA,xlim=c(-2,2),ylim=c(-2,2))
#x<-seq(-1,1,length.out=200)
#lines(x,sqrt(1-x^2))
#lines(x,-sqrt(1-x^2))

# collect n unit gaussian random numbers
while(reads<n){

  # monitor for incoming serial data
  while(a==""){
    Sys.sleep(0.1) # seems overkill to monitor for input constantly
    a<-read.serialConnection(con)
  }
  while(b==""){
    Sys.sleep(0.1) # seems overkill to monitor for input constantly
    b<-read.serialConnection(con)
  }
  a<-as.numeric(a)
  b<-as.numeric(b)
  print(paste(a,b))
  reads<-reads+1
  z1<-sqrt(-2*log(a))*cos(2*pi*b)
  vals[reads]<-z1
  reads<-reads+1
  z2<-sqrt(-2*log(a))*sin(2*pi*b)
  vals[reads]<-z2
  a<-""
  b<-""
#  points(z1,z2)
  # add data to live plot
  v<-vals[which(vals>-4&vals<4)]
  h<-hist(v,breaks=seq(-4,4,by=0.5),main="")
  x<-seq(-5,5,length.out=60)
  lines(x,dnorm(x)*reads/2)
  text(0.78,max(h$counts)*1.05,xpd=TRUE,paste("n: ",reads,sep=""),adj=0)
}

# generate final plot of example data
png("../figures/uniform_rng_example.png",height=480,width=480)
hist(vals, breaks=seq(0,1,by=0.05),main="",
   xlab="value",ylab="count",xaxt='n',border="lightgray")
lines(0:1,rep(50,2))
axis(side=1,seq(0,1,by=0.1))
dev.off()
