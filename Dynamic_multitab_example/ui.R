library(shiny)
library(DT)
library(plotly)

shinyUI(
  
  # Include Google Analytics in the header
  tagList(
    tags$head(
      includeHTML('www/google_analytics.html')
    ),

  # App UI
  fluidPage(
    theme = 'bootstrap.yeti.css',
    title = 'Metabolomics Analysis',
    
    # Center the logo
    tags$head(tags$style(
      type='text/css', 
      '#logo img {max-width: 30%; height: auto; display: block; margin: auto}')
    ),
    imageOutput('logo', height = 'auto'),
    br(),
    
    # Sidebar
    sidebarLayout(
      sidebarPanel(
        conditionalPanel(
          'input.tabs === "Upload data"',
          'Upload metabolomics data',
          hr(),
          fileInput('input_file', label = 'Select .csv file for upload'),
          span(textOutput('num_NAs'), style = 'color: #CFB87B;'),
          uiOutput('replace_NAs'),
          hr(),
          helpText('Check below if data needs to be transposed so that each row corresponds to a sample'),
          checkboxInput('checkbox_transform', label = 'Transpose', value = F),
          checkboxInput('checkbox_headers', label = 'File has headers', value = T),
          selectInput('select_sample_column', label = 'Select sample ID column (gold)',
                      choices = NULL),
          selectizeInput('select_covar_columns', label = 'Select covariate(s) (grey)',
                      choices = NULL, multiple = T),
          checkboxInput('checkbox_log2', label = 'log2 transform numeric data', value = F),
          span(textOutput('log_message'), style = 'color: #CFB87B;'),
          br(),
          actionButton('button_save_params', 'Save analysis parameters',
                       style = 'margin-bottom: 10px;'),
          br(),
          span(textOutput('save_message'), style = 'color: #CFB87B;'),
          textOutput('save_sample'),
          textOutput('save_covars')
        ),
        conditionalPanel(
          'input.tabs === "Principal components analysis"',
          'Create PCA plot',
          hr(),
          selectInput('select_color_column', label = 'Color points by',
                      choices = NULL),
          selectInput('select_shape_column', label = 'Shape points by',
                      choices = NULL),
          downloadButton('download_PCA', label = 'Download plot (PDF)')
        ),
        conditionalPanel(
          'input.tabs === "Differential abundance"',
          helpText('Download results')
        ),
        conditionalPanel(
          'input.tabs === "Correlations"',
          'Create correlation plot',
          hr(),
          selectInput('compound1', 'Compound 1', choices = NULL),
          selectInput('compound2', 'Compound 2', choices = NULL),
          radioButtons('corr', 'Correlation method',
                       choices = c('spearman', 'pearson'),
                       selected = 'spearman'),
          selectInput('select_color_column2', label = 'Color points by',
                      choices = NULL),
          selectInput('select_shape_column2', label = 'Shape points by',
                      choices = NULL),
          downloadButton('download_corr', label = 'Download plot (PDF)',
                         style = 'margin-bottom: 10px;'),
          downloadButton('download_corr_tab', label = 'Download table (CSV)')
        )
      ),
      
      # Main panel
      mainPanel(
        tabsetPanel(
          id = 'tabs',
          tabPanel('Upload data', 
                   br(),
                   strong(span(textOutput('upload_message'), 
                        style = 'color: #CFB87B;')),
                   br(),
                   DT::dataTableOutput('dt_preview')),
          tabPanel('Principal components analysis', 
                   br(),
                   strong(span(textOutput('pca_message'), 
                        style = 'color: #CFB87B;')),
                   plotlyOutput('PCA_plot')),
          #tabPanel('Differential abundance', 
          #         br(),
          #         'TODO'),
          tabPanel('Correlations', 
                   br(),
                   strong(span('Correlation plot', 
                               style = 'color: #CFB87B;')),
                   plotlyOutput('corr_plot'),
                   br(),
                   DT::dataTableOutput('corr_table'))
        )
      ) # end mainPanel
    )  # end sidebarLayout
  )) # end fluidPage
)
