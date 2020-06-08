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
    
    # condition parsing
    g <- gsub("[0-9]*$","",colnames(countdata)) # Remove all numbers from end
    #g = gsub("_Rep|_rep|_REP","", g)
    g <- gsub("_$", "", g); # remove "_" from end
    g <- gsub("_Rep$", "", g); # remove "_Rep" from end
    g <- gsub("_rep$", "", g); # remove "_rep" from end
    g <- gsub("_REP$", "", g)  # remove "_REP" from end
    
    (condition <- factor(g))
    
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
