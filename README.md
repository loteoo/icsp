# icsp - iCalendar (.ics) parser

Small, fast and simple command-line tool to convert calendar exports (.ics files) into CSV files for easy analysis and usage in broader use-cases.

Combine this with CSV tools like [xsv](https://github.com/BurntSushi/xsv), [q](https://github.com/harelba/q), [csvkit](https://github.com/wireservice/csvkit) or [visidata](https://github.com/saulpw/visidata) for calendar data superpowers.

Works with a simple stream-in stream-out loop that can handle large files. Hand-written in pure bash.

## Installation

To install icsp, place the `icsp` script in your executable bin path, or alternatively, use the install script:

```sh
curl -sSL "https://raw.githubusercontent.com/loteoo/icsp/main/install" | sh
```

> (always check scripts before running them...)

With enough traction on the project, I will publish icsp to common package managers. (feel free to help!)

## Usage

Run `icsp -h` for usage.

```
icsp - iCalendar (.ics) parser. v0.2

Reads an iCalendar stream from stdin (or from a file)
and outputs a CSV of it's contents to stdout.

Usage:
  icsp [-h] [-c columns] [-d delimiter] [file ...]

Options:
  -c <string>   Comma seperated list of fields to parse. Order is preserved, case insensitive.
  -d <string>   Delimiter character to use for seperating values. Default: ','
  -h            Show this help text.
```

Basic examples:

```sh
# Basic usage
icsp calendar.ics > calendar.csv

# Display specific fields as TSV
icsp -c 'dtstart,summary,duration' -d $'\t' calendar.ics > calendar.tsv

# Download calendar from the internet as CSV
curl -s https://foobar/path/to/calendar.ics | icsp > calendar.csv
```

Advanced command-line example:

```sh
icsp \
  -c 'dtstart,summary,duration' \
  -d $'\t' \
  calendar.ics \
  | grep '2022-06' \
  | sort \
  | column -t -s $'\t' \
  | less -S
```

What each line does in order:

1. Only show the 'dtstart', 'summary' and 'duration' fields, in that order
1. Use a TAB character as the delimiter (tsv)
1. Use the calendar.ics file
1. Filter to June 2022 only
1. Sort chronologically
1. Align columns
1. Display result in scrollable area

## Demo commands

Canadian 2023 holidays

```sh
curl -s 'https://calendar.google.com/calendar/ical/en.canadian%23holiday%40group.v.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary \
  | grep 2023 \
  | sed 's/ 00:00:00//g' \
  | sort \
  | column -t -s , \
  | less -S
```

Montreal weather forecast in celsius:

```sh
curl -s 'https://ical.meteomatics.com/calendar/GC37%2B87%20Montreal%2C%20QC%2C%20Canada/45.503279_-73.586855/en/meteomat.ics' \
  | icsp -c dtstart,summary \
  | tail -n +2 \
  | sed 's/ 00:00:00//g' \
  | column -t -s ,
```

Phases of the Moon 2023:

```sh
curl -s 'https://calendar.google.com/calendar/ical/ht3jlfaac5lfd6263ulfh4tql8%40group.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary \
  | tail -n +2 \
  | sed 's/ 00:00:00//g' \
  | grep 2023 \
  | sort \
  | column -t -s ,
```

Space flight launch calendar:

```sh
curl -s 'https://calendar.google.com/calendar/ical/nextspaceflight.com_l328q9n2alm03mdukb05504c44%40group.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary,location -d $'\t' \
  | tail -n +2 \
  | sort \
  | column -t -s $'\t' \
  | less -S
```

</details>

I like to do these kind of manipulations on the command-line, but remember that you can always load these CSV files in your favorite programming language for maximum power and flexibility.

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

At the same time, they all provide very simple import/export features just a few clicks away using the iCalendar (.ics) format from 1998. Let's use that instead!

## Reading

#### Working with CSVs on the command-line:

- [CSVs on the CLI](https://bconnelly.net/posts/working_with_csvs_on_the_command_line/)
- [Command-Line data manipulation](https://planspace.org/2013/05/21/command-line-data-manipulation/)
- [CLI data scripting intro](https://compphylo.github.io/Oslo2019/Scripting_CLI_Intro/Scripting_CLI_Intro.html)
- [Singapore university data manipulation intro](https://nusit.nus.edu.sg/technus/data-manipulation-and-more-with-the-command-line/)
- [More CLI tools](https://github.com/dbohdan/structured-text-tools)

#### iCalendar:

- [icalendar.org](https://icalendar.org/) - iCalendar docs & tools
- [RFC5545](https://datatracker.ietf.org/doc/html/rfc5545) - iCalendar RFC

---

PRs, issues and ideas are welcome.

Give the repo a star to show your support! ❤️
