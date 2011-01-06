$ = window.jQuery

copypasta_debug = window.location.hash.indexOf('debug') > 0

debug_msg = (msg)->
  if copypasta_debug
    console.debug(msg)

resize = () ->
  m = {label : 'resize', h: $('html').height()}
  send_message(m)

send_message = (msg) ->
  debug_msg("Frame send: " + msg.label + " to " + parent_url)
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

  send_message({'label' : 'ready', form_id : $('form').attr('id')})
  resize()

$('.close').live 'click', ()-> send_message({'label' : 'finished'})
$('.edits .edit').live 'click', ()->
  send_message {
    label: 'preview'
    proposed: $(this).find('.proposed').html()
    element_path: $(this).find('.element_path').html()
  }
$(init)
