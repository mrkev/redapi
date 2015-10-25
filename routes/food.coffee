
################################### Helpers. ###################################

##
# Reduces a menu array to an object.
# Either {meal: {hall : menu}} or {menu: {meal: hall}}
dimentionalize = (array, key_dim) -> switch key_dim
  when 'LOCATIONS'
    array.reduce (acc, curr) ->
      acc[curr.location]            = {} if !acc[curr.location]
      acc[curr.location][curr.meal] = curr.menu
      return acc
    , {}

  when 'MEALS'
    array.reduce (acc, curr) ->
      acc[curr.meal]                = {} if !acc[curr.meal]
      acc[curr.meal][curr.location] = curr.menu
      return acc
    , {}

  else
    throw new Error 'Invalid dimention'

##
# Returns an array from the comma-separated values 
# of a given [@param string]. If the string is ALL,
# and an [@param all] is given, it returns that 
# instead.
normalize_list = (string, all) ->
  all = ['ALL'] if not all
  switch string
    when 'ALL' then all
    when undefined, null, '' then []
    else string.split ','

##
# Coerces a word into one from a list. If word is
# not found. First word in the list is returned.
normalize_keyword = (word, list) ->
  i = list.indexOf word #.toUppercase
  list[(if i > -1 then i else 0)]


################################ The Real Deal. ################################

module.exports = (router_factory) ->
  cueats = require 'cornell-dining'
  router = router_factory()

  router
    ##
    # Serve array with ids for all available calendars
    # Done. Works.
    .route '/dining'
    .get (req, res) -> res.json
      halls : cueats.ALL_HALLS.map (x) ->
        x.type = 'hall'
        return x
      cafes : cueats.ALL_BRBS.map (x) ->
        x.type = 'cafe'
        return x

  router
    ##
    # Serve array with ids for all available calendars
    # Done. Works. NEXT: Add type.
    .route '/dining/location_info'
    .get (req, res) ->
      res.json 
        locations : cueats.ALL.map (x) ->
          name : x.name
          id : x.id
          coordinates : x.coordinates
          payment : if not (x.payment is "") then x.payment else null
          description : x.description
          description_location : x.what
          description_menu : x.menu
          # type

  router
    .route '/dining/menu/:locations'
    .get (req, res) ->  
      locations = normalize_list req.params.locations, cueats.ALL_LOCATIONS    

      try
        cueats.get_menus locations, cueats.ALL_MEALS
        .then (data) ->
          res.json
            menus : data.filter (x) -> x.menu
        .catch res.json
      catch e
        throw e

  router
    .route '/dining/menu/:locations/:meals'
    .get (req, res) ->  
      locations = normalize_list req.params.locations, cueats.ALL_LOCATIONS    
      meals     = normalize_list req.params.meals, cueats.ALL_MEALS

      try
        cueats.get_menus locations, meals
        .then (data) ->
          res.json
            menus : data.filter (x) -> x.menu
        .catch res.json
      catch e
        throw e

  router
    ##
    # FROZEN
    # Serve menus
    # req: contains meal, location, dim coordinates for menu to fetch
    .route '/dining/menu/:locations/:meals/:dim'
    .get (req, res) ->  
      locations = normalize_list req.params.locations, cueats.ALL_LOCATIONS    
      meals     = normalize_list req.params.meals, cueats.ALL_MEALS
      dim       = normalize_keyword req.params.dim, ['LOCATIONS', 'MEALS']

      try
        cueats.get_menus locations, meals
        .then (data) -> 
          res.json (dimentionalize data, dim)
        .catch res.json
      catch e
        throw e

  router
    ##
    # req: contains date range, location of calendar events to fetch
    .route '/dining/event/:locations/:dater/'
    .get (req, res) ->
      location = normalize_list req.params.locations, cueats.ALL_LOCATIONS
      dater = switch req.params.dater
        when undefined, null, '' then []
        else cueats.DATE_RANGE.apply(cueats, req.params.dater.split('-'))

      (cueats.get_events location, dater).then (arr) ->
        console.log arr

        acc = {}
        for e in arr
          acc[e.location] = [] if not acc[e.location]
          acc[e.location].push(e)

        res.json(acc)

      .catch res.json

        
