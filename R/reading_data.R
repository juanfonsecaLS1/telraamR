#' Get hourly traffic report
#'
#' Function as an interface for the traffic API call
#'
#' @param id the segment (or instance) identifier in question (can be found in the address of the segment from the Telraam website)
#' @param report can only be "per-hour", resulting in hourly aggregated traffic
#' @param time_start The beginning of the requested time interval
#' @param time_end The end of the requested time interval (note: the time interval is closed-open, so the end time is not included anymore in the request
#' @param mytoken the authentication token, if not previously set with the \code{set_TelraamToken} function
#' @param tz timezone, by default the system timezone
#' @param include_speed logical, if car speed distribution included in the final data, \code{FALSE} as default
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
#'
#'
#'
#'
#' \dontrun{
#' # Setting up the PAT Method 1 (Recommended):
#' # 1. Run the following line
#' usethis::edit_r_environ()
#'
#' # 2. Add a line as telraam = "your token goes here"
#' # 3. Restart your R session
#'
#' # Setting up the PAT Method 2:
#' my_token = readLines(con = "mytoken.txt",warn = FALSE)
#'
#'
#' read_telraam_traffic(9000003890,
#'                      time_start = "2023-03-25 07:00:00",
#'                      time_end = "2023-03-30 07:00:00")
#'
#' read_telraam_traffic(9000003890,
#'                      time_start = "2023-03-25 07:00:00",
#'                      time_end = "2023-03-30 07:00:00",
#'                      include_speed = TRUE)
#' }
read_telraam_traffic = function(id,
                                report = c("per-hour"),
                                time_start,
                                time_end,
                                tz = Sys.timezone(),
                                mytoken = get_Telraam_Token(),
                                include_speed = FALSE
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

  if (time_end>Sys.time()){
    warning("End time is in the future. End time constained to current system time")
    time_end = Sys.time()
  }

  ## Time conversion into UTC
  if (tz!="UTC"){
    tz(time_start) = "UTC"
    tz(time_end) = "UTC"
  }


  # Time difference check
  if (difftime(time_end,time_start,units = "days")>90){
    warning("Interval is longer than 3 months, end date was set to 90 days after the start date")
    time_end = time_start + as.difftime(90,"days")
  }


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
  res = VERB("POST",
             url = "https://telraam-api.net/v1/reports/traffic",
             body = body,
             add_headers(headers))

  my_response = fromJSON(content(res,
                                 'text',
                                 encoding = "UTF-8"))


  # Processing response
  if(my_response$message!="ok"){
    stop("Response returned a non ok message")
  }

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

  if(include_speed){
    my_speed = lapply(my_response$report,
                      function(x) {
                        y = x[["car_speed_hist_0to120plus"]]
                        z = data.frame(t(y))
                        names(z) = paste("car speed ",c(paste0("[",seq(0,115,by=5),",",seq(5,120,by=5),")"),"120+"))
                        return(z)
                      }
    )

    mydata_speed = do.call(rbind, my_speed)
    mydata = cbind(mydata,mydata_speed)
  }

  mydata$date = ymd_hms(mydata$date)

  return(mydata)
}
