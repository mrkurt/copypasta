(function() {
  var $, activate, blank_dialog, currentLive, deactivate, dialog, el, ids, iframe_action, iframe_ready, indicator, paths, send_queued, send_to_iframe, send_to_iframe_queue, show_widget, watch, _i, _len, _ref;
  $ = jQuery;
  currentLive = false;
  iframe_ready = false;
  ids = {
    indicator: 'copy-pasta-edit-indicator',
    dialog: 'copy-pasta-dialog',
    iframe: 'copy-pasta-iframe',
    cancel_btn: 'copy-pasta-cancel'
  };
  paths = {
    indicator: '#' + ids.indicator,
    dialog: '#' + ids.dialog,
    btn: '.copy-pasta-button',
    active: '.copy-pasta-active',
    cancel_btn: '#' + ids.cancel_btn,
    iframe: '#' + ids.iframe
  };
  blank_dialog = '<div id="' + ids.dialog + '"><iframe frameborder="no" style="margin: 0px; padding: 0px; width: 100%; height: 300px; z-index: 2;" id="' + ids.iframe + '" scrolling="no"></iframe><input type="button" class="close" id="copy-pasta-cancel" style="display:none;"></div>';
  indicator = function() {
    if ($(paths.indicator).length === 0) {
      $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>');
    }
    return $(paths.indicator);
  };
  dialog = function(src) {
    if ($(paths.dialog).length === 0) {
      $('body').append(blank_dialog);
    }
    iframe_ready = false;
    if (src != null) {
      $(paths.iframe).attr('src', src);
    }
    return $(paths.dialog);
  };
  activate = function() {
    var pos, sz;
    pos = $(this).offset();
    pos.top = pos.top + 'px';
    pos.left = pos.left + 'px';
    sz = {
      width: $(this).outerWidth() + 'px',
      height: $(this).outerHeight() + 'px'
    };
    indicator().css(sz).css(pos).show();
    return currentLive = this;
  };
  deactivate = function() {
    indicator().hide();
    return currentLive = false;
  };
  watch = function(el) {
    return $(paths.active + ' ' + el).live('mouseover', activate);
  };
  show_widget = function() {
    var data, e, _ref;
    e = currentLive;
    (_ref = e.original_text) != null ? _ref : e.original_text = e.innerHTML;
    indicator().addClass('loading');
    data = {
      'edit[original]': e.original_text,
      'edit[proposed]': e.original_text,
      'edit[url]': window.location.href
    };
    send_to_iframe({
      'label': 'form_data',
      'data': data
    });
    return dialog('http://copypasta.heroku.com/edits/new?view=framed&url=' + escape(window.location.href)).lightbox_me({
      closeClick: false,
      closeEsc: false
    });
  };
  send_to_iframe_queue = [];
  send_to_iframe = function(msg) {
    if (iframe_ready) {
      $(paths.iframe).get(0).contentWindow.postMessage(JSON.stringify(msg), 'http://copypasta.heroku.com');
      return console.debug("Parent Sent: " + msg.label + " to " + window.location.href);
    } else {
      return send_to_iframe_queue.push(msg);
    }
  };
  send_queued = function() {
    var m, _i, _len;
    for (_i = 0, _len = send_to_iframe_queue.length; _i < _len; _i++) {
      m = send_to_iframe_queue[_i];
      send_to_iframe(m);
    }
    return send_to_iframe_queue = [];
  };
  iframe_action = function(e) {
    var data;
    if (e.origin !== 'http://copypasta.heroku.com/') {
      return;
    }
    data = JSON.parse(e.data);
    if (data.label === 'ready') {
      iframe_ready = true;
      return send_queued();
    } else if (data.label === 'finished') {
      $(paths.btn + '.on').click();
      return dialog().find(paths.cancel_btn).click();
    } else if (data.label === 'resize') {
      return $(paths.iframe).animate({
        height: e.data.h + 'px'
      });
    }
  };
  _ref = ['p', 'li', 'h1', 'h2', 'h3', 'h4', 'h5'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    el = _ref[_i];
    watch(el);
  }
  $(paths.indicator).live('mouseout', deactivate);
  $(paths.indicator).live('click', show_widget);
  $(paths.btn + '.off').live('click', function() {
    var btn;
    btn = $(this);
    btn.removeClass('off').addClass('on');
    return $(btn.attr('href')).addClass('copy-pasta-active');
  });
  $(paths.btn + '.on').live('click', function() {
    var btn;
    btn = $(this);
    btn.removeClass('on').addClass('off');
    $(btn.attr('href')).removeClass('copy-pasta-active');
    return false;
  });
  window.addEventListener('message', iframe_action, false);
}).call(this);
