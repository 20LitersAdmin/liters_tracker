# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

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

  # _village_form && _facility_form: setting polymorphic reportable_type and reportable_id
  setPolymorphic = (type, id) ->
    $('#report_reportable_type.village-form').val(type)
    $('#report_reportable_id.village-form').val(id)

  selectLogic = () ->
    # don't forget: when #report_cell is un-set, #report_village gets reset by finders.coffee
    cell_val = $('#report_cell.village-form').val()
    vill_val = $('#report_village.village-form').val()

    if vill_val != ''
      # if #report_village has a value, always use that
      setPolymorphic('Village', vill_val)
    else if cell_val != ''
      # if #report_village is blank, but #report_cell has a value, use that
      setPolymorphic('Cell', cell_val)
    else
      # if they're both blank, clear the fields
      setPolymorphic('','')


  $('#report_cell.village-form').on 'change', ->
    selectLogic()

  $('#report_village.village-form').on 'change', ->
    selectLogic()

  # _facility_form: setting polymorphic reportable_type and reportable_id
