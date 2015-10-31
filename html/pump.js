// vim: set foldmethod=marker foldmarker={,} :

// Copyright 2013-2015 Michigan Technological University
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

var rpc, position = 0, speed = 0, calibration = 0;
var positionp, speedp, calibrationp;

var message_obj = {
	calibration: function(c) {
		calibration = c;
		settext(calibrationp, calibration);
	},
	position: function(p) {
		position = p;
		settext(positionp, position);
		positionp.style.background = '';
	},
	speed: function(s) {
		speed = s;
		settext(speedp, speed);
	},
	move: function() {
		// moving now.
		positionp.style.background = 'red';
	},
	'': function(msg) {
		console.warn('Unknown message:', msg);
	}
};

function init() {
	positionp = document.getElementById('pos');
	speedp = document.getElementById('speed');
	calibrationp = document.getElementById('calibration');
	rpc = Rpc(message_obj, function() { rpc.call('monitor'); }, function() { alert('The connection to the server was lost.'); });
}

function settext(element, text) {
	element.replaceChild(document.createTextNode(text), element.firstChild);
}

function calibrate() {
	rpc.call('calibrate', [Number(document.getElementById('calibration_input').value)]);
}

function setpos() {
	rpc.call('setposition', [Number(document.getElementById('pos_input').value)]);
}

function setspeed() {
	rpc.call('speed', [Number(document.getElementById('speed_input').value)]);
}

function push() {
	rpc.call('move', [-Number(document.getElementById('amount').value)]);
}

function pull() {
	rpc.call('move', [Number(document.getElementById('amount').value)]);
}

function sleep() {
	rpc.call('sleep');
}
