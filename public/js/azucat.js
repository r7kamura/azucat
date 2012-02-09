/*
* example:
*   <script type="text/javascript" src="/js/jquery.min.js"></script>
*   <script type="text/javascript" src="/js/azucat.js"></script>
*   <script type="text/javascript"> Azucat.start(9999); </script>
* */
var Azucat = {
  container: undefined,

  start: function(port) {
    var self = this;
    $(function() {
      self.init({ container: $('#timeline') });
      self.setupWebSocket(port);
      self.setupAjaxForm();
      self.focusFirstForm();
    });
  },

  init: function(args) {
    this.container = args.container;
  },

  setupAjaxForm: function() {
    $('form[data-remote]').submit(function() {
      var form = $(this);
      $.post(form.attr('action'), form.serialize());
      form.find('input').val('');
      return false;
    });
  },

  setupWebSocket: function(port) {
    var self = this;
    var ws = new WebSocket('ws://localhost:' + port);
    ws.onmessage = function(e) {
      self.updateTitle(e.data);
      self.prependToBody(e.data);
    };
  },

  focusFirstForm: function() {
    $('input').eq(0).focus();
  },

  addLink: function(str) {
    return str.replace(/(http:\/\/[\x21-\x7e]+)/gi, '<a href="$1">$1</a>');
  },

  prependToBody: function(str) {
    str = this.addLink(str);
    dom = $('<pre/>').append(str);
    this.container.prepend(dom);
  },

  updateTitle: function(str) {
    document.title = this.removeTags(str);
  },

  removeTags: function(str) {
    return str.replace(/<.*?>/g, '');
  }
};
