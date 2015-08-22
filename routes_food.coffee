
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
    { error : 'Invalid dimension' }

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
  
  iroh   = require 'iroh'
  router = router_factory()

  router
    ##
    # Serve array with ids for all available calendars
    .route('/dining')
    .get (req, res) -> res.json
      halls : iroh.ALL_HALLS
      cafes : iroh.ALL_BRBS

  router
    ##
    # Serve array with ids for all available calendars
    .route('/dining/location_info')
    .get (req, res) ->
      res.json 
        info : iroh.ALL.map (x) ->
          name : x.name
          id : x.id
          coordinates : x.coordinates
          payment : if not (x.payment is "") then x.payment else null
          description : x.description
          description_location : x.what
          description_menu : x.menu

  router
    ##
    # Serve menus
    # req: contains meal, location, dim coordinates for menu to fetch
    .route '/dining/menu/:locations/:meals/:dim'
    .get (req, res) ->  
      location = normalize_list req.params.locations, iroh.ALL_LOCATIONS    
      meal     = normalize_list req.params.meals, iroh.ALL_MEALS
      dim      = normalize_keyword req.params.dim, ['LOCATIONS', 'MEALS']

      console.log "YO MENU w/ #{location}, #{meal}, #{dim}"

      iroh.get_menus location, meal
      .then (data) -> res.json (dimentionalize data, dim)
      .catch res.json

  router
    ##
    # req: contains date range, location of calendar events to fetch
    .route '/dining/event/:locations/:dater/'
    .get (req, res) ->
      location = normalize_list req.params.locations, iroh.ALL_LOCATIONS
      dater = switch req.params.dater
        when undefined, null, '' then []
        else iroh.DATE_RANGE.apply(iroh, req.params.dater.split('-'))

      console.log "YO EVENTS w/ #{location}, #{dater}"

      iroh.get_events location, dater
      .then res.json
      .catch res.json
