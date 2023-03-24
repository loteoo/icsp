# icsp - iCalendar (.ics) parser

Fast and simple command-line tool to convert calendar exports (.ics files) into CSV files for easy analysis and usage in broader use-cases.

Combine this with CSV tools such as [xsv](https://github.com/BurntSushi/xsv), [q](https://github.com/harelba/q) or [csvkit](https://github.com/wireservice/csvkit) for calendar data superpowers.

## Installation
To install the script, put it in your bin path and make sure it's executable.

Alternatively run this install script (bash):
```sh
# Always check scripts before running them...
sh <(curl -sSL https://raw.githubusercontent.com/loteoo/icsp/main/install)
```

With enough traction on the project, I will create proper installers and publish it to common package managers.

## Usage examples
Run `icsp -h` for usage.

Examples:

```sh
# Basic usage
icsp calendar.ics > calendar.csv

# Download calendar from the internet as CSV
curl -s https://foobar/path/to/calendar.ics | icsp > calendar.csv

# Display specified fields in table format using 'column' command
icsp -c 'DTSTART,DTEND,SUMMARY' calendar.ics | column -t -s ','
```

How to get some .ics files to try it out:

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

---

PRs, issues and ideas are welcome.

Give the repo a star to show your support! ❤️ 
