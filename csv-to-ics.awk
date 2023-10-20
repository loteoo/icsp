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
    if ($i != "" && key !~ /DURATION/) {
      print key ":" $i
    }
  }
  print "END:VEVENT"
}

END {
  print "END:VCALENDAR"
}
