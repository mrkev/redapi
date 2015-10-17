
module.exports =

  # Standard
  nan       : isNaN
  array     : Array.isArray || (value) -> {}.toString.call(value) is '[object Array]'
  date      : (x) -> x instanceof Date && !(isNaN x.valueOf())
  regexp    : (x) -> x instanceof RegExp
  number    : (x) -> typeof x is 'number' && not isNaN x
  string    : (x) -> typeof x is 'string'
  boolean   : (x) -> typeof x is 'boolean'
  function  : (x) -> typeof x is 'function'
  undefined : (x) -> x is undefined
  null      : (x) -> x is null
  
  # Numbers
  integer   : (x) -> @number  x && not (x % 1)
  positive  : (x) -> @number  x && x > 0
  negative  : (x) -> @number  x && x < 0
  finite    : (x) -> @number  x && isFinite x
  natural   : (x) -> @integer x && x > -1
  color     : (x) -> @natural x && x < 16777216

if require.main is module
  console.log module.exports.self()