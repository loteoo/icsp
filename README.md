# icsp - iCalendar (.ics) parser

Fast and simple command-line tool to convert calendar exports (.ics files) into CSV files for easy analysis and usage in broader use-cases.

Combine this with CSV tools such as [xsv](https://github.com/BurntSushi/xsv), [q](https://github.com/harelba/q) or [csvkit](https://github.com/wireservice/csvkit) for calendar data superpowers.

## Installation
Run this to put the script in your bin path and make sure it's executable:
```sh
USR_BIN_PATH="$HOME/bin"
SCRIPT_PATH="$USR_BIN_PATH/icsp"
mkdir -p "$USR_BIN_PATH"
curl -s https://raw.githubusercontent.com/loteoo/icsp/main/icsp -o $SCRIPT_PATH
chmod +x $SCRIPT_PATH
icsp -h
```

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

![Step 1](https://user-images.githubusercontent.com/14101189/227633230-1565bac9-4be6-46be-9e88-55429447592c.png)
![Step 2](https://user-images.githubusercontent.com/14101189/227633260-6ef82b3f-6706-43c6-b3b4-adb2d3350657.png)
</details>

<details><summary>From Outlook</summary>

![Step 2](https://user-images.githubusercontent.com/14101189/227634762-6229a640-654f-4b2a-8ab5-6acbf4ab7524.png)
![Step 2](https://user-images.githubusercontent.com/14101189/227635163-3136bc60-656e-42e1-b0f9-87c67a6c85ac.png)
![Step 3](https://user-images.githubusercontent.com/14101189/227633645-d9fa440e-5380-42c7-bf5d-72dc816f7021.png)
</details>


## Motivation

While common calendar software (Google, outlook, apple calendars, etc) may provide API access to your calendar data, it is usually a very involved setup that requires changing account configuration or permissions, dealing with authentication / authorization and reading company specific docs to get to work. 

At the same time they all provide very simple import/export features just a few clicks away using the iCalendar (.ics) format since 1998. Let's use that instead!

---

PRs, issues and ideas are welcome.

Give the repo a star to show your support! ❤️ 
