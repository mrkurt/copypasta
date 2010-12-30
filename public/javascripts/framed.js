(function() {
  var $, fill_form, init, receive_message, resize, send_message;
  $ = jQuery;
  init = function() {
    if (window.addEventListener != null) {
      window.addEventListener('message', receive_message, false);
    } else if (window.attachEvent != null) {
      window.attachEvent('onmessage', function() {
        return receive_message(event);
      });
    }
    send_message({
      'label': 'ready'
    });
    return resize();
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
    return parent.postMessage(JSON.stringify(msg), parent_url);
  };
  fill_form = function(data) {
    return $('form input, form textarea').each(function() {
      var attr;
      attr = $(this).attr('name');
      if (attr in data) {
        return $(this).val(data[attr]);
      }
    });
  };
  receive_message = function(e) {
    var data;
    if (parent_url.indexOf(e.origin) !== 0) {
      return;
    }
    data = JSON.parse(e.data);
    if (data.label === 'form_data') {
      return fill_form(data.data);
    }
  };
  $('.close').live('click', function() {
    return send_message({
      'label': 'finished'
    });
  });
  $(init);
}).call(this);
