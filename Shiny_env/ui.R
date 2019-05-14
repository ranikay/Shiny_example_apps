library(shiny)
library(shinyjs)
library(shinyURL)

shinyUI(
  
  # ----------------------------- PAGE STYLES & AUTH ------------------------ #
  fluidPage(
    theme = 'bootstrap.yeti.css',
    title = 'Shiny Auth Example App',
    
    tags$head(
      # Just using md5 for simple illustrative purposes
      tags$script(type='text/javascript', src = 'md5.js'),
      tags$script(type='text/javascript', src = 'passwdInputBinding.js')
    ),
    useShinyjs(),
    br(),
    
    # Center the logo
    tags$head(tags$style(
      type='text/css', 
      '#logo img {max-width: 20%; width: 100%; height: auto; display: block; margin: auto}')),
    imageOutput('logo', height = 'auto'),
    br(),
    uiOutput('app')
  )
)

# ------------------------------- DASHBOARD UI ------------------------------ #

dashboard_ui = sidebarLayout(
  sidebarPanel(
    sliderInput(inputId = "bins",
                label = "Number of bins:",
                min = 1,
                max = 50,
                value = 30)
  ),
  
  mainPanel(
    plotOutput(outputId = "distPlot")
  )
)