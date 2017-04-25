(function (){
  var GOVUKDATEFIELDS = function (){
    var $allDateGroupInstances = $(".form-date"),

      init = function (){

        $allDateGroupInstances.each(function (){
          var $currentGroup = $(this);
          var $inputs = $currentGroup.find('input');
          var $todayButton = $currentGroup.find('a');

          //Show Today Button if js is enabled
          $todayButton.addClass('js-enabled');

          $todayButton.on('click', function(e) {
            //Set date and remove inputs from natural tab order
            event.preventDefault();
            setTodayDate($currentGroup, $inputs, $todayButton);
            $inputs.attr('tabIndex', -1);
          }).on('focus', function(){
            $inputs.attr('tabIndex', 0);
          })
        })
      },
      setTodayDate = function($currentGroup, $inputs, $todayButton){
        //Cache the input fields
        var $dateField = $inputs.eq(0);
        var $monthField = $inputs.eq(1);
        var $yearField = $inputs.eq(2);

        //Create and return todays date
        var d = new Date();
        var day = d.getUTCDate();
        var month = d.getUTCMonth() + 1;
        var year = d.getUTCFullYear();

        if(month < 10 ){
          month = '0' + month;
        }

        //Set the input fields
        $dateField.val(day);
        $monthField.val(month);
        $yearField.val(year);
      };

    return {
      init : function(){
        init();
      }
    }
  }();

  GOVUKDATEFIELDS.init();

})();
