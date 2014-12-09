##purpose: calc NDVI index from red and nir geotiff



##load package
library(spgrass6)

# intialize GRASS (if not run from inside grass shell)
# initGRASS(gisBase ='/gis/grass', 
#           location = 'LV03', 
#           mapset = 'martinz')
# G <- gmeta6()

execGRASS("g.mlist", parameters = list(type = "rast"))





##import 
execGRASS("r.in.gdal", parameters=list(input="img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group2.tif", output="red", band=1))
execGRASS("r.in.gdal", parameters=list(input="img/w140925nir/3_dsm_ortho/2_mosaic/transparent_w140925nir_mosaic_group5.tif", output="nir", band=1))


##calculate and export ndvi
execGRASS("r.mapcalculator", amap="nir", bmap="red", outfile="ndvi_test", formula="1.00 * (A-B)/(A+B)") ## 1.00 needed to create FLOAT raster (instead of integer)
execGRASS("r.colors", map="ndvi_test",color="ndvi")
execGRASS("r.out.gdal", input="ndvi_test", format="GTiff",output="out/ndvi_test.tif")

## analyse result
ndvi <- readRAST6(c("ndvi_test"), cat=F, ignore.stderr=TRUE, plugin=NULL)
read
image(ndvi)
title("ndvi index")
summary(ndvi$ndvi)
table(ndvi$ndvi)

library(classInt)
t1 <- classIntervals(ndvi$ndvi.mapset, n=5, style="fisher")
print(t1)

