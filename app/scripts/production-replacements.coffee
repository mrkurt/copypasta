CoffeeScript = require 'coffee-script'

replacements =
  'iframe_host = "http://localhost:3000"' : 'iframe_host = "https://copypasta.credibl.es"'
  'http://localhost:3000' : '//copypasta.credibl.es'

CoffeeScript.on 'compile', (task) ->
  for own key, value of replacements
    task.input = task.input.replace(new RegExp(key, 'g'),value)
