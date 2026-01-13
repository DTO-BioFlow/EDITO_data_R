# -----------------------------
# Full script to read Parquet from S3/MinIO
# File: PLET/assessment_data.parquet
# -----------------------------

library(arrow)
library(dplyr)
library(lubridate)

# ---- 0. Start timing ----
t0 <- Sys.time()

# ---- 1. Connect to S3 bucket ----
s3_fs <- s3_bucket(
  bucket = "oidc-willemboone",
  endpoint_override = "https://minio.dive.edito.eu"
)

t1 <- Sys.time()
print("connection time:")
print(t1 - t0)

# ---- 2. Open Parquet file on S3 ----
t2 <- Sys.time()

# Using Arrow dataset API directly from S3
parquet_file <- s3_fs$path("PLET/assessment_data.parquet")

t3 <- Sys.time()
print("file path resolution time:")
print(t3 - t2)

# ---- 3. Read Parquet into R ----
t4 <- Sys.time()

# read_parquet_arrow reads directly from S3
df <- read_parquet(parquet_file)

t5 <- Sys.time()
print("read time:")
print(t5 - t4)

# ---- 4. Optional: select only a column (like 'period') ----
# Uncomment if needed:
# df_period <- df %>% select(period)

# ---- 5. Total timing ----
print("total time:")
print(t5 - t0)
