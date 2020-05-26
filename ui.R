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


