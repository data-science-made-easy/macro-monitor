create_xlsx <- function(work, y_lst, y_lst_processed, arg_lst, settings) {
  # creates xlsx with tab 'meta' (arg_lst), tab 'data' (y_lst_processed), tab 'original' (y_lst)
  # the xlsx enables users to (adapt and) recreate each given figure
  # returns vector with paths to xlsx-files
  xlsx_path_vec <- NULL
  dir.create(settings$xlsx_path, recursive = TRUE, showWarnings = FALSE)
  for (i in seq_along(arg_lst)) {
    wb <- openxlsx::createWorkbook()
    openxlsx::addWorksheet(wb, "meta")
    openxlsx::addWorksheet(wb, "data")
    openxlsx::addWorksheet(wb, "data-original")
    # tab: meta
    df <- data.frame(parameter = c("tab", names(arg_lst[[i]])), value = c("data", unlist(arg_lst[[i]])), row.names = NULL, stringsAsFactors = FALSE)
    openxlsx::writeData(wb, sheet = "meta", df, colNames = FALSE)
    openxlsx::addStyle(wb, sheet = "meta", openxlsx::createStyle(fontColour = "#e6006e", textDecoration = "bold"), rows = 1:nrow(df), cols = 1, gridExpand = TRUE)
    # tab: data
    openxlsx::writeData(wb, sheet = "data", y_lst_processed[[i]], rowNames = TRUE, colNames = TRUE)
    # tab: data-original
    openxlsx::writeData(wb, sheet = "data-original", y_lst[[i]], rowNames = TRUE, colNames = TRUE)
    xlsx_path <- file.path(settings$xlsx_path, paste0(tools::file_path_sans_ext(basename(work$img[index_lst[[i]][1]])), ".xlsx"))
    openxlsx::saveWorkbook(wb, file = xlsx_path, overwrite = TRUE)
    
    xlsx_path_vec <- c(xlsx_path_vec, normalizePath(xlsx_path, mustWork = TRUE))
  }
  
  xlsx_path_vec
}