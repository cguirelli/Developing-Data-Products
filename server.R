library(UsingR)
library(shiny)
library(ggplot2)
library(caret)


shinyServer(
    function(input, output) {
        

        datasetInput  <- reactive({
            
            # input$file1 will be NULL initially. After the user selects and uploads a 
            # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
            # columns. The 'datapath' column will contain the local filenames where the 
            # data can be found.
            
            inFile <- input$file1
            
            if (is.null(inFile))
                    #return(NULL)
                    read.csv("./example.csv", header=1, sep=";")
                else
                    read.csv(inFile$datapath, header=1, sep=";")
        })
    
  
        

    output$contents <- renderTable({datasetInput()})

    output$summary <- renderPrint({summary(datasetInput()$EC)})
    
    
    output$years <- renderUI({ 
        selectInput("ano", "Select year", unique(sort(datasetInput()$year)) )
    })
    
    max_year <- reactive({max(unique(sort(datasetInput()$year)))})
    
    min_year <- reactive({min(unique(sort(datasetInput()$year)))})
    
    output$ano_pred <- renderUI({ 
      numericInput('ano_pred', 'Year for prediction:', max_year()+1, min = min_year(), max = max_year()+10, step = 1)
    })
    

    #output$year_min <- renderText({unique(sort(datasetInput()$year))[1]})
    #output$year_max <- renderText({tail(unique(sort(datasetInput()$year)),1)})

    #
    # Gráfico do histograma
    #
    output$Plot1 <- renderPlot({
            dados <- datasetInput()
            hist(dados$EC,
                 freq=TRUE,
                 xlab='Energy Consumption (kWh)', 
                 main='Energy Consumption (kWh)',
                 col='darkgreen')
            
            grid(nx=NULL, ny=NULL,col="gray") #grid over boxplot
            par(new=TRUE)
            hist(dados$EC,
                 freq=TRUE,
                 xlab='Energy Consumption (kWh)', 
                 main='Energy Consumption (kWh)',
                 col='darkgreen') 
        })
    
    #
    # Gráfico do consumo por ano selecionado
    #
    output$Plot2 <- renderPlot({
        dados <- datasetInput()
        dados <- dados[dados$year==input$ano,]
        dados <- dados[order(dados$month),]
        meses <- c("Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct",
                    "Nov","Dec")
        dados_ano <- data.frame(Characters=character(),
                                Ints=integer(),
                                stringsAsFactors=FALSE)
        for (i in 1:12)
        {
            dados_ano[i,1]=meses[i]
            if (is.na(dados[i,1]))
                dados_ano[i,2]=0
                else
                if (i==dados[i,1])
                    dados_ano[i,2]=dados[i,3]
        }
            
        barplot(dados_ano[,2]
                ,names.arg=dados_ano[,1]
                ,col='darkgreen' 
                ,bg = "blue"
                ,xlab='month'
                ,ylab='Energy (kWh)')
        grid(nx=NA, ny=NULL,col="black")
        par(new=TRUE)
        barplot(dados_ano[,2]
                ,names.arg=dados_ano[,1]
                ,col='darkgreen' 
                ,bg = "blue"
                ,xlab='month'
                ,ylab='Energy (kWh)')
    })
 
    output$Plot3 <- renderPlot({
        dados <- datasetInput()
        dados$month <- factor(dados$month, 
                        labels = c("Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct",
                                   "Nov","Dec"))
                        
        boxplot(dados$EC ~ dados$month
                 ,data = dados
                 ,col = 'darkgreen'
                 ,xlab='month'
                 ,ylab='Energy (kWh)')
        par(bg = "yellow")
        grid(nx=NULL, ny=NULL,col="gray") #grid over boxplot
        par(new=TRUE)
        
        boxplot(dados$EC ~ dados$month
                ,data = dados
                ,col = 'darkgreen'
                ,xlab='month'
                ,ylab='Energy (kWh)')
        
    })
    
    meses <- reactive ({c("Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct",
                          "Nov","Dec")})

    previsao_dataset <- reactive ({
                                    ano <- input$ano_pred
                                    previsao_dataset <- data.frame(c(1:12),rep(ano,12))
                                    colnames(previsao_dataset) <- c("month","year")
                                    print(previsao_dataset)
                                    previsao_dataset
                                })
    

    modelo <- reactive ({ dados <- datasetInput()
                          set.seed(107)
                          train(EC ~ ., data=dados, method=input$pred_model)
                        })
    
    prediction <- reactive ({ predict(modelo(), previsao_dataset())})
    
    output$verificacao <- renderText({modelo()$results$Rsquared})
    #
    # Gráfico da Previsão
    #
    output$Plot4 <- renderPlot({
        barplot(prediction()
                ,names.arg= meses()
                ,col='lightgreen' 
                ,bg = "blue"
                ,xlab='month'
                ,ylab='Energy (kWh)'
                ,main=input$ano_pred
                ,ylim=c(0,max(prediction()))
                )
        grid(nx=NULL, ny=NULL,col="black") #grid over boxplot
        par(new=TRUE)
        barplot(prediction()
                ,names.arg= meses()
                ,col='lightblue' 
                ,bg = "blue"
                ,xlab='month'
                ,ylab='Energy (kWh)'
                ,main=input$ano_pred
                ,ylim=c(0,max(prediction()))
                )
    })
 

    
       
    }
)