get_index_list <- function(work) {
  # Filter rows where 'create' is TRUE or NA
  index_no <- which(is_false(work$create))
  index_av <- which(is.na(work$create) | sapply(work$create, is_true))
  work_sub <- work[index_av, ]
  figs     <- unique(work_sub[, c("section", "subsection", "tab")])
  
  lst <- list()
  for (i in 1:nrow(figs)) {
    sec         <- figs$section[i]
    subsec      <- figs$subsection[i]
    tab         <- figs$tab[i]
    name        <- paste(sec, subsec, tab, sep = "_")
    index       <- which(work$section == sec & work$subsection == subsec & work$tab == tab)
    lst[[name]] <- setdiff(index, index_no)
  }
  
  return(lst)
}

is_date_with_letter <- function(x) stringr::str_detect(x, "^....[A-Za-z]") # e.g. 2003m02 gives TRUE

get_x <- function(x_string, freq) {
  if (is_date_with_letter(x_string[1])) {
    x      <- as.numeric(stringr::str_sub(x_string, 1, 4))
    period <- as.numeric(stringr::str_sub(x_string, 6, 7)) - 1
    x_new  <- x + period / get_period(freq)
    # suppressWarnings(x + 0:(get_period(freq) - 1) / get_period(freq))
  } else {
    # Detect format like "1995.01M" and normalize
    if (all(grepl("^\\d{4}\\.\\d{2}M$", x_string))) {
      x_string <- sub("M$", "", x_string)     # drop trailing M
      x_string <- gsub("\\.", "-", x_string)  # 1995.01 → 1995-01
      x_string <- paste0(x_string, "-01")     # assume day = 1
    }
    
    x     <- lubridate::ymd(x_string)
    year  <- lubridate::year(x)
    start <- lubridate::ymd(paste0(year, "-01-01"))
    end   <- start + lubridate::years(1)
    x_new <- year + as.numeric(x - start) / as.numeric(end - start)
  }
  
  x_new
}

get_y_union <- function(y_lst) {
  col_union <- sort(Reduce(union, lapply(y_lst, colnames)))
  
  lst <- lapply(y_lst, function(mat) {
    mat[, setdiff(col_union, colnames(mat))] <- NA
    mat[, col_union]
  })
  
  do.call(rbind, lst)
}

get_y <- function(d, series) {
  if (is.element(series, colnames(d))) { # col wise
    d_sub <- t(d[, which(colnames(d) %in% series), drop = FALSE])
    colnames(d_sub) <- if (inherits(d[1, 1], "Date")) format(d[, 1], "%Y-%m-%d") else d[, 1]
  } else if (is.element(series, d[, 1])) { # row wise
    d_sub <- d[which(d[, 1] %in% series), -c(1, 2), drop = FALSE]
  } else stop(paste0("Series '", series, "' not found in row 1 or col 1 :-O"))
  
  return(d_sub)
}

get_data <- function(work) {
  if (1 < length(unique(work$frequency))) stop(paste0("In current version of software, frequency must be equal for all time series. Please contact Martijn Dijkstra if you want time series with different frequency in one figure."))
    
  y_lst <- list()
  for (i in 1:nrow(work)) {
    d <- openxlsx::read.xlsx(work$source[i], sheet = if (is.na(work$sheet[i])) 1 else work$sheet[i], detectDates = TRUE)

    # skip lines
    skip_first <- work$skip_first_n_rows[i]
    skip_last  <- work$skip_last_n_rows[i]

    # If NA, treat as 0
    skip_first <- if (is.na(skip_first)) 0 else skip_first
    skip_last  <- if (is.na(skip_last)) 0 else skip_last

    n_rows <- nrow(d)

    rows_to_drop <- c(
      if (skip_first > 0) seq_len(skip_first) else integer(0),
      if (skip_last  > 0) (n_rows - skip_last + 1):n_rows else integer(0)
    )

    if (length(rows_to_drop)) d <- d[-rows_to_drop, , drop = FALSE]
    
    # fix the issue that read.xlsx replaces ' ' with '.'
    header <- openxlsx::read.xlsx(
      work$source[i],
      sheet = if (is.na(work$sheet[i])) 1 else work$sheet[i],
      colNames = FALSE, rows = 1, detectDates = FALSE
    )
    header <- as.character(unlist(header[1, ], use.names = FALSE))
    if (ncol(d) == 1 + length(header)) {
      colnames(d) <- c(NA, header)
    } else {
      colnames(d) <- header
    }
    
    y_lst[[i]] <- get_y(d, work$series[i])
  }
  y <- get_y_union(y_lst)
  y <- t(y)
  colnames(y) <- work$series # Put original time series names here
  
  # REMOVE DATA FOR WHICH x-axis IS non-numerical
  index_wrong_x <- which(!grepl("^[0-9]", rownames(y)))
  if (length(index_wrong_x)) {
    y <- y[-index_wrong_x, , drop = F]
  }
  
  # x-axis as rownames
  # sheet can have different frequency than series
  frequency_inconsistency <- !is_empty(work[["frequency-sheet"]][1])
  freq_sheet <- if (frequency_inconsistency) work[["frequency-sheet"]][1] else work$frequency[1]
  x <- get_x(x_string = rownames(y), freq = freq_sheet)
  rownames(y) <- x
  
  if (frequency_inconsistency) y <- y[-which(is.na(y[, 1])), , drop = FALSE]

  # cast numeric
  y <- as.data.frame(y)
  for (j in 1:ncol(y)) y[, j] <- as.numeric(y[, j])

  y
}

process <- function(y, work) {
  colnames(y) <- ifelse(is.na(work$name), "unknown", work$name)
  x  <- as.numeric(rownames(y))
  y_new <- y_ <- y
    
  for (i in 1:nrow(work)) {
    ## (1) seasonal adjustment
    ##
    if (is_true(work[["season-adj"]][i])) {
      y_star          <- ts(y[, i], frequency = get_period(work$frequency[i]), start = rownames(y)[1])
      y_seas          <- seasonal::seas(y_star)
      index_av        <- which(!is_empty(y[, i]))
      y_[index_av, i] <- as.vector(seasonal::final(y_seas))
    }
    
    ## (2) index
    ##
    base_year <- work[["index-base-year"]][i]
    if (!is_empty(base_year)) {
      y_mean_base_year <- mean(y_[which(base_year == trunc(x)), i], na.rm = T) # take average value in base year
      y_[, i]          <- y_[, i] / y_mean_base_year * 100
    }
    y_new[, i] <- y_[, i]
    
    ## (3) differences instead of plain values?
    ##
    if (!is_empty(work[["delta-period"]][i])) {
      n                       <- work[["delta-period"]][i]
      y_[(1 + n):nrow(y_), i] <- tail(y_[, i], -n) - head(y_[, i], -n)
      y_[1:n, i]              <- NA
      
      # relative values?
      if (is_true(work[["delta-as-percentage"]][i])) {
        y_[(1 + n):nrow(y_), i] <- tail(y_[, i], -n) / head(y_new[, i], -n) * 100
      }
      
      y_new[, i] <- y_[, i]
    }
    
    ## (4) cummulate
    ##
    base_year_cumulative_growth <- work[["cumulative-growth-base-year"]][i]
    if (!is_empty(base_year_cumulative_growth)) {
      index <- which(!is_empty(y_[, i]))
      
      for (k in seq_along(index)) {
        if (1 == k) {
          y_[index[1], i] <- 100 # TODO ? Als er voor index[i] een NA zit, dan had je ook daar kunnen beginnen, niet waar?
        } else {
          y_[index[k], i] <- y_[index[k - 1], i] * (1 + y_[index[k], i] / 100)
        }
      }      

      index_by         <- which(base_year_cumulative_growth == trunc(x))
      y_mean_base_year <- mean(y_[index_by, i], na.rm = T) # take average value in base year # y_new[index_by[1], i]#
      y_new[, i]       <- y_[, i] / y_mean_base_year * 100
    }
  }
  
  y_new
}