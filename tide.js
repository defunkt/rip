(function($) {
  var apiURL = "http://github.com/api/v2/json/"

  function fetchIssues() {
    var issuesURL = apiURL + "issues/list/schacon/hg-git/open",
           issues = 0

    $.getJSON(issuesURL + '?callback=?', function(data) {
      if (data.issues)
        $('#issues-link').html('issues <sup>(' + data.issues.length + ')</sup>')
    })
  }

  function scrollToTop() {
    $('html,body').animate({scrollTop: 0}, 0)
    return false
  }

  function spanifyHeaders() {
    $('h1').css({ borderBottom: 'none' }).append($('<span></span>'))
  }

  function buildChangelog() {
    if ($('.changelog').length == 0) return

    var commitsURL = apiURL + "commits/list/schacon/hg-git/master"

    $.getJSON(commitsURL + '?callback=?', function(data) {
      var ul = $('<ul id="commits"></ul>')

      $.each(data.commits, function() {
        if (/^Merge/.test(this.message)) return
        ul.append('<li><a href="' + this.url + '">' + this.message + '</a></li>')
      })

      $('h1').after(ul)
      $('#main img').remove()
    })
  }

  function slideNavLink(size) {
    return function(event) {
      var elem = $(event.target);
      if (elem.parents().hasClass(elem.text())) { return; }
      elem.animate({ paddingRight: size + 'px' }, 100);
    }
  }

  $(function() {
    fetchIssues()
    spanifyHeaders()
    buildChangelog()
    $('#top').click(scrollToTop)
    $('#sidebar a').mouseenter(slideNavLink(paddingRight=20));
    $('#sidebar a').mouseleave(slideNavLink(paddingRight=5));
  })
})(jQuery)
