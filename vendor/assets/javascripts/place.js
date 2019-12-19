var map, marker;
list_classify_category_ids = [];
if ($("#list_classify_category").val() != "") {
  list_classify_category_ids = $("#list_classify_category").val().split(',');
  list_classify_category_ids.forEach(function(cc) {
    $('.select-box-classify-category').find('option[value="'+cc+'"]').attr('disabled', 'disabled');
  });
}
$('.select-box-classify-category').on('change', function () {
  var id = $(this).attr('data-id');
  var value_id = $(this).val();
  var value_name = $(this).find('option:selected').text();
  $(this).find('option[value="'+value_id+'"]').attr('disabled', 'disabled');
  $(this).val(null);
  $('#tags_classify_category_'+id).append('<a href=\"javascript:void(0)\" class=\"nomargin tag-classify-category\" id=\"tag-classify-category-'+value_id+'\" data-id=\"'+id+'\" data-value-id=\"'+value_id+'\"><i class=\"icon-cancel-circled-1\"></i>'+value_name+'</a>\n');
  list_classify_category_ids.push(value_id);
  $("#list_classify_category").val(list_classify_category_ids);
});
jQuery('body').on('click', '.tag-classify-category', function () {
  var tag_id = $(this).attr('data-id');
  var tag_value_id = $(this).attr('data-value-id');
  $('#tag-classify-category-'+tag_value_id).remove();
  $('#classify_category_'+tag_id).find('option[value="'+tag_value_id+'"]').removeAttr('disabled');
  var index = list_classify_category_ids.indexOf(tag_value_id);
  list_classify_category_ids.splice(index, 1);
  $("#list_classify_category").val(list_classify_category_ids);
});
$('#province-parent').on('change', function () {
  var geocoder = new google.maps.Geocoder();
  var address = $('#province-parent').find('option:selected').text();
  geocoder.geocode( {'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      var province_lat = results[0].geometry.location.lat();
      var province_lng = results[0].geometry.location.lng();
      var province_myCoords = new google.maps.LatLng(province_lat, province_lng);
      marker.setPosition(province_myCoords);
      map.setCenter(marker.getPosition());
      $('#latitude').val(province_lat);
      $('#longitude').val(province_lng);
    }
  });

  var province_parent_id = $('#province-parent').val();
  $.ajax({
    url: '/places/show_province_child',
    type: 'get',
    cache: false,
    data: {
      province_parent_id: province_parent_id
    },
    success: function (data) {
      for (var i = 0; i < data.province_child.length; i++) {
        $('#place_province_id').append('<option value=\"'+data.province_child[i].id+'\">'+data.province_child[i].name+'</option>');
      }
    }
  });
});

// Google maps
document.addEventListener("DOMContentLoaded", initMap2);

function initMap2() {
  var lat = 16.0749477;
  var lng = 108.22590129999999;
  if ($('#latitude').val() == "" && $('#longitude').val() == "") {
    $('#latitude').val(lat);
    $('#longitude').val(lng);
  } else {
    lat = $('#latitude').val();
    lng = $('#longitude').val();
  }
  var myCoords = new google.maps.LatLng(lat, lng);
  //Map option
  var mapOptions = {
  center: myCoords,
  zoom: 16
  };
  map = new google.maps.Map(document.getElementById('map2'), mapOptions);
  marker = new google.maps.Marker({
    position: myCoords,
    animation: google.maps.Animation.DROP,
    map: map,
    draggable: true
  });
  // refresh marker position and recenter map on marker
  function refreshMarker(){
    var lat = $('#latitude').val();
    var lng = $('#longitude').val();
    var myCoords = new google.maps.LatLng(lat, lng);
    marker.setPosition(myCoords);
    map.setCenter(marker.getPosition());
  }
  // when marker is dragged update input values
  marker.addListener('drag', function() {
    latlng = marker.getPosition();
    newlat=(Math.round(latlng.lat()*1000000))/1000000;
    newlng=(Math.round(latlng.lng()*1000000))/1000000;
    $('#latitude').val(newlat);
    $('#longitude').val(newlng);
  });
  // When drag ends, center (pan) the map on the marker position
  marker.addListener('dragend', function() {
    map.panTo(marker.getPosition());
  });
  //Search box in Google map
  var searchBox = new google.maps.places.SearchBox(document.getElementById('pac-input'));
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(document.getElementById('pac-input'));
  google.maps.event.addListener(searchBox, 'places_changed', function() {
    searchBox.set('map', map);
    var places = searchBox.getPlaces();
    var myCoords = places[0].geometry.location;
    marker.setPosition(myCoords);
    map.setCenter(marker.getPosition());
    $('#latitude').val(places[0].geometry.location.lat());
    $('#longitude').val(places[0].geometry.location.lng());
  });
}
