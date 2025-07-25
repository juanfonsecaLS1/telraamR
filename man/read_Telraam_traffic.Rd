% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reading_data.R
\name{read_telraam_traffic}
\alias{read_telraam_traffic}
\title{Get hourly traffic report}
\usage{
read_telraam_traffic(
  id,
  report = c("per-hour", "per-quarter"),
  time_start,
  time_end,
  tz = Sys.timezone(),
  mytoken = get_telraam_token(),
  include_speed = FALSE
)
}
\arguments{
\item{id}{the segment (or instance) identifier in question (can be found in the address of the segment from the Telraam website)}

\item{report}{one of "per-hour" or "per-quarter", if "per-quarter" is selected, an Advanced API token should be provided resulting in hourly aggregated traffic}

\item{time_start}{The beginning of the requested time interval}

\item{time_end}{The end of the requested time interval (note: the time interval is closed-open, so the end time is not included anymore in the request}

\item{tz}{timezone, by default the value from \code{Sys.timezone()} in your machine.
If the provided time zone is affected by daylight saving time, the conversion of the time might result in \code{NA} values
for the datetime when the clocks change.}

\item{mytoken}{the authentication token, if not previously set with \code{usethis::edit_r_environ()} or the \code{set_telraamToken} function}

\item{include_speed}{logical, if car speed distribution included in the final data, \code{FALSE} as default}
}
\value{
data.frame with traffic data
}
\description{
Function as an interface for the traffic API call
}
\examples{
\dontrun{
# Setting up the PAT Method 1 (Recommended):
# 1. Run the following line
usethis::edit_r_environ()

# 2. Add the following line:
telraam <- "your token goes here"
# 3. Restart your R session

# Setting up the PAT Method 2:
my_token <- readLines(con = "mytoken.txt", warn = FALSE)

# Using the function
read_telraam_traffic(9000003890,
  time_start = "2023-03-25 07:00:00",
  time_end = "2023-03-30 07:00:00"
)

read_telraam_traffic(9000003890,
  time_start = "2023-03-25 07:00:00",
  time_end = "2023-03-30 07:00:00",
  include_speed = TRUE
)
}
}
