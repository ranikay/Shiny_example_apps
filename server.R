library(shiny)
library(RColorBrewer)
# View the running app at localhost:7445
# options(shiny.port = 7445)

shinyServer(function(input, output, session) {
  
  # ------------------------- Authentication logic -------------------------- #
  USER <- reactiveValues(Logged = FALSE,
                         Name = NULL,
                         Email = NULL,
                         Image = NULL)
  ORG_DOMAIN <- 'gmail.com'
  
  # Given an email address, determine whether the user can access the app
  observeEvent(input$g_email, {
    USER$Name <- input$g_name
    USER$Email <- input$g_email
    USER$Image <- input$g_image
    if (grepl(ORG_DOMAIN, USER$Email)){
      USER$Logged <- TRUE
    } else{
      USER$Logged <- FALSE
    }
  })
  
  # Sign out when the user clicks "Sign Out" button
  # (Signout was handled differently in https://github.com/dkulp2/Google-Sign-In
  # but doing this gave me more reliable results)
  observeEvent(input$signout, {
    USER$Logged <- FALSE
    USER$Name <- NULL
    USER$Email <- NULL
    USER$Image <- NULL
  })
  
  # ---------------------- The rest of the server logic --------------------- #
  
  # React to the user's current state
  is_logged_in <- function() { return(USER$Logged) }
  get_user_name <- function() { return(USER$Name) }
  get_user_email <- function() { return(USER$Email) }
  get_user_image <- function(){ return(USER$Image) }
  
  # Logo :)
  output$logo <- renderImage({
    return(list(
      src = 'www/logo.png',
      contentType = 'image/png',
      alt = 'Logo'
    ))
  }, deleteFile = F)
  
  # Display the user's Google image
  output$g_image <- renderUI({ img(src = get_user_image()) })
  
  # If the user is logged in, show a welcome message
  output$welcome_message <- renderText({
    if (is_logged_in()){
      paste0('Welcome, ', get_user_name(), '!')
    } else{
      if (!is.null(get_user_name())){
        paste0('Hi, ', get_user_name(), 
               '. Unfortunately, you do not have access to this app.',
               ' Please sign back in with a ', ORG_DOMAIN, 
               ' account or contact the system administrator.')
      } else{
        paste0('Please sign-in to continue')
      }
    }
  })
  
  # If the user is logged in, show the dashboard sidebar
  output$dashboard_inputs <- renderUI(
    if (is_logged_in()) {
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
    } else{
      NULL
    }
  )
  
  # If the user is logged in, show the dashboard
  output$mainpanel <- renderUI(
    if (is_logged_in()) {
      plotOutput('distPlot')
    }  else{
      NULL
    }
  )
  
  # Plot some secret stuff for the user to see once they've logged in
  output$distPlot <- renderPlot({
    x = faithful$waiting
    plot_cols = brewer.pal(11, 'Spectral')
    bins = seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = plot_cols, border = "white",
         xlab = "Waiting time to next eruption (minutes)",
         main = "Histogram of waiting times")
  })

})