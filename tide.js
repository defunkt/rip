(function($) {
  function fetchIssues() {
    var issuesURL = "http://github.com/api/v2/json/issues/list/schacon/hg-git/open",
        issues = 0

    $.getJSON(issuesURL + '?callback=?', function(data) {
      if (data.issues)
        $('#issues-link').html('issues <sup>(' + data.issues.length + ')</sup>')
    });
  }

  function spanifyHeaders() {
    $('h1').css({ borderBottom: 'none' }).append($('<span></span>'));
  }

  function scrollToTop() {
    $('html,body').animate({scrollTop: 0}, 80)
    return false
  }

  $(function() {
    fetchIssues();
    spanifyHeaders();
    $('#top').click(scrollToTop)
  })
})(jQuery);
