(function() {
  var $, activate, append_to_element, blank_dialog, copypasta, css, currentContainer, currentLive, deactivate, debug_msg, dialog_types, e, form_data, hide_dialog_overlay, hide_edit_previews, ids, images, indicator, init, load_iframe_form, paths, queue, receive_from_iframe, resize_dialog, s, scripts, send_to_iframe, show_dialog, show_dialog_overlay, show_edit_dialog, show_edit_preview, show_info_dialog, static_host, watch;
  if (window.postMessage == null) {
    r345eturn;
  }
  append_to_element = ((function() {
    var _i, _len, _ref, _results;
    _ref = document.documentElement.childNodes;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      if (e.nodeType === 1) {
        _results.push(e);
      }
    }
    return _results;
  })())[0];
  static_host = "http://copypasta.heroku.com";
  css = document.createElement('link');
  css.rel = "stylesheet";
  css.href = static_host + "/stylesheets/compiled/copypasta.css";
  append_to_element.appendChild(css);
  $ = false;
  currentLive = false;
  currentContainer = false;
  form_data = {};
  window.copypasta = copypasta = {
    $: false,
    page_id: window.copypasta_page_id,
    auto_start: window.copypasta_auto_start
  };
  copypasta.debug = window.copypasta_debug || window.location.hash.indexOf('debug') > 0;
  debug_msg = function(msg) {
    if (copypasta.debug) {
      return console.debug(msg);
    }
  };
  ids = {
    indicator: 'copy-pasta-edit-indicator',
    dialog: 'copy-pasta-dialog',
    iframe: 'copy-pasta-iframe',
    overlay: 'copy-pasta-overlay'
  };
  paths = {
    indicator: '#' + ids.indicator,
    dialog: '#' + ids.dialog,
    btn: '.copy-pasta-button',
    active: '.copy-pasta-active',
    iframe: '#' + ids.iframe,
    overlay: '#' + ids.overlay,
    status: '.copy-pasta-button .status'
  };
  indicator = function() {
    if ($(paths.indicator).length === 0) {
      $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>');
      $(paths.indicator).bind('mouseout', deactivate);
      $(paths.indicator).bind('click', show_edit_dialog);
    }
    return $(paths.indicator);
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
  blank_dialog = function(class_name) {
    return '<div id="' + ids.dialog + '" class="' + class_name + '"><div id="' + ids.overlay + '"></div><iframe frameborder="no"id="' + ids.iframe + '" scrolling="no"></iframe></div>';
  };
  show_dialog_overlay = function() {
    return $(paths.overlay).fadeIn(function() {
      return debug_msg("Overlay shown");
    });
  };
  hide_dialog_overlay = function() {
    return $(paths.overlay).fadeOut(function() {
      return debug_msg("Overlay hidden");
    });
  };
  resize_dialog = function(data) {
    return $(paths.dialog).animate({
      height: data.h + 'px'
    });
  };
  show_edit_dialog = function() {
    var page_id, url, _ref, _ref2;
    e = currentLive;
    (_ref = e.original_text) != null ? _ref : e.original_text = e.innerHTML;
    page_id = (_ref2 = copypasta.page_id) != null ? _ref2 : '';
    form_data.new_edit = {
      'edit[original]': e.original_text,
      'edit[proposed]': e.original_text,
      'edit[url]': window.location.href,
      'edit[element_path]': copypasta.getElementCssPath(e, currentContainer)
    };
    url = 'http://copypasta.heroku.com/edits/new?view=framed&url=' + escape(window.location.href) + '&page[key]=' + escape(page_id);
    return show_dialog(url, 'edit');
  };
  show_info_dialog = function() {
    var page_id, url, _ref;
    page_id = (_ref = copypasta.page_id) != null ? _ref : '';
    url = 'http://copypasta.heroku.com/edits?view=framed&url=' + escape(window.location.href) + '&page[key]=' + escape(page_id);
    return show_dialog(url, 'info');
  };
  dialog_types = {
    "default": {
      options: {
        escClose: true,
        overlayClose: true,
        overlayId: 'copy-pasta-lightbox-overlay',
        containerId: 'copy-pasta-lightbox-container',
        opacity: 70,
        persist: true
      }
    },
    edit: {
      "class": 'copy-pasta-lightbox'
    },
    info: {
      "class": 'copy-pasta-widget',
      options: {
        modal: false,
        position: [200, '0%']
      }
    }
  };
  show_dialog = function(src, type) {
    var t;
    if (!$.fn.modal) {
      copypasta.modal_init($);
    }
    if ($.modal && $('#copy-pasta-lightbox-container').length > 0) {
      $.modal.close();
      return setTimeout((function() {
        return show_dialog(src, type);
      }), 11);
    } else {
      t = dialog_types["default"];
      t.options.onShow = function() {
        if (src != null) {
          $(paths.overlay).show();
          debug_msg("Overlay shown");
          src = src;
          if (copypasta.debug) {
            src += '#debug';
          }
          debug_msg("Loading iframe: " + src);
          return $(paths.iframe).attr('src', src);
        }
      };
      if ((type != null) && (dialog_types[type] != null)) {
        t = dialog_types[type];
        if (t.options == null) {
          t.options = {};
        }
        if (!t.extended) {
          t.options = $.extend(t.options, dialog_types["default"].options);
        }
        t.extended = true;
      }
      return $.modal(blank_dialog(t["class"]), t.options);
    }
  };
  show_edit_preview = function(data) {
    var pos, target;
    debug_msg('Previewing ' + data.element_path);
    target = $(currentContainer).find(data.element_path);
    pos = target.position();
    window.scrollTo(pos.left, pos.top);
    if (target.get(0).original_text == null) {
      target.get(0).original_text = target.html();
    }
    return target.html(data.proposed).addClass('copy-pasta-preview');
  };
  hide_edit_previews = function() {
    return $('.copy-pasta-preview').each(function() {
      var o, _ref;
      o = (_ref = this.original_text) != null ? _ref : $(this).html();
      return $(this).removeClass('copy-pasta-preview').html(o);
    });
  };
  load_iframe_form = function(id) {
    if ((id != null) && (form_data[id] != null)) {
      return send_to_iframe({
        'label': 'form_data',
        'data': form_data[id]
      });
    }
  };
  send_to_iframe = function(msg) {
    debug_msg("Parent send: " + msg.label + " to http://copypasta.heroku.com");
    msg = JSON.stringify(msg);
    return $(paths.iframe).get(0).contentWindow.postMessage(msg, 'http://copypasta.heroku.com');
  };
  receive_from_iframe = function(e) {
    var data;
    if (e.origin !== 'http://copypasta.heroku.com') {
      debug_msg(e);
      return;
    }
    data = JSON.parse(e.data);
    debug_msg("Parent receive: " + data.label + " from " + e.origin);
    if (data.label === 'ready') {
      if (!load_iframe_form(data.form_id)) {
        return hide_dialog_overlay();
      }
    } else if (data.label === 'form_data_loaded') {
      return hide_dialog_overlay();
    } else if (data.label === 'preview') {
      return show_edit_preview(data);
    } else if (data.label === 'finished') {
      if ($.modal != null) {
        $.modal.close();
      }
      return hide_edit_previews();
    } else if (data.label === 'resize') {
      return resize_dialog(data);
    }
  };
  init = function() {
    var el, _i, _len, _ref;
    _ref = ['p', 'li', 'h1', 'h2', 'h3', 'h4', 'h5'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      el = _ref[_i];
      watch(el);
    }
    if (copypasta.auto_start) {
      $(paths.btn).removeClass('off').addClass('on');
      currentContainer = $('body').addClass('copy-pasta-active').get(0);
    }
    $(paths.btn + '.off').live('click', function() {
      var btn;
      if ($(this).hasClass('on')) {
        btn = $(this);
        btn.removeClass('on');
        return $(btn.attr('href')).removeClass('copy-pasta-active');
      } else {
        images.load();
        btn = $(this);
        btn.addClass('on');
        return currentContainer = $(btn.attr('href') || 'body').addClass('copy-pasta-active').get(0);
      }
    });
    $(paths.btn + ' .status').live('click', function() {
      var p;
      p = $(this).parent().attr('href') || 'body';
      currentContainer = $(p).get(0);
      show_info_dialog();
      return false;
    });
    if (window.addEventListener != null) {
      return window.addEventListener('message', receive_from_iframe, false);
    } else if (window.attachEvent != null) {
      return window.attachEvent('onmessage', function() {
        return receive_from_iframe(event);
      });
    }
  };
  scripts = [
    {
      test: function() {
        if (window.jQuery && window.jQuery.fn && window.jQuery.fn.jquery > "1.3") {
          $ = window.jQuery;
          debug_msg("Using existing jquery: version " + $.fn.jquery);
          return true;
        }
      },
      src: 'http://copypasta.heroku.com/javascripts/jquery-1.4.4.min.js',
      callback: function() {
        (copypasta.$ = $ = window.jQuery).noConflict(1);
        return debug_msg("Loaded own jquery: version " + $.fn.jquery);
      }
    }, {
      test: function() {
        return copypasta.getElementCssPath && window.jQuery && window.jQuery.fn.lightbox_me;
      },
      src: 'http://copypasta.heroku.com/javascripts/utils.js'
    }, {
      test: function() {
        return window.JSON;
      },
      src: 'http://copypasta.heroku.com/javascripts/json2.min.js'
    }
  ];
  scripts.load = function(queue, callback) {
    var def, i, remaining, s;
    remaining = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = queue.length; _i < _len; _i++) {
        i = queue[_i];
        if (!(i.state != null)) {
          _results.push(i);
        }
      }
      return _results;
    })();
    if (remaining.length === 0) {
      return;
    }
    def = remaining.pop();
    def.state = 'pending';
    s = document.createElement('script');
    s.type = "text/javascript";
    s.src = def.src;
    s.onload = s.onreadystatechange = function() {
      var d, i;
      d = this.readyState;
      if (def.state !== 'loaded' && (!d || d === 'loaded' || d === 'complete')) {
        def.state = 'loaded';
        if (def.callback != null) {
          def.callback();
        }
        remaining = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = queue.length; _i < _len; _i++) {
            i = queue[_i];
            if (i.state !== 'loaded') {
              _results.push(i);
            }
          }
          return _results;
        })();
        if (remaining.length === 0) {
          return callback();
        }
      }
    };
    if (queue.length > 0) {
      scripts.load(queue, callback);
    }
    return append_to_element.appendChild(s);
  };
  images = ["translucent-blue.png", "translucent-black.png", "loading.gif"];
  images.load = function() {
    var i, img, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = images.length; _i < _len; _i++) {
      i = images[_i];
      img = new Image;
      _results.push(img.src = static_host + '/images/' + i);
    }
    return _results;
  };
  queue = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = scripts.length; _i < _len; _i++) {
      s = scripts[_i];
      if ((s != null) && !s.test()) {
        _results.push(s);
      }
    }
    return _results;
  })();
  if (queue.length > 0) {
    scripts.load(queue, init);
  } else {
    init();
  }
}).call(this);
