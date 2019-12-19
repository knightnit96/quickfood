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
//= require admin/jquery.min
//= require admin/bootstrap.bundle.min
//= require admin/jquery.dataTables
//= require admin/dataTables.bootstrap4
//= require admin/Chart.min
//= require admin/jquery.overlayScrollbars.min
//= require admin/adminlte
//= require admin/demo
//= require admin/jquery.mousewheel
//= require admin/raphael.min
//= require admin/jquery.mapael.min
//= require admin/usa_states.min
//= require admin/dashboard2
//= require sweetalert2/dist/sweetalert2.all.min
//= require notification
//= require rails-ujs
//= require admin/bs-custom-file-input.min
//= require bootstrap-select

$(function () {
  $('#datatable-setting').DataTable({
    columnDefs: [
      {orderable: false, searchable: false, targets: 'stt', width: '25px', className: 'stt text-center'},
      {orderable: true, targets: 'have_orderable'},
      {orderable: false, searchable: false, targets: 'action', width: '7%', className: 'action text-center'},
      {orderable: false, searchable: false, targets: 'status', width: '10%', className: 'status text-center'},
      {orderable: false, searchable: false, targets: 'image', className: 'image text-center'},
    ],
    order: [],
  });
  bsCustomFileInput.init();
});
