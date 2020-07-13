$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['reports']) &&
    actionMatches(['index'])

    $('table#reports-dttb').dataTable
      processing: true
      ajax:
        url: $('table#reports-dttb').data('source')
      lengthMenu: [[50, 100, 500, -1], [50, 100, 500, "All"] ]
      columns: [
        {data: 'date' }
        {data: 'location' }
        {data: 'sector' }
        {data: 'tech' }
        {data: 'dist' }
        {data: 'checked' }
        {data: 'ppl' }
        {data: 'hrs' }
        {data: 'impact' }
        {data: 'author' }
        {data: 'links' }
      ]
      pagingType: 'full_numbers'
      language: {
        paginate: {
          first: "&#8676",
          previous: "&#8592",
          next: "&#8594",
          last: "&#8677"
        }
      }
