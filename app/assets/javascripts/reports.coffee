$ ->
  $('table#dttb-reports').dataTable
    processing: true
    ajax:
      url: $('table#dttb-reports').data('source')
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
