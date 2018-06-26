#distance_mean <- function(submaps, submaps_num)
#{
#  sapply(1:22, function(i) max(submaps@atlas[[submaps_num]]@map$distance[submaps@atlas[[submaps_num]]@map$chr == i]))
#}

HFLOD.manhattan.plot <- function(submaps, regions, unit="cM")
{
  if(submaps@bySegments && class(submaps@atlas[[1]])[1] == "snps.matrix")
    stop("Cannot plot by segments for snps.matrix object")
  
  if(submaps@bySegments)
  {
    HFLOD <- submaps@HFLOD
    pos <- submaps@atlas[[1]]@map$dist
    chromosome <- submaps@bedmatrix@snps$chr[submaps@atlas[[1]]@submap]
  }
  #HFLOD=read.table(paste(folder,"/HFLOD.temp.txt",sep=""),h=T)
  #pos <- sapply(submaps@atlas, function(hh) hh@submap)
  #pos <- unique(unlist(pos))
  else{
    HFLOD <- submaps@HFLOD
    pos <- as.data.frame(table(unlist(sapply(submaps@atlas, function(hh) hh@submap))), stringsAsFactors=FALSE)
    pos <- as.numeric(pos$Var1)
    pos <- sort(pos)
    chromosome <- submaps@bedmatrix@snps$chr[pos]
    pos <- submaps@bedmatrix@snps$dist[pos]
  }
  
  
  
  #if (regions!="empty") {myreg=read.table(regions,h=F); color2="green4"}
  if(missing(regions)) 
    myreg <- NULL
  else { 
    myreg  <- regions
    color2 <- "green4"
    myreg$start = regions$start/1e6
    myref$end   = regions$end/1e6
  }
  
  if(unit == "cM"){
    myxlab <- "Position (cM)"
    coeff  <- 1
  }else{
    myxlab <- "Position (Mb)"
    coeff  <- 1e6
    pos    <- pos/1e6
  }
  
  

  newout   <- NULL
  axis_mp  <- NULL
  chr_pos  <- c(5) 
  myreg_mp <- NULL
  
  if(!missing(regions)){
    myreg_chr <-  myreg[which(myreg$CHR == c),]
    if(nrow(myreg_chr) > 0){
      for(i in 1:nrow(myreg_chr)){
        #polygon(myreg_chr[i,c(2,3,3,2)],c(rep(-1,2),rep(ymax+1,2)),col=color2,border=color2,lwd=2)
        polygon(x = myreg_chr[i,c("start","end","end","start")], 
                y = c(rep(-1,2),rep(ymax+1,2)), 
                col    = color2,
                border = color2,
                lwd    = 2)
        
        myreg_mp = rbind(myreg_mp,max(c(0,axis_mp))+10+myreg_chr$start[i]+myreg_chr$end[i])
      }
    }
  }

  #toplot_pos   <- pos[which(h@atlas[[1]]@map$chr == chr)]
  
  #2)Manhattan plot
  #ymax <- max(3.3,max(HFLOD$HFLOD))
  
  ymax <- max(3.3,max(HFLOD[,1]))
  mycol <- rep(c("cadetblue2",8),11)
  
  
  for(i in 1:22)
  {
    pos_chr <- pos[chromosome==i]
    chr_pos <- c(chr_pos, pos_chr[length(pos_chr)])
    #chr_pos <- c(chr_pos, pos_chr[length(pos_chr)]+chr_pos[i-1])
    axis_mp <- c(axis_mp, max(c(0,axis_mp), na.rm = TRUE)+10+pos_chr)
  }
  chr_pos <- cumsum(chr_pos+10)
  
  #chr_pos <- c(chr_pos, max(c(0,axis_mp))+5)
  
  
  #chr_pos <- sapply(1:length(submaps@atlas), function(i) distance_mean(submaps, i))
  #chr_pos <- sapply(1:nrow(chr_pos), function(i) mean(chr_pos[i,]))
  #chr_pos <- cumsum(chr_pos+5)
  
  #png(file=paste(folder,"/HFLOD.",distance,".png",sep=""), width = 2400, height = 800,pointsize=24)
  #plot (axis_mp,HFLOD,pch=16,ylim=c(0,ymax),xlab="",ylab="HFLOD",cex.lab=1.4,cex.axis=1.5,col=mycol[HFLOD$CHR],xaxt="n",cex=0.75)
  plot (axis_mp,HFLOD[,1],pch=16,ylim=c(0,ymax),xlab="",ylab="HFLOD",cex.lab=1.4,cex.axis=1.5,col=mycol[chromosome],xaxt="n",cex=0.75)
                                                                                                        
  if (!missing(regions)) {
    for (i in 1:nrow(myreg_mp)) {
      polygon(x = myreg_mp[i,c("start","end","end","start")]/coeff,
              y = c(rep(-10,2),rep(max(HFLOD[,1])+10,2)),
              col=color2,
              border=color2,
              lwd=2)
    }
    points(axis_mp,HFLOD[,1],pch=16,col=mycol[chromosome],cex=0.75)
  }
  #lines(axis_mp,HFLOD$MA_HFLOD,col=2,lwd=3)
  lines(axis_mp,HFLOD[,2],col=2,lwd=2)
  
  for(i in 1:length(unique(chromosome))) {
    abline(v=chr_pos[i],col="grey",lwd=2)
    axis(1,at=chr_pos[i],i,col.ticks=0,cex.axis=1.5)
  }
  abline(v=chr_pos[23],col="grey",lwd=2)
  
  for (i in 1:3) 
    abline(h=i,col="grey",lwd=1,lty=2)
  
  
  abline(h=3.3,col="grey",lwd=2) 
  
  
  
}