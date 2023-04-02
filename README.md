# icsp - iCalendar (.ics) parser

Small, fast and simple command-line tool to convert calendar exports (.ics files) into CSV files for easy analysis and usage in broader use-cases.

Combine this with CSV tools like [xsv](https://github.com/BurntSushi/xsv), [q](https://github.com/harelba/q), [csvkit](https://github.com/wireservice/csvkit) or [visidata](https://github.com/saulpw/visidata) for calendar data superpowers.

Works with a simple stream-in stream-out loop that can handle large files. Hand-written in pure bash.

## Installation

To install the script, place it in your bin path and make sure it's executable, or alternatively, run this install script (bash):

```sh
# Always check scripts before running them...
sh <(curl -sSL https://raw.githubusercontent.com/loteoo/icsp/main/install)
```

With enough traction on the project, I will create proper installers and publish it to common package managers.

## Usage examples

Run `icsp -h` for usage.

```sh
# Basic usage
icsp calendar.ics > calendar.csv

# Download calendar from the internet as CSV
curl -s https://foobar/path/to/calendar.ics | icsp > calendar.csv

# Display specified fields in scrollable table format using 'column' and 'less' command
icsp -c 'dtstart,summary,duration' -d '|' calendar.ics | column -t -s '|' | less -S
```

### Demo commands

Canadian 2023 holidays
```sh
curl -s 'https://calendar.google.com/calendar/ical/en.canadian%23holiday%40group.v.calendar.google.com/public/basic.ics' \
  | icsp -c dtstart,summary,location \
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
  | tail -n +2 \
  | icsp -c dtstart,summary,location -d ';' \
  | sort \
  | column -t -s ';' \
  | less -S
```
</details>

### How to get some .ics files to try it out:

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

- [icalendar.org](https://icalendar.org/) - iCalendar docs & tools
- [RFC5545](https://datatracker.ietf.org/doc/html/rfc5545) - iCalendar RFC

---

PRs, issues and ideas are welcome.

Give the repo a star to show your support! ❤️
