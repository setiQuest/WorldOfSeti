/*
################################################################################
#
# File:    display2.js
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

var map; // Global map variable.

/**
 * Initializes Google Sky Map
 */
function initialize() {
    if (GBrowserIsCompatible()) {
        map = new GMap2(document.getElementById("sky_map"), {
            mapTypes : G_SKY_MAP_TYPES
        });
        // sample look at Mars initially
        var longitude = raToLng('23:14:52.02');
        var latitude  = decToLat('-05:56:40.36');
        map.setCenter(new GLatLng(latitude, longitude), 3);
        map.addControl(new GLargeMapControl());
        map.addControl(new GMapTypeControl());
        map.enableContinuousZoom();
    }
}

/**
 * Updates the map location to the passed in coordinates. The map will pan
 * to the location if it is not already looking at the passed in coordinates.
 *
 * @param ra
 * @param dec
 * @param fov_ra
 * @param fov_dec
 */
function updateMapLocation(ra, dec, fov_ra, fov_dec)
{
    var longitude = raToLng(decimalDegreesToString(ra));
    var latitude = decToLat(decimalDegreesToString(dec));
    var fov_longitude = raToLng(decimalDegreesToString(fov_ra));
    var fov_latitude = decToLat(decimalDegreesToString(fov_dec));

    // Clear all overlays and markers
    map.clearOverlays();

    // construct GLatLng primary beam loc
    var primary_beam_ll = new GLatLng(latitude, longitude);

    // construct GLatLng fov beam loc
    var fov_beam_ll = new GLatLng(fov_latitude, fov_longitude);

    // Add markers to show where FOV and beam loc is (mainly for debugging)
    // var primary_marker = new GMarker(primary_beam_ll);
    // var fov_marker = new GMarker(fov_beam_ll);
    // map.addOverlay(primary_marker);
    // map.addOverlay(fov_marker);

    // Covert to pixels because it's easier to draw circle
    var current_projection = map.getCurrentMapType().getProjection();

    // Start zoom at 0 (entire sky) and gradually increase until
    // radius is only 25% of vertical axis.
    var zoom = 0;
    var pixel_distance = 0; // Assume really high so we recalc.
    var pixelxy;
    var fov_pixelxy;

   // map.setZoom(zoom); // zoom out entirely first

    // Start zoom at very far away ( zoom 0 is entire sky) and then
    // gradually zoom in. Stop when the radius of the FOV is greater than
    // 25% vertical screen (1080/4 = 270).
    var max_vertical_div_4 = SCREENSIZE_HEIGHT/4;
    while((zoom < 20) && (pixel_distance < max_vertical_div_4))
    {
        zoom++; // Increase zoom
    //    map.zoomIn(primary_beam_ll, true, true); // Zoom in on map
        pixelxy = current_projection.fromLatLngToPixel(primary_beam_ll,zoom);
        fov_pixelxy = current_projection.fromLatLngToPixel(fov_beam_ll,zoom);

        // Calculate actual pixel distance from the two points
        pixel_distance = Math.sqrt(Math.pow(pixelxy.x - fov_pixelxy.x,2) + Math.pow(pixelxy.y - fov_pixelxy.y,2));
    }

   map.setZoom(zoom); // zoom to range

    // Draw circle
    var degrees = 0;
    var x, y;
    var lla = new Array();
    for(;degrees<=Math.PI*2 + .15; degrees+=.15)
    {
        y = pixelxy.y + Math.cos(degrees) * pixel_distance;
        x = pixelxy.x + Math.sin(degrees) * pixel_distance;
        var new_pixelxy = new GPoint(x,y);
        lla.push(current_projection.fromPixelToLatLng(new_pixelxy,zoom,false));
    }
    gp = new GPolygon(lla , "#FFFFFF", 2, 1,"#0000FF",.10);
    map.addOverlay(gp);
    gp.show(); // Show the overlay

    // Pan to right of the center of the primary beam
    var center_pixelxy = current_projection.fromLatLngToPixel(primary_beam_ll,zoom);

    // Shift center of the FOV circle 400 pixels to the right
    center_pixelxy.x -= 400; 
    // When panorama is working, uncomment the below to shift FOV circle up.
   // center_pixelxy.y += 150; 
    var center_beam_ll = current_projection.fromPixelToLatLng(center_pixelxy,zoom,false);
    


   // map.panTo( primary_beam_ll ); // Pan center of the map to the primary beam location
    map.panTo( center_beam_ll ); // Pan center of the map to the primary beam location
}

/**
 * This method creates a beam marker that marks where the beam is pointing at
 * in the Google Sky map display.
 *
 * @param ra The RA of the marker
 * @param dec The DEC of the marker
 */
function addBeamMarker(ra, dec)
{
    var longitude = raToLng(decimalDegreesToString(ra));
    var latitude = decToLat(decimalDegreesToString(dec));

    // construct GLatLng beam loc
    var beam_ll = new GLatLng(latitude, longitude);

    // Create "beam" marker icon
    var beamIcon = new GIcon();
    beamIcon.image = "http://chart.apis.google.com/chart?chst=d_map_pin_icon&chld=camping|FFFF00";
    beamIcon.iconSize = new GSize(12, 20);
    beamIcon.shadowSize = new GSize(22, 20);
    beamIcon.iconAnchor = new GPoint(6, 20);
    beamIcon.infoWindowAnchor = new GPoint(5, 1);
    markerOptions = { icon:beamIcon };

    // the Marker is divine
    var marker = new GMarker(beam_ll, markerOptions);
    map.addOverlay(marker);
}

/**
 * Updates the weather forecast
 */
function updateWeatherForecast()
{
    $('#weatherForecast').html($('#weatherForecast').html());
}

/**
 * Updates the ATA web cam by rotating the images one by one so that we can
 * show all of them over time.
 */
function updateWebCam() {
    var MAX_NUM_IMAGES = 18
    // initialize the panorama id if not defined yet (only happens the first time)
    if(updateWebCam.panorama_id == undefined) {
        updateWebCam.panorama_id = 1;
    } else {
        // goto the next panorama id and if it hits the max num of images, reset it
        updateWebCam.panorama_id++;
        if(updateWebCam.panorama_id > MAX_NUM_IMAGES) {
            updateWebCam.panorama_id = 1;
        }
    }

    // rotate the 3 webcam images to the next one in the list
    updateWebCamImages(1, updateWebCam.panorama_id);
    updateWebCamImages(2, (updateWebCam.panorama_id+1) % MAX_NUM_IMAGES);
    updateWebCamImages(3, (updateWebCam.panorama_id+2) % MAX_NUM_IMAGES);
}

/**
 * Changes the webcam's img src tags to the next image in the list. Also
 * append the current date as a random parameter to the URL to prevent browser
 * caching.
 *
 * @param id The id of the webcam img element
 * @param panorama_id The id of the webcam panorama image
 */
function updateWebCamImages(id, panorama_id)
{
    // to bypass browser caching, we need to append a random parameter to the URL
    d = new Date();
    $('#webcamImage' + id).attr('src', 'http://atacam.seti.org/panorama/Pan' + panorama_id + ".jpg" + '?' + d.getTime());
}

/**
 * Performs the AJAX call to the web server to obtain the activity data. It will
 * only perform updates if the activity's status is currently observing. Also
 * updates the map location in the Google Sky map and also updates the beam
 * markers. Lastly it updates the URL for the contextual information.
 *
 * @param json The JSON response object recieved from the server.
 */
function updateActivity(json)
{
    if(json == undefined)
    {
        var updateActivityCallback = function() {
            updateActivity();
        };
        // Take id and make AJAX query
        $.ajax({
            type: 'GET',
            url: display1_activity_path,
            success: function(response) {
                if(isObserving(response.status))
                {
                    if(!timeoutManager.isObserving)
                    {
                        timeoutManager.isObserving = true;
                        timeoutManager.startObserving(function() {});
                    }
                    // Call update map location
                    updateMapLocation(response.primaryBeamLocation.ra,
                        response.primaryBeamLocation.dec,
                        response.fovBeamLocation.ra,
                        response.fovBeamLocation.dec);

                    // Update all markers on the beam ( updateMapLocation will
                    // remove all overlays so we don't need to worry about that)
                    updateBeamInfo(1);
                    updateBeamInfo(2);
                    updateBeamInfo(3);

                    $('#contextual-info').attr('src', '/display1/activity_contextual_info');
                    $("#contextual-info").load( function(){
                        $("#contextual-info").height($("#contextual-info").contents().find("html").height());
                    } )

                }
                else
                {
                    timeoutManager.isObserving = false;
                }

                setTimeout(updateActivityCallback, TIMEOUT_ACTIVITY );
            },
            error: function() {
                // We should handle error here
                errors = true;
                setTimeout(updateActivityCallback, TIMEOUT_RETRY_LONG );
            },
            datatype: 'json'
        });
    }
    else
    {
        $.ajax({
            type: 'GET',
            url: display1_activity_path,
            data: {
                jsonobject:json.jsonobject.value
                },
            success: function(response) {
                if(response.status == "Observing")
                {
                    // Call update map location
                    updateMapLocation(response.primaryBeamLocation.ra,
                        response.primaryBeamLocation.dec,
                        response.fovBeamLocation.ra,
                        response.fovBeamLocation.dec);
                }
            },
            datatype: 'json'
        });
    }
}

/**
 * This method gets called when the AJAX call for the beam info returns on
 * success.
 *
 * @param response The JSON response object
 */
function updateBeamInfoAjaxSuccess(response)
{
    addBeamMarker(response.ra, response.dec);
}

/**
 * Makes a call to the web server to obtain the beam data, and calls a function
 * to update the beam info in the view.
 *
 * @param id The id of the beam
 * @param json The JSON response object
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
            type: 'GET',
            url: display1_beam_path,
            data: {
                id:id
            },
            success: function(response) {
                updateBeamInfoAjaxSuccess(response, id, updateBeamInfoCallback, function(){
                    updateFrequencyCoverage(id, response.freq);
                });
            },
            error: function() {
            },
            datatype: 'json'
        });
    }
}
