input <- list()

input$current.infected = 1340
input$start.date = as.Date(Sys.time())
input$doubling.time = 3
input$total.population = 5.4
input$socialDistancing = "no"
input$social.distancing.date = as.Date(Sys.time())
input$incubation.time = 5
input$social.distancing.doubling.time = 10
input$critical.cases = 6


point <- scales::format_format(big.mark = " ", decimal.mark = ".", scientific = FALSE)

ggplot(inf.dt, aes(x = Date, y = daily.critical)) +
  geom_col() +
  scale_y_continuous("Number of hospitalized people per day", labels = point) +
  scale_x_date("Date", date_breaks = "1 week", date_minor_breaks = "1 day", date_labels = "%b %d") +
  theme_bw()
