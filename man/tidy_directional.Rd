% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/card_directions.R
\name{tidy_directional}
\alias{tidy_directional}
\title{Directional traffic data in a tidy format}
\usage{
tidy_directional(data)
}
\arguments{
\item{data}{a \code{data.frame} with telraam traffic data}
}
\value{
a long format \code{data.frame} with cardinal road directions
}
\description{
Directional traffic data in a tidy format
}
\examples{
\dontrun{

data <- read_telraam_traffic(9000003890,
  time_start = "2023-03-25 07:00:00",
  time_end = "2023-03-30 07:00:00"
)

tidy_directional(data)
}

}
