//= require datatables/jquery.dataTables

// optional change '//' --> '//=' to enable

// require datatables/extensions/AutoFill/dataTables.autoFill
// require datatables/extensions/Buttons/dataTables.buttons
// require datatables/extensions/Buttons/buttons.html5
// require datatables/extensions/Buttons/buttons.print
// require datatables/extensions/Buttons/buttons.colVis
// require datatables/extensions/Buttons/buttons.flash
// require datatables/extensions/ColReorder/dataTables.colReorder
// require datatables/extensions/FixedColumns/dataTables.fixedColumns
// require datatables/extensions/FixedHeader/dataTables.fixedHeader
// require datatables/extensions/KeyTable/dataTables.keyTable
// require datatables/extensions/Responsive/dataTables.responsive
// require datatables/extensions/RowGroup/dataTables.rowGroup
// require datatables/extensions/RowReorder/dataTables.rowReorder
// require datatables/extensions/Scroller/dataTables.scroller
// require datatables/extensions/Select/dataTables.select

//= require datatables/dataTables.bootstrap4
// require datatables/extensions/AutoFill/autoFill.bootstrap4
// require datatables/extensions/Buttons/buttons.bootstrap4
// require datatables/extensions/Responsive/responsive.bootstrap4


//Global setting and initializer

$.extend( $.fn.dataTable.defaults, {
  responsive: true,
  pagingType: 'full',
  lengthMenu: [ [10, 25, 50, 100, -1], [ 10, 25, 50, 100, 'All'] ],
  pageLength: -1,
  language: {
    paginate: {
      first: "&#8676",
      previous: "&#8592",
      next: "&#8594",
      last: "&#8677"
    }
  }
  //dom:
  //  "<'row'<'col-sm-4 text-left'f><'right-action col-sm-8 text-right'<'buttons'B> <'select-info'> >>" +
  //  "<'row'<'dttb col-12 px-0'tr>>" +
  //  "<'row'<'col-sm-12 table-footer'lip>>"
});


$(document).on('preInit.dt', function(e, settings) {
  var api, table_id, url;
  api = new $.fn.dataTable.Api(settings);
  table_id = "#" + api.table().node().id;
  url = $(table_id).data('source');
  if (url) {
    return api.ajax.url(url);
  }
});


// init on turbolinks load
// Global dataTables can be initialized using #dttb-{name}
// For custom dataTables, use #dttb_#{name}
$(document).on('turbolinks:load', function() {
  if (!$.fn.DataTable.isDataTable("table[id^=dttb]")) {
    // global standard
    $("table[id^=dttb-]").DataTable({
      order: [0, 'asc']
    });
    $("table[id^=dttb_hidden-]").DataTable({
      lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"] ],
      columnDefs: [ {
        "searchable": false,
        "orderable": false,
        "targets": [-1]
      } ]
    });
    $("table[id^=dttb_btn0-]").DataTable({
      order: [1, 'asc'],
      columnDefs: [ {
        "searchable": false,
        "orderable": false,
        "targets": [0]
      } ]
    });
    // technology/#/reports
    $("table#dttb_reports").DataTable( {
      order: [0, 'desc']
    });
  }
});

// turbolinks cache fix
$(document).on('turbolinks:before-cache', function() {
  var dataTable = $($.fn.dataTable.tables(true)).DataTable();
  if (dataTable !== null) {
    dataTable.clear();
    dataTable.destroy();
    return dataTable = null;
  }
});


