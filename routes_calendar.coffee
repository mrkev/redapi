##
# The route handler for calendar information. 
# 
# Should get the data, filter it, and answer to the response.
##

iroh = require 'iroh'

##
# Serves array with ids for all available calendars
module.exports.all_ids = (req, res) ->
  iroh.getJSON().then((data)->
      res.json data.dining
      return
    )

##
# req: contains cal_id for calendar to fetch.
module.exports.cal_data = (req, res) ->
  console.log req.params.cal_id
  iroh.getJSON(req.params.cal_id).then((data)->
      console.log 'yo frankie'
      res.json data
      return
    ).catch res.json

##
# req: contains meal, location, dim coordinates for menu to fetch
module.exports.menu = (req, res) -> 
  console.log('YO MENU') 
  meal = switch req.params.meals
    when 'ALL' then iroh.ALL_MEALS
    when undefined, null, '' then []
    else req.params.meals.split(',')
  
  location = switch req.params.locations
    when 'ALL' then iroh.ALL_LOCATIONS
    when undefined, null, '' then []
    else req.params.locations.split(',')
  
  dim = switch req.params.dim
    when 'MEALS' then iroh.DIM_MEALS
    when 'LOCATIONS', undefined, null, '' then iroh.DIM_LOCATIONS
    else throw new Error('YO');
  

  console.log 'passing in', meal, location, dim
  iroh.get_menus(meal, location, dim).then((data)->
      res.json data
      return
    ).catch res.json

##
# req: contains date range, location of calendar events to fetch
module.exports.event = (req, res) -> 
  console.log('YO EVENTS') 
  
  # TODO: Test support for single dates, comma separated dates.
  dater = switch req.params.dater
    when undefined, null, '' then []
    else iroh.DATE_RANGE.apply(iroh, req.params.dater.split('-'))
  
  location = switch req.params.locations
    when 'ALL' then iroh.ALL_LOCATIONS
    when undefined, null, '' then []
    else req.params.locations.split(',')

  console.log 'passing in', location, dater
  iroh.get_events(location, dater).then((data)->
      res.json data
      return
    ).catch res.json