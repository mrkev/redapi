##
# The route handler for calendar information. 
# 
# Should get the data, filter it, and answer to the response.
##

sokka = require 'Sokka'

##
# Serves all printer information
module.exports.all_printers = (req, res) ->
  sokka.getJSON()
    .then((data)->
      res.json data
      return
    ).catch((err)->
      res.json {error: 'sorry'}
    )
