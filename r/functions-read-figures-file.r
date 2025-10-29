resolve_value <- function(value, resolved) {
  variable_syntax <- regmatches(value, regexpr("\\$\\{([^}]+)\\}", value)) # get ${...}
  variable_name <- sub("\\$\\{([^}]+)\\}", "\\1", variable_syntax)         # strip ${...} resulting in ...
  
  if (is.null(resolved[[variable_name]])) stop(paste0("Variable '", variable_name, "' not found!", collapse = ""))
  
  res_val <- if (is.na(resolved[[variable_name]])) "" else resolved[[variable_name]]
  
  sub(paste0("\\$\\{", variable_name, "\\}"), res_val, value)
}

resolve_settings <- function(settings, path_run_default = NULL) {
  resolved <- list()
    
  for (i in 1:nrow(settings)) {
    param <- settings$parameter[i]
    value <- settings$value[i]
    while (grepl("\\$\\{[^}]+\\}", value)) {
      value <- resolve_value(value, resolved)
    }
    resolved[[param]] <- value
    
    # fix path_run
    if (PATH_RUN == param & is_empty(value)) resolved[[PATH_RUN]] <- path_run_default
  }
  
  return(resolved)
}

resolve_figures <- function(d, settings) {
  for (i in 1:nrow(d)) for (j in 1:ncol(d)) while (grepl("\\$\\{[^}]+\\}", d[i, j])) {
    d[i, j] <- resolve_value(d[i, j], settings)
  } 

  return(d)
}

get_work <- function(path, settings) {
  figures_with_variables  <- openxlsx::read.xlsx(path, sheet = "figures", startRow = 2)
  resolve_figures(figures_with_variables, settings)
}
