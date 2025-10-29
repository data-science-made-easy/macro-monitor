is_false <- function(value) "n" == value

is_true <- function(value) {
  if (is.null(value)) return(FALSE)
  clean_string <- tolower(stringr::str_trim(value))
  first_char <- substr(clean_string, 1, 1)          # also works for empty string
  return(is.element(first_char, c("y", "t", "j")))  # yes, true, ja
}

is_empty <- function(vec) sapply(vec, function(v) if (is.na(v)) return(TRUE) else return(0 == nchar(stringr::str_trim(v))))

get_period <- function(freq) {
  freq <- tolower(stringr::str_trim(freq))
  # if ("y" == freq) return(1)
  if ("q" == freq) return(4)
  if ("m" == freq) return(12)
  # if ("w" == freq) return(52)

  return(FALSE)
}

# for debugging purposes only:
get_index_vec <- function(index_lst) seq_along(index_lst) # 31:39
