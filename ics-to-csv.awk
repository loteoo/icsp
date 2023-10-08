BEGIN {
  FS = "\t" # FS is a tab character because we expect a special ICS file that uses
  # tab characters as the delimiter for key-value pairs.

  # "OFS" (Output Field Separator) variable is set by bash via the "-d" (delimiter) option
  # Default: ","

  # "columns" variable is set by bash via the "-c".
  # Default: "" (empty string)
  # It represents which fields of the .ics object we want to include in the CSV output.

  # "component" variable is set by bash via the "-x" option.
  # It represents the .ics object we want to parse.
  # Default: "VEVENT"
  # Other possible values: "VTODO", "VJOURNAL" "VFREEBUSY" "VTIMEZONE" "VALARM"

  idx = 0 # Current object "index", counts up to the total number of rows.
  in_component = 0 # Whether or not the current line is within the specified component
}

# Update "in_component" and "idx" accordingly for each line
$1 == "BEGIN" {
  if ($2 == component) {
    in_component = 1
  } else {
    in_component = 0
  }
  next
}
$1 == "END" {
  if ($2 == component) {
    in_component = 0
    idx = idx + 1
  } else {
    in_component = 1
  }
  next
}

# Pick up relevant values as we go through the file
in_component == 1 {
  found_cols[$1] = found_cols[$1] + 1
  values[idx,$1] = $2
}

END {
  # If no columns were specified, create a list of columns 
  # sorted by how often they had a value in the CSV file.
  if (columns == "") {
    unsorted_columns=""
    for (col in found_cols) {
      unsorted_columns = unsorted_columns found_cols[col] "\t" col "\n" 
    }
    command = "echo '" unsorted_columns "' | sort -rn | cut -d'\t' -f2 | sed '/^$/d'"
    for (i = 0; (command | getline line) > 0; i++) {
      auto_sorted_columns[i] = line
    }
    close(command)
    for (k = 0; k < length(auto_sorted_columns); k++) {
      if (columns == "") {
        columns = auto_sorted_columns[k]
      } else {
        columns = columns "," auto_sorted_columns[k]
      }
    }
  }

  # Print headers
  headers = columns
  gsub(",", OFS, headers)
  print headers

  # Convert the columns string into an array
  for (i = 0; (next_col_pos = index(columns, ",")) != 0; i++) {
    cols_array[i] = substr(columns, 0, next_col_pos - 1)
    columns = substr(columns, next_col_pos + 1, length(columns))
  }
  cols_array[i] = columns

  # Loop rows
  for (i = 0; i < idx; i++) {
    line_out = ""

    # Loop columns
    for (k = 0; k < length(cols_array); k++) {
      value = values[i,cols_array[k]]
      if (index(value, ",") != 0) {
        gsub("\"", "\"\"", value)
        value = "\"" value "\""
      }
      if (line_out == "") {
        line_out = value
      } else {
        line_out = line_out OFS value
      }
    }

    # Print row
    print line_out
  }
}
