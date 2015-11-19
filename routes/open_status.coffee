fs      = require 'fs'
rp      = require 'request-promise'
cueats  = require 'cornell-dining'
Promise = require('es6-promise').Promise

# pre: d is Date object
# post: (h|hh):mm (am|pm)
getTime = (d) -> d.toString('H:mm tt').toLowerCase()

is_west =
  "becker_house_dining_room"        : true
  "cook_house_dining_room"          : true
  "jansens_dining_room_bethe_house" : true
  "keeton_house_dining_room"        : true
  "rose_house_dining_room"          : true

###
pre:
  id  : the id of the location
  loc : object with these attributes:
    cal_id         : a Google Calendar calendarId
    name           : name of the location
    is_dining_hall : if true, this location is a dining hall, else cafe
post:
  Promise resolving to object:
  {
    id             : id of the place
    name           : user-friendly name
    change_time    : unix time of when the current status changes
                     if none found, set to 0 to imply closed for a while
    is_open        : boolean of is open currently
    is_almost_open : boolean of is closed, but opens within 2 hours
    is_dining_hall : if true, this location is a dining hall, else cafe
  }
###
getLocDetails = (loc) ->
  # console.log loc.id
  # https://developers.google.com/apis-explorer/#s/calendar/v3/calendar.events.list
  FRONT_URL = "https://www.googleapis.com/calendar/v3/calendars/"
  END_URL = "/events?singleEvents=true&orderBy=startTime" +
            "&maxResults=10&fields=items(summary%2Cstart%2Cend)%2Csummary" +
            "&timeMin=#{Date.today().toISOString()}" + 
            "&key=AIzaSyBnR3NSTeZw4TBak_kW6uAhe38ooEzVW8U"

  rp(FRONT_URL + loc.cal_id + END_URL)
  .then (response) ->

    # list of events
    events = (JSON.parse response).items
    now = new Date()

    # vars to-be-set by getOpenStatus below
    change_time = 0

    return {
      event_changes : []
      status : 'closed'
      id : loc.id
      name : loc.name
      type : if loc.is_dining_hall then "hall" else "cafe"
    } if not events[0] # If array is empty it
    # means the location is either permanently
    # closed or no one has bothered updating
    # the calendars.

    # All-day events have dates, not dateTimes
    next_start = Date.parse (events[0].start.dateTime or events[0].start.date)
    next_end   = Date.parse (events[0].end.dateTime   or events[0].end.date  )

    dayDiff   = next_start.getDay()   - now.getDay()
    hoursDiff = next_start.getHours() - now.getHours()
    
    # Assuming events come in chronological order, 
    # which it seems like they always should.
    
    # Note that now < next_end should always be true.
    # if it weren't the case we wouldn't be getting
    # this event from our API call to Google.
    is_open = now >= next_start && now < next_end

    status = switch true
      when now >= next_start && now < next_end && \
           is_west[loc.id] && now.getDay() is 3 && now.getHours() is 18          # House dinner, Wednesday at 18:00-18:59
        "house dinner"
      when now >= next_start && now < next_end && \
           next_start.getHours() >= 16
        "dinner"
      when now >= next_start && now < next_end && \
           next_start.getHours() >= 14
        "lunch"
      when now >= next_start && now < next_end && \
           next_start.getHours() >= 10
        "brunch"
      when now >= next_start && now < next_end && \
           next_start.getHours() >= 7
        "breakfast"
      else
        "closed"

    event_changes = events[...3].reduce (acc, e, i) ->

      return acc if (e.summary.search /closed/i) > -1

      start = Date.parse(e.start.dateTime or e.start.date)
      end   = Date.parse(e.end.dateTime   or e.end.date)

      new_status = switch true
        when is_west[loc.id] && start.getDay() is 3 && start.getHours() is 18          # House dinner, Wednesday at 18:00-18:59
          "house dinner"
        when start.getHours() >= 16
          "dinner"
        when start.getHours() >= 14
          "lunch"
        when start.getHours() >= 10
          "brunch"
        when start.getHours() >= 7
          "breakfast"
        else
          "closed"

      acc.push {
        time : start
        status : new_status
      }

      # A status change; next event starts right when this one ends. We just
      # want to display that events start, and skip this event's end
      return acc if Date.parse(events[i+1]?.start.dateTime or events[i+1]?.start.date).valueOf() is end.valueOf()

      acc.push {
        time : end
        status : 'close'
      }

      return acc

    , []

    # console.log event_changes, id

    # Only the first change-time has the chance of 
    # being less than now. If the first two were
    # the event wouldn't be in our API call to Google
    event_changes.shift() if event_changes[0].time < now

    return {
      event_changes
      status
      id : loc.id
      name : loc.name
      type : if loc.is_dining_hall then "hall" else "cafe"
    }

    # # pre: e is Google Calendar event
    # # eg.
    # #   { summary: 'Lunch until 2pm',
    # #     start:
    # #     { dateTime: '2015-08-31T11:00:00-04:00',
    # #       timeZone: 'America/New_York' },
    # #     end:
    # #     { dateTime: '2015-08-31T14:00:00-04:00',
    # #       timeZone: 'America/New_York' } }
    # # 
    # # post: sets change_time, is_open, is_almost_open
    # getOpenStatus = (e) ->
    #   # event summary contains closed -> not an open event
    #   return if e.summary.search /closed/i > -1

    #   start = Date.parse e.start.dateTime
    #   # if change_time not set yet, or this event continues the previous event continue
    #   return if !(!change_time or !prevEnd or start.equals(prevEnd))

    #   end = Date.parse(e.end.dateTime)
    #   prevEnd = end
    #   if now >= start && now < end 
    #     # we are in this event, so set it to be open until the end
    #     change_time = end.getTime()
    #   else if now < start
    #     # we are before this event, so set it as closed until the start
    #     change_time = start.getTime()

    # # run getOpenStatus over the events
    # # (getOpenStatus event) for event in events

    # return {
    #   event_changes
    #   status
    #   id
    #   name : loc.name
    #   type : if loc.is_dining_hall then "hall" else "cafe"
    # }

###
post:
  Promise resolving to object:
  {
    'dining_halls' : list of getLocDetails(diningHall) for each dining hall
    'cafes'        : list of getLocDetails(cafes) for each cafes
  }
  Done for every calendar
  Each list will be sorted by name
###
getResult = ->
  Promise
  .all((getLocDetails loc) for loc in cueats.ALL)
  .catch (e) -> throw new Error('Error getting details\n' + e)

module.exports = (where_my_router_at) ->
  router = where_my_router_at()
  router
    .route '/dining/location_status/'
    .get (req, res) -> 
      getResult()
      .then (result) ->
        res.json 
          locations : result
      .catch res.json

if require.main is module
   
  (getLocDetails '104west', 
    icalendar: 'https://www.google.com/calendar/ical/vlpa2hk9677m9bcbh6n2dtpn7k%40group.calendar.google.com/public/basic.ics'
    cal_id: 'vlpa2hk9677m9bcbh6n2dtpn7k@group.calendar.google.com'
    name: '104West!'
    is_dining_hall: true
    coordinates: '42.4442660, -76.4875983'
    payment: 'BRB,cash,swipe'
    hall_menu_id: 9
  ).then (res) ->
    console.log '\n'
    console.dir res


