

#' Obtain the telraam segments as a sf object
#'
#' @inheritParams read_telraam_traffic
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
read_telraam_segments = function(mytoken = get_telraam_token()
                                 ){

  # Call preparation
  headers = c('X-Api-Key' = mytoken)

  res <- VERB("GET", url = "https://telraam-api.net/v1/segments/all", add_headers(headers))

  my_response = geojson_sf(content(res,
                                   'text',
                                   encoding = "UTF-8"),
                           expand_geometries = TRUE)

  st_crs(my_response) = "EPSG:31370"

  my_segments = st_transform(my_response,crs = 3857)

  return(my_segments)
}



