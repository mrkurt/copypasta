return unless window.postMessage?

append_to_element = (e for e in document.documentElement.childNodes when e.nodeType == 1)[0]
static_host = "http://localhost:3000"
css = document.createElement('link')
css.rel = "stylesheet"
css.href = static_host + "/stylesheets/compiled/copypasta.css"
append_to_element.appendChild(css)

$ = false
currentLive = false
currentContainer = false
form_data = {}

window.copypasta = copypasta = {$ : false, page_id : window.copypasta_page_id, auto_start : window.copypasta_auto_start}
copypasta.debug = window.copypasta_debug || window.location.hash.indexOf('debug') > 0

debug_msg = (msg)->
  if copypasta.debug
    console.debug(msg)

ids =
  indicator: 'copy-pasta-edit-indicator'
  dialog: 'copy-pasta-dialog'
  iframe : 'copy-pasta-iframe'
  overlay: 'copy-pasta-overlay'

paths =
  indicator: '#' + ids.indicator
  dialog: '#' + ids.dialog
  btn: '.copy-pasta-button'
  active: '.copy-pasta-active'
  iframe: '#' + ids.iframe
  overlay: '#' + ids.overlay

indicator = () ->
  if $(paths.indicator).length == 0
    $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>')
    $(paths.indicator).bind('mouseout', deactivate)
    $(paths.indicator).bind('click', show_edit_dialog)

  $(paths.indicator)

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

blank_dialog = '<div id="' + ids.dialog + '"><div id="' + ids.overlay + '"></div><iframe frameborder="no"id="' + ids.iframe + '" scrolling="no"></iframe></div>'

hide_dialog_overlay = ()->
  $(paths.overlay).fadeOut ()->
    debug_msg("Overlay hidden")

resize_dialog = (data)->
  $(paths.dialog).animate({height : data.h + 'px'})

show_edit_dialog = ()->
  e = currentLive
  e.original_text ?= e.innerHTML

  page_id = copypasta.page_id ? ''
  form_data.new_edit =
    'edit[original]' : e.original_text
    'edit[proposed]' : e.original_text
    'edit[url]' : window.location.href
    'edit[element_path]' : copypasta.getElementCssPath(e, currentContainer)
  
  url = 'http://localhost:3000/edits/new?view=framed&url=' + escape(window.location.href) + '&page[key]=' + escape(page_id)

  show_dialog(url, 'lightbox')

dialog_types =
  default:
    options: { escClose: true, overlayClose: true, overlayId : 'copy-pasta-lightbox-overlay', containerId : 'copy-pasta-lightbox-container', opacity: 70, persist: true}
  lightbox:
    class: 'copy-pasta-lightbox'
    options: { position: ['10%'], minWidth: 440 }
  widget:
    class: 'copy-pasta-widget'
    options: { position: ['10%', '0%'], modal: false }

show_dialog = (src, type) ->
  copypasta.modal_init($) unless $.fn.modal
  t = dialog_types.default
  t.options.onShow = ()->
    if t.class?
      $(paths.dialog).addClass(t.class)
    if src?
      $(paths.overlay).show()
      debug_msg("Overlay shown")
      src = src
      src += '#debug' if copypasta.debug
      debug_msg("Loading iframe: " + src)
      $(paths.iframe).attr('src', src)

  if type? && dialog_types[type]?
    t = dialog_types[type]
    t.options = {} unless t.options?
    t.options = $.extend(t.options, dialog_types.default.options) unless t.extended
    t.extended = true

  $.modal(blank_dialog, t.options)

load_iframe_form = (id)->
  if id? && form_data[id]?
    send_to_iframe('label' : 'form_data', 'data' : form_data[id])

send_to_iframe = (msg) ->
  debug_msg("Parent send: " + msg.label + " to http://localhost:3000")
  msg = JSON.stringify(msg)
  $(paths.iframe).get(0).contentWindow.postMessage(msg, 'http://localhost:3000')

receive_from_iframe = (e) ->
  unless e.origin == 'http://localhost:3000'
    debug_msg(e)
    return
  data = JSON.parse(e.data)
  debug_msg("Parent receive: " + data.label + " from " + e.origin)
  if data.label == 'ready'
    unless load_iframe_form(data.form_id)
      #have to wait til after form data postMessage, otherwise
      hide_dialog_overlay()
  else if data.label == 'form_data_loaded'
    hide_dialog_overlay()
  else if data.label == 'finished'
    $.modal.close() if $.modal?
  else if data.label == 'resize'
    resize_dialog(data)

init = ()->
  watch el for el in ['p', 'li', 'h1', 'h2', 'h3', 'h4', 'h5']

  if copypasta.auto_start
    $(paths.btn).removeClass('off').addClass('on')
    currentContainer = $('body').addClass('copy-pasta-active').get(0)

  $(paths.btn + '.off').live 'click', ()->
    images.load()
    btn = $(this)
    btn.removeClass('off').addClass('on')
    currentContainer = $(btn.attr('href') || 'body').addClass('copy-pasta-active').get(0)

  $(paths.btn + '.on').live 'click', ()->
    btn = $(this)
    btn.removeClass('on').addClass('off')
    $(btn.attr('href')).removeClass('copy-pasta-active')
    currentContainer = false

  if window.addEventListener?
    window.addEventListener('message', receive_from_iframe, false)
  else if window.attachEvent?
    window.attachEvent('onmessage', ()-> receive_from_iframe(event))

scripts = [
    {
      test: ()->
        if window.jQuery && window.jQuery.fn && window.jQuery.fn.jquery > "1.3"
          $ = window.jQuery
          debug_msg("Using existing jquery: version " + $.fn.jquery)
          true
      #src: 'http://localhost:3000/javascripts/jquery-1.3.min.js'
      src: 'http://localhost:3000/javascripts/jquery-1.4.4.min.js'
      callback : ()->
        (copypasta.$ = $ = window.jQuery).noConflict(1)
        debug_msg("Loaded own jquery: version " + $.fn.jquery)
    },
    {
      test: ()-> copypasta.getElementCssPath && window.jQuery && window.jQuery.fn.lightbox_me
      src: 'http://localhost:3000/javascripts/utils.js'
    },
    { #json lib for ie8 in quirks mode
      test: ()-> window.JSON
      src: 'http://localhost:3000/javascripts/json2.min.js'
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
    if def.state != 'loaded' && (!d || d == 'loaded' || d == 'complete')
      def.state = 'loaded'
      def.callback() if def.callback?
      remaining = (i for i in queue when i.state != 'loaded')
      if remaining.length == 0
        callback()
  scripts.load(queue, callback) if queue.length > 0
  append_to_element.appendChild(s)

images = [
  "translucent-blue.png",
  "translucent-black.png",
  "loading.gif"
]
images.load = ()->
  for i in images
    img = new Image
    img.src = static_host + '/images/' + i

queue = (s for s in scripts when s? && !s.test())

if queue.length > 0
  scripts.load(queue, init)
else
  init()
