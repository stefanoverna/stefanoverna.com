window.disqus_shortname = 'stefanoverna';
window._gaq = [['_setAccount', 'UA-5105763-1'], ['_trackPageview']];

function asyncLoad(src) {
  var s = document.createElement('script');
    s.type = 'text/javascript';
    s.async = true;
    s.src = src;
    var x = document.getElementsByTagName('script')[0];
    x.parentNode.insertBefore(s, x);
}

var scripts = [
  'http://platform.twitter.com/widgets.js', 
  'http://stefanoverna.disqus.com/embed.js', 
  'http://stefanoverna.disqus.com/count.js', 
  'http://www.google-analytics.com/ga.js'
];

for (var i = 0; i < scripts.length; i++) {
  asyncLoad(scripts[i]);
}

