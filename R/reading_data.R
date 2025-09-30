  #' Get hourly or quarter-hourly traffic report from Telraam API
  #'
  #' @description
  #' Interface to the Telraam traffic API, retrieving traffic data for a specified segment or instance and time interval.
  #'
  #' @param id Integer. Segment or instance identifier (see Telraam website for details).
  #' @param report Character. Either "per-hour" or "per-quarter". "per-quarter" requires an Advanced API token and returns 15-minute aggregated data.
  #' @param time_start Character string. Start date-time in format "YYYY-MM-DD HH:MM:SS".
  #' @param time_end Character string. End date-time in format "YYYY-MM-DD HH:MM:SS" (exclusive).
  #' @param mytoken Character string. Authentication token. If not set, uses value from environment.
  #' @param tz Character string. Timezone name (default: value from `Sys.timezone()`).
  #' @param include_speed Logical. If TRUE, includes car speed distribution in the returned data (default: FALSE).
  #' @param level Character. Either "segments" or "instances" (default: "segments").
  #'
  #'
  #' @return Data frame with traffic data for the specified segment/instance and time interval.
  #' @export
  #'
  #' @examples
  #' \dontrun{
  #' # Set up the token (see set_telraam_token)
  #' mytoken <- "your_token_here"
  #' read_telraam_traffic(9000003890,
  #'                      time_start = "2023-03-25 07:00:00",
  #'                      time_end = "2023-03-30 07:00:00")
  #' read_telraam_traffic(9000003890,
  #'                      time_start = "2023-03-25 07:00:00",
  #'                      time_end = "2023-03-30 07:00:00",
  #'                      include_speed = TRUE)
  #' read_telraam_traffic(12031,
  #'                      time_start = "2025-07-20 00:00:00",
  #'                      time_end = "2025-07-28 00:00:00",
  #'                      level = "instances",
  #'                      report = "per-quarter")
  #' }
read_telraam_traffic <- function(id,
                                 level = c("segments","instances"),
                                 report = c("per-hour","per-quarter"),
                                 time_start,
                                 time_end,
                                 tz = Sys.timezone(),
                                 mytoken = get_telraam_token(),
                                 include_speed = FALSE) {
  # Arguments check
  report <- match.arg(report)
  level <- match.arg(level)

  if (report == "per-quarter") {
    warning("per-quarter data requires a token for the advance API! \n the request might fail if you do not provide one")
    base_url <- "https://telraam-api.net/advanced/reports/traffic"
  } else {
    base_url <- "https://telraam-api.net/v1/reports/traffic"
  }

  tz <- match.arg(tz, choices = OlsonNames())

  checked_times <- check_time_args(time_start, time_end, tz)

  time_start <- paste0(format(checked_times[[1]], "%Y-%m-%d %H:%M:%S"),"Z")
  time_end <- paste0(format(checked_times[[2]], "%Y-%m-%d %H:%M:%S"),"Z")

  # Building the request

  req <- httr2::request( base_url ) |>
    httr2::req_headers_redacted(`X-Api-Key` = mytoken) |>
    httr2::req_body_json(
      list(
        level = level,
        format = report,
        id = id,
        time_start = time_start,
        time_end = time_end
      )
    )


  # Performing the POST request

  resp <- req |> httr2::req_perform()

  # checking the response status
  status <- resp |> httr2::resp_status()

  if (status != 200) {
    stop("Response returned a non ok message")
  }

  # Extracting the body of the request
  my_response <- resp |> httr2::resp_body_json()

  ## Check
  mycols <- vapply(my_response$report[[1]], FUN = length, numeric(1)) == 1

  # Speed data is not included
  omitcols <- c(names(mycols[!mycols]), "v85")

  # Extract only traffic data
  my_report <- lapply(
    my_response$report,
    function(x) {
      x[omitcols] <- NULL
      y <- data.frame(x)
      return(y)
    }
  )

  mydata <- do.call(rbind, my_report)

  if (include_speed) {
    my_speed <- lapply(
      my_response$report,
      function(x) {
        y <- x[["car_speed_hist_0to120plus"]]
        z <- data.frame(t(y))
        names(z) <- paste("car speed ", c(paste0("[", seq(0, 115, by = 5), ",", seq(5, 120, by = 5), ")"), "120+"))
        return(z)
      }
    )

    mydata_speed <- do.call(rbind, lapply(my_speed,unlist))


    mydata <- cbind(mydata, mydata_speed)
  }

  ## Adds columns for date, day of the week and hour
  mydata$datetime <- lubridate::ymd_hms(mydata$date)
  lubridate::tz(mydata$datetime) <- tz
  mydata$timezone <- tz

  mydata$date <- as.Date(mydata$datetime)
  mydata$day <- lubridate::wday(mydata$datetime, week_start = 1)
  mydata$hr <- lubridate::hour(mydata$datetime)

  return(mydata)
}


