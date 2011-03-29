/*
################################################################################
#
# File:    application.js
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

/*
 * This code searches for all the <script type="application/processing" target="canvasid">
 * in your page and loads each script in the target canvas with the proper id.
 * It is useful to smooth the process of adding Processing code in your page and starting
 * the Processing.js engine.
 */

if (window.addEventListener) {
  window.addEventListener("load", function() {
    var scripts = document.getElementsByTagName("script");
    var canvasArray = Array.prototype.slice.call(document.getElementsByTagName("canvas"));
    var canvas;
    for (var i = 0, j = 0; i < scripts.length; i++) {
      if (scripts[i].type == "application/processing") {
        var src = scripts[i].getAttribute("target");
        if (src && src.indexOf("#") > -1) {
          canvas = document.getElementById(src.substr(src.indexOf("#") + 1));
          if (canvas) {
            Processing.addInstance(new Processing(canvas, scripts[i].text));
            for (var k = 0; k< canvasArray.length; k++)
            {
              if (canvasArray[k] === canvas) {
                // remove the canvas from the array so we dont override it in the else
                canvasArray.splice(k,1);
              }
            }
          }
        } else {
          if (canvasArray.length >= j) {
            Processing.addInstance(new Processing(canvasArray[j], scripts[i].text));
          }
          j++;
        }
      }
    }
  }, false);
}

function TimeoutManager()
{
    this.isObserving = false;
    this.startObserving = function( startFunction ) {
        startFunction;
    };
    this.setTimeout = function( fn_handle, interval_milliseconds ) {
        if(timeoutManager.isObserving)
        {
            setTimeout(fn_handle, interval_milliseconds);
        }
    };
    this.registerTimeout = function( fn_handle, interval_milliseconds ) {
        // Create new function with timeout
        var newfunction = function(){
            fn_handle();
            setTimeout(newfunction, interval_milliseconds);
        }

        // Call new function to register timeout
        newfunction();
    };
}

var timeoutManager = new TimeoutManager();

/* Javascript update function */
function registerElementTimer( fn_handle, interval_milliseconds )
{
    // Create new function with timeout
    var newfunction = function(){
        fn_handle();
        setTimeout(newfunction, interval_milliseconds);
    }

    // Call new function to register timeout
    newfunction();
}
