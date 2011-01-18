(function() {
  var $, copypasta_debug, debug_msg, fill_form, init, last_checked_preview, receive_message, resize, send_message;
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
    msg['frame_type'] = $('body').attr('class');
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
      label: 'ready',
      form_id: $('form.primary').attr('id')
    });
    return resize();
  };
  $('.close').live('click', function() {
    return send_message({
      label: 'finished'
    });
  });
  last_checked_preview = false;
  $('input.edit-preview-toggle').live('change', function() {
    if (last_checked_preview) {
      send_message({
        label: 'preview-off',
        element_path: last_checked_preview
      });
    }
    last_checked_preview = $(this).parent().find('.element_path').val();
    return send_message({
      label: 'preview',
      proposed: $(this).val(),
      element_path: last_checked_preview
    });
  });
  $('form.editor-options input').live('change', function() {
    var this2;
    this2 = this;
    return $(this).closest('tr').fadeOut(function() {
      return $(this2).closest('form').submit();
    });
  });
  $('input.back').live('click', function() {
    return history.go(-1);
  });
  $(init);
}).call(this);
