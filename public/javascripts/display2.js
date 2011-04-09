
  var map; // Global map variable.

  // Initializes Google Sky Map
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

  // Updates the map location
  function updateMapLocation(ra, dec, fov_ra, fov_dec)
  {
    var longitude = raToLng(decimalDegreesToString(ra));
    var latitude  = decToLat(decimalDegreesToString(dec));
    var fov_longitude = raToLng(decimalDegreesToString(fov_ra));
    var fov_latitude  = decToLat(decimalDegreesToString(fov_dec));

    // Clear all overlays and markers
    map.clearOverlays();

    // construct GLatLng primary beam loc
    var primary_beam_ll = new GLatLng(latitude, longitude);

    // construct GLatLng fov beam loc
    var fov_beam_ll = new GLatLng(fov_latitude, fov_longitude);

    // Add markers to show where FOV and beam loc is (mainly for debugging)
    var primary_marker = new GMarker(primary_beam_ll);
    var fov_marker = new GMarker(fov_beam_ll);
    map.addOverlay(primary_marker);
    map.addOverlay(fov_marker);

    // Covert to pixels because it's easier to draw circle
    var current_projection = map.getCurrentMapType().getProjection();

    // Start zoom at 0 (entire sky) and gradually increase until
    // radius is only 25% of vertical axis.
    var zoom = 0;
    var pixel_distance = 0; // Assume really high so we recalc.
    var pixelxy;
    var fov_pixelxy;

    map.setZoom(zoom); // zoom out entirely first

    // Start zoom at very far away ( zoom 0 is entire sky) and then
    // gradually zoom in. Stop when the radius of the FOV is greater than
    // 25% vertical screen (1080/4 = 270).
    var max_vertical_div_4 = SCREENSIZE_HEIGHT/4;
    while((zoom < 20) && (pixel_distance < max_vertical_div_4))
    {
       zoom++;   // Increase zoom
       map.zoomIn(primary_beam_ll, true, true);  // Zoom in on map
       pixelxy = current_projection.fromLatLngToPixel(primary_beam_ll,zoom);
       fov_pixelxy = current_projection.fromLatLngToPixel(fov_beam_ll,zoom);

       // Calculate actual pixel distance from the two points
       pixel_distance = Math.sqrt(Math.pow(pixelxy.x - fov_pixelxy.x,2) + Math.pow(pixelxy.y - fov_pixelxy.y,2));
     }

     // Draw circle
     var degrees = 0;
     var x, y;
     var lla = new Array();
     for(;degrees<=Math.PI*2 + .15; degrees+=.15)
     {
        y =  pixelxy.y + Math.cos(degrees) * pixel_distance;
        x =  pixelxy.x + Math.sin(degrees) * pixel_distance;
        var new_pixelxy = new GPoint(x,y);
        lla.push(current_projection.fromPixelToLatLng(new_pixelxy,zoom,false));
     }
     gp = new GPolygon(lla , "#FFFFFF", 2, 1,"#0000FF",.15);
     map.addOverlay(gp);
     gp.show();               // Show the overlay
     map.panTo( primary_beam_ll );  // Pan center of the map to the primary beam location
  }

  // Updates the weather forecast
  function updateWeatherForecast()
  {
    $('#weatherForecast').html($('#weatherForecast').html());
  }

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

  function updateWebCamImages(id, panorama_id)
  {
    // to bypass browser caching, we need to append a random parameter to the URL
    d = new Date();
    $('#webcamImage' + id).attr('src', 'http://atacam.seti.org/panorama/Pan' + panorama_id + ".jpg" + '?' + d.getTime());
  }

  function updateActivity(json)
  {
     if(json == undefined)
     {  
         var updateActivityCallback = function() { updateActivity(); };
         // Take id and make AJAX query
         $.ajax({
            type:     'GET',
            url:      display1_activity_path,
            success:  function(response) {
               if(response.status == "Observing")
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
               }
               else
               {
                  timeoutManager.isObserving = false;
               }

               setTimeout(updateActivityCallback, TIMEOUT_ACTIVITY );
            },
            error:    function() {
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
           type:     'GET',
           url:      display1_activity_path,
           data:     {jsonobject:json.jsonobject.value},
           success:  function(response) {
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
