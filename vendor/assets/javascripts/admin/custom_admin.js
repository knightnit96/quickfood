$('.checkbox_active_user').on('change', function () {
  var id = $(this).attr('data-id');
  var value = $(this).val();
  if (value == "1") {
    $.ajax({
      url: '/admin/users/change_lock_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function () {
        $('#on_off_user_'+id).val(0);
      }
    });
  } else {
    $.ajax({
      url: '/admin/users/change_lock_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function () {
        $('#on_off_user_'+id).val(1);
      }
    });
  }
});
$('.checkbox_active_shipper').on('change', function () {
  var id = $(this).attr('data-id');
  var value = $(this).val();
  if (value == "1") {
    $.ajax({
      url: '/admin/shippers/change_lock_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function () {
        $('#on_off_shipper_'+id).val(0);
      }
    });
  } else {
    $.ajax({
      url: '/admin/shippers/change_lock_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function () {
        $('#on_off_shipper_'+id).val(1);
      }
    });
  }
});
$('.checkbox_active_place').on('change', function () {
  var id = $(this).attr('data-id');
  var value = $(this).val();
  if (value == "1") {
    $.ajax({
      url: '/admin/places/change_lock_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function () {
        $('#on_off_place_'+id).val(0);
      }
    });
  } else {
    $.ajax({
      url: '/admin/places/change_lock_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function () {
        $('#on_off_place_'+id).val(1);
      }
    });
  }
});
$('.select_is_proposal').on('click', function () {
  var title = $(this).attr('data-title');
  var id = $(this).attr('data-id');
  var value = $(this).attr('data-value');
  sweetalert_select_proposal(title, id, value);
});
$('.input_address_change').on('change', function () {
  var geocoder = new google.maps.Geocoder();
  var address = $('.input_address_change').val();
  geocoder.geocode( {'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      var address_lat = results[0].geometry.location.lat();
      var address_lng = results[0].geometry.location.lng();
      $('#latitude').val(address_lat);
      $('#longitude').val(address_lng);
    }
  });
});
$('.selectpicker').change(function () {
  var icon = $('.selectpicker').val();
  $('#icon_classify_category').val(icon);
});
