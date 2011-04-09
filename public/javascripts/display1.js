
function ajaxError(callback_fn, timeout)
{
    timeoutManager.setObservingTimeout(callback_fn, timeout );
}

function updateWaterfallAjaxSuccess(response, id, updateWaterfallCallback_fn)
{
    // store the last row we have so far, so that the next query gets the subsequent rows
    updateWaterfall.waterfall_data[id].last_row = response.endRow + 1;
    if(updateWaterfall.waterfall_data[id].last_row >= waterfall_height )
    {
      updateWaterfall.waterfall_data[id].last_row = 1;
    }

    // drawWaterfallRows
    var waterfall_data = decode64(response.data);

    var processingInstance = Processing.getInstanceById('canvas_waterfall' + id);
    if (processingInstance)
    {
      processingInstance.drawWaterfallRows(response.id, response.startRow, response.endRow - response.startRow + 1, waterfall_data);
    }

    timeoutManager.setObservingTimeout(updateWaterfallCallback_fn, TIMEOUT_WATERFALL );
}

// AJAX call to update JSON
function updateWaterfall(id, json)
{
   if(updateWaterfall.waterfall_data == undefined)
   {
      updateWaterfall.waterfall_data = new Array();
   }

   if(updateWaterfall.waterfall_data[id] == undefined)
   {
      updateWaterfall.waterfall_data[id] = {data:"", last_row:1};
   }

   if(json == undefined)
   {
       var updateWaterfallCallback = function() { updateWaterfall(id); };

       // Take id and make AJAX query
       $.ajax({
          type:     'GET',
          url:      display1_waterfall_path,
          data:     { id:id, start_row:updateWaterfall.waterfall_data[id].last_row },
          success:  function(response) {
             updateWaterfallAjaxSuccess(response, id, updateWaterfallCallback);
          },
          error:    function() {
             ajaxError(updateWaterfallCallback, TIMEOUT_RETRY_SHORT);
          },
          datatype: 'json'
      });
   }
   else
   {
    $.ajax({
       type:     'GET',
       url:      display1_waterfall_path,
       data: {id:id,  start_row:updateWaterfall.waterfall_data[id].last_row, jsonobject:json.jsonobject.value},
       success:  function(response) {
          updateWaterfallAjaxSuccess(response, id, updateWaterfallCallback);
       },
      datatype: 'json'
    });
   }
}

function updateBaseline(id, json)
{
   // to bypass browser caching, we need to append a random parameter to the URL
   var d = new Date();

   if(json == undefined)
   {
      var updateBaselineCallback = function() { updateBaseline(id); };
      timeoutManager.setObservingTimeout(updateBaselineCallback, TIMEOUT_BASELINE );

      $('#baseline' + id).attr('src', '/display1/baseline_chart/' + id + '?' + d.getTime());
   }
   else
      $('#baseline' + id).attr('src', '/display1/baseline_chart/' + id + '?' + d.getTime() + "&jsonobject=" + json.jsonobject.value);
}

function updateBeamInfoAjaxSuccess(response, id, updateBeamInfoCallback_fn, updateFrequencyCoverageCallback_fn)
{
    if(response.status.indexOf('ON') >= 0)
    {
      $('#beam' + id + ' .beam_status').css("background-image", "url(/images/icon_on.png)");
    }
    else
    {
      $('#beam' + id + ' .beam_status').css("background-image", "url(/images/icon_off.png)");
    }

    var longitude = lngToRa(response.ra);
    var latitude = latToDec(response.dec);

    $('#beam' + id + ' .beam_status').text(response.status);
    $('#beam' + id + ' .beam_location').text(longitude + ' - ' + latitude);
    $('#beam' + id + ' .beam_description').text(response.description);
    $('#beam' + id + ' .beam_frequency').text(response.freq + ' MHz');

    updateFrequencyCoverageCallback_fn();

    timeoutManager.setObservingTimeout(updateBeamInfoCallback_fn, TIMEOUT_BEAM_INFO );
}

function updateBeamInfo(id, json)
{
   if(json == undefined)
   {
      var updateBeamInfoCallback = function() { updateBeamInfo(id); };

      // Take id and make AJAX query
      $.ajax({
         type:     'GET',
         url:      display1_beam_path,
         data:     { id:id },
         success:  function(response) {
            updateBeamInfoAjaxSuccess(response, id, updateBeamInfoCallback, function(){updateFrequencyCoverage(id, response.freq);});
            },
         error:    function() {
            ajaxError(updateBeamInfoCallback, TIMEOUT_RETRY_SHORT);
            },
         datatype: 'json'
     });
   }
   else
   {
      $.ajax({
         type:     'GET',
         url:      display1_beam_path,
         data:     {id:id, jsonobject:json.jsonobject.value},
         success:  function(response) {
            updateBeamInfoAjaxSuccess(response, id, updateBeamInfoCallback, function(){updateFrequencyCoverage(id, response.freq);});
         },
         datatype: 'json'
      });
   }
}

function updateActivityAjaxSuccess(response, updateActivityCallback_fn, initCallback_fn, bSetObserving)
{
    $('#activity-id').text(response.id);
    $('#current-observation-id').text(response.status);

    if(bSetObserving)
    {
        if(response.status == "Observing")
        {
          if(!timeoutManager.isObserving)
          {
            timeoutManager.isObserving = true;
            timeoutManager.startObserving(initCallback_fn);
          }
        }
        else
        {
          timeoutManager.isObserving = false;
        }

        setTimeout(updateActivityCallback_fn, TIMEOUT_ACTIVITY );
    }
}

function updateActivityAjaxError(updateActivityCallback_fn, timeout)
{
    setTimeout(updateActivityCallback, TIMEOUT_RETRY_LONG );
}

//  Function to update the activity. Updating the activity to a observational state
//  will turn on all other updates.
function updateActivity(json)
{
  var updateActivityCallback = function() { updateActivity(); };
  var initTimerCallback = function() { initTimers(); };
  
   if(json == undefined)
   {
      // Take id and make AJAX query
      $.ajax({
         type:     'GET',
         url:      display1_activity_path,
         success:  function(response) {
            updateActivityAjaxSuccess(response, updateActivityCallback, initTimerCallback, true);
          },
          error:    function() {
             updateActivityAjaxError(updateActivityCallback, TIMEOUT_RETRY_LONG );
          },
          datatype: 'json'
      });
   }
   else
   {
      $.ajax({
         type:     'GET',
         url:      display1_activity_path,
         data:     {jsonobject:json.jsonobject.value},
         success:  function(response) {
            updateActivityAjaxSuccess(response, updateActivityCallback, initTimerCallback, false);
         },
         datatype: 'json'
      });
   }
}

function updateFrequencyCoverageAjaxSuccess(response, id, currFreq, bUpdateCurrentFrequencyPointer)
{
    var freqHistory = response;
    for(var col = 0; col < freqHistory.length; col++) {
      var cell = $('#frequency_cover_data_table' + id + ' tr:nth-child(2) td:nth-child(' + (col+1) + ')');
      if(freqHistory[col]) {
        cell.attr("class", "on");
      } else {
        cell.attr("class", "off");
      }
      
      if(bUpdateCurrentFrequencyPointer)
      {
          var thisFreq = col * 100 + 1000;
          var displayValue = "none";
          if(currFreq != null && (thisFreq <= currFreq && currFreq < (thisFreq + 100)) )
          {
            displayValue = "block";
          }
          $('#frequency_cover_data_table' + id + ' tr:nth-child(1) td:nth-child(' + (col+1) + ')').children().css("display", displayValue);
      }
    }
}

function updateFrequencyCoverage(id, currFreq, json) {
   if(json == undefined)
   {
      // Take id and make AJAX query
      $.ajax({
         type:     'GET',
         url:      display1_frequency_coverage_path,
         data:     { id:id },
         success:  function(response) {
            updateFrequencyCoverageAjaxSuccess(response, id, currFreq, true);
         },
         error:    function() {
         },
         datatype: 'json'
      });
   }
   else
   {
      $.ajax({
         type:     'GET',
         url:      display1_frequency_coverage_path,
         data:     {id:id, jsonobject:json.jsonobject.value},
         success:  function(response) {
            updateFrequencyCoverageAjaxSuccess(response, id, currFreq, false);
         },
         datatype: 'json'
    });
   }
}


// Register display for automatic updates
function initTimers()
{
    // Time updates for antenna id 1
    updateWaterfall(1);
    updateBaseline(1);
    updateBeamInfo(1);

    // Time updates for antenna id 2
    updateWaterfall(2);
    updateBaseline(2);
    updateBeamInfo(2);

    // Time updates for antenna id 3
    updateWaterfall(3);
    updateBaseline(3);
    updateBeamInfo(3);
}
