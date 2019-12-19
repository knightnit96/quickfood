$('.header').on('click', function() {
  var order_id = $(this).attr('data-id');
  $('#live_chat_'+order_id).slideToggle(300, 'swing');
  var cookie_chat = getCookie('chat_order_'+order_id);
  if (cookie_chat == 1) {
    $('#header_notify_'+order_id).removeClass('quadrat');
    document.cookie = "notify_chat_order_"+order_id+"=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
    setCookie('chat_order_'+order_id, 0, 365);
  } else {
    setCookie('chat_order_'+order_id, 1, 365);
  }
  function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }
  var objDiv1 = document.getElementById("history_live_chat_"+order_id);
  objDiv1.scrollTop = objDiv1.scrollHeight;
});
$('.click_cancel_order').on('click', function () {
  Swal.fire({
    title: 'Hủy bỏ đơn hàng. Bạn chắc chắn?',
    type: 'warning',
    showCancelButton: true,
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      var order_id = $(this).attr('data-id');
      $.ajax({
        url: '/places/update_status_order_cancel',
        type: 'post',
        cache: false,
        data: { id: order_id, status: 5},
        success: function(data) {
          if (data.status == '1') {
            Swal.fire({
              title: 'Đơn hàng #' + data.order_id + ' đã bị hủy!',
              type: 'warning',
              allowOutsideClick: false
            }).then((result) => {
              window.location.reload();
            });
          } else if (data.status == '0') {
            Swal.fire({
              title: 'Đơn hàng #' + data.order_id + ' không thể hủy!',
              type: 'warning',
              allowOutsideClick: false
            }).then((result) => {
              window.location.reload();
            });
          } else {
            Swal.fire({
              title: 'Đơn hàng #' + data.order_id + ' đã bị hủy!',
              type: 'warning',
              allowOutsideClick: false
            });
          }
        }
      });
    }
  });
});
$('.click_update_order').on('click', function () {
  var title = $('.click_update_order').attr('data-title');
  Swal.fire({
    title: title,
    type: 'warning',
    showCancelButton: true,
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      var id = $('.click_update_order').attr('data-id');
      var status = $('.click_update_order').attr('data-value');
      $.ajax({
        url: '/places/shipper_update_order',
        type: 'put',
        cache: false,
        data: { id: id, status: status},
        success: function() {
          if (status == '3') {
            $('.btn_confirm_shipper').text('');
            $('.btn_confirm_shipper').append('<button class="btn_1 click_update_order" data-id="'+id+'" data-value="4" data-title="Đơn hàng thành công! Xác nhận?">'+ I18n.t('shared.live_chat.delivered') +'</button>');
            $('.click_update_order').on('click', function () {
              var title = $('.click_update_order').attr('data-title');
              Swal.fire({
                title: title,
                type: 'warning',
                showCancelButton: true,
                cancelButtonText: 'Hủy bỏ',
              }).then((result) => {
                if (result.value) {
                  var id = $('.click_update_order').attr('data-id');
                  var status = $('.click_update_order').attr('data-value');
                  $.ajax({
                    url: '/places/shipper_update_order',
                    type: 'put',
                    cache: false,
                    data: { id: id, status: status},
                    success: function() {
                      window.location.reload();
                    }
                  });
                }
              });
            });
          } else {
            window.location.reload();
          }
        }
      });
    }
  });
});
$('.form_message').submit(function(e) {
  e.preventDefault();
  this.submit();
  $('#chat_content').val('');
});
var list_order = $('#list_order_js').attr('data-list');
if (list_order) {
  list_order.split(',').forEach(function(order) {
    if (order != list_order.split(',')[list_order.split(',').length -1]) {
      var objDiv = document.getElementById("history_live_chat_"+order);
      objDiv.scrollTop = objDiv.scrollHeight;
    }
  });
}
