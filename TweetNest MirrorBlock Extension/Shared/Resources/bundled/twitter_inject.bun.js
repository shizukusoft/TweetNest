/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/scripts/inject/twitter-inject.ts");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./node_modules/uuid/dist/esm-browser/bytesToUuid.js":
/*!***********************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/bytesToUuid.js ***!
  \***********************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/**
 * Convert array of 16 byte values to UUID string format of the form:
 * XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
 */
var byteToHex = [];

for (var i = 0; i < 256; ++i) {
  byteToHex[i] = (i + 0x100).toString(16).substr(1);
}

function bytesToUuid(buf, offset) {
  var i = offset || 0;
  var bth = byteToHex; // join used to fix memory issue caused by concatenation: https://bugs.chromium.org/p/v8/issues/detail?id=3175#c4

  return [bth[buf[i++]], bth[buf[i++]], bth[buf[i++]], bth[buf[i++]], '-', bth[buf[i++]], bth[buf[i++]], '-', bth[buf[i++]], bth[buf[i++]], '-', bth[buf[i++]], bth[buf[i++]], '-', bth[buf[i++]], bth[buf[i++]], bth[buf[i++]], bth[buf[i++]], bth[buf[i++]], bth[buf[i++]]].join('');
}

/* harmony default export */ __webpack_exports__["default"] = (bytesToUuid);

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/index.js":
/*!*****************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/index.js ***!
  \*****************************************************/
/*! exports provided: v1, v3, v4, v5 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _v1_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./v1.js */ "./node_modules/uuid/dist/esm-browser/v1.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "v1", function() { return _v1_js__WEBPACK_IMPORTED_MODULE_0__["default"]; });

/* harmony import */ var _v3_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./v3.js */ "./node_modules/uuid/dist/esm-browser/v3.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "v3", function() { return _v3_js__WEBPACK_IMPORTED_MODULE_1__["default"]; });

/* harmony import */ var _v4_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./v4.js */ "./node_modules/uuid/dist/esm-browser/v4.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "v4", function() { return _v4_js__WEBPACK_IMPORTED_MODULE_2__["default"]; });

/* harmony import */ var _v5_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./v5.js */ "./node_modules/uuid/dist/esm-browser/v5.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "v5", function() { return _v5_js__WEBPACK_IMPORTED_MODULE_3__["default"]; });






/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/md5.js":
/*!***************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/md5.js ***!
  \***************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/*
 * Browser-compatible JavaScript MD5
 *
 * Modification of JavaScript MD5
 * https://github.com/blueimp/JavaScript-MD5
 *
 * Copyright 2011, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * https://opensource.org/licenses/MIT
 *
 * Based on
 * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
 * Digest Algorithm, as defined in RFC 1321.
 * Version 2.2 Copyright (C) Paul Johnston 1999 - 2009
 * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
 * Distributed under the BSD License
 * See http://pajhome.org.uk/crypt/md5 for more info.
 */
function md5(bytes) {
  if (typeof bytes == 'string') {
    var msg = unescape(encodeURIComponent(bytes)); // UTF8 escape

    bytes = new Array(msg.length);

    for (var i = 0; i < msg.length; i++) {
      bytes[i] = msg.charCodeAt(i);
    }
  }

  return md5ToHexEncodedArray(wordsToMd5(bytesToWords(bytes), bytes.length * 8));
}
/*
 * Convert an array of little-endian words to an array of bytes
 */


function md5ToHexEncodedArray(input) {
  var i;
  var x;
  var output = [];
  var length32 = input.length * 32;
  var hexTab = '0123456789abcdef';
  var hex;

  for (i = 0; i < length32; i += 8) {
    x = input[i >> 5] >>> i % 32 & 0xff;
    hex = parseInt(hexTab.charAt(x >>> 4 & 0x0f) + hexTab.charAt(x & 0x0f), 16);
    output.push(hex);
  }

  return output;
}
/*
 * Calculate the MD5 of an array of little-endian words, and a bit length.
 */


function wordsToMd5(x, len) {
  /* append padding */
  x[len >> 5] |= 0x80 << len % 32;
  x[(len + 64 >>> 9 << 4) + 14] = len;
  var i;
  var olda;
  var oldb;
  var oldc;
  var oldd;
  var a = 1732584193;
  var b = -271733879;
  var c = -1732584194;
  var d = 271733878;

  for (i = 0; i < x.length; i += 16) {
    olda = a;
    oldb = b;
    oldc = c;
    oldd = d;
    a = md5ff(a, b, c, d, x[i], 7, -680876936);
    d = md5ff(d, a, b, c, x[i + 1], 12, -389564586);
    c = md5ff(c, d, a, b, x[i + 2], 17, 606105819);
    b = md5ff(b, c, d, a, x[i + 3], 22, -1044525330);
    a = md5ff(a, b, c, d, x[i + 4], 7, -176418897);
    d = md5ff(d, a, b, c, x[i + 5], 12, 1200080426);
    c = md5ff(c, d, a, b, x[i + 6], 17, -1473231341);
    b = md5ff(b, c, d, a, x[i + 7], 22, -45705983);
    a = md5ff(a, b, c, d, x[i + 8], 7, 1770035416);
    d = md5ff(d, a, b, c, x[i + 9], 12, -1958414417);
    c = md5ff(c, d, a, b, x[i + 10], 17, -42063);
    b = md5ff(b, c, d, a, x[i + 11], 22, -1990404162);
    a = md5ff(a, b, c, d, x[i + 12], 7, 1804603682);
    d = md5ff(d, a, b, c, x[i + 13], 12, -40341101);
    c = md5ff(c, d, a, b, x[i + 14], 17, -1502002290);
    b = md5ff(b, c, d, a, x[i + 15], 22, 1236535329);
    a = md5gg(a, b, c, d, x[i + 1], 5, -165796510);
    d = md5gg(d, a, b, c, x[i + 6], 9, -1069501632);
    c = md5gg(c, d, a, b, x[i + 11], 14, 643717713);
    b = md5gg(b, c, d, a, x[i], 20, -373897302);
    a = md5gg(a, b, c, d, x[i + 5], 5, -701558691);
    d = md5gg(d, a, b, c, x[i + 10], 9, 38016083);
    c = md5gg(c, d, a, b, x[i + 15], 14, -660478335);
    b = md5gg(b, c, d, a, x[i + 4], 20, -405537848);
    a = md5gg(a, b, c, d, x[i + 9], 5, 568446438);
    d = md5gg(d, a, b, c, x[i + 14], 9, -1019803690);
    c = md5gg(c, d, a, b, x[i + 3], 14, -187363961);
    b = md5gg(b, c, d, a, x[i + 8], 20, 1163531501);
    a = md5gg(a, b, c, d, x[i + 13], 5, -1444681467);
    d = md5gg(d, a, b, c, x[i + 2], 9, -51403784);
    c = md5gg(c, d, a, b, x[i + 7], 14, 1735328473);
    b = md5gg(b, c, d, a, x[i + 12], 20, -1926607734);
    a = md5hh(a, b, c, d, x[i + 5], 4, -378558);
    d = md5hh(d, a, b, c, x[i + 8], 11, -2022574463);
    c = md5hh(c, d, a, b, x[i + 11], 16, 1839030562);
    b = md5hh(b, c, d, a, x[i + 14], 23, -35309556);
    a = md5hh(a, b, c, d, x[i + 1], 4, -1530992060);
    d = md5hh(d, a, b, c, x[i + 4], 11, 1272893353);
    c = md5hh(c, d, a, b, x[i + 7], 16, -155497632);
    b = md5hh(b, c, d, a, x[i + 10], 23, -1094730640);
    a = md5hh(a, b, c, d, x[i + 13], 4, 681279174);
    d = md5hh(d, a, b, c, x[i], 11, -358537222);
    c = md5hh(c, d, a, b, x[i + 3], 16, -722521979);
    b = md5hh(b, c, d, a, x[i + 6], 23, 76029189);
    a = md5hh(a, b, c, d, x[i + 9], 4, -640364487);
    d = md5hh(d, a, b, c, x[i + 12], 11, -421815835);
    c = md5hh(c, d, a, b, x[i + 15], 16, 530742520);
    b = md5hh(b, c, d, a, x[i + 2], 23, -995338651);
    a = md5ii(a, b, c, d, x[i], 6, -198630844);
    d = md5ii(d, a, b, c, x[i + 7], 10, 1126891415);
    c = md5ii(c, d, a, b, x[i + 14], 15, -1416354905);
    b = md5ii(b, c, d, a, x[i + 5], 21, -57434055);
    a = md5ii(a, b, c, d, x[i + 12], 6, 1700485571);
    d = md5ii(d, a, b, c, x[i + 3], 10, -1894986606);
    c = md5ii(c, d, a, b, x[i + 10], 15, -1051523);
    b = md5ii(b, c, d, a, x[i + 1], 21, -2054922799);
    a = md5ii(a, b, c, d, x[i + 8], 6, 1873313359);
    d = md5ii(d, a, b, c, x[i + 15], 10, -30611744);
    c = md5ii(c, d, a, b, x[i + 6], 15, -1560198380);
    b = md5ii(b, c, d, a, x[i + 13], 21, 1309151649);
    a = md5ii(a, b, c, d, x[i + 4], 6, -145523070);
    d = md5ii(d, a, b, c, x[i + 11], 10, -1120210379);
    c = md5ii(c, d, a, b, x[i + 2], 15, 718787259);
    b = md5ii(b, c, d, a, x[i + 9], 21, -343485551);
    a = safeAdd(a, olda);
    b = safeAdd(b, oldb);
    c = safeAdd(c, oldc);
    d = safeAdd(d, oldd);
  }

  return [a, b, c, d];
}
/*
 * Convert an array bytes to an array of little-endian words
 * Characters >255 have their high-byte silently ignored.
 */


function bytesToWords(input) {
  var i;
  var output = [];
  output[(input.length >> 2) - 1] = undefined;

  for (i = 0; i < output.length; i += 1) {
    output[i] = 0;
  }

  var length8 = input.length * 8;

  for (i = 0; i < length8; i += 8) {
    output[i >> 5] |= (input[i / 8] & 0xff) << i % 32;
  }

  return output;
}
/*
 * Add integers, wrapping at 2^32. This uses 16-bit operations internally
 * to work around bugs in some JS interpreters.
 */


function safeAdd(x, y) {
  var lsw = (x & 0xffff) + (y & 0xffff);
  var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
  return msw << 16 | lsw & 0xffff;
}
/*
 * Bitwise rotate a 32-bit number to the left.
 */


function bitRotateLeft(num, cnt) {
  return num << cnt | num >>> 32 - cnt;
}
/*
 * These functions implement the four basic operations the algorithm uses.
 */


function md5cmn(q, a, b, x, s, t) {
  return safeAdd(bitRotateLeft(safeAdd(safeAdd(a, q), safeAdd(x, t)), s), b);
}

function md5ff(a, b, c, d, x, s, t) {
  return md5cmn(b & c | ~b & d, a, b, x, s, t);
}

function md5gg(a, b, c, d, x, s, t) {
  return md5cmn(b & d | c & ~d, a, b, x, s, t);
}

function md5hh(a, b, c, d, x, s, t) {
  return md5cmn(b ^ c ^ d, a, b, x, s, t);
}

function md5ii(a, b, c, d, x, s, t) {
  return md5cmn(c ^ (b | ~d), a, b, x, s, t);
}

/* harmony default export */ __webpack_exports__["default"] = (md5);

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/rng.js":
/*!***************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/rng.js ***!
  \***************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return rng; });
// Unique ID creation requires a high quality random # generator. In the browser we therefore
// require the crypto API and do not support built-in fallback to lower quality random number
// generators (like Math.random()).
// getRandomValues needs to be invoked in a context where "this" is a Crypto implementation. Also,
// find the complete implementation of crypto (msCrypto) on IE11.
var getRandomValues = typeof crypto != 'undefined' && crypto.getRandomValues && crypto.getRandomValues.bind(crypto) || typeof msCrypto != 'undefined' && typeof msCrypto.getRandomValues == 'function' && msCrypto.getRandomValues.bind(msCrypto);
var rnds8 = new Uint8Array(16); // eslint-disable-line no-undef

function rng() {
  if (!getRandomValues) {
    throw new Error('crypto.getRandomValues() not supported. See https://github.com/uuidjs/uuid#getrandomvalues-not-supported');
  }

  return getRandomValues(rnds8);
}

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/sha1.js":
/*!****************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/sha1.js ***!
  \****************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
// Adapted from Chris Veness' SHA1 code at
// http://www.movable-type.co.uk/scripts/sha1.html
function f(s, x, y, z) {
  switch (s) {
    case 0:
      return x & y ^ ~x & z;

    case 1:
      return x ^ y ^ z;

    case 2:
      return x & y ^ x & z ^ y & z;

    case 3:
      return x ^ y ^ z;
  }
}

function ROTL(x, n) {
  return x << n | x >>> 32 - n;
}

function sha1(bytes) {
  var K = [0x5a827999, 0x6ed9eba1, 0x8f1bbcdc, 0xca62c1d6];
  var H = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0];

  if (typeof bytes == 'string') {
    var msg = unescape(encodeURIComponent(bytes)); // UTF8 escape

    bytes = new Array(msg.length);

    for (var i = 0; i < msg.length; i++) {
      bytes[i] = msg.charCodeAt(i);
    }
  }

  bytes.push(0x80);
  var l = bytes.length / 4 + 2;
  var N = Math.ceil(l / 16);
  var M = new Array(N);

  for (var i = 0; i < N; i++) {
    M[i] = new Array(16);

    for (var j = 0; j < 16; j++) {
      M[i][j] = bytes[i * 64 + j * 4] << 24 | bytes[i * 64 + j * 4 + 1] << 16 | bytes[i * 64 + j * 4 + 2] << 8 | bytes[i * 64 + j * 4 + 3];
    }
  }

  M[N - 1][14] = (bytes.length - 1) * 8 / Math.pow(2, 32);
  M[N - 1][14] = Math.floor(M[N - 1][14]);
  M[N - 1][15] = (bytes.length - 1) * 8 & 0xffffffff;

  for (var i = 0; i < N; i++) {
    var W = new Array(80);

    for (var t = 0; t < 16; t++) {
      W[t] = M[i][t];
    }

    for (var t = 16; t < 80; t++) {
      W[t] = ROTL(W[t - 3] ^ W[t - 8] ^ W[t - 14] ^ W[t - 16], 1);
    }

    var a = H[0];
    var b = H[1];
    var c = H[2];
    var d = H[3];
    var e = H[4];

    for (var t = 0; t < 80; t++) {
      var s = Math.floor(t / 20);
      var T = ROTL(a, 5) + f(s, b, c, d) + e + K[s] + W[t] >>> 0;
      e = d;
      d = c;
      c = ROTL(b, 30) >>> 0;
      b = a;
      a = T;
    }

    H[0] = H[0] + a >>> 0;
    H[1] = H[1] + b >>> 0;
    H[2] = H[2] + c >>> 0;
    H[3] = H[3] + d >>> 0;
    H[4] = H[4] + e >>> 0;
  }

  return [H[0] >> 24 & 0xff, H[0] >> 16 & 0xff, H[0] >> 8 & 0xff, H[0] & 0xff, H[1] >> 24 & 0xff, H[1] >> 16 & 0xff, H[1] >> 8 & 0xff, H[1] & 0xff, H[2] >> 24 & 0xff, H[2] >> 16 & 0xff, H[2] >> 8 & 0xff, H[2] & 0xff, H[3] >> 24 & 0xff, H[3] >> 16 & 0xff, H[3] >> 8 & 0xff, H[3] & 0xff, H[4] >> 24 & 0xff, H[4] >> 16 & 0xff, H[4] >> 8 & 0xff, H[4] & 0xff];
}

/* harmony default export */ __webpack_exports__["default"] = (sha1);

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/v1.js":
/*!**************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/v1.js ***!
  \**************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _rng_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./rng.js */ "./node_modules/uuid/dist/esm-browser/rng.js");
/* harmony import */ var _bytesToUuid_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./bytesToUuid.js */ "./node_modules/uuid/dist/esm-browser/bytesToUuid.js");

 // **`v1()` - Generate time-based UUID**
//
// Inspired by https://github.com/LiosK/UUID.js
// and http://docs.python.org/library/uuid.html

var _nodeId;

var _clockseq; // Previous uuid creation time


var _lastMSecs = 0;
var _lastNSecs = 0; // See https://github.com/uuidjs/uuid for API details

function v1(options, buf, offset) {
  var i = buf && offset || 0;
  var b = buf || [];
  options = options || {};
  var node = options.node || _nodeId;
  var clockseq = options.clockseq !== undefined ? options.clockseq : _clockseq; // node and clockseq need to be initialized to random values if they're not
  // specified.  We do this lazily to minimize issues related to insufficient
  // system entropy.  See #189

  if (node == null || clockseq == null) {
    var seedBytes = options.random || (options.rng || _rng_js__WEBPACK_IMPORTED_MODULE_0__["default"])();

    if (node == null) {
      // Per 4.5, create and 48-bit node id, (47 random bits + multicast bit = 1)
      node = _nodeId = [seedBytes[0] | 0x01, seedBytes[1], seedBytes[2], seedBytes[3], seedBytes[4], seedBytes[5]];
    }

    if (clockseq == null) {
      // Per 4.2.2, randomize (14 bit) clockseq
      clockseq = _clockseq = (seedBytes[6] << 8 | seedBytes[7]) & 0x3fff;
    }
  } // UUID timestamps are 100 nano-second units since the Gregorian epoch,
  // (1582-10-15 00:00).  JSNumbers aren't precise enough for this, so
  // time is handled internally as 'msecs' (integer milliseconds) and 'nsecs'
  // (100-nanoseconds offset from msecs) since unix epoch, 1970-01-01 00:00.


  var msecs = options.msecs !== undefined ? options.msecs : new Date().getTime(); // Per 4.2.1.2, use count of uuid's generated during the current clock
  // cycle to simulate higher resolution clock

  var nsecs = options.nsecs !== undefined ? options.nsecs : _lastNSecs + 1; // Time since last uuid creation (in msecs)

  var dt = msecs - _lastMSecs + (nsecs - _lastNSecs) / 10000; // Per 4.2.1.2, Bump clockseq on clock regression

  if (dt < 0 && options.clockseq === undefined) {
    clockseq = clockseq + 1 & 0x3fff;
  } // Reset nsecs if clock regresses (new clockseq) or we've moved onto a new
  // time interval


  if ((dt < 0 || msecs > _lastMSecs) && options.nsecs === undefined) {
    nsecs = 0;
  } // Per 4.2.1.2 Throw error if too many uuids are requested


  if (nsecs >= 10000) {
    throw new Error("uuid.v1(): Can't create more than 10M uuids/sec");
  }

  _lastMSecs = msecs;
  _lastNSecs = nsecs;
  _clockseq = clockseq; // Per 4.1.4 - Convert from unix epoch to Gregorian epoch

  msecs += 12219292800000; // `time_low`

  var tl = ((msecs & 0xfffffff) * 10000 + nsecs) % 0x100000000;
  b[i++] = tl >>> 24 & 0xff;
  b[i++] = tl >>> 16 & 0xff;
  b[i++] = tl >>> 8 & 0xff;
  b[i++] = tl & 0xff; // `time_mid`

  var tmh = msecs / 0x100000000 * 10000 & 0xfffffff;
  b[i++] = tmh >>> 8 & 0xff;
  b[i++] = tmh & 0xff; // `time_high_and_version`

  b[i++] = tmh >>> 24 & 0xf | 0x10; // include version

  b[i++] = tmh >>> 16 & 0xff; // `clock_seq_hi_and_reserved` (Per 4.2.2 - include variant)

  b[i++] = clockseq >>> 8 | 0x80; // `clock_seq_low`

  b[i++] = clockseq & 0xff; // `node`

  for (var n = 0; n < 6; ++n) {
    b[i + n] = node[n];
  }

  return buf ? buf : Object(_bytesToUuid_js__WEBPACK_IMPORTED_MODULE_1__["default"])(b);
}

/* harmony default export */ __webpack_exports__["default"] = (v1);

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/v3.js":
/*!**************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/v3.js ***!
  \**************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _v35_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./v35.js */ "./node_modules/uuid/dist/esm-browser/v35.js");
/* harmony import */ var _md5_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./md5.js */ "./node_modules/uuid/dist/esm-browser/md5.js");


var v3 = Object(_v35_js__WEBPACK_IMPORTED_MODULE_0__["default"])('v3', 0x30, _md5_js__WEBPACK_IMPORTED_MODULE_1__["default"]);
/* harmony default export */ __webpack_exports__["default"] = (v3);

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/v35.js":
/*!***************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/v35.js ***!
  \***************************************************/
/*! exports provided: DNS, URL, default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "DNS", function() { return DNS; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "URL", function() { return URL; });
/* harmony import */ var _bytesToUuid_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./bytesToUuid.js */ "./node_modules/uuid/dist/esm-browser/bytesToUuid.js");


function uuidToBytes(uuid) {
  // Note: We assume we're being passed a valid uuid string
  var bytes = [];
  uuid.replace(/[a-fA-F0-9]{2}/g, function (hex) {
    bytes.push(parseInt(hex, 16));
  });
  return bytes;
}

function stringToBytes(str) {
  str = unescape(encodeURIComponent(str)); // UTF8 escape

  var bytes = new Array(str.length);

  for (var i = 0; i < str.length; i++) {
    bytes[i] = str.charCodeAt(i);
  }

  return bytes;
}

var DNS = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
var URL = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';
/* harmony default export */ __webpack_exports__["default"] = (function (name, version, hashfunc) {
  var generateUUID = function generateUUID(value, namespace, buf, offset) {
    var off = buf && offset || 0;
    if (typeof value == 'string') value = stringToBytes(value);
    if (typeof namespace == 'string') namespace = uuidToBytes(namespace);
    if (!Array.isArray(value)) throw TypeError('value must be an array of bytes');
    if (!Array.isArray(namespace) || namespace.length !== 16) throw TypeError('namespace must be uuid string or an Array of 16 byte values'); // Per 4.3

    var bytes = hashfunc(namespace.concat(value));
    bytes[6] = bytes[6] & 0x0f | version;
    bytes[8] = bytes[8] & 0x3f | 0x80;

    if (buf) {
      for (var idx = 0; idx < 16; ++idx) {
        buf[off + idx] = bytes[idx];
      }
    }

    return buf || Object(_bytesToUuid_js__WEBPACK_IMPORTED_MODULE_0__["default"])(bytes);
  }; // Function#name is not settable on some platforms (#270)


  try {
    generateUUID.name = name;
  } catch (err) {} // For CommonJS default export support


  generateUUID.DNS = DNS;
  generateUUID.URL = URL;
  return generateUUID;
});

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/v4.js":
/*!**************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/v4.js ***!
  \**************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _rng_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./rng.js */ "./node_modules/uuid/dist/esm-browser/rng.js");
/* harmony import */ var _bytesToUuid_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./bytesToUuid.js */ "./node_modules/uuid/dist/esm-browser/bytesToUuid.js");



function v4(options, buf, offset) {
  var i = buf && offset || 0;

  if (typeof options == 'string') {
    buf = options === 'binary' ? new Array(16) : null;
    options = null;
  }

  options = options || {};
  var rnds = options.random || (options.rng || _rng_js__WEBPACK_IMPORTED_MODULE_0__["default"])(); // Per 4.4, set bits for version and `clock_seq_hi_and_reserved`

  rnds[6] = rnds[6] & 0x0f | 0x40;
  rnds[8] = rnds[8] & 0x3f | 0x80; // Copy bytes to buffer, if provided

  if (buf) {
    for (var ii = 0; ii < 16; ++ii) {
      buf[i + ii] = rnds[ii];
    }
  }

  return buf || Object(_bytesToUuid_js__WEBPACK_IMPORTED_MODULE_1__["default"])(rnds);
}

/* harmony default export */ __webpack_exports__["default"] = (v4);

/***/ }),

/***/ "./node_modules/uuid/dist/esm-browser/v5.js":
/*!**************************************************!*\
  !*** ./node_modules/uuid/dist/esm-browser/v5.js ***!
  \**************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _v35_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./v35.js */ "./node_modules/uuid/dist/esm-browser/v35.js");
/* harmony import */ var _sha1_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./sha1.js */ "./node_modules/uuid/dist/esm-browser/sha1.js");


var v5 = Object(_v35_js__WEBPACK_IMPORTED_MODULE_0__["default"])('v5', 0x50, _sha1_js__WEBPACK_IMPORTED_MODULE_1__["default"]);
/* harmony default export */ __webpack_exports__["default"] = (v5);

/***/ }),

/***/ "./src/scripts/event-names.ts":
/*!************************************!*\
  !*** ./src/scripts/event-names.ts ***!
  \************************************/
/*! exports provided: TWEET, USERCELL, DM */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TWEET", function() { return TWEET; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "USERCELL", function() { return USERCELL; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "DM", function() { return DM; });
const TWEET = 'MirrorBlock<-Tweet';
const USERCELL = 'MirrorBlock<-UserCell';
const DM = 'MirrorBlock<-DMConversation';


/***/ }),

/***/ "./src/scripts/inject/twitter-inject.ts":
/*!**********************************************!*\
  !*** ./src/scripts/inject/twitter-inject.ts ***!
  \**********************************************/
/*! exports provided: initialize */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "initialize", function() { return initialize; });
/* harmony import */ var _twitter_inject_redux_dispatcher__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./twitter-inject/redux-dispatcher */ "./src/scripts/inject/twitter-inject/redux-dispatcher.ts");
/* harmony import */ var _twitter_inject_redux_fetchter__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./twitter-inject/redux-fetchter */ "./src/scripts/inject/twitter-inject/redux-fetchter.ts");
/* harmony import */ var _twitter_inject_detector__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./twitter-inject/detector */ "./src/scripts/inject/twitter-inject/detector.ts");
/* harmony import */ var _twitter_inject_inject_common__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./twitter-inject/inject-common */ "./src/scripts/inject/twitter-inject/inject-common.ts");




function isReduxStore(something) {
    if (!something) {
        return false;
    }
    if (typeof something !== 'object') {
        return false;
    }
    if (typeof something.getState !== 'function') {
        return false;
    }
    if (typeof something.dispatch !== 'function') {
        return false;
    }
    if (typeof something.subscribe !== 'function') {
        return false;
    }
    return true;
}
function findReduxStore(reactRoot) {
    const rEventHandler = Object(_twitter_inject_inject_common__WEBPACK_IMPORTED_MODULE_3__["getReactEventHandler"])(reactRoot.children[0]);
    const reduxStore = rEventHandler.children.props.children.props.store;
    if (!isReduxStore(reduxStore)) {
        throw new Error('fail to find redux store');
    }
    return reduxStore;
}
function inject(reactRoot) {
    const reduxStore = findReduxStore(reactRoot);
    _twitter_inject_redux_dispatcher__WEBPACK_IMPORTED_MODULE_0__["listenEvent"](reduxStore);
    _twitter_inject_redux_fetchter__WEBPACK_IMPORTED_MODULE_1__["listenEvent"](reduxStore);
    _twitter_inject_detector__WEBPACK_IMPORTED_MODULE_2__["observe"](reactRoot, reduxStore);
}
function initialize() {
    const reactRoot = document.getElementById('react-root');
    if ('_reactRootContainer' in reactRoot) {
        inject(reactRoot);
    } else {
        setTimeout(initialize, 500);
    }
}
requestIdleCallback(initialize, {
    timeout: 10000
});


/***/ }),

/***/ "./src/scripts/inject/twitter-inject/detector.ts":
/*!*******************************************************!*\
  !*** ./src/scripts/inject/twitter-inject/detector.ts ***!
  \*******************************************************/
/*! exports provided: observe */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "observe", function() { return observe; });
/* harmony import */ var _inject_common__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./inject-common */ "./src/scripts/inject/twitter-inject/inject-common.ts");
/* harmony import */ var _scripts_event_names__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/event-names */ "./src/scripts/event-names.ts");


const touchedElems = new WeakSet();
function findTweetIdFromElement(elem) {
    if (!elem.matches('[data-testid=tweet]')) {
        throw new Error('unexpected non-tweet elem?');
    }
    const article = elem.closest('article[role=article]');
    const permalinks = article.querySelectorAll('a[href^="/"][href*="/status/"');
    for (const plink of permalinks){
        const tweetIdMatch = /\/status\/(\d+)/.exec(plink.pathname);
        const tweetId = tweetIdMatch[1];
        const firstChild = plink.firstElementChild;
        if ((firstChild === null || firstChild === void 0 ? void 0 : firstChild.tagName) === 'TIME') {
            return tweetId;
        }
        const viaLabel = article.querySelector('a[href="https://help.twitter.com/using-twitter/how-to-tweet#source-labels"]');
        if (viaLabel === null || viaLabel === void 0 ? void 0 : viaLabel.parentElement.contains(plink)) {
            return tweetId;
        }
    }
    // 신고한 트윗이나 안 보이는 트윗 등의 경우, 여기서 트윗 ID를 못 찾는다.
    return null;
}
function findUserIdFromElement(elem) {
    if (!elem.matches('[data-testid=UserCell')) {
        throw new Error('unexpected non-usercell elem?');
    }
    const btn = elem.querySelector('[role=button][data-testid]');
    // 자기 자신의 UserCell은 아무 버튼도 없다.
    // 또한 여러 계정 로그인이 되어있을 때, 하단의 계정전환 버튼을 누를 때
    // 나타나는 계정메뉴 항목도 UserCell로 이루어져있음
    if (!btn) {
        return null;
    }
    const userIdMatch = /^(\d+)/.exec(btn.getAttribute('data-testid'));
    if (!userIdMatch) {
        return null;
    }
    const userId = userIdMatch[1];
    return userId;
}
function getTweetEntityById(state, tweetId) {
    const entities = state.entities.tweets.entities;
    for (const entity_ of Object.values(entities)){
        const entity = entity_;
        if (entity.id_str.toLowerCase() === tweetId) {
            return entity;
        }
    }
    return null;
}
function getUserEntityById(state, userId) {
    const entities = state.entities.users.entities;
    return entities[userId] || null;
}
function inspectTweetElement(state, elem) {
    const tweetId = findTweetIdFromElement(elem);
    if (!tweetId) {
        return null;
    }
    const tweetEntity = getTweetEntityById(state, tweetId);
    if (!tweetEntity) {
        return null;
    }
    const user = getUserEntityById(state, tweetEntity.user);
    if (!user) {
        return null;
    }
    let quotedTweet = null;
    if (tweetEntity.is_quote_status) {
        const quotedTweetEntity = getTweetEntityById(state, tweetEntity.quoted_status);
        if (quotedTweetEntity) {
            const user1 = getUserEntityById(state, quotedTweetEntity.user);
            if (user1) {
                quotedTweet = Object.assign({
                }, quotedTweetEntity, {
                    user: user1
                });
            }
        }
    }
    const tweet = Object.assign({
    }, tweetEntity, {
        user,
        quoted_status: quotedTweet
    });
    return tweet;
}
function inspectUserCellElement(state, elem) {
    const userId = findUserIdFromElement(elem);
    if (!userId) {
        return null;
    }
    const user = getUserEntityById(state, userId);
    if (!user) {
        return null;
    }
    return user;
}
function userCellDetector(state) {
    const userCells = document.querySelectorAll('[data-testid=UserCell]');
    for (const elem of userCells){
        if (touchedElems.has(elem)) {
            continue;
        }
        touchedElems.add(elem);
        const user = inspectUserCellElement(state, elem);
        if (!user) {
            continue;
        }
        const event = new CustomEvent(_scripts_event_names__WEBPACK_IMPORTED_MODULE_1__["USERCELL"], {
            bubbles: true,
            detail: {
                user
            }
        });
        const intObserver = new IntersectionObserver((entries, observer)=>{
            for (const ent of entries){
                if (!ent.isIntersecting) {
                    continue;
                }
                observer.unobserve(ent.target);
                requestIdleCallback(()=>elem.dispatchEvent(event)
                , {
                    timeout: 1000
                });
            }
        });
        intObserver.observe(elem);
    }
}
function sendDMConversationsToExtension() {
    const convElems = document.querySelectorAll('[data-testid=conversation]');
    for (const elem of convElems){
        const parent = elem.parentElement;
        const rEventHandler = Object(_inject_common__WEBPACK_IMPORTED_MODULE_0__["getReactEventHandler"])(parent);
        const convId = Object(_inject_common__WEBPACK_IMPORTED_MODULE_0__["dig"])(()=>rEventHandler.children[0].props.conversationId
        );
        if (typeof convId !== 'string') {
            throw new Error('failed to get conv. id');
        }
        elem.setAttribute('data-mirrorblock-conversation-id', convId);
        const customEvent = new CustomEvent(_scripts_event_names__WEBPACK_IMPORTED_MODULE_1__["DM"], {
            detail: {
                convId
            }
        });
        document.dispatchEvent(customEvent);
    }
}
function tweetDetector(state) {
    const tweetElems = document.querySelectorAll('[data-testid=tweet]');
    for (const elem of tweetElems){
        // Tree-UI 등에서, 트윗을 접었다 펴면 붙었던 뱃지가 사라져 다시 붙여야 함
        // 그냥 중복처리를 허용하기로?
        // if (touchedElems.has(elem)) {
        //   continue
        // }
        // touchedElems.add(elem)
        const tweet = inspectTweetElement(state, elem);
        if (!tweet) {
            continue;
        }
        const event = new CustomEvent(_scripts_event_names__WEBPACK_IMPORTED_MODULE_1__["TWEET"], {
            bubbles: true,
            detail: {
                tweet
            }
        });
        const intObserver = new IntersectionObserver((entries, observer)=>{
            for (const ent of entries){
                if (!ent.isIntersecting) {
                    continue;
                }
                observer.unobserve(ent.target);
                requestIdleCallback(()=>elem.dispatchEvent(event)
                , {
                    timeout: 1000
                });
            }
        });
        intObserver.observe(elem);
    }
}
function observe(reactRoot, reduxStore) {
    new MutationObserver(()=>{
        const state = reduxStore.getState();
        tweetDetector(state);
        userCellDetector(state);
        sendDMConversationsToExtension();
    }).observe(reactRoot, {
        subtree: true,
        childList: true
    });
}


/***/ }),

/***/ "./src/scripts/inject/twitter-inject/inject-common.ts":
/*!************************************************************!*\
  !*** ./src/scripts/inject/twitter-inject/inject-common.ts ***!
  \************************************************************/
/*! exports provided: dig, getReactEventHandler */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "dig", function() { return dig; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getReactEventHandler", function() { return getReactEventHandler; });
function dig(obj) {
    try {
        return obj();
    } catch (err) {
        if (err instanceof TypeError) {
            return null;
        } else {
            throw err;
        }
    }
}
function getReactEventHandler(target) {
    const key = Object.keys(target).filter((k)=>k.startsWith('__reactEventHandlers')
    ).pop();
    return key ? target[key] : null;
}


/***/ }),

/***/ "./src/scripts/inject/twitter-inject/redux-dispatcher.ts":
/*!***************************************************************!*\
  !*** ./src/scripts/inject/twitter-inject/redux-dispatcher.ts ***!
  \***************************************************************/
/*! exports provided: listenEvent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "listenEvent", function() { return listenEvent; });
/* harmony import */ var uuid__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! uuid */ "./node_modules/uuid/dist/esm-browser/index.js");

function addEvent(name, callback) {
    document.addEventListener(`MirrorBlock->${name}`, (event)=>{
        const customEvent = event;
        callback(customEvent);
    });
}
function listenEvent(reduxStore) {
    addEvent('insertSingleUserIntoStore', (event)=>{
        const user = event.detail.user;
        reduxStore.dispatch({
            type: 'rweb/entities/ADD_ENTITIES',
            payload: {
                users: {
                    [user.id_str]: user
                }
            }
        });
    });
    addEvent('insertMultipleUsersIntoStore', (event)=>{
        const users = event.detail.users;
        reduxStore.dispatch({
            type: 'rweb/entities/ADD_ENTITIES',
            payload: {
                users
            }
        });
    });
    addEvent('afterBlockUser', (event)=>{
        const { user  } = event.detail;
        const userId = user.id_str;
        const uniqId = Object(uuid__WEBPACK_IMPORTED_MODULE_0__["v1"])();
        reduxStore.dispatch({
            type: 'rweb/blockedUsers/BLOCK_REQUEST',
            optimist: {
                id: uniqId,
                type: 'BEGIN'
            },
            meta: {
                userId
            }
        });
    });
    addEvent('toastMessage', (event)=>{
        const { text  } = event.detail;
        reduxStore.dispatch({
            type: 'rweb/toasts/ADD_TOAST',
            payload: {
                text
            }
        });
    });
}


/***/ }),

/***/ "./src/scripts/inject/twitter-inject/redux-fetchter.ts":
/*!*************************************************************!*\
  !*** ./src/scripts/inject/twitter-inject/redux-fetchter.ts ***!
  \*************************************************************/
/*! exports provided: listenEvent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "listenEvent", function() { return listenEvent; });
/* harmony import */ var _inject_common__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./inject-common */ "./src/scripts/inject/twitter-inject/inject-common.ts");

function addEventWithResponse(name, callback) {
    document.addEventListener(`MirrorBlock-->${name}`, (event)=>{
        const customEvent = event;
        const { nonce  } = customEvent.detail;
        const response = callback(customEvent);
        const responseEvent = new CustomEvent(`MirrorBlock<--${name}.${nonce}`, {
            detail: response
        });
        document.dispatchEvent(responseEvent);
    });
}
function listenEvent(reduxStore) {
    addEventWithResponse('getMultipleUsersByIds', (event)=>{
        const state = reduxStore.getState();
        const { userIds  } = event.detail;
        const result = {
        };
        const userEntities = Object(_inject_common__WEBPACK_IMPORTED_MODULE_0__["dig"])(()=>state.entities.users.entities
        ) || [];
        for (const userId of userIds){
            result[userId] = userEntities[userId];
        }
        return result;
    });
    addEventWithResponse('getUserByName', (event)=>{
        const state = reduxStore.getState();
        const { userName  } = event.detail;
        const targetUserName = userName.toLowerCase();
        const userEntities = Object(_inject_common__WEBPACK_IMPORTED_MODULE_0__["dig"])(()=>state.entities.users.entities
        ) || [];
        for (const userEntity of Object.values(userEntities)){
            const name = userEntity.screen_name.toLowerCase();
            if (targetUserName === name) {
                return userEntity;
            }
        }
        return null;
    });
    addEventWithResponse('getDMData', (event)=>{
        const state = reduxStore.getState();
        const { convId  } = event.detail;
        const conversations = Object(_inject_common__WEBPACK_IMPORTED_MODULE_0__["dig"])(()=>state.directMessages.conversations
        );
        if (!conversations) {
            return null;
        }
        const convData = Object(_inject_common__WEBPACK_IMPORTED_MODULE_0__["dig"])(()=>conversations[convId]
        );
        return convData || null;
    });
}


/***/ })

/******/ });
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL3V1aWQvZGlzdC9lc20tYnJvd3Nlci9ieXRlc1RvVXVpZC5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvdXVpZC9kaXN0L2VzbS1icm93c2VyL2luZGV4LmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy91dWlkL2Rpc3QvZXNtLWJyb3dzZXIvbWQ1LmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy91dWlkL2Rpc3QvZXNtLWJyb3dzZXIvcm5nLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy91dWlkL2Rpc3QvZXNtLWJyb3dzZXIvc2hhMS5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvdXVpZC9kaXN0L2VzbS1icm93c2VyL3YxLmpzIiwid2VicGFjazovLy8uL25vZGVfbW9kdWxlcy91dWlkL2Rpc3QvZXNtLWJyb3dzZXIvdjMuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL3V1aWQvZGlzdC9lc20tYnJvd3Nlci92MzUuanMiLCJ3ZWJwYWNrOi8vLy4vbm9kZV9tb2R1bGVzL3V1aWQvZGlzdC9lc20tYnJvd3Nlci92NC5qcyIsIndlYnBhY2s6Ly8vLi9ub2RlX21vZHVsZXMvdXVpZC9kaXN0L2VzbS1icm93c2VyL3Y1LmpzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL2V2ZW50LW5hbWVzLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL2luamVjdC90d2l0dGVyLWluamVjdC50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9pbmplY3QvdHdpdHRlci1pbmplY3QvZGV0ZWN0b3IudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvaW5qZWN0L3R3aXR0ZXItaW5qZWN0L2luamVjdC1jb21tb24udHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvaW5qZWN0L3R3aXR0ZXItaW5qZWN0L3JlZHV4LWRpc3BhdGNoZXIudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvaW5qZWN0L3R3aXR0ZXItaW5qZWN0L3JlZHV4LWZldGNodGVyLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7UUFBQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTs7O1FBR0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBLDBDQUEwQyxnQ0FBZ0M7UUFDMUU7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQSx3REFBd0Qsa0JBQWtCO1FBQzFFO1FBQ0EsaURBQWlELGNBQWM7UUFDL0Q7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBLHlDQUF5QyxpQ0FBaUM7UUFDMUUsZ0hBQWdILG1CQUFtQixFQUFFO1FBQ3JJO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMkJBQTJCLDBCQUEwQixFQUFFO1FBQ3ZELGlDQUFpQyxlQUFlO1FBQ2hEO1FBQ0E7UUFDQTs7UUFFQTtRQUNBLHNEQUFzRCwrREFBK0Q7O1FBRXJIO1FBQ0E7OztRQUdBO1FBQ0E7Ozs7Ozs7Ozs7Ozs7QUNsRkE7QUFBQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBLGVBQWUsU0FBUztBQUN4QjtBQUNBOztBQUVBO0FBQ0E7QUFDQSxzQkFBc0I7O0FBRXRCO0FBQ0E7O0FBRWUsMEVBQVcsRTs7Ozs7Ozs7Ozs7O0FDakIxQjtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUF3QztBQUNBO0FBQ0E7Ozs7Ozs7Ozs7Ozs7QUNGeEM7QUFBQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBLGtEQUFrRDs7QUFFbEQ7O0FBRUEsbUJBQW1CLGdCQUFnQjtBQUNuQztBQUNBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7O0FBR0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7O0FBRUEsYUFBYSxjQUFjO0FBQzNCO0FBQ0E7QUFDQTtBQUNBOztBQUVBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7OztBQUdBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOztBQUVBLGFBQWEsY0FBYztBQUMzQjtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7OztBQUdBO0FBQ0E7QUFDQTtBQUNBOztBQUVBLGFBQWEsbUJBQW1CO0FBQ2hDO0FBQ0E7O0FBRUE7O0FBRUEsYUFBYSxhQUFhO0FBQzFCO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOzs7QUFHQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBOzs7QUFHQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7OztBQUdBO0FBQ0E7QUFDQTs7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QUksWUFBWSxDQUFDLE1BQU07O2VBRS9CLE1BQU07O0lBRWYsb0JBQW9CLEVBQUMsYUFBZSxJQUFFLEtBQUs7Y0FDbkMsS0FBSyxHQUFHLFVBQVUsQ0FBQyxRQUFRO2dCQUN6QixRQUFRLE1BQUssS0FBSyxDQUFDLE1BQU07Y0FDM0IsY0FBYyxHQUFHLFFBQVEsQ0FBQyxXQUFXO2NBQ3JDLFlBQVksR0FBd0IsMERBQUcsS0FBTyxLQUFLLENBQUMsUUFBUSxDQUFDLEtBQUssQ0FBQyxRQUFROzttQkFDdEUsVUFBVSxJQUFJLE1BQU0sQ0FBQyxNQUFNLENBQUMsWUFBWTtrQkFDM0MsSUFBSSxHQUFHLFVBQVUsQ0FBQyxXQUFXLENBQUMsV0FBVztnQkFDM0MsY0FBYyxLQUFLLElBQUk7dUJBQ2xCLFVBQVU7OztlQUdkLElBQUk7O0lBRWIsb0JBQW9CLEVBQUMsU0FBVyxJQUFFLEtBQUs7Y0FDL0IsS0FBSyxHQUFHLFVBQVUsQ0FBQyxRQUFRO2dCQUN6QixNQUFNLE1BQUssS0FBSyxDQUFDLE1BQU07Y0FDekIsYUFBYSxHQUFHLDBEQUFHLEtBQU8sS0FBSyxDQUFDLGNBQWMsQ0FBQyxhQUFhOzthQUM3RCxhQUFhO21CQUNULElBQUk7O2NBRVAsUUFBUSxHQUFHLDBEQUFHLEtBQU8sYUFBYSxDQUFDLE1BQU07O2VBQ3hDLFFBQVEsSUFBSSxJQUFJIiwiZmlsZSI6InR3aXR0ZXJfaW5qZWN0LmJ1bi5qcyIsInNvdXJjZXNDb250ZW50IjpbIiBcdC8vIFRoZSBtb2R1bGUgY2FjaGVcbiBcdHZhciBpbnN0YWxsZWRNb2R1bGVzID0ge307XG5cbiBcdC8vIFRoZSByZXF1aXJlIGZ1bmN0aW9uXG4gXHRmdW5jdGlvbiBfX3dlYnBhY2tfcmVxdWlyZV9fKG1vZHVsZUlkKSB7XG5cbiBcdFx0Ly8gQ2hlY2sgaWYgbW9kdWxlIGlzIGluIGNhY2hlXG4gXHRcdGlmKGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdKSB7XG4gXHRcdFx0cmV0dXJuIGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdLmV4cG9ydHM7XG4gXHRcdH1cbiBcdFx0Ly8gQ3JlYXRlIGEgbmV3IG1vZHVsZSAoYW5kIHB1dCBpdCBpbnRvIHRoZSBjYWNoZSlcbiBcdFx0dmFyIG1vZHVsZSA9IGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdID0ge1xuIFx0XHRcdGk6IG1vZHVsZUlkLFxuIFx0XHRcdGw6IGZhbHNlLFxuIFx0XHRcdGV4cG9ydHM6IHt9XG4gXHRcdH07XG5cbiBcdFx0Ly8gRXhlY3V0ZSB0aGUgbW9kdWxlIGZ1bmN0aW9uXG4gXHRcdG1vZHVsZXNbbW9kdWxlSWRdLmNhbGwobW9kdWxlLmV4cG9ydHMsIG1vZHVsZSwgbW9kdWxlLmV4cG9ydHMsIF9fd2VicGFja19yZXF1aXJlX18pO1xuXG4gXHRcdC8vIEZsYWcgdGhlIG1vZHVsZSBhcyBsb2FkZWRcbiBcdFx0bW9kdWxlLmwgPSB0cnVlO1xuXG4gXHRcdC8vIFJldHVybiB0aGUgZXhwb3J0cyBvZiB0aGUgbW9kdWxlXG4gXHRcdHJldHVybiBtb2R1bGUuZXhwb3J0cztcbiBcdH1cblxuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZXMgb2JqZWN0IChfX3dlYnBhY2tfbW9kdWxlc19fKVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5tID0gbW9kdWxlcztcblxuIFx0Ly8gZXhwb3NlIHRoZSBtb2R1bGUgY2FjaGVcbiBcdF9fd2VicGFja19yZXF1aXJlX18uYyA9IGluc3RhbGxlZE1vZHVsZXM7XG5cbiBcdC8vIGRlZmluZSBnZXR0ZXIgZnVuY3Rpb24gZm9yIGhhcm1vbnkgZXhwb3J0c1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5kID0gZnVuY3Rpb24oZXhwb3J0cywgbmFtZSwgZ2V0dGVyKSB7XG4gXHRcdGlmKCFfX3dlYnBhY2tfcmVxdWlyZV9fLm8oZXhwb3J0cywgbmFtZSkpIHtcbiBcdFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgbmFtZSwgeyBlbnVtZXJhYmxlOiB0cnVlLCBnZXQ6IGdldHRlciB9KTtcbiBcdFx0fVxuIFx0fTtcblxuIFx0Ly8gZGVmaW5lIF9fZXNNb2R1bGUgb24gZXhwb3J0c1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5yID0gZnVuY3Rpb24oZXhwb3J0cykge1xuIFx0XHRpZih0eXBlb2YgU3ltYm9sICE9PSAndW5kZWZpbmVkJyAmJiBTeW1ib2wudG9TdHJpbmdUYWcpIHtcbiBcdFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgU3ltYm9sLnRvU3RyaW5nVGFnLCB7IHZhbHVlOiAnTW9kdWxlJyB9KTtcbiBcdFx0fVxuIFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgJ19fZXNNb2R1bGUnLCB7IHZhbHVlOiB0cnVlIH0pO1xuIFx0fTtcblxuIFx0Ly8gY3JlYXRlIGEgZmFrZSBuYW1lc3BhY2Ugb2JqZWN0XG4gXHQvLyBtb2RlICYgMTogdmFsdWUgaXMgYSBtb2R1bGUgaWQsIHJlcXVpcmUgaXRcbiBcdC8vIG1vZGUgJiAyOiBtZXJnZSBhbGwgcHJvcGVydGllcyBvZiB2YWx1ZSBpbnRvIHRoZSBuc1xuIFx0Ly8gbW9kZSAmIDQ6IHJldHVybiB2YWx1ZSB3aGVuIGFscmVhZHkgbnMgb2JqZWN0XG4gXHQvLyBtb2RlICYgOHwxOiBiZWhhdmUgbGlrZSByZXF1aXJlXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnQgPSBmdW5jdGlvbih2YWx1ZSwgbW9kZSkge1xuIFx0XHRpZihtb2RlICYgMSkgdmFsdWUgPSBfX3dlYnBhY2tfcmVxdWlyZV9fKHZhbHVlKTtcbiBcdFx0aWYobW9kZSAmIDgpIHJldHVybiB2YWx1ZTtcbiBcdFx0aWYoKG1vZGUgJiA0KSAmJiB0eXBlb2YgdmFsdWUgPT09ICdvYmplY3QnICYmIHZhbHVlICYmIHZhbHVlLl9fZXNNb2R1bGUpIHJldHVybiB2YWx1ZTtcbiBcdFx0dmFyIG5zID0gT2JqZWN0LmNyZWF0ZShudWxsKTtcbiBcdFx0X193ZWJwYWNrX3JlcXVpcmVfXy5yKG5zKTtcbiBcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KG5zLCAnZGVmYXVsdCcsIHsgZW51bWVyYWJsZTogdHJ1ZSwgdmFsdWU6IHZhbHVlIH0pO1xuIFx0XHRpZihtb2RlICYgMiAmJiB0eXBlb2YgdmFsdWUgIT0gJ3N0cmluZycpIGZvcih2YXIga2V5IGluIHZhbHVlKSBfX3dlYnBhY2tfcmVxdWlyZV9fLmQobnMsIGtleSwgZnVuY3Rpb24oa2V5KSB7IHJldHVybiB2YWx1ZVtrZXldOyB9LmJpbmQobnVsbCwga2V5KSk7XG4gXHRcdHJldHVybiBucztcbiBcdH07XG5cbiBcdC8vIGdldERlZmF1bHRFeHBvcnQgZnVuY3Rpb24gZm9yIGNvbXBhdGliaWxpdHkgd2l0aCBub24taGFybW9ueSBtb2R1bGVzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm4gPSBmdW5jdGlvbihtb2R1bGUpIHtcbiBcdFx0dmFyIGdldHRlciA9IG1vZHVsZSAmJiBtb2R1bGUuX19lc01vZHVsZSA/XG4gXHRcdFx0ZnVuY3Rpb24gZ2V0RGVmYXVsdCgpIHsgcmV0dXJuIG1vZHVsZVsnZGVmYXVsdCddOyB9IDpcbiBcdFx0XHRmdW5jdGlvbiBnZXRNb2R1bGVFeHBvcnRzKCkgeyByZXR1cm4gbW9kdWxlOyB9O1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQoZ2V0dGVyLCAnYScsIGdldHRlcik7XG4gXHRcdHJldHVybiBnZXR0ZXI7XG4gXHR9O1xuXG4gXHQvLyBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGxcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubyA9IGZ1bmN0aW9uKG9iamVjdCwgcHJvcGVydHkpIHsgcmV0dXJuIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmplY3QsIHByb3BlcnR5KTsgfTtcblxuIFx0Ly8gX193ZWJwYWNrX3B1YmxpY19wYXRoX19cbiBcdF9fd2VicGFja19yZXF1aXJlX18ucCA9IFwiXCI7XG5cblxuIFx0Ly8gTG9hZCBlbnRyeSBtb2R1bGUgYW5kIHJldHVybiBleHBvcnRzXG4gXHRyZXR1cm4gX193ZWJwYWNrX3JlcXVpcmVfXyhfX3dlYnBhY2tfcmVxdWlyZV9fLnMgPSBcIi4vc3JjL3NjcmlwdHMvaW5qZWN0L3R3aXR0ZXItaW5qZWN0LnRzXCIpO1xuIiwiLyoqXG4gKiBDb252ZXJ0IGFycmF5IG9mIDE2IGJ5dGUgdmFsdWVzIHRvIFVVSUQgc3RyaW5nIGZvcm1hdCBvZiB0aGUgZm9ybTpcbiAqIFhYWFhYWFhYLVhYWFgtWFhYWC1YWFhYLVhYWFhYWFhYWFhYWFxuICovXG52YXIgYnl0ZVRvSGV4ID0gW107XG5cbmZvciAodmFyIGkgPSAwOyBpIDwgMjU2OyArK2kpIHtcbiAgYnl0ZVRvSGV4W2ldID0gKGkgKyAweDEwMCkudG9TdHJpbmcoMTYpLnN1YnN0cigxKTtcbn1cblxuZnVuY3Rpb24gYnl0ZXNUb1V1aWQoYnVmLCBvZmZzZXQpIHtcbiAgdmFyIGkgPSBvZmZzZXQgfHwgMDtcbiAgdmFyIGJ0aCA9IGJ5dGVUb0hleDsgLy8gam9pbiB1c2VkIHRvIGZpeCBtZW1vcnkgaXNzdWUgY2F1c2VkIGJ5IGNvbmNhdGVuYXRpb246IGh0dHBzOi8vYnVncy5jaHJvbWl1bS5vcmcvcC92OC9pc3N1ZXMvZGV0YWlsP2lkPTMxNzUjYzRcblxuICByZXR1cm4gW2J0aFtidWZbaSsrXV0sIGJ0aFtidWZbaSsrXV0sIGJ0aFtidWZbaSsrXV0sIGJ0aFtidWZbaSsrXV0sICctJywgYnRoW2J1ZltpKytdXSwgYnRoW2J1ZltpKytdXSwgJy0nLCBidGhbYnVmW2krK11dLCBidGhbYnVmW2krK11dLCAnLScsIGJ0aFtidWZbaSsrXV0sIGJ0aFtidWZbaSsrXV0sICctJywgYnRoW2J1ZltpKytdXSwgYnRoW2J1ZltpKytdXSwgYnRoW2J1ZltpKytdXSwgYnRoW2J1ZltpKytdXSwgYnRoW2J1ZltpKytdXSwgYnRoW2J1ZltpKytdXV0uam9pbignJyk7XG59XG5cbmV4cG9ydCBkZWZhdWx0IGJ5dGVzVG9VdWlkOyIsImV4cG9ydCB7IGRlZmF1bHQgYXMgdjEgfSBmcm9tICcuL3YxLmpzJztcbmV4cG9ydCB7IGRlZmF1bHQgYXMgdjMgfSBmcm9tICcuL3YzLmpzJztcbmV4cG9ydCB7IGRlZmF1bHQgYXMgdjQgfSBmcm9tICcuL3Y0LmpzJztcbmV4cG9ydCB7IGRlZmF1bHQgYXMgdjUgfSBmcm9tICcuL3Y1LmpzJzsiLCIvKlxuICogQnJvd3Nlci1jb21wYXRpYmxlIEphdmFTY3JpcHQgTUQ1XG4gKlxuICogTW9kaWZpY2F0aW9uIG9mIEphdmFTY3JpcHQgTUQ1XG4gKiBodHRwczovL2dpdGh1Yi5jb20vYmx1ZWltcC9KYXZhU2NyaXB0LU1ENVxuICpcbiAqIENvcHlyaWdodCAyMDExLCBTZWJhc3RpYW4gVHNjaGFuXG4gKiBodHRwczovL2JsdWVpbXAubmV0XG4gKlxuICogTGljZW5zZWQgdW5kZXIgdGhlIE1JVCBsaWNlbnNlOlxuICogaHR0cHM6Ly9vcGVuc291cmNlLm9yZy9saWNlbnNlcy9NSVRcbiAqXG4gKiBCYXNlZCBvblxuICogQSBKYXZhU2NyaXB0IGltcGxlbWVudGF0aW9uIG9mIHRoZSBSU0EgRGF0YSBTZWN1cml0eSwgSW5jLiBNRDUgTWVzc2FnZVxuICogRGlnZXN0IEFsZ29yaXRobSwgYXMgZGVmaW5lZCBpbiBSRkMgMTMyMS5cbiAqIFZlcnNpb24gMi4yIENvcHlyaWdodCAoQykgUGF1bCBKb2huc3RvbiAxOTk5IC0gMjAwOVxuICogT3RoZXIgY29udHJpYnV0b3JzOiBHcmVnIEhvbHQsIEFuZHJldyBLZXBlcnQsIFlkbmFyLCBMb3N0aW5ldFxuICogRGlzdHJpYnV0ZWQgdW5kZXIgdGhlIEJTRCBMaWNlbnNlXG4gKiBTZWUgaHR0cDovL3BhamhvbWUub3JnLnVrL2NyeXB0L21kNSBmb3IgbW9yZSBpbmZvLlxuICovXG5mdW5jdGlvbiBtZDUoYnl0ZXMpIHtcbiAgaWYgKHR5cGVvZiBieXRlcyA9PSAnc3RyaW5nJykge1xuICAgIHZhciBtc2cgPSB1bmVzY2FwZShlbmNvZGVVUklDb21wb25lbnQoYnl0ZXMpKTsgLy8gVVRGOCBlc2NhcGVcblxuICAgIGJ5dGVzID0gbmV3IEFycmF5KG1zZy5sZW5ndGgpO1xuXG4gICAgZm9yICh2YXIgaSA9IDA7IGkgPCBtc2cubGVuZ3RoOyBpKyspIHtcbiAgICAgIGJ5dGVzW2ldID0gbXNnLmNoYXJDb2RlQXQoaSk7XG4gICAgfVxuICB9XG5cbiAgcmV0dXJuIG1kNVRvSGV4RW5jb2RlZEFycmF5KHdvcmRzVG9NZDUoYnl0ZXNUb1dvcmRzKGJ5dGVzKSwgYnl0ZXMubGVuZ3RoICogOCkpO1xufVxuLypcbiAqIENvbnZlcnQgYW4gYXJyYXkgb2YgbGl0dGxlLWVuZGlhbiB3b3JkcyB0byBhbiBhcnJheSBvZiBieXRlc1xuICovXG5cblxuZnVuY3Rpb24gbWQ1VG9IZXhFbmNvZGVkQXJyYXkoaW5wdXQpIHtcbiAgdmFyIGk7XG4gIHZhciB4O1xuICB2YXIgb3V0cHV0ID0gW107XG4gIHZhciBsZW5ndGgzMiA9IGlucHV0Lmxlbmd0aCAqIDMyO1xuICB2YXIgaGV4VGFiID0gJzAxMjM0NTY3ODlhYmNkZWYnO1xuICB2YXIgaGV4O1xuXG4gIGZvciAoaSA9IDA7IGkgPCBsZW5ndGgzMjsgaSArPSA4KSB7XG4gICAgeCA9IGlucHV0W2kgPj4gNV0gPj4+IGkgJSAzMiAmIDB4ZmY7XG4gICAgaGV4ID0gcGFyc2VJbnQoaGV4VGFiLmNoYXJBdCh4ID4+PiA0ICYgMHgwZikgKyBoZXhUYWIuY2hhckF0KHggJiAweDBmKSwgMTYpO1xuICAgIG91dHB1dC5wdXNoKGhleCk7XG4gIH1cblxuICByZXR1cm4gb3V0cHV0O1xufVxuLypcbiAqIENhbGN1bGF0ZSB0aGUgTUQ1IG9mIGFuIGFycmF5IG9mIGxpdHRsZS1lbmRpYW4gd29yZHMsIGFuZCBhIGJpdCBsZW5ndGguXG4gKi9cblxuXG5mdW5jdGlvbiB3b3Jkc1RvTWQ1KHgsIGxlbikge1xuICAvKiBhcHBlbmQgcGFkZGluZyAqL1xuICB4W2xlbiA+PiA1XSB8PSAweDgwIDw8IGxlbiAlIDMyO1xuICB4WyhsZW4gKyA2NCA+Pj4gOSA8PCA0KSArIDE0XSA9IGxlbjtcbiAgdmFyIGk7XG4gIHZhciBvbGRhO1xuICB2YXIgb2xkYjtcbiAgdmFyIG9sZGM7XG4gIHZhciBvbGRkO1xuICB2YXIgYSA9IDE3MzI1ODQxOTM7XG4gIHZhciBiID0gLTI3MTczMzg3OTtcbiAgdmFyIGMgPSAtMTczMjU4NDE5NDtcbiAgdmFyIGQgPSAyNzE3MzM4Nzg7XG5cbiAgZm9yIChpID0gMDsgaSA8IHgubGVuZ3RoOyBpICs9IDE2KSB7XG4gICAgb2xkYSA9IGE7XG4gICAgb2xkYiA9IGI7XG4gICAgb2xkYyA9IGM7XG4gICAgb2xkZCA9IGQ7XG4gICAgYSA9IG1kNWZmKGEsIGIsIGMsIGQsIHhbaV0sIDcsIC02ODA4NzY5MzYpO1xuICAgIGQgPSBtZDVmZihkLCBhLCBiLCBjLCB4W2kgKyAxXSwgMTIsIC0zODk1NjQ1ODYpO1xuICAgIGMgPSBtZDVmZihjLCBkLCBhLCBiLCB4W2kgKyAyXSwgMTcsIDYwNjEwNTgxOSk7XG4gICAgYiA9IG1kNWZmKGIsIGMsIGQsIGEsIHhbaSArIDNdLCAyMiwgLTEwNDQ1MjUzMzApO1xuICAgIGEgPSBtZDVmZihhLCBiLCBjLCBkLCB4W2kgKyA0XSwgNywgLTE3NjQxODg5Nyk7XG4gICAgZCA9IG1kNWZmKGQsIGEsIGIsIGMsIHhbaSArIDVdLCAxMiwgMTIwMDA4MDQyNik7XG4gICAgYyA9IG1kNWZmKGMsIGQsIGEsIGIsIHhbaSArIDZdLCAxNywgLTE0NzMyMzEzNDEpO1xuICAgIGIgPSBtZDVmZihiLCBjLCBkLCBhLCB4W2kgKyA3XSwgMjIsIC00NTcwNTk4Myk7XG4gICAgYSA9IG1kNWZmKGEsIGIsIGMsIGQsIHhbaSArIDhdLCA3LCAxNzcwMDM1NDE2KTtcbiAgICBkID0gbWQ1ZmYoZCwgYSwgYiwgYywgeFtpICsgOV0sIDEyLCAtMTk1ODQxNDQxNyk7XG4gICAgYyA9IG1kNWZmKGMsIGQsIGEsIGIsIHhbaSArIDEwXSwgMTcsIC00MjA2Myk7XG4gICAgYiA9IG1kNWZmKGIsIGMsIGQsIGEsIHhbaSArIDExXSwgMjIsIC0xOTkwNDA0MTYyKTtcbiAgICBhID0gbWQ1ZmYoYSwgYiwgYywgZCwgeFtpICsgMTJdLCA3LCAxODA0NjAzNjgyKTtcbiAgICBkID0gbWQ1ZmYoZCwgYSwgYiwgYywgeFtpICsgMTNdLCAxMiwgLTQwMzQxMTAxKTtcbiAgICBjID0gbWQ1ZmYoYywgZCwgYSwgYiwgeFtpICsgMTRdLCAxNywgLTE1MDIwMDIyOTApO1xuICAgIGIgPSBtZDVmZihiLCBjLCBkLCBhLCB4W2kgKyAxNV0sIDIyLCAxMjM2NTM1MzI5KTtcbiAgICBhID0gbWQ1Z2coYSwgYiwgYywgZCwgeFtpICsgMV0sIDUsIC0xNjU3OTY1MTApO1xuICAgIGQgPSBtZDVnZyhkLCBhLCBiLCBjLCB4W2kgKyA2XSwgOSwgLTEwNjk1MDE2MzIpO1xuICAgIGMgPSBtZDVnZyhjLCBkLCBhLCBiLCB4W2kgKyAxMV0sIDE0LCA2NDM3MTc3MTMpO1xuICAgIGIgPSBtZDVnZyhiLCBjLCBkLCBhLCB4W2ldLCAyMCwgLTM3Mzg5NzMwMik7XG4gICAgYSA9IG1kNWdnKGEsIGIsIGMsIGQsIHhbaSArIDVdLCA1LCAtNzAxNTU4NjkxKTtcbiAgICBkID0gbWQ1Z2coZCwgYSwgYiwgYywgeFtpICsgMTBdLCA5LCAzODAxNjA4Myk7XG4gICAgYyA9IG1kNWdnKGMsIGQsIGEsIGIsIHhbaSArIDE1XSwgMTQsIC02NjA0NzgzMzUpO1xuICAgIGIgPSBtZDVnZyhiLCBjLCBkLCBhLCB4W2kgKyA0XSwgMjAsIC00MDU1Mzc4NDgpO1xuICAgIGEgPSBtZDVnZyhhLCBiLCBjLCBkLCB4W2kgKyA5XSwgNSwgNTY4NDQ2NDM4KTtcbiAgICBkID0gbWQ1Z2coZCwgYSwgYiwgYywgeFtpICsgMTRdLCA5LCAtMTAxOTgwMzY5MCk7XG4gICAgYyA9IG1kNWdnKGMsIGQsIGEsIGIsIHhbaSArIDNdLCAxNCwgLTE4NzM2Mzk2MSk7XG4gICAgYiA9IG1kNWdnKGIsIGMsIGQsIGEsIHhbaSArIDhdLCAyMCwgMTE2MzUzMTUwMSk7XG4gICAgYSA9IG1kNWdnKGEsIGIsIGMsIGQsIHhbaSArIDEzXSwgNSwgLTE0NDQ2ODE0NjcpO1xuICAgIGQgPSBtZDVnZyhkLCBhLCBiLCBjLCB4W2kgKyAyXSwgOSwgLTUxNDAzNzg0KTtcbiAgICBjID0gbWQ1Z2coYywgZCwgYSwgYiwgeFtpICsgN10sIDE0LCAxNzM1MzI4NDczKTtcbiAgICBiID0gbWQ1Z2coYiwgYywgZCwgYSwgeFtpICsgMTJdLCAyMCwgLTE5MjY2MDc3MzQpO1xuICAgIGEgPSBtZDVoaChhLCBiLCBjLCBkLCB4W2kgKyA1XSwgNCwgLTM3ODU1OCk7XG4gICAgZCA9IG1kNWhoKGQsIGEsIGIsIGMsIHhbaSArIDhdLCAxMSwgLTIwMjI1NzQ0NjMpO1xuICAgIGMgPSBtZDVoaChjLCBkLCBhLCBiLCB4W2kgKyAxMV0sIDE2LCAxODM5MDMwNTYyKTtcbiAgICBiID0gbWQ1aGgoYiwgYywgZCwgYSwgeFtpICsgMTRdLCAyMywgLTM1MzA5NTU2KTtcbiAgICBhID0gbWQ1aGgoYSwgYiwgYywgZCwgeFtpICsgMV0sIDQsIC0xNTMwOTkyMDYwKTtcbiAgICBkID0gbWQ1aGgoZCwgYSwgYiwgYywgeFtpICsgNF0sIDExLCAxMjcyODkzMzUzKTtcbiAgICBjID0gbWQ1aGgoYywgZCwgYSwgYiwgeFtpICsgN10sIDE2LCAtMTU1NDk3NjMyKTtcbiAgICBiID0gbWQ1aGgoYiwgYywgZCwgYSwgeFtpICsgMTBdLCAyMywgLTEwOTQ3MzA2NDApO1xuICAgIGEgPSBtZDVoaChhLCBiLCBjLCBkLCB4W2kgKyAxM10sIDQsIDY4MTI3OTE3NCk7XG4gICAgZCA9IG1kNWhoKGQsIGEsIGIsIGMsIHhbaV0sIDExLCAtMzU4NTM3MjIyKTtcbiAgICBjID0gbWQ1aGgoYywgZCwgYSwgYiwgeFtpICsgM10sIDE2LCAtNzIyNTIxOTc5KTtcbiAgICBiID0gbWQ1aGgoYiwgYywgZCwgYSwgeFtpICsgNl0sIDIzLCA3NjAyOTE4OSk7XG4gICAgYSA9IG1kNWhoKGEsIGIsIGMsIGQsIHhbaSArIDldLCA0LCAtNjQwMzY0NDg3KTtcbiAgICBkID0gbWQ1aGgoZCwgYSwgYiwgYywgeFtpICsgMTJdLCAxMSwgLTQyMTgxNTgzNSk7XG4gICAgYyA9IG1kNWhoKGMsIGQsIGEsIGIsIHhbaSArIDE1XSwgMTYsIDUzMDc0MjUyMCk7XG4gICAgYiA9IG1kNWhoKGIsIGMsIGQsIGEsIHhbaSArIDJdLCAyMywgLTk5NTMzODY1MSk7XG4gICAgYSA9IG1kNWlpKGEsIGIsIGMsIGQsIHhbaV0sIDYsIC0xOTg2MzA4NDQpO1xuICAgIGQgPSBtZDVpaShkLCBhLCBiLCBjLCB4W2kgKyA3XSwgMTAsIDExMjY4OTE0MTUpO1xuICAgIGMgPSBtZDVpaShjLCBkLCBhLCBiLCB4W2kgKyAxNF0sIDE1LCAtMTQxNjM1NDkwNSk7XG4gICAgYiA9IG1kNWlpKGIsIGMsIGQsIGEsIHhbaSArIDVdLCAyMSwgLTU3NDM0MDU1KTtcbiAgICBhID0gbWQ1aWkoYSwgYiwgYywgZCwgeFtpICsgMTJdLCA2LCAxNzAwNDg1NTcxKTtcbiAgICBkID0gbWQ1aWkoZCwgYSwgYiwgYywgeFtpICsgM10sIDEwLCAtMTg5NDk4NjYwNik7XG4gICAgYyA9IG1kNWlpKGMsIGQsIGEsIGIsIHhbaSArIDEwXSwgMTUsIC0xMDUxNTIzKTtcbiAgICBiID0gbWQ1aWkoYiwgYywgZCwgYSwgeFtpICsgMV0sIDIxLCAtMjA1NDkyMjc5OSk7XG4gICAgYSA9IG1kNWlpKGEsIGIsIGMsIGQsIHhbaSArIDhdLCA2LCAxODczMzEzMzU5KTtcbiAgICBkID0gbWQ1aWkoZCwgYSwgYiwgYywgeFtpICsgMTVdLCAxMCwgLTMwNjExNzQ0KTtcbiAgICBjID0gbWQ1aWkoYywgZCwgYSwgYiwgeFtpICsgNl0sIDE1LCAtMTU2MDE5ODM4MCk7XG4gICAgYiA9IG1kNWlpKGIsIGMsIGQsIGEsIHhbaSArIDEzXSwgMjEsIDEzMDkxNTE2NDkpO1xuICAgIGEgPSBtZDVpaShhLCBiLCBjLCBkLCB4W2kgKyA0XSwgNiwgLTE0NTUyMzA3MCk7XG4gICAgZCA9IG1kNWlpKGQsIGEsIGIsIGMsIHhbaSArIDExXSwgMTAsIC0xMTIwMjEwMzc5KTtcbiAgICBjID0gbWQ1aWkoYywgZCwgYSwgYiwgeFtpICsgMl0sIDE1LCA3MTg3ODcyNTkpO1xuICAgIGIgPSBtZDVpaShiLCBjLCBkLCBhLCB4W2kgKyA5XSwgMjEsIC0zNDM0ODU1NTEpO1xuICAgIGEgPSBzYWZlQWRkKGEsIG9sZGEpO1xuICAgIGIgPSBzYWZlQWRkKGIsIG9sZGIpO1xuICAgIGMgPSBzYWZlQWRkKGMsIG9sZGMpO1xuICAgIGQgPSBzYWZlQWRkKGQsIG9sZGQpO1xuICB9XG5cbiAgcmV0dXJuIFthLCBiLCBjLCBkXTtcbn1cbi8qXG4gKiBDb252ZXJ0IGFuIGFycmF5IGJ5dGVzIHRvIGFuIGFycmF5IG9mIGxpdHRsZS1lbmRpYW4gd29yZHNcbiAqIENoYXJhY3RlcnMgPjI1NSBoYXZlIHRoZWlyIGhpZ2gtYnl0ZSBzaWxlbnRseSBpZ25vcmVkLlxuICovXG5cblxuZnVuY3Rpb24gYnl0ZXNUb1dvcmRzKGlucHV0KSB7XG4gIHZhciBpO1xuICB2YXIgb3V0cHV0ID0gW107XG4gIG91dHB1dFsoaW5wdXQubGVuZ3RoID4+IDIpIC0gMV0gPSB1bmRlZmluZWQ7XG5cbiAgZm9yIChpID0gMDsgaSA8IG91dHB1dC5sZW5ndGg7IGkgKz0gMSkge1xuICAgIG91dHB1dFtpXSA9IDA7XG4gIH1cblxuICB2YXIgbGVuZ3RoOCA9IGlucHV0Lmxlbmd0aCAqIDg7XG5cbiAgZm9yIChpID0gMDsgaSA8IGxlbmd0aDg7IGkgKz0gOCkge1xuICAgIG91dHB1dFtpID4+IDVdIHw9IChpbnB1dFtpIC8gOF0gJiAweGZmKSA8PCBpICUgMzI7XG4gIH1cblxuICByZXR1cm4gb3V0cHV0O1xufVxuLypcbiAqIEFkZCBpbnRlZ2Vycywgd3JhcHBpbmcgYXQgMl4zMi4gVGhpcyB1c2VzIDE2LWJpdCBvcGVyYXRpb25zIGludGVybmFsbHlcbiAqIHRvIHdvcmsgYXJvdW5kIGJ1Z3MgaW4gc29tZSBKUyBpbnRlcnByZXRlcnMuXG4gKi9cblxuXG5mdW5jdGlvbiBzYWZlQWRkKHgsIHkpIHtcbiAgdmFyIGxzdyA9ICh4ICYgMHhmZmZmKSArICh5ICYgMHhmZmZmKTtcbiAgdmFyIG1zdyA9ICh4ID4+IDE2KSArICh5ID4+IDE2KSArIChsc3cgPj4gMTYpO1xuICByZXR1cm4gbXN3IDw8IDE2IHwgbHN3ICYgMHhmZmZmO1xufVxuLypcbiAqIEJpdHdpc2Ugcm90YXRlIGEgMzItYml0IG51bWJlciB0byB0aGUgbGVmdC5cbiAqL1xuXG5cbmZ1bmN0aW9uIGJpdFJvdGF0ZUxlZnQobnVtLCBjbnQpIHtcbiAgcmV0dXJuIG51bSA8PCBjbnQgfCBudW0gPj4+IDMyIC0gY250O1xufVxuLypcbiAqIFRoZXNlIGZ1bmN0aW9ucyBpbXBsZW1lbnQgdGhlIGZvdXIgYmFzaWMgb3BlcmF0aW9ucyB0aGUgYWxnb3JpdGhtIHVzZXMuXG4gKi9cblxuXG5mdW5jdGlvbiBtZDVjbW4ocSwgYSwgYiwgeCwgcywgdCkge1xuICByZXR1cm4gc2FmZUFkZChiaXRSb3RhdGVMZWZ0KHNhZmVBZGQoc2FmZUFkZChhLCBxKSwgc2FmZUFkZCh4LCB0KSksIHMpLCBiKTtcbn1cblxuZnVuY3Rpb24gbWQ1ZmYoYSwgYiwgYywgZCwgeCwgcywgdCkge1xuICByZXR1cm4gbWQ1Y21uKGIgJiBjIHwgfmIgJiBkLCBhLCBiLCB4LCBzLCB0KTtcbn1cblxuZnVuY3Rpb24gbWQ1Z2coYSwgYiwgYywgZCwgeCwgcywgdCkge1xuICByZXR1cm4gbWQ1Y21uKGIgJiBkIHwgYyAmIH5kLCBhLCBiLCB4LCBzLCB0KTtcbn1cblxuZnVuY3Rpb24gbWQ1aGgoYSwgYiwgYywgZCwgeCwgcywgdCkge1xuICByZXR1cm4gbWQ1Y21uKGIgXiBjIF4gZCwgYSwgYiwgeCwgcywgdCk7XG59XG5cbmZ1bmN0aW9uIG1kNWlpKGEsIGIsIGMsIGQsIHgsIHMsIHQpIHtcbiAgcmV0dXJuIG1kNWNtbihjIF4gKGIgfCB+ZCksIGEsIGIsIHgsIHMsIHQpO1xufVxuXG5leHBvcnQgZGVmYXVsdCBtZDU7IiwiLy8gVW5pcXVlIElEIGNyZWF0aW9uIHJlcXVpcmVzIGEgaGlnaCBxdWFsaXR5IHJhbmRvbSAjIGdlbmVyYXRvci4gSW4gdGhlIGJyb3dzZXIgd2UgdGhlcmVmb3JlXG4vLyByZXF1aXJlIHRoZSBjcnlwdG8gQVBJIGFuZCBkbyBub3Qgc3VwcG9ydCBidWlsdC1pbiBmYWxsYmFjayB0byBsb3dlciBxdWFsaXR5IHJhbmRvbSBudW1iZXJcbi8vIGdlbmVyYXRvcnMgKGxpa2UgTWF0aC5yYW5kb20oKSkuXG4vLyBnZXRSYW5kb21WYWx1ZXMgbmVlZHMgdG8gYmUgaW52b2tlZCBpbiBhIGNvbnRleHQgd2hlcmUgXCJ0aGlzXCIgaXMgYSBDcnlwdG8gaW1wbGVtZW50YXRpb24uIEFsc28sXG4vLyBmaW5kIHRoZSBjb21wbGV0ZSBpbXBsZW1lbnRhdGlvbiBvZiBjcnlwdG8gKG1zQ3J5cHRvKSBvbiBJRTExLlxudmFyIGdldFJhbmRvbVZhbHVlcyA9IHR5cGVvZiBjcnlwdG8gIT0gJ3VuZGVmaW5lZCcgJiYgY3J5cHRvLmdldFJhbmRvbVZhbHVlcyAmJiBjcnlwdG8uZ2V0UmFuZG9tVmFsdWVzLmJpbmQoY3J5cHRvKSB8fCB0eXBlb2YgbXNDcnlwdG8gIT0gJ3VuZGVmaW5lZCcgJiYgdHlwZW9mIG1zQ3J5cHRvLmdldFJhbmRvbVZhbHVlcyA9PSAnZnVuY3Rpb24nICYmIG1zQ3J5cHRvLmdldFJhbmRvbVZhbHVlcy5iaW5kKG1zQ3J5cHRvKTtcbnZhciBybmRzOCA9IG5ldyBVaW50OEFycmF5KDE2KTsgLy8gZXNsaW50LWRpc2FibGUtbGluZSBuby11bmRlZlxuXG5leHBvcnQgZGVmYXVsdCBmdW5jdGlvbiBybmcoKSB7XG4gIGlmICghZ2V0UmFuZG9tVmFsdWVzKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKCdjcnlwdG8uZ2V0UmFuZG9tVmFsdWVzKCkgbm90IHN1cHBvcnRlZC4gU2VlIGh0dHBzOi8vZ2l0aHViLmNvbS91dWlkanMvdXVpZCNnZXRyYW5kb212YWx1ZXMtbm90LXN1cHBvcnRlZCcpO1xuICB9XG5cbiAgcmV0dXJuIGdldFJhbmRvbVZhbHVlcyhybmRzOCk7XG59IiwiLy8gQWRhcHRlZCBmcm9tIENocmlzIFZlbmVzcycgU0hBMSBjb2RlIGF0XG4vLyBodHRwOi8vd3d3Lm1vdmFibGUtdHlwZS5jby51ay9zY3JpcHRzL3NoYTEuaHRtbFxuZnVuY3Rpb24gZihzLCB4LCB5LCB6KSB7XG4gIHN3aXRjaCAocykge1xuICAgIGNhc2UgMDpcbiAgICAgIHJldHVybiB4ICYgeSBeIH54ICYgejtcblxuICAgIGNhc2UgMTpcbiAgICAgIHJldHVybiB4IF4geSBeIHo7XG5cbiAgICBjYXNlIDI6XG4gICAgICByZXR1cm4geCAmIHkgXiB4ICYgeiBeIHkgJiB6O1xuXG4gICAgY2FzZSAzOlxuICAgICAgcmV0dXJuIHggXiB5IF4gejtcbiAgfVxufVxuXG5mdW5jdGlvbiBST1RMKHgsIG4pIHtcbiAgcmV0dXJuIHggPDwgbiB8IHggPj4+IDMyIC0gbjtcbn1cblxuZnVuY3Rpb24gc2hhMShieXRlcykge1xuICB2YXIgSyA9IFsweDVhODI3OTk5LCAweDZlZDllYmExLCAweDhmMWJiY2RjLCAweGNhNjJjMWQ2XTtcbiAgdmFyIEggPSBbMHg2NzQ1MjMwMSwgMHhlZmNkYWI4OSwgMHg5OGJhZGNmZSwgMHgxMDMyNTQ3NiwgMHhjM2QyZTFmMF07XG5cbiAgaWYgKHR5cGVvZiBieXRlcyA9PSAnc3RyaW5nJykge1xuICAgIHZhciBtc2cgPSB1bmVzY2FwZShlbmNvZGVVUklDb21wb25lbnQoYnl0ZXMpKTsgLy8gVVRGOCBlc2NhcGVcblxuICAgIGJ5dGVzID0gbmV3IEFycmF5KG1zZy5sZW5ndGgpO1xuXG4gICAgZm9yICh2YXIgaSA9IDA7IGkgPCBtc2cubGVuZ3RoOyBpKyspIHtcbiAgICAgIGJ5dGVzW2ldID0gbXNnLmNoYXJDb2RlQXQoaSk7XG4gICAgfVxuICB9XG5cbiAgYnl0ZXMucHVzaCgweDgwKTtcbiAgdmFyIGwgPSBieXRlcy5sZW5ndGggLyA0ICsgMjtcbiAgdmFyIE4gPSBNYXRoLmNlaWwobCAvIDE2KTtcbiAgdmFyIE0gPSBuZXcgQXJyYXkoTik7XG5cbiAgZm9yICh2YXIgaSA9IDA7IGkgPCBOOyBpKyspIHtcbiAgICBNW2ldID0gbmV3IEFycmF5KDE2KTtcblxuICAgIGZvciAodmFyIGogPSAwOyBqIDwgMTY7IGorKykge1xuICAgICAgTVtpXVtqXSA9IGJ5dGVzW2kgKiA2NCArIGogKiA0XSA8PCAyNCB8IGJ5dGVzW2kgKiA2NCArIGogKiA0ICsgMV0gPDwgMTYgfCBieXRlc1tpICogNjQgKyBqICogNCArIDJdIDw8IDggfCBieXRlc1tpICogNjQgKyBqICogNCArIDNdO1xuICAgIH1cbiAgfVxuXG4gIE1bTiAtIDFdWzE0XSA9IChieXRlcy5sZW5ndGggLSAxKSAqIDggLyBNYXRoLnBvdygyLCAzMik7XG4gIE1bTiAtIDFdWzE0XSA9IE1hdGguZmxvb3IoTVtOIC0gMV1bMTRdKTtcbiAgTVtOIC0gMV1bMTVdID0gKGJ5dGVzLmxlbmd0aCAtIDEpICogOCAmIDB4ZmZmZmZmZmY7XG5cbiAgZm9yICh2YXIgaSA9IDA7IGkgPCBOOyBpKyspIHtcbiAgICB2YXIgVyA9IG5ldyBBcnJheSg4MCk7XG5cbiAgICBmb3IgKHZhciB0ID0gMDsgdCA8IDE2OyB0KyspIHtcbiAgICAgIFdbdF0gPSBNW2ldW3RdO1xuICAgIH1cblxuICAgIGZvciAodmFyIHQgPSAxNjsgdCA8IDgwOyB0KyspIHtcbiAgICAgIFdbdF0gPSBST1RMKFdbdCAtIDNdIF4gV1t0IC0gOF0gXiBXW3QgLSAxNF0gXiBXW3QgLSAxNl0sIDEpO1xuICAgIH1cblxuICAgIHZhciBhID0gSFswXTtcbiAgICB2YXIgYiA9IEhbMV07XG4gICAgdmFyIGMgPSBIWzJdO1xuICAgIHZhciBkID0gSFszXTtcbiAgICB2YXIgZSA9IEhbNF07XG5cbiAgICBmb3IgKHZhciB0ID0gMDsgdCA8IDgwOyB0KyspIHtcbiAgICAgIHZhciBzID0gTWF0aC5mbG9vcih0IC8gMjApO1xuICAgICAgdmFyIFQgPSBST1RMKGEsIDUpICsgZihzLCBiLCBjLCBkKSArIGUgKyBLW3NdICsgV1t0XSA+Pj4gMDtcbiAgICAgIGUgPSBkO1xuICAgICAgZCA9IGM7XG4gICAgICBjID0gUk9UTChiLCAzMCkgPj4+IDA7XG4gICAgICBiID0gYTtcbiAgICAgIGEgPSBUO1xuICAgIH1cblxuICAgIEhbMF0gPSBIWzBdICsgYSA+Pj4gMDtcbiAgICBIWzFdID0gSFsxXSArIGIgPj4+IDA7XG4gICAgSFsyXSA9IEhbMl0gKyBjID4+PiAwO1xuICAgIEhbM10gPSBIWzNdICsgZCA+Pj4gMDtcbiAgICBIWzRdID0gSFs0XSArIGUgPj4+IDA7XG4gIH1cblxuICByZXR1cm4gW0hbMF0gPj4gMjQgJiAweGZmLCBIWzBdID4+IDE2ICYgMHhmZiwgSFswXSA+PiA4ICYgMHhmZiwgSFswXSAmIDB4ZmYsIEhbMV0gPj4gMjQgJiAweGZmLCBIWzFdID4+IDE2ICYgMHhmZiwgSFsxXSA+PiA4ICYgMHhmZiwgSFsxXSAmIDB4ZmYsIEhbMl0gPj4gMjQgJiAweGZmLCBIWzJdID4+IDE2ICYgMHhmZiwgSFsyXSA+PiA4ICYgMHhmZiwgSFsyXSAmIDB4ZmYsIEhbM10gPj4gMjQgJiAweGZmLCBIWzNdID4+IDE2ICYgMHhmZiwgSFszXSA+PiA4ICYgMHhmZiwgSFszXSAmIDB4ZmYsIEhbNF0gPj4gMjQgJiAweGZmLCBIWzRdID4+IDE2ICYgMHhmZiwgSFs0XSA+PiA4ICYgMHhmZiwgSFs0XSAmIDB4ZmZdO1xufVxuXG5leHBvcnQgZGVmYXVsdCBzaGExOyIsImltcG9ydCBybmcgZnJvbSAnLi9ybmcuanMnO1xuaW1wb3J0IGJ5dGVzVG9VdWlkIGZyb20gJy4vYnl0ZXNUb1V1aWQuanMnOyAvLyAqKmB2MSgpYCAtIEdlbmVyYXRlIHRpbWUtYmFzZWQgVVVJRCoqXG4vL1xuLy8gSW5zcGlyZWQgYnkgaHR0cHM6Ly9naXRodWIuY29tL0xpb3NLL1VVSUQuanNcbi8vIGFuZCBodHRwOi8vZG9jcy5weXRob24ub3JnL2xpYnJhcnkvdXVpZC5odG1sXG5cbnZhciBfbm9kZUlkO1xuXG52YXIgX2Nsb2Nrc2VxOyAvLyBQcmV2aW91cyB1dWlkIGNyZWF0aW9uIHRpbWVcblxuXG52YXIgX2xhc3RNU2VjcyA9IDA7XG52YXIgX2xhc3ROU2VjcyA9IDA7IC8vIFNlZSBodHRwczovL2dpdGh1Yi5jb20vdXVpZGpzL3V1aWQgZm9yIEFQSSBkZXRhaWxzXG5cbmZ1bmN0aW9uIHYxKG9wdGlvbnMsIGJ1Ziwgb2Zmc2V0KSB7XG4gIHZhciBpID0gYnVmICYmIG9mZnNldCB8fCAwO1xuICB2YXIgYiA9IGJ1ZiB8fCBbXTtcbiAgb3B0aW9ucyA9IG9wdGlvbnMgfHwge307XG4gIHZhciBub2RlID0gb3B0aW9ucy5ub2RlIHx8IF9ub2RlSWQ7XG4gIHZhciBjbG9ja3NlcSA9IG9wdGlvbnMuY2xvY2tzZXEgIT09IHVuZGVmaW5lZCA/IG9wdGlvbnMuY2xvY2tzZXEgOiBfY2xvY2tzZXE7IC8vIG5vZGUgYW5kIGNsb2Nrc2VxIG5lZWQgdG8gYmUgaW5pdGlhbGl6ZWQgdG8gcmFuZG9tIHZhbHVlcyBpZiB0aGV5J3JlIG5vdFxuICAvLyBzcGVjaWZpZWQuICBXZSBkbyB0aGlzIGxhemlseSB0byBtaW5pbWl6ZSBpc3N1ZXMgcmVsYXRlZCB0byBpbnN1ZmZpY2llbnRcbiAgLy8gc3lzdGVtIGVudHJvcHkuICBTZWUgIzE4OVxuXG4gIGlmIChub2RlID09IG51bGwgfHwgY2xvY2tzZXEgPT0gbnVsbCkge1xuICAgIHZhciBzZWVkQnl0ZXMgPSBvcHRpb25zLnJhbmRvbSB8fCAob3B0aW9ucy5ybmcgfHwgcm5nKSgpO1xuXG4gICAgaWYgKG5vZGUgPT0gbnVsbCkge1xuICAgICAgLy8gUGVyIDQuNSwgY3JlYXRlIGFuZCA0OC1iaXQgbm9kZSBpZCwgKDQ3IHJhbmRvbSBiaXRzICsgbXVsdGljYXN0IGJpdCA9IDEpXG4gICAgICBub2RlID0gX25vZGVJZCA9IFtzZWVkQnl0ZXNbMF0gfCAweDAxLCBzZWVkQnl0ZXNbMV0sIHNlZWRCeXRlc1syXSwgc2VlZEJ5dGVzWzNdLCBzZWVkQnl0ZXNbNF0sIHNlZWRCeXRlc1s1XV07XG4gICAgfVxuXG4gICAgaWYgKGNsb2Nrc2VxID09IG51bGwpIHtcbiAgICAgIC8vIFBlciA0LjIuMiwgcmFuZG9taXplICgxNCBiaXQpIGNsb2Nrc2VxXG4gICAgICBjbG9ja3NlcSA9IF9jbG9ja3NlcSA9IChzZWVkQnl0ZXNbNl0gPDwgOCB8IHNlZWRCeXRlc1s3XSkgJiAweDNmZmY7XG4gICAgfVxuICB9IC8vIFVVSUQgdGltZXN0YW1wcyBhcmUgMTAwIG5hbm8tc2Vjb25kIHVuaXRzIHNpbmNlIHRoZSBHcmVnb3JpYW4gZXBvY2gsXG4gIC8vICgxNTgyLTEwLTE1IDAwOjAwKS4gIEpTTnVtYmVycyBhcmVuJ3QgcHJlY2lzZSBlbm91Z2ggZm9yIHRoaXMsIHNvXG4gIC8vIHRpbWUgaXMgaGFuZGxlZCBpbnRlcm5hbGx5IGFzICdtc2VjcycgKGludGVnZXIgbWlsbGlzZWNvbmRzKSBhbmQgJ25zZWNzJ1xuICAvLyAoMTAwLW5hbm9zZWNvbmRzIG9mZnNldCBmcm9tIG1zZWNzKSBzaW5jZSB1bml4IGVwb2NoLCAxOTcwLTAxLTAxIDAwOjAwLlxuXG5cbiAgdmFyIG1zZWNzID0gb3B0aW9ucy5tc2VjcyAhPT0gdW5kZWZpbmVkID8gb3B0aW9ucy5tc2VjcyA6IG5ldyBEYXRlKCkuZ2V0VGltZSgpOyAvLyBQZXIgNC4yLjEuMiwgdXNlIGNvdW50IG9mIHV1aWQncyBnZW5lcmF0ZWQgZHVyaW5nIHRoZSBjdXJyZW50IGNsb2NrXG4gIC8vIGN5Y2xlIHRvIHNpbXVsYXRlIGhpZ2hlciByZXNvbHV0aW9uIGNsb2NrXG5cbiAgdmFyIG5zZWNzID0gb3B0aW9ucy5uc2VjcyAhPT0gdW5kZWZpbmVkID8gb3B0aW9ucy5uc2VjcyA6IF9sYXN0TlNlY3MgKyAxOyAvLyBUaW1lIHNpbmNlIGxhc3QgdXVpZCBjcmVhdGlvbiAoaW4gbXNlY3MpXG5cbiAgdmFyIGR0ID0gbXNlY3MgLSBfbGFzdE1TZWNzICsgKG5zZWNzIC0gX2xhc3ROU2VjcykgLyAxMDAwMDsgLy8gUGVyIDQuMi4xLjIsIEJ1bXAgY2xvY2tzZXEgb24gY2xvY2sgcmVncmVzc2lvblxuXG4gIGlmIChkdCA8IDAgJiYgb3B0aW9ucy5jbG9ja3NlcSA9PT0gdW5kZWZpbmVkKSB7XG4gICAgY2xvY2tzZXEgPSBjbG9ja3NlcSArIDEgJiAweDNmZmY7XG4gIH0gLy8gUmVzZXQgbnNlY3MgaWYgY2xvY2sgcmVncmVzc2VzIChuZXcgY2xvY2tzZXEpIG9yIHdlJ3ZlIG1vdmVkIG9udG8gYSBuZXdcbiAgLy8gdGltZSBpbnRlcnZhbFxuXG5cbiAgaWYgKChkdCA8IDAgfHwgbXNlY3MgPiBfbGFzdE1TZWNzKSAmJiBvcHRpb25zLm5zZWNzID09PSB1bmRlZmluZWQpIHtcbiAgICBuc2VjcyA9IDA7XG4gIH0gLy8gUGVyIDQuMi4xLjIgVGhyb3cgZXJyb3IgaWYgdG9vIG1hbnkgdXVpZHMgYXJlIHJlcXVlc3RlZFxuXG5cbiAgaWYgKG5zZWNzID49IDEwMDAwKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKFwidXVpZC52MSgpOiBDYW4ndCBjcmVhdGUgbW9yZSB0aGFuIDEwTSB1dWlkcy9zZWNcIik7XG4gIH1cblxuICBfbGFzdE1TZWNzID0gbXNlY3M7XG4gIF9sYXN0TlNlY3MgPSBuc2VjcztcbiAgX2Nsb2Nrc2VxID0gY2xvY2tzZXE7IC8vIFBlciA0LjEuNCAtIENvbnZlcnQgZnJvbSB1bml4IGVwb2NoIHRvIEdyZWdvcmlhbiBlcG9jaFxuXG4gIG1zZWNzICs9IDEyMjE5MjkyODAwMDAwOyAvLyBgdGltZV9sb3dgXG5cbiAgdmFyIHRsID0gKChtc2VjcyAmIDB4ZmZmZmZmZikgKiAxMDAwMCArIG5zZWNzKSAlIDB4MTAwMDAwMDAwO1xuICBiW2krK10gPSB0bCA+Pj4gMjQgJiAweGZmO1xuICBiW2krK10gPSB0bCA+Pj4gMTYgJiAweGZmO1xuICBiW2krK10gPSB0bCA+Pj4gOCAmIDB4ZmY7XG4gIGJbaSsrXSA9IHRsICYgMHhmZjsgLy8gYHRpbWVfbWlkYFxuXG4gIHZhciB0bWggPSBtc2VjcyAvIDB4MTAwMDAwMDAwICogMTAwMDAgJiAweGZmZmZmZmY7XG4gIGJbaSsrXSA9IHRtaCA+Pj4gOCAmIDB4ZmY7XG4gIGJbaSsrXSA9IHRtaCAmIDB4ZmY7IC8vIGB0aW1lX2hpZ2hfYW5kX3ZlcnNpb25gXG5cbiAgYltpKytdID0gdG1oID4+PiAyNCAmIDB4ZiB8IDB4MTA7IC8vIGluY2x1ZGUgdmVyc2lvblxuXG4gIGJbaSsrXSA9IHRtaCA+Pj4gMTYgJiAweGZmOyAvLyBgY2xvY2tfc2VxX2hpX2FuZF9yZXNlcnZlZGAgKFBlciA0LjIuMiAtIGluY2x1ZGUgdmFyaWFudClcblxuICBiW2krK10gPSBjbG9ja3NlcSA+Pj4gOCB8IDB4ODA7IC8vIGBjbG9ja19zZXFfbG93YFxuXG4gIGJbaSsrXSA9IGNsb2Nrc2VxICYgMHhmZjsgLy8gYG5vZGVgXG5cbiAgZm9yICh2YXIgbiA9IDA7IG4gPCA2OyArK24pIHtcbiAgICBiW2kgKyBuXSA9IG5vZGVbbl07XG4gIH1cblxuICByZXR1cm4gYnVmID8gYnVmIDogYnl0ZXNUb1V1aWQoYik7XG59XG5cbmV4cG9ydCBkZWZhdWx0IHYxOyIsImltcG9ydCB2MzUgZnJvbSAnLi92MzUuanMnO1xuaW1wb3J0IG1kNSBmcm9tICcuL21kNS5qcyc7XG52YXIgdjMgPSB2MzUoJ3YzJywgMHgzMCwgbWQ1KTtcbmV4cG9ydCBkZWZhdWx0IHYzOyIsImltcG9ydCBieXRlc1RvVXVpZCBmcm9tICcuL2J5dGVzVG9VdWlkLmpzJztcblxuZnVuY3Rpb24gdXVpZFRvQnl0ZXModXVpZCkge1xuICAvLyBOb3RlOiBXZSBhc3N1bWUgd2UncmUgYmVpbmcgcGFzc2VkIGEgdmFsaWQgdXVpZCBzdHJpbmdcbiAgdmFyIGJ5dGVzID0gW107XG4gIHV1aWQucmVwbGFjZSgvW2EtZkEtRjAtOV17Mn0vZywgZnVuY3Rpb24gKGhleCkge1xuICAgIGJ5dGVzLnB1c2gocGFyc2VJbnQoaGV4LCAxNikpO1xuICB9KTtcbiAgcmV0dXJuIGJ5dGVzO1xufVxuXG5mdW5jdGlvbiBzdHJpbmdUb0J5dGVzKHN0cikge1xuICBzdHIgPSB1bmVzY2FwZShlbmNvZGVVUklDb21wb25lbnQoc3RyKSk7IC8vIFVURjggZXNjYXBlXG5cbiAgdmFyIGJ5dGVzID0gbmV3IEFycmF5KHN0ci5sZW5ndGgpO1xuXG4gIGZvciAodmFyIGkgPSAwOyBpIDwgc3RyLmxlbmd0aDsgaSsrKSB7XG4gICAgYnl0ZXNbaV0gPSBzdHIuY2hhckNvZGVBdChpKTtcbiAgfVxuXG4gIHJldHVybiBieXRlcztcbn1cblxuZXhwb3J0IHZhciBETlMgPSAnNmJhN2I4MTAtOWRhZC0xMWQxLTgwYjQtMDBjMDRmZDQzMGM4JztcbmV4cG9ydCB2YXIgVVJMID0gJzZiYTdiODExLTlkYWQtMTFkMS04MGI0LTAwYzA0ZmQ0MzBjOCc7XG5leHBvcnQgZGVmYXVsdCBmdW5jdGlvbiAobmFtZSwgdmVyc2lvbiwgaGFzaGZ1bmMpIHtcbiAgdmFyIGdlbmVyYXRlVVVJRCA9IGZ1bmN0aW9uIGdlbmVyYXRlVVVJRCh2YWx1ZSwgbmFtZXNwYWNlLCBidWYsIG9mZnNldCkge1xuICAgIHZhciBvZmYgPSBidWYgJiYgb2Zmc2V0IHx8IDA7XG4gICAgaWYgKHR5cGVvZiB2YWx1ZSA9PSAnc3RyaW5nJykgdmFsdWUgPSBzdHJpbmdUb0J5dGVzKHZhbHVlKTtcbiAgICBpZiAodHlwZW9mIG5hbWVzcGFjZSA9PSAnc3RyaW5nJykgbmFtZXNwYWNlID0gdXVpZFRvQnl0ZXMobmFtZXNwYWNlKTtcbiAgICBpZiAoIUFycmF5LmlzQXJyYXkodmFsdWUpKSB0aHJvdyBUeXBlRXJyb3IoJ3ZhbHVlIG11c3QgYmUgYW4gYXJyYXkgb2YgYnl0ZXMnKTtcbiAgICBpZiAoIUFycmF5LmlzQXJyYXkobmFtZXNwYWNlKSB8fCBuYW1lc3BhY2UubGVuZ3RoICE9PSAxNikgdGhyb3cgVHlwZUVycm9yKCduYW1lc3BhY2UgbXVzdCBiZSB1dWlkIHN0cmluZyBvciBhbiBBcnJheSBvZiAxNiBieXRlIHZhbHVlcycpOyAvLyBQZXIgNC4zXG5cbiAgICB2YXIgYnl0ZXMgPSBoYXNoZnVuYyhuYW1lc3BhY2UuY29uY2F0KHZhbHVlKSk7XG4gICAgYnl0ZXNbNl0gPSBieXRlc1s2XSAmIDB4MGYgfCB2ZXJzaW9uO1xuICAgIGJ5dGVzWzhdID0gYnl0ZXNbOF0gJiAweDNmIHwgMHg4MDtcblxuICAgIGlmIChidWYpIHtcbiAgICAgIGZvciAodmFyIGlkeCA9IDA7IGlkeCA8IDE2OyArK2lkeCkge1xuICAgICAgICBidWZbb2ZmICsgaWR4XSA9IGJ5dGVzW2lkeF07XG4gICAgICB9XG4gICAgfVxuXG4gICAgcmV0dXJuIGJ1ZiB8fCBieXRlc1RvVXVpZChieXRlcyk7XG4gIH07IC8vIEZ1bmN0aW9uI25hbWUgaXMgbm90IHNldHRhYmxlIG9uIHNvbWUgcGxhdGZvcm1zICgjMjcwKVxuXG5cbiAgdHJ5IHtcbiAgICBnZW5lcmF0ZVVVSUQubmFtZSA9IG5hbWU7XG4gIH0gY2F0Y2ggKGVycikge30gLy8gRm9yIENvbW1vbkpTIGRlZmF1bHQgZXhwb3J0IHN1cHBvcnRcblxuXG4gIGdlbmVyYXRlVVVJRC5ETlMgPSBETlM7XG4gIGdlbmVyYXRlVVVJRC5VUkwgPSBVUkw7XG4gIHJldHVybiBnZW5lcmF0ZVVVSUQ7XG59IiwiaW1wb3J0IHJuZyBmcm9tICcuL3JuZy5qcyc7XG5pbXBvcnQgYnl0ZXNUb1V1aWQgZnJvbSAnLi9ieXRlc1RvVXVpZC5qcyc7XG5cbmZ1bmN0aW9uIHY0KG9wdGlvbnMsIGJ1Ziwgb2Zmc2V0KSB7XG4gIHZhciBpID0gYnVmICYmIG9mZnNldCB8fCAwO1xuXG4gIGlmICh0eXBlb2Ygb3B0aW9ucyA9PSAnc3RyaW5nJykge1xuICAgIGJ1ZiA9IG9wdGlvbnMgPT09ICdiaW5hcnknID8gbmV3IEFycmF5KDE2KSA6IG51bGw7XG4gICAgb3B0aW9ucyA9IG51bGw7XG4gIH1cblxuICBvcHRpb25zID0gb3B0aW9ucyB8fCB7fTtcbiAgdmFyIHJuZHMgPSBvcHRpb25zLnJhbmRvbSB8fCAob3B0aW9ucy5ybmcgfHwgcm5nKSgpOyAvLyBQZXIgNC40LCBzZXQgYml0cyBmb3IgdmVyc2lvbiBhbmQgYGNsb2NrX3NlcV9oaV9hbmRfcmVzZXJ2ZWRgXG5cbiAgcm5kc1s2XSA9IHJuZHNbNl0gJiAweDBmIHwgMHg0MDtcbiAgcm5kc1s4XSA9IHJuZHNbOF0gJiAweDNmIHwgMHg4MDsgLy8gQ29weSBieXRlcyB0byBidWZmZXIsIGlmIHByb3ZpZGVkXG5cbiAgaWYgKGJ1Zikge1xuICAgIGZvciAodmFyIGlpID0gMDsgaWkgPCAxNjsgKytpaSkge1xuICAgICAgYnVmW2kgKyBpaV0gPSBybmRzW2lpXTtcbiAgICB9XG4gIH1cblxuICByZXR1cm4gYnVmIHx8IGJ5dGVzVG9VdWlkKHJuZHMpO1xufVxuXG5leHBvcnQgZGVmYXVsdCB2NDsiLCJpbXBvcnQgdjM1IGZyb20gJy4vdjM1LmpzJztcbmltcG9ydCBzaGExIGZyb20gJy4vc2hhMS5qcyc7XG52YXIgdjUgPSB2MzUoJ3Y1JywgMHg1MCwgc2hhMSk7XG5leHBvcnQgZGVmYXVsdCB2NTsiLCJleHBvcnQgY29uc3QgVFdFRVQgPSAnTWlycm9yQmxvY2s8LVR3ZWV0J1xuZXhwb3J0IGNvbnN0IFVTRVJDRUxMID0gJ01pcnJvckJsb2NrPC1Vc2VyQ2VsbCdcbmV4cG9ydCBjb25zdCBETSA9ICdNaXJyb3JCbG9jazwtRE1Db252ZXJzYXRpb24nXG4iLCJpbXBvcnQgKiBhcyBSZWR1eERpc3BhdGNoZXIgZnJvbSAnLi90d2l0dGVyLWluamVjdC9yZWR1eC1kaXNwYXRjaGVyJ1xuaW1wb3J0ICogYXMgUmVkdXhGZXRjaGVyIGZyb20gJy4vdHdpdHRlci1pbmplY3QvcmVkdXgtZmV0Y2h0ZXInXG5pbXBvcnQgKiBhcyBEZXRlY3RvciBmcm9tICcuL3R3aXR0ZXItaW5qZWN0L2RldGVjdG9yJ1xuXG5pbXBvcnQgeyBnZXRSZWFjdEV2ZW50SGFuZGxlciB9IGZyb20gJy4vdHdpdHRlci1pbmplY3QvaW5qZWN0LWNvbW1vbidcblxuZnVuY3Rpb24gaXNSZWR1eFN0b3JlKHNvbWV0aGluZzogYW55KTogc29tZXRoaW5nIGlzIFJlZHV4U3RvcmUge1xuICBpZiAoIXNvbWV0aGluZykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGlmICh0eXBlb2Ygc29tZXRoaW5nICE9PSAnb2JqZWN0Jykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGlmICh0eXBlb2Ygc29tZXRoaW5nLmdldFN0YXRlICE9PSAnZnVuY3Rpb24nKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBzb21ldGhpbmcuZGlzcGF0Y2ggIT09ICdmdW5jdGlvbicpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICBpZiAodHlwZW9mIHNvbWV0aGluZy5zdWJzY3JpYmUgIT09ICdmdW5jdGlvbicpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICByZXR1cm4gdHJ1ZVxufVxuZnVuY3Rpb24gZmluZFJlZHV4U3RvcmUocmVhY3RSb290OiBIVE1MRWxlbWVudCk6IFJlZHV4U3RvcmUge1xuICBjb25zdCByRXZlbnRIYW5kbGVyID0gZ2V0UmVhY3RFdmVudEhhbmRsZXIocmVhY3RSb290LmNoaWxkcmVuWzBdKVxuICBjb25zdCByZWR1eFN0b3JlID0gckV2ZW50SGFuZGxlci5jaGlsZHJlbi5wcm9wcy5jaGlsZHJlbi5wcm9wcy5zdG9yZVxuICBpZiAoIWlzUmVkdXhTdG9yZShyZWR1eFN0b3JlKSkge1xuICAgIHRocm93IG5ldyBFcnJvcignZmFpbCB0byBmaW5kIHJlZHV4IHN0b3JlJylcbiAgfVxuICByZXR1cm4gcmVkdXhTdG9yZVxufVxuZnVuY3Rpb24gaW5qZWN0KHJlYWN0Um9vdDogSFRNTEVsZW1lbnQpOiB2b2lkIHtcbiAgY29uc3QgcmVkdXhTdG9yZSA9IGZpbmRSZWR1eFN0b3JlKHJlYWN0Um9vdClcbiAgUmVkdXhEaXNwYXRjaGVyLmxpc3RlbkV2ZW50KHJlZHV4U3RvcmUpXG4gIFJlZHV4RmV0Y2hlci5saXN0ZW5FdmVudChyZWR1eFN0b3JlKVxuICBEZXRlY3Rvci5vYnNlcnZlKHJlYWN0Um9vdCwgcmVkdXhTdG9yZSlcbn1cbmV4cG9ydCBmdW5jdGlvbiBpbml0aWFsaXplKCkge1xuICBjb25zdCByZWFjdFJvb3QgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgncmVhY3Qtcm9vdCcpIVxuICBpZiAoJ19yZWFjdFJvb3RDb250YWluZXInIGluIHJlYWN0Um9vdCkge1xuICAgIGluamVjdChyZWFjdFJvb3QpXG4gIH0gZWxzZSB7XG4gICAgc2V0VGltZW91dChpbml0aWFsaXplLCA1MDApXG4gIH1cbn1cblxucmVxdWVzdElkbGVDYWxsYmFjayhpbml0aWFsaXplLCB7XG4gIHRpbWVvdXQ6IDEwMDAwLFxufSlcbiIsImltcG9ydCB7IGRpZywgZ2V0UmVhY3RFdmVudEhhbmRsZXIgfSBmcm9tICcuL2luamVjdC1jb21tb24nXG5pbXBvcnQgKiBhcyBFdmVudE5hbWVzIGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL2V2ZW50LW5hbWVzJ1xuXG5jb25zdCB0b3VjaGVkRWxlbXMgPSBuZXcgV2Vha1NldDxIVE1MRWxlbWVudD4oKVxuXG5mdW5jdGlvbiBmaW5kVHdlZXRJZEZyb21FbGVtZW50KGVsZW06IEhUTUxFbGVtZW50KTogc3RyaW5nIHwgbnVsbCB7XG4gIGlmICghZWxlbS5tYXRjaGVzKCdbZGF0YS10ZXN0aWQ9dHdlZXRdJykpIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3VuZXhwZWN0ZWQgbm9uLXR3ZWV0IGVsZW0/JylcbiAgfVxuICBjb25zdCBhcnRpY2xlID0gZWxlbS5jbG9zZXN0KCdhcnRpY2xlW3JvbGU9YXJ0aWNsZV0nKSEgYXMgSFRNTEVsZW1lbnRcbiAgY29uc3QgcGVybWFsaW5rcyA9IGFydGljbGUucXVlcnlTZWxlY3RvckFsbDxIVE1MQW5jaG9yRWxlbWVudD4oJ2FbaHJlZl49XCIvXCJdW2hyZWYqPVwiL3N0YXR1cy9cIicpXG4gIGZvciAoY29uc3QgcGxpbmsgb2YgcGVybWFsaW5rcykge1xuICAgIGNvbnN0IHR3ZWV0SWRNYXRjaCA9IC9cXC9zdGF0dXNcXC8oXFxkKykvLmV4ZWMocGxpbmsucGF0aG5hbWUpXG4gICAgY29uc3QgdHdlZXRJZCA9IHR3ZWV0SWRNYXRjaCFbMV1cbiAgICBjb25zdCBmaXJzdENoaWxkID0gcGxpbmsuZmlyc3RFbGVtZW50Q2hpbGRcbiAgICBpZiAoZmlyc3RDaGlsZD8udGFnTmFtZSA9PT0gJ1RJTUUnKSB7XG4gICAgICByZXR1cm4gdHdlZXRJZFxuICAgIH1cbiAgICBjb25zdCB2aWFMYWJlbCA9IGFydGljbGUucXVlcnlTZWxlY3RvcihcbiAgICAgICdhW2hyZWY9XCJodHRwczovL2hlbHAudHdpdHRlci5jb20vdXNpbmctdHdpdHRlci9ob3ctdG8tdHdlZXQjc291cmNlLWxhYmVsc1wiXSdcbiAgICApXG4gICAgaWYgKHZpYUxhYmVsPy5wYXJlbnRFbGVtZW50IS5jb250YWlucyhwbGluaykpIHtcbiAgICAgIHJldHVybiB0d2VldElkXG4gICAgfVxuICB9XG4gIC8vIOyLoOqzoO2VnCDtirjsnJfsnbTrgpgg7JWIIOuztOydtOuKlCDtirjsnJcg65Ox7J2YIOqyveyasCwg7Jes6riw7IScIO2KuOyclyBJROulvCDrqrsg7LC+64qU64ukLlxuICByZXR1cm4gbnVsbFxufVxuXG5mdW5jdGlvbiBmaW5kVXNlcklkRnJvbUVsZW1lbnQoZWxlbTogSFRNTEVsZW1lbnQpOiBzdHJpbmcgfCBudWxsIHtcbiAgaWYgKCFlbGVtLm1hdGNoZXMoJ1tkYXRhLXRlc3RpZD1Vc2VyQ2VsbCcpKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKCd1bmV4cGVjdGVkIG5vbi11c2VyY2VsbCBlbGVtPycpXG4gIH1cbiAgY29uc3QgYnRuID0gZWxlbS5xdWVyeVNlbGVjdG9yKCdbcm9sZT1idXR0b25dW2RhdGEtdGVzdGlkXScpIVxuICAvLyDsnpDquLAg7J6Q7Iug7J2YIFVzZXJDZWxs7J2AIOyVhOustCDrsoTtirzrj4Qg7JeG64ukLlxuICAvLyDrmJDtlZwg7Jes65+sIOqzhOyglSDroZzqt7jsnbjsnbQg65CY7Ja07J6I7J2EIOuVjCwg7ZWY64uo7J2YIOqzhOygleyghO2ZmCDrsoTtirzsnYQg64iE66W8IOuVjFxuICAvLyDrgpjtg4DrgpjripQg6rOE7KCV66mU64m0IO2VreuqqeuPhCBVc2VyQ2VsbOuhnCDsnbTro6jslrTsoLjsnojsnYxcbiAgaWYgKCFidG4pIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG4gIGNvbnN0IHVzZXJJZE1hdGNoID0gL14oXFxkKykvLmV4ZWMoYnRuLmdldEF0dHJpYnV0ZSgnZGF0YS10ZXN0aWQnKSEpXG4gIGlmICghdXNlcklkTWF0Y2gpIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG4gIGNvbnN0IHVzZXJJZCA9IHVzZXJJZE1hdGNoWzFdXG4gIHJldHVybiB1c2VySWRcbn1cblxuZnVuY3Rpb24gZ2V0VHdlZXRFbnRpdHlCeUlkKHN0YXRlOiBhbnksIHR3ZWV0SWQ6IHN0cmluZyk6IFR3ZWV0RW50aXR5IHwgbnVsbCB7XG4gIGNvbnN0IGVudGl0aWVzID0gc3RhdGUuZW50aXRpZXMudHdlZXRzLmVudGl0aWVzXG4gIGZvciAoY29uc3QgZW50aXR5XyBvZiBPYmplY3QudmFsdWVzKGVudGl0aWVzKSkge1xuICAgIGNvbnN0IGVudGl0eSA9IGVudGl0eV8gYXMgYW55XG4gICAgaWYgKGVudGl0eS5pZF9zdHIudG9Mb3dlckNhc2UoKSA9PT0gdHdlZXRJZCkge1xuICAgICAgcmV0dXJuIGVudGl0eVxuICAgIH1cbiAgfVxuICByZXR1cm4gbnVsbFxufVxuXG5mdW5jdGlvbiBnZXRVc2VyRW50aXR5QnlJZChzdGF0ZTogYW55LCB1c2VySWQ6IHN0cmluZyk6IFR3aXR0ZXJVc2VyIHwgbnVsbCB7XG4gIGNvbnN0IGVudGl0aWVzID0gc3RhdGUuZW50aXRpZXMudXNlcnMuZW50aXRpZXNcbiAgcmV0dXJuIGVudGl0aWVzW3VzZXJJZF0gfHwgbnVsbFxufVxuXG5mdW5jdGlvbiBpbnNwZWN0VHdlZXRFbGVtZW50KHN0YXRlOiBhbnksIGVsZW06IEhUTUxFbGVtZW50KSB7XG4gIGNvbnN0IHR3ZWV0SWQgPSBmaW5kVHdlZXRJZEZyb21FbGVtZW50KGVsZW0pXG4gIGlmICghdHdlZXRJZCkge1xuICAgIHJldHVybiBudWxsXG4gIH1cbiAgY29uc3QgdHdlZXRFbnRpdHkgPSBnZXRUd2VldEVudGl0eUJ5SWQoc3RhdGUsIHR3ZWV0SWQpXG4gIGlmICghdHdlZXRFbnRpdHkpIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG4gIGNvbnN0IHVzZXIgPSBnZXRVc2VyRW50aXR5QnlJZChzdGF0ZSwgdHdlZXRFbnRpdHkudXNlcilcbiAgaWYgKCF1c2VyKSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxuICBsZXQgcXVvdGVkVHdlZXQ6IFR3ZWV0IHwgbnVsbCA9IG51bGxcbiAgaWYgKHR3ZWV0RW50aXR5LmlzX3F1b3RlX3N0YXR1cykge1xuICAgIGNvbnN0IHF1b3RlZFR3ZWV0RW50aXR5ID0gZ2V0VHdlZXRFbnRpdHlCeUlkKHN0YXRlLCB0d2VldEVudGl0eS5xdW90ZWRfc3RhdHVzISlcbiAgICBpZiAocXVvdGVkVHdlZXRFbnRpdHkpIHtcbiAgICAgIGNvbnN0IHVzZXIgPSBnZXRVc2VyRW50aXR5QnlJZChzdGF0ZSwgcXVvdGVkVHdlZXRFbnRpdHkudXNlcilcbiAgICAgIGlmICh1c2VyKSB7XG4gICAgICAgIHF1b3RlZFR3ZWV0ID0gT2JqZWN0LmFzc2lnbih7fSwgcXVvdGVkVHdlZXRFbnRpdHksIHtcbiAgICAgICAgICB1c2VyLFxuICAgICAgICB9KVxuICAgICAgfVxuICAgIH1cbiAgfVxuICBjb25zdCB0d2VldDogVHdlZXQgPSBPYmplY3QuYXNzaWduKHt9LCB0d2VldEVudGl0eSwge1xuICAgIHVzZXIsXG4gICAgcXVvdGVkX3N0YXR1czogcXVvdGVkVHdlZXQsXG4gIH0pXG4gIHJldHVybiB0d2VldFxufVxuXG5mdW5jdGlvbiBpbnNwZWN0VXNlckNlbGxFbGVtZW50KHN0YXRlOiBhbnksIGVsZW06IEhUTUxFbGVtZW50KSB7XG4gIGNvbnN0IHVzZXJJZCA9IGZpbmRVc2VySWRGcm9tRWxlbWVudChlbGVtKVxuICBpZiAoIXVzZXJJZCkge1xuICAgIHJldHVybiBudWxsXG4gIH1cbiAgY29uc3QgdXNlciA9IGdldFVzZXJFbnRpdHlCeUlkKHN0YXRlLCB1c2VySWQpXG4gIGlmICghdXNlcikge1xuICAgIHJldHVybiBudWxsXG4gIH1cbiAgcmV0dXJuIHVzZXJcbn1cblxuZnVuY3Rpb24gdXNlckNlbGxEZXRlY3RvcihzdGF0ZTogYW55KSB7XG4gIGNvbnN0IHVzZXJDZWxscyA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGw8SFRNTEVsZW1lbnQ+KCdbZGF0YS10ZXN0aWQ9VXNlckNlbGxdJylcbiAgZm9yIChjb25zdCBlbGVtIG9mIHVzZXJDZWxscykge1xuICAgIGlmICh0b3VjaGVkRWxlbXMuaGFzKGVsZW0pKSB7XG4gICAgICBjb250aW51ZVxuICAgIH1cbiAgICB0b3VjaGVkRWxlbXMuYWRkKGVsZW0pXG4gICAgY29uc3QgdXNlciA9IGluc3BlY3RVc2VyQ2VsbEVsZW1lbnQoc3RhdGUsIGVsZW0pXG4gICAgaWYgKCF1c2VyKSB7XG4gICAgICBjb250aW51ZVxuICAgIH1cbiAgICBjb25zdCBldmVudCA9IG5ldyBDdXN0b21FdmVudChFdmVudE5hbWVzLlVTRVJDRUxMLCB7XG4gICAgICBidWJibGVzOiB0cnVlLFxuICAgICAgZGV0YWlsOiB7IHVzZXIgfSxcbiAgICB9KVxuICAgIGNvbnN0IGludE9ic2VydmVyID0gbmV3IEludGVyc2VjdGlvbk9ic2VydmVyKChlbnRyaWVzLCBvYnNlcnZlcikgPT4ge1xuICAgICAgZm9yIChjb25zdCBlbnQgb2YgZW50cmllcykge1xuICAgICAgICBpZiAoIWVudC5pc0ludGVyc2VjdGluZykge1xuICAgICAgICAgIGNvbnRpbnVlXG4gICAgICAgIH1cbiAgICAgICAgb2JzZXJ2ZXIudW5vYnNlcnZlKGVudC50YXJnZXQpXG4gICAgICAgIHJlcXVlc3RJZGxlQ2FsbGJhY2soKCkgPT4gZWxlbS5kaXNwYXRjaEV2ZW50KGV2ZW50KSwge1xuICAgICAgICAgIHRpbWVvdXQ6IDEwMDAsXG4gICAgICAgIH0pXG4gICAgICB9XG4gICAgfSlcbiAgICBpbnRPYnNlcnZlci5vYnNlcnZlKGVsZW0pXG4gIH1cbn1cblxuZnVuY3Rpb24gc2VuZERNQ29udmVyc2F0aW9uc1RvRXh0ZW5zaW9uKCkge1xuICBjb25zdCBjb252RWxlbXMgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCdbZGF0YS10ZXN0aWQ9Y29udmVyc2F0aW9uXScpXG4gIGZvciAoY29uc3QgZWxlbSBvZiBjb252RWxlbXMpIHtcbiAgICBjb25zdCBwYXJlbnQgPSBlbGVtLnBhcmVudEVsZW1lbnQhXG4gICAgY29uc3QgckV2ZW50SGFuZGxlciA9IGdldFJlYWN0RXZlbnRIYW5kbGVyKHBhcmVudCkhXG4gICAgY29uc3QgY29udklkID0gZGlnKCgpID0+IHJFdmVudEhhbmRsZXIuY2hpbGRyZW5bMF0ucHJvcHMuY29udmVyc2F0aW9uSWQpXG4gICAgaWYgKHR5cGVvZiBjb252SWQgIT09ICdzdHJpbmcnKSB7XG4gICAgICB0aHJvdyBuZXcgRXJyb3IoJ2ZhaWxlZCB0byBnZXQgY29udi4gaWQnKVxuICAgIH1cbiAgICBlbGVtLnNldEF0dHJpYnV0ZSgnZGF0YS1taXJyb3JibG9jay1jb252ZXJzYXRpb24taWQnLCBjb252SWQpXG4gICAgY29uc3QgY3VzdG9tRXZlbnQgPSBuZXcgQ3VzdG9tRXZlbnQoRXZlbnROYW1lcy5ETSwge1xuICAgICAgZGV0YWlsOiB7IGNvbnZJZCB9LFxuICAgIH0pXG4gICAgZG9jdW1lbnQuZGlzcGF0Y2hFdmVudChjdXN0b21FdmVudClcbiAgfVxufVxuXG5mdW5jdGlvbiB0d2VldERldGVjdG9yKHN0YXRlOiBhbnkpIHtcbiAgY29uc3QgdHdlZXRFbGVtcyA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGw8SFRNTEVsZW1lbnQ+KCdbZGF0YS10ZXN0aWQ9dHdlZXRdJylcbiAgZm9yIChjb25zdCBlbGVtIG9mIHR3ZWV0RWxlbXMpIHtcbiAgICAvLyBUcmVlLVVJIOuTseyXkOyEnCwg7Yq47JyX7J2EIOygkeyXiOuLpCDtjrTrqbQg67aZ7JeI642YIOuxg+yngOqwgCDsgqzrnbzsoLgg64uk7IucIOu2meyXrOyVvCDtlahcbiAgICAvLyDqt7jrg6Ug7KSR67O17LKY66as66W8IO2XiOyaqe2VmOq4sOuhnD9cbiAgICAvLyBpZiAodG91Y2hlZEVsZW1zLmhhcyhlbGVtKSkge1xuICAgIC8vICAgY29udGludWVcbiAgICAvLyB9XG4gICAgLy8gdG91Y2hlZEVsZW1zLmFkZChlbGVtKVxuICAgIGNvbnN0IHR3ZWV0ID0gaW5zcGVjdFR3ZWV0RWxlbWVudChzdGF0ZSwgZWxlbSlcbiAgICBpZiAoIXR3ZWV0KSB7XG4gICAgICBjb250aW51ZVxuICAgIH1cbiAgICBjb25zdCBldmVudCA9IG5ldyBDdXN0b21FdmVudChFdmVudE5hbWVzLlRXRUVULCB7XG4gICAgICBidWJibGVzOiB0cnVlLFxuICAgICAgZGV0YWlsOiB7IHR3ZWV0IH0sXG4gICAgfSlcbiAgICBjb25zdCBpbnRPYnNlcnZlciA9IG5ldyBJbnRlcnNlY3Rpb25PYnNlcnZlcigoZW50cmllcywgb2JzZXJ2ZXIpID0+IHtcbiAgICAgIGZvciAoY29uc3QgZW50IG9mIGVudHJpZXMpIHtcbiAgICAgICAgaWYgKCFlbnQuaXNJbnRlcnNlY3RpbmcpIHtcbiAgICAgICAgICBjb250aW51ZVxuICAgICAgICB9XG4gICAgICAgIG9ic2VydmVyLnVub2JzZXJ2ZShlbnQudGFyZ2V0KVxuICAgICAgICByZXF1ZXN0SWRsZUNhbGxiYWNrKCgpID0+IGVsZW0uZGlzcGF0Y2hFdmVudChldmVudCksIHtcbiAgICAgICAgICB0aW1lb3V0OiAxMDAwLFxuICAgICAgICB9KVxuICAgICAgfVxuICAgIH0pXG4gICAgaW50T2JzZXJ2ZXIub2JzZXJ2ZShlbGVtKVxuICB9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBvYnNlcnZlKHJlYWN0Um9vdDogRWxlbWVudCwgcmVkdXhTdG9yZTogUmVkdXhTdG9yZSk6IHZvaWQge1xuICBuZXcgTXV0YXRpb25PYnNlcnZlcigoKSA9PiB7XG4gICAgY29uc3Qgc3RhdGUgPSByZWR1eFN0b3JlLmdldFN0YXRlKClcbiAgICB0d2VldERldGVjdG9yKHN0YXRlKVxuICAgIHVzZXJDZWxsRGV0ZWN0b3Ioc3RhdGUpXG4gICAgc2VuZERNQ29udmVyc2F0aW9uc1RvRXh0ZW5zaW9uKClcbiAgfSkub2JzZXJ2ZShyZWFjdFJvb3QsIHtcbiAgICBzdWJ0cmVlOiB0cnVlLFxuICAgIGNoaWxkTGlzdDogdHJ1ZSxcbiAgICAvLyBjaGFyYWN0ZXJEYXRhOiB0cnVlLFxuICB9KVxufVxuIiwiZXhwb3J0IGZ1bmN0aW9uIGRpZyhvYmo6ICgpID0+IGFueSk6IGFueSB7XG4gIHRyeSB7XG4gICAgcmV0dXJuIG9iaigpXG4gIH0gY2F0Y2ggKGVycikge1xuICAgIGlmIChlcnIgaW5zdGFuY2VvZiBUeXBlRXJyb3IpIHtcbiAgICAgIHJldHVybiBudWxsXG4gICAgfSBlbHNlIHtcbiAgICAgIHRocm93IGVyclxuICAgIH1cbiAgfVxufVxuXG5leHBvcnQgZnVuY3Rpb24gZ2V0UmVhY3RFdmVudEhhbmRsZXIodGFyZ2V0OiBFbGVtZW50KTogYW55IHtcbiAgY29uc3Qga2V5ID0gT2JqZWN0LmtleXModGFyZ2V0KVxuICAgIC5maWx0ZXIoKGs6IHN0cmluZykgPT4gay5zdGFydHNXaXRoKCdfX3JlYWN0RXZlbnRIYW5kbGVycycpKVxuICAgIC5wb3AoKVxuICByZXR1cm4ga2V5ID8gKHRhcmdldCBhcyBhbnkpW2tleV0gOiBudWxsXG59XG4iLCJpbXBvcnQgeyB2MSBhcyB1dWlkdjEgfSBmcm9tICd1dWlkJ1xuXG5mdW5jdGlvbiBhZGRFdmVudChuYW1lOiBSZWR1eFN0b3JlRXZlbnROYW1lcywgY2FsbGJhY2s6IChldmVudDogQ3VzdG9tRXZlbnQpID0+IHZvaWQpOiB2b2lkIHtcbiAgZG9jdW1lbnQuYWRkRXZlbnRMaXN0ZW5lcihgTWlycm9yQmxvY2stPiR7bmFtZX1gLCBldmVudCA9PiB7XG4gICAgY29uc3QgY3VzdG9tRXZlbnQgPSBldmVudCBhcyBDdXN0b21FdmVudFxuICAgIGNhbGxiYWNrKGN1c3RvbUV2ZW50KVxuICB9KVxufVxuZXhwb3J0IGZ1bmN0aW9uIGxpc3RlbkV2ZW50KHJlZHV4U3RvcmU6IFJlZHV4U3RvcmUpOiB2b2lkIHtcbiAgYWRkRXZlbnQoJ2luc2VydFNpbmdsZVVzZXJJbnRvU3RvcmUnLCBldmVudCA9PiB7XG4gICAgY29uc3QgdXNlcjogVHdpdHRlclVzZXIgPSBldmVudC5kZXRhaWwudXNlclxuICAgIHJlZHV4U3RvcmUuZGlzcGF0Y2goe1xuICAgICAgdHlwZTogJ3J3ZWIvZW50aXRpZXMvQUREX0VOVElUSUVTJyxcbiAgICAgIHBheWxvYWQ6IHtcbiAgICAgICAgdXNlcnM6IHtcbiAgICAgICAgICBbdXNlci5pZF9zdHJdOiB1c2VyLFxuICAgICAgICB9LFxuICAgICAgfSxcbiAgICB9KVxuICB9KVxuICBhZGRFdmVudCgnaW5zZXJ0TXVsdGlwbGVVc2Vyc0ludG9TdG9yZScsIGV2ZW50ID0+IHtcbiAgICBjb25zdCB1c2VyczogVHdpdHRlclVzZXJFbnRpdGllcyA9IGV2ZW50LmRldGFpbC51c2Vyc1xuICAgIHJlZHV4U3RvcmUuZGlzcGF0Y2goe1xuICAgICAgdHlwZTogJ3J3ZWIvZW50aXRpZXMvQUREX0VOVElUSUVTJyxcbiAgICAgIHBheWxvYWQ6IHtcbiAgICAgICAgdXNlcnMsXG4gICAgICB9LFxuICAgIH0pXG4gIH0pXG4gIGFkZEV2ZW50KCdhZnRlckJsb2NrVXNlcicsIGV2ZW50ID0+IHtcbiAgICBjb25zdCB7IHVzZXIgfSA9IGV2ZW50LmRldGFpbFxuICAgIGNvbnN0IHVzZXJJZCA9IHVzZXIuaWRfc3RyXG4gICAgY29uc3QgdW5pcUlkID0gdXVpZHYxKClcbiAgICByZWR1eFN0b3JlLmRpc3BhdGNoKHtcbiAgICAgIHR5cGU6ICdyd2ViL2Jsb2NrZWRVc2Vycy9CTE9DS19SRVFVRVNUJyxcbiAgICAgIG9wdGltaXN0OiB7XG4gICAgICAgIGlkOiB1bmlxSWQsXG4gICAgICAgIHR5cGU6ICdCRUdJTicsXG4gICAgICB9LFxuICAgICAgbWV0YToge1xuICAgICAgICB1c2VySWQsXG4gICAgICB9LFxuICAgIH0pXG4gIH0pXG4gIGFkZEV2ZW50KCd0b2FzdE1lc3NhZ2UnLCBldmVudCA9PiB7XG4gICAgY29uc3QgeyB0ZXh0IH0gPSBldmVudC5kZXRhaWxcbiAgICByZWR1eFN0b3JlLmRpc3BhdGNoKHtcbiAgICAgIHR5cGU6ICdyd2ViL3RvYXN0cy9BRERfVE9BU1QnLFxuICAgICAgcGF5bG9hZDogeyB0ZXh0IH0sXG4gICAgfSlcbiAgfSlcbn1cbiIsImltcG9ydCB7IGRpZyB9IGZyb20gJy4vaW5qZWN0LWNvbW1vbidcblxuZnVuY3Rpb24gYWRkRXZlbnRXaXRoUmVzcG9uc2UoXG4gIG5hbWU6IFJlZHV4U3RvcmVFdmVudE5hbWVzLFxuICBjYWxsYmFjazogKGV2ZW50OiBDdXN0b21FdmVudCkgPT4gYW55XG4pOiB2b2lkIHtcbiAgZG9jdW1lbnQuYWRkRXZlbnRMaXN0ZW5lcihgTWlycm9yQmxvY2stLT4ke25hbWV9YCwgZXZlbnQgPT4ge1xuICAgIGNvbnN0IGN1c3RvbUV2ZW50ID0gZXZlbnQgYXMgQ3VzdG9tRXZlbnRcbiAgICBjb25zdCB7IG5vbmNlIH0gPSBjdXN0b21FdmVudC5kZXRhaWxcbiAgICBjb25zdCByZXNwb25zZSA9IGNhbGxiYWNrKGN1c3RvbUV2ZW50KVxuICAgIGNvbnN0IHJlc3BvbnNlRXZlbnQgPSBuZXcgQ3VzdG9tRXZlbnQoYE1pcnJvckJsb2NrPC0tJHtuYW1lfS4ke25vbmNlfWAsIHtcbiAgICAgIGRldGFpbDogcmVzcG9uc2UsXG4gICAgfSlcbiAgICBkb2N1bWVudC5kaXNwYXRjaEV2ZW50KHJlc3BvbnNlRXZlbnQpXG4gIH0pXG59XG5leHBvcnQgZnVuY3Rpb24gbGlzdGVuRXZlbnQocmVkdXhTdG9yZTogUmVkdXhTdG9yZSk6IHZvaWQge1xuICBhZGRFdmVudFdpdGhSZXNwb25zZSgnZ2V0TXVsdGlwbGVVc2Vyc0J5SWRzJywgZXZlbnQgPT4ge1xuICAgIGNvbnN0IHN0YXRlID0gcmVkdXhTdG9yZS5nZXRTdGF0ZSgpXG4gICAgY29uc3QgeyB1c2VySWRzIH0gPSBldmVudC5kZXRhaWxcbiAgICBjb25zdCByZXN1bHQ6IHsgW2lkOiBzdHJpbmddOiBUd2l0dGVyVXNlciB9ID0ge31cbiAgICBjb25zdCB1c2VyRW50aXRpZXM6IFR3aXR0ZXJVc2VyRW50aXRpZXMgPSBkaWcoKCkgPT4gc3RhdGUuZW50aXRpZXMudXNlcnMuZW50aXRpZXMpIHx8IFtdXG4gICAgZm9yIChjb25zdCB1c2VySWQgb2YgdXNlcklkcykge1xuICAgICAgcmVzdWx0W3VzZXJJZF0gPSB1c2VyRW50aXRpZXNbdXNlcklkXVxuICAgIH1cbiAgICByZXR1cm4gcmVzdWx0XG4gIH0pXG4gIGFkZEV2ZW50V2l0aFJlc3BvbnNlKCdnZXRVc2VyQnlOYW1lJywgZXZlbnQgPT4ge1xuICAgIGNvbnN0IHN0YXRlID0gcmVkdXhTdG9yZS5nZXRTdGF0ZSgpXG4gICAgY29uc3QgeyB1c2VyTmFtZSB9ID0gZXZlbnQuZGV0YWlsXG4gICAgY29uc3QgdGFyZ2V0VXNlck5hbWUgPSB1c2VyTmFtZS50b0xvd2VyQ2FzZSgpXG4gICAgY29uc3QgdXNlckVudGl0aWVzOiBUd2l0dGVyVXNlckVudGl0aWVzID0gZGlnKCgpID0+IHN0YXRlLmVudGl0aWVzLnVzZXJzLmVudGl0aWVzKSB8fCBbXVxuICAgIGZvciAoY29uc3QgdXNlckVudGl0eSBvZiBPYmplY3QudmFsdWVzKHVzZXJFbnRpdGllcykpIHtcbiAgICAgIGNvbnN0IG5hbWUgPSB1c2VyRW50aXR5LnNjcmVlbl9uYW1lLnRvTG93ZXJDYXNlKClcbiAgICAgIGlmICh0YXJnZXRVc2VyTmFtZSA9PT0gbmFtZSkge1xuICAgICAgICByZXR1cm4gdXNlckVudGl0eVxuICAgICAgfVxuICAgIH1cbiAgICByZXR1cm4gbnVsbFxuICB9KVxuICBhZGRFdmVudFdpdGhSZXNwb25zZSgnZ2V0RE1EYXRhJywgZXZlbnQgPT4ge1xuICAgIGNvbnN0IHN0YXRlID0gcmVkdXhTdG9yZS5nZXRTdGF0ZSgpXG4gICAgY29uc3QgeyBjb252SWQgfSA9IGV2ZW50LmRldGFpbFxuICAgIGNvbnN0IGNvbnZlcnNhdGlvbnMgPSBkaWcoKCkgPT4gc3RhdGUuZGlyZWN0TWVzc2FnZXMuY29udmVyc2F0aW9ucylcbiAgICBpZiAoIWNvbnZlcnNhdGlvbnMpIHtcbiAgICAgIHJldHVybiBudWxsXG4gICAgfVxuICAgIGNvbnN0IGNvbnZEYXRhID0gZGlnKCgpID0+IGNvbnZlcnNhdGlvbnNbY29udklkXSlcbiAgICByZXR1cm4gY29udkRhdGEgfHwgbnVsbFxuICB9KVxufVxuIl0sInNvdXJjZVJvb3QiOiIifQ==