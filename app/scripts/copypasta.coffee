$ = jQuery
currentLive = false
#yes

ids =
  indicator: 'copy-pasta-edit-indicator'
  dialog: 'copy-pasta-dialog'
  iframe : 'copy-pasta-iframe'
  form : 'copy-pasta-form'

paths =
  indicator: '#' + ids.indicator
  dialog: '#' + ids.dialog
  btn: '.copy-pasta-button'
  active: '.copy-pasta-active'
  form: '#' + ids.form

default_form = '<form style="" id="' + ids.form + '" method="post" action="http://localhost:3000/edits/new" target="' + ids.iframe + '"><input type="hidden" name="view" value="framed"></form>'

blank_dialog = '<div id="' + ids.dialog + '"><iframe frameborder="no" style="margin: 0px; padding: 0px; width: 400px; height: 400px;" id="' + ids.iframe + '" scrolling="no"></iframe></div>'

indicator = () ->
  if $(paths.indicator).length == 0
    $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>')
  $(paths.indicator)

dialog = () ->
  if $(paths.dialog).length == 0
    $('body').append(blank_dialog)
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

  dialog().append(default_form)
  for own key, value of data
    $('<input type="hidden" name="' + key + '">').val(value).appendTo(paths.form)

  dialog().lightbox_me()

  $(paths.form).submit()

iframe_action = (e) ->
  console.debug(e)

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
