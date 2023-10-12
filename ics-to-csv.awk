function to_iso(dt) {
  format = ""
  if (dt ~ /^[0-9]{8}$/) {
    format = "%Y%m%d"
  } else if (dt ~ /^[0-9]{8}T[0-9]{6}$/) {
    format = "%Y%m%dT%H%M%S"
  } else if (dt ~ /^[0-9]{8}T[0-9]{6}Z$/) {
    format = "%Y%m%dT%H%M%SZ"
  }
  if (format != "") {
    date_command = "date -jf '" format "' -v '" tz_offset "M' '" dt "' '+%Y-%m-%d %H:%M:%S'"
    date_command | getline out
    close(date_command)
    return out
  }
  return dt
}

function to_epoch(dt) {
  if (dt ~ /^[0-9]{8}$/) {
    format = "%Y%m%d"
  } else if (dt ~ /^[0-9]{8}T[0-9]{6}$/) {
    format = "%Y%m%dT%H%M%S"
  } else if (dt ~ /^[0-9]{8}T[0-9]{6}Z$/) {
    format = "%Y%m%dT%H%M%SZ"
  }
  date_command = "date -jf '" format "' '" dt "' '+%s'"
  date_command | getline out
  close(date_command)
  return out
}

function get_duration(dtstart, dtend) {
  start = to_epoch(dtstart)
  end = to_epoch(dtend)
  seconds = end - start
  hours = seconds / 3600
  decimal_index = index(hours, ".")
  if (decimal_index == "0") {
    return hours "h"
  }
  decimals = substr(hours, decimal_index + 1, length(hours))
  hour = substr(hours, 0, decimal_index - 1)
  minutes_precise = ("0." decimals) * 60
  minutes_decimal_index = index(minutes_precise, ".")
  if (minutes_decimal_index != "0") {
    minutes = substr(minutes_precise, 0, minutes_decimal_index - 1)
  } else {
    minutes = minutes_precise
  }
  if (hour == "0") {
    return minutes "m"
  }
  return hour "h" minutes "m"
}

function get_date_cmd_type() {
  check_date_cmd_type = "date --version >/dev/null 2>&1"
  if (system(check_date_cmd_type) == 0) {
    date_cmd_type = "gnu"
  } else {
    date_cmd_type = "bsd"
  }
  close(check_date_cmd_type)
  return date_cmd_type
}

function get_tz_offset() {
  check_tz_offset = "date +%z"
  check_tz_offset | getline tz_offset_str
  close(check_tz_offset)
  tz_d = substr(tz_offset_str, 1, 1)
  tz_h = substr(tz_offset_str, 2, 2)
  tz_m = substr(tz_offset_str, 4, 2)
  tz_offset = tz_d ((tz_h * 60) + tz_m)
  return tz_offset
}

BEGIN {
  FS = "\t" # FS is a tab character because we expect a special ICS file that uses
  # tab characters as the delimiter for key-value pairs.

  OFS = "\t" # "OFS" is also a tab character because we want to simplify processing later or
  # using a unique delimiter character that won't be found in the values.

  # "columns" variable is set by icsp via the "-c".
  # Default: "" (empty string)
  # It represents which fields of the .ics object we want to include in the CSV output.

  # "component" variable is set by icsp via the "-x" option.
  # It represents the .ics object we want to parse.
  # Default: "VEVENT"
  # Other possible values: "VTODO", "VJOURNAL" "VFREEBUSY" "VTIMEZONE" "VALARM"

  iso_format = "true"
  compute_duration = "true"

  idx = 0 # Current object "index", counts up to the total number of rows.
  in_component = 0 # Whether or not the current line is within the specified component

  date_cmd_type = get_date_cmd_type()
  tz_offset = get_tz_offset()
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
  values[idx, $1] = $2
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

    if (compute_duration == "true") {
      values[i, "DURATION"] = get_duration(values[i, "DTSTART"], values[i, "DTEND"])
    }

    # Loop columns
    for (k = 0; k < length(cols_array); k++) {
      column = cols_array[k]
      value = values[i, column]

      if (iso_format == "true") {
        value = to_iso(value)
      }

      # Escape value if necessary
      if (index(value, OFS) != 0) {
        gsub("\"", "\"\"", value)
        value = "\"" value "\""
      }

      # Concatenate output line
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
