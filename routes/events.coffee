
module.exports = (router_factory) ->
  util   = require '../lib/common.coffee'
  cueats = require 'cornell-dining'
  router = router_factory()

  router
    ##
    # req: contains date range, location of calendar events to fetch
    .route '/dining/event/:locations/:dater/'
    .get (req, res) ->
      location = util.normalize_list req.params.locations, cueats.ALL_LOCATIONS
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