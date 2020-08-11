# LinkedSelect is Global Linked Select field, comes from finders.coffee

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['sectors']) &&
    actionMatches(['report'])

  # init datatables

  # sort reports_villages by cell and village
  $("table#dttb_sector_reports").DataTable
    order: [[ 0, 'asc' ], [ 1, 'asc' ]],
    columnDefs: [ {
      "searchable": false,
      "orderable": false,
      "targets": [-1, -2]
    } ]

  # handle datepicker on sector#reports:_facility_form
  dateStr = getParameterByName('date')
  date = moment(dateStr, 'YYYY-MM-DD')
  first = date.startOf('month').format('YYYY-MM-DD')
  last = date.endOf('month').format('YYYY-MM-DD')

  # init datetimepickers
  $('#report_date.datetimepicker-input').datetimepicker({
    format: 'YYYY-MM-DD',
    useCurrent: false,
    minDate: first,
    maxDate: last,
    viewDate: date.startOf('month'),
    widgetPositioning: {
      horizontal: 'auto'
      vertical: 'bottom'
    }
  })


  # existing reports delete button:
  # remove the deleted row from the table views using DataTables API
  $(document).on 'ajax:success', '.sector-report-delete', ->
    $('#dttb_sector_reports').DataTable()
      .row( $(this).parents('tr') )
      .remove()
      .draw()

  # _facility_form
  $('#report_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')

  $('#report_village.facility-form').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')

  $('#report_village.village-form').on 'change', ->
    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')
    else
      LinkedSelect.forcePolymorphics($(this), 'id')

  $('#report_facility').on 'change', ->
    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')
    else
      LinkedSelect.forcePolymorphics($(this), 'id')
