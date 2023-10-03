#' Get the cardinal directions for the segments
#'
#' @param mysegments an `sf` object with the segments
#'
#' @return a `data.frame` with the correspondence of left `lft` and
#' right `rgt`directions to cardinal directions of the road
#' @export
#'
#' @importFrom stplanr line_bearing
#'
#'
#' @examples
#' \dontrun{
#' anysegment <- my_segments |>
#'   filter(oidn == 9000003890)
#'
#' get_cardinal_dirs(anysegment)
#' }
get_cardinal_dirs <- function(mysegments) {
  bearings <- line_bearing(mysegments)

  # Ensuring values are between 0 and 360
  bearings[bearings < 0] <- bearings[bearings < 0] + 360
  bearings[bearings > 360] <- bearings[bearings > 360] - 360

  # Calculating opposite
  bearings_op <- bearings + 180
  bearings_op[bearings_op > 360] <- bearings_op[bearings_op > 360] - 360

  breaks <- seq(-22.5, 360 + 22.5, by = 45)
  labels <- c(
    "Northbound",
    "Northeastbound",
    "Eastbound",
    "Southeastbound",
    "Southbound",
    "Southwestbound",
    "Westbound",
    "Northwestbound",
    "Northbound"
  )
  df_directions <- data.frame(
    lft = cut(
      bearings,
      breaks,
      labels,
      include.lowest = TRUE,
      ordered_result = F
    ),
    rgt = cut(
      bearings_op,
      breaks,
      labels,
      include.lowest = TRUE,
      ordered_result = F
    )
  )



  result <- mysegments |>
    st_drop_geometry() |>
    cbind(df_directions)

  return(result)
}

#' Directional traffic data in a tidy format
#'
#' @param data a `data.frame` with telraam traffic data
#'
#' @return a long format `data.frame` with cardinal road directions
#' @export
#'
#' @importFrom tidyr pivot_longer all_of
#' @importFrom sf st_drop_geometry
#' @importFrom stringr str_extract
#' @importFrom dplyr mutate select left_join
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#'
#' data <- read_telraam_traffic(9000003890,
#'   time_start = "2023-03-25 07:00:00",
#'   time_end = "2023-03-30 07:00:00"
#' )
#'
#' tidy_directional(data)
#' }
#'
tidy_directional <- function(data) {
  oids <- unique(data$segment_id)

  all_segments <- read_telraam_segments()
  sel_segments <- all_segments[all_segments$oidn %in% oids, ]

  lfrg2card <- get_cardinal_dirs(sel_segments) |>
    pivot_longer(
      cols = -all_of("oidn"),
      names_to = "view_direction",
      values_to = "road_dir"
    ) |>
    mutate(road_dir = as.character(.data$road_dir))


  sel_cols <- c(
    "instance_id",
    "direction",
    "interval",
    "heavy",
    "car",
    "bike",
    "pedestrian",
    names(data)[grepl("speed", names(data))]
  )

  dir_data <- data[, !(names(data) %in% sel_cols)]

  dir_cols <- names(dir_data)[grepl(pattern = "(lft|rgt)", names(dir_data))]

  long_dir <- dir_data |>
    pivot_longer( # names_pattern = ".*\\_(lft|rgt)",
      cols = all_of(dir_cols),
      values_to = "flow"
    ) |>
    mutate(
      view_direction = str_extract(string = .data$name, pattern = "(lft|rgt)"),
      type = str_extract(string = .data$name, pattern = "(heavy|car|bike|pedestrian)")
    ) |>
    left_join(lfrg2card, by = c("segment_id" = "oidn", "view_direction")) |>
    select(all_of(
      c(
        "segment_id",
        "uptime",
        "timezone",
        "date",
        "datetime",
        "day",
        "hr",
        "road_dir",
        "type",
        "flow"
      )
    ))

  return(long_dir)
}
