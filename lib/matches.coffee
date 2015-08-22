# 
# .then (json) ->
#   


chalk = (require 'chalk')

err_too_many_keys = (jkeys, mkeys) ->
  console.log """
  #{chalk.dim('-----------------------------')}
  JSON has more keys than model
  JSON: #{jkeys}
  Model:#{mkeys}
  """

matches = (model, json) ->
  jkeys = Object.keys json
  mkeys = Object.keys model

  # not === becase model might describe undefined's in json
  if jkeys.length > mkeys.length
    err_too_many_keys jkeys, mkeys
    return false

  for mkey in mkeys
    if model[mkey](json[mkey], json) is false
      console.log """
      #{chalk.dim('-----------------------------')}
      #{mkey} doesn't match spec.
      Tester is:
        #{model[mkey].toString()}
      but got:
        #{json[mkey]}
      """

      return false 

  return true

module.exports = matches

if require.main is module 

  model = 
    one : (x) -> typeof x is 'string'
    two : (x) -> x is 3 || x is 5
    three : (x) -> x is undefined || x.length > 0

  a =
    one : 'hello'
    two : 3
    three : [1]

  b =
    one : 'hello'
    two : 3

  c =
    one : 'hello'
    two : 3
    three : []

  d =
    one : 'hello'
    two : 2
    three : [3, 2]

  console.log 'a good' if matches model, a
  console.log 'b good' if matches model, b
  console.log 'c good' if not matches model, c
  console.log 'd good' if not matches model, d



