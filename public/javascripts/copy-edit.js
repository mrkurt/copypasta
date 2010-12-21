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
  widget : function(original){
    if($('#dialog').length == 0){
      $('body').append('<div id="dialog"></div>');
    }

    $('#dialog')
      .html('<div><textarea>' + original + '</textarea><p><input type="button" value="Submit Changes"> <input type="button" value="Cancel" class="close"></p></div>')
      .lightbox_me()
      .find('textarea').focus();
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
    indicator.css('top', t + 'px').css('left', l + 'px').show();
  },
  deactivate : function(){
    edit.currentLive = false;
    edit.indicator().hide();
  },
  element_click : function(){
    var e = edit.currentLive;
    if(!e){
      console.debug("no element");
      return;
    }
    if(!$(e).attr('original-content')){
      $(e).attr('original-content', $(e).html());
    }
    edit.widget($(e).html());
  }
};

edit.setup();
