var edit = {
  start : function(){
    $(this).parent().addClass('editing');
    $(this).addClass('active');
  },
  stop : function(){
    $('#start-edit').removeClass('active').parent().removeClass('editing');
    edit.indicator().remove();
    return false;
  },
  indicator : function(){
    if($('#edit-indicator').length == 0){
      $('body').append('<div id="edit-indicator"><p>click to correct</p></div>');
    }
    return $('#edit-indicator');
  },
  widget : function(original, path){
    if($('#dialog').length == 0){
      $('body').append('<div id="dialog"><iframe id="copy_pasta_frame" frameborder="no" style="width: 100%; height: 500px;"></iframe><a href="#" class="close">Close (esc)</a><form id="copy_pasta_form" target="copy_pasta_frame" action="/edits/new" method="post"><input id="copy_pasta_input_original" type="hidden" name="edit[original]"><input id="copy_pasta_input_proposed" type="hidden" name="edit[proposed]"><input id="copy_pasta_input_url" type="hidden" name="edit[url]"><input id="copy_pasta_input_path" type="hidden" name="edit[element_path]"></form></div>');
    }

    $('#copy_pasta_input_original').val(original);
    $('#copy_pasta_input_proposed').val(original);
    $('#copy_pasta_input_url').val(window.location.href);
    $('#dialog').lightbox_me();
    $('#copy_pasta_form').submit();
  },
  setup : function(){
    var elementSelector = '';
    for(var i = 0; i < edit.elements.length; i++){
      if(i > 0) elementSelector += ', ';
      elementSelector += '.editing ' + edit.elements[i];
    }
    $(elementSelector).live('mouseover', edit.activate);
    $('#edit-indicator').live('click', edit.element_click);
    $('#edit-indicator').live('mouseout', edit.deactivate);
    $('#start-edit').live('click', edit.start);
    $('#end-edit').live('click', edit.stop);
  },
  elements : ['p', 'li', 'h1', 'h2', 'h3', 'h4', 'h5'],
  currentLive : false,
  activate : function(){
    var t = 0, l = 0, position, indicator = edit.indicator();
    position = $(this).offset();
    t = position.top;
    l = position.left;
    indicator
      .css('width', $(this).outerWidth())
      .css('height', $(this).outerHeight());
    edit.currentLive = this;
    indicator.css('top', t + 'px').css('left', l + 'px').fadeIn();
  },
  deactivate : function(){
    edit.currentLive = false;
    edit.indicator().hide();
  },
  element_click : function(){
    var e = edit.currentLive, 
        others = $(edit.currentLive.tagName),
        indicator = edit.indicator(),
        i;
    if(!e){
      console.debug("no element");
      return;
    }
    if(!$(e).attr('original-content')){
      $(e).attr('original-content', $(e).html());
    }

    edit.widget($(e).html(), '');
  }
};

edit.setup();
