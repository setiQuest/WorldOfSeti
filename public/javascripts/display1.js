
var beam_frequency = null;

function drawWaterfallRows(id, start_row, end_row, data64)
{
    var waterfall_data = decode64(data64);

    var processingInstance = Processing.getInstanceById('canvas_waterfall' + id);
    if (processingInstance)
    {
      processingInstance.drawWaterfallRows(id, start_row, end_row - start_row + 1, waterfall_data);
    }
}

// AJAX call to update JSON
function updateWaterfall(id)
{
    var updateWaterfallCallback = function() { updateWaterfall(id); };

    if(updateWaterfall.waterfall_data == undefined)
    {
      updateWaterfall.waterfall_data = new Array();
    }

    if(updateWaterfall.waterfall_data[id] == undefined)
    {
      updateWaterfall.waterfall_data[id] = {data:"", last_row:1};
    }

    // Take id and make AJAX query
    $.ajax({
      type:     'GET',
      url:      display1_waterfall_path,
      data:     { id:id, start_row:updateWaterfall.waterfall_data[id].last_row },
      success:  function(response) {
        // store the last row we have so far, so that the next query gets the subsequent rows
        updateWaterfall.waterfall_data[id].last_row = response.endRow + 1;
        if(updateWaterfall.waterfall_data[id].last_row >= waterfall_height )
        {
          updateWaterfall.waterfall_data[id].last_row = 1;
        }

        drawWaterfallRows(response.id, response.startRow, response.endRow, response.data);

        timeoutManager.setObservingTimeout(updateWaterfallCallback, TIMEOUT_WATERFALL );
      },
      error:    function() {
        // We should handle error here
        timeoutManager.setObservingTimeout(updateWaterfallCallback, TIMEOUT_RETRY_SHORT );
      },
      datatype: 'json'
    });
}

function updateBaseline(id)
{
    var updateBaselineCallback = function() { updateBaseline(id); };
    timeoutManager.setObservingTimeout(updateBaselineCallback, TIMEOUT_BASELINE );

    // to bypass browser caching, we need to append a random parameter to the URL
    var d = new Date();
    $('#baseline' + id).attr('src', '/display1/baseline_chart/' + id + '?' + d.getTime());
}

function updateBeamInfo(id)
{
    var updateBeamInfoCallback = function() { updateBeamInfo(id); };

    // Take id and make AJAX query
    $.ajax({
      type:     'GET',
      url:      display1_beam_path,
      data:     { id:id },
      success:  function(response) {
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
        updateFrequencyCoverage(id, response.freq);

        timeoutManager.setObservingTimeout(updateBeamInfoCallback, TIMEOUT_BEAM_INFO );
      },
      error:    function() {
        // We should handle error here
        timeoutManager.setObservingTimeout(updateBeamInfoCallback, TIMEOUT_RETRY_SHORT );
      },
      datatype: 'json'
    });
}

function updateActivity()
{
    var updateActivityCallback = function() { updateActivity(); };
    // Take id and make AJAX query
    $.ajax({
      type:     'GET',
      url:      display1_activity_path,
      success:  function(response) {
        $('#activity-id').text(response.id);
        $('#current-observation-id').text(response.status);

        if(response.status == "Observing")
        {
          if(!timeoutManager.isObserving)
          {
            timeoutManager.isObserving = true;
            timeoutManager.startObserving(initTimers());
          }
        }
        else
        {
          timeoutManager.isObserving = false;
        }

        setTimeout(updateActivityCallback, TIMEOUT_ACTIVITY );
      },
      error:    function() {
        // We should handle error here
        setTimeout(updateActivityCallback, TIMEOUT_RETRY_LONG );
      },
      datatype: 'json'
    });
}

function updateFrequencyCoverage(id, currFreq) {
    // Take id and make AJAX query
    $.ajax({
      type:     'GET',
      url:      display1_frequency_coverage_path,
      data:     { id:id },
      success:  function(response) {

        var freqHistory = response;
        for(var col = 0; col < freqHistory.length; col++) {
          var cell = $('#frequency_cover_data_table' + id + ' tr:nth-child(2) td:nth-child(' + (col+1) + ')');
          if(freqHistory[col]) {
            cell.attr("class", "on");
          } else {
            cell.attr("class", "off");
          }

          var thisFreq = col * 100 + 1000;
          if(currFreq != null && (thisFreq <= currFreq && currFreq < (thisFreq + 100)) )
          {
            $('#frequency_cover_data_table' + id + ' tr:nth-child(1) td:nth-child(' + (col+1) + ')').children().css("display", "block");
          }
          else
          {
            $('#frequency_cover_data_table' + id + ' tr:nth-child(1) td:nth-child(' + (col+1) + ')').children().css("display", "none");
          }
        }
      },
      error:    function() {
        // We should handle error here
      },
      datatype: 'json'
    });
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
