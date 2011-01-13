w = window
return unless w.postMessage

append_to_element = (e for e in document.documentElement.childNodes when e.nodeType == 1)[0]
iframe_host = "http://localhost:3000"
static_host = "http://localhost:3000"
css = document.createElement('link')
css.rel = "stylesheet"
css.href = static_host + "/stylesheets/compiled/copypasta.css"
append_to_element.appendChild(css)

$ = false
currentLive = false
currentContainer = false
form_data = {}

w.copypasta = copypasta = {$ : false, page_id : w.copypasta_page_id}
copypasta.debug = w.copypasta_debug || w.location.hash.indexOf('copypasta-debug') > 0
copypasta.auto_start = w.copypasta_auto_start || w.location.hash.indexOf('copypasta-auto') > 0
copypasta.include_url_hash = w.copypasta_include_url_hash || false

debug_msg = (msg)->
  if copypasta.debug
    console.debug(msg)

ids =
  indicator: 'copy-pasta-edit-indicator'
  dialog: 'copy-pasta-dialog'
  iframe : 'copy-pasta-iframe'
  overlay: 'copy-pasta-overlay'
  btn: 'copy-pasta-button'

paths =
  indicator: '#' + ids.indicator
  dialog: '#' + ids.dialog
  btn: '#' + ids.btn
  active: '.copy-pasta-active'
  iframe: '#' + ids.iframe
  overlay: '#' + ids.overlay
  status: '#copy-pasta-button .status'


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

find_current_url = ()->
  oh = w.location.hash
  if copypasta.include_url_hash
    w.location.hash = w.location.hash.replace(/#?copypasta-[a-z]+/g,'')
  else
    w.location.hash = ''

  url = ($('link[rel=canonical]').attr('href') || w.location.href.replace(/#+$/,''))
  w.location.hash = oh
  url

blank_dialog = (class_name) -> '<div id="' + ids.dialog + '" class="' + class_name + '"><div id="' + ids.overlay + '"></div><iframe frameborder="no" id="' + ids.iframe + '" scrolling="no"></iframe></div>'

show_dialog_overlay = ()->
  $(paths.overlay).fadeIn ()->
    debug_msg("Overlay shown")

hide_dialog_overlay = ()->
  $(paths.overlay).fadeOut ()->
    debug_msg("Overlay hidden")

resize_dialog = (data)->
  $(paths.dialog).animate {height : data.h}

show_edit_dialog = ()->
  e = currentLive
  e.original_text ?= e.innerHTML

  page_id = copypasta.page_id ? ''
  form_data.new_edit =
    'edit[original]' : e.original_text
    'edit[proposed]' : e.original_text
    'edit[url]' : find_current_url()
    'edit[element_path]' : copypasta.getElementCssPath(e, currentContainer)
  
  url = iframe_host + '/edits/new?view=framed&url=' + escape(find_current_url()) + '&page[key]=' + escape(page_id)

  show_dialog(url, 'edit')

show_info_dialog = ()->
  page_id = copypasta.page_id ? ''
  url = iframe_host + '/edits?view=framed&url=' + escape(find_current_url()) + '&page[key]=' + escape(page_id)

  show_dialog(url, 'info')

dialog_types =
  default:
    options: { escClose: true, overlayClose: true, overlayId : 'copy-pasta-lightbox-overlay', containerId : 'copy-pasta-lightbox-container', opacity: 70, persist: true}
  edit:
    class: 'copy-pasta-lightbox'
  info:
    class: 'copy-pasta-widget'
    options: { modal: false, position: [100, '0%'] }

show_dialog = (src, type) ->
  copypasta.modal_init($) unless $.fn.modal

  if $.modal && $('#copy-pasta-lightbox-container').length > 0
    $.modal.close()
    setTimeout (()-> show_dialog(src,type)), 11 #modal closes async in 10ms
  else
    t = dialog_types.default
    t.options.onShow = ()->
      if src
        $(paths.overlay).show()
        debug_msg("Overlay shown")
        src = src
        src += '#debug' if copypasta.debug
        debug_msg("Loading iframe: " + src)
        $(paths.iframe).attr('src', src)

    if type && dialog_types[type]
      t = dialog_types[type]
      t.options = {} unless t.options
      t.options = $.extend(t.options, dialog_types.default.options) unless t.extended
      t.extended = true

    $.modal(blank_dialog(t.class), t.options)

show_edit_preview = (data)->
  debug_msg('Previewing ' + data.element_path)
  target = $(currentContainer).find(data.element_path)
  pos = target.position()
  unless target.get(0).original_text
    target.get(0).original_text = target.html()
  s = if $('html').scrollTop(1) > 0 then 'html' else 'body'
  $(s).animate {scrollTop : pos.top}, ()->
    target.html(data.proposed).addClass('copy-pasta-preview')

hide_edit_preview = (path)->
  target = $(currentContainer).find(path)
  target.removeClass('copy-pasta-preview').html(target.get(0).original_text)

hide_edit_previews = ()->
  $('.copy-pasta-preview').each ()->
    o = this.original_text ? $(this).html()
    $(this).removeClass('copy-pasta-preview').html(o)

is_scrolled_into_view = (elem)->
    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()

    elemTop = $(elem).offset().top
    elemBottom = elemTop + $(elem).height()

    (elemBottom >= docViewTop) && (elemTop <= docViewBottom)&& (elemBottom <= docViewBottom) &&  (elemTop >= docViewTop)

load_iframe_form = (id)->
  if id && form_data[id]
    send_to_iframe('label' : 'form_data', 'data' : form_data[id])

send_to_iframe = (msg) ->
  debug_msg("Parent send: " + msg.label + " to " + iframe_host)
  msg = JSON.stringify(msg)
  $(paths.iframe).get(0).contentWindow.postMessage(msg, iframe_host)

receive_from_iframe = (e) ->
  unless e.origin == iframe_host
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
  else if data.label == 'preview'
    show_edit_preview(data)
  else if data.label == 'preview-off'
    hide_edit_preview(data.element_path)
  else if data.label == 'finished'
    $.modal.close() if $.modal
    hide_edit_previews()
  else if data.label == 'resize'
    resize_dialog(data)

init = ()->
  watch el for el in ['p', 'li', 'h1', 'h2', 'h3', 'h4', 'h5']

  if copypasta.auto_start
    currentContainer = $($(paths.btn).attr('href') || 'body').addClass('copy-pasta-active').get(0)
    show_info_dialog()

  $(paths.btn + '.off').live 'click', ()->
    if $(this).hasClass('on')
      btn = $(this)
      btn.removeClass('on')
      $(btn.attr('href')).removeClass('copy-pasta-active')
    else
      images.load()
      btn = $(this)
      btn.addClass('on')
      currentContainer = $(btn.attr('href') || 'body').addClass('copy-pasta-active').get(0)

  $(paths.btn + ' .status').live 'click', ()->
    p = $(this).parent().attr('href') || 'body'
    currentContainer = $(p).get(0)
    show_info_dialog()
    return false

  if w.addEventListener
    w.addEventListener('message', receive_from_iframe, false)
  else if w.attachEvent
    w.attachEvent('onmessage', ()-> receive_from_iframe(event))

scripts = [
    {
      test: ()->
        if w.jQuery && w.jQuery.fn && w.jQuery.fn.jquery > "1.3"
          $ = w.jQuery
          debug_msg("Using existing jquery: version " + $.fn.jquery)
          true
      #src: 'http://localhost:3000/javascripts/jquery-1.3.min.js'
      src: 'http://localhost:3000/javascripts/jquery-1.4.4.min.js'
      callback : ()->
        (copypasta.$ = $ = w.jQuery).noConflict(1)
        debug_msg("Loaded own jquery: version " + $.fn.jquery)
    },
    {
      test: ()-> copypasta.getElementCssPath && w.jQuery && w.jQuery.fn.lightbox_me
      src: 'http://localhost:3000/javascripts/utils.js'
    }
]

scripts.load = (queue, callback) ->
  remaining = (i for i in queue when !i.state)
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
      def.callback() if def.callback
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

queue = (s for s in scripts when s && !s.test())

if queue.length > 0
  scripts.load(queue, init)
else
  init()
