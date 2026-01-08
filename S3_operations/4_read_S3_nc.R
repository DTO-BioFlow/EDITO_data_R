# ---- Load libraries ----
library(stars)
library(terra)

# ---- Public URL of the NetCDF ----
# Replace this with your actual public URL
nc_url <- "https://minio.dive.edito.eu/oidc-willemboone/random_raster.nc"

# ---- Read NetCDF directly ----
# stars can read NetCDF files directly from a URL
raster <- read_stars(nc_url)

# ---- Check the raster ----
print(raster)
plot(raster)  # quick visualization

# ---- Access metadata ----
attr(raster, "units")
attr(raster, "description")