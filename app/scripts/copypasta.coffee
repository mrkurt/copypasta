$ = false
currentLive = false
iframe_ready = false

window.copypasta = copypasta = {}

ids =
  indicator: 'copy-pasta-edit-indicator'
  dialog: 'copy-pasta-dialog'
  iframe : 'copy-pasta-iframe'
  cancel_btn : 'copy-pasta-cancel'

paths =
  indicator: '#' + ids.indicator
  dialog: '#' + ids.dialog
  btn: '.copy-pasta-button'
  active: '.copy-pasta-active'
  cancel_btn: '#' + ids.cancel_btn
  iframe: '#' + ids.iframe


blank_dialog = '<div id="' + ids.dialog + '"><iframe frameborder="no" style="margin: 0px; padding: 0px; width: 100%; height: 300px; z-index: 2;" id="' + ids.iframe + '" scrolling="no"></iframe><input type="button" class="close" id="copy-pasta-cancel" style="display:none;"></div>'

indicator = () ->
  if $(paths.indicator).length == 0
    $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>')
  $(paths.indicator)

dialog = (src) ->
  if src?
    src = src + "&" + Math.random()
  if $(paths.dialog).length == 0
    $('body').append(blank_dialog)
  iframe_ready = false
  $(paths.iframe).attr('src', src) if src?
  $(paths.dialog)

activate = () ->
  pos = $(this).offset()
  pos.top = pos.top + 'px'
  pos.left = pos.left + 'px'
  sz =
    width: $(this).outerWidth() + 'px'
    height: $(this).outerHeight() + 'px'

  indicator().css(sz).css(pos).show()
  currentLive = this

deactivate = () ->
  indicator().hide()
  currentLive = false

watch = (el) ->
  $(paths.active + ' ' + el).live('mouseover', activate)

show_widget = () ->
  e = currentLive
  e.original_text ?= e.innerHTML

  indicator().addClass('loading')

  data =
    'edit[original]' : e.original_text
    'edit[proposed]' : e.original_text
    'edit[url]' : window.location.href

  send_to_iframe({'label' : 'form_data', 'data' : data})

  dialog('http://localhost:3000/edits/new?view=framed&url=' + escape(window.location.href)).lightbox_me {closeClick : false, closeEsc : false }

send_to_iframe_queue = []
send_to_iframe = (msg) ->
  if iframe_ready
    $(paths.iframe).get(0).contentWindow.postMessage(JSON.stringify(msg), 'http://localhost:3000')
  else
    send_to_iframe_queue.push msg

send_queued = () ->
  send_to_iframe m for m in send_to_iframe_queue
  send_to_iframe_queue = []

iframe_action = (e) ->
  return unless e.origin == 'http://localhost:3000'
  data = JSON.parse(e.data)
  if data.label == 'ready'
    iframe_ready = true
    send_queued()
  else if data.label == 'finished'
    $(paths.btn + '.on').click()
    dialog().find(paths.cancel_btn).click()
  else if data.label == 'resize'
    $(paths.iframe).animate({height : data.h + 'px'})

init = ()->
  lightbox_me_init($)
  watch el for el in ['p', 'li', 'h1', 'h2', 'h3', 'h4', 'h5']

  $(paths.indicator).live('mouseout', deactivate)
  $(paths.indicator).live('click', show_widget)

  $(paths.btn + '.off').live 'click', ()->
    btn = $(this)
    btn.removeClass('off').addClass('on')
    $(btn.attr('href')).addClass('copy-pasta-active')

  $(paths.btn + '.on').live 'click', ()->
    btn = $(this)
    btn.removeClass('on').addClass('off')
    $(btn.attr('href')).removeClass('copy-pasta-active')
    false

  if window.addEventListener?
    window.addEventListener('message', iframe_action, false)
  else if window.attachEvent?
    window.attachEvent('onmessage', ()-> iframe_action(event))

scripts = [
    {
      test: ()-> window.jQuery && window.jQuery.fn && window.jQuery.fn.jquery > "1.4.2"
      src: 'http://localhost:3000/javascripts/jquery-1.4.2.min.js'
      callback : ()->
        ($ = window.jQuery).noConflict(1)
    },
    {
      test: ()-> window.jQuery && window.jQuery.fn.lightbox_me
      src: 'http://localhost:3000/javascripts/jquery.lightbox_me.js'
    },
    { #json lib for ie8 in quirks mode
      test: ()-> window.JSON
      src: 'http://localhost:3000/javascripts/json2.js'
    }
  ]

scripts.load = (queue, callback) ->
  remaining = (i for i in queue when !i.state?)
  return if remaining.length == 0
  def = remaining.pop()
  def.state = 'pending'
  s = document.createElement('script')
  s.type = "text/javascript"
  s.src = def.src
  s.onload = s.onreadystatechange = ()->
    d = this.readyState
    if !def.loaded && (!d || d == 'loaded' || d == 'complete')
      def.state = 'loaded'
      def.callback() if def.callback?
      remaining = (i for i in queue when i.state != 'loaded')
      if remaining.length == 0
        callback()
  scripts.load(queue, callback) if queue.length > 0
  document.documentElement.childNodes[0].appendChild(s)

queue = (s for s in scripts when s? && !s.test())

if queue.length > 0
  scripts.load(queue, init)
else
  init()
