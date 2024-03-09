transform_variable <- function(data, variable, labels) {
  data[[variable]] <- as.factor(data[[variable]])
  data[[variable]] <- as.factor(labels[data[[variable]]])
  return(data)
}

