source("r/constants.r")
source("r/functions-init.r")
source("r/functions-helpers.r")
source("r/functions-read-figures-file.r")
source("r/functions-process-work.r")
source("r/functions-xlsx.r")
source("r/functions-report.r")

# stop("FONT mag niet in GIT, doe path naar p_james/font")

## INPUT
##
fig_def_file_name <- "figure-definition.xlsx" # input file
settings <- resolve_settings(openxlsx::read.xlsx(fig_def_file_name, sheet = "settings"), path_run_default = get_new_run_path())            # get settings
settings$fig_def_file_path <- file.path(getwd(), fig_def_file_name)
#path_run <- if (is_empty(settings$path_run)) get_new_run_path() else settings$path_run  # create output path

## GET DATA
##
work      <- get_work(fig_def_file_name, settings)
index_lst <- get_index_list(work) # list of time series indices per figure

# index_lst <- tail(index_lst, 1)                                         # TODO <<<< WEG!
# index = which(names(index_lst)=="Binnenland_Lonen_Beloning werknemers") # TODO <<<< WEG!
# index = 0:3 + index                                                     # TODO <<<< WEG!
# index_lst <- index_lst[index]                                           # TODO <<<< WEG!
y_lst <- list()
for (i in get_index_vec(index_lst)) {
  index      <- index_lst[[i]]
  # work <- work[index, ]                                                 # TODO <<<< WEG!
  y_lst[[i]] <- get_data(work[index, ])
}

# TODO <<<<< WEG!
#work <- work[index, ]


# # copy input files to ./run/input
# for (i in seq_along(index_lst)) {
#   index        <- index_lst[[i]]
#   path_i       <- file.path(path_run, "input", i)
#   dir.create(path_i, recursive = T) # to avoid file name conflicts, we put source files in subdir corresponding to figure number
#   source_files <- unique(work$source[index])
#   file.copy(from = source_files, to = path_i)
# }

## PROCESS DATA
##
y_lst_processed <- list()
for (i in get_index_vec(index_lst)) {
  index                <- index_lst[[i]]
  y_lst_processed[[i]] <- process(y_lst[[i]], work[index, ])
}

## CREATE OUTPUT: FIGURES
##
## + store nicerplot's arguments in a list so we can create an xlsx-file per figure, which can recreate the figure
arg_lst  <- list()
work$img <- NA
j_start  <- which(START_COLUMN == colnames(work))
for (i in get_index_vec(index_lst)) {
  index <- index_lst[[i]]
  
  # Get parameters
  w <- work[index, ]
  y <- y_lst_processed[[i]]
  lst <- list(x = y, destination_path = settings$path_run, open = F)
  for (j in j_start:ncol(w)) {
    param <- colnames(w)[j]
    if (!all(sapply(w[, j], is_empty))) { # parameter has value(s)
      if (nicerplot:::param_is_list_type(param)) {
        lst[[param]] <- paste(na.omit(w[, j]), collapse = nicerplot:::get_param_list_sep(param))
        
        # TODO Warning: this is a hack. You MUST have a y-axis with values left; i.e. you can't have just a right side y-axis. This hack changes the first 'r' to 'l' iff no 'l' present in y_axis
        if ("y_axis" == param && "r" == unique(lst[[param]])) lst[[param]][1] <- "l"
        
      } else {
        lst[[param]] <- w[1, j]
      }
      
    }
    if (is_true(settings$figure_wide) & "style" == param) lst[[param]] <- paste0(c(lst[[param]], "wide"), collapse = ", ")
  }

  # Create figure
  file_name <- do.call(what = nicerplot::nplot, args = lst)
  
  # Add file name to sheet 'work'
  work$img[index] <- file_name
  
  # Store nicerplot's arguments
  arg_lst[[i]] <- lst[-c(1, 2, 3)] # remove data and useless settings
}

## CREATE XLSX-FILES (one for each figure)
##
xlsx_path <- create_xlsx(work, y_lst, y_lst_processed, arg_lst, settings)

## CREATE OUTPUT: REPORT
##

## Preprocess report data
report <- list()
for (i in get_index_vec(index_lst)) {
  index   <- index_lst[[i]]
  j       <- index[1]
  report[[work$section[j]]][[work$subsection[j]]][[work$tab[j]]] <- c(normalizePath(work$img[j], winslash = "/"), normalizePath(xlsx_path[i], winslash = "/"))
}

## Markdown report
path <- NULL
path <- create_html_file(report, xlsx_path, settings)
print(path)
system(paste0("open ", path))
