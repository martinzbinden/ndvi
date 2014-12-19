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
library(gdalUtils)

imgpath <- "img/w140925nir/3_dsm_ortho/2_mosaic/"
imgprefix <- "transparent"
onebandfiles <- list.files(imgpath, pattern=glob2rx(paste(imgprefix, "*.tif", sep="")), full.names = T)
vrtfile <- "out/multiband.vrt"
multiband <- "out/multiband.tif"


gdalbuildvrt(gdalfile = onebandfiles, 
            output.vrt = vrtfile,
            separate = T)

mosaic_rasters(gdalfile = vrtfile, dst_dataset = multiband)
gdalinfo(multiband)

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

