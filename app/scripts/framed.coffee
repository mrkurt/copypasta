$ = window.jQuery

copypasta_debug = window.location.hash.indexOf('debug') > 0

debug_msg = (msg)->
  if copypasta_debug
    if console && console.log
      console.log(msg)

resize = () ->
  m = {label : 'resize', h: $('html').height()}
  send_message(m)

send_message = (msg) ->
  debug_msg("Frame send: " + msg.label + " to " + parent_url)
  msg['frame_type'] = $('body').attr('class') unless msg.frame_type
  msg = JSON.stringify(msg)
  parent.postMessage(msg, parent_url)

fill_form = (data) ->
  $('form input, form textarea').each ()->
    attr = $(this).attr('name')
    if attr of data
      $(this).val(data[attr])
  send_message { label : 'form_data_loaded' }

receive_message = (e)->
  unless parent_url.indexOf(e.origin) == 0
    debug_msg(e)
    return
  data = JSON.parse(e.data)
  debug_msg("Frame receive: " + data.label + " from " + e.origin)
  if data.label == 'form_data'
    fill_form data.data

init = ()->
  if window.addEventListener?
    window.addEventListener('message', receive_message, false)
  else if window.attachEvent?
    window.attachEvent('onmessage', ()-> receive_message(event))

  send_message({label : 'ready', form_id : $('form.primary').attr('id')})
  resize()

$('.close').live 'click', ()->
  msg = {label : 'finished'}
  if (msg.frame_type = $('body').attr('class')) == 'dialog'
    msg.reload_widget = true if $('.success').length > 0
  send_message(msg)
last_checked_preview = false
$('input.edit-preview-toggle').live 'click', ()->
  if last_checked_preview
    send_message {
      label: 'preview-off'
      element_path: last_checked_preview
    }

  last_checked_preview = $(this).parent().find('.element_path').val()
  send_message {
    label: 'preview'
    proposed: $(this).val()
    element_path: last_checked_preview
  }

$('form.editor-options input').live 'change', ()->
  send_message({label : 'loading'})
  $(this).closest('form').submit()

$('input.back').live 'click', ()->
  history.go(-1)

$(init)
