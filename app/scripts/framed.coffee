$ = jQuery

init = ()->
  window.addEventListener('message', receive_message, false)
  send_message({'label' : 'ready'})
  resize()

resize = () ->
  m = {label : 'resize', h: $('html').height()}
  send_message(m)

send_message = (msg) ->
  parent.postMessage(JSON.stringify(msg), parent_url)
  console.debug("Frame Sent: " + msg.label + " to " + parent_url)

fill_form = (data) ->
  $('form input, form textarea').each ()->
    attr = $(this).attr('name')
    if attr of data
      $(this).val(data[attr])

receive_message = (e)->
  return unless parent_url.indexOf(e.origin) == 0
  data = JSON.parse(e.data)
  if data.label == 'form_data'
    fill_form data.data

$('.close').live 'click', ()-> send_message({'label' : 'finished'})
$(init)
