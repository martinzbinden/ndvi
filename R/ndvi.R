##purpose: calc NDVI index from red and nir geotiff

##load package
library(spgrass6)

# intialize GRASS (if not run from inside grass shell)
initGRASS(gisBase = '/usr/lib/grass70/',
  gisDbase ='/gis/grass', 
  location = 'LV03', 
  mapset = 'martinz', override=TRUE)
G <- gmeta6()


##prepare multiband raster from 5 uniband rasters
getwd()
setwd("img/w140925nir/3_dsm_ortho/2_mosaic/")
gdalbuildvrt -separate multiband.vrt transparent_w140925nir_mosaic_group*.tif
gdal_merge.py -o multiband.tif -separate my.vrt

##import and calc with GRASS GIS (requires GRASS 7)
ndvi.grass <- function() {
  #work in progress!
  execGRASS("r.in.gdal", parameters=list(input="img/w140925nir/3_dsm_ortho/2_mosaic/multiband.tif", output="multiband"))

  execGRASS("r.mapcalc",expression="ndvi_test=(1.00 * multiband.5 - multiband.2)/(multiband.5 + multiband.2)", flags="overwrite")
  #flags="overwrite")
  execGRASS("r.colors", map="ndvi_test", color="ndvi")
            
}

ndvi.grass()

ndvi.import()

execGRASS("r.in.gdal", parameters=list(input="img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group2.tif", output="red", band=1))
execGRASS("r.in.gdal", parameters=list(input="img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group5.tif", output="nir", band=1))

execGRASS("r.mapcalc",expression="ndvi_test=(1.00 * nir-red)/(nir+red)")
          #flags="overwrite")
execGRASS("r.colors", map="ndvi_test", color="ndvi")
#alternative color sheme
#execGRASS("r.colors", map="ndvi_test", rules="R/ndvi_colorrules.R")

outprefix = "test1/"
dir.create(paste("out/", outprefix,sep=""))

ndvi.tif <- function(rastermap) {
  execGRASS("r.out.gdal", 
            input=rastermap, 
            format="GTiff",
            output=paste("out/",outprefix,rastermap,".tif",sep=""))
}

ndvi.png <- function(rastermap) {
  execGRASS("d.mon", start="cairo", 
            output=paste("out/",outprefix,rastermap,".png",sep=""))
  execGRASS("d.rast", map=rastermap)
  execGRASS("d.legend", rast=rastermap)
  execGRASS("d.mon", stop="cairo")
}

ndvi.png("ndvi_test")


ndvi.mon <- function(rastermap) {
  execGRASS("d.mon", start="wx0")
  execGRASS("d.rast", map=rastermap)
  execGRASS("d.legend", rast=rastermap)
  #execGRASS("d.out.file", output=paste("out/",outprefix,rastermap,"_mon.tif",sep=""))
  execGRASS("d.mon", stop="wx0")
}



## analyse result
library(grid)
ndvi <- readRAST6("ndvi_test", cat=F, ignore.stderr=TRUE, plugin=NULL)
image(ndvi, col=rainbow(n = 10, start=0, end=1))
title("ndvi index")
summary(ndvi$ndvi_test)
summarize(ndvi$ndvi_test)



## calc with GDAL directly

ndvi.fixtif("img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group")


ndvi.fixtif <- function(filepath) {
  for (bandnr in c(1:5)){
    infile <- paste(filepath, bandnr, ".tif", sep="")
    outfile <- paste(dirname(filepath), "/band", bandnr, ".tif", sep="")
    command <- paste("gdal_translate -b 1 ", infile, " ", outfile, sep="")
    system(command)
  }
  outfile <- paste(dirname(filepath), "/multiband.tif ", sep="")
  command <- paste("gdal_merge.py -separate -o ", outfile, " ", dirname(filepath), "/band*.tif", sep="")
  system(command)
}

filepath <- "img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group"
#filepath <- "."
multibandfile <- paste(dirname(filepath), "/multiband.tif ", sep="")
ndvifile <- paste(dirname(filepath), "/ndvi.tif", sep="")
command <- paste("gdal_calc.py -A ", multibandfile, " -B ", multibandfile, " --A_band=5 --B_band=2  --outfile=", ndvifile, " --type=Float32  --calc='(1.00*A-B)/(A+B)'  --overwrite", sep="")
system(command)
command

execGRASS("r.in.gdal", parameters=list(input="img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group5.tif", output="nir", band=1))






# system("gdal_calc.py -A nirfile -B redfile  --outfile=ndvifile --type=Float32  --calc='1.00*(A-B)/(A+B)'  --overwrite")


ndvi.gdal <- function(filepath, redband, nirband) {
  nirfile <- paste(filepath, nirband, ".tif", sep="")
  redfile <- paste(filepath, redband, ".tif", sep="")
  ndvifile <- paste(dirname(filepath),"/ndvi_", basename(filepath), nirband, redband, ".tif", sep="")
  command <- paste("gdal_calc.py -A ", nirfile, " -B ", redfile, " --A_band=1 --B_band=1 --outfile=", ndvifile, " --type=Float32  --calc='1.00*(A-B)/(A+B)'  --overwrite", sep="")
  #system("gdal_calc.py -A nirfile -B redfile  --outfile=ndvifile --type=Float32  --calc='1.00*(A-B)/(A+B)'  --overwrite")
  system(command)
}

ndvi.gdal("img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group", 5, 2)

ndvi.gdal("img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group", 4, 2)

ndvi.gdal("img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group", 5, 1)


dirname("img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group3.tif")

bands <- list()
bands[[1]] <- c(2,5)
bands[[2]] <- c(1,5)
bands[[3]] <- c(2,4)
bands[[4]] <- c(2,3)
bands


