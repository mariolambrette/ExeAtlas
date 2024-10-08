#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @export
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    
    # Wrap the main map module UI inside uiOutput to make it reactive
    shiny::fluidPage(
      #uiOutput("map_ui")  # Placeholder for rendering module UI reactively
      
      ## DEBUGGING
      # leaflet::leafletOutput("simple_map")
      
      mod_main_map_ui("main_map_1")
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "ExeAtlas"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
