#' Saves an Authentication Token for the telraam API
#'
#' @param token a \code{string} with the token
#'
#' @return TRUE if token correctly set
#' @export
#'
#' @examples
#'
#' mytoken = "ivRgw7ZAGFedfwIdASezecdnETZDsdETB4Bqv3pbs5X8JDNnt1pQtpxDmpR6as2k"
#' set_TelraamToken(mytoken)
#'
set_TelraamToken = function(token) {
  if (is.null(token)) {
    stop("No token provided")
  }
  return(Sys.setenv(telraam = token))
}

