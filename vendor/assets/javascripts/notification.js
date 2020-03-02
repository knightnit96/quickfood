document.addEventListener("DOMContentLoaded", notification_flash);

var sweetalert2 = function (type, title) {
  Swal.fire({
    type: type,
    title: title,
    showConfirmButton: false,
    timer: 5000,
  });
}
var sweetalert_error = function (text) {
  Swal.fire({
    type: 'error',
    title: 'Lỗi!',
    text: text,
    showConfirmButton: false
  });
}
var sweetalert_new_order = function (text, order_id, status) {
  Swal.fire({
    title: "Đơn hàng mới! Xác nhận?",
    animation: false,
    customClass: {
      popup: 'animated tada'
    },
    text: text,
    type: 'warning',
    showCancelButton: true,
    allowOutsideClick: false,
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      $.ajax({
        url: '/places/update_order',
        type: 'put',
        cache: false,
        data: { order_id: order_id, status: status},
        success: function() {
        }
      });
    } else {
      $.ajax({
        url: '/places/update_status_order_cancel',
        type: 'post',
        cache: false,
        data: { id: order_id, status: 5},
        success: function(data) {
        }
      });
    }
  });
}
var sweetalert_find_shipper = function (text, order_id, status) {
  Swal.fire({
    title: "Đơn hàng mới! Xác nhận?",
    animation: false,
    customClass: {
      popup: 'animated tada'
    },
    text: text,
    type: 'warning',
    showCancelButton: true,
    allowOutsideClick: false,
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      $.ajax({
        url: '/places/find_shipper',
        type: 'put',
        cache: false,
        data: { order_id: order_id, status: status},
        success: function(data) {
          if (data.had_recipient == true) {
            sweetalert_error('Đã có người nhận!');
          } else {
            window.location.reload();
          }
        }
      });
    }
  });
}
var sweetalert_cancel_order = function (text, reset) {
  Swal.fire({
    title: "Hủy đơn hàng!",
    animation: false,
    customClass: {
      popup: 'animated tada'
    },
    text: text,
    type: 'warning',
    allowOutsideClick: false
  }).then((result) => {
    if (reset == true) {
      window.location.reload();
    }
  });
}
var sweetalert_select_proposal = function (title, place_id, value) {
  Swal.fire({
    title: title,
    type: 'warning',
    showCancelButton: true,
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      $.ajax({
        url: '/admin/places/confirm_proposal',
        type: 'post',
        cache: false,
        data: { id: place_id, value: value},
        success: function() {
          window.location.reload();
        }
      });
    }
  });
}
var sweetalert_select_confirm_order = function (title, order_id, value) {
  Swal.fire({
    title: title,
    type: 'warning',
    showCancelButton: true,
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      if (value == 1) {
        $.ajax({
          url: '/places/update_order',
          type: 'put',
          cache: false,
          data: { order_id: order_id, status: value},
          success: function() {
            $('.td_confirm_order').text('');
            $('.td_confirm_order').append('<span class="icon-ok" style="font-size: 25px"></span>');
          }
        });
      } else {
        $.ajax({
          url: '/places/update_status_order_cancel',
          type: 'post',
          cache: false,
          data: { id: order_id, status: value},
          success: function() {
            $('.td_confirm_order').text('');
            $('.td_confirm_order').append('<span class="icon-cancel" style="font-size: 25px"></span>');
          }
        });
      }
    }
  });
}
function notification_flash() {
  var message = $('.notification_flash').attr('data-message');
  var message_type = $('.notification_flash').attr('data-message-type');
  if (message_type == 'notice') {
    sweetalert2('success', message);
  } else if (message_type == 'alert') {
    sweetalert2('warning', message);
  } else if (message_type == 'error') {
    sweetalert_error(message);
  } else if (message_type == 'danger') {
    sweetalert2('warning', message);
  } else if (message_type != null) {
    sweetalert2(message_type, message);
  }
}
(function() {
  var handleConfirm = function(element) {
    if (!allowAction(this)) {
      Rails.stopEverything(element)
    }
  }
  var allowAction = function(element) {
    if (element.getAttribute('data-confirm') === null) {
      return true
    }
    showConfirmationDialog(element)
    return false
  }
  var showConfirmationDialog = function(element) {
    var message = element.getAttribute('data-confirm')
    Swal.fire({
      title: message,
      type: 'warning',
      showCancelButton: true,
      cancelButtonColor: '#d33',
      cancelButtonText: 'Hủy bỏ',
    }).then(function(confirm) {
      confirmed(element, confirm);
    });
  }
  var confirmed = function(element, result) {
    if (result.value) {
      element.removeAttribute('data-confirm');
      element.click();
    }
  }
  document.addEventListener('rails:attachBindings', function() {
    Rails.delegate(document, 'a[data-confirm]', 'click', handleConfirm)
    Rails.delegate(document, 'button[data-confirm]', 'click', handleConfirm)
  })
}).call(this)
