library(shiny)
library(shinyjs)

shinyUI(
  
  # Use Google Sign-In API
  tagList(
    tags$head(
      tags$meta(name = 'google-signin-scope', 
                content = 'profile email'),
      tags$meta(name = 'google-signin-client_id', 
                content = '<CLIENT_ID>.apps.googleusercontent.com'),
      HTML('<script src="https://apis.google.com/js/platform.js?onload=init"></script>'),
      includeScript('www/signin.js')
    ),
    
    # Page UI
    fluidPage(
      
      # Center the logo
      tags$head(tags$style(
        type='text/css', 
        '#logo img {max-width: 20%; width: 100%; height: auto; display: block; margin: auto}')),
      imageOutput('logo', height = 'auto'),
      br(),
      
      sidebarLayout(
        sidebarPanel(
          textOutput('welcome_message'),
          br(),
          uiOutput('g_image'),
          hr(),
          uiOutput('dashboard_inputs'),
          br(),
          div('signin', class = 'g-signin2', 'data-onsuccess' = 'onSignIn', 
              style = 'margin-top: 8px;'),
          actionButton('signout', 'Sign Out', class = 'btn-danger', 
                       style = 'margin-top: 8px;', onclick="signOut();")
        ),
        
        mainPanel(
          h5('The dashboard will only appear to authenticated users with an "@gmail.com" account'),
          uiOutput('mainpanel')
        )
      )
    )
  )
)