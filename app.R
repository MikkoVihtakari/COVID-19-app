## Libraries required to run the app ####

library(shiny)
library(shinydashboard)
library(tidyverse)
library(scales)
library(plotly)

# required.packages <- c("shiny", "shinydashboard", "tidyverse", "scales", "plotly")
# new.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
# if (length(new.packages) > 0) install.packages(new.packages)
# sapply(required.packages, require, character.only = TRUE)

## Source functions used by the app

predict.infected <- function(N0, T0, Td, t = 0:30, pop.size, SD = "no", SDt = NULL, inc.p = NULL, SDTd = NULL, pr.crit) {
  
  if(SD == "yes") {
    
    cut.date <- SDt + inc.p
    cut.t <- as.numeric(cut.date - T0)
    
    tmp1 <- N0 * 2 ^ {min(t):cut.t/Td}
    
    tmp2 <- max(tmp1) * 2 ^ {0:(max(t) - cut.t)/SDTd}
    
    tmp <- unique(c(tmp1, tmp2))
    
    out <- data.frame(Date = T0 + t, pred.infected = round(tmp, 0))
    
  } else {
    
    tmp <- N0 * 2 ^ {t/Td}  
    
    out <- data.frame(Date = T0 + t, pred.infected = round(tmp, 0))  
    
  }
  
  if(max(out$pred.infected) > pop.size * 1e6) {
    
    out$pred.infected[out$pred.infected > pop.size * 1e6] <- pop.size * 1e6
  }
  
  out$pred.critical <- round(out$pred.infected * (pr.crit / 100), 0)
  out$daily.critical <- c(0, diff(out$pred.critical))
  
  out
  
}

##____________________
## User interface ####

## Header

header <- dashboardHeader(title = "COVID-19 outbreak model", titleWidth = 300, 
                          dropdownMenu(type = "notifications", 
                                       headerText = tags$div(
                                         "Author: Mikko Vihtakari", 
                                         tags$br(),
                                         "Affiliation: Institute of Marine Research",
                                         tags$br(),
                                         "Version: 2020-03-17",
                                         tags$br(),
                                         "Thanks: RStudio and shiny developers"
                                       ),
                                       icon = icon("cog"), badgeStatus = NULL)
)


##__________
## Body ####

body <- dashboardBody(
  fluidRow(
    
    tabItem("parameters",
            box(
              title = "Model for the start phase of COVID-19 outbreak", width = 12, status = "primary", solidHeader = TRUE, collapsible = TRUE,
              
              p("Uncontrolled viral infections follow", a("exponential growth", href = "https://en.wikipedia.org/wiki/Exponential_growth"), "and are relatively easy to model. This app illustrates how COVID-19 infection could develop in your country and why the drastic measures to fight the outbreak are justified. The model uses simple exponential maths, median estimates and ignores a whole lot of important parameters, such as reporting error, development of immunity, population density, demography, variation, and uncertainty. Consequently, the model is not accurate but gives an idea of how the outbreak could develop during the uncontrolled start phase most European countries have been going through in March 2020. The model parameters have been adjusted for the situation in Norway 2020-03-17. See", a("here", href = "https://www.worldometers.info/coronavirus/#countries"), "to find the current parameters for your country."),
              
              p("The", strong("doubling time"), "measures how many days it takes for the number of infected people to double. During the uncontrolled phase of the COVID-19 outbreak, this time has been typically between 2 and 4 days. An overview of the doubling times and numbers of people infected around the globe can be found from", a("here", href = "https://ourworldindata.org/coronavirus"), "and", a("here.", href = "https://www.worldometers.info/coronavirus/#countries")),
              
              splitLayout(
                sliderInput("doubling.time", label = "Doubling time", min = 1, max = 30, value = 3),
                dateInput("start.date", label = "Start date", value = "2020-03-17"),
                numericInput("current.infected", label = "Infected at start", value = 1450)
              ),
              
              p("Measures, such as", strong("social distancing"), "or forced home-quarantines prolong the doubling time. While there is still a lack of data on the effects of social distancing, the doubling time seems to increase from 10 to over 30 days, depending on the measures. You can examine the addition of social distancing to the model by changing the box under, but see first what would happen without social distancing"),
              
              radioButtons("socialDistancing", label = "Apply social distancing",
                           choices = list("No" = "no", "Yes" = "yes"), 
                           selected = "no",
                           inline = TRUE),
              
              conditionalPanel(
                condition = "input.socialDistancing == 'yes'",
                
                p("The virus has an", strong("incubation time"), "from infection to when the symptoms occur and are tested by the authorities, which", a("varies between 2 and 12 days with a median close to 5 days.", href = "https://www.jwatch.org/na51083/2020/03/13/covid-19-incubation-period-update"), "This implies that the effects of social distancing will be seen after the incubation time is over. To add the", strong("social distancing"), "to the model, select a date using the box under. You can also adjust the effectiviness of social distancing."),
                
                splitLayout(
                  sliderInput("incubation.time", label = "Incubation time", min = 2, max = 14, value = 5),
                  dateInput("social.distancing.date", label = "Social distancing begins", value = "2020-03-13"),
                  sliderInput("social.distancing.doubling.time", label = "Doubling time after social distancing", min = 2, max = 30, value = 10)
                )
              ),
              
              p("The global mean for the percentage of", strong("people needing intensive care"), "is", a("6 at the moment.", href = "https://www.worldometers.info/coronavirus/"), "This parameter influences the estimates for the number of people hospitalized per day. The", strong("total population"), "in your country sets the limits for the number of people infected. Note that in reality, the infection curve starts to flatten out (i.e. the doubling time increases) as the outbreak proceeds due to natural feedback mechanisms (people recover and develop a resistance). The percentage of deaths depends on the number of people requiring hospital-care per day (i.e. whether the health-care system can handle all cases) and demography of the population. Therefore death estimates have not been calculated in the model."),
              
              splitLayout(
                numericInput("critical.cases", label = "Percentage hospitalized", min = 0, max = 100, value = 6),
                numericInput("total.population", label = "Total population in millions", min = 0.01, max = 1500, value = 5.4),
                numericInput("ndays", label = "Number of days to forecast", min = 10, max = 200, value = 60)
                
              ),
              
            )
            
    ), 
    
    tabItem("Infplot",
            box(
              title = "Predicted infections", 
              width = 12, status = "primary", solidHeader = TRUE, collapsible = TRUE,
              plotlyOutput(outputId = "infPlot")
            )
    ),
    
    tabItem("Hosplot",
            box(
              title = "People hospitalized per day", 
              width = 12, status = "primary", solidHeader = TRUE, collapsible = TRUE,
              plotlyOutput(outputId = "hosPlot"),
            )
    )
  )
)


## Dashboard page  

ui <- dashboardPage(header = header, sidebar = dashboardSidebar(disable = TRUE), body = body)

##............
## Server ####

server <- shinyServer(function(input, output, session) {
  
  
  ## Data
  
  inf.dt <- reactive({
    
    predict.infected(N0 = input$current.infected,
                     T0 = input$start.date,
                     Td = input$doubling.time,
                     t = 0:round(input$ndays, 0),
                     pop.size = input$total.population,
                     SD = input$socialDistancing,
                     SDt = input$social.distancing.date,
                     inc.p = input$incubation.time,
                     SDTd = input$social.distancing.doubling.time,
                     pr.crit = input$critical.cases
    )
    
    
    
  })
  
  ## Plots
  
  output$infPlot <- renderPlotly({
    
    point <- scales::format_format(big.mark = " ", decimal.mark = ".", scientific = FALSE)
    
    p <- ggplot(inf.dt(), aes(x = Date, y = pred.infected)) +
      geom_line() +
      scale_y_continuous("Number of infected people", labels = point) +
      scale_x_date("Date", date_breaks = "1 week", date_minor_breaks = "1 day", date_labels = "%b %d") +
      theme_bw()
    
    ggplotly(p)
    
  })
  
  output$hosPlot <- renderPlotly({
    
    point <- scales::format_format(big.mark = " ", decimal.mark = ".", scientific = FALSE)
    
    p <- ggplot(inf.dt(), aes(x = Date, y = daily.critical)) +
      geom_col() +
      scale_y_continuous("Number of hospitalized people per day", labels = point) +
      scale_x_date("Date", date_breaks = "1 week", date_minor_breaks = "1 day", date_labels = "%b %d") +
      theme_bw()
    
    ggplotly(p)  %>% plotly::layout(annotations = list(x = 0, y= 1, xref = "paper", yref = "paper", text = paste("Total hospitalized:\n", max(inf.dt()$pred.critical)), showarrow = FALSE, font = list(size = 12)))
    
  })
  
  
})

###########################
## Compilte to the app ####

shinyApp(ui, server)
