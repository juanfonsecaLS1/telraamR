#' Read all cameras
#'
#' @inheritParams read_telraam_traffic
#' @param usecache `logical` used to store the API response in the cache of the package, `TRUE` as default
#'
#' @return a data frame with the data for all cameras in telraam
#' @export
#'
#' @importFrom httr VERB
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom tidyr unnest
#' @importFrom dplyr across
#' @importFrom dplyr everything
#' @importFrom dplyr mutate
#' @importFrom dplyr starts_with
#' @importFrom dplyr ends_with
#'
#' @examples
#' \dontrun{
#' read_telraam_cameras()
#' }
read_telraam_cameras <- function(mytoken = get_telraam_token(),
                                 usecache = T) {
  if (exists("telraamcameras",
    envir = cacheEnv
  ) & usecache) {
    return(get("telraamcameras",
      envir = cacheEnv
    ))
  }


  # Call preparation
  headers <- c("X-Api-Key" = mytoken)

  res <- VERB("GET",
    url = "https://telraam-api.net/v1/cameras",
    add_headers(headers)
  )

  my_response <- fromJSON(content(res,
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
    unnest(cols = everything()) |>
    mutate(
      across(starts_with("time"), ymd_hms),
      across(ends_with("data_package"), ymd_hms)
    )

  assign("telraamcameras", my_cameras_df, envir = cacheEnv)

  return(my_cameras_df)
}
