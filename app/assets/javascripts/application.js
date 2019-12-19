// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require modernizr
//= require jquery-2.2.4.min
//= require cable
//= require sweetalert2/dist/sweetalert2.all.min
//= require notification
//= require rails-ujs
//= require html5shiv/dist/html5shiv.min
//= require respond.min.js/respond.min
//= require tabs
//= require common_scripts_min
//= require functions
//= require validate
//= require bootstrap-datepicker
//= require bootstrap-timepicker
//= require gmaps/google
//= require bootstrap3-wysihtml5.min
//= require dropzone.min
//= require cat_nav_mobile
//= require ion.rangeSlider
//= require jquery.rateyo
//= require star


//= require i18n
//= require i18n.js
//= require i18n/translations

function getCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(';');
  for(var i = 0; i <ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0)==' ') {
          c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
          return c.substring(name.length,c.length);
      }
  }
  return "";
}
setInterval(function(){
  var user = getCookie("user");
  var shipper = getCookie("shipper");
  if (shipper == 1) {
    if (navigator.geolocation) {
      console.log(navigator.geolocation);
      navigator.geolocation.getCurrentPosition(showPosition1);
    } else {
      sweetalert2('error', "Geolocation is not supported by this browser.");
    }
    function showPosition1(position) {
      var latitude_shipper = position.coords.latitude;
      var longitude_shipper = position.coords.longitude;
      console.log(latitude_shipper);

      $.ajax({
        url: '/shippers/update_location',
        type: 'POST',
        cache: false,
        data: {
          id: user,
          latitude : latitude_shipper,
          longitude : longitude_shipper
        },
        success: function (data) {
        }
      });
    }
  }
},5000);

$(window).on('load',function(){
  $('#confirm_unlock_code').modal('show');
});
