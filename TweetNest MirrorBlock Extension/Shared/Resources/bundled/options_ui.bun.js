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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/options/options.ts");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./src/extoption.ts":
/*!**************************!*\
  !*** ./src/extoption.ts ***!
  \**************************/
/*! exports provided: save, load */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "save", function() { return save; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "load", function() { return load; });
const defaults = Object.freeze({
    outlineBlockUser: false,
    enableBlockReflection: false,
    blockMutedUser: false,
    alwaysImmediatelyBlockMode: false
});
async function save(newOption) {
    const option = Object.assign({
    }, defaults, newOption);
    return browser.storage.local.set({
        option
    });
}
async function load() {
    const loaded = await browser.storage.local.get('option');
    return Object.assign({
    }, defaults, loaded.option);
}


/***/ }),

/***/ "./src/options/options.ts":
/*!********************************!*\
  !*** ./src/options/options.ts ***!
  \********************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _extoption__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/extoption */ "./src/extoption.ts");
/* harmony import */ var _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/i18n */ "./src/scripts/i18n.ts");


const elements = {
    outlineBlockUser: document.getElementById('outlineBlockUser'),
    enableBlockReflection: document.getElementById('enableBlockReflection'),
    blockMutedUser: document.getElementById('blockMutedUser'),
    alwaysImmediatelyBlockMode: document.getElementById('alwaysImmediatelyBlockMode')
};
async function saveOption() {
    const option = await _extoption__WEBPACK_IMPORTED_MODULE_0__["load"]();
    for (const [key_, elem] of Object.entries(elements)){
        const key = key_;
        option[key] = elem.checked;
    }
    return _extoption__WEBPACK_IMPORTED_MODULE_0__["save"](option);
}
async function loadOption() {
    const option = await _extoption__WEBPACK_IMPORTED_MODULE_0__["load"]();
    for (const [key_, elem] of Object.entries(elements)){
        const key = key_;
        elem.disabled = false;
        elem.checked = option[key];
    }
}
function displayVersion() {
    const elem = document.getElementById('version');
    const manifest = browser.runtime.getManifest();
    elem.textContent = manifest.version;
}
function init() {
    _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["applyI18nOnHtml"]();
    loadOption();
    for (const input of document.querySelectorAll('.field input')){
        input.addEventListener('change', ()=>{
            saveOption();
        });
    }
    displayVersion();
}
document.addEventListener('DOMContentLoaded', init);


/***/ }),

/***/ "./src/scripts/i18n.ts":
/*!*****************************!*\
  !*** ./src/scripts/i18n.ts ***!
  \*****************************/
/*! exports provided: getMessage, applyI18nOnHtml */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getMessage", function() { return getMessage; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "applyI18nOnHtml", function() { return applyI18nOnHtml; });
function getMessage(key, substs = undefined) {
    if (Array.isArray(substs)) {
        return browser.i18n.getMessage(key, substs.map((s)=>s.toLocaleString()
        ));
    } else if (typeof substs === 'number') {
        return browser.i18n.getMessage(key, substs.toLocaleString());
    } else {
        return browser.i18n.getMessage(key, substs);
    }
}
function tryGetMessage(messageName) {
    const message = getMessage(messageName);
    if (!message) {
        throw new Error(`invalid messageName? "${messageName}"`);
    }
    return message;
}
function applyI18nOnHtml() {
    const i18nTextElements = document.querySelectorAll('[data-i18n-text]');
    for (const elem of i18nTextElements){
        const messageName = elem.getAttribute('data-i18n-text');
        const message = tryGetMessage(messageName);
        // console.debug('%o .textContent = %s [from %s]', elem, message, messageName)
        elem.textContent = message;
    }
    const i18nAttrsElements = document.querySelectorAll('[data-i18n-attrs]');
    for (const elem1 of i18nAttrsElements){
        // example:
        // <span data-i18n-attrs="title=popup_title&alt=popup_alt"></span>
        const attrsToNameSerialized = elem1.getAttribute('data-i18n-attrs');
        const attrsToNameParsed = new URLSearchParams(attrsToNameSerialized);
        attrsToNameParsed.forEach((value, key)=>{
            // console.debug('|attr| key:"%s", value:"%s"', key, value)
            const message = tryGetMessage(value);
            elem1.setAttribute(key, message);
        });
    }
}
function checkMissingTranslations(// ko/messages.json 엔 있고 en/messages.json 엔 없는 키가 있으면
// TypeScript 컴파일러가 타입에러를 일으킨다.
// tsconfig.json의 resolveJsonModule 옵션을 켜야 함
keys, find, _check = find(keys)) {
}
checkMissingTranslations;


/***/ })

/******/ });
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V4dG9wdGlvbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvb3B0aW9ucy9vcHRpb25zLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL2kxOG4udHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtRQUFBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBOzs7UUFHQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMENBQTBDLGdDQUFnQztRQUMxRTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBLHdEQUF3RCxrQkFBa0I7UUFDMUU7UUFDQSxpREFBaUQsY0FBYztRQUMvRDs7UUFFQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0EseUNBQXlDLGlDQUFpQztRQUMxRSxnSEFBZ0gsbUJBQW1CLEVBQUU7UUFDckk7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQSwyQkFBMkIsMEJBQTBCLEVBQUU7UUFDdkQsaUNBQWlDLGVBQWU7UUFDaEQ7UUFDQTtRQUNBOztRQUVBO1FBQ0Esc0RBQXNELCtEQUErRDs7UUFFckg7UUFDQTs7O1FBR0E7UUFDQTs7Ozs7Ozs7Ozs7Ozs7OztNQ2xGTSxRQUFRLEdBQUcsTUFBTSxDQUFDLE1BQU07SUFDNUIsZ0JBQWdCLEVBQUUsS0FBSztJQUN2QixxQkFBcUIsRUFBRSxLQUFLO0lBQzVCLGNBQWMsRUFBRSxLQUFLO0lBQ3JCLDBCQUEwQixFQUFFLEtBQUs7O2VBR2IsSUFBSSxDQUFDLFNBQTRCO1VBQy9DLE1BQU0sR0FBRyxNQUFNLENBQUMsTUFBTTtPQUl0QixRQUFRLEVBQUUsU0FBUztXQUNsQixPQUFPLENBQUMsT0FBTyxDQUFDLEtB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Y0FDM0QsaUJBQWlCLE9BQU8sZUFBZSxDQUFDLHFCQUFxQjtRQUNuRSxpQkFBaUIsQ0FBQyxPQUFPLEVBQUUsS0FBSyxFQUFFLEdBQUc7WUFDbkMsRUFBMkQ7a0JBQ3JELE9BQU8sR0FBRyxhQUFhLENBQUMsS0FBSztZQUNuQyxLQUFJLENBQUMsWUFBWSxDQUFDLEdBQUcsRUFBRSxPQUFPOzs7O1NBSzNCLHdCQUF3QixDQUMvQixFQUFxRCxtREFBc0I7QUFDckQsRUFBUyw2QkFBNEI7QUFDL0IsRUFBZ0I7QUFDNUMsSUFRSyxFQUNMLElBQTRCLEVBQzVCLE1BQU0sR0FBRyxJQUFJLENBQUMsSUFBSTs7QUFFcEIsd0JBQXdCIiwiZmlsZSI6Im9wdGlvbnNfdWkuYnVuLmpzIiwic291cmNlc0NvbnRlbnQiOlsiIFx0Ly8gVGhlIG1vZHVsZSBjYWNoZVxuIFx0dmFyIGluc3RhbGxlZE1vZHVsZXMgPSB7fTtcblxuIFx0Ly8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbiBcdGZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblxuIFx0XHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcbiBcdFx0aWYoaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0pIHtcbiBcdFx0XHRyZXR1cm4gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0uZXhwb3J0cztcbiBcdFx0fVxuIFx0XHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuIFx0XHR2YXIgbW9kdWxlID0gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0gPSB7XG4gXHRcdFx0aTogbW9kdWxlSWQsXG4gXHRcdFx0bDogZmFsc2UsXG4gXHRcdFx0ZXhwb3J0czoge31cbiBcdFx0fTtcblxuIFx0XHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cbiBcdFx0bW9kdWxlc1ttb2R1bGVJZF0uY2FsbChtb2R1bGUuZXhwb3J0cywgbW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cbiBcdFx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuIFx0XHRtb2R1bGUubCA9IHRydWU7XG5cbiBcdFx0Ly8gUmV0dXJuIHRoZSBleHBvcnRzIG9mIHRoZSBtb2R1bGVcbiBcdFx0cmV0dXJuIG1vZHVsZS5leHBvcnRzO1xuIFx0fVxuXG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlcyBvYmplY3QgKF9fd2VicGFja19tb2R1bGVzX18pXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm0gPSBtb2R1bGVzO1xuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZSBjYWNoZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5jID0gaW5zdGFsbGVkTW9kdWxlcztcblxuIFx0Ly8gZGVmaW5lIGdldHRlciBmdW5jdGlvbiBmb3IgaGFybW9ueSBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQgPSBmdW5jdGlvbihleHBvcnRzLCBuYW1lLCBnZXR0ZXIpIHtcbiBcdFx0aWYoIV9fd2VicGFja19yZXF1aXJlX18ubyhleHBvcnRzLCBuYW1lKSkge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBuYW1lLCB7IGVudW1lcmFibGU6IHRydWUsIGdldDogZ2V0dGVyIH0pO1xuIFx0XHR9XG4gXHR9O1xuXG4gXHQvLyBkZWZpbmUgX19lc01vZHVsZSBvbiBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIgPSBmdW5jdGlvbihleHBvcnRzKSB7XG4gXHRcdGlmKHR5cGVvZiBTeW1ib2wgIT09ICd1bmRlZmluZWQnICYmIFN5bWJvbC50b1N0cmluZ1RhZykge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBTeW1ib2wudG9TdHJpbmdUYWcsIHsgdmFsdWU6ICdNb2R1bGUnIH0pO1xuIFx0XHR9XG4gXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCAnX19lc01vZHVsZScsIHsgdmFsdWU6IHRydWUgfSk7XG4gXHR9O1xuXG4gXHQvLyBjcmVhdGUgYSBmYWtlIG5hbWVzcGFjZSBvYmplY3RcbiBcdC8vIG1vZGUgJiAxOiB2YWx1ZSBpcyBhIG1vZHVsZSBpZCwgcmVxdWlyZSBpdFxuIFx0Ly8gbW9kZSAmIDI6IG1lcmdlIGFsbCBwcm9wZXJ0aWVzIG9mIHZhbHVlIGludG8gdGhlIG5zXG4gXHQvLyBtb2RlICYgNDogcmV0dXJuIHZhbHVlIHdoZW4gYWxyZWFkeSBucyBvYmplY3RcbiBcdC8vIG1vZGUgJiA4fDE6IGJlaGF2ZSBsaWtlIHJlcXVpcmVcbiBcdF9fd2VicGFja19yZXF1aXJlX18udCA9IGZ1bmN0aW9uKHZhbHVlLCBtb2RlKSB7XG4gXHRcdGlmKG1vZGUgJiAxKSB2YWx1ZSA9IF9fd2VicGFja19yZXF1aXJlX18odmFsdWUpO1xuIFx0XHRpZihtb2RlICYgOCkgcmV0dXJuIHZhbHVlO1xuIFx0XHRpZigobW9kZSAmIDQpICYmIHR5cGVvZiB2YWx1ZSA9PT0gJ29iamVjdCcgJiYgdmFsdWUgJiYgdmFsdWUuX19lc01vZHVsZSkgcmV0dXJuIHZhbHVlO1xuIFx0XHR2YXIgbnMgPSBPYmplY3QuY3JlYXRlKG51bGwpO1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIobnMpO1xuIFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkobnMsICdkZWZhdWx0JywgeyBlbnVtZXJhYmxlOiB0cnVlLCB2YWx1ZTogdmFsdWUgfSk7XG4gXHRcdGlmKG1vZGUgJiAyICYmIHR5cGVvZiB2YWx1ZSAhPSAnc3RyaW5nJykgZm9yKHZhciBrZXkgaW4gdmFsdWUpIF9fd2VicGFja19yZXF1aXJlX18uZChucywga2V5LCBmdW5jdGlvbihrZXkpIHsgcmV0dXJuIHZhbHVlW2tleV07IH0uYmluZChudWxsLCBrZXkpKTtcbiBcdFx0cmV0dXJuIG5zO1xuIFx0fTtcblxuIFx0Ly8gZ2V0RGVmYXVsdEV4cG9ydCBmdW5jdGlvbiBmb3IgY29tcGF0aWJpbGl0eSB3aXRoIG5vbi1oYXJtb255IG1vZHVsZXNcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubiA9IGZ1bmN0aW9uKG1vZHVsZSkge1xuIFx0XHR2YXIgZ2V0dGVyID0gbW9kdWxlICYmIG1vZHVsZS5fX2VzTW9kdWxlID9cbiBcdFx0XHRmdW5jdGlvbiBnZXREZWZhdWx0KCkgeyByZXR1cm4gbW9kdWxlWydkZWZhdWx0J107IH0gOlxuIFx0XHRcdGZ1bmN0aW9uIGdldE1vZHVsZUV4cG9ydHMoKSB7IHJldHVybiBtb2R1bGU7IH07XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18uZChnZXR0ZXIsICdhJywgZ2V0dGVyKTtcbiBcdFx0cmV0dXJuIGdldHRlcjtcbiBcdH07XG5cbiBcdC8vIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbFxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5vID0gZnVuY3Rpb24ob2JqZWN0LCBwcm9wZXJ0eSkgeyByZXR1cm4gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsKG9iamVjdCwgcHJvcGVydHkpOyB9O1xuXG4gXHQvLyBfX3dlYnBhY2tfcHVibGljX3BhdGhfX1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5wID0gXCJcIjtcblxuXG4gXHQvLyBMb2FkIGVudHJ5IG1vZHVsZSBhbmQgcmV0dXJuIGV4cG9ydHNcbiBcdHJldHVybiBfX3dlYnBhY2tfcmVxdWlyZV9fKF9fd2VicGFja19yZXF1aXJlX18ucyA9IFwiLi9zcmMvb3B0aW9ucy9vcHRpb25zLnRzXCIpO1xuIiwiY29uc3QgZGVmYXVsdHMgPSBPYmplY3QuZnJlZXplPE1pcnJvckJsb2NrT3B0aW9uPih7XG4gIG91dGxpbmVCbG9ja1VzZXI6IGZhbHNlLFxuICBlbmFibGVCbG9ja1JlZmxlY3Rpb246IGZhbHNlLFxuICBibG9ja011dGVkVXNlcjogZmFsc2UsXG4gIGFsd2F5c0ltbWVkaWF0ZWx5QmxvY2tNb2RlOiBmYWxzZSxcbn0pXG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBzYXZlKG5ld09wdGlvbjogTWlycm9yQmxvY2tPcHRpb24pIHtcbiAgY29uc3Qgb3B0aW9uID0gT2JqZWN0LmFzc2lnbjxcbiAgICBvYmplY3QsXG4gICAgTWlycm9yQmxvY2tPcHRpb24sXG4gICAgUGFydGlhbDxNaXJyb3JCbG9ja09wdGlvbj5cbiAgPih7fSwgZGVmYXVsdHMsIG5ld09wdGlvbilcbiAgcmV0dXJuIGJyb3dzZXIuc3RvcmFnZS5sb2NhbC5zZXQoe1xuICAgIG9wdGlvbixcbiAgfSBhcyBhbnkpXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBsb2FkKCk6IFByb21pc2U8TWlycm9yQmxvY2tPcHRpb24+IHtcbiAgY29uc3QgbG9hZGVkID0gYXdhaXQgYnJvd3Nlci5zdG9yYWdlLmxvY2FsLmdldCgnb3B0aW9uJylcbiAgcmV0dXJuIE9iamVjdC5hc3NpZ248b2JqZWN0LCBNaXJyb3JCbG9ja09wdGlvbiwgYW55PihcbiAgICB7fSxcbiAgICBkZWZhdWx0cyxcbiAgICBsb2FkZWQub3B0aW9uXG4gIClcbn1cbiIsImltcG9ydCAqIGFzIE9wdGlvbnMgZnJvbSAn66+465+s67iU6529L2V4dG9wdGlvbidcbmltcG9ydCAqIGFzIGkxOG4gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvaTE4bidcblxuY29uc3QgZWxlbWVudHM6IHsgW2tleSBpbiBrZXlvZiBNaXJyb3JCbG9ja09wdGlvbl06IEhUTUxJbnB1dEVsZW1lbnQgfSA9IHtcbiAgb3V0bGluZUJsb2NrVXNlcjogZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ291dGxpbmVCbG9ja1VzZXInKSBhcyBIVE1MSW5wdXRFbGVtZW50LFxuICBlbmFibGVCbG9ja1JlZmxlY3Rpb246IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdlbmFibGVCbG9ja1JlZmxlY3Rpb24nKSBhcyBIVE1MSW5wdXRFbGVtZW50LFxuICBibG9ja011dGVkVXNlcjogZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ2Jsb2NrTXV0ZWRVc2VyJykgYXMgSFRNTElucHV0RWxlbWVudCxcbiAgYWx3YXlzSW1tZWRpYXRlbHlCbG9ja01vZGU6IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKFxuICAgICdhbHdheXNJbW1lZGlhdGVseUJsb2NrTW9kZSdcbiAgKSBhcyBIVE1MSW5wdXRFbGVtZW50LFxufVxuXG5hc3luYyBmdW5jdGlvbiBzYXZlT3B0aW9uKCkge1xuICBjb25zdCBvcHRpb24gPSBhd2FpdCBPcHRpb25zLmxvYWQoKVxuICBmb3IgKGNvbnN0IFtrZXlfLCBlbGVtXSBvZiBPYmplY3QuZW50cmllcyhlbGVtZW50cykpIHtcbiAgICBjb25zdCBrZXkgPSBrZXlfIGFzIGtleW9mIE1pcnJvckJsb2NrT3B0aW9uXG4gICAgb3B0aW9uW2tleV0gPSBlbGVtLmNoZWNrZWRcbiAgfVxuICByZXR1cm4gT3B0aW9ucy5zYXZlKG9wdGlvbilcbn1cblxuYXN5bmMgZnVuY3Rpb24gbG9hZE9wdGlvbigpIHtcbiAgY29uc3Qgb3B0aW9uID0gYXdhaXQgT3B0aW9ucy5sb2FkKClcbiAgZm9yIChjb25zdCBba2V5XywgZWxlbV0gb2YgT2JqZWN0LmVudHJpZXMoZWxlbWVudHMpKSB7XG4gICAgY29uc3Qga2V5ID0ga2V5XyBhcyBrZXlvZiBNaXJyb3JCbG9ja09wdGlvblxuICAgIGVsZW0uZGlzYWJsZWQgPSBmYWxzZVxuICAgIGVsZW0uY2hlY2tlZCA9IG9wdGlvbltrZXldXG4gIH1cbn1cblxuZnVuY3Rpb24gZGlzcGxheVZlcnNpb24oKSB7XG4gIGNvbnN0IGVsZW0gPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgndmVyc2lvbicpIVxuICBjb25zdCBtYW5pZmVzdCA9IGJyb3dzZXIucnVudGltZS5nZXRNYW5pZmVzdCgpXG4gIGVsZW0udGV4dENvbnRlbnQgPSBtYW5pZmVzdC52ZXJzaW9uXG59XG5cbmZ1bmN0aW9uIGluaXQoKSB7XG4gIGkxOG4uYXBwbHlJMThuT25IdG1sKClcbiAgbG9hZE9wdGlvbigpXG4gIGZvciAoY29uc3QgaW5wdXQgb2YgZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgnLmZpZWxkIGlucHV0JykpIHtcbiAgICBpbnB1dC5hZGRFdmVudExpc3RlbmVyKCdjaGFuZ2UnLCAoKSA9PiB7XG4gICAgICBzYXZlT3B0aW9uKClcbiAgICB9KVxuICB9XG4gIGRpc3BsYXlWZXJzaW9uKClcbn1cblxuZG9jdW1lbnQuYWRkRXZlbnRMaXN0ZW5lcignRE9NQ29udGVudExvYWRlZCcsIGluaXQpXG4iLCJ0eXBlIEkxOE5NZXNzYWdlcyA9IHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2tvL21lc3NhZ2VzLmpzb24nKVxudHlwZSBTdWJzdEl0ZW0gPSBudW1iZXIgfCBzdHJpbmdcbnR5cGUgU3Vic3RpdHV0aW9ucyA9IFN1YnN0SXRlbSB8IFN1YnN0SXRlbVtdIHwgdW5kZWZpbmVkXG5leHBvcnQgdHlwZSBJMThOTWVzc2FnZUtleXMgPSBrZXlvZiBJMThOTWVzc2FnZXNcblxuZXhwb3J0IGZ1bmN0aW9uIGdldE1lc3NhZ2Uoa2V5OiBzdHJpbmcgJiBJMThOTWVzc2FnZUtleXMsIHN1YnN0czogU3Vic3RpdHV0aW9ucyA9IHVuZGVmaW5lZCkge1xuICBpZiAoQXJyYXkuaXNBcnJheShzdWJzdHMpKSB7XG4gICAgcmV0dXJuIGJyb3dzZXIuaTE4bi5nZXRNZXNzYWdlKFxuICAgICAga2V5LFxuICAgICAgc3Vic3RzLm1hcChzID0+IHMudG9Mb2NhbGVTdHJpbmcoKSlcbiAgICApXG4gIH0gZWxzZSBpZiAodHlwZW9mIHN1YnN0cyA9PT0gJ251bWJlcicpIHtcbiAgICByZXR1cm4gYnJvd3Nlci5pMThuLmdldE1lc3NhZ2Uoa2V5LCBzdWJzdHMudG9Mb2NhbGVTdHJpbmcoKSlcbiAgfSBlbHNlIHtcbiAgICByZXR1cm4gYnJvd3Nlci5pMThuLmdldE1lc3NhZ2Uoa2V5LCBzdWJzdHMpXG4gIH1cbn1cblxuZnVuY3Rpb24gdHJ5R2V0TWVzc2FnZShtZXNzYWdlTmFtZTogc3RyaW5nKSB7XG4gIGNvbnN0IG1lc3NhZ2UgPSBnZXRNZXNzYWdlKG1lc3NhZ2VOYW1lIGFzIGFueSlcbiAgaWYgKCFtZXNzYWdlKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKGBpbnZhbGlkIG1lc3NhZ2VOYW1lPyBcIiR7bWVzc2FnZU5hbWV9XCJgKVxuICB9XG4gIHJldHVybiBtZXNzYWdlXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBhcHBseUkxOG5Pbkh0bWwoKSB7XG4gIGNvbnN0IGkxOG5UZXh0RWxlbWVudHMgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCdbZGF0YS1pMThuLXRleHRdJylcbiAgZm9yIChjb25zdCBlbGVtIG9mIGkxOG5UZXh0RWxlbWVudHMpIHtcbiAgICBjb25zdCBtZXNzYWdlTmFtZSA9IGVsZW0uZ2V0QXR0cmlidXRlKCdkYXRhLWkxOG4tdGV4dCcpIVxuICAgIGNvbnN0IG1lc3NhZ2UgPSB0cnlHZXRNZXNzYWdlKG1lc3NhZ2VOYW1lKVxuICAgIC8vIGNvbnNvbGUuZGVidWcoJyVvIC50ZXh0Q29udGVudCA9ICVzIFtmcm9tICVzXScsIGVsZW0sIG1lc3NhZ2UsIG1lc3NhZ2VOYW1lKVxuICAgIGVsZW0udGV4dENvbnRlbnQgPSBtZXNzYWdlXG4gIH1cbiAgY29uc3QgaTE4bkF0dHJzRWxlbWVudHMgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCdbZGF0YS1pMThuLWF0dHJzXScpXG4gIGZvciAoY29uc3QgZWxlbSBvZiBpMThuQXR0cnNFbGVtZW50cykge1xuICAgIC8vIGV4YW1wbGU6XG4gICAgLy8gPHNwYW4gZGF0YS1pMThuLWF0dHJzPVwidGl0bGU9cG9wdXBfdGl0bGUmYWx0PXBvcHVwX2FsdFwiPjwvc3Bhbj5cbiAgICBjb25zdCBhdHRyc1RvTmFtZVNlcmlhbGl6ZWQgPSBlbGVtLmdldEF0dHJpYnV0ZSgnZGF0YS1pMThuLWF0dHJzJykhXG4gICAgY29uc3QgYXR0cnNUb05hbWVQYXJzZWQgPSBuZXcgVVJMU2VhcmNoUGFyYW1zKGF0dHJzVG9OYW1lU2VyaWFsaXplZClcbiAgICBhdHRyc1RvTmFtZVBhcnNlZC5mb3JFYWNoKCh2YWx1ZSwga2V5KSA9PiB7XG4gICAgICAvLyBjb25zb2xlLmRlYnVnKCd8YXR0cnwga2V5OlwiJXNcIiwgdmFsdWU6XCIlc1wiJywga2V5LCB2YWx1ZSlcbiAgICAgIGNvbnN0IG1lc3NhZ2UgPSB0cnlHZXRNZXNzYWdlKHZhbHVlKVxuICAgICAgZWxlbS5zZXRBdHRyaWJ1dGUoa2V5LCBtZXNzYWdlKVxuICAgIH0pXG4gIH1cbn1cblxuZnVuY3Rpb24gY2hlY2tNaXNzaW5nVHJhbnNsYXRpb25zKFxuICAvLyBrby9tZXNzYWdlcy5qc29uIOyXlCDsnojqs6AgZW4vbWVzc2FnZXMuanNvbiDsl5Qg7JeG64qUIO2CpOqwgCDsnojsnLzrqbRcbiAgLy8gVHlwZVNjcmlwdCDsu7TtjIzsnbzrn6zqsIAg7YOA7J6F7JeQ65+s66W8IOydvOycvO2CqOuLpC5cbiAgLy8gdHNjb25maWcuanNvbuydmCByZXNvbHZlSnNvbk1vZHVsZSDsmLXshZjsnYQg7Lyc7JW8IO2VqFxuICBrZXlzOlxuICAgIHwgRXhjbHVkZTxcbiAgICAgICAga2V5b2YgdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMva28vbWVzc2FnZXMuanNvbicpLFxuICAgICAgICBrZXlvZiB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9lbi9tZXNzYWdlcy5qc29uJylcbiAgICAgID5cbiAgICB8IEV4Y2x1ZGU8XG4gICAgICAgIGtleW9mIHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2VuL21lc3NhZ2VzLmpzb24nKSxcbiAgICAgICAga2V5b2YgdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMva28vbWVzc2FnZXMuanNvbicpXG4gICAgICA+LFxuICBmaW5kOiAoX2tleXM6IG5ldmVyKSA9PiB2b2lkLFxuICBfY2hlY2sgPSBmaW5kKGtleXMpXG4pIHt9XG5jaGVja01pc3NpbmdUcmFuc2xhdGlvbnNcbiJdLCJzb3VyY2VSb290IjoiIn0=