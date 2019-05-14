library(shiny)
library(RColorBrewer)
library(dotenv)
source('ui.R')

credentials <- list('noob' = '202cb962ac59075b964b07152d234b70',  # how definitely NOT to do auth
                    'pro' = Sys.getenv("LOGIN_HASH"))   # pw hash is moved out into an env variable

shinyServer(function(input, output) {

  # ------------------------- Authentication logic -------------------------- #
  
  shinyURL.server()
  
  USER <- reactiveValues(Logged = FALSE)
  
  observeEvent(input$.login, {
    if (isTRUE(credentials[[input$.username]]==input$.password)){
      USER$Logged <- TRUE
    } else {
      show('message')
      output$message = renderText('Invalid user name or password')
      delay(2000, hide('message', anim = TRUE, animType = 'fade'))
    }
  })
  
  output$app <- renderUI(
    if (!isTRUE(USER$Logged)) {
      fluidRow(
        column(width=4, offset = 4,
               wellPanel(id = 'login',
                         textInput('.username', 'Username:'),
                         passwordInput('.password', 'Password:'),
                         div(actionButton('.login', 'Log in'), 
                             style='text-align: center;')
               ),
               textOutput('message')
        ))
    } else {
      dashboard_ui  # see ui.R
    }
  )
  
  # ---------------------- The rest of the server logic --------------------- #
  
  output$logo <- renderImage({
    return(list(
      src = 'www/logo.png',
      contentType = 'image/png',
      alt = 'Logo'
    ))
  }, deleteFile = F)
  
  output$distPlot <- renderPlot({
    x = faithful$waiting
    plot_cols = brewer.pal(11, 'Spectral')
    bins = seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = plot_cols, border = "white",
         xlab = "Waiting time to next eruption (minutes)",
         main = "Histogram of waiting times")
  })
})