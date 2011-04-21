/*
################################################################################
#
# File:    display1.js
# Project: World of SETI (WOS)
# Authors:
#                  Alan Mak
#                  Anthony Tang
#                  Dia Kharrat
#                  Paul Wong
#
# The initial source was worked on by students of Carnegie Mellon Silicon Valley
#
# Copyright 2011 The SETI Institute
#
# World of SETI is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# World of SETI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with World of SETI.  If not, see<http://www.gnu.org/licenses/>.
#
# Implementers of this code are requested to include the caption
# "Licensed through SETI" with a link to setiQuest.org.
#
# For alternate licensing arrangements, please contact
# The SETI Institute at www.seti.org or setiquest.org.
#
################################################################################
*/

/**
 *
 * @param callback_fn
 * @param timeout
 */
function ajaxError(callback_fn, timeout)
{
    timeoutManager.setObservingTimeout(callback_fn, timeout);
}

/**
 * This method gets called when the AJAX call to the activity resource is
 * successful. It updates the canvas element that is used to display the
 * waterfall in the view. We use processing.js to draw the waterfall.
 *
 * @param response The JSON response from the server
 * @param id The id of the waterfall
 * @param updateWaterfallCallback_fn The function to call in the next waterfall interval
 */
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

/*
 * Performs the AJAX call to the server to obtain the latest waterfall data and
 * then on success updates the waterfall, else handles the error and retries
 * the request.
 *
 * @param id The id of the waterfall
 * @param json The JSON to use to create the waterfall. This is only used for
 *             manual testing purposes.
 */
function updateWaterfall(id, json)
{
    if(updateWaterfall.waterfall_data == undefined)
    {
        updateWaterfall.waterfall_data = new Array();
    }

    if(updateWaterfall.waterfall_data[id] == undefined)
    {
        updateWaterfall.waterfall_data[id] = {
            data:"",
            last_row:1
        };
    }

    if(json == undefined)
    {
        var updateWaterfallCallback = function() {
            updateWaterfall(id);
        };

        // Take id and make AJAX query
        $.ajax({
            type:     'GET',
            url:      display1_waterfall_path,
            data:     {
                id: id,
                start_row: updateWaterfall.waterfall_data[id].last_row
            },
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
            data: {
                id: id,
                start_row: updateWaterfall.waterfall_data[id].last_row,
                jsonobject: json.jsonobject.value
            },
            success:  function(response) {
                updateWaterfallAjaxSuccess(response, id, updateWaterfallCallback);
            },
            datatype: 'json'
        });
    }
}

/**
 * Performs the AJAX call to the server to obtain the latest baseline data and
 * then on success updates the baseline, else handles the error and retries
 * the request.
 *
 * @param id The id of the baseline
 * @param json The JSON to use to create the baseline. This is only used for
 *             manual testing purposes.
 */
function updateBaseline(id, json)
{
    // to bypass browser caching, we need to append a random parameter to the URL
    var d = new Date();

    if(json == undefined)
    {
        var updateBaselineCallback = function() {
            updateBaseline(id);
        };
        timeoutManager.setObservingTimeout(updateBaselineCallback, TIMEOUT_BASELINE );

        $('#baseline' + id).attr('src', '/display1/baseline_chart/' + id + '?' + d.getTime());
    }
    else
    {
        $('#baseline' + id).attr('src', '/display1/baseline_chart/' + id + '?' + d.getTime() + "&jsonobject=" + json.jsonobject.value);
    }
}

/**
 * Updates the beam information when the AJAX call to the server for beam
 * data is successful. Updates the icon image for the beam status, location,
 * description, and frequency.
 * 
 * @param response The response JSON object
 * @param id The id of the beam
 * @param updateBeamInfoCallback_fn The function to call in the next beam timeout
 * @param updateFrequencyCoverageCallback_fn
 */
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

    var ra = decimalHoursToStringHours(response.ra);
    var dec = decimalDegreesToStringDegrees(response.dec);

    $('#beam' + id + ' .beam_status').text(response.status);
    $('#beam' + id + ' .beam_location').text(ra + ' / ' + dec);
    $('#beam' + id + ' .beam_description').text(response.description);
    $('#beam' + id + ' .beam_frequency').text(response.freq + ' MHz');

    updateFrequencyCoverageCallback_fn();

    timeoutManager.setObservingTimeout(updateBeamInfoCallback_fn, TIMEOUT_BEAM_INFO);
}

/**
 * Performs the AJAX call to the server to obtain the latest beam info and
 * then on success updates the beam info, else handles the error and retries
 * the request.
 *
 * @param id The id of the baseline
 * @param json The JSON to use to create the baseline. This is only used for
 *             manual testing purposes.
 */
function updateBeamInfo(id, json)
{
    if(json == undefined)
    {
        var updateBeamInfoCallback = function() {
            updateBeamInfo(id);
        };

        // Take id and make AJAX query
        $.ajax({
            type:     'GET',
            url:      display1_beam_path,
            data:     {
                id:id
            },
            success:  function(response) {
                updateBeamInfoAjaxSuccess(response, id, updateBeamInfoCallback, function(){
                    updateFrequencyCoverage(id, response.freq);
                });
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
            data:     {
                id:id,
                jsonobject:json.jsonobject.value
            },
            success:  function(response) {
                updateBeamInfoAjaxSuccess(response, id, updateBeamInfoCallback, function(){
                    updateFrequencyCoverage(id, response.freq);
                });
            },
            datatype: 'json'
        });
    }
}

/**
 * This method gets called on success of the AJAX call to the server to obtain
 * the activity data. It takes the data and updates the activity id and
 * observation status in the view. Also, if the status is Observing, it will
 * let the timeoutManager know so that it will make requests to the other types
 * of data. Otherwise if the beams are not observing, it will turn off the polling
 * in the timeoutManager.
 *
 * @param response The JSON response
 * @param updateActivityCallback_fn The callback method to call in the next timeout of the activity
 * @param initCallback_fn
 * @param bSetObserving 
 */
function updateActivityAjaxSuccess(response, updateActivityCallback_fn, initCallback_fn, bSetObserving)
{
    $('#activity-id').text(response.id);
    $('#current-observation-id').text(response.status);

    if(bSetObserving)
    {
        if(isObserving(response.status))
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

/**
 *
 */
function updateActivityAjaxError(updateActivityCallback_fn, timeout)
{
    setTimeout(updateActivityCallback_fn, timeout);
}

/**
 * Performs the AJAX call to the server to obtain the latest activity data and
 * then on success updates the activity data, else handles the error and retries
 * the request. Updating the activity to a observational state will turn on all
 * other updates.
 *
 * @param json The JSON to use to create the activity data. This is only used for
 *             manual testing purposes.
 */
function updateActivity(json)
{
    var updateActivityCallback = function() {
        updateActivity();
    };
    var initTimerCallback = function() {
        initTimers();
    };
  
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
            data:     {
                jsonobject:json.jsonobject.value
            },
            success:  function(response) {
                updateActivityAjaxSuccess(response, updateActivityCallback, initTimerCallback, false);
            },
            datatype: 'json'
        });
    }
}

/**
 * This method gets called on success of the AJAX call to the server to obtain
 * the frequency coverage data. It takes the data and updates the frequency
 * coverage table in the view.
 *
 * @param response The JSON reponse object from the AJAX call
 * @param id The id of the beam
 * @param currFreq 
 * @param bUpdateCurrentFrequencyPointer
 */
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

/**
 * Performs the AJAX call to the server to obtain the latest frequency coverage data
 * and then on success updates the frequency coverage, else handles the error and retries
 * the request.
 *
 * @param id The id of the beam
 * @param currFreq
 * @param json The JSON to use to create the activity data. This is only used for
 *             manual testing purposes.
 */
function updateFrequencyCoverage(id, currFreq, json) {
    if(json == undefined)
    {
        // Take id and make AJAX query
        $.ajax({
            type:     'GET',
            url:      display1_frequency_coverage_path,
            data:     {
                id:id
            },
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
            data:     {
                id:id,
                jsonobject:json.jsonobject.value
            },
            success:  function(response) {
                updateFrequencyCoverageAjaxSuccess(response, id, currFreq, false);
            },
            datatype: 'json'
        });
    }
}

/**
 * Registers display1 for automatic updates for all its various components.
 */
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
