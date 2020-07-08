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
//= require rails-ujs
//= require activestorage
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require datatables
//= require popper
//= require bootstrap
//= require moment
//= require tempusdominus-bootstrap-4.js
//= require tinymce
//= require finders
//= require_tree .

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function controllerMatches(controllers_ary) {
  var controller = $('body').data('controller');
  return controllers_ary.indexOf(controller) !== -1;
}

function actionMatches(actions_ary) {
  var action = $('body').data('action');
  return actions_ary.indexOf(action) !== -1;
}
