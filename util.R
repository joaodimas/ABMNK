while (!require("plotly")) install.packages("plotly")
plotline <- function(y1, y2, x) {
  df <- get(strsplit(deparse(substitute(y1)), "$", fixed=TRUE)[[1]][1])
  if(missing(x)) {
    if(!"date" %in% colnames(real_data_afterReal)) {
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
