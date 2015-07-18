##
# The route handler for academic calendar information. 
##

tenzin = require 'Tenzin'

##
# req: contains ac_year for calendar to fetch.
module.exports.cal_for_year = (req, res) ->
  ac_year = 0
  try 
    ac_year = parseInt req.params.ac_year

  tenzin.query(ac_year).then((data)->
      res.json data
      return
    )