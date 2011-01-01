(function() {
  var $, activate, blank_dialog, copypasta, css, currentContainer, currentLive, deactivate, dialog, form_data, ids, iframe_action, iframe_ready, images, indicator, init, load_iframe_form, paths, queue, s, scripts, send_queued, send_to_iframe, send_to_iframe_queue, show_widget, static_host, watch;
  static_host = "http://copypasta.heroku.com";
  css = document.createElement('link');
  css.rel = "stylesheet";
  css.href = static_host + "/stylesheets/compiled/copypasta.css";
  document.documentElement.childNodes[0].appendChild(css);
  $ = false;
  currentLive = false;
  currentContainer = false;
  iframe_ready = false;
  form_data = {};
  window.copypasta = copypasta = {
    $: false,
    page_id: copypasta_page_id
  };
  ids = {
    indicator: 'copy-pasta-edit-indicator',
    dialog: 'copy-pasta-dialog',
    iframe: 'copy-pasta-iframe',
    cancel_btn: 'copy-pasta-cancel',
    overlay: 'copy-pasta-overlay'
  };
  paths = {
    indicator: '#' + ids.indicator,
    dialog: '#' + ids.dialog,
    btn: '.copy-pasta-button',
    active: '.copy-pasta-active',
    cancel_btn: '#' + ids.cancel_btn,
    iframe: '#' + ids.iframe,
    overlay: '#' + ids.overlay
  };
  blank_dialog = '<div id="' + ids.dialog + '" class="copy-pasta-loading"><div id="copy-pasta-overlay"></div><iframe frameborder="no"id="' + ids.iframe + '" scrolling="no"></iframe><input type="button" class="close" id="copy-pasta-cancel" style="display:none;"></div>';
  indicator = function() {
    if ($(paths.indicator).length === 0) {
      $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>');
    }
    return $(paths.indicator);
  };
  dialog = function(src) {
    if (src != null) {
      src = src + "&" + Math.random();
    }
    if ($(paths.dialog).length === 0) {
      $('body').append(blank_dialog);
    }
    if (src != null) {
      $(paths.overlay).show();
      iframe_ready = false;
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
    var e, _ref;
    e = currentLive;
    (_ref = e.original_text) != null ? _ref : e.original_text = e.innerHTML;
    indicator().addClass('loading');
    form_data.new_edit = {
      'edit[original]': e.original_text,
      'edit[proposed]': e.original_text,
      'edit[url]': window.location.href,
      'edit[element_path]': copypasta.getElementCssPath(e, currentContainer)
    };
    return dialog('http://copypasta.heroku.com/edits/new?view=framed&url=' + escape(window.location.href) + '&page[key]=' + escape(copypasta.page_id)).lightbox_me();
  };
  send_to_iframe_queue = [];
  send_to_iframe = function(msg) {
    if (iframe_ready) {
      return $(paths.iframe).get(0).contentWindow.postMessage(JSON.stringify(msg), 'http://copypasta.heroku.com');
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
  load_iframe_form = function(id) {
    if ((id != null) && (form_data[id] != null)) {
      return send_to_iframe({
        'label': 'form_data',
        'data': form_data[id]
      });
    }
  };
  iframe_action = function(e) {
    var data;
    if (e.origin !== 'http://copypasta.heroku.com') {
      return;
    }
    data = JSON.parse(e.data);
    if (data.label === 'ready') {
      iframe_ready = true;
      send_queued();
      if (data.form_id != null) {
        load_iframe_form(data.form_id);
      }
      return $(paths.overlay).fadeOut();
    } else if (data.label === 'finished') {
      iframe_ready = false;
      return dialog().find(paths.cancel_btn).click();
    } else if (data.label === 'resize') {
      return $(paths.iframe).animate({
        height: data.h + 'px'
      });
    }
  };
  init = function() {
    var el, _i, _len, _ref;
    lightbox_me_init($);
    _ref = ['p', 'li', 'h1', 'h2', 'h3', 'h4', 'h5'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      el = _ref[_i];
      watch(el);
    }
    $(paths.indicator).live('mouseout', deactivate);
    $(paths.indicator).live('click', show_widget);
    $(paths.btn + '.off').live('click', function() {
      var btn;
      images.load();
      btn = $(this);
      btn.removeClass('off').addClass('on');
      return currentContainer = $(btn.attr('href')).addClass('copy-pasta-active').get(0);
    });
    $(paths.btn + '.on').live('click', function() {
      var btn;
      btn = $(this);
      btn.removeClass('on').addClass('off');
      $(btn.attr('href')).removeClass('copy-pasta-active');
      return currentContainer = false;
    });
    if (window.addEventListener != null) {
      return window.addEventListener('message', iframe_action, false);
    } else if (window.attachEvent != null) {
      return window.attachEvent('onmessage', function() {
        return iframe_action(event);
      });
    }
  };
  scripts = [
    {
      test: function() {
        return window.jQuery && window.jQuery.fn && window.jQuery.fn.jquery > "1.4.2";
      },
      src: 'http://copypasta.heroku.com/javascripts/jquery-1.4.2.min.js',
      callback: function() {
        return (copypasta.$ = $ = window.jQuery).noConflict(1);
      }
    }, {
      test: function() {
        return window.jQuery && window.jQuery.fn.lightbox_me;
      },
      src: 'http://copypasta.heroku.com/javascripts/utils.min.js'
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
      if (!def.loaded && (!d || d === 'loaded' || d === 'complete')) {
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
    return document.documentElement.childNodes[0].appendChild(s);
  };
  images = ["translucent-black.png", "translucent-blue.png", "loading.gif"];
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
