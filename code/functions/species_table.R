#' Species table
#'
#' Create table showing important facts about a species.
#'
#' @param x \code{character} scientific name of species.
#'
#' @param species_data \code{data.frame} containing the scientific name and
#'   threat status information about the species. The argument to \code{data}
#'   must have the columns \code{"species_scientific_name"},
#'   \code{"species_scientific_name"}, \code{"iucn_threat_status"},
#'   \code{"national_threat_status"}, and \code{"qld_threat_status"}.
#'
#' @param record_data \code{sf} object containing the records for the species.
#'   This object must have the following fields:
#'   \code{"species_scientific_name"}, \code{"season"}, and \code{"grid_id}.
#'
#' @return \code{data.frame}.
species_table <- function(x, species_data, record_data) {
  # Initialization
  record_data <- as.data.frame(record_data) %>% dplyr::select(-geometry)
  spp_index <- which(species_data$species_scientific_name == x)
  spp_data <- record_data[record_data$species_scientific_name == x, ]
  spp_type <- species_data$distribution[spp_index]
  ## determine starting years for records and checklists
  checklists_starting_year <-
    species_data$checklists_starting_year[spp_index]
  records_starting_year <- species_data$records_starting_year[spp_index]
  ## set up grid
  if (spp_type == "land") {
    study_area_cells <- grid_data$id[grid_data$type == "land"]
  } else if (spp_type == "marine") {
    study_area_cells <- grid_data$id[grid_data$type == "marine"]
  } else {
    study_area_cells <- grid_data$id
  }
  # Main processing
  ## iucn threat status
  iucn_threat_status <- paste("_IUCN:_",
                              species_data$iucn_threat_status[spp_index])
  ## national threat status
  national_threat_status <- paste("_National:_",
                                  species_data$national_threat_status[spp_index])
  ## qld threat status
  qld_threat_status <- paste("_Queensland:_",
                             species_data$qld_threat_status[spp_index])
  ## ebird records
  ebird_records <- paste("_eBird records:_",
    formatC(as.integer(sum(spp_data$year >= records_starting_year,
                           na.rm = TRUE)), big.mark = ","))
  ## atlas squares
  if (sum(spp_data$year >= records_starting_year) > 0) {
    spp_cells <- spp_data %>%
                 filter(year >= records_starting_year,
                        grid_id %in% study_area_cells) %>%
                 `[[`("grid_id")
    atlas_squares <- paste("_Atlas squares:_",
                           length(unique(na.omit(spp_cells))))
  } else {
    atlas_squares <- "_Atlas squares:_ 0"
  }
  ## reporting rate
  record_data <- record_data[
    record_data$is_checklist &
    record_data$year >= checklists_starting_year &
    record_data$is_fully_sampled_year, , drop = FALSE]
  total_checklists <- dplyr::n_distinct(
    record_data$event[record_data$is_checklist])
  spp_checklists <- dplyr::n_distinct(
    record_data$event[record_data$is_checklist &
                      (record_data$species_scientific_name == x)])
  reporting_rate <- paste0("_Reporting rate:_ ",
                           round((spp_checklists / total_checklists) * 100),
                           "%")
  # return result
  data.frame(threat_status = c(iucn_threat_status, national_threat_status,
                               qld_threat_status),
             brisbane_status = c(ebird_records, atlas_squares, reporting_rate))
}
