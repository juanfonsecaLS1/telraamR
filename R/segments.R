  #' Obtain Telraam segments as an sf object
  #'
  #' @description
  #' Retrieves all Telraam segments as a spatial (sf) object, optionally using cached API responses.
  #'
  #' @param mytoken Character string. Telraam API authentication token. If not set, uses value from environment.
  #' @param usecache Logical. If TRUE, uses cached API response if available (default: TRUE).
  #'
  #' @return An sf object containing all Telraam segments with their IDs and geometry.
  #' @export
  #'
  #'
  #' @examples
  #' \dontrun{
  #' read_telraam_segments()
  #' }
read_telraam_segments <- function(mytoken = get_telraam_token(),
                                  usecache = T) {
  if (exists("telraamsegments", envir = cacheEnv) &&
    usecache) {
    return(get("telraamsegments", envir = cacheEnv))
  }

  # Call preparation
  headers <- c("X-Api-Key" = mytoken)

  res <-
    httr::VERB("GET", url = "https://telraam-api.net/v1/segments/all", httr::add_headers(headers))

  my_response <- geojsonsf::geojson_sf(
    httr::content(res,
      "text",
      encoding = "UTF-8"
    ),
    expand_geometries = TRUE
  )


  # this is to suppress the warning produced by the use of the st_crs<- function
  # Warning: st_crs<- : replacing crs does not reproject data; use st_transform for that
  suppressWarnings(sf::st_crs(my_response) <- "EPSG:31370")

  my_segments <- sf::st_transform(my_response, crs = 4326)

  assign("telraamsegments", my_segments, envir = cacheEnv)

  return(my_segments)
}
