// vim: set foldmethod=marker foldmarker={,} :

// Copyright 2013 Michigan Technological University
// Author: Bas Wijnen <bwijnen@mtu.edu>
// This design was developed as part of a project with
// the Michigan Tech Open Sustainability Technology Research Group
// http://www.appropedia.org/Category:MOST
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

var websocket, position = 0, speed = 0, calibration = 0;
var positionp, speedp, calibrationp;

function debug (text) {
	var t = document.createTextNode (text);
	var p = document.createElement ('p');
	p.appendChild (t);
	document.getElementById ('debug').appendChild (p);
}

function dump (obj) {
	var s = '';
	var i;
	for (i in obj)
		s += i + ': ' + obj[i] + '\n';
	return s;
}

function init () {
	positionp = document.getElementById ('pos');
	speedp = document.getElementById ('speed');
	calibrationp = document.getElementById ('calibration');
	websocket = new WebSocket ('ws://HOSTNAME');
	websocket.onmessage = message_cb;
	websocket.onclose = function () { alert ('The connection to the server was lost.'); };
	websocket.onopen = function () { websocket.send (JSON.stringify (['monitor'])); };
}

function settext (element, text) {
	element.replaceChild (document.createTextNode (text), element.firstChild);
}

function message_cb (data) {
	d = JSON.parse (data.data);
	if (d[0] == 'calibration') {
		calibration = d[1];
		settext (calibrationp, calibration);
	}
	else if (d[0] == 'position') {
		position = d[1];
		settext (positionp, position);
		positionp.style.background = '';
	}
	else if (d[0] == 'speed') {
		speed = d[1];
		settext (speedp, speed);
	}
	else if (d[0] == 'move') {
		// moving now.
		positionp.style.background = 'red';
	}
	else {
		debug ('unknown message: ' + d);
	}
}

function calibrate () {
	websocket.send (JSON.stringify (['calibrate', Number (document.getElementById ('calibration_input').value)]));
}

function setpos () {
	websocket.send (JSON.stringify (['setposition', Number (document.getElementById ('pos_input').value)]));
}

function setspeed () {
	websocket.send (JSON.stringify (['speed', Number (document.getElementById ('speed_input').value)]));
}

function push () {
	websocket.send (JSON.stringify (['move', -Number (document.getElementById ('amount').value)]));
}

function pull () {
	websocket.send (JSON.stringify (['move', Number (document.getElementById ('amount').value)]));
}

function sleep () {
	websocket.send (JSON.stringify (['sleep']));
}
