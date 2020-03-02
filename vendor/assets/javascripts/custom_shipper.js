window.onload = function(){
  var list_order = $('#list_orders_shipper').attr('data-list');
  if (list_order != null) {
    var list_order_id = list_order.split(",");
    list_order_id.forEach(function(order_id) {
      var place_latitude = $('#cal_distance_'+order_id).attr('data-place-latitude');
      var place_longitude = $('#cal_distance_'+order_id).attr('data-place-longitude');
      var user_latitude = $('#cal_distance_'+order_id).attr('data-address-latitude');
      var user_longitude = $('#cal_distance_'+order_id).attr('data-address-longitude');
      var myCoords_place = new google.maps.LatLng(place_latitude, place_longitude);
      var myCoords_user = new google.maps.LatLng(user_latitude, user_longitude);
      var distance = google.maps.geometry.spherical.computeDistanceBetween(myCoords_place, myCoords_user);
      distance = parseInt(distance) * 0.001;
      $('#cal_distance_'+order_id).text(distance+' km');
    });
  }
  var user_latitude = $('#select_address_user option:selected').attr('data-latitude');
  var user_longitude = $('#select_address_user option:selected').attr('data-longitude');
  var myCoords_user = new google.maps.LatLng(user_latitude, user_longitude);
  var list_place = $('#select_address_user').attr('data-list-place');
  if (list_place != null) {
    var list_place_id = list_place.split(",");
    var size = $('#remove_place_filter').attr('data-size');
    list_place_id.forEach(function(place_id) {
      var range_input = getUrlParameter('range');
      var from_range, to_range;
      if (range_input != null) {
        range_input = range_input.split(';');
        from_range = range_input[0];
        to_range = range_input[1];
      }
      var place_latitude = $('#cal_distance_place_'+place_id).attr('data-place-latitude');
      var place_longitude = $('#cal_distance_place_'+place_id).attr('data-place-longitude');
      var myCoords_place = new google.maps.LatLng(place_latitude, place_longitude);
      var distance = google.maps.geometry.spherical.computeDistanceBetween(myCoords_place, myCoords_user);
      distance = parseInt(distance) * 0.001;
      if (from_range != null && to_range != null) {
        if (distance < from_range || distance > to_range) {
          $('#remove_place_'+place_id).remove();
          size = size - 1;
          var province = $('#remove_place_filter').attr('data-province');
          $('#remove_place_filter').text(I18n.t('places.index.all_place', {size: size, province: province}));
        }
      }
      $('#cal_distance_place_'+place_id).text(distance);
    });
  }
};
$('#select_address_user').on('change', function () {
  var value = $('#select_address_user option:selected').val();
  setCookie('address', value, 365);
  function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }
  var user_latitude = $('#select_address_user option:selected').attr('data-latitude');
  var user_longitude = $('#select_address_user option:selected').attr('data-longitude');
  var myCoords_user = new google.maps.LatLng(user_latitude, user_longitude);
  var list_place = $('#select_address_user').attr('data-list-place');
  if (list_place != null) {
    var list_place_id = list_place.split(",");
    list_place_id.forEach(function(place_id) {
      var place_latitude = $('#cal_distance_place_'+place_id).attr('data-place-latitude');
      var place_longitude = $('#cal_distance_place_'+place_id).attr('data-place-longitude');
      var myCoords_place = new google.maps.LatLng(place_latitude, place_longitude);
      var distance = google.maps.geometry.spherical.computeDistanceBetween(myCoords_place, myCoords_user);
      distance = parseInt(distance) * 0.001;
      $('#cal_distance_place_'+place_id).text(distance);
    });
  }
});
var getUrlParameter = function getUrlParameter(sParam) {
  var sPageURL = window.location.search.substring(1),
      sURLVariables = sPageURL.split('&'),
      sParameterName,
      i;

  for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] === sParam) {
          return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
      }
  }
};
function submitFilter(name = null, value = null, type = null){
  var keyword = getUrlParameter('keyword');
  if (keyword != null) {
    var input = $("<input>")
               .attr("type", "hidden")
               .attr("name", "keyword").val(keyword);
    $('#click-submit-filter').append(input);
  }
  if (name != null) {
    if (name == 'checkbox-category') {
      var checkbox_district = getUrlParameter('checkbox-district');
      if (checkbox_district != null) {
        var input_checkbox_district = $("<input>")
                                    .attr("type", "hidden")
                                    .attr("name", "checkbox-district").val(checkbox_district);
        $('#click-submit-filter').append(input_checkbox_district);
      }
    }
    if (name == 'checkbox-district') {
      var checkbox_category = getUrlParameter('checkbox-category');
      if (checkbox_category != null) {
        var input_checkbox_category = $("<input>")
                                    .attr("type", "hidden")
                                    .attr("name", "checkbox-category").val(checkbox_category);
        $('#click-submit-filter').append(input_checkbox_category);
      }
    }
    var param_name = getUrlParameter(name);
    var input_checkbox;
    if (param_name != null) {
      if (type == "uncheck") {
        list_params_name = param_name.split(',')
        list_params_name.forEach(function(pname, index, object) {
          if (pname == value) {
            object.splice(index, 1);
          }
        });
        param_name = '';
        list_params_name.forEach(function(pname, index, object) {
          if (list_params_name.length == 1) {
            param_name = pname;
          } else {
            if (index == 0) {
              param_name = pname;
            } else {
              param_name = param_name + ',' + pname;
            }
          }
        });
        if (list_params_name.length != 0) {
          input_checkbox = $("<input>")
                        .attr("type", "hidden")
                        .attr("name", name).val(param_name);
        }
      } else {
        input_checkbox = $("<input>")
                        .attr("type", "hidden")
                        .attr("name", name).val(param_name+','+value);
      }
    } else {
      input_checkbox = $("<input>")
                        .attr("type", "hidden")
                        .attr("name", name).val(value);
    }
    $('#click-submit-filter').append(input_checkbox);
  } else {
    var checkbox_category = getUrlParameter('checkbox-category');
    if (checkbox_category != null) {
      var input_checkbox_category = $("<input>")
                                  .attr("type", "hidden")
                                  .attr("name", "checkbox-category").val(checkbox_category);
      $('#click-submit-filter').append(input_checkbox_category);
    }
    var checkbox_district = getUrlParameter('checkbox-district');
    if (checkbox_district != null) {
      var input_checkbox_district = $("<input>")
                                  .attr("type", "hidden")
                                  .attr("name", "checkbox-district").val(checkbox_district);
      $('#click-submit-filter').append(input_checkbox_district);
    }
  }
  $('#form_edit_avatar').submit();
}
$('input').on('ifChecked', function(){
  if ($(this).hasClass('checkbox-category') == true) {
    submitFilter('checkbox-category', $(this).val());
  } else if ($(this).hasClass('checkbox-district') == true) {
    submitFilter('checkbox-district', $(this).val());
  } else {
    submitFilter();
  }
});
$('input').on('ifUnchecked', function(){
  if ($(this).hasClass('checkbox-category') == true) {
    submitFilter('checkbox-category', $(this).val(), "uncheck");
  } else if ($(this).hasClass('checkbox-district') == true) {
    submitFilter('checkbox-district', $(this).val(), "uncheck");
  } else {
    submitFilter();
  }
});
$('#range').on('change', function(){
  submitFilter();
});
var range = getUrlParameter('range');
if (range != null) {
  range = range.split(';');
  from = range[0];
  to = range[1];
}
var rating = getUrlParameter('rating');
if (rating == '5') {
  document.getElementById('rating-5').checked = true;
}
if (rating == '4') {
  document.getElementById('rating-4').checked = true;
}
if (rating == '3') {
  document.getElementById('rating-3').checked = true;
}
if (rating == '2') {
  document.getElementById('rating-2').checked = true;
}
if (rating == '1') {
  document.getElementById('rating-1').checked = true;
}
var checkbox_category = getUrlParameter('checkbox-category');
if (checkbox_category != null) {
  var list_checkbox_category = checkbox_category.split(',');
  list_checkbox_category.forEach(function(cc) {
    $('#checkbox_category_'+cc).attr('checked', true);
  });
}
var checkbox_district = getUrlParameter('checkbox-district');
if (checkbox_district != null) {
  var list_checkbox_district = checkbox_district.split(',');
  list_checkbox_district.forEach(function(cd) {
    $('#checkbox_district_'+cd).attr('checked', true);
  });
}
$('.btn_click_distance').on('click', function () {
  var id = $(this).attr('data-id');
  var distance = $('#cal_distance_place_'+id).text();
  setcookie("distance", distance)
});
function setcookie(name, value) {
  var date = new Date();
  date.setTime(date.getTime()+365*24*60*60*1000); // ) removed
  var expires = "; expires=" + date.toGMTString(); // + added
  document.cookie = name+"=" + value+expires + ";path=/"; // + and " added
}
