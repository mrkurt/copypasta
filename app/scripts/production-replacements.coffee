CoffeeScript = require 'coffee-script'

replacements =
  'http://localhost:3000' : 'http://copypasta.heroku.com'

CoffeeScript.on 'compile', (task) ->
  for own key, value of replacements
    task.input = task.input.replace(new RegExp(key, 'g'),value)
