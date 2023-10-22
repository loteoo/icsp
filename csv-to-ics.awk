function to_timestamp(iso_dt) {
  if (length(iso_dt) ~ /19|20/) {
    Y = substr(iso_dt, 1, 4)
    M = substr(iso_dt, 6, 2)
    D = substr(iso_dt, 9, 2)
    h = substr(iso_dt, 12, 2)
    m = substr(iso_dt, 15, 2)
    s = substr(iso_dt, 18, 2)
    Z = substr(iso_dt, 20, 1)
    return Y M D "T" h m s Z
  } else if (length(iso_dt) == 10) {
    Y = substr(iso_dt, 1, 4)
    M = substr(iso_dt, 6, 2)
    D = substr(iso_dt, 9, 2)
    return Y M D
  }
}

BEGIN {
  print "BEGIN:VCALENDAR"
}

NR == 1 {
  split($0, fields, FS)
}

NR != 1 {
  print "BEGIN:VEVENT"
  for (i = 1; i <= NF; i++) {
    key = toupper(fields[i])
    value = $i
    if (value == "" || key ~ /DURATION/) {
      continue
    }
    if (key ~ /DTSTART|DTEND|DTSTAMP|CREATED|LAST-MOD/ && value ~ /-|:/) {
      value = to_timestamp(value)
    }
    print key ":" value
  }
  print "END:VEVENT"
}

END {
  print "END:VCALENDAR"
}
