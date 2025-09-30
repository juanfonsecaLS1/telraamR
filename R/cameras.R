  #' Read all Telraam cameras
  #'
  #' @description
  #' Retrieves all camera data from the Telraam API, optionally using cached responses.
  #'
  #' @param mytoken Character string. Telraam API authentication token. If not set, uses value from environment.
  #' @param usecache Logical. If TRUE, uses cached API response if available (default: TRUE).
  #'
  #' @return Data frame containing all Telraam cameras and their metadata.
  #' @export
  #'
  #'
  #' @examples
  #' \dontrun{
  #' read_telraam_cameras()
  #' }
read_telraam_cameras <- function(mytoken = get_telraam_token(),
                                 usecache = T) {
  if (exists("telraamcameras",
    envir = cacheEnv
  ) && usecache) {
    return(get("telraamcameras",
      envir = cacheEnv
    ))
  }


  # Call preparation
  headers <- c("X-Api-Key" = mytoken)

  res <- httr::VERB("GET",
    url = "https://telraam-api.net/v1/cameras",
    httr::add_headers(headers)
  )

  my_response <- rjson::fromJSON(
    httr::content(res,
    "text",
    encoding = "UTF-8"
  ))

  # Processing response
  if (my_response$message != "ok") {
    stop("Response returned a non ok message")
  }

  my_cameras <- data.frame(do.call(
    rbind,
    lapply(
      my_response$cameras,
      rbind
    )
  ))
  my_cameras_df <- my_cameras |>
    tidyr::unnest(cols = dplyr::everything()) |>
    dplyr::mutate(
      dplyr::across(dplyr::starts_with("time"), lubridate::ymd_hms),
      dplyr::across(dplyr::ends_with("data_package"), lubridate::ymd_hms)
    )

  assign("telraamcameras", my_cameras_df, envir = cacheEnv)

  return(my_cameras_df)
}
