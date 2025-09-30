
#' Check and process time arguments for Telraam API requests
#'
#' @description
#' Validates and processes start and end time arguments, ensuring correct format, timezone conversion, and interval constraints for Telraam API queries.
#'
#' @param time_start Character string. Start date-time in format "YYYY-MM-DD HH:MM:SS".
#' @param time_end Character string. End date-time in format "YYYY-MM-DD HH:MM:SS".
#' @param tz Character string. Timezone name (e.g., "UTC", "Europe/London").
#'
#' @return List containing processed start and end POSIXct date-times in UTC.
#' @examples
#' \dontrun{
#' check_time_args("2023-01-01 00:00:00",
#'                 "2023-01-10 00:00:00",
#'                 "Europe/London")
#' }
check_time_args <- function(time_start,
                            time_end,
                            tz
){
  time_start <- lubridate::ymd_hms(time_start, tz = tz)
  time_end <- lubridate::ymd_hms(time_end, tz = tz)

  # Dates check
  if (is.na(time_start)) {
    stop("Start date is not in the correct format i.e. YYYY-MM-DD H:M:S")
  }
  if (is.na(time_end)) {
    stop("End date is not in the correct format i.e. YYYY-MM-DD H:M:S")
  }
  if (time_end > Sys.time()) {
    warning("End time is in the future. End time constrained to current system time")
    time_end <- Sys.time()
  }
  ## Time conversion into UTC
  if (tz != "UTC") {
    lubridate::tz(time_start) <- "UTC"
    lubridate::tz(time_end) <- "UTC"
  }
  # Time difference check
  if (difftime(time_end, time_start, units = "days") > 90) {
    warning("Interval is longer than 3 months, end date was set to 90 days after the start date")
    time_end <- time_start + as.difftime(90, "days")
  }
  return(list(time_start, time_end))
}
