#' Get hourly traffic report
#'
#' Function as an interface for the traffic API call
#'
#' @param id the segment (or instance) identifier in question (can be found in the address of the segment from the Telraam website
#' @param report can only be "per-hour", resulting in hourly aggregated traffic
#' @param time_start The beginning of the requested time interval
#' @param time_end The end of the requested time interval (note: the time interval is closed-open, so the end time is not included anymore in the request
#' @param mytoken the authentication token, if not previously set with the \code{set_TelraamToken} function
#' @param tz timezone, by default the system timezone
#'
#' @importFrom httr VERB
#' @importFrom httr add_headers
#' @importFrom httr content
#' @importFrom rjson fromJSON
#' @importFrom lubridate ymd_hms
#' @importFrom lubridate `tz<-`
#'
#'
#'
#' @return data.frame with traffic data
#' @export
#'
#' @examples
#' read_Telraam_traffic(9000003890,time_start = "2023-03-28 07:00:00",time_end = "2023-03-30 07:00:00")
read_Telraam_traffic = function(id,
                                report = c("per-hour"),
                                time_start,
                                time_end,
                                tz = Sys.timezone(),
                                mytoken = Sys.getenv('telraam')
                                ){
  # Arguments check
  report = match.arg(report)
  tz = match.arg(tz,choices = OlsonNames())


  time_start = ymd_hms(time_start,tz=tz)
  time_end = ymd_hms(time_end,tz=tz)

  # Dates check
  if (is.na(time_start)){
    stop("Stard date is not in the correct format i.e. YYYY-MM-DD H:M:S")
  }

  if (is.na(time_end)){
    stop("Stard date is not in the correct format i.e. YYYY-MM-DD H:M:S")
  }

  ## Time conversion into UTC
  if (tz!="UTC"){
    tz(time_start) = "UTC"
    tz(time_end) = "UTC"
  }


  ## Time difference check


  # Call preparation




  headers = c('X-Api-Key' = mytoken)

  body = paste0('{\r\n
         \"level\": \"segments\",
         \r\n  \"format\": \"',report,'\",
         \r\n  \"id\": \"',id,'\",
         \r\n  \"time_start\": \"',time_start,'Z,\",
         \r\n  \"time_end\": \"',time_end,'Z\"
         \r\n}')

  # API call
  res = httr::VERB("POST",
                   url = "https://telraam-api.net/v1/reports/traffic",
                   body = body,
                   add_headers(headers))

  my_response = fromJSON(content(res,
                                 'text',
                                 encoding = "UTF-8"))


  # Processing response

  ## Check
  mycols = sapply(my_response$report[[1]], length) == 1

  # Speed data is not included
  omitcols = c(names(mycols[!mycols]), "v85")

  # Extract only traffic data
  my_report = lapply(my_response$report,
                     function(x) {
                       x[omitcols] = NULL
                       y = data.frame(x)
                       return(y)
                       }
                     )

  mydata = do.call(rbind, my_report)

  return(mydata)

}
