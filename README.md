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
usethis::edit_r_environ()
```

Save your token into the `.Renviron` file that is opened when you
execute the command above and restart your session. You can check to see
if the token has been loaded as follows:

The authentication token can also be provided in the `mytoken` argument
of functions that call the Telraam API.

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

``` r
data |> head()
```

    ##   instance_id segment_id                     date interval    uptime    heavy
    ## 1          -1 9000003890 2023-03-25T07:00:00.000Z   hourly 0.7622222 48.54227
    ## 2          -1 9000003890 2023-03-25T08:00:00.000Z   hourly 0.7638889 41.89091
    ## 3          -1 9000003890 2023-03-25T09:00:00.000Z   hourly 0.7377778 78.61446
    ## 4          -1 9000003890 2023-03-25T10:00:00.000Z   hourly 0.6547222 61.09461
    ## 5          -1 9000003890 2023-03-25T11:00:00.000Z   hourly 0.6850000 75.91241
    ## 6          -1 9000003890 2023-03-25T12:00:00.000Z   hourly 0.6072222 72.46112
    ##         car      bike pedestrian heavy_lft heavy_rgt  car_lft  car_rgt
    ## 1  276.8222  10.49563   1.311953  23.61516  24.92711 107.5802 169.2420
    ## 2  489.6000  28.80000   5.236364  17.01818  24.87273 226.4727 263.1273
    ## 3  826.8072  32.53012   5.421687  33.88554  44.72892 363.2530 463.5542
    ## 4  696.4786 106.91557   3.054731  22.91048  38.18413 343.6572 352.8214
    ## 5  945.9854  49.63504  23.357664  30.65693  45.25547 421.8978 524.0876
    ## 6 1007.8683  65.87374   3.293687  18.11528  54.34584 535.2242 472.6441
    ##    bike_lft  bike_rgt pedestrian_lft pedestrian_rgt direction        timezone
    ## 1  5.247813  5.247813       1.311953       0.000000         1 Europe/Brussels
    ## 2 11.781818 17.018182       2.618182       2.618182         1 Europe/Brussels
    ## 3  9.487952 23.042169       0.000000       5.421687         1 Europe/Brussels
    ## 4 44.293594 62.621977       1.527365       1.527365         1 Europe/Brussels
    ## 5 27.737226 21.897810       4.379562      18.978102         1 Europe/Brussels
    ## 6 42.817932 23.055810       0.000000       3.293687         1 Europe/Brussels

If the `include_speed` is set as `TRUE`. The returned data frame will
include the binned speed distribution for cars

``` r
library(tidyverse)
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.1     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.1     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
    ## ✔ purrr     1.0.1     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
data = read_Telraam_traffic(9000003890,
                            time_start = "2023-03-25 07:00:00",
                            time_end = "2023-04-10 07:00:00",
                            report = "per-hour",
                            include_speed = TRUE)



data |> select(date,starts_with("car speed")) |> str()
```

    ## 'data.frame':    376 obs. of  26 variables:
    ##  $ date                : chr  "2023-03-25T07:00:00.000Z" "2023-03-25T08:00:00.000Z" "2023-03-25T09:00:00.000Z" "2023-03-25T10:00:00.000Z" ...
    ##  $ car speed  [0,5)    : num  0.948 0.535 2.131 1.974 0.772 ...
    ##  $ car speed  [5,10)   : num  0.474 1.07 0.328 2.193 0.463 ...
    ##  $ car speed  [10,15)  : num  3.79 2.94 1.64 2.19 1.08 ...
    ##  $ car speed  [15,20)  : num  2.844 1.337 0.984 2.193 0.772 ...
    ##  $ car speed  [20,25)  : num  1.896 0.802 1.148 3.509 4.167 ...
    ##  $ car speed  [25,30)  : num  2.37 2.41 4.92 7.46 11.73 ...
    ##  $ car speed  [30,35)  : num  5.69 10.43 12.13 13.38 16.67 ...
    ##  $ car speed  [35,40)  : num  19.9 12.8 18.4 16.2 22.1 ...
    ##  $ car speed  [40,45)  : num  18 19.3 18.2 18.2 18.4 ...
    ##  $ car speed  [45,50)  : num  17.5 14.4 14.3 11.2 11.9 ...
    ##  $ car speed  [50,55)  : num  11.37 11.76 8.52 6.14 5.71 ...
    ##  $ car speed  [55,60)  : num  4.27 6.68 4.75 4.82 2.78 ...
    ##  $ car speed  [60,65)  : num  2.844 3.743 3.115 3.289 0.772 ...
    ##  $ car speed  [65,70)  : num  1.896 0.802 3.115 1.974 0.926 ...
    ##  $ car speed  [70,75)  : num  1.896 2.674 1.311 1.535 0.463 ...
    ##  $ car speed  [75,80)  : num  2.844 1.872 1.475 0.439 0.309 ...
    ##  $ car speed  [80,85)  : num  0 0.535 0.82 0.219 0.154 ...
    ##  $ car speed  [85,90)  : num  0 1.07 0.492 0.439 0.309 ...
    ##  $ car speed  [90,95)  : num  0.474 1.604 0.492 0.877 0.154 ...
    ##  $ car speed  [95,100) : num  0 0.802 0.328 0.219 0.309 ...
    ##  $ car speed  [100,105): num  0.474 1.07 0.328 0 0 ...
    ##  $ car speed  [105,110): num  0 0.267 0.656 0 0.154 ...
    ##  $ car speed  [110,115): num  0 0 0.164 0.219 0 ...
    ##  $ car speed  [115,120): num  0 0 0.164 0.219 0 ...
    ##  $ car speed  120+     : num  0.474 1.07 0.164 1.096 0 ...
