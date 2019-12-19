jQuery('#sidebar').theiaStickySidebar({
  additionalMarginTop: 80
});
$('#faq_box a[href^="#"]').on('click', function (e) {
  e.preventDefault();
  var target = this.hash;
  var $target = $(target);
  $('html, body').stop().animate({
    'scrollTop': $target.offset().top - 120
  }, 900, 'swing', function () {
    window.location.hash = target;
  });
});
