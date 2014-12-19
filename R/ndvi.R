##purpose: calc NDVI index from red and nir geotiff

# load needed packages (be sure to have them installed)
library(gdalUtils)

#only for windows:
Sys.getenv("PATH")
Sys.setenv(PATH = paste(Sys.getenv("PATH"), "C:\gdalwin32-1.6\bin", sep=":"))

ndvi.gdal <- function(redfile, nirfile, ndvifile) {
  command <- paste("gdal_calc.py -A ", nirfile, " -B ", redfile, " --A_band=1 --B_band=1 --outfile=", ndvifile, " --type=Float32  --calc='1.00*(A-B)/(A+B)'  --overwrite", sep="")
  print(command)
  system(command)
}


ndvi.gdal("img/w140925nir/3_dsm_ortho/2_mosaic/band2.tif", "img/w140925nir/3_dsm_ortho/2_mosaic/band2.tif", "out_w140925nir")



  
  
