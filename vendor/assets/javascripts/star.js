$(function () {
  var rating = $('.rateyo-readonly').attr('data');
  if (rating == '') rating = 0

  $('.rateyo-readonly').rateYo({
    rating: rating,
    readOnly: true
  });

  $('.rateyo').rateYo({
    rating: 0,
    fullStar: true
  });
});

function loadReviews() {
  $('.review_item').slice(0, 5).show();
  if ($('.review_item:hidden').length == 0) {
    $('#loadMore').fadeOut('slow');
  }
  $('#loadMore').on('click', function (e) {
    e.preventDefault();
    $('.review_item:hidden').slice(0, 5).slideDown();
    if ($('.review_item:hidden').length == 0) {
      $('#loadMore').fadeOut('slow');
    }
    $('html,body').animate({
      scrollTop: $(this).offset().top
    }, 1500);
  });
}

$(document).ready(function () {
  loadReviews();
});
