
# Checks types.

  var is = require('isita');
  is.array([])
  is.date(new Date)
  is.null(null)
  is.color(0xFFFFFF)
  is.function(is.function)

etc.

Supported:

 - nan
 - array
 - date
 - regexp
 - number
 - string
 - boolean
 - function
 - undefined
 - null
 - integer
 - positive
 - negative
 - finite
 - natural
 - color

