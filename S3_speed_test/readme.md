# Data Access Benchmark – S3 Files

## Setup

- R packages: arrow, dplyr, lubridate, stars (for NetCDF)
- Bucket path: https://minio.dive.edito.eu/oidc-willemboone/PLET/
- Files tested: assessment\_data.csv, assessment\_data.nc, assessment\_data.parquet



This document summarizes the performance of reading different file types (CSV, NetCDF, and Parquet) from the S3 bucket `oidc-willemboone` on `https://minio.dive.edito.eu` using R.



## Benchmark Results



| File Type   | Connection Time (s) | Open/Path Resolution (s) | Read Time (s) | Total Time (s) | Notes                                                                                                                                                                                            |
| ----------- | ------------------- | ------------------------ | ------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **CSV**     | 0.15                | 0.13                     | 20.38         | 20.67          | CSV streamed via `arrow::read\_csv\_arrow`. Only reading one column (`period`) still slow due to full CSV scan.                                                                                    |
| **NetCDF**  | 0.08                | –                        | –             | –              | Requires local copy for non-raster GDAL-compatible files. Cannot be read directly via Arrow; reading via `stars` only works for raster-conform NetCDF. Local copy introduces extra I/O overhead. |
| **Parquet** | 0.15                | 0.002                    | 1.09          | 1.19           | Columnar Parquet read directly from S3 using `arrow::read\_parquet`. Supports selective column reading (e.g., `period`) for faster access.                                                        |



