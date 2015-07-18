Promise = require("es6-promise").Promise
remap   = require("obender").remap

jquery  = require("fs").readFileSync(__dirname + "/vendor/jquery.min.js", "utf-8")
t2json  = require("fs").readFileSync(__dirname + "/vendor/jquery.tabletojson.js", "utf-8")
jsdom   = require("jsdom")

###*
Sokka

query()   : returns a promise to the queried data and resets the timer. The
data recieved gets stored on cache.

jetJSON() : returns a promise to the most readily available data. If there's
no cache, same as query(). Else, to cache.

interval  : time in milliseconds between automatic calls of query()
###
class Sokka
  constructor : (@url) ->
    @interval = 604800000 # One week
    @data = null

  clear : ->
    @data = null
    return
  
  query : ->
    self  = this
    new Promise (resolve, reject) ->
      jsdom.env
        url: self.url
        src: [ jquery, t2json ]
        done: (err, window) ->
          $ = window.jQuery
          if err isnt null
            console.error err
            reject err
          
          self.data = $("table").tableToJSON()
          
          # Reformat data.
          i = self.data.length - 1
          while i >= 0
            remap
              "Queue Name"    : "queue_name"
              "Printer Name"  : "printer_name"
              "Printer Model" : "printer_model"
              "Color" :
                color : (value) -> value is "Color"
              "DPI" :
                dpi : (value) -> parseFloat value
              "Duplex" :
                duplex : (value) -> value is "Two-sided"
              "¢/Pg":
                price_per_page : (value) -> parseFloat(value) / 100
            , self.data[i]
            i--
          
          resolve self.data

      self.timer = setTimeout(self.query, self.interval)
    
  getJSON : ->
    if @data is null
      @query()
    else
      Promise.resolve @data


module.exports = new Sokka "https://net-print.cit.cornell.edu/netprintx-cgi/qfeatures.cgi"


