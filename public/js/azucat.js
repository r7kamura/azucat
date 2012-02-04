/*
* example:
*   <script type="text/javascript" src="/js/jquery.min.js"></script>
*   <script type="text/javascript" src="/js/azucat.js"></script>
*   <script type="text/javascript"> Azucat.start(3000); </script>
* */
var Azucat = {
  start: function(port) {
    var self = this;
    $(function() {
      var ws = new WebSocket('ws://localhost:' + port);
      ws.onmessage = function(e) {
        var isScrolledToBottom = self._isScrolledToBottom();

        self._updateTitle(e.data);
        self._appendToBody(e.data);

        if (isScrolledToBottom) { self._scrollToBottom() }
      };
    });
  },

  _addLink: function(str) {
    return str.replace(/(http:\/\/[\x21-\x7e]+)/gi, '<a href="$1">$1</a>');
  },

  _appendToBody: function(str) {
    str = this._addLink(str);
    str = '<pre>' + str + '</pre>';
    $(document.body).append(str);
  },

  _updateTitle: function(str) {
    document.title = this._removeTags(str);
  },

  _removeTags: function(str) {
    return str.replace(/<.*?>/g, '');
  },

  _isScrolledToBottom: function() {
    var base = (document.compatMode !== 'BackCompat') ?
      document.documentElement : document.body;
    return !(
      base.scrollHeight -
      base.clientHeight -
      (window.pageYOffset || base.scrollTop)
    );
  },

  _scrollToBottom: function() {
    window.scrollTo(0, document.body.scrollHeight);
  }
};
