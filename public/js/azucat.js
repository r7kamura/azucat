/*
* example:
*   <script type="text/javascript" src="/js/jquery.min.js"></script>
*   <script type="text/javascript" src="/js/azucat.js"></script>
*   <script type="text/javascript"> Azucat.start(9999); </script>
* */
var Azucat = {
  container: undefined,

  unreadCount: 0,

  start: function(port) {
    var self = this;
    $(function() {
      self.init({ container: $('#timeline') });
      self.setupWebSocket(port);
      self.setupAjaxForm();
      self.setupUnreadCounter();
      self.focusFirstForm();
    });
  },

  init: function(args) {
    this.container = args.container;
  },

  setupUnreadCounter: function() {
    var self = this;
    $(window).keydown(function() { self.updateUnreadCounter(0) })
      .keydown();
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
      self.countupUnreadCounter();
      self.updateTitle(e.data);
      self.prependToBody(e.data);
    };
  },

  updateUnreadCounter: function(count) {
    Tinycon.setBubble(count);
    this.unreadCount = count;
  },

  countupUnreadCounter: function() {
    this.updateUnreadCounter(++this.unreadCount);
  },

  focusFirstForm: function() {
    $('input').eq(0).focus();
  },

  addLink: function(str) {
    return str.replace(
      /(https?:\/\/[\x21-\x7e]+)/gi, '<a href="$1" target="_blank">$1</a>');
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
