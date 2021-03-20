$(document).ready(function() {
  $('.js-select-multiple').select2({
    theme: "foundation"
  });

  $('.js-contractor-select').select2({
    theme: "foundation",
    ajax: {
      dataType: 'json',
      url: '/api/contractors',
      data: function (params) {
        return {
          q: params.term
        };
      },
      processResults: function (data) {
        return {
            results: $.map(data, function (item) {
                return {
                    text: item.name,
                    id: item.id
                }
            })
        };
      }
    }
  });
});
