## ui_new.R

library(shiny)
library(shinydashboard)
library(DT)


ui <- dashboardPage(
  skin = 'red',
  dashboardHeader(title = "3BIGS Shiny"),
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("DEG Analysis", tabName = "deg", icon = icon("th")),
      menuItem("Plot", tabName = "Plot", icon = icon("bar-chart-o"), badgeLabel = "new", badgeColor = "green")
    )
  ),
  
  dashboardBody(
    # First tab content
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                box(
                  width = 12, solidHeader = TRUE,
                  title = "Input count table",
                  # Input: Select a file ----
                  fileInput("file1", "Upload CSV File",
                            multiple = FALSE,
                            accept = c("text/csv",
                                       "text/comma-separated-values,text/plain",
                                       ".csv"))
                ),
                box(
                  width = 12, solidHeader = TRUE,status = 'warning',
                  title = "Gene counts for samples",
                  tableOutput("contents")
                )
              )
      ),
      
      # Second tab content
      tabItem(tabName = "deg",
              
              #fluidRow(
              #  box(
              #    width = 12, solidHeader = TRUE,
              #    title = "Differential Gene Expression Analysis",
              
              #    p("Click the button to run DEG analysis."),
              #    actionButton("runButton", "run DEA")
              
              #  ),
              
              box(
                width = 12, solidHeader = TRUE, status = 'warning',
                title = "FPKM Values and DEG statistics",
                DT::dataTableOutput("view"),
                downloadButton("downloadCsv", "Download as CSV")
                
              )
      )
    )
  )
)


## server_new.R

### TEMP ###

server <- function(input, output) {
  
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$file1)
    
    # when reading semicolon separated files,
    # having a comma separator causes `read.csv` to error
    tryCatch(
      {
        df <- read.csv(input$file1$datapath,
                       header = TRUE,
                       sep = "\t")
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    
    return(head(df, 10))
    
  })
  
  res_data <- reactive({
    
    ###Here I put preprocess & DEA codes###
    countdata <- read.table(input$file1$datapath, header=TRUE, row.names=1)
    
    colnames(countdata) <- gsub("\\.[sb]am$", "", colnames(countdata))
    colnames(countdata) <- gsub("\\.sorted$", "", colnames(countdata))
    
    countdata <- as.matrix(countdata)
    
    (condition <- factor(c(rep("con", 2), rep("DOX", 2))))
    
    library("DESeq2")
    
    (coldata <- data.frame(row.names=colnames(countdata), condition))
    
    dds <- DESeqDataSetFromMatrix(countData=countdata, colData=coldata, design=~condition)
    
    dds <- DESeq(dds)
    
    res <- results(dds)
    
    res <- res[order(res$padj), ]
    
    data <- merge(as.data.frame(res), as.data.frame(counts(dds, normalized=TRUE)), by="row.names", sort=FALSE)
    names(data)[1] <- "Gene_id"
    
    data
    
  })
  
  
  output$view <- DT::renderDataTable({
    
    resdata <- res_data()
    
    DT::datatable(resdata, options = list(lengthMenu = c(10, 25, 50, 75, 100), pageLength = 10))
    
    #return(head(resdata, 10))
  })
  
  
  output$downloadCsv <- downloadHandler(
    
    filename = "DEG.data.csv",
    content = function(file) {
      
      resdata <- res_data()
      
      write.csv(resdata, file)
    },
    contentType = "text/csv"
  )
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
