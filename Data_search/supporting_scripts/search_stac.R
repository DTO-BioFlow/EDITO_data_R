library(httr)
library(jsonlite)
library(lubridate)

`%||%` <- function(a, b) if (!is.null(a)) a else b

collection_url <- "https://api.dive.edito.eu/data/collections"

get_collection_url <- function() {
  collection_url
}

# ---- helpers -------------------------------------------------------------

get_items_url <- function(links) {
  for (l in links) {
    if (identical(l$rel, "items")) return(l$href)
  }
  NULL
}

get_next_link <- function(links) {
  for (l in links) {
    if (identical(l$rel, "next")) return(l$href)
  }
  NULL
}

fetch_all_items <- function(items_url, verbose = 0) {
  
  all_items <- list()
  next_url <- items_url
  page <- 1
  
  while (!is.null(next_url)) {
    
    if (verbose > 1) {
      cat(sprintf("[%s] | fetching page %d\n", now(), page))
    }
    
    res <- GET(
      next_url,
      config = config(http_version = 1.1),
      user_agent("R (httr)")
    )
    stop_for_status(res)
    
    payload <- content(res, as = "parsed", simplifyVector = FALSE)
    
    if (!is.null(payload$features)) {
      all_items <- c(all_items, payload$features)
    }
    
    next_url <- get_next_link(payload$links)
    page <- page + 1
  }
  
  all_items
}

# ---- main search ----------------------------------------------------------

search_on_title <- function(title, collection = NULL, verbose = 0) {
  
  results <- list()
  item_counter <- 0
  
  res <- GET(
    collection_url,
    config = config(http_version = 1.1),
    user_agent("R (httr)")
  )
  stop_for_status(res)
  
  payload <- content(res, as = "parsed", simplifyVector = FALSE)
  collections <- payload$collections
  
  if (is.null(collections)) {
    stop("No collections found in STAC response")
  }
  
  if (!is.null(collection)) {
    collections <- Filter(function(c) c$id == collection, collections)
    if (length(collections) == 0) {
      stop(sprintf("Collection '%s' not found.", collection))
    }
  }
  
  total_collections <- length(collections)
  
  for (i in seq_along(collections)) {
    
    col <- collections[[i]]
    
    cat(sprintf(
      "[%s] | Collection %d/%d: %s\n",
      now(), i, total_collections, col$title %||% col$id
    ))
    
    items_url <- get_items_url(col$links)
    if (is.null(items_url)) {
      warning(sprintf("No items link for collection %s", col$id))
      next
    }
    
    items <- tryCatch(
      fetch_all_items(items_url, verbose),
      error = function(e) {
        warning(sprintf(
          "[%s] | Could not fetch items from %s: %s",
          now(), col$id, e$message
        ))
        NULL
      }
    )
    
    if (is.null(items)) next
    
    if (verbose > 0) {
      cat(sprintf("[%s] | scanning %d items...\n", now(), length(items)))
    }
    
    item_counter <- item_counter + length(items)
    
    for (item in items) {
      item_title <- item$properties$title %||% ""
      if (grepl(title, item_title, ignore.case = TRUE)) {
        if (verbose > 0) {
          cat(sprintf("[%s] | >>> found: %s\n", now(), item_title))
        }
        results <- append(results, list(item))
      }
    }
  }
  
  if (verbose > 0) {
    cat("###########\n# SUMMARY #\n###########\n")
    cat(sprintf("searched %d items\n", item_counter))
    cat(sprintf("found %d results\n", length(results)))
    for (r in results) {
      cat(sprintf("- %s\n", r$properties$title %||% "<no title>"))
    }
  }
  
  results
}
