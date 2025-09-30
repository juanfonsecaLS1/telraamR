
#' Set the Telraam API authentication token
#'
#' @description
#' Stores the provided authentication token in the environment for use with Telraam API requests.
#'
#' @param token Character string. The Telraam API token to be saved.
#'
#' @return Logical TRUE if the token is correctly set, otherwise an error is thrown.
#' @export
#'
#' @examples
#' mytoken <- "ivRgw7ZAGFedfwIdASezecdnETZDsdETB4Bqv3pbs5X8JDNnt1pQtpxDmpR6as2k"
#' \dontrun{
#' set_telraam_token(mytoken)
#' }
set_telraam_token <- function(token) {
  if (is.null(token) || !is.character(token)) {
    stop("No valid token provided. Token must be a character string.")
  }
  Sys.setenv(telraam = token)
  return(TRUE)
}

#' Get the Telraam API authentication token
#'
#' @description
#' Retrieves the Telraam API token from the environment.
#'
#' @return Character string containing the Telraam API token. Throws an error if not set.
#' @export
#'
#' @examples
#' \dontrun{
#' # After setting the token with set_telraam_token()
#' get_telraam_token()
#' }
get_telraam_token <- function() {
  PAT <- Sys.getenv("telraam")
  if (PAT == "") {
    stop("Telraam token has not been set. Use set_telraam_token().")
  }
  return(PAT)
}
