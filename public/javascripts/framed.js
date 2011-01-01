(function() {
  var $, copypasta_debug, debug_msg, fill_form, init, receive_message, resize, send_message;
  $ = window.jQuery;
  copypasta_debug = window.location.hash.indexOf('debug') > 0;
  debug_msg = function(msg) {
    if (copypasta_debug) {
      return console.debug(msg);
    }
  };
  resize = function() {
    var m;
    m = {
      label: 'resize',
      h: $('html').height()
    };
    return send_message(m);
  };
  send_message = function(msg) {
    debug_msg("Frame send: " + msg.label + " to " + parent_url);
    msg = JSON.stringify(msg);
    return parent.postMessage(msg, parent_url);
  };
  fill_form = function(data) {
    $('form input, form textarea').each(function() {
      var attr;
      attr = $(this).attr('name');
      if (attr in data) {
        return $(this).val(data[attr]);
      }
    });
    return send_message({
      label: 'form_data_loaded'
    });
  };
  receive_message = function(e) {
    var data;
    if (parent_url.indexOf(e.origin) !== 0) {
      debug_msg(e);
      return;
    }
    data = JSON.parse(e.data);
    debug_msg("Frame receive: " + data.label + " from " + e.origin);
    if (data.label === 'form_data') {
      return fill_form(data.data);
    }
  };
  init = function() {
    if (window.addEventListener != null) {
      window.addEventListener('message', receive_message, false);
    } else if (window.attachEvent != null) {
      window.attachEvent('onmessage', function() {
        return receive_message(event);
      });
    }
    send_message({
      'label': 'ready',
      form_id: $('form').attr('id')
    });
    return resize();
  };
  $('.close').live('click', function() {
    return send_message({
      'label': 'finished'
    });
  });
  $(init);
}).call(this);
