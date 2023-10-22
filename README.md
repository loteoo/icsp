# icsp - iCalendar (.ics) parser

Small, fast and simple command-line tool to convert calendar exports (.ics files) into TSV/CSV files for easy analysis and usage in broader use-cases

Combine this with CSV tools like [xsv](https://github.com/BurntSushi/xsv), [q](https://github.com/harelba/q), [csvkit](https://github.com/wireservice/csvkit) or [visidata](https://github.com/saulpw/visidata) for calendar data superpowers.

Written in pure bash and AWK. Compatible with most unix systems (ubuntu, macOS or windows with WSL).

## Installation

To install icsp, you can use the install script:

```sh
bash <(curl -fsSL "https://raw.githubusercontent.com/loteoo/icsp/main/install")
```

<details><summary>Or, do a manual installation (click to expand):</summary>

1. Download the repo (via git clone or .zip download) and keep it somewhere
2. Create a symlink from an executable BIN directory (such as /usr/local/bin, ~/.local/bin or ~/bin) to the `icsp` file in the directory that you downloaded.

Example:
```sh
#         This bin directory should be in your executable $PATH
#                                     /
ln -s ~/my-repos/icsp/icsp ~/.local/bin/icsp
#                       \
#     This should be the actual icsp script file
```

</details>

## Usage

Run `icsp -h` for usage.

```
icsp - iCalendar (.ics) parser. v1.0.0

Convert iCalendar files to (and from) TSV files.

Usage:
  icsp [-c columns] [-d delimiter] [-x component] [-nrh] [...files]

Options:
  -c <string>   Comma seperated list of fields to parse. Order is preserved, case insensitive.
  -d <string>   Delimiter character to use for seperating values. Default: '\t' (TAB character)
  -x <string>   ICS component to parse. Default: VEVENT
  -n            No date conversion (faster processing, no DURATION column, no ISO format)
  -r            Reverse conversion (Build ICS file from TSV)
  -h            Show this help text.
```

Basic examples:

```sh
# Simple usage
icsp calendar.ics > calendar.tsv

# Custom delimiter
icsp -d ',' calendar.ics > calendar.csv

# Display specific fields
icsp -c 'dtstart,summary,duration' calendar.ics > calendar.tsv

# Download calendar from the internet as TSV
curl https://foobar/path/to/calendar.ics | icsp > calendar.tsv

# Convert TSV file to iCalendar file
icsp -r calendar.tsv > calendar.ics
```

#### Usage notes:

For the `-c` option, if you don't specify it, icsp will return all fields found in the .ics file, sorted by how often they are populated. This is useful to quickly check what's in a file, but it is also usually pretty messy, so specifying the wanted columns and their order is probably recommended.

There is also a special `duration` column you can specify via `-c` that will be computed by icsp (unless already supplied by the iCalendar file). This is often useful because calendar providers usually don't provide this value directly even if it's really useful for viewing the calendar data.

The default delimiter for the `-d` option is a TAB character (TSV), instead of a comma (CSV), because tab delimited files have a much better chance of not needing to escape the field delimiter within the values, which makes it more likely to be command-line friendly by default.

The `-x` option lets you parse iCalendar objects other than events if needed. The default value is "VEVENT" for events, but other values could be, for example: "VTODO", "VJOURNAL" "VFREEBUSY" "VTIMEZONE" "VALARM".

The `-n` option skips external calls to the `date` command which makes the processing much faster and might avoid issues if you don't have a normal `date` command available on your system. Downside is: no ISO timestamps, and no DURATION computation.

The `-r` option is for creating ics files from tabular files, because why not! This will also take care of converting the ISO timestamps back into the iCalendar format if necessary. This is somewhat of a "experimental" feature right now, since there's a lot of options that this could open the door to that we don't support. For now it just creates a bare-bones, minimal ics file with zero metadata.


## Advanced examples

```sh
icsp -c 'dtstart,summary,duration' calendar.ics \
  | grep '2022-06' \
  | sort \
  | column -t -s $'\t' \
  | less -S
```

What each line does in order:

1. Only show the 'dtstart', 'summary' and 'duration' fields, in that order from the 'calendar.ics' file
1. Filter to June 2022 only
1. Sort chronologically
1. Align columns (using `column` command)
1. Display result in scrollable area (using `less`` command)

#### Demo commands

Canadian 2023 holidays

```sh
curl -s 'https://calendar.google.com/calendar/ical/en.canadian%23holiday%40group.v.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary \
  | grep 2023 \
  | sort \
  | column -t -s $'\t' \
  | less -S
```

Montreal weather forecast in celsius:

```sh
curl -s 'https://ical.meteomatics.com/calendar/GC37%2B87%20Montreal%2C%20QC%2C%20Canada/45.503279_-73.586855/en/meteomat.ics' \
  | icsp -c dtstart,summary \
  | tail -n +2 \
  | column -t -s $'\t'
```

Phases of the Moon 2023:

```sh
curl -s 'https://calendar.google.com/calendar/ical/ht3jlfaac5lfd6263ulfh4tql8%40group.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary \
  | tail -n +2 \
  | grep 2023 \
  | sort \
  | column -t -s $'\t'
```

Space flight launch calendar:

```sh
curl -s 'https://calendar.google.com/calendar/ical/nextspaceflight.com_l328q9n2alm03mdukb05504c44%40group.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary,location \
  | tail -n +2 \
  | sort \
  | column -t -s $'\t' \
  | less -S
```

Merge calendars together:

```sh
curl -s 'https://calendar.google.com/calendar/ical/nextspaceflight.com_l328q9n2alm03mdukb05504c44%40group.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary,location \
  | tail -n +2 \
  | sort \
  | column -t -s $'\t' \
  | less -S
```

I like to do these kind of manipulations on the command-line, but remember that you can always load these TSV/CSV files in your favorite programming language for maximum power and flexibility.

## How to get some .ics files to try it out:

<details><summary>From Google Calendar</summary>

<img src="https://user-images.githubusercontent.com/14101189/227659925-cbc204bc-95e0-4bf6-be2e-686ed1fd815f.png" width="320" alt="Step 1" />

<img src="https://user-images.githubusercontent.com/14101189/227659927-93e7b7f7-0534-45f9-8e77-c0ef242dd567.png" width="720" alt="Step 2" />
</details>

<details><summary>From Outlook</summary>

<img src="https://user-images.githubusercontent.com/14101189/227634762-6229a640-654f-4b2a-8ab5-6acbf4ab7524.png" width="320" alt="Step 2" />

<img src="https://user-images.githubusercontent.com/14101189/227635163-3136bc60-656e-42e1-b0f9-87c67a6c85ac.png" width="720" alt="Step 2" />

<img src="https://user-images.githubusercontent.com/14101189/227633645-d9fa440e-5380-42c7-bf5d-72dc816f7021.png" width="280" alt="Step 3" />
</details>


## Motivation

While common calendar software (Google, outlook, apple calendars, etc) may provide API access to your calendar data, it is usually a very involved setup that requires changing account configuration or permissions, dealing with authentication / authorization and reading company specific docs.

At the same time, they all provide very simple import/export features just a few clicks away using the iCalendar (.ics) format from 1998. If we just want to read in data, let's use that instead!

## Reading

#### iCalendar:

- [RFC5545](https://datatracker.ietf.org/doc/html/rfc5545) - iCalendar RFC
- [icalendar.org](https://icalendar.org/) - iCalendar docs & tools

#### Working with tabular data on the command-line:

- [CSVs on the CLI](https://bconnelly.net/posts/working_with_csvs_on_the_command_line/)
- [Command-Line data manipulation](https://planspace.org/2013/05/21/command-line-data-manipulation/)
- [CLI data scripting intro](https://compphylo.github.io/Oslo2019/Scripting_CLI_Intro/Scripting_CLI_Intro.html)
- [Singapore university data manipulation intro](https://nusit.nus.edu.sg/technus/data-manipulation-and-more-with-the-command-line/)
- [More CLI tools](https://github.com/dbohdan/structured-text-tools)

---

PRs, issues and ideas are welcome.

Give the repo a star to show your support! ❤️
