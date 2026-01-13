library(arrow)
library(dplyr)
library(lubridate)

t0 = Sys.time()

# ---- 1. Connect to S3 bucket ----
s3_fs <- arrow::s3_bucket(
  bucket = "oidc-willemboone",
  endpoint_override = "https://minio.dive.edito.eu"
)

t1 = Sys.time()

print("connection time: ")
print(t1-t0)

t2 = Sys.time()

# ---- 2. Open the CSV file on S3 ----
s3_file <- s3_fs$OpenInputFile("PLET/assessment_data.csv")

t3 = Sys.time()

print("open time: ")
print(t3-t2)

t4 = Sys.time()
# ---- 3. Read CSV directly with Arrow ----
# Only read the 'period' column
df <- read_csv_arrow(
  s3_file,
)

t5 = Sys.time()
print("read time: ")
print(t5-t4)

print("total time: ")
print(t5-t0)


