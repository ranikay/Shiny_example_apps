library(shiny)
library(DT)
library(plotly)
library(reshape2)

# View the app running locally at http://localhost:7445
options(shiny.port = 7445, shiny.maxRequestSize=30*1024^2)

shinyServer(function(input, output, session) {
  
  DATA <- reactiveValues(Cleaned_Table = NULL,
                         NA_Replace = 0,
                         Col_Names = NULL,
                         Sample_Col_Name = NULL,
                         Covar_Col_Names = NULL,
                         Logged = F,
                         Log_Message = NULL,
                         Save_Message = NULL,
                         Save_Sample = NULL,
                         Save_Covars = NULL,
                         Clean_Matrix = NULL,
                         PCA_plot = NULL,
                         Corr_plot = NULL)
  
  # Logo
  output$logo <- renderImage({
    return(list(
      src = 'www/logo.png',
      contentType = 'image/png',
      alt = 'Logo'
    ))
  }, deleteFile = F)
  
  # User's uploaded file and formatting parameters
  df <- reactive(DATA$Cleaned_Table)
  uploaded_file <- reactive(input$input_file)
  has_headers <- reactive(input$checkbox_headers)
  needs_transform <- reactive(input$checkbox_transform)
  needs_log2 <- reactive(input$checkbox_log2)
  
  # Title for uploaded data table
  output$upload_message <- renderText({
    inFile = uploaded_file()
    if (is.null(inFile)){
      return('Begin by uploading a .csv file')
    } else{
      if (DATA$Logged){
        return('Uploaded data preview (log2-transformed)')
      } else{
        return('Uploaded data preview')
      }
    }
  })
  
  # Read the file with current parameters
  update_uploaded_file <- function(){
    inFile = uploaded_file()
    needsTransform = needs_transform()
    hasHeaders = has_headers()
    if (!is.null(inFile)){
      if (needsTransform){
        DATA$Cleaned_Table <- as.data.frame(t(read.csv(inFile$datapath, 
                                           header = has_headers(),
                                           stringsAsFactors = F)))
      } else{
        DATA$Cleaned_Table <- read.csv(inFile$datapath, 
                                       header = has_headers(),
                                       stringsAsFactors = F)
      }
      DATA$Col_Names <- names(DATA$Cleaned_Table)
    }
  }
  
  # Toggle uploaded file
  observeEvent(uploaded_file(), {
    update_uploaded_file()
  })
  
  # Toggle file has headers
  observeEvent(has_headers(), {
    update_uploaded_file()
  })
  
  # Toggle transform
  observeEvent(needs_transform(), {
    update_uploaded_file()
  })
  
  # Toggle log2 transform
  observeEvent(needs_log2(), {
    if (needs_log2()){
      dataFrame = df()
      if (!is.null(dataFrame)){
        exclude_cols = c(sample_column(), covar_columns())
        numeric_cols = names(dataFrame)[!names(dataFrame) %in% exclude_cols]
        col_classes = sapply(numeric_cols, function(x){
          class(dataFrame[,x])
        })
        if (any(col_classes == 'character')){
          DATA$Log_Message <- 'Non-numeric values found - please remove before log-transforming'
          DATA$Logged <- F
          updateCheckboxInput(session = session,
                              inputId = 'checkbox_log2',
                              value = F)
        } else{
          DATA$Cleaned_Table <- cbind(dataFrame[, exclude_cols],
                                      log2(dataFrame[, numeric_cols]))
          DATA$Log_Message <- NULL
          DATA$Logged <- T
        }
      }
    } else{
      update_uploaded_file()
      DATA$Logged <- F
    }
  })
  output$log_message <- renderText({
    if (!is.null(DATA$Log_Message)){
      DATA$Log_Message
    }
  })
  
  # Make the selected sample ID column the row names
  sample_column <- reactive(input$select_sample_column)
  covar_columns <- reactive(input$select_covar_columns)
  replace_na_val <- reactive(input$replace_NAs_with)
  
  # Select which column is the sample ID and covariates
  col_names <- reactive(DATA$Col_Names)
  observeEvent(col_names(), {
    updateSelectInput(session = session,
                      inputId = 'select_sample_column', 
                      choices = col_names())
  })
  observeEvent(col_names(), {
    updateSelectizeInput(session = session,
                      inputId = 'select_covar_columns',
                      choices = col_names())
  })
  
  # Summarize number of NAs
  output$num_NAs <- renderText({
    inFile = uploaded_file()
    if (!is.null(inFile)){
      dataFrame = df()
      return(paste0('Number of NA values: ', sum(is.na(dataFrame))))
    }
  })
  output$replace_NAs <- renderUI({
    inFile = uploaded_file()
    if (!is.null(inFile)){
      dataFrame = df()
      if (any(is.na(dataFrame))){
        numericInput('replace_NAs_with', 'Replace NA values with', 0)  
      }
    }
  })
  
  # Color sample ID and covariate columns
  output$dt_preview <- DT::renderDataTable({
    inFile = uploaded_file()
    if (!is.null(inFile)){
      sampleCol = sample_column()
      covarCols = covar_columns()
      dataFrame = df()
      dt = DT::datatable(dataFrame, rownames = F, 
                         options = list(pageLength = 15))
      if (sampleCol %in% names(dataFrame)){
        if (is.null(covarCols)){
          return(dt %>%
            formatStyle(sampleCol,
              backgroundColor = '#CFB87B'
            ))
        } else{
          return(dt %>%
                   formatStyle(sampleCol,
                               backgroundColor = '#CFB87B'
                   ) %>%
                   formatStyle(covarCols,
                               backgroundColor = 'lightgrey'
                   ))
        }
      }
    } else{
      return(NULL)
    }
  })
  
  # Save all params when user clicks Save
  observeEvent(input$button_save_params, {
    inFile = uploaded_file()
    if (!is.null(inFile)){
      DATA$NA_Replace <- replace_na_val()
      DATA$Sample_Col_Name <- sample_column()
      DATA$Covar_Col_Names <- covar_columns()
      DATA$Save_Message <- 'Parameters saved!'
      DATA$Save_Sample <- paste0('Sample ID column: ', DATA$Sample_Col_Name)
      if (is.null(DATA$Covar_Col_Names)){
        DATA$Save_Covars <- 'Covariate column(s): None'
      } else{
        DATA$Save_Covars <- paste0('Covariate column(s): ',
                                   paste0(DATA$Covar_Col_Names, collapse = ', '))
      }
      # Also generate cleaned numeric matrix for PCA
      dataFrame = df()
      if (!is.null(DATA$Sample_Col_Name)){
        row.names(dataFrame) = dataFrame[, DATA$Sample_Col_Name]
        dataFrame[, DATA$Sample_Col_Name] = NULL
      }
      if (!is.null(DATA$Covar_Col_Names)){
        dataFrame[, DATA$Covar_Col_Names] = NULL
      }
      dataFrame[is.na(dataFrame)] = DATA$NA_Replace
      DATA$Clean_Matrix <- dataFrame
    }
  })
  output$save_message <- renderText({
    if (!is.null(DATA$Save_Message)){
      DATA$Save_Message
    }
  })
  output$save_sample <- renderText({
    if (!is.null(DATA$Save_Sample)){
      DATA$Save_Sample
    }
  })
  output$save_covars <- renderText({
    if (!is.null(DATA$Save_Covars)){
      DATA$Save_Covars
    }
  })
  
  # PCA tab message
  output$pca_message <- renderText({
    if (is.null(pca_data())){
      return('Upload data and set parameters on the "Upload data" tab')
    } else{
      return('Principal components analysis (PCA) plot')
    }
  })
  
  # Update dropdown options based on selected covariates
  observeEvent(input$button_save_params, {
    covarColNames = DATA$Covar_Col_Names
    # PCA plot params
    updateSelectInput(session = session,
                      inputId = 'select_color_column',
                      choices = covarColNames,
                      selected = covarColNames[1])
    updateSelectInput(session = session,
                      inputId = 'select_shape_column',
                      choices = c('None', covarColNames),
                      selected = 'None')
    # Corr plot params
    updateSelectInput(session = session,
                      inputId = 'select_color_column2',
                      choices = covarColNames,
                      selected = covarColNames[1])
    updateSelectInput(session = session,
                      inputId = 'select_shape_column2',
                      choices = c('None', covarColNames),
                      selected = 'None')
  })
  
  # Get PCA data
  pca_data <- reactive(DATA$Clean_Matrix)
  compute_pca <- function(dat){
    p = prcomp(dat)
    p_df = as.data.frame(p$x)
    return(p_df[,1:2])
  }
  
  # PCA plot
  point_color_column <- reactive(input$select_color_column)
  point_shape_column <- reactive(input$select_shape_column)
  output$PCA_plot <- renderPlotly({
    if (is.null(pca_data())){
      return(NULL)
    } else{
      cleaned_data = pca_data()
      data_to_plot = compute_pca(cleaned_data)
      colorCol = point_color_column()
      shapeCol = point_shape_column()
      allData = DATA$Cleaned_Table
      covarColNames = DATA$Covar_Col_Names
      data_to_plot = cbind(data_to_plot, 
                           allData[,covarColNames])
      names(data_to_plot) = c('PC1', 'PC2',
                              covarColNames)
      
      # Create basic plot and color points by selected column
      if (!is.null(colorCol)){
        if (shapeCol == 'None'){
          p <- plot_ly(data = data_to_plot, x = ~PC1, y = ~PC2, type = 'scatter',
                  mode = 'markers', marker = list(size = 10),
                  text = row.names(data_to_plot), hoverinfo = 'text',
                  color = ~get(colorCol), colors = 'Spectral')
        } else{
          p <- plot_ly(data = data_to_plot, x = ~PC1, y = ~PC2, type = 'scatter',
                       mode = 'markers', marker = list(size = 10),
                       text = row.names(data_to_plot), hoverinfo = 'text',
                       color = ~get(colorCol), colors = 'Spectral',
                       symbol = ~get(shapeCol))
        }
        DATA$PCA_plot <- p
        return(p)
      }
    }
  })
  
  get_pca_plot <- reactive(DATA$PCA_plot)
  output$download_PCA <- downloadHandler(
    filename = function() {
      paste0('PCA_', 
             Sys.Date(), '.pdf')
    },
    content = function(file) {
      pdf(get_pca_plot(), 
          file, height = 5, width = 5)
    }
  )
  
  # Get correlation plot data
  corr_data <- reactive(DATA$Clean_Matrix)
  corr_type <- reactive(input$corr)
  compute_corr <- function(dat){
    return(cor(dat, method = corr_type()))
  }
  compound_1 <- reactive(input$compound1)
  compound_2 <- reactive(input$compound2)
  point_color_column_2 <- reactive(input$select_color_column2)
  point_shape_column_2 <- reactive(input$select_shape_column2)
  
  # Select compounds to correlate
  observeEvent(corr_data(), {
    dataFrame = df()
    exclude_cols = c(sample_column(), covar_columns())
    numeric_cols = names(dataFrame)[!names(dataFrame) %in% exclude_cols]
    col_classes = sapply(numeric_cols, function(x){
      class(dataFrame[,x])
    })
    if (!any(col_classes == 'character')){
      updateSelectInput(session = session,
                        inputId = 'compound1',
                        choices = numeric_cols,
                        selected = numeric_cols[1])
      updateSelectInput(session = session,
                        inputId = 'compound2',
                        choices = numeric_cols,
                        selected = numeric_cols[2])
    }
  })
  
  # Correlation plot
  output$corr_plot <- renderPlotly({
    if (is.null(corr_data())){
      return(NULL)
    } else{
      dataFrame = df()
      data_to_plot = corr_data()
      compoundOne = compound_1()
      compoundTwo = compound_2()
      covarColNames = covar_columns()
      colorCol = point_color_column_2()
      shapeCol = point_shape_column_2()
      
      data_to_plot = cbind(dataFrame[,covarColNames],
                           data_to_plot)
      names(data_to_plot)[1:length(covarColNames)] = covarColNames
      
      # Create basic plot and color points by selected column
      if (!is.null(colorCol)){
        if (shapeCol == 'None'){
      
          # Create basic plot
          p <- plot_ly(data = data_to_plot, x = ~get(compoundOne), y = ~get(compoundTwo), 
                       type = 'scatter',
                       mode = 'markers', marker = list(size = 10),
                       text = row.names(data_to_plot), hoverinfo = 'text',
                       color = ~get(colorCol), colors = 'Spectral') %>%
            layout(xaxis = list(title = compoundOne),
                   yaxis = list(title = compoundTwo))
        
        } else{
          p <- plot_ly(data = data_to_plot, x = ~get(compoundOne), y = ~get(compoundTwo),
                       type = 'scatter',
                       mode = 'markers', marker = list(size = 10),
                       text = row.names(data_to_plot), hoverinfo = 'text',
                       color = ~get(colorCol), colors = 'Spectral',
                       symbol = ~get(shapeCol)) %>%
            layout(xaxis = list(title = compoundOne),
                   yaxis = list(title = compoundTwo))
        }
        DATA$Corr_plot <- p
        return(p)
      }
    }
  })
  
  # Correlation table
  output$corr_table <- DT::renderDataTable({
    if (is.null(corr_data())){
      return(NULL)
    } else{
      cleaned_data = corr_data()
      corMethod = corr_type()
      corColName = paste0(corMethod, ' correlation')
      data_to_table = compute_corr(cleaned_data)
      data_to_table[lower.tri(data_to_table)] = NA
      data_long = as.data.frame(na.omit(melt(data_to_table)))
      names(data_long) = c('Compound_1', 'Compound_2', 
                           corColName)
      data_long = data_long[data_long[,corColName] != 1,]
      data_long[,corColName] = round(data_long[,corColName], 4)
      data_long = data_long[order(data_long[,corColName], decreasing = T),]
      return(DT::datatable(data_long, rownames = F))
    }
  })
  
})