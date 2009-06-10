$(function() {
  var issuesURL = "http://github.com/api/v2/json/issues/list/schacon/hg-git/open",
      issues = 0

  $.getJSON(issuesURL + '?callback=?', function(data) {
    if (data.issues)
      $('#issues-link').html('issues <sup>(' + data.issues.length + ')</sup>')
  })
})