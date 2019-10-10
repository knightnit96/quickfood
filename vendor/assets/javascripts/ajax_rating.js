$('#rate').on('click', function () {
  var fdata = new FormData();
  fdata.append('place_id', $('.rateyo').attr('pid'));
  fdata.append('rating', $('.rateyo').rateYo('option', 'rating'));
  fdata.append('content', $('#content').val());
  $.ajax({
    url: '/rates',
    type: 'POST',
    cache: false,
    processData: false,
    contentType: false,
    data: fdata,
    success: function (data) {
      $('#overall_review_a').text(I18n.t('places.show.reviews', { count: data.counter_reviews }));
      $('.rateyo-readonly').attr('data', data.overall);
      $('.rateyo-readonly').rateYo('option', 'rating', data.overall);
      $('#content').val('');
      var reviewDiv = $('.review_list');
      reviewDiv.text('');
      for (var i = 0; i < data.reviews.length; i++) {
        reviewDiv.append(data.reviews[i]);
      }
      $('#modal_add_review').modal('toggle');
      $('#not_have_review').remove();
      $('#has_review').text('');
      $('#has_review').append('<div id="loadMore"><a href="#">'+ I18n.t('places.show.load_more') +'</a></div>');
      $('#btn_review_now').remove();
      loadReviews();
    }
  });
});

jQuery('body').on('click', '.delete_review_btn', function () {
  Swal.fire({
    title: I18n.t('places.show.are_you_sure'),
    type: 'warning',
    showCancelButton: true,
    cancelButtonColor: '#d33',
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      var fdata = new FormData();
      fdata.append('place_id', $(this).attr('pid'));
      fdata.append('review_id', $(this).attr('data_id'));
      $.ajax({
        url: '/rates/' + $(this).attr('data_id'),
        type: 'DELETE',
        cache: false,
        processData: false,
        contentType: false,
        data: fdata,
        success: function (data) {
          $('#overall_review_a').text(I18n.t('places.show.reviews', { count: data.counter_reviews }));
          $('.rateyo-readonly').attr('data', data.overall);
          $('.rateyo-readonly').rateYo('option', 'rating', data.overall);
          $('#content').val('');
          var reviewDiv = $('.review_list');
          reviewDiv.text('');
          for (var i = 0; i < data.reviews.length; i++) {
            reviewDiv.append(data.reviews[i]);
          }
          $('#has_review').text('');
          if (data.counter_reviews == 0) {
            $('#has_review').append('<div id="not_have_review">'+ I18n.t('places.show.not_have_review') +'</div>');
          } else {
            $('#has_review').append('<div id="loadMore"><a href="#">'+ I18n.t('places.show.load_more') +'</a></div>');
          }
          loadReviews();
        }
      });
    }
  })
});
