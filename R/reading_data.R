#' Get hourly traffic report
#'
#' Function as an interface for the traffic API call
#'
#' @param id the segment (or instance) identifier in question (can be found in the address of the segment from the Telraam website)
#' @param report one of "per-hour" or "per-quarter", if "per-quarter" is selected, an Advanced API token should be provided resulting in hourly aggregated traffic
#' @param time_start The beginning of the requested time interval
#' @param time_end The end of the requested time interval (note: the time interval is closed-open, so the end time is not included anymore in the request
#' @param mytoken the authentication token, if not previously set with `usethis::edit_r_environ()` or the \code{set_telraamToken} function
#' @param tz timezone, by default the value from `Sys.timezone()` in your machine.
#'   If the provided time zone is affected by daylight saving time, the conversion of the time might result in `NA` values
#'   for the datetime when the clocks change.
#'
#' @param include_speed logical, if car speed distribution included in the final data, \code{FALSE} as default
#'
#' @importFrom lubridate ymd_hms hour wday `tz<-`
#'
#'
#'
#' @return data.frame with traffic data
#' @export
#'
#' @examples
#' \dontrun{
#' # Setting up the PAT Method 1 (Recommended):
#' # 1. Run the following line
#' usethis::edit_r_environ()
#'
#' # 2. Add the following line:
#' telraam <- "your token goes here"
#' # 3. Restart your R session
#'
#' # Setting up the PAT Method 2:
#' my_token <- readLines(con = "mytoken.txt", warn = FALSE)
#'
#' # Using the function
#' read_telraam_traffic(9000003890,
#'   time_start = "2023-03-25 07:00:00",
#'   time_end = "2023-03-30 07:00:00"
#' )
#'
#' read_telraam_traffic(9000003890,
#'   time_start = "2023-03-25 07:00:00",
#'   time_end = "2023-03-30 07:00:00",
#'   include_speed = TRUE
#' )
#' }
read_telraam_traffic <- function(id,
                                 report = c("per-hour","per-quarter"),
                                 time_start,
                                 time_end,
                                 tz = Sys.timezone(),
                                 mytoken = get_telraam_token(),
                                 include_speed = FALSE) {
  # Arguments check
  report <- match.arg(report)

  if (report == "per-quarter") {
    warning("per-quarter data requires a token for the advance API! \n the request might fail if you do not provide one")
    base_url = "https://telraam-api.net/advanced/reports/traffic"
  } else {
    base_url = "https://telraam-api.net/v1/reports/traffic"
  }

  tz <- match.arg(tz, choices = OlsonNames())

  checked_times <- check_time_args(time_start,time_end,tz)

  time_start <- paste0(checked_times[[1]],"Z")
  time_end <- paste0(checked_times[[2]],"Z")

  # Building the request

  req <- httr2::request( base_url ) |>
    httr2::req_headers_redacted(`X-Api-Key` = mytoken) |>
    httr2::req_body_json(
      list(
        level = "segments",
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

  if ( status != 200)  {
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

    mydata_speed <- do.call(rbind, my_speed)
    mydata <- cbind(mydata, mydata_speed)
  }

  ## Adds columns for date, day of the week and hour
  mydata$datetime <- ymd_hms(mydata$date)
  tz(mydata$datetime) <- tz
  mydata$timezone <- tz

  mydata$date <- as.Date(mydata$datetime)
  mydata$day <- wday(mydata$datetime, week_start = 1)
  mydata$hr <- hour(mydata$datetime)

  return(mydata)
}


