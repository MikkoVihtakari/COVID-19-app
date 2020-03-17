# COVID-19-app
A shiny app to predict and study the beginning phase of COVID-19 outbreak

Uncontrolled viral infections follow [exponential growth](https://en.wikipedia.org/wiki/Exponential_growth) and are relatively easy to model. This app illustrates how COVID-19 infection could develop in your country and why the drastic measures to fight the outbreak are justified. The model uses simple exponential maths, median estimates and ignores a whole lot of important parameters, such as reporting error, development of immunity, population density, demography, variation, and uncertainty. Consequently, the model is not accurate but gives an idea of how the outbreak could develop during the uncontrolled start phase most European countries have been going through in March 2020. The model parameters have been adjusted for the situation in Norway 2020-03-17. See [here](https://www.worldometers.info/coronavirus/#countries) to find the parameters for your country.

The doubling time measures how many days it takes for the number of infected people to double. During the uncontrolled phase of the COVID-19 outbreak, this time has been typically between 2 and 4 days. Measures, such as social distancing or forced home-quarantines prolong the doubling time. While there is still a lack of data on the effects of social distancing, the doubling time seems to increase from 10 to over 30 days, depending on the measures. An overview of the doubling times around the globe can be found from [here](https://ourworldindata.org/coronavirus) and [here.](https://www.worldometers.info/coronavirus/#countries).

The virus has an incubation time, from infection to when the symptoms occur and are tested by the authorities, which [varies between 2 and 12 days with a median close to 5 days](https://www.jwatch.org/na51083/2020/03/13/covid-19-incubation-period-update). This implies that the effects of social distancing will be seen after the incubation time is over. 

The global mean for the percentage of people needing intensive care is [6 at the moment](https://www.worldometers.info/coronavirus/). This parameter influences the estimates for the number of people hospitalized per day. The total population in your country sets the limits for the number of people infected. Note that in reality, the infection curve starts to flatten out (i.e. the doubling time increases) as the outbreak proceeds due to natural feedback mechanisms (people recover and develop a resistance). The percentage of deaths depends on the number of people requiring hospital-care per day (i.e. whether the health-care system can handle all cases) and demography of the population. Therefore death estimates have not been calculated in the model.

## Installation of the desktop version

A desktop version of the app can be installed on any modern computer. The app requires [R](https://www.r-project.org/) and [RStudio](https://www.rstudio.com/). Install these software on your computer following the instructions on the respective webpages. Open RStudio and install the [Shiny](https://shiny.rstudio.com/) package:

```r
install.packages("shiny")
```

### Running the app directly from GitHub

Once you have the RstoxData package installed, you can run the app. Write:

```r
library(shiny)
shiny::runGitHub("BioticExplorer", "MikkoVihtakari")
```

### Running the app from your hard drive

Click "Clone or download" -> "Download ZIP". Find the zip file (typically in your Downloads folder) and extract it to a desired location. Open the app.R file in RStudio and [click "Run app"](https://shiny.rstudio.com/tutorial/written-tutorial/lesson1/).
