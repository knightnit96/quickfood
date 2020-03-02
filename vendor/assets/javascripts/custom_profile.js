$(document).ready(function(){
  if (localStorage.getItem("message-success")) {
    sweetalert2('success', localStorage.getItem("message-success"));
    localStorage.clear();
  } else if (localStorage.getItem("message-error")) {
    sweetalert_error(localStorage.getItem("message-error"));
    localStorage.clear();
  }
});
var map, marker;
var currentFile = null;
new CBPFWTabs(document.getElementById('tabs'));
$('.wysihtml5').wysihtml5({});
if ($('.dropzone').length > 0) {
  Dropzone.autoDiscover = false;
  $('#photos').dropzone({
    url: 'upload',
    addRemoveLinks: true
  });
  $('#logo_picture').dropzone({
    url: 'upload',
    maxFiles: 1,
    addRemoveLinks: true
  });
  $('.menu-item-pic').dropzone({
    url: 'profiles/create_menu_item',
    maxFiles: 1,
    addRemoveLinks: true,
    autoProcessQueue: false,
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    init: function () {
      var myDropzone = this;
      $("#submit_add_menu_item").click(function (e) {
        e.preventDefault();
        myDropzone.processQueue();
      });
      this.on('sending', function(file, xhr, formData) {
        // Append all form inputs to the formData Dropzone will POST
        var data = $('#form_add_menu_item').serializeArray();
        $.each(data, function(key, el) {
          formData.append(el.name, el.value);
        });
      });
      this.on('success', function(data) {
        var json = JSON.parse(data.xhr.response);
        if (json.status == 'success') {
          sweetalert2("success", json.message);
          $(':input','#form_add_menu_item').not(':button, :submit, :reset, :hidden').val('');
          this.removeFile(data);
        } else {
          sweetalert_error(json.message);
        }
      });
    }
  });
  $('.edit-avatar-user').dropzone({
    url: 'profiles/update_avatar',
    maxFiles: 1,
    addRemoveLinks: true,
    autoProcessQueue: false,
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    init: function () {
      var myDropzone = this;
      this.on('sending', function(file, xhr, formData) {
        var data = $('#form_edit_avatar').serializeArray();
        $.each(data, function(key, el) {
          formData.append(el.name, el.value);
        });
      });
      this.on('success', function(data) {
        var json = JSON.parse(data.xhr.response);
        if (json.status == 'success') {
          sweetalert2("success", json.message);
          $(':input','#form_edit_avatar').not(':button, :submit, :reset, :hidden').val('');
          this.removeFile(data);
          sweetalert2(json.status, json.message);
          $('#avatar_profile').attr('src', json.avatar);
          if (json.old_avatar) {
            var html = [
              '<div class="col-md-3 col-sm-3">',
                '<div class="item-picture-available">',
                  '<a class="event-update_avatar" href="javascript:void(0)">',
                    '<img src="/uploads/user/avatar/'+json.id+'/'+json.old_avatar+'" class="img-picture-available">',
                    '<div class="ovrly"></div>',
                    '<div class="buttons">',
                      '<div class="icon-ok"></div>',
                    '</div>',
                  '</a>',
                '</div>',
              '</div>',
            ];
            $('.zone_edit_avatar').append(html.join(''));
          }
        } else {
          sweetalert_error(json.message);
        }
      });
      this.on("addedfile", function (file) {
        Swal.fire({
          title: I18n.t("javascript.are_you_sure"),
          text: I18n.t("javascript.change_avatar"),
          type: 'warning',
          showCancelButton: true,
          cancelButtonColor: '#d33',
          cancelButtonText: 'Hủy bỏ',
        }).then((result) => {
          if (result.value) {
            myDropzone.processQueue();
          }
        })
      });
    }
  });
  $('.edit-menu-item-pic').dropzone({
    url: 'profiles/update_menu_item',
    maxFiles: 1,
    addRemoveLinks: true,
    autoProcessQueue: false,
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    init: function () {
      var myDropzone = this;
      $('.open_modal_menu_item').on('click', function () {
        var id = $(this).attr('data-id');
        var name = $(this).attr('data-name');
        var price = $(this).attr('data-price');
        var discount = $(this).attr('data-discount');
        var image = $(this).attr('data-image');
        var name_image = $(this).attr('data-name-image');
        $('#menu_item_name').val(name);
        $('#menu_item_price').val(price);
        $('#menu_item_discount').val(discount);
        $('#menu_item_id').val(id);
        if (currentFile) {
          myDropzone.removeAllFiles();
        }
        var mockFile = { name: name_image, size: 12345 };
        myDropzone.emit("addedfile", mockFile);
        myDropzone.emit("thumbnail", mockFile, image);
        myDropzone.emit("complete", mockFile);
        myDropzone.files.push(mockFile);
        currentFile = mockFile;
        $("#submit_edit_menu_item").click(function (e) {
          e.preventDefault();
          myDropzone.processQueue();
        });
        myDropzone.on('sending', function(file, xhr, formData) {
          var data = $('#form_edit_menu_item').serializeArray();
          $.each(data, function(key, el) {
            formData.append(el.name, el.value);
          });
        });
        myDropzone.on('success', function(data) {
          var json = JSON.parse(data.xhr.response);
          if (json.status == 'success') {
            localStorage.setItem('message-success', json.message)
          } else {
            localStorage.setItem('message-error', json.message)
          }
          window.location.reload();
        });
      });
    }
  });
}
jQuery('#profile_sidebar').theiaStickySidebar({
  additionalMarginTop: 80
});
//Custom url
const urlParams = new URLSearchParams(window.location.search);
const nav = urlParams.get('nav');
const tab = urlParams.get('tab');
if (nav == null || nav == 'basic_info') {
  $('#basic_info').addClass('active');
  $('[data-check="true"]')[0].checked = true;
}
if (nav == 'change_password') {
  $('#change_password').addClass('active');
}
if (nav == 'update_avatar') {
  $('#update_avatar').addClass('active');
}
if (nav == 'address_manage') {
  $('#address_manage').addClass('active');
}
if (tab == "manage_place") {
  var manage_place = nav.split("_");
  if (nav == 'manage_place_'+manage_place[2]) {
    $('#tab_personal').removeClass('tab-current');
    $('#tab_manage_place').addClass('tab-current');
    $('#personal').removeClass('content-current');
    $('#manage_place').addClass('content-current');
    $('#manage_place_'+manage_place[2]).addClass('active');
    $('#tab_order_history').removeClass('tab-current');
    $('#order_history').removeClass('content-current');
    $('#tab_manage_shipper').removeClass('tab-current');
    $('#manage_shipper').removeClass('content-current');
  }
}
if (tab == 'manage_shipper') {
  $('#tab_manage_shipper').addClass('tab-current');
  $('#manage_shipper').addClass('content-current');
  $('#tab_order_history').removeClass('tab-current');
  $('#order_history').removeClass('content-current');
  $('#tab_manage_place').removeClass('tab-current');
  $('#manage_place').removeClass('content-current');
  $('#tab_personal').removeClass('tab-current');
  $('#personal').removeClass('content-current');
}
if (tab == 'order_history') {
  $('#tab_order_history').addClass('tab-current');
  $('#order_history').addClass('content-current');
  $('#tab_manage_shipper').removeClass('tab-current');
  $('#manage_shipper').removeClass('content-current');
  $('#tab_manage_place').removeClass('tab-current');
  $('#manage_place').removeClass('content-current');
  $('#tab_personal').removeClass('tab-current');
  $('#personal').removeClass('content-current');
}
$('#tab_personal').on('click', function() {
  $('#tab_personal').addClass('tab-current');
  $('#personal').addClass('content-current');
  $('#tab_manage_place').removeClass('tab-current');
  $('#manage_place').removeClass('content-current');
  $('#tab_manage_shipper').removeClass('tab-current');
  $('#manage_shipper').removeClass('content-current');
  $('#tab_order_history').removeClass('tab-current');
  $('#order_history').removeClass('content-current');
});
$('#tab_order_history').on('click', function() {
  $('#tab_order_history').addClass('tab-current');
  $('#order_history').addClass('content-current');
  $('#tab_manage_place').removeClass('tab-current');
  $('#manage_place').removeClass('content-current');
  $('#tab_manage_shipper').removeClass('tab-current');
  $('#manage_shipper').removeClass('content-current');
  $('#tab_personal').removeClass('tab-current');
  $('#personal').removeClass('content-current');
});
$('#tab_manage_place').on('click', function() {
  $('#tab_manage_place').addClass('tab-current');
  $('#manage_place').addClass('content-current');
  $('#tab_order_history').removeClass('tab-current');
  $('#order_history').removeClass('content-current');
  $('#tab_manage_shipper').removeClass('tab-current');
  $('#manage_shipper').removeClass('content-current');
  $('#tab_personal').removeClass('tab-current');
  $('#personal').removeClass('content-current');
});
$('#tab_manage_shipper').on('click', function() {
  $('#tab_manage_shipper').addClass('tab-current');
  $('#manage_shipper').addClass('content-current');
  $('#tab_order_history').removeClass('tab-current');
  $('#order_history').removeClass('content-current');
  $('#tab_manage_place').removeClass('tab-current');
  $('#manage_place').removeClass('content-current');
  $('#tab_personal').removeClass('tab-current');
  $('#personal').removeClass('content-current');
});
//Update avatar
$('.event-update_avatar').on('click', function () {
  var link_new_avatar = $(this).find('.img-picture-available').attr('src');
  var arr_link_new_avatar = link_new_avatar.split('/');
  var new_avatar = arr_link_new_avatar[arr_link_new_avatar.length-1];
  Swal.fire({
    title: I18n.t("javascript.are_you_sure"),
    text: I18n.t("javascript.change_avatar"),
    type: 'warning',
    showCancelButton: true,
    cancelButtonColor: '#d33',
    cancelButtonText: 'Hủy bỏ',
  }).then((result) => {
    if (result.value) {
      $.ajax({
        url: '/profiles/update_avatar',
        type: 'put',
        cache: false,
        data: { new_avatar: new_avatar },
        success: function(data) {
          if (data.status == 'success') {
            sweetalert2('success', I18n.t("javascript.success.change_avatar"));
            setTimeout(window.location.reload(), 3000 );
          } else {
            sweetalert2('error', I18n.t("javascript.error.change_avatar"));
          }
        }
      });
    }
  })
});
//Google map
$('.select_address').on('change', function () {
  var geocoder = new google.maps.Geocoder();
  var address = $('.select_address').val();
  geocoder.geocode( {'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      var address_lat = results[0].geometry.location.lat();
      var address_lng = results[0].geometry.location.lng();
      $('#latitude_address').val(address_lat);
      $('#longitude_address').val(address_lng);
    }
  });
});
$('.select_address_edit').on('change', function () {
  var geocoder = new google.maps.Geocoder();
  var address = $('.select_address_edit').val();
  geocoder.geocode( {'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      var address_lat = results[0].geometry.location.lat();
      var address_lng = results[0].geometry.location.lng();
      var address_id = $(this).attr('data-id');
      $('#latitude_address_edit_'+address_id).val(address_lat);
      $('#longitude_address_edit_'+address_id).val(address_lng);
    }
  });
});
var latitude_user, longitude_user;
if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition(showPosition);
} else {
  sweetalert2('error', "Geolocation is not supported by this browser.");
}
function showPosition(position) {
  latitude_user = position.coords.latitude;
  longitude_user = position.coords.longitude;
}
$('#on_off_location').on('change', function () {
  var value = $(this).val();
  var id = $(this).attr('data-id');
  if (value == "1") {
    $.ajax({
      url: '/shippers/update_location',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id,
        latitude : latitude_user,
        longitude : longitude_user
      },
      success: function (data) {
        $('#on_off_location').val(0);
      }
    });
  } else {
    $.ajax({
      url: '/shippers/update_location',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function (data) {
        $('#on_off_location').val(1);
      }
    });
  }
});
$('#on_off_manage_place').on('change', function () {
  var value = $(this).val();
  var id = $(this).attr('data-id');
  if (value == "1") {
    $.ajax({
      url: '/places/update_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function (data) {
        $('#on_off_manage_place').val(0);
      }
    });
  } else {
    $.ajax({
      url: '/places/update_status',
      type: 'POST',
      cache: false,
      data: {
        value: value,
        id: id
      },
      success: function (data) {
        $('#on_off_manage_place').val(1);
      }
    });
  }
});
//Food option
list_food_ids = [];
$('.select-box-food-option').on('change', function () {
  var value_id = $(this).val();
  var value_name = $(this).find('option:selected').text();
  $(this).find('option[value="'+value_id+'"]').attr('disabled', 'disabled');
  $(this).val(null);
  $('#tags_food_option').append('<a href=\"javascript:void(0)\" class=\"tag-food-option\" id=\"tag-food-option-'+value_id+'\" data-value-id=\"'+value_id+'\"><i class=\"icon-cancel-circled-1\"></i>'+value_name+'</a>\n');
  list_food_ids.push(value_id);
  $("#list_foods").val(list_food_ids);
});
jQuery('body').on('click', '.tag-food-option', function () {
  var tag_value_id = $(this).attr('data-value-id');
  $('#tag-food-option-'+tag_value_id).remove();
  $('#is_optional').find('option[value="'+tag_value_id+'"]').removeAttr('disabled');
  var index = list_food_ids.indexOf(tag_value_id);
  list_food_ids.splice(index, 1);
  $("#list_foods").val(list_food_ids);
});
$('#add_input_menu_option').on('click', function() {
  var number = $("#number").val();
  number++;
  $("#number").val(number);
  var html = [
    '<div class="form-group" id="number_'+number+'">',
      '<div class="row">',
        '<div class="col-sm-3">',
          '<input name="price_'+number+'" type="number" class="form-control" placeholder="VD. 5000đ">',
        '</div>',
        '<div class="col-sm-5">',
          '<input name="name_'+number+'" type="text" class="form-control" placeholder="VD. Thêm đường, thêm sữa,...">',
        '</div>',
        '<div class="col-sm-4 radio-input">',
          '<label><input type="radio" name="option_item_'+number+'" checked class="icheck" value="1">Checkbox&nbsp;</label>',
          '<label class="margin_left"><input type="radio" name="option_item_'+number+'" class="icheck" value="2">Radio&nbsp;</label>',
          '<a href="javascript:void(0)" class="nomargin remove_input_food_option" data-number="'+number+'"><i class="icon-trash"></i></a>',
        '</div>',
      '</div>',
    '</div>',
  ];
  $('#input_food_option').append(html.join(''));
  $('input.icheck').iCheck({
    checkboxClass: 'icheckbox_square-grey',
    radioClass: 'iradio_square-grey'
  });
  $('.remove_input_food_option').on('click', function() {
    var number = $(this).attr('data-number');
    $('#number_'+number).remove();
  });
});
$('.remove_input_food_option').on('click', function() {
  var number = $(this).attr('data-number');
  $('#number_'+number).remove();
});
//Modal edit
$('.open_modal_menu_category').on('click', function () {
  var id = $(this).attr('data-id');
  var name = $(this).attr('data-name');
  $('#old_name').val(name);
  $('#menu_category_id').val(id);
});
$('.open_modal_menu_option').on('click', function () {
  var id = $(this).attr('data-id');
  var name = $(this).attr('data-name');
  var price = $(this).attr('data-price');
  $('#menu_option_name').val(name);
  $('#menu_option_price').val(price);
  $('#menu_option_id').val(id);
});
$('.select_confirm_order').on('click', function () {
  var title = $(this).attr('data-title');
  var id = $(this).attr('data-id');
  var value = $(this).attr('data-value');
  sweetalert_select_confirm_order(title, id, value);
});
