$ = jQuery
currentLive = false
iframe_ready = false

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
    console.debug("Parent Sending: " + msg.label + " to " + window.location.href)
    $(paths.iframe).get(0).contentWindow.postMessage(JSON.stringify(msg), 'http://localhost:3000')
    console.debug("Parent send done")
  else
    send_to_iframe_queue.push msg

send_queued = () ->
  send_to_iframe m for m in send_to_iframe_queue
  send_to_iframe_queue = []

iframe_action = (e) ->
  return unless e.origin == 'http://localhost:3000/'
  data = JSON.parse(e.data)
  if data.label == 'ready'
    iframe_ready = true
    send_queued()
  else if data.label == 'finished'
    $(paths.btn + '.on').click()
    dialog().find(paths.cancel_btn).click()
  else if data.label == 'resize'
    $(paths.iframe).animate({height : e.data.h + 'px'})

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

window.addEventListener('message', iframe_action, false)
