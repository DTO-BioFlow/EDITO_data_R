# Data Search

## Install
Simply source the functions from github.
```source "https://github.com/DTO-BioFlow/EDITO_data_R/blob/main/Data_search/supporting_scripts/search_stac.R"```


## Functions

### search_on_title
Search STAC items whose title contains a given substring.
This function performs a client-side scan of one or more STAC collections and returns all items whose title property contains the provided search string (case-insensitive). Since the target STAC API does not support the /search endpoint, server-side filtering is unavailable and a full collection scan is required.


#### Args

* title [string]: Substring to search for within the item title field. The match is performed in a case-insensitive manner.
* collection [string, optional]: Identifier of a specific collection to search. If not provided, all available collections in the catalog are searched.
* verbose [int]: level of message logs. 0 is silent, 1 is with logs, 2 has extensive logs.





#### Returns

* Results [list of pystac items]: A list of STAC items whose title field contains the specified substring.





#### Examples 

Search all collections for items containing "koster" in their title:

```items = search_on_title("koster", verbose=1) ```



Search only within a specific collection:

```items = search\_on\_title("koster", collection="emodnet-biology")```

