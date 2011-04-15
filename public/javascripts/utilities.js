/*   
      CryptoMX Tools
      Copyright (C) 2004 - 2006 Derek Buitenhuis

      This program is free software; you can redistribute it and/or
      modify it under the terms of the GNU General Public License
      as published by the Free Software Foundation; either version 2
      of the License, or (at your option) any later version.

      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.

      You should have received a copy of the GNU General Public License
      along with this program; if not, write to the Free Software
      Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

var keyStr = "ABCDEFGHIJKLMNOP" +
                "QRSTUVWXYZabcdef" +
                "ghijklmnopqrstuv" +
                "wxyz0123456789+/" +
                "=";

function encode64(input) {
    var output = "";
    var chr1, chr2, chr3 = "";
    var enc1, enc2, enc3, enc4 = "";
    var i = 0;

    do {
        chr1 = input.charCodeAt(i++);
        chr2 = input.charCodeAt(i++);
        chr3 = input.charCodeAt(i++);

        enc1 = chr1 >> 2;
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        enc4 = chr3 & 63;

        if (isNaN(chr2)) {
            enc3 = enc4 = 64;
        } else if (isNaN(chr3)) {
            enc4 = 64;
        }

        output = output +
        keyStr.charAt(enc1) +
        keyStr.charAt(enc2) +
        keyStr.charAt(enc3) +
        keyStr.charAt(enc4);
        chr1 = chr2 = chr3 = "";
        enc1 = enc2 = enc3 = enc4 = "";
    } while (i < input.length);

    return output;
}

function decode64(input) {
    var output = "";
    var chr1, chr2, chr3 = "";
    var enc1, enc2, enc3, enc4 = "";
    var i = 0;

    // remove all characters that are not A-Z, a-z, 0-9, +, /, or =
    var base64test = /[^A-Za-z0-9\+\/\=]/g;
    if (base64test.exec(input)) {
        alert("There were invalid base64 characters in the input text.\n" +
            "Valid base64 characters are A-Z, a-z, 0-9, �+�, �/�, and �=�\n" +
            "Expect errors in decoding.");
    }
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

    do {
        enc1 = keyStr.indexOf(input.charAt(i++));
        enc2 = keyStr.indexOf(input.charAt(i++));
        enc3 = keyStr.indexOf(input.charAt(i++));
        enc4 = keyStr.indexOf(input.charAt(i++));

        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;

        output = output + String.fromCharCode(chr1);

        if (enc3 != 64) {
            output = output + String.fromCharCode(chr2);
        }
        if (enc4 != 64) {
            output = output + String.fromCharCode(chr3);
        }

        chr1 = chr2 = chr3 = "";
        enc1 = enc2 = enc3 = enc4 = "";

    } while (i < input.length);

    return output;
}


/*
  latToDec: latitude to declination

  @param {Number} latitude
  @return {Number} declination for this latitude
 
  // Copyright 2008 Google Inc.
  // All Rights Reserved.
*/
function latToDec(latitude) {
  if (latitude < 0) return '-' + latToDec(- latitude);
  var DEC = Math.floor(latitude).toString() + '° ';
  latitude = (latitude - Math.floor(latitude)) * 60;
  DEC += Math.floor(latitude).toString() + '\' ';
  latitude = (latitude - Math.floor(latitude)) * 60;
  DEC += latitude.toFixed(1) + '"';
  return DEC;
}

/*
  decToLat: declination to latitude

  @param {Number} dec
  @return {Number} latitude for this declination

  // Copyright 2008 Google Inc.
  // All Rights Reserved.
*/
function decToLat(dec) {
  if (dec[0] == '-') return '-' + decToLat(dec.substring(1));
  var decSplit = dec.split(':');
  var latitude = parseFloat(decSplit[0]) +
                 parseFloat(decSplit[1]) / 60.0 +
                 parseFloat(decSplit[2]) / 3600.0;
  return latitude;
}

/*
  lngToRa: longitude to right ascension

  @param {Number} longitude
  @return {Number} right ascension
  // Copyright 2008 Google Inc.
  // All Rights Reserved.

*/
function lngToRa(longitude) {
  longitude = (- longitude + 180) / 15;
  var RA = Math.floor(longitude).toString() + 'h ';
  longitude = (longitude - Math.floor(longitude)) * 60;
  RA += Math.floor(longitude).toString() + 'm ';
  longitude = (longitude - Math.floor(longitude)) * 60;
  RA += Math.floor(longitude).toFixed(1) + 's';
  return RA;
}

/*
  raToLng: right ascension to longitude

  @param {Number} right ascension
  @return {Number} longitude

  // Copyright 2008 Google Inc.
  // All Rights Reserved.
*/
function raToLng(ra) {
  var raSplit = ra.split(':');
  var longitude = parseFloat(raSplit[0]) +
                  parseFloat(raSplit[1]) / 60.0 +
                  parseFloat(raSplit[2]) / 3600.0;
  return - (longitude * 15 - 180);
}

/*
 * This function takes in a float in decimal degrees and returns a
 * string in DMS
 */
function decimalDegreesToString( dd )
{
  var h = parseInt(dd);
  var m, s;
  var stringdd = "" + h + ":";
  m = ((dd - h) * 60);
  stringdd += parseInt(m) + ":";
  s = (m - parseInt(m)) * 60;
  stringdd += s;
  return stringdd;
}
