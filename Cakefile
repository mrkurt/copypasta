fs = require('fs')
CoffeeScript = require('coffee-script')
option '-e', '--env [ENVIRONMENT]', 'compilation environment'

data =
  development :
    '$$ENDPOINT$$' : 'http://localhost:3000'
  production :
    '$$ENDPOINT$$' : 'http://copypasta.heroku.com'

task 'build', (options) ->
  env = data[options.env] || data.production
  fs.readFile './app/scripts/copypasta.coffee', (err, code) ->
    tokens = CoffeeScript.tokens code.toString()
    for t in tokens when t[0] == 'IDENTIFIER'
      if t[1] of env
        t[0] = 'STRING'
        t[1] = "'" + env[t[1]] + "'"
    js = CoffeeScript.nodes(tokens).compile()
    fs.writeFile './public/javascripts/copypasta.js', js
