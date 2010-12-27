(function() {
  var $, activate, currentLive, deactivate, dialog, el, ids, indicator, paths, show_widget, watch, _i, _len, _ref;
  $ = jQuery;
  currentLive = false;
  ids = {
    indicator: 'copy-pasta-edit-indicator',
    dialog: 'copy-pasta-dialog'
  };
  paths = {
    indicator: '#' + ids.indicator,
    dialog: '#' + ids.dialog,
    btn: '.copy-pasta-button',
    active: '.copy-pasta-active'
  };
  indicator = function() {
    if ($(paths.indicator).length === 0) {
      $('body').append('<div id="' + ids.indicator + '"><p>click to correct</p></div>');
    }
    return $(paths.indicator);
  };
  dialog = function() {
    if ($(paths.dialog).length === 0) {
      $('body').append('<div id="' + ids.dialog + '"></div>');
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
    return $.post('/edits/new', data, function(d, status, xhr) {
      dialog().html(d).removeClass('loading').lightbox_me();
      return deactivate();
    });
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
    return $(btn.attr('href')).removeClass('copy-pasta-active');
  });
}).call(this);
