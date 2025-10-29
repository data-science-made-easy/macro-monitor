get_new_run_path <- function() {
  parent_dir <- "run"
  if (!dir.exists(parent_dir)) dir.create(parent_dir)
  run_path <- file.path(parent_dir, paste0("run-", format(Sys.time(), "%Y%m%d-%H%M%S", tz = "Europe/Amsterdam")))
  dir.create(run_path)
  run_path
}

