##prepare multiband raster from 5 uniband rasters

imgpath <- "img/w140925nir/3_dsm_ortho/2_mosaic/"
imgprefix <- "transparent"
onebandfiles <- list.files(imgpath, pattern=glob2rx(paste(imgprefix, "*.tif", sep="")), full.names = T)
vrtfile <- "out/multiband.vrt"
multibandfile <- "out/multiband.tif"

gdalbuildvrt(gdalfile = onebandfiles, 
             output.vrt = vrtfile,
             separate = T)
mosaic_rasters(gdalfile = vrtfile, dst_dataset = multibandfile)
gdalinfo(multibandfile)
ndvifile <- "out/ndvi.tif"


ndvi.gdal_mb <- function(multibandfile, ndvifile, redband, nirband) {
  command <- paste("gdal_calc.py -A ", multibandfile, " -B ", multibandfile, " --A_band=",nirband, " --B_band=", redband, " --outfile=", ndvifile, " --type=Float32  --calc='1.00*(A-B)/(A+B)'  --overwrite", sep="")
  #system("gdal_calc.py -A nirfile -B redfile  --outfile=ndvifile --type=Float32  --calc='1.00*(A-B)/(A+B)'  --overwrite")
  print(command)
  system(command)
}
