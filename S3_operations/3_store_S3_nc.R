# ---- Setup ----
set.seed(123)

library(terra)
library(stars)
library(paws)

# Create raster
values <- sample(0:10, size = 100, replace = TRUE)

r <- rast(
  nrows = 10,
  ncols = 10,
  xmin = 0,
  xmax = 10,
  ymin = 50,
  ymax = 60,
  crs = "EPSG:4326"
)
values(r) <- values

# Convert to stars object
raster <- st_as_stars(r)
names(raster) <- "random_raster"
attr(raster, "units") <- "arbitrary"
attr(raster, "description") <- "Random 10x10 raster covering 0–10E, 50–60N"

# ---- Save as NetCDF ----
nc_file <- "random_raster.nc"
write_stars(raster, nc_file, options = c("COMPRESS=4"))  # optional compression

# ---- Configure MinIO/S3 ----
Sys.setenv(
  AWS_ACCESS_KEY_ID = "",
  AWS_SECRET_ACCESS_KEY = "",
  AWS_DEFAULT_REGION = "waw3-1",
  AWS_SESSION_TOKEN = "",
  AWS_S3_ENDPOINT = "minio.dive.edito.eu"
)

# Initialize S3 client
minio <- paws::s3(
  config = list(
    credentials = list(
      creds = list(
        access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
        secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
        session_token = Sys.getenv("AWS_SESSION_TOKEN")
      )
    ),
    endpoint = paste0("https://", Sys.getenv("AWS_S3_ENDPOINT")),
    region = Sys.getenv("AWS_DEFAULT_REGION")
  )
)

# ---- Upload NetCDF to S3 ----
bucket_name <- "oidc-willemboone"  # Replace with your bucket
object_key <- "random_raster.nc"   # Name in S3

minio$put_object(
  Bucket = bucket_name,
  Key = object_key,
  Body = nc_file
)

# Verify
print(paste("Uploaded", nc_file, "to bucket", bucket_name))
