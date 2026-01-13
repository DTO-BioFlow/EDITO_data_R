library(stars)
library(arrow)
library(dplyr)
library(lubridate)

t0 <- Sys.time()

# ---- 1. Connect to S3 bucket ----
s3_fs <- s3_bucket(
  bucket = "oidc-willemboone",
  endpoint_override = "https://minio.dive.edito.eu"
)

t1 <- Sys.time()
print("connection time:")
print(t1 - t0)

# ---- 2. Download NetCDF file from S3 to temp ----
t2 <- Sys.time()

s3_file <- s3_fs$OpenInputFile("PLET/assessment_data.nc")
buf <- s3_file$Read(s3_file$GetSize())
raw_bytes <- buf$as_vector()

tmp_nc <- tempfile(fileext = ".nc")
writeBin(raw_bytes, tmp_nc)

t3 <- Sys.time()
print("download time:")
print(t3 - t2)

# ---- 3. Read NetCDF with stars ----
t4 <- Sys.time()
x <- read_stars(tmp_nc)
t5 <- Sys.time()
print("open + read time:")
print(t5 - t4)

# ---- 4. Convert to tibble ----
t6 <- Sys.time()
df <- as_tibble(x)
t7 <- Sys.time()
print("to tibble time:")
print(t7 - t6)

print("total time:")
print(t7 - t0)
