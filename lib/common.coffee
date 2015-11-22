chalk = require('chalk');

module.exports = 
  ##
  # Returns an array from the comma-separated values 
  # of a given [@param string]. If the string is ALL,
  # and an [@param all] is given, it returns that 
  # instead.
  normalize_list : (string, all) ->
    all = ['ALL'] if not all
    switch string
      when 'ALL' then all
      when undefined, null, '' then []
      else string.split ','
  
  ##
  # Coerces a word into one from a list. If word is
  # not found. First word in the list is returned.
  normalize_keyword : (word, list) ->
    i = list.indexOf word #.toUppercase
    list[(if i > -1 then i else 0)]
  
    
  log : ->
    args = Array.prototype.slice.call(arguments)
    args.unshift(chalk.green "#{new Date()}: ")
    console.log.apply(@, args)