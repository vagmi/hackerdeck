 Reveal.initialize({
   controls: true,
   progress: true,
   history: true,
   center: true,
   transition: 'default',
   dependencies: [
     { src: '/js/lib/js/classList.js', condition: function() { return !document.body.classList; } },
     { src: '/plugin/markdown/showdown.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
     { src: '/plugin/markdown/markdown.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
     { src: '/plugin/highlight/highlight.js', async: true, callback: function() { hljs.initHighlightingOnLoad(); } },
     { src: '/plugin/zoom-js/zoom.js', async: true, condition: function() { return !!document.body.classList; } },
     { src: '/plugin/notes/notes.js', async: true, condition: function() { return !!document.body.classList; } }
   ]
 });
