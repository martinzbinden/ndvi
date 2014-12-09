##setup
##prerequisites: r-base r-cran-vr r-cran-rodbc r-cran-xml (apt-get etc.)
pkgs <- c('akima', 'spgrass6', 'RODBC', 'VR', 'gstat')
install.packages(pkgs, dependencies=TRUE, type='source') 
