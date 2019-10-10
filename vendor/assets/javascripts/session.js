$('.ajax-signin-btn').on('click', function () {
  var email = $("#user_email").val();
  var password = $("#user_password").val();
  var remember_me = ($("#user_remember_me:checked").length != 0) ? 1 : 0
  $.ajax({
    url: '/users/sign_in.json',
    type: 'post',
    contentType: "application/json",
    dataType: "json",
    data: JSON.stringify({
      "user": {"email": email, "password": password, "remember_me": remember_me, "locale": I18n.locale}
    }),
    success: function (data) {
      if (data.success) {
        if (data.admin) {
          window.location.replace("http://localhost:3000/admin")
        } else {
          window.location.reload();
        }
      } else {
        $('.error').addClass('alert alert-danger').html(data.errors)
      }
    }
  });
});
$('.ajax-signup-btn').on('click', function () {
  var check_condition = $("#check_condition:checked").length
  if (check_condition != 0) {
    var geocoder = new google.maps.Geocoder();
    var name = $("#register_user_name").val();
    var email = $("#register_user_email").val();
    var password = $("#register_user_password").val();
    var password_confirmation = $("#register_user_password_confirmation").val();
    var gender = $("#register_user_gender").val();
    var address = $("#register_user_address").val();
    var phone = $("#register_user_phone").val();
    var address_lat, address_lng;
    geocoder.geocode( {'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        address_lat = results[0].geometry.location.lat();
        address_lng = results[0].geometry.location.lng();
      }
    });
    setTimeout(function() {
      $.ajax({
        url: '/profiles/create_user',
        type: 'post',
        cache: false,
        data: {
          name: name,
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          gender: gender,
          address: address,
          phone: phone,
          latitude: address_lat,
          longitude: address_lng
        },
        success: function(data) {
          if (data.status == 'error') {
            $('.error_register').addClass('alert alert-danger');
            $('.error_register').css('text-align', 'left');
            var errors = data.errors.split(',');
            var html = '';
            errors.forEach(function(error, index) {
              if (index == 0) {
                html += '&emsp;'+error+'<br>';
              } else {
                html += error+'!<br>';
              }
            });
            $('.error_register').html(html);
          } else {
            $.ajax({
              url: '/users/sign_in.json',
              type: 'post',
              contentType: "application/json",
              dataType: "json",
              data: JSON.stringify({
                "user": {"email": email, "password": password, "remember_me": 0, "locale": I18n.locale}
              }),
              success: function (data) {
                if (data.success) {
                  window.location.reload();
                } else {
                  $('.error').addClass('alert alert-danger').html(data.errors)
                }
              }
            });
          }
        }
      });
    }, 500);
  } else {
    $(".error_register").addClass('alert alert-danger');
    $(".error_register").text('Bạn phải đồng ý với các điều khoản và điều kiện!');
  }
});
$('.ajax-confirm-btn').on('click', function () {
  var code = $("#confirm_code").val();
  $.ajax({
    url: '/profiles/confirm_unlock',
    type: 'post',
    cache: false,
      data: {
        code: code,
      },
    success: function (data) {
      if (data.status == 'success') {
        window.location.reload();
      } else {
        $('.error_confirm').addClass('alert alert-danger').html(data.error)
      }
    }
  });
});
