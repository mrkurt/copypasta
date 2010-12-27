$ = jQuery
currentLive = false

ids =
  indicator: 'copy-pasta-edit-indicator'
  dialog: 'copy-pasta-dialog'

paths =
  indicator: '#' + ids.indicator
  dialog: '#' + ids.dialog
  btn: '.copy-pasta-button'
  active: '.copy-pasta-active'

indicator = () ->
  if $(paths.indicator).length == 0
    $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>')
  $(paths.indicator)

dialog = () ->
  if $(paths.dialog).length == 0
    $('body').append('<div id="' + ids.dialog + '"></div>')
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

  $.post '/edits/new', data, (d, status, xhr) ->
    dialog().html(d).removeClass('loading').lightbox_me()
    deactivate()

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
