var edit = {
  start : function(){
    $(this).parent().addClass('editing');
    $(this).addClass('active');
  },
  indicator : function(){
    if($('#edit-indicator').length == 0){
      $('body').append('<div id="edit-indicator"><p>click to edit</p></div>');
    }
    return $('#edit-indicator');
  },
  widget : function(original){
    if($('#dialog').length == 0){
      $('body').append('<div id="dialog"></div>');
    }

    $('#dialog')
      .html('<div><textarea>' + original + '</textarea><input type="button" value="Submit Changes"></div>')
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
    $(elementSelector).live('mouseout', edit.deactivate);
    $('#edit-indicator').live('click', edit.element_click);
    $('#start-edit').live('click', edit.start);
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
