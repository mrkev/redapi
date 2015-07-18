##
# The route handler for exam calendar information. 
##

sozin = require 'Sozin'

##
# req: contains :term and :type for calendar to fetch.
module.exports.cal_for_type_term = (req, res) ->
  sozin.getJSON(req.params.term, req.params.type).then((data)->
      res.json data
      return
    )

