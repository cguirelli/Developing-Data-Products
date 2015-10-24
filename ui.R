library(shiny)
 
shinyUI(
    
    
        fluidPage(
                
        tags$head(
            tags$style(HTML("
                        h1 {
                        font-family: 'Times New Roman',Times, serif;
                        font-style:italic;
                        font-weight: bold;
                        line-height: 1.1;
                        color: rgba(56, 134, 204, 1);
                        }

                            "))),    
        
    
                
    headerPanel("Home Electricity Consumption"),
    sidebarPanel(
        fileInput('file1', 'Choose File',
                  accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
        
        h4("Using the application"),
        HTML("This application load a data file with the energy consumption of a house and presents some information/analysis of the data.<BR>"),
        HTML("<ol><LI>To use this application just load a data file in <I>Choose file</I>. When started, the application loads the file <I>example.csv</I> file.<BR>"),
        HTML("<LI>Choose one of the panels on the right to get the information needed.<BR></ol>"),
        hr(),
        HTML("<LI>Data file must be type <I>csv</I> with 3 columns labeled:<BR>"),
        HTML("<P ALIGN=CENTER><I>month, year, EC</I><BR>"),
        HTML("<LI TYPE=CIRCLE><I>month</I> : a number from 1 to 12<BR>"),
        HTML("<LI TYPE=CIRCLE><I>year</I> : year<BR>"),
        HTML("<LI TYPE=CIRCLE><I>EC</I> : energy consumption in the given month/year in kWh<BR>"),
        HTML("<LI>File must look like:"),
        HTML("<P ALIGN=CENTER>month;year;EC"),
        HTML("<P ALIGN=CENTER>    1;2013;165"),
        HTML("<P ALIGN=CENTER>    2;2013;268"),
        HTML("<P ALIGN=CENTER>    3;2013;206"),
        HTML("<P ALIGN=CENTER>    4;2013;237"),
        HTML("<LI>Missing measurements should be omitted, not replaced with <I>0</I> or <I>NA</I>.")
    ),
    mainPanel(
        
        tabsetPanel(type =  "pills",
            tabPanel("Distribution",plotOutput("Plot1")),
            tabPanel('Consumption'
                     ,htmlOutput("years")
                    ,plotOutput("Plot2")),
            tabPanel("Statistics",
                     helpText("Some statistics of the dataset: max, min, average, quantiles and boxplot"),
                     h4('Summary of dataset:'),
                     verbatimTextOutput("summary"),
                     fluidRow(column(9,
                                     h4('Monthly boxplot:'),
                                     plotOutput('Plot3')),
                              column(3,
                                    helpText("How to read a boxplot"),
                                    img(src="boxplot.png",width = 175)))),
            tabPanel("Prediction",
                     helpText("Select a year and a prediction model to forecast 
                              future consumptions. Rsquared, is a number that 
                              indicates how well data fit the model. * Obs.: some predictions may take a while to run in web. "),
                     fluidRow(column(4,
                                     htmlOutput("ano_pred")
                                     ),
                              column(8,
                                     selectInput("pred_model", "Prediction Model:",
                                                 selected = 'rf',
                                                 list(
                                                     'Generalized Linear Model'='glm',
                                                     'Independent Component Regression'='icr',
                                                     'Linear Regression'='lm',
                                                     'Non-Negative Least Squares'='nnls',
                                                     'Principal Component Analysis'='pcr',
                                                     'Projection Pursuit Regression'='ppr',
                                                     'Quantile Random Forest'='qrf',
                                                     'Random Forest'='rf',
                                                     'Ridge Regression'='ridge',
                                                     'Robust Linear Model'='rlm'
                                                 ))
                                     )),
                     plotOutput("Plot4"),
                     h4('Rsquared:'),
                     verbatimTextOutput("verificacao")
                     ),
            tabPanel("Data set",
                     helpText("Shows the loaded dataset."),
                     tableOutput('contents'))
        )
    )
)
)