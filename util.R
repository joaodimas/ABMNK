while (!require("plotly")) install.packages("plotly")
while (!require("extrafont")) install.packages("extrafont")
font_import(paths=c("/Users/jdimas/GitHub/ABMNK/computer-modern"), pattern="cmu*", prompt=FALSE)
loadfonts(device="postscript")

plotline <- function(y1, y2, x) {
  df <- get(strsplit(deparse(substitute(y1)), "$", fixed=TRUE)[[1]][1])
  if(missing(x)) {
    if(!"date" %in% colnames(df)) {
      stop("Can't find column 'date' in the same data.frame. Please specify a date variable by setting argument x.")
    }
    formula_x <- ~date
  } else {
    formula_x <- formula(paste0("~",strsplit(deparse(substitute(x)), "$", fixed=TRUE)[[1]][2]))
  }
  formula_y1 <- formula(paste0("~",strsplit(deparse(substitute(y1)), "$", fixed=TRUE)[[1]][2]))
  name_y1 <- strsplit(deparse(substitute(y1)), "$", fixed=TRUE)[[1]][2]
  formula_y2 <- formula(paste0("~",strsplit(deparse(substitute(y2)), "$", fixed=TRUE)[[1]][2]))
  name_y2 <- strsplit(deparse(substitute(y2)), "$", fixed=TRUE)[[1]][2]
  if(missing(y2)) {
    plot_ly(df,x=formula_x, y=formula_y1, type="scatter", mode="lines", name=name_y1)
  } else {
    plot_ly(df,x=formula_x, y=formula_y1, type="scatter", mode="lines", name=name_y1) %>%
      add_trace(y = formula_y2, name=name_y2)
  }
}

checkStationarity <- function(x) {
  adf.x <- adf.test(na.omit(x))
  print(adf.x)
  if(adf.x$p.value > 0.1) {
    print("Not stationary!")
  } else {
    print("Yes! Stationary!")
  }
}
checkVARStability <- function(var) {
  roots <- summary(var)$roots
  if(!(FALSE %in% (roots < 1))) {
    print(roots)
    print("All roots of the coefficient matrix are within the unit circle. The VAR is stable!")
  } else {
    print(roots)
    print("VAR NOT STABLE!")
  }
}

checkVARSerialCorr <- function(var) {
  test <- serial.test(var, lags.bg = var$p, type="BG")
  print(test)
  if(test$serial$p.value < 0.1) {
    print("Detected serial correlation!")
  } else {
    print("No serial correlation!")
  }
  
}

checkVARHeteroskedasticity <- function(var1) {
  test <- arch.test(var1)
  print(test)
  if(test$arch.mul$p.value < 0.1) {
    print("Detected heteroskedasticity!")
  } else {
    print("No heteroskedasticity!")
  }
}

checkVARErrorNormality <- function(var1) {
  test <- normality.test(var1)
  print(test)
  if(test$jb.mul$JB$p.value < 0.1) {
    print("Errors are not Normally distributed!")
  } else {
    print("Erros are normal!")
  }
}

formatBrazilianMonth <- function(date) {
  date <- gsub("janeiro ","01/",date, fixed=TRUE)
  date <- gsub("fevereiro ","02/",date, fixed=TRUE)
  date <- gsub("março ","03/",date, fixed=TRUE)
  date <- gsub("abril ","04/",date, fixed=TRUE)
  date <- gsub("maio ","05/",date, fixed=TRUE)
  date <- gsub("junho ","06/",date, fixed=TRUE)
  date <- gsub("julho ","07/",date, fixed=TRUE)
  date <- gsub("agosto ","08/",date, fixed=TRUE)
  date <- gsub("setembro ","09/",date, fixed=TRUE)
  date <- gsub("outubro ","10/",date, fixed=TRUE)
  date <- gsub("novembro ","11/",date, fixed=TRUE)
  date <- gsub("dezembro ","12/",date, fixed=TRUE)
  return(date)
}

plotIRF <- function(irf, impulseSize=1, impulseName, responseName, yAxisFormat = NULL, yAxisDTick = NULL, titlePrefix = "") {
  df <- data.frame(mean = irf$irf[[1]], upper = irf$Upper[[1]], lower = irf$Lower[[1]])
  colnames(df) <- c("mean", "upper", "lower")
  df$mean <- df$mean * impulseSize
  df$upper <- df$upper * impulseSize
  df$lower <- df$lower * impulseSize
  if(missing(impulseName)) {
    impulseName <- irf$impulse
  }
  if(missing(responseName)) {
    responseName <- irf$response
  }
  title <- paste(titlePrefix,"Response of", responseName,"to a shock in",impulseName,ifelse(irf$cumulative,"(cumulative)",""))
  xTicks <- seq(0, nrow(df), by=2)
  emptyTicks <- rep("",length(xTicks)-1)
  xTickText <- c()
  for(i in c(1:length(xTicks))) {
    xTickText <- c(xTickText, xTicks[i])
    if (i <= length(emptyTicks))
      xTickText <- c(xTickText, emptyTicks[i])
  }
  
  plot <- plot_ly(df, y=~mean, type="scatter", mode="lines", name= "Mean") %>%
    add_trace(y=~upper, name="Upper bound", line = list(color = 'red', dash = 'dash')) %>%
    add_trace(y=~lower, name="Lower bound", line = list(color = 'red', dash = 'dash')) %>%
    layout(title = title, yaxis = list(tickformat = yAxisFormat, title="", dtick=yAxisDTick, autotick = is.null(yAxisDTick)), xaxis = list(dtick=2, tickvals=seq(0, nrow(df), by=1), ticktext=xTickText, ticklen=5), showlegend=FALSE, t <- list(family = "sans serif", size = 14))
  return(plot)
}

findOrderNoSerialCorr <- function(data, max.lags=30) {
  for(p in c(1:max.lags)) {
    var <- VAR(data, p=p, type="const")
    test <- serial.test(var, lags.bg = var$p, type="BG")
    if(test$serial$p.value > 0.05) {
      print(test)
      print(paste("Lag order", p, "has no serial correlation at 5%."))
      return(p)
    } 
  }
}

plotIRF2 <- function(irf, impulse, response) {
  if(missing(impulse)) {
    if(exists("labelsMap")) {
      label <- labelsMap[[irf$impulse]]
      if(!is.na(label)) {
        impulse <- label
      } else {
        impulse <- irf$impulse
      }
    }
  }
  if(missing(response)) {
    if(exists("labelsMap")) {
      label <- labelsMap[[irf$response]]
      if(!is.na(label)) {
        response <- label
      } else {
        response <- irf$response
      }
    }
  }
  return(plot(irf, ylab=response, main=paste("Orthogonal Impulse Responses: shock to",impulse)))
}

plotIRFToPS <- function(irf, impulse, response, aspectRatio=1.6, width=10, fileName, path="./paper/LaTeX/Paper/Images/", latexFont=TRUE) {
  old.par <- par(no.readonly = TRUE)
  old.par$new <- NULL
  old.par$pin <- NULL
  setEPS(width=width,height=width/aspectRatio)
  if(missing(fileName)) {
    fileName <- paste0(deparse(substitute(irf)),".eps")
  }
  if(missing(impulse)) {
    if(exists("labelsMap")) {
      label <- labelsMap[[irf$impulse]]
      if(!is.na(label)) {
        impulse <- label
      } else {
        impulse <- irf$impulse
      }
    }
  }
  if(missing(response)) {
    if(exists("labelsMap")) {
      label <- labelsMap[[irf$response]]
      if(!is.na(label)) {
        response <- label
      } else {
        response <- irf$response
      }
    }
  }
  
  postscript(paste0(path,fileName), fonts=c("CMU Serif"))
  lwd<-3 # Line thickness
  cex.lab<-2.5 # Label font size
  cex.axis<-2.5 # Numbers font size
  cex<-2.5 # Text font size
  oma<-c(5.5,0,4,0) # Margins of outer frame
  mar.multi <- c(1.5,9,0.5,0.5) # Margins inside figure
  mgp <- c(7,1,0) # Margin between numbers and label

  if(latexFont) {
    par(family = "CMU Serif")
  }
  plot(irf,mgp=mgp, las=1, lwd=lwd, cex.lab=cex.lab, cex.axis=cex.axis, cex=cex, oma=oma, mar.multi=mar.multi, ylab=response, main=paste("Impulse:",impulse))
  dev.off()
  par(old.par)
}

plotIRFToPSByName <- function(irfName) {
  plotIRFToPS(get(irfName), fileName=paste0(irfName,".eps"))
}

printVARVariables <- function(varData) {
  varLabels <- c()
  for(v in names(varData)) {
    varLabels <- c(varLabels,labelsMap[[v]])
  }
  print(paste(varLabels, collapse=", "))
}
