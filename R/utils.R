check_time_args <- function(time_start,
                            time_end,
                            tz
){

  time_start <- ymd_hms(time_start, tz = tz)
  time_end <- ymd_hms(time_end, tz = tz)

  # Dates check
  if (is.na(time_start)) {
    stop("Start date is not in the correct format i.e. YYYY-MM-DD H:M:S")
  }

  if (is.na(time_end)) {
    stop("Start date is not in the correct format i.e. YYYY-MM-DD H:M:S")
  }

  if (time_end > Sys.time()) {
    warning("End time is in the future. End time constained to current system time")
    time_end <- Sys.time()
  }

  ## Time conversion into UTC
  if (tz != "UTC") {
    tz(time_start) <- "UTC"
    tz(time_end) <- "UTC"
  }


  # Time difference check
  if (difftime(time_end, time_start, units = "days") > 90) {
    warning("Interval is longer than 3 months, end date was set to 90 days after the start date")
    time_end <- time_start + as.difftime(90, "days")
  }
  return(list(time_start,time_end))
}
