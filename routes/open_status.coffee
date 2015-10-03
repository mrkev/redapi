fs      = require 'fs'
rp      = require 'request-promise'
iroh    = require 'iroh'
Promise = require('es6-promise').Promise

# https://developers.google.com/apis-explorer/#s/calendar/v3/calendar.events.list
FRONT_URL = "https://www.googleapis.com/calendar/v3/calendars/"
END_URL = "/events?singleEvents=true&orderBy=startTime" +
          "&maxResults=10&fields=items(summary%2Cstart%2Cend)%2Csummary" +
          "&timeMin=#{Date.today().toISOString()}" + 
          "&key=#{fs.readFileSync './priv/api_key'}"

# pre: d is Date object
# post: (h|hh):mm (am|pm)
getTime = (d) -> d.toString('H:mm tt').toLowerCase()

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
getLocDetails = (id, loc) ->
  rp(FRONT_URL + loc.cal_id + END_URL).then (response) ->

    # list of events
    events = (JSON.parse response).items
    now = new Date()

    # vars to-be-set by getOpenStatus below
    change_time = 0
    is_open = false
    is_almost_open = false
    prevEnd = null

    # pre: e is Google Calendar event
    # eg.
    #   { summary: 'Lunch until 2pm',
    #  start:
    #   { dateTime: '2015-08-31T11:00:00-04:00',
    #     timeZone: 'America/New_York' },
    #  end:
    #   { dateTime: '2015-08-31T14:00:00-04:00',
    #  timeZone: 'America/New_York' } }
    # 
    # post: sets change_time, is_open, is_almost_open
    getOpenStatus = (e) ->
      # event summary contains closed -> not an open event
      return if e.summary.search(/closed/i) > -1

      start = Date.parse(e.start.dateTime)
      # if change_time not set yet, or this event continues the previous event continue
      return if !(!change_time or !prevEnd or start.equals(prevEnd))

      end = Date.parse(e.end.dateTime)
      prevEnd = end
      if now >= start && now < end 
        # we are in this event, so set it to be open until the end
        is_open = true
        change_time = end.getTime()
      else if now < start
        # we are before this event, so set it as closed until the start
        dayDiff = start.getDay() - now.getDay()
        hoursDiff = start.getHours() - now.getHours()
        
        is_almost_open = true if dayDiff is 0 && hoursDiff <= 2
        change_time = start.getTime()

    # run getOpenStatus over the events
    (getOpenStatus event) for event in events

    status = if is_open then "open" else (if is_almost_open then 'almost_open' else 'closed')

    # resolve the parent new Promise object
    return {
      event_changes : [{
        time : change_time
        type : if status is 'closed' then 'open' else 'closed'
      }]
      status
      id
      name : loc.name
      type : if loc.is_dining_hall then "hall" else "cafe"
    }

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
  .all(getLocDetails id, loc for own id, loc of iroh.caldb)
  .catch (e) -> console.log 'Error getting details', e

module.exports = (where_my_router_at) ->
  router = where_my_router_at()
  router
    .route '/dining/location_status/'
    .get (req, res) -> getResult().then((result) ->
      res.json 
        locations : result
    )




