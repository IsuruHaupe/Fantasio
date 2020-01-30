plot.segments.chr <- function(byROHfile=FALSE, fileOrSubmaps, unit = "cM", chr, list_id, regions, color2="green4", build=37)
{
  if(length(list_id) > 20 )
    list_id <- list_id[seq_len(20)]
  
  l <- unit.plot.chr(file = fileOrSubmaps, unit, byROHfile = byROHfile) 
  pos1   <- l$pos1
  pos2   <- l$pos2
  myxlab <- l$myxlab
  coeff  <- l$coeff
  
  #special cases for chromosomes when genetic maps starts after 10 Mb
  start <- 0
  if (unit=="cM"){
    if( (chr==13) || (chr==14) || (chr==15)){
      start <- -20
    } else if ((chr==21) || (chr==22)) {
      start <- -15
    }
  } 
  
  end <- lengthChromosome(chr,unit, build)/coeff
  
  
  #empty plot
  y_max <- length(list_id)+1
  mar.default <- c(5,4,4,2) + 0.1
  par(mar = mar.default + c(0, y_max/2.5, 0, 0)) 
  
  plot(x <- c(start,end), y <- c(0,y_max), 
       type="n", yaxt="n", ylab="", xlab=myxlab, 
       main=paste("HBDsegments on chromosome ",chr,sep=""))

  axis(2, at = (seq_along(list_id))+0.25, list_id, col.ticks=0, las=2) 
  
  #treating regions option
  if(!is.null(regions)){
    if (nrow(regions)>0) {       
      for (i in seq_len(nrow(regions))) {
        polygon(x = regions[i,c("start","end","end","start")]/coeff,
                y = c(0.75,0.75,y_max,y_max), col=color2, border=color2, lwd=2)
      }
    }
  }
  
  #paint the chromosome
  paintCytobands(chr,units=unit,pos=c(0,0.5), build=build, orientation="h",legend = FALSE, length.out = end)
  
  #draw the HBDsegments
  # tmp <- strsplit(list_id, "_")
  # list_id <- sapply(tmp, function(i) i[2])
  
  # for (j in seq_along(list_id)){
  #  if(byROHfile)
  #  {
  #    toplot <- fileOrSubmaps[fileOrSubmaps$IID==list_id[j],]
  #  }else{
  #    toplot <- fileOrSubmaps[fileOrSubmaps$individual==list_id[j],]
  #  }
  #  
  #  
  #  if (nrow(toplot) > 0) {
  #     for (k in seq_len(nrow(toplot))) {
  #      polygon( x  = c(toplot[k,pos1],toplot[k,pos2],toplot[k,pos2],toplot[k,pos1])/coeff,
  #               y  = c(j,j,j+0.5,j+0.5),
  #               col=ifelse(byROHfile, color(toplot$PHE[k]), color(toplot$status[k])),
  #               lwd=1)
  #    }
  #  }
  # }

  for (j in seq_along(list_id)){ # parcourt tous les individus...
    if(byROHfile) {
      toplot <- fileOrSubmaps[ unique.ids( fileOrSubmaps$FID, fileOrSubmaps$IID) %in% list_id[j], ]
    } else {
      toplot <- fileOrSubmaps[ unique.ids( fileOrSubmaps$family, fileOrSubmaps$individual) %in% list_id[j], ]
    }

    for (k in seq_len(nrow(toplot))) { # !! seq_len permet de gérer le cas toplot = vide (pas de segment HBD sur ce chr)
      polygon( x  = c(toplot[k,pos1],toplot[k,pos2],toplot[k,pos2],toplot[k,pos1])/coeff,
               y  = c(j,j,j+0.5,j+0.5),
               col=ifelse(byROHfile, color(toplot$PHE[k]), color(toplot$status[k])),
               lwd=1)
    }
  }
  
  
}
