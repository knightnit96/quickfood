// Google maps
document.addEventListener("DOMContentLoaded", initMap5);

var map, marker_user, marker_place, marker_shipper;
function initMap5() {
  var lat = 16.0749477;
  var lng = 108.22590129999999;
  var myCoords = new google.maps.LatLng(lat, lng);
  var mapOptions = {
  center: myCoords,
  zoom: 16
  };
  map = new google.maps.Map(document.getElementById('map5'), mapOptions);
  marker_user = new google.maps.Marker({
    position: myCoords,
    animation: google.maps.Animation.DROP,
    map: map,
    icon: 'https://img.icons8.com/metro/30/000000/home.png'
  });
  marker_place = new google.maps.Marker({
    position: myCoords,
    animation: google.maps.Animation.DROP,
    map: map,
    icon: 'https://img.icons8.com/pastel-glyph/30/000000/shop.png'
  });
  marker_shipper = new google.maps.Marker({
    position: myCoords,
    animation: google.maps.Animation.DROP,
    map: map,
    icon: 'https://img.icons8.com/ios-filled/30/000000/motorcycle.png'
  });
}
$('.click_map').on('click', function () {
  var order_id = $(this).attr('data-id');
  var latitude_user = $(this).attr('data-latitude-user');
  var longitude_user = $(this).attr('data-longitude-user');
  var latitude_place = $(this).attr('data-latitude-place');
  var longitude_place = $(this).attr('data-longitude-place');
  var latitude_shipper = $(this).attr('data-latitude-shipper');
  var longitude_shipper = $(this).attr('data-longitude-shipper');
  var myCoords_user = new google.maps.LatLng(latitude_user, longitude_user);
  var myCoords_place = new google.maps.LatLng(latitude_place, longitude_place);
  var myCoords_shipper = new google.maps.LatLng(latitude_shipper, longitude_shipper);
  marker_user.setPosition(myCoords_user);
  marker_place.setPosition(myCoords_place);
  marker_shipper.setPosition(myCoords_shipper);
  map.setCenter(marker_user.getPosition());
  setInterval(function(){
    var latitude_shipper_new = $('#map_order_message_'+order_id).attr('data-latitude-shipper');
    var longitude_shipper_new = $('#map_order_message_'+order_id).attr('data-longitude-shipper');
    if (latitude_shipper == "") {
      latitude_shipper = 0
    }
    if (longitude_shipper == "") {
      longitude_shipper = 0
    }
    if (latitude_shipper_new == "") {
      latitude_shipper_new = 0
    }
    if (longitude_shipper_new == "") {
      longitude_shipper_new = 0
    }
    latitude_shipper_new = parseFloat(latitude_shipper_new);
    longitude_shipper_new = parseFloat(longitude_shipper_new);
    latitude_shipper = parseFloat(latitude_shipper);
    longitude_shipper = parseFloat(longitude_shipper);
    if (latitude_shipper != latitude_shipper_new || longitude_shipper != longitude_shipper_new) {
      transition(latitude_shipper_new, longitude_shipper_new);
      var i = 0;
      var deltaLat;
      var deltaLng;
      function transition(latitude_shipper_new, longitude_shipper_new){
        i = 0;
        deltaLat = (latitude_shipper_new - latitude_shipper)/100;
        deltaLng = (longitude_shipper_new - longitude_shipper)/100;
        moveMarker();
      }
      function moveMarker(){
        latitude_shipper += deltaLat;
        longitude_shipper += deltaLng;
        var myCoords_user_new = new google.maps.LatLng(latitude_user, longitude_user);
        marker_user.setPosition(myCoords_user_new);
        if(i!=100){
          i++;
          setTimeout(moveMarker, 20);
        }
      }
    }
  },5000);
});
