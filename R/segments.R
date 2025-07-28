#' Obtain the telraam segments as a sf object
#'
#' @inheritParams read_telraam_traffic
#' @param usecache `logical` used to store the API response in the cache of the package, `TRUE` as default
#'
#' @return a sf object with all segments with the id
#' @export
#'
#' @importFrom httr VERB
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom geojsonsf geojson_sf
#' @importFrom sf `st_crs<-`
#' @importFrom sf st_transform
#'
#'
#'
#' @examples
#' \dontrun{
#' read_telraam_segments()
#' }
#'
read_telraam_segments <- function(mytoken = get_telraam_token(),
                                  usecache = T) {
  if (exists("telraamsegments", envir = cacheEnv) &
    usecache) {
    return(get("telraamsegments", envir = cacheEnv))
  }

  # Call preparation
  headers <- c("X-Api-Key" = mytoken)

  res <-
    VERB("GET", url = "https://telraam-api.net/v1/segments/all", add_headers(headers))

  my_response <- geojson_sf(
    content(res,
      "text",
      encoding = "UTF-8"
    ),
    expand_geometries = TRUE
  )


  # this is to suppress the warning produced by the use of the st_crs<- function
  # Warning: st_crs<- : replacing crs does not reproject data; use st_transform for that
  suppressWarnings(st_crs(my_response) <- "EPSG:31370")

  my_segments <- st_transform(my_response, crs = 4326)

  assign("telraamsegments", my_segments, envir = cacheEnv)

  return(my_segments)
}
