function run_cmd(cmd) {
  cmd | getline out
  close(cmd)
  return out
}

function get_dt_type(dt) {
  date_part = substr(dt, 1, 8)
  T_part = substr(dt, 9, 1)
  time_part = substr(dt, 10, 6)
  Z_part = substr(dt, 16, 1)
  if (length(dt) == 8 && date_part !~ /[^0-9]/) {
    return "date"
  }
  if (length(dt) == 15 && date_part !~ /[^0-9]/ && T_part == "T" && time_part !~ /[^0-9]/) {
    return "datetime"
  }
  if (length(dt) == 16 && date_part !~ /[^0-9]/ && T_part == "T" && time_part !~ /[^0-9]/ && Z_part == "Z" ) {
    return "utc datetime"
  }
}

function to_iso(dt) {
  dt_type = get_dt_type(dt)
  if (dt_type == "date") {
    Y = substr(dt, 1, 4)
    M = substr(dt, 5, 2)
    D = substr(dt, 7, 2)
    return Y "-" M "-" D
  } else if (dt_type == "datetime") {
    Y = substr(dt, 1, 4)
    M = substr(dt, 5, 2)
    D = substr(dt, 7, 2)
    h = substr(dt, 10, 2)
    m = substr(dt, 12, 2)
    s = substr(dt, 14, 2)
    return Y "-" M "-" D " " h ":" m ":" s
  } else if (dt_type == "utc datetime") {
    Y = substr(dt, 1, 4)
    M = substr(dt, 5, 2)
    D = substr(dt, 7, 2)
    h = substr(dt, 10, 2)
    m = substr(dt, 12, 2)
    s = substr(dt, 14, 2)
    return Y "-" M "-" D " " h ":" m ":" s "Z"
  }
  print "Unrecognized format: " dt
}

function get_iso_format(iso_dt) {
  format = "%Y-%m-%d %H:%M:%SZ"
  if (length(iso_dt) == 19) {
    format = "%Y-%m-%d %H:%M:%S"
  } else if (length(iso_dt) == 10) {
    format = "%Y-%m-%d"
  }
  return format
}

function dt_format_local(dt, output_format) {
  iso_dt = to_iso(dt)
  date_command = "date -d '" iso_dt "' '" output_format "'"
  if (date_cmd_type == "bsd") {
    date_command = "date -jf '" get_iso_format(iso_dt) "' -v '" tz_offset "M' '" iso_dt "' '" output_format "'"
  }
  return run_cmd(date_command)
}

function get_duration(dtstart, dtend) {
  start = dt_format_local(dtstart, "+%s")
  end = dt_format_local(dtend, "+%s")
  seconds = end - start
  hours = seconds / 3600
  decimal_index = index(hours, ".")
  if (decimal_index == "0") {
    return hours "h"
  }
  decimals = substr(hours, decimal_index + 1, length(hours))
  hour = substr(hours, 0, decimal_index - 1)
  minutes = int(("0." decimals) * 60)
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

function get_tz_offset(tzid) {
  tzid_prefix = ""
  if (tzid != "") {
    tzid_prefix = "TZ=" tzid " "
  }
  check_tz_offset = tzid_prefix "date +%z"
  check_tz_offset | getline tz_offset_str
  close(check_tz_offset)
  tz_d = substr(tz_offset_str, 1, 1)
  tz_h = substr(tz_offset_str, 2, 2)
  tz_m = substr(tz_offset_str, 4, 2)
  tz_offset = tz_d ((tz_h * 60) + tz_m)
  return tz_offset
}

BEGIN {
  FS = "\t" # FS is a tab character because we expect a pre-formatted 
  # ICS stream that uses tab characters as the delimiter for key-value pairs.

  # "OFS" variable is set by icsp via the "-d" option.

  # "columns" variable is set by icsp via the "-c" option.
  # It represents which fields of the iCalendar object we want to include in the output.
  # Default: "" (empty string means all fields)

  # "component" variable is set by icsp via the "-x" option.
  # It represents which iCalendar object we want to parse.
  # Default: "VEVENT"
  # Other possible values: "VTODO", "VJOURNAL" "VFREEBUSY" "VTIMEZONE" "VALARM"

  # "no_iso" variable is set by icsp via the "-n" option.
  # Disables ISO conversion via "date" command. Faster processing but inconvenient format

  idx = 0 # Current object "index", counts up to the total number of rows.
  in_component = 0 # Whether or not the current line is within the specified component

  date_cmd_type = get_date_cmd_type()
  tz_offset = get_tz_offset()
}

# Register calendar's timezone
idx == 0 && $1 ~ /TZID|TIMEZONE/ {
  tz_offset = get_tz_offset($2)
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
in_component == 1 && $1 != "" && $2 != "" {
  found_cols[$1] = found_cols[$1] + 1
  values[idx, $1] = $2
}

END {
  # If no columns were specified, create a list of columns 
  # sorted by how often they had a value in the file.
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
    line_out = "\0"

    if (no_iso == "" && headers ~ /DURATION/ && values[i, "DURATION"] == "" && values[i, "DTSTART"] != "" && values[i, "DTEND"] != "") {
      values[i, "DURATION"] = get_duration(values[i, "DTSTART"], values[i, "DTEND"])
    }

    # Loop columns
    for (k = 0; k < length(cols_array); k++) {
      column = cols_array[k]
      value = values[i, column]

      if (no_iso == "" && column ~ /DTSTART|DTEND|DTSTAMP|CREATED|LAST-MOD/) {
        dt_type = get_dt_type(value)
        if (dt_type != "") {
          if (dt_type == "utc datetime") {
            value = dt_format_local(value, "+%Y-%m-%d %H:%M:%S")
          } else {
            value = to_iso(value)
          }
        }
      }

      # Escape value if necessary
      if (index(value, OFS) != 0) {
        gsub("\"", "\"\"", value)
        value = "\"" value "\""
      }

      # Concatenate output line
      if (line_out == "\0") {
        line_out = value 
      } else {
        line_out = line_out OFS value
      }
    }

    # Print row
    if (line_out != "\0") {
      print line_out
    }
  }
}
