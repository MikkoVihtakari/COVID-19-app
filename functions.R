## Functions
# N0 = 1340; T0 = as.Date(Sys.time()); Td = 2; t = 0:30; SD = "no"; SDt = NULL; inc.p = NULL; SDTd = NULL; pop.size = 5.4

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
  