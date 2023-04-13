telraamR
================

This package provides wrappers for Telraam API calls

## Instalation

For the instalation you need to have the \`remotes\`\` library.

``` r
install.packages("remotes")
```

Once `remotes` is available. The package can be installed using the
following code:

``` r
remotes::install_github("juanfonsecaLS1/telraamR")
```

To load the package:

``` r
library(telraamR)
```

## Set the Authentintication token

An authentication token is needed for using the Telraam API. If you do
not have one, you can obtain one by registering in Telraam
[here](https://www.telraam.net/en/register). Once you have obtained the
token, it can be set using the following line of code:

``` r
set_Telraam_Token("your token goes here")
```

**NOTE:** The token has to be set at the beginning of every session.
Alternatively, the authentication token can be provided as a parameter
of all functions of this package.

## Usage

### Traffic data

The hourly report for a single site can be obtained using the
`read_Telraam_traffic` function. The following code shows an example of
the use:

``` r
data = read_Telraam_traffic(9000003890,
                            time_start = "2023-03-25 07:00:00",
                            time_end = "2023-04-10 07:00:00",
                            report = "per-hour",
                            include_speed = FALSE)
```

The function returns a data set with the hourly traffic by vehicle type
and direction

If the `include_speed` is set as `TRUE`. The returned data frame will
include the binned speed distribution for cars

``` r
library(tidyverse)

data = read_Telraam_traffic(9000003890,
                            time_start = "2023-03-25 07:00:00",
                            time_end = "2023-04-10 07:00:00",
                            report = "per-hour",
                            include_speed = TRUE)



data |> select(date,starts_with("car speed"))
```
