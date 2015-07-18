##
# The route handler for calendar information. 
# 
# Should get the data, filter it, and answer to the response.
##

katara = require 'katara'

current_term = 'FA14'

module.exports.current_term = (req, res) ->
  katara.getJSON('', current_term)
    .then((data)->
      res.json data
      return
    ).catch((err)->
      res.json {error: 'sorry'}
    )


##
# Serves all printer information
module.exports.term = (req, res) ->
  katara.getJSON('', req.params.term)
    .then((data)->
      res.json data
      return
    ).catch((err)->
      res.json {error: 'sorry'}
    )


module.exports.subject = (req, res) ->
  katara.getJSON(req.params.subject, req.params.term)
    .then((data)->
      res.json data
      return
    ).catch((err)->
      res.json {error: 'sorry'}
    )