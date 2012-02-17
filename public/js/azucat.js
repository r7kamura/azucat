/*
* example:
*   <script type="text/javascript" src="/js/jquery.min.js"></script>
*   <script type="text/javascript" src="/js/azucat.js"></script>
*   <script type="text/javascript"> Azucat.start(9999); </script>
* */
var Azucat = {
  container: undefined,
  onMessage: [],
  unreadCount: 0,

  start: function(port, opts) {
    opts = $.extend({
      audio:   true,
      counter: true
    }, opts);

    var self = this;
    $(function() {
      self.init({ container: $('#timeline') });
      self.setupWebSocket(port);
      self.setupWebSocketOnMessage();
      self.setupAjaxForm();
      self.focusFirstForm();
      opts.counter && self.setupUnreadCounter();
      opts.audio   && self.setupAudio();
    });
  },

  init: function(args) {
    this.container = args.container;
  },

  setupUnreadCounter: function() {
    var self = this;
    $(window).keydown(function() { self.updateUnreadCounter(0) })
      .keydown();
    this.onMessage.push(function() { self.countupUnreadCounter() });
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
    var ws   = this.createWebSocket('ws://localhost:' + port);
    var self = this;
    ws.onmessage = function(e) {
      $.each(self.onMessage, function() { this(e) });
    };
  },

  setupWebSocketOnMessage: function() {
    var self = this;
    this.onMessage.push(function(e) { self.updateTitle(e.data) });
    this.onMessage.push(function(e) { self.prependToBody(e.data) });
  },

  createWebSocket: function(url) {
    if ("WebSocket" in window) {
      return new WebSocket(url);
    } else if ("MozWebSocket" in window) {
      return new MozWebSocket(url);
    }
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

  convertToLink: function(str) {
    return str.replace(
      /(https?:\/\/[\x21-\x7e]+)/gi, '<a href="$1" target="_blank">$1</a>');
  },

  prependToBody: function(str) {
    str = this.convertToLink(str);
    dom = $('<pre/>').append(str);
    this.container.prepend(dom);
  },

  updateTitle: function(str) {
    document.title = this.removeTags(str);
  },

  removeTags: function(str) {
    return str.replace(/<.*?>/g, '');
  },

  setupAudio: function() {
    var self = this;
    this.setupAudioQueue({ size: 3, path: "/sounds/on-message.mp3" });
    this.onMessage.push(function() {
      self.rotateAudioQueue(function(audio) { audio.play() });
    });
  },

  setupAudioQueue: function(args) {
    this.audioQueue = [];
    for (var i = 0; i < args.size; i++) {
      this.audioQueue.push(new Audio(args.path));
    }
  },

  rotateAudioQueue: function(callback) {
    var audio = this.audioQueue.shift();
    callback(audio);
    this.audioQueue.push(audio);
  }
};
