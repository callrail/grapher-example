function refetchPage() {
  var tag = $("#tag_id").val();
  var range = $("#date_range").val();
  location.href = "/charts?tag=" + tag + "&date_range=" + range;
}
