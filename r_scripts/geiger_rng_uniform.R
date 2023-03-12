# geiger_rng_uniform.R
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

# collect n uniform random numbers
while(reads<n){

  # monitor for incoming serial data
  while(a==""){
    Sys.sleep(0.1) # seems overkill to monitor for input constantly
    a<-read.serialConnection(con)
  }
  a<-as.numeric(a)
  print(a)
  reads<-reads+1
  vals[reads]<-a
  a<-""

  # add data to live plot
  h<-hist(vals, breaks=seq(0,1,by=0.05),main="",xaxt='n')
  axis(side=1,seq(0,1,by=0.05))
  text(0.78,max(h$counts)*1.05,xpd=TRUE,paste("n: ",reads,sep=""),adj=0)
}

# generate final plot of example data
pdf("../figures/uniform_rng_example.pdf",height=5,width=5)
hist(vals, breaks=seq(0,1,by=0.05),main="",
   xlab="value",ylab="count",xaxt='n',border="lightgray")
lines(0:1,rep(50,2))
axis(side=1,seq(0,1,by=0.1))
dev.off()
