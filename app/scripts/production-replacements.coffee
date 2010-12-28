CoffeeScript = require 'coffee-script'
sys = require 'sys'

replacements =
  'http://localhost:3000/' : 'http://copypasta.heroku.com/'

CoffeeScript.on 'compile', (task) ->
  for own key, value of replacements
    task.input = task.input.replace(key,value)
