document.addEventListener("DOMContentLoaded", initMap4);

function initMap4() {
  var lat = $('#map').attr('data-latitude');
  var lng = $('#map').attr('data-longitude');;
  var myCoords = new google.maps.LatLng(lat, lng);
  var mapOptions = {
  center: myCoords,
  zoom: 16
  };
  map = new google.maps.Map(document.getElementById('map'), mapOptions);
  marker = new google.maps.Marker({
    position: myCoords,
    animation: google.maps.Animation.DROP,
    map: map,
  });
}
//Add cart
var old_value;
$('.input_food_option_radio').on('change', function () {
  var food_item_id = $(this).attr('data-food-item');
  $("#add_cart_item_"+food_item_id).attr('data-option-radio', $(this).val());
  if ($(this).val() == 0) {
    $("#add_cart_item_"+food_item_id).attr('data-option-radio', '');
  }
});
$('.input_food_option_checkbox').on('change', function () {
  var list_food_option_checkbox_ids = [];
  var food_item_id = $(this).attr('data-food-item');
  $('input[name="options_checkbox_'+food_item_id+'"]:checked').each(function() {
    list_food_option_checkbox_ids.push(this.value);
  });
  $("#add_cart_item_"+food_item_id).attr('data-option-checkbox', list_food_option_checkbox_ids);
});
$('.add_item_to_cart').on('click', function () {
  var id = $(this).attr('data-id');
  var food_id = $(this).attr('data-item');
  var food_option_radio_id = $(this).attr('data-option-radio');
  var food_option_checkbox_id = $(this).attr('data-option-checkbox');
  var food_option;
  if (food_option_radio_id != "" && food_option_checkbox_id != "") {
    food_option = food_option_radio_id + ',' + food_option_checkbox_id;
  } else if (food_option_radio_id == "") {
    food_option = food_option_checkbox_id;
  } else if (food_option_checkbox_id == "") {
    food_option = food_option_radio_id;
  }
  $.ajax({
    url: '/places/add_to_cart',
    type: 'POST',
    cache: false,
    data: {
      id: id,
      food_id: food_id,
      food_option: food_option
    },
    success: function (data) {
      $('#price_subtotal').html(data.subtotal);
      if (data.food_exist == 1) {
        $('#quantity_food_'+data.key_food.split(',').join('')).val(data.quantity);
        $('#price_food_'+data.key_food.split(',').join('')).html(data.price);
        for (const key in data.food_option) {
          if (data.food_option.hasOwnProperty(key)) {
            const element = data.food_option[key];
            $('#price_food_'+data.key_food.split(',').join('')+'_'+element.split('-')[0]).html(element.split('-')[1]);
          }
        }
      } else {
        var html = [
          '<tr>',
            '<td>',
              '<input type="number" min="0" max="99" value="1" class="text-center change_quantity" data-id="'+data.id+'" data-key="'+data.key_food+'" id="quantity_food_'+data.key_food.split(',').join('')+'"> '+data.food.name,
            '</td>',
            '<td>',
              '<strong class="pull-right" id="price_food_'+data.key_food.split(',').join('')+'">'+data.price+'</strong>',
            '</td>',
          '</tr>',
        ];
        $('#cart').append(html.join(''));
        for (const key in data.food_option) {
          if (data.food_option.hasOwnProperty(key)) {
            const element = data.food_option[key];
            var html_option = [
              '<tr>',
                '<td>',
                  '<i class="icon_plus_alt"></i> '+key,
                '</td>',
                '<td>',
                  '<strong class="pull-right" id="price_food_'+data.key_food.split(',').join('')+'_'+element.split('-')[0]+'">'+element.split('-')[1]+'</strong>',
                '</td>',
              '</tr>',
            ];
            $('#cart').append(html_option.join(''));
          }
        }
      }
      $('.change_quantity').on('focus', function () {
        old_value = $(this).val();
      }).change(function () {
        var value = $(this).val();
        var obj = $(this);
        if (value > 99 || value < 0 || value == "") {
          $(this).val(old_value);
        } else {
          var key = $(this).attr('data-key');
          $.ajax({
            url: '/places/update_cart',
            type: 'PUT',
            cache: false,
            data: {
              id: id,
              key: key,
              quantity: value
            },
            success: function (data) {
              $('#price_subtotal').html(data.new_subtotal);
              if (value == 0) {
                obj.closest("tr").remove();
                key.split(',').forEach(function(element){
                  $('#price_food_'+key.split(',').join('')+'_'+element).closest("tr").remove();
                });
              } else {
                $('#price_food_'+key.split(',').join('')).html(data.new_price);
                for (const key_id in data.new_food_option) {
                  if (data.new_food_option.hasOwnProperty(key_id)) {
                    const element = data.new_food_option[key_id];
                    $('#price_food_'+key.split(',').join('')+'_'+key_id).html(element);
                  }
                }
              }
            }
          });
        }
      });
    }
  });
});
$('.change_quantity').on('focus', function () {
  old_value = $(this).val();
}).change(function () {
  var value = $(this).val();
  var obj = $(this);
  if (value > 99 || value < 0 || value == "") {
    $(this).val(old_value);
  } else {
    var key = $(this).attr('data-key');
    var id = $(this).attr('data-id');
    $.ajax({
      url: '/places/update_cart',
      type: 'PUT',
      cache: false,
      data: {
        id: id,
        key: key,
        quantity: value
      },
      success: function (data) {
        $('#price_subtotal').html(data.new_subtotal);
        if (value == 0) {
          obj.closest("tr").remove();
          key.split(',').forEach(function(element){
            $('#price_food_'+key.split(',').join('')+'_'+element).closest("tr").remove();
          });
        } else {
          $('#price_food_'+key.split(',').join('')).html(data.new_price);
          for (const key_id in data.new_food_option) {
            if (data.new_food_option.hasOwnProperty(key_id)) {
              const element = data.new_food_option[key_id];
              $('#price_food_'+key.split(',').join('')+'_'+key_id).html(element);
            }
          }
        }
      }
    });
  }
});
//Create order
$('#button_create_order').on('click', function () {
  var address = $('#order_address').val();
  var payment = $('input[name="payment_method"]:checked').val();
  var fee = $('.delivery_fee_cal').text();
  fee = fee.toString().replace('.', '');
  var total_price = $('.total_delivery_fee_cal').text();
  total_price = total_price.toString().replace('.', '');
  total_price = parseInt(total_price)*0.0043
  var href = $(this).attr('href');
  var new_href = href + '?total_price=' + total_price + '&payment=' + payment + '&address=' + address + '&fee=' + fee
  $(this).attr('href', new_href);
});
window.onload = function(){
  array_link = window.location.pathname.split('/');
  if (array_link[array_link.length - 1] == "show_order") {
    var distance = getCookie("distance");
    if (distance < 5) {
      $('.delivery_fee_cal').text('0');
      var total_old = $('.total_delivery_fee_cal').text();
      total_old = parseInt(total_old);
      $('.total_delivery_fee_cal').text(separate(total_old));
    } else {
      distance = Math.ceil(distance)*3000;
      $('.delivery_fee_cal').text(separate(distance));
      var total_old = $('.total_delivery_fee_cal').text();
      total_old = parseInt(total_old);
      total_new = total_old + distance;
      $('.total_delivery_fee_cal').text(separate(total_new));
    }
  }
};
$('#order_address').on('change', function () {
  var place_latitude = $(this).attr('data-latitude');
  var place_longitude = $(this).attr('data-longitude');
  var user_latitude = $('#order_address option:selected').attr('data-latitude');
  var user_longitude = $('#order_address option:selected').attr('data-longitude');
  var myCoords_place = new google.maps.LatLng(place_latitude, place_longitude);
  var myCoords_user = new google.maps.LatLng(user_latitude, user_longitude);
  var distance = google.maps.geometry.spherical.computeDistanceBetween(myCoords_place, myCoords_user);
  distance = parseInt(distance) * 0.001;
  if (distance < 5) {
    var fee_old = $('.delivery_fee_cal').text();
    $('.delivery_fee_cal').text('0');
    var total_old = $('.total_delivery_fee_cal').text();
    total_old = total_old.toString().replace('.', '');
    total_old = parseInt(total_old);
    if (fee_old == '0') {
      $('.total_delivery_fee_cal').text(separate(total_old));
    } else {
      fee_old = fee_old.toString().replace('.', '');
      fee_old = parseInt(fee_old);
      total_old = total_old - fee_old;
      $('.total_delivery_fee_cal').text(separate(total_old));
    }
  } else {
    distance = Math.ceil(distance)*3000;
    $('.delivery_fee_cal').text(separate(distance));
    var total_old = $('.total_delivery_fee_cal').text();
    total_old = total_old.toString().replace('.', '');
    total_old = parseInt(total_old);
    total_new = total_old + distance;
    $('.total_delivery_fee_cal').text(separate(total_new));
  }
});
function getCookie(name) {
  var value = "; " + document.cookie;
  var parts = value.split("; " + name + "=");
  if (parts.length == 2) return parts.pop().split(";").shift();
};
function separate(number) {
  return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}
var url = new URL(window.location.href);
if (url.searchParams.get("token")) {
  var payment = url.searchParams.get("payment");
  var address = url.searchParams.get("address");
  var fee = url.searchParams.get("fee");
  var place_id = url.searchParams.get("place_id");
  var token = url.searchParams.get("token");
  var payer_id = url.searchParams.get("PayerID");
  $.ajax({
    url: '/places/'+place_id+'/create_order',
    type: 'post',
    cache: false,
    data: {
      payment: payment,
      address: address,
      fee: fee,
      id: place_id,
      token: token,
      payer_id: payer_id,
    },
    success: function() {
      window.location.replace("http://localhost:3000");
    }
  });
}
