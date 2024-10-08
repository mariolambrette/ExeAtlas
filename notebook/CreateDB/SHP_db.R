# Add shapefiles to InteractiveMap database

setwd("C:/Users/ml673/University of Exeter/Exe Atlas - Documents/data")

library(sf)
library(dplyr)


## CONNECT TO DATABASE ----

# Create path to database
rel.save.path <- file.path('..', 'sw', 'InteractiveMap')
sp <- file.path(getwd(), rel.save.path) %>%
  normalizePath()

if (!dir.exists(sp)) {
  dir.create(sp)
}

## Connect to InteractiveMap database in temporary data store ----
con <- DBI::dbConnect(RSQLite::SQLite(), paste0(sp, '\\ExeAtlas_db.db'))

# Should spatial tables be updated. If FALSE only the look up table is updated
update.spatial <- T

# Load subcatchment layer for future reference
if (update.spatial) {
  sc <- sf::st_read("spatial/Sub_catchments_BNG.shp")
}


## INITIATE LAYER INDEX TABLE ----

# Initiate empty table
layer_index <- tibble::tibble(
  SHP_name = NA,
  disp_name = NA,
  aes = NA,
  triggers = NA,
  .rows = 0
) %>%
  mutate_all(as.character())


## ADD BACKGROUND LAYERS ----

# List of background (spatial) shapefiles to be added
SPA_files <- list(
  bg = 'spatial/BG_map_BNG.shp',                    # background map for basemap
  ss = 'spatial/Study_site_boundary_BNG.shp',       # Study site boundary
  sc = 'spatial/Sub_catchments_BNG.shp',            # subcatchment polygons
  cs = 'spatial/Catchments_BNG.shp',                # All main catchment areas
  ri = 'spatial/All_rivers_BNG.shp'
)

# spatial layer look up table
spa_lu <- tibble::tibble(
  SHP_name = names(SPA_files) %>%
    tolower() %>%
    paste0('SHP_SPA_', .), # Spatial file prefix
  disp_name = c('Background',
                'Study site boundary',
                'Subcatchment polygons',
                'Catchment areas',
                'Rivers'),
  aes = NA,
  triggers = NA,
)

# Loop over each of the spatial files and save them as tables into the database
if (update.spatial) {
  plyr::llply(
    seq(1:length(SPA_files)),
    function(x){

      if (is.null(SPA_files[[x]])) {
        return()
      }

      # read shapefile
      p <- sf::read_sf(SPA_files[[x]])

      # Change the geometry column to WKT
      p <- p %>%
        sf::st_transform(crs = 4326) %>%
        mutate(geom = sf::st_as_text(geometry)) %>%
        sf::st_drop_geometry()

      tbl_name <- spa_lu$SHP_name[x]

      # Write layer table into database
      RSQLite::dbWriteTable(
        con,
        tbl_name,
        p,
        overwrite = T
      )

      return()
    },
    .progress = 'text'
  )
}

layer_index <- rbind(layer_index, spa_lu)

## ADD MANAGEMENT AREA FILES ----

# List of Management shapefiles to be added
MA_files <- list(
  WHS = 'terrestrial/World_Heritage_Sites_clipped_BNG.shp',
  LNR = 'terrestrial/LNRs_clipped_BNG.shp',
  IBA = NULL,
  BR = NULL,
  HC = 'terrestrial/Heritage_coast_clipped_BNG.shp',
  RSPBr = 'terrestrial/RSPB_reserves_clipped_BNG.shp',
  RSPBpl = 'terrestrial/RSPB_priority_landscapes_clipped_BNG.shp',
  AONBs = 'terrestrial/AONBs_clipped_BNG.shp',
  NPs = 'terrestrial/NP_areas_clipped_BNG.shp',
  SACs = 'terrestrial/Terrestrial_SACs_clipped_BNG.shp',
  SPAs = 'terrestrial/SPAs_clipped_BNG.shp',
  SSSI = 'terrestrial/SSSIs_clipped_BNG.shp',
  RAMSAR = 'terrestrial/RAMSAR_clipped_BNG.shp',
  CWS = NULL,
  CGS = NULL,
  WRs = NULL
)

ma_lu <- tibble::tibble( # To be bound into `SHP_lookup` table
  SHP_name = names(MA_files) %>%
    tolower() %>%
    paste0('SHP_MNG_', .), # Management area file prefix
  disp_name = c('World Heritage Sites',
                'Local Nature Reserves',
                'Important Bird & Biodiversity Area UNAVAILABLE',
                'Biosphere Reserve UNAVAILABLE',
                'Heritage Coast',
                'RSPB Reserves',
                'RSPB Priority Landscapes',
                'AONBs',
                'National Parks',
                'SACs',
                'SPAs',
                'SSSIs',
                'RAMSAR Sites',
                'County Wildlife Sites UNAVAILABLE',
                'County Geological Sites UNAVAILABLE',
                'Wildlife Reserves UNAVAILABLE'),
  aes = c(
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_whs'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_lnr'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_iba'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_br'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_hc'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_rspbr'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_rspbpl'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_aonbs'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_nps'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_sacs'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_spas'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_sssi'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  "leafletProxy(ns('basemap')) %>%
    addPolygons(data = LoadLayer(name = 'SHP_MNG_ramsar'),
                stroke = F,
                color = '#659665',
                fillOpacity = 0.3,
                fillColor = '#659665',
                group = 'MNG',
                options = pathOptions(pane = 'mng_layers'))",
  NA,
  NA,
  NA
  ), ## Plotting aesthetics for management layers
  triggers = NA
)

# Loop over each of management files and save them as tables into the database
if (update.spatial) {
  plyr::llply(
    seq(1:length(MA_files)),
    function(x){

      if (is.null(MA_files[[x]])) {
        return()
      }

      # read shapefile
      p <- sf::read_sf(MA_files[[x]])

      # Change the geometry column to WKT
      p <- p  %>%
        sf::st_transform(crs = 4326) %>%
        mutate(geom = sf::st_as_text(geometry)) %>%
        sf::st_drop_geometry()

      tbl_name <- ma_lu$SHP_name[x]

      # Write layer table into database
      RSQLite::dbWriteTable(
        con,
        tbl_name,
        p,
        overwrite = T
      )

      return()
    },
    .progress = 'text'
  )
}

layer_index <- bind_rows(layer_index, ma_lu)


## Data files ----

# List of data files
DAT_files <- list(
  lc = 'terrestrial/CEH_lc_parcels_clipped_BNG.shp',
  ct = 'terrestrial/CROME_21_clipped_BNG.shp'
)

# Data file look up table
dat_lu <- tibble::tibble(
  SHP_name = names(DAT_files) %>%
    tolower() %>%
    paste0('SHP_DAT_', .), # Data file prefix
  disp_name = c('Land cover',
                'Crop type'),
  aes = c(
    "
     ## Land cover plotting
     lc <- LoadLayer(name = 'SHP_DAT_lc')

     leafletProxy(ns('basemap')) %>%
       addPolygons(data = lc,
                   stroke = F,
                   fillColor = ~colour,
                   fillOpacity = 1,
                   group = 'DAT',
                   options = pathOptions(pane = 'dat_layers'))

    ",
    "" # crop type plotting
  ),
  triggers = NA,
)

# Loop over each of the data files and save them as tables into the database
if (update.spatial) {
  plyr::llply(
    seq(1:length(DAT_files)),
    function(x){

      if (is.null(DAT_files[[x]])) {
        return()
      }

      # read shapefile
      p <- sf::read_sf(DAT_files[[x]])

      # Change the geometry column to WKT
      p <- p  %>%
        sf::st_transform(crs = 4326) %>%
        mutate(geom = sf::st_as_text(geometry)) %>%
        sf::st_drop_geometry()

      tbl_name <- dat_lu$SHP_name[x]

      # Write layer table into database
      RSQLite::dbWriteTable(
        con,
        tbl_name,
        p,
        overwrite = T
      )

      return()
    },
    .progress = 'text'
  )

}

layer_index <- bind_rows(layer_index, dat_lu)


## CONTINUOUS SEWAGE DISCHARGES ----

if (update.spatial) {
  # Load continuous sewage discharge data
  csd <- readxl::read_xlsx("Pressures/Sewage discharges/Continuous sewage discharges to wider Exe catchment Exe estuary and Lyme Bay.xlsx")

  # Convert the NGR to easting and northing in BNG
  csd <- csd %>%
    mutate(NGR = gsub(" ", "", NGR, fixed = T)) %>%
    mutate(easting  = rnrfa::osg_parse(NGR)[[1]],
           northing = rnrfa::osg_parse(NGR)[[2]])

  # Convert to an sf object
  csd <- csd %>%
    sf::st_as_sf(., coords = c("easting", "northing"), crs = 27700) %>%
    sf::st_join(., sc) %>%
    rename(sc_ID = ID) %>%
    select(c(Sewage, `Treatment works`, NGR, Treatment,
             `Dry weather flow (m3 day-1)`, sc_ID))

  # Convert to WKT format and export to database for use in interactive map
  csd <- csd %>%
    sf::st_transform(crs = 4326) %>%
    mutate(DryWeatherFlow = if_else(
      `Dry weather flow (m3 day-1)` == "Unspecified",
      NA,
      `Dry weather flow (m3 day-1)`
      ) %>%
        as.numeric()
    ) %>%
    mutate(geom = sf::st_as_text(geometry)) %>%
    sf::st_drop_geometry()

  # Write table into database
  RSQLite::dbWriteTable(
    con,
    'SHP_DAT_csd',
    csd,
    overwrite = T
  )
}

# Update look up table
csd_lu <- tibble::tibble(
  SHP_name = "SHP_DAT_csd",
  disp_name = "Continuous sewage discharge sites",
  aes = "csd <- LoadLayer(name = 'SHP_DAT_csd')

         csd$colour <- ifelse(is.na(csd$DryWeatherFlow), 'darkgrey', '#FFDB00')

         # Function to scale DryWeatherFlow values to radii
         scale_radius <- function(x, min_r, max_r) {
           if (is.na(x)) {
             return(min_r)
           }

           scaled <- ((x - min(csd$DryWeatherFlow, na.rm = TRUE)) /
                     (max(csd$DryWeatherFlow, na.rm = TRUE) - min(csd$DryWeatherFlow, na.rm = TRUE))) *
                     (max_r - min_r) + min_r
           return(scaled)
         }

         # Apply the function to calculate the radii
         csd$radius <- sapply(csd$DryWeatherFlow, scale_radius, min_r = 3, max_r = 10)


         leafletProxy(ns('basemap')) %>%
           addCircleMarkers(data = csd,
                            radius = ~radius,
                            opacity = 1,
                            color = ~colour,
                            fillOpacity = 1,
                            group = 'DAT',
                            options = pathOptions(pane = 'dat_points'))",
  triggers = NA
)

layer_index <- bind_rows(layer_index, csd_lu)


## UPDATE SHP_lookup TABLE ----

# Update SHP_lookup
RSQLite::dbWriteTable(
  con,
  'SHP_lookup',
  layer_index,
  overwrite = T
)

# Disconnect from database
RSQLite::dbDisconnect(con)
rm(con)
