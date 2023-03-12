# geiger_rng_poisson.R
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
n <- 1000
counts<-array(dim=maxCounts)
reads <- 0

# discard anything already in the incoming serial buffer
a<-read.serialConnection(con)
a<-""

while(reads<n){

  # wait for data to come in
  while(a==""){
    Sys.sleep(0.1) # seems overkill to monitor for input constantly
    a<-read.serialConnection(con)
  }
  a<-as.numeric(a)
  print(a)
  reads<-reads+1
  counts[reads]<-a
  a<-""

  # live plot as data accumulate
  m<-max(counts,na.rm=TRUE)
  h<-hist(counts, breaks=seq(-0.5,m+0.5,by=1),main="",xaxt='n')
  axis(side=1,0:m)
  text(m*0.78,max(h$counts),paste("n: ",reads,sep=""),adj=0)
  text(m*0.78,max(h$counts)*0.9,paste("mean: ",round(
                    mean(counts,na.rm=TRUE),2),sep=""),adj=0)
  text(m*0.78,max(h$counts)*0.8,paste("variance: ",round(
                    var(counts,na.rm=TRUE),2),sep=""),adj=0)
}

# generate final plot of example data
pdf("./poisson_rng_example.pdf",height=5,width=5
m<-max(counts,na.rm=TRUE)
hist(counts, breaks=seq(-0.5,m+0.5,by=1),main="",xaxt='n')
axis(side=1,0:m)
dev.off()

