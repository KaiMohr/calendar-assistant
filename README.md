# calendar assistant

A command-line tool to help you manage your Google Calendar.

- easily join the videoconference for your current meeting
- see yours and others' "availability" suitable for an email response
- set up all-day events to let people know where you are (for frequent travelers)
- see views on your calendar events for a date or time range
- book (and re-book) one-on-ones and other meetings automatically

[![Concourse CI](https://ci.nokogiri.org/api/v1/teams/calendar-assistants/pipelines/calendar-assistant/jobs/rake-spec/badge)](https://ci.nokogiri.org/teams/calendar-assistants/pipelines/calendar-assistant)
[![Maintainability](https://api.codeclimate.com/v1/badges/3525792e1feeccfd8875/maintainability)](https://codeclimate.com/github/flavorjones/calendar-assistant/maintainability)

<!-- toc -->

- [Features](#features)
  * [Pretty Display in Your Terminal](#pretty-display-in-your-terminal)
  * [Human-Friendly Date and Time Specification](#human-friendly-date-and-time-specification)
  * [Human-Friendly Duration Specification](#human-friendly-duration-specification)
  * [Preferences](#preferences)
- [Setup](#setup)
  * [Installation](#installation)
  * [Set up a Google Cloud Project with API access](#set-up-a-google-cloud-project-with-api-access)
  * [Authorize access to your Google Calendar](#authorize-access-to-your-google-calendar)
- [Commands](#commands)
  * [Join a video call attached to a meeting](#join-a-video-call-attached-to-a-meeting)
  * [Find your availability for meetings](#find-your-availability-for-meetings)
  * [Tell people where you are at in the world](#tell-people-where-you-are-at-in-the-world)
  * [Look up where you're going to be](#look-up-where-youre-going-to-be)
  * [Display your calendar events](#display-your-calendar-events)
  * [View your configuration parameters](#view-your-configuration-parameters)
- [Development](#development)
  * [Tests](#tests)
  * [Generate README](#generate-readme)
- [References](#references)
- [License](#license)

<!-- tocstop -->

## Features

### Pretty Display in Your Terminal

Events are nicely formatted, with faint strikeouts for events you've declined, and some additional attributes listed when present (e.g., "awaiting", "self", "not-busy", "1:1" ...)


### Human-Friendly Date and Time Specification

All dates and times are interpreted by [Chronic](https://github.com/mojombo/chronic) and so can be fuzzy terms like "tomorrow", "tuesday", "next thursday", and "two days from now" as well as specific dates and times.

For a date range or a datetime range, split the start and end with `..` or `...` (with or without spaces) like:

* "tomorrow ... three days from now"
* "2018-09-24..2018-09-27".

Also note that every command will adopt an intelligent default, which is generally "today" or "now".


### Human-Friendly Duration Specification

Some duration-related preferences are interpreted by [ChronicDuration](https://github.com/henrypoydar/chronic_duration) and so can be terms like "10m", "30 minutes", "four hours", etc.


### Preferences

All tokens and preferences will be stored in `~/.calendar-assistant` which is in TOML format for easy editing.


## Setup

### Installation

Install the gem: `gem install calendar-assistant`.


### Set up a Google Cloud Project with API access

<pre>
Usage:
  calendar-assistant setup

Options:
  -h, -?, [--help], [--no-help]    
          [--debug], [--no-debug]  # how dare you suggest there are bugs

Description:
  This command will walk you through setting up a Google Cloud Project, enabling the Google Calendar 
  API, and saving the credentials necessary to access the API on behalf of users.

  If you already have downloaded client credentials, you don't need to run this command. Instead, 
  rename the downloaded JSON file to `/home/user/.calendar-assistant.client`
</pre>


### Authorize access to your Google Calendar

<pre>
Usage:
  calendar-assistant authorize PROFILE_NAME

Options:
  -h, -?, [--help], [--no-help]    
          [--debug], [--no-debug]  # how dare you suggest there are bugs

Description:
  Create and authorize a named profile (e.g., "work", "home", "flastname@company.tld") to access 
  your calendar.

  When setting up a profile, you'll be asked to visit a URL to authenticate, grant authorization, 
  and generate and persist an access token.

  In order for this to work, you'll need to have set up your API client credentials. Run 
  `calendar-assistant help setup` for instructions.
</pre>


## Commands

<pre>
Commands:
  calendar-assistant authorize PROFILE_NAME                       # create (or validate) a profil...
  calendar-assistant availability [DATE | DATERANGE | TIMERANGE]  # Show your availability for a ...
  calendar-assistant config                                       # Dump your configuration param...
  calendar-assistant help [COMMAND]                               # Describe available commands o...
  calendar-assistant join [TIME]                                  # Open the URL for a video call...
  calendar-assistant location [DATE | DATERANGE]                  # Show your location for a date...
  calendar-assistant location-set LOCATION [DATE | DATERANGE]     # Set your location to LOCATION...
  calendar-assistant setup                                        # Link your local calendar-assi...
  calendar-assistant show [DATE | DATERANGE | TIMERANGE]          # Show your events for a date o...
  calendar-assistant version                                      # Display the version of calend...

Options:
  -h, -?, [--help], [--no-help]    
          [--debug], [--no-debug]  # how dare you suggest there are bugs
</pre>


### Join a video call attached to a meeting

<pre>
Usage:
  calendar-assistant join [TIME]

Options:
          [--join], [--no-join]     # launch a browser to join the video call URL
                                    # Default: true
  -p, [--profile=PROFILE]           # the profile you'd like to use (if different from default)
          [--local-store=FILENAME]  # Load events from a local file instead of Google Calendar
  -h, -?, [--help], [--no-help]     
          [--debug], [--no-debug]   # how dare you suggest there are bugs

Open the URL for a video call attached to your meeting at time TIME (default 'now')
</pre>

Some examples:

<pre>
<b>$</b> calendar-assistant join
<i>me@example.com</i>

2018-10-01  11:30 - 12:00<b> | Facilitate customized web-readiness </b><i> (1:1, recurring)</i>

https://pivotal.zoom.us/j/ABC90210 <i># ... and opens the videoconference URL</i>


<b>$</b> calendar-assistant join work 11:30 --no-join
<i>me@example.com</i>

2018-10-01  11:30 - 12:00<b> | Facilitate customized web-readiness </b><i> (1:1, recurring)</i>

https://pivotal.zoom.us/j/ABC90210 <i># ... and does not open the URL</i>
</pre>


### Find your availability for meetings

This is useful for emailing people your availability. It only considers `accepted` meetings when determining busy/free.

<pre>
Usage:
  calendar-assistant availability [DATE | DATERANGE | TIMERANGE]

Options:
  -l, [--meeting-length=LENGTH]     # [default 30m] find chunks of available time at least as long as LENGTH (which is a ChronicDuration string like '30m' or '2h')
  -s, [--start-of-day=TIME]         # [default 9am] find chunks of available time after TIME (which is a BusinessTime string like '9am' or '14:30')
  -e, [--end-of-day=TIME]           # [default 6pm] find chunks of available time before TIME (which is a BusinessTime string like '9am' or '14:30')
  -r, [--required=ATTENDEE]         # Find availability for someone else
  -p, [--profile=PROFILE]           # the profile you'd like to use (if different from default)
          [--local-store=FILENAME]  # Load events from a local file instead of Google Calendar
  -h, -?, [--help], [--no-help]     
          [--debug], [--no-debug]   # how dare you suggest there are bugs

Show your availability for a date or range of dates (default 'today')
</pre>


For example: show me my available time over a chunk of time:

<pre>
<b>$</b> calendar-assistant avail 2018-11-05..2018-11-07
<i>me@example.com
- looking for blocks at least 30 mins long
- between 9am and 6pm in America/New_York
</i>
<b>Availability on Monday, November 5:
</b>
 •  9:00am - 10:00am EST <i>(1h)</i>
 •  1:30pm -  2:30pm EST <i>(1h)</i>
 •  3:30pm -  5:00pm EST <i>(1h 30m)</i>
 •  5:30pm -  6:00pm EST <i>(30m)</i>

<b>Availability on Tuesday, November 6:
</b>
 •  9:00am -  4:30pm EST <i>(7h 30m)</i>
 •  4:50pm -  6:00pm EST <i>(1h 10m)</i>

<b>Availability on Wednesday, November 7:
</b>
 •  9:00am -  2:30pm EST <i>(5h 30m)</i>
 •  5:30pm -  6:00pm EST <i>(30m)</i>
</pre>


You can also set start and end times for the search, which is useful when looking for overlap with another time zone:

<pre>
<b>$</b> calendar-assistant avail 2018-11-05..2018-11-07 -s 12pm -e 7pm
<i>me@example.com
- looking for blocks at least 30 mins long
- between 12pm and 7pm in America/New_York
</i>
<b>Availability on Monday, November 5:
</b>
 •  1:30pm -  2:30pm EST <i>(1h)</i>
 •  3:30pm -  5:00pm EST <i>(1h 30m)</i>
 •  5:30pm -  7:00pm EST <i>(1h 30m)</i>

<b>Availability on Tuesday, November 6:
</b>
 • 12:00pm -  4:30pm EST <i>(4h 30m)</i>
 •  4:50pm -  7:00pm EST <i>(2h 10m)</i>

<b>Availability on Wednesday, November 7:
</b>
 • 12:00pm -  2:30pm EST <i>(2h 30m)</i>
 •  5:30pm -  7:00pm EST <i>(1h 30m)</i>
</pre>


### Tell people where you are at in the world

Declare your location as an all-day non-busy event:

<pre>
Usage:
  calendar-assistant location-set LOCATION [DATE | DATERANGE]

Options:
  -p, [--profile=PROFILE]           # the profile you'd like to use (if different from default)
          [--local-store=FILENAME]  # Load events from a local file instead of Google Calendar
  -h, -?, [--help], [--no-help]     
          [--debug], [--no-debug]   # how dare you suggest there are bugs

Set your location to LOCATION for a date or range of dates (default 'today')
</pre>

**Note** that you can only be in one place at a time, so existing location events may be modified or deleted when new overlapping events are created.

Some examples:

<pre>
<i># create an event titled `🗺 WFH` for today</i>
<b>$</b> calendar-assistant location set -p home WFH
<b>Created:</b>
2018-09-03                | <b>🗺  WFH</b> (not-busy, self)

<i># create an event titled `🗺 OOO` for tomorrow</i>
<b>$</b> calendar-assistant location-set OOO tomorrow
<b>Created:</b>
2018-09-04                | <b>🗺  OOO</b> (not-busy, self)

<i># create an event titled `🗺 Spring One` on the days of that conference</i>
<b>$</b> calendar-assistant location-set "Spring One" 2018-09-24...2018-09-27
<b>Created:</b>
2018-09-24 - 2018-09-27   | <b>🗺  Spring One</b> (not-busy, self)

<i># create a vacation event for next week</i>
<b>$</b> calendar-assistant location-set "Vacation!" "next monday ... next week friday"
<b>Created:</b>
2018-09-10 - 2018-09-14   | <b>🗺  Vacation!</b> (not-busy, self)
</pre>


### Look up where you're going to be

<pre>
Usage:
  calendar-assistant location [DATE | DATERANGE]

Options:
  -p, [--profile=PROFILE]           # the profile you'd like to use (if different from default)
          [--local-store=FILENAME]  # Load events from a local file instead of Google Calendar
  -h, -?, [--help], [--no-help]     
          [--debug], [--no-debug]   # how dare you suggest there are bugs

Show your location for a date or range of dates (default 'today')
</pre>

For example:

<pre>
<b>$</b> calendar-assistant location "2018-09-24...2018-09-28"
<i>me@example.com (all times in America/New_York)
</i>
2018-09-24 - 2018-09-28  <b> | 🗺 Iron Hills</b><i> (not-busy)</i>
2018-09-28               <b> | 🗺 The Great Mill</b><i> (not-busy)</i>
</pre>


### Display your calendar events

<pre>
Usage:
  calendar-assistant show [DATE | DATERANGE | TIMERANGE]

Options:
  -c, [--commitments], [--no-commitments]  # only show events that you've accepted with another person
  -r, [--required=ATTENDEE]                # Show events from someone else's calendar
  -p, [--profile=PROFILE]                  # the profile you'd like to use (if different from default)
          [--local-store=FILENAME]         # Load events from a local file instead of Google Calendar
  -h, -?, [--help], [--no-help]            
          [--debug], [--no-debug]          # how dare you suggest there are bugs

Show your events for a date or range of dates (default 'today')
</pre>

For example: display all events scheduled for tomorrow:

<pre>
<b>$</b> calendar-assistant show 2018-10-01
<i>me@example.com (all times in America/New_York)
</i>
<strike>2018-10-01  03:30 - 05:00 | Strategize out-of-the-box e-commerce</strike>
<strike>2018-10-01  07:30 - 08:30 | Scale dot-com e-tailers</strike>
<strike>2018-10-01  07:30 - 08:30 | Synthesize 24/365 functionalities</strike>
2018-10-01  10:30 - 10:55<b> | Leverage sticky convergence</b><i> (1:1, recurring)</i>
2018-10-01  11:00 - 11:30<b> | Incentivize b2b convergence</b><i> (recurring)</i>
2018-10-01  11:30 - 12:00<b> | Implement killer e-markets</b><i> (1:1, recurring)</i>
<strike>2018-10-01  11:50 - 12:00 | Empower cross-platform interfaces</strike>
2018-10-01  12:00 - 12:30<b> | Monetize efficient vortals</b><i> (self)</i>
<strike>2018-10-01  12:15 - 12:30 | Aggregate web-enabled platforms</strike>
<strike>2018-10-01  12:30 - 13:30 | Reinvent rich bandwidth</strike>
2018-10-01  12:30 - 13:30<b> | Leverage compelling bandwidth</b><i> (recurring)</i>
2018-10-01  13:30 - 14:50<b> | Utilize granular experiences</b><i> (self)</i>
<strike>2018-10-01  13:30 - 14:30 | Implement robust platforms</strike>
2018-10-01  15:00 - 15:30<b> | Benchmark impactful systems</b><i> (1:1)</i>
2018-10-01  16:00 - 17:00<b> | Synergize seamless markets</b><i> (1:1, recurring)</i>
2018-10-01  16:45 - 17:00<b> | Syndicate robust action-items</b><i> (recurring)</i>
2018-10-01  17:00 - 17:30<b> | Recontextualize viral architectures</b><i> (recurring)</i>
2018-10-01  17:30 - 17:55<b> | Whiteboard strategic markets</b><i> (1:1, recurring)</i>
<strike>2018-10-01  18:00 - 20:30 | E-enable sexy web-readiness</strike>
<strike>2018-10-01  18:30 - 19:00 | Deliver end-to-end deliverables</strike>
<strike>2018-10-01  19:00 - 19:30 | Mesh sticky systems</strike>
2018-10-01               <b> | 🗺 Mines of Moria</b><i> (not-busy)</i>
</pre>

Display _only_ the commitments I have to other people using the `-c` option:

<pre>
<b>$</b> calendar-assistant show -c 2018-10-01
<i>me@example.com (all times in America/New_York)
</i>
2018-10-01  10:30 - 10:55<b> | Leverage sticky convergence</b><i> (1:1, recurring)</i>
2018-10-01  11:00 - 11:30<b> | Incentivize b2b convergence</b><i> (recurring)</i>
2018-10-01  11:30 - 12:00<b> | Implement killer e-markets</b><i> (1:1, recurring)</i>
2018-10-01  12:30 - 13:30<b> | Leverage compelling bandwidth</b><i> (recurring)</i>
2018-10-01  15:00 - 15:30<b> | Benchmark impactful systems</b><i> (1:1)</i>
2018-10-01  16:00 - 17:00<b> | Synergize seamless markets</b><i> (1:1, recurring)</i>
2018-10-01  16:45 - 17:00<b> | Syndicate robust action-items</b><i> (recurring)</i>
2018-10-01  17:00 - 17:30<b> | Recontextualize viral architectures</b><i> (recurring)</i>
2018-10-01  17:30 - 17:55<b> | Whiteboard strategic markets</b><i> (1:1, recurring)</i>
2018-10-01               <b> | 🗺 Mines of Moria</b><i> (not-busy)</i>
</pre>


### View your configuration parameters

Calendar Assistant has intelligent defaults, which can be overridden in the TOML file `~/.calendar-assistant`, and further overridden via command-line parameters. Sometimes it's nice to be able to see what defaults Calendar Assistant is using:

<pre>
Usage:
  calendar-assistant config

Options:
  -h, -?, [--help], [--no-help]    
          [--debug], [--no-debug]  # how dare you suggest there are bugs

Dump your configuration parameters (merge of defaults and overrides from /home/user/.calendar-assistant)
</pre>

The output is TOML, which is suitable for dumping into `~/.calendar-assistant` and editing.

<pre>
<b>$</b> calendar-assistant config

[settings]
end-of-day = "6pm"
meeting-length = "30m"
profile = "work"
start-of-day = "9am"
</pre>

## Development

### Tests

```bash
gem install bundler
bundle install

rake spec
```

### Generate README

* Requires npm to be installed
* Will use a fixture file rather than connecting to a remote calendar. Fixtures can be updated/regenerated in [generate-fixtures](generate-fixtures) script

```bash
./generate-readme
```

## References

Google Calendar Concepts: https://developers.google.com/calendar/concepts/

Google Calendar API Reference: https://developers.google.com/calendar/v3/reference/

Google Calendar Ruby Client Docs: https://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/CalendarV3


## License

See files `LICENSE` and `NOTICE` in this repository.
