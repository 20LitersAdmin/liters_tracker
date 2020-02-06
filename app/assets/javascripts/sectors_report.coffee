# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['sectors']) &&
    actionMatches(['report'])

  # init datatables

  # sort reports_villages by cell and village
  $("table#dttb_reports").DataTable
    order: [[ 0, 'asc' ], [ 1, 'asc' ]],
    columnDefs: [ {
      "searchable": false,
      "orderable": false,
      "targets": [-1, -2]
    } ]

  # handle datepickers on sector#reports:_facility_form
  dateStr = getParameterByName('date')
  date = moment(dateStr, 'YYYY-MM-DD')
  first = date.startOf('month').format('YYYY-MM-DD')
  last = date.endOf('month').format('YYYY-MM-DD')

  $('.datetimepicker-input').datetimepicker({
    format: 'YYYY-MM-DD'
    useCurrent: false
    viewDate: date.startOf('month')
    widgetPositioning: {
      horizontal: 'auto'
      vertical: 'bottom'
    }
  })

  $('.datetimepicker-input').datetimepicker('minDate', first)
  $('.datetimepicker-input').datetimepicker('maxDate', last)

  # preserves the set date for existing reports
  # $('.datetimepicker-input').each( ()->
  #   if $(this).data('record') == 'existing'
  #     val = $(this).attr('value')
  #     $(this).datetimepicker('date', val)
  # )

  # existing reports delete button:
  # remove the deleted row from the table views using DataTables API
  $(document).on 'ajax:success', '.sector-report-delete', ->
    $('#dttb_sector_reports').DataTable()
      .row( $(this).parents('tr') )
      .remove()
      .draw()

  # form error checking for @technology.scale == 'Community':
  # TODO: see if any of this should be preserved
  # $('div.warning-div').hide()

  # checkRow = (row) ->
  #   dist = row.find('input.distributed')
  #   check = row.find('input.checked')
  #   number = Number(dist.val()) + Number(check.val())
  #   date = row.find('input.datetimepicker-input')

  #   if number > 0 && date.val() == ''
  #     dist.css('border-color', '#dc3545')
  #     check.css('border-color', '#dc3545')
  #     date.css('border-color', '#dc3545')
  #     return 1
  #   else
  #     dist.css('border-color', '')
  #     check.css('border-color', '')
  #     date.css('border-color', '')
  #     return 0

  # checkForm = () ->
  #   errorCount = 0
  #   $('tr.facility-row').each ()->
  #     errorCount += checkRow($(this))

  #   if errorCount > 0
  #     $('input[type=submit').attr('disabled', true)
  #     $('div.warning-div').show()
  #     $('div.submit-div').hide()
  #   else
  #     $('input[type=submit').attr('disabled', false)
  #     $('div.warning-div').hide()
  #     $('div.submit-div').show()

  # $('tr.facility-row input.date-checker').on 'change', ->
  #   checkForm()

  # $('input.datetimepicker-input').on 'change.datetimepicker', ({date, oldDate})  ->
  #   checkForm()

  # _village_form: setting polymorphic reportable_type and reportable_id
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
