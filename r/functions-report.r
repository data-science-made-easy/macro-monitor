create_html_file <- function(report, xlsx_path, settings) {
  # create path
  dir.create(settings$report_path, recursive = TRUE, showWarnings = FALSE)
  output_path_abs      <- normalizePath(settings$report_path, mustWork = FALSE)
  output_file_path_abs <- file.path(output_path_abs, settings$report_file)

  knitr::opts_chunk$set(echo = FALSE)
  knitr::opts_knit$set(unnamed.chunk.label = "just-some-label", progress = FALSE, verbose = FALSE)
  css_path <- paste0(normalizePath(settings$report_css, mustWork = TRUE), "?", paste(sample(c(0:9, letters, LETTERS), 3, replace = TRUE), collapse = ""))
  int_dir  <- normalizePath(settings$report_path)
  rmarkdown::render(settings$report_template, output_file = output_file_path_abs, intermediates_dir = int_dir, params = list(lst = report, xlsx_path = xlsx_path), clean = FALSE, output_options = list(css = css_path))

  output_file_path_abs
}