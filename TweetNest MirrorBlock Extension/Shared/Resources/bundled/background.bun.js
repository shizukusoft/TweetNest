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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/scripts/background/background.ts");
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

/***/ "./src/scripts/background/background.ts":
/*!**********************************************!*\
  !*** ./src/scripts/background/background.ts ***!
  \**********************************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _extoption__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/extoption */ "./src/extoption.ts");
/* harmony import */ var _context_menus__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./context-menus */ "./src/scripts/background/context-menus.ts");
/* harmony import */ var _scripts_i18n__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! 미러블락/scripts/i18n */ "./src/scripts/i18n.ts");



async function updateBadge(option) {
    const { enableBlockReflection  } = option;
    const manifest = browser.runtime.getManifest();
    browser.browserAction.setBadgeText({
        text: enableBlockReflection ? 'o' : ''
    });
    browser.browserAction.setBadgeBackgroundColor({
        color: enableBlockReflection ? 'crimson' : 'gray'
    });
    browser.browserAction.setTitle({
        title: [
            `Mirror Block v${manifest.version}`,
            `* ${_scripts_i18n__WEBPACK_IMPORTED_MODULE_2__["getMessage"]('block_reflection')}: ${enableBlockReflection ? 'On' : 'Off'}`, 
        ].join('\n')
    });
}
async function initialize() {
    browser.storage.onChanged.addListener((changes)=>{
        const option = changes.option.newValue;
        updateBadge(option);
    });
    const option = await _extoption__WEBPACK_IMPORTED_MODULE_0__["load"]();
    updateBadge(option);
}
initialize();
Object(_context_menus__WEBPACK_IMPORTED_MODULE_1__["initializeContextMenus"])();


/***/ }),

/***/ "./src/scripts/background/context-menus.ts":
/*!*************************************************!*\
  !*** ./src/scripts/background/context-menus.ts ***!
  \*************************************************/
/*! exports provided: initializeContextMenus */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "initializeContextMenus", function() { return initializeContextMenus; });
/* harmony import */ var _scripts_common__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/scripts/common */ "./src/scripts/common.ts");
/* harmony import */ var _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/i18n */ "./src/scripts/i18n.ts");


function getUserNameFromClickInfo(info) {
    const { linkUrl  } = info;
    if (!linkUrl) {
        return null;
    }
    const url = new URL(linkUrl);
    return Object(_scripts_common__WEBPACK_IMPORTED_MODULE_0__["getUserNameFromTweetUrl"])(url);
}
function initializeContextMenus() {
    const contexts = [
        'link'
    ];
    const documentUrlPatterns = [
        'https://twitter.com/*',
        'https://mobile.twitter.com/*'
    ];
    const targetUrlPatterns = documentUrlPatterns;
    browser.contextMenus.create({
        contexts,
        documentUrlPatterns,
        targetUrlPatterns,
        title: _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('run_chainblock_from_followers_contextmenu'),
        onclick (clickInfo, tab) {
            const tabId = tab.id;
            const userName = getUserNameFromClickInfo(clickInfo);
            if (!userName) {
                return;
            }
            browser.tabs.sendMessage(tabId, {
                action: _scripts_common__WEBPACK_IMPORTED_MODULE_0__["Action"].StartChainBlock,
                followKind: 'followers',
                userName
            });
        }
    });
    browser.contextMenus.create({
        contexts,
        documentUrlPatterns,
        targetUrlPatterns,
        title: _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('run_chainblock_from_following_contextmenu'),
        onclick (clickInfo, tab) {
            const tabId = tab.id;
            const userName = getUserNameFromClickInfo(clickInfo);
            if (!userName) {
                return;
            }
            browser.tabs.sendMessage(tabId, {
                action: _scripts_common__WEBPACK_IMPORTED_MODULE_0__["Action"].StartChainBlock,
                followKind: 'following',
                userName
            });
        }
    });
}


/***/ }),

/***/ "./src/scripts/common.ts":
/*!*******************************!*\
  !*** ./src/scripts/common.ts ***!
  \*******************************/
/*! exports provided: Action, TwitterUserMap, EventEmitter, sleep, injectScript, copyFrozenObject, getAddedElementsFromMutations, iterateUntouchedElems, isTwitterUser, isInNameBlacklist, validateTwitterUserName, getUserNameFromTweetUrl */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Action", function() { return Action; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TwitterUserMap", function() { return TwitterUserMap; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "EventEmitter", function() { return EventEmitter; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "sleep", function() { return sleep; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "injectScript", function() { return injectScript; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "copyFrozenObject", function() { return copyFrozenObject; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getAddedElementsFromMutations", function() { return getAddedElementsFromMutations; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "iterateUntouchedElems", function() { return iterateUntouchedElems; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isTwitterUser", function() { return isTwitterUser; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isInNameBlacklist", function() { return isInNameBlacklist; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "validateTwitterUserName", function() { return validateTwitterUserName; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getUserNameFromTweetUrl", function() { return getUserNameFromTweetUrl; });
var Action;
(function(Action1) {
    Action1["StartChainBlock"] = 'MirrorBlock/Start';
    Action1["StopChainBlock"] = 'MirrorBlock/Stop';
    Action1["Alert"] = 'MirrorBlock/Alert';
})(Action || (Action = {
}));
const USER_NAME_BLACKLIST = Object.freeze([
    '1',
    'about',
    'account',
    'followers',
    'followings',
    'hashtag',
    'home',
    'i',
    'lists',
    'login',
    'oauth',
    'privacy',
    'search',
    'tos',
    'notifications',
    'messages',
    'explore', 
]);
class TwitterUserMap extends Map {
    addUser(user) {
        this.set(user.id_str, user);
    }
    hasUser(user) {
        return this.has(user.id_str);
    }
    toUserArray() {
        return Array.from(this.values());
    }
    toUserObject() {
        const usersObj = Object.create(null);
        for (const [userId, user] of this){
            usersObj[userId] = user;
        }
        return usersObj;
    }
    static fromUsersArray(users) {
        return new TwitterUserMap(users.map((user)=>[
                user.id_str,
                user
            ]
        ));
    }
    filter(fn) {
        return TwitterUserMap.fromUsersArray(this.toUserArray().filter(fn));
    }
}
class EventEmitter {
    on(eventName, handler) {
        if (!(eventName in this.events)) {
            this.events[eventName] = [];
        }
        this.events[eventName].push(handler);
        return this;
    }
    emit(eventName, eventHandlerParameter) {
        const handlers = this.events[eventName] || [];
        handlers.forEach((handler)=>handler(eventHandlerParameter)
        );
        return this;
    }
    constructor(){
        this.events = {
        };
    }
}
function sleep(time) {
    return new Promise((resolve)=>window.setTimeout(resolve, time)
    );
}
function injectScript(path) {
    return new Promise((resolve)=>{
        const script = document.createElement('script');
        script.addEventListener('load', ()=>{
            script.remove();
            resolve();
        });
        script.src = browser.runtime.getURL(path);
        const appendTarget = document.head || document.documentElement;
        appendTarget.appendChild(script);
    });
}
function copyFrozenObject(obj) {
    return Object.freeze(Object.assign({
    }, obj));
}
function* getAddedElementsFromMutations(mutations) {
    for (const mut of mutations){
        for (const node of mut.addedNodes){
            if (node instanceof HTMLElement) {
                yield node;
            }
        }
    }
}
const touchedElems = new WeakSet();
function* iterateUntouchedElems(elems) {
    for (const elem of Array.from(elems)){
        if (!touchedElems.has(elem)) {
            touchedElems.add(elem);
            yield elem;
        }
    }
}
// naive check given object is TwitterUser
function isTwitterUser(obj) {
    if (!(obj && typeof obj === 'object')) {
        return false;
    }
    const objAsAny = obj;
    if (typeof objAsAny.id_str !== 'string') {
        return false;
    }
    if (typeof objAsAny.screen_name !== 'string') {
        return false;
    }
    if (typeof objAsAny.blocking !== 'boolean') {
        return false;
    }
    if (typeof objAsAny.blocked_by !== 'boolean') {
        return false;
    }
    return true;
}
function isInNameBlacklist(name) {
    const lowerCasedName = name.toLowerCase();
    return USER_NAME_BLACKLIST.includes(lowerCasedName);
}
function validateTwitterUserName(userName) {
    if (isInNameBlacklist(userName)) {
        return false;
    }
    const pattern = /^[0-9a-z_]{1,15}$/i;
    return pattern.test(userName);
}
function getUserNameFromTweetUrl(extractMe) {
    const { hostname , pathname  } = extractMe;
    const supportingHostname = [
        'twitter.com',
        'mobile.twitter.com'
    ];
    if (!supportingHostname.includes(hostname)) {
        return null;
    }
    const matches = /^\/([0-9a-z_]{1,15})/i.exec(pathname);
    if (!matches) {
        return null;
    }
    const name = matches[1];
    if (validateTwitterUserName(name)) {
        return name;
    } else {
        return null;
    }
}


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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V4dG9wdGlvbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9iYWNrZ3JvdW5kL2JhY2tncm91bmQudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvYmFja2dyb3VuZC9jb250ZXh0LW1lbnVzLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL2NvbW1vbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9pMThuLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7UUFBQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTs7O1FBR0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBLDBDQUEwQyxnQ0FBZ0M7UUFDMUU7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQSx3REFBd0Qsa0JBQWtCO1FBQzFFO1FBQ0EsaURBQWlELGNBQWM7UUFDL0Q7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBLHlDQUF5QyxpQ0FBaUM7UUFDMUUsZ0hBQWdILG1CQUFtQixFQUFFO1FBQ3JJO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMkJBQTJCLDBCQUEwQixFQUFFO1FBQ3ZELGlDQUFpQyxlQUFlO1FBQ2hEO1FBQ0E7UUFDQTs7UUFFQTtRQUNBLHNEQUFzRCwrREFBK0Q7O1FBRXJIO1FBQ0E7OztRQUdBO1FBQ0E7Ozs7Ozs7Ozs7Ozs7Ozs7TUNsRk0sUUFBUSxHQUFHLE1BQU0sQ0FBQyxNQUFNO0lBQzVCLGdCQUFnQixFQUFFLEtBQUs7SUFDdkIscUJBQXFCLEVBQUUsS0FBSztJQUM1QixjQUFjLEVBQUUsS0FBSztJQUNyQiwwQkFBMEIsRUFBRSxL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ZSI6ImJhY2tncm91bmQuYnVuLmpzIiwic291cmNlc0NvbnRlbnQiOlsiIFx0Ly8gVGhlIG1vZHVsZSBjYWNoZVxuIFx0dmFyIGluc3RhbGxlZE1vZHVsZXMgPSB7fTtcblxuIFx0Ly8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbiBcdGZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblxuIFx0XHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcbiBcdFx0aWYoaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0pIHtcbiBcdFx0XHRyZXR1cm4gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0uZXhwb3J0cztcbiBcdFx0fVxuIFx0XHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuIFx0XHR2YXIgbW9kdWxlID0gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0gPSB7XG4gXHRcdFx0aTogbW9kdWxlSWQsXG4gXHRcdFx0bDogZmFsc2UsXG4gXHRcdFx0ZXhwb3J0czoge31cbiBcdFx0fTtcblxuIFx0XHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cbiBcdFx0bW9kdWxlc1ttb2R1bGVJZF0uY2FsbChtb2R1bGUuZXhwb3J0cywgbW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cbiBcdFx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuIFx0XHRtb2R1bGUubCA9IHRydWU7XG5cbiBcdFx0Ly8gUmV0dXJuIHRoZSBleHBvcnRzIG9mIHRoZSBtb2R1bGVcbiBcdFx0cmV0dXJuIG1vZHVsZS5leHBvcnRzO1xuIFx0fVxuXG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlcyBvYmplY3QgKF9fd2VicGFja19tb2R1bGVzX18pXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm0gPSBtb2R1bGVzO1xuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZSBjYWNoZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5jID0gaW5zdGFsbGVkTW9kdWxlcztcblxuIFx0Ly8gZGVmaW5lIGdldHRlciBmdW5jdGlvbiBmb3IgaGFybW9ueSBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQgPSBmdW5jdGlvbihleHBvcnRzLCBuYW1lLCBnZXR0ZXIpIHtcbiBcdFx0aWYoIV9fd2VicGFja19yZXF1aXJlX18ubyhleHBvcnRzLCBuYW1lKSkge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBuYW1lLCB7IGVudW1lcmFibGU6IHRydWUsIGdldDogZ2V0dGVyIH0pO1xuIFx0XHR9XG4gXHR9O1xuXG4gXHQvLyBkZWZpbmUgX19lc01vZHVsZSBvbiBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIgPSBmdW5jdGlvbihleHBvcnRzKSB7XG4gXHRcdGlmKHR5cGVvZiBTeW1ib2wgIT09ICd1bmRlZmluZWQnICYmIFN5bWJvbC50b1N0cmluZ1RhZykge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBTeW1ib2wudG9TdHJpbmdUYWcsIHsgdmFsdWU6ICdNb2R1bGUnIH0pO1xuIFx0XHR9XG4gXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCAnX19lc01vZHVsZScsIHsgdmFsdWU6IHRydWUgfSk7XG4gXHR9O1xuXG4gXHQvLyBjcmVhdGUgYSBmYWtlIG5hbWVzcGFjZSBvYmplY3RcbiBcdC8vIG1vZGUgJiAxOiB2YWx1ZSBpcyBhIG1vZHVsZSBpZCwgcmVxdWlyZSBpdFxuIFx0Ly8gbW9kZSAmIDI6IG1lcmdlIGFsbCBwcm9wZXJ0aWVzIG9mIHZhbHVlIGludG8gdGhlIG5zXG4gXHQvLyBtb2RlICYgNDogcmV0dXJuIHZhbHVlIHdoZW4gYWxyZWFkeSBucyBvYmplY3RcbiBcdC8vIG1vZGUgJiA4fDE6IGJlaGF2ZSBsaWtlIHJlcXVpcmVcbiBcdF9fd2VicGFja19yZXF1aXJlX18udCA9IGZ1bmN0aW9uKHZhbHVlLCBtb2RlKSB7XG4gXHRcdGlmKG1vZGUgJiAxKSB2YWx1ZSA9IF9fd2VicGFja19yZXF1aXJlX18odmFsdWUpO1xuIFx0XHRpZihtb2RlICYgOCkgcmV0dXJuIHZhbHVlO1xuIFx0XHRpZigobW9kZSAmIDQpICYmIHR5cGVvZiB2YWx1ZSA9PT0gJ29iamVjdCcgJiYgdmFsdWUgJiYgdmFsdWUuX19lc01vZHVsZSkgcmV0dXJuIHZhbHVlO1xuIFx0XHR2YXIgbnMgPSBPYmplY3QuY3JlYXRlKG51bGwpO1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIobnMpO1xuIFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkobnMsICdkZWZhdWx0JywgeyBlbnVtZXJhYmxlOiB0cnVlLCB2YWx1ZTogdmFsdWUgfSk7XG4gXHRcdGlmKG1vZGUgJiAyICYmIHR5cGVvZiB2YWx1ZSAhPSAnc3RyaW5nJykgZm9yKHZhciBrZXkgaW4gdmFsdWUpIF9fd2VicGFja19yZXF1aXJlX18uZChucywga2V5LCBmdW5jdGlvbihrZXkpIHsgcmV0dXJuIHZhbHVlW2tleV07IH0uYmluZChudWxsLCBrZXkpKTtcbiBcdFx0cmV0dXJuIG5zO1xuIFx0fTtcblxuIFx0Ly8gZ2V0RGVmYXVsdEV4cG9ydCBmdW5jdGlvbiBmb3IgY29tcGF0aWJpbGl0eSB3aXRoIG5vbi1oYXJtb255IG1vZHVsZXNcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubiA9IGZ1bmN0aW9uKG1vZHVsZSkge1xuIFx0XHR2YXIgZ2V0dGVyID0gbW9kdWxlICYmIG1vZHVsZS5fX2VzTW9kdWxlID9cbiBcdFx0XHRmdW5jdGlvbiBnZXREZWZhdWx0KCkgeyByZXR1cm4gbW9kdWxlWydkZWZhdWx0J107IH0gOlxuIFx0XHRcdGZ1bmN0aW9uIGdldE1vZHVsZUV4cG9ydHMoKSB7IHJldHVybiBtb2R1bGU7IH07XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18uZChnZXR0ZXIsICdhJywgZ2V0dGVyKTtcbiBcdFx0cmV0dXJuIGdldHRlcjtcbiBcdH07XG5cbiBcdC8vIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbFxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5vID0gZnVuY3Rpb24ob2JqZWN0LCBwcm9wZXJ0eSkgeyByZXR1cm4gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsKG9iamVjdCwgcHJvcGVydHkpOyB9O1xuXG4gXHQvLyBfX3dlYnBhY2tfcHVibGljX3BhdGhfX1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5wID0gXCJcIjtcblxuXG4gXHQvLyBMb2FkIGVudHJ5IG1vZHVsZSBhbmQgcmV0dXJuIGV4cG9ydHNcbiBcdHJldHVybiBfX3dlYnBhY2tfcmVxdWlyZV9fKF9fd2VicGFja19yZXF1aXJlX18ucyA9IFwiLi9zcmMvc2NyaXB0cy9iYWNrZ3JvdW5kL2JhY2tncm91bmQudHNcIik7XG4iLCJjb25zdCBkZWZhdWx0cyA9IE9iamVjdC5mcmVlemU8TWlycm9yQmxvY2tPcHRpb24+KHtcbiAgb3V0bGluZUJsb2NrVXNlcjogZmFsc2UsXG4gIGVuYWJsZUJsb2NrUmVmbGVjdGlvbjogZmFsc2UsXG4gIGJsb2NrTXV0ZWRVc2VyOiBmYWxzZSxcbiAgYWx3YXlzSW1tZWRpYXRlbHlCbG9ja01vZGU6IGZhbHNlLFxufSlcblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIHNhdmUobmV3T3B0aW9uOiBNaXJyb3JCbG9ja09wdGlvbikge1xuICBjb25zdCBvcHRpb24gPSBPYmplY3QuYXNzaWduPFxuICAgIG9iamVjdCxcbiAgICBNaXJyb3JCbG9ja09wdGlvbixcbiAgICBQYXJ0aWFsPE1pcnJvckJsb2NrT3B0aW9uPlxuICA+KHt9LCBkZWZhdWx0cywgbmV3T3B0aW9uKVxuICByZXR1cm4gYnJvd3Nlci5zdG9yYWdlLmxvY2FsLnNldCh7XG4gICAgb3B0aW9uLFxuICB9IGFzIGFueSlcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGxvYWQoKTogUHJvbWlzZTxNaXJyb3JCbG9ja09wdGlvbj4ge1xuICBjb25zdCBsb2FkZWQgPSBhd2FpdCBicm93c2VyLnN0b3JhZ2UubG9jYWwuZ2V0KCdvcHRpb24nKVxuICByZXR1cm4gT2JqZWN0LmFzc2lnbjxvYmplY3QsIE1pcnJvckJsb2NrT3B0aW9uLCBhbnk+KFxuICAgIHt9LFxuICAgIGRlZmF1bHRzLFxuICAgIGxvYWRlZC5vcHRpb25cbiAgKVxufVxuIiwiaW1wb3J0ICogYXMgT3B0aW9ucyBmcm9tICfrr7jrn6zruJTrnb0vZXh0b3B0aW9uJ1xuaW1wb3J0IHsgaW5pdGlhbGl6ZUNvbnRleHRNZW51cyB9IGZyb20gJy4vY29udGV4dC1tZW51cydcbmltcG9ydCAqIGFzIGkxOG4gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvaTE4bidcblxuYXN5bmMgZnVuY3Rpb24gdXBkYXRlQmFkZ2Uob3B0aW9uOiBNaXJyb3JCbG9ja09wdGlvbikge1xuICBjb25zdCB7IGVuYWJsZUJsb2NrUmVmbGVjdGlvbiB9ID0gb3B0aW9uXG4gIGNvbnN0IG1hbmlmZXN0ID0gYnJvd3Nlci5ydW50aW1lLmdldE1hbmlmZXN0KClcbiAgYnJvd3Nlci5icm93c2VyQWN0aW9uLnNldEJhZGdlVGV4dCh7XG4gICAgdGV4dDogZW5hYmxlQmxvY2tSZWZsZWN0aW9uID8gJ28nIDogJycsXG4gIH0pXG4gIGJyb3dzZXIuYnJvd3NlckFjdGlvbi5zZXRCYWRnZUJhY2tncm91bmRDb2xvcih7XG4gICAgY29sb3I6IGVuYWJsZUJsb2NrUmVmbGVjdGlvbiA/ICdjcmltc29uJyA6ICdncmF5JyxcbiAgfSlcbiAgYnJvd3Nlci5icm93c2VyQWN0aW9uLnNldFRpdGxlKHtcbiAgICB0aXRsZTogW1xuICAgICAgYE1pcnJvciBCbG9jayB2JHttYW5pZmVzdC52ZXJzaW9ufWAsXG4gICAgICBgKiAke2kxOG4uZ2V0TWVzc2FnZSgnYmxvY2tfcmVmbGVjdGlvbicpfTogJHtlbmFibGVCbG9ja1JlZmxlY3Rpb24gPyAnT24nIDogJ09mZid9YCxcbiAgICBdLmpvaW4oJ1xcbicpLFxuICB9KVxufVxuXG5hc3luYyBmdW5jdGlvbiBpbml0aWFsaXplKCkge1xuICBicm93c2VyLnN0b3JhZ2Uub25DaGFuZ2VkLmFkZExpc3RlbmVyKGNoYW5nZXMgPT4ge1xuICAgIGNvbnN0IG9wdGlvbiA9IGNoYW5nZXMub3B0aW9uLm5ld1ZhbHVlIGFzIE1pcnJvckJsb2NrT3B0aW9uXG4gICAgdXBkYXRlQmFkZ2Uob3B0aW9uKVxuICB9KVxuXG4gIGNvbnN0IG9wdGlvbiA9IGF3YWl0IE9wdGlvbnMubG9hZCgpXG4gIHVwZGF0ZUJhZGdlKG9wdGlvbilcbn1cblxuaW5pdGlhbGl6ZSgpXG5pbml0aWFsaXplQ29udGV4dE1lbnVzKClcbiIsImltcG9ydCB7IGdldFVzZXJOYW1lRnJvbVR3ZWV0VXJsLCBBY3Rpb24gfSBmcm9tICfrr7jrn6zruJTrnb0vc2NyaXB0cy9jb21tb24nXG5pbXBvcnQgKiBhcyBpMThuIGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL2kxOG4nXG5cbmZ1bmN0aW9uIGdldFVzZXJOYW1lRnJvbUNsaWNrSW5mbyhpbmZvOiBicm93c2VyLmNvbnRleHRNZW51cy5PbkNsaWNrRGF0YSk6IHN0cmluZyB8IG51bGwge1xuICBjb25zdCB7IGxpbmtVcmwgfSA9IGluZm9cbiAgaWYgKCFsaW5rVXJsKSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxuICBjb25zdCB1cmwgPSBuZXcgVVJMKGxpbmtVcmwpXG4gIHJldHVybiBnZXRVc2VyTmFtZUZyb21Ud2VldFVybCh1cmwpXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBpbml0aWFsaXplQ29udGV4dE1lbnVzKCkge1xuICBjb25zdCBjb250ZXh0czogYnJvd3Nlci5jb250ZXh0TWVudXMuQ29udGV4dFR5cGVbXSA9IFsnbGluayddXG4gIGNvbnN0IGRvY3VtZW50VXJsUGF0dGVybnMgPSBbJ2h0dHBzOi8vdHdpdHRlci5jb20vKicsICdodHRwczovL21vYmlsZS50d2l0dGVyLmNvbS8qJ11cbiAgY29uc3QgdGFyZ2V0VXJsUGF0dGVybnMgPSBkb2N1bWVudFVybFBhdHRlcm5zXG4gIGJyb3dzZXIuY29udGV4dE1lbnVzLmNyZWF0ZSh7XG4gICAgY29udGV4dHMsXG4gICAgZG9jdW1lbnRVcmxQYXR0ZXJucyxcbiAgICB0YXJnZXRVcmxQYXR0ZXJucyxcbiAgICB0aXRsZTogaTE4bi5nZXRNZXNzYWdlKCdydW5fY2hhaW5ibG9ja19mcm9tX2ZvbGxvd2Vyc19jb250ZXh0bWVudScpLFxuICAgIG9uY2xpY2soY2xpY2tJbmZvLCB0YWIpIHtcbiAgICAgIGNvbnN0IHRhYklkID0gdGFiLmlkIVxuICAgICAgY29uc3QgdXNlck5hbWUgPSBnZXRVc2VyTmFtZUZyb21DbGlja0luZm8oY2xpY2tJbmZvKVxuICAgICAgaWYgKCF1c2VyTmFtZSkge1xuICAgICAgICByZXR1cm5cbiAgICAgIH1cbiAgICAgIGJyb3dzZXIudGFicy5zZW5kTWVzc2FnZTxNQlN0YXJ0Q2hhaW5CbG9ja01lc3NhZ2U+KHRhYklkLCB7XG4gICAgICAgIGFjdGlvbjogQWN0aW9uLlN0YXJ0Q2hhaW5CbG9jayxcbiAgICAgICAgZm9sbG93S2luZDogJ2ZvbGxvd2VycycsXG4gICAgICAgIHVzZXJOYW1lLFxuICAgICAgfSlcbiAgICB9LFxuICB9KVxuICBicm93c2VyLmNvbnRleHRNZW51cy5jcmVhdGUoe1xuICAgIGNvbnRleHRzLFxuICAgIGRvY3VtZW50VXJsUGF0dGVybnMsXG4gICAgdGFyZ2V0VXJsUGF0dGVybnMsXG4gICAgdGl0bGU6IGkxOG4uZ2V0TWVzc2FnZSgncnVuX2NoYWluYmxvY2tfZnJvbV9mb2xsb3dpbmdfY29udGV4dG1lbnUnKSxcbiAgICBvbmNsaWNrKGNsaWNrSW5mbywgdGFiKSB7XG4gICAgICBjb25zdCB0YWJJZCA9IHRhYi5pZCFcbiAgICAgIGNvbnN0IHVzZXJOYW1lID0gZ2V0VXNlck5hbWVGcm9tQ2xpY2tJbmZvKGNsaWNrSW5mbylcbiAgICAgIGlmICghdXNlck5hbWUpIHtcbiAgICAgICAgcmV0dXJuXG4gICAgICB9XG4gICAgICBicm93c2VyLnRhYnMuc2VuZE1lc3NhZ2U8TUJTdGFydENoYWluQmxvY2tNZXNzYWdlPih0YWJJZCwge1xuICAgICAgICBhY3Rpb246IEFjdGlvbi5TdGFydENoYWluQmxvY2ssXG4gICAgICAgIGZvbGxvd0tpbmQ6ICdmb2xsb3dpbmcnLFxuICAgICAgICB1c2VyTmFtZSxcbiAgICAgIH0pXG4gICAgfSxcbiAgfSlcbn1cbiIsImV4cG9ydCBjb25zdCBlbnVtIEFjdGlvbiB7XG4gIFN0YXJ0Q2hhaW5CbG9jayA9ICdNaXJyb3JCbG9jay9TdGFydCcsXG4gIFN0b3BDaGFpbkJsb2NrID0gJ01pcnJvckJsb2NrL1N0b3AnLFxuICBBbGVydCA9ICdNaXJyb3JCbG9jay9BbGVydCcsXG59XG5cbmNvbnN0IFVTRVJfTkFNRV9CTEFDS0xJU1QgPSBPYmplY3QuZnJlZXplKFtcbiAgJzEnLFxuICAnYWJvdXQnLFxuICAnYWNjb3VudCcsXG4gICdmb2xsb3dlcnMnLFxuICAnZm9sbG93aW5ncycsXG4gICdoYXNodGFnJyxcbiAgJ2hvbWUnLFxuICAnaScsXG4gICdsaXN0cycsXG4gICdsb2dpbicsXG4gICdvYXV0aCcsXG4gICdwcml2YWN5JyxcbiAgJ3NlYXJjaCcsXG4gICd0b3MnLFxuICAnbm90aWZpY2F0aW9ucycsXG4gICdtZXNzYWdlcycsXG4gICdleHBsb3JlJyxcbl0pXG5cbmV4cG9ydCBjbGFzcyBUd2l0dGVyVXNlck1hcCBleHRlbmRzIE1hcDxzdHJpbmcsIFR3aXR0ZXJVc2VyPiB7XG4gIHB1YmxpYyBhZGRVc2VyKHVzZXI6IFR3aXR0ZXJVc2VyKSB7XG4gICAgdGhpcy5zZXQodXNlci5pZF9zdHIsIHVzZXIpXG4gIH1cbiAgcHVibGljIGhhc1VzZXIodXNlcjogVHdpdHRlclVzZXIpIHtcbiAgICByZXR1cm4gdGhpcy5oYXModXNlci5pZF9zdHIpXG4gIH1cbiAgcHVibGljIHRvVXNlckFycmF5KCk6IFR3aXR0ZXJVc2VyW10ge1xuICAgIHJldHVybiBBcnJheS5mcm9tKHRoaXMudmFsdWVzKCkpXG4gIH1cbiAgcHVibGljIHRvVXNlck9iamVjdCgpOiBUd2l0dGVyVXNlckVudGl0aWVzIHtcbiAgICBjb25zdCB1c2Vyc09iajogVHdpdHRlclVzZXJFbnRpdGllcyA9IE9iamVjdC5jcmVhdGUobnVsbClcbiAgICBmb3IgKGNvbnN0IFt1c2VySWQsIHVzZXJdIG9mIHRoaXMpIHtcbiAgICAgIHVzZXJzT2JqW3VzZXJJZF0gPSB1c2VyXG4gICAgfVxuICAgIHJldHVybiB1c2Vyc09ialxuICB9XG4gIHB1YmxpYyBzdGF0aWMgZnJvbVVzZXJzQXJyYXkodXNlcnM6IFR3aXR0ZXJVc2VyW10pOiBUd2l0dGVyVXNlck1hcCB7XG4gICAgcmV0dXJuIG5ldyBUd2l0dGVyVXNlck1hcCh1c2Vycy5tYXAoKHVzZXIpOiBbc3RyaW5nLCBUd2l0dGVyVXNlcl0gPT4gW3VzZXIuaWRfc3RyLCB1c2VyXSkpXG4gIH1cbiAgcHVibGljIGZpbHRlcihmbjogKHVzZXI6IFR3aXR0ZXJVc2VyKSA9PiBib29sZWFuKTogVHdpdHRlclVzZXJNYXAge1xuICAgIHJldHVybiBUd2l0dGVyVXNlck1hcC5mcm9tVXNlcnNBcnJheSh0aGlzLnRvVXNlckFycmF5KCkuZmlsdGVyKGZuKSlcbiAgfVxufVxuXG5leHBvcnQgYWJzdHJhY3QgY2xhc3MgRXZlbnRFbWl0dGVyIHtcbiAgcHJvdGVjdGVkIGV2ZW50czogRXZlbnRTdG9yZSA9IHt9XG4gIG9uPFQ+KGV2ZW50TmFtZTogc3RyaW5nLCBoYW5kbGVyOiAodDogVCkgPT4gYW55KSB7XG4gICAgaWYgKCEoZXZlbnROYW1lIGluIHRoaXMuZXZlbnRzKSkge1xuICAgICAgdGhpcy5ldmVudHNbZXZlbnROYW1lXSA9IFtdXG4gICAgfVxuICAgIHRoaXMuZXZlbnRzW2V2ZW50TmFtZV0ucHVzaChoYW5kbGVyKVxuICAgIHJldHVybiB0aGlzXG4gIH1cbiAgZW1pdDxUPihldmVudE5hbWU6IHN0cmluZywgZXZlbnRIYW5kbGVyUGFyYW1ldGVyPzogVCkge1xuICAgIGNvbnN0IGhhbmRsZXJzID0gdGhpcy5ldmVudHNbZXZlbnROYW1lXSB8fCBbXVxuICAgIGhhbmRsZXJzLmZvckVhY2goaGFuZGxlciA9PiBoYW5kbGVyKGV2ZW50SGFuZGxlclBhcmFtZXRlcikpXG4gICAgcmV0dXJuIHRoaXNcbiAgfVxufVxuXG5leHBvcnQgZnVuY3Rpb24gc2xlZXAodGltZTogbnVtYmVyKTogUHJvbWlzZTx2b2lkPiB7XG4gIHJldHVybiBuZXcgUHJvbWlzZShyZXNvbHZlID0+IHdpbmRvdy5zZXRUaW1lb3V0KHJlc29sdmUsIHRpbWUpKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gaW5qZWN0U2NyaXB0KHBhdGg6IHN0cmluZyk6IFByb21pc2U8dm9pZD4ge1xuICByZXR1cm4gbmV3IFByb21pc2UocmVzb2x2ZSA9PiB7XG4gICAgY29uc3Qgc2NyaXB0ID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnc2NyaXB0JylcbiAgICBzY3JpcHQuYWRkRXZlbnRMaXN0ZW5lcignbG9hZCcsICgpID0+IHtcbiAgICAgIHNjcmlwdC5yZW1vdmUoKVxuICAgICAgcmVzb2x2ZSgpXG4gICAgfSlcbiAgICBzY3JpcHQuc3JjID0gYnJvd3Nlci5ydW50aW1lLmdldFVSTChwYXRoKVxuICAgIGNvbnN0IGFwcGVuZFRhcmdldCA9IGRvY3VtZW50LmhlYWQgfHwgZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50XG4gICAgYXBwZW5kVGFyZ2V0IS5hcHBlbmRDaGlsZChzY3JpcHQpXG4gIH0pXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBjb3B5RnJvemVuT2JqZWN0PFQgZXh0ZW5kcyBvYmplY3Q+KG9iajogVCk6IFJlYWRvbmx5PFQ+IHtcbiAgcmV0dXJuIE9iamVjdC5mcmVlemUoT2JqZWN0LmFzc2lnbih7fSwgb2JqKSlcbn1cblxuZXhwb3J0IGZ1bmN0aW9uKiBnZXRBZGRlZEVsZW1lbnRzRnJvbU11dGF0aW9ucyhcbiAgbXV0YXRpb25zOiBNdXRhdGlvblJlY29yZFtdXG4pOiBJdGVyYWJsZUl0ZXJhdG9yPEhUTUxFbGVtZW50PiB7XG4gIGZvciAoY29uc3QgbXV0IG9mIG11dGF0aW9ucykge1xuICAgIGZvciAoY29uc3Qgbm9kZSBvZiBtdXQuYWRkZWROb2Rlcykge1xuICAgICAgaWYgKG5vZGUgaW5zdGFuY2VvZiBIVE1MRWxlbWVudCkge1xuICAgICAgICB5aWVsZCBub2RlXG4gICAgICB9XG4gICAgfVxuICB9XG59XG5cbmNvbnN0IHRvdWNoZWRFbGVtcyA9IG5ldyBXZWFrU2V0PEhUTUxFbGVtZW50PigpXG5leHBvcnQgZnVuY3Rpb24qIGl0ZXJhdGVVbnRvdWNoZWRFbGVtczxUIGV4dGVuZHMgSFRNTEVsZW1lbnQ+KGVsZW1zOiBJdGVyYWJsZTxUPiB8IEFycmF5TGlrZTxUPikge1xuICBmb3IgKGNvbnN0IGVsZW0gb2YgQXJyYXkuZnJvbShlbGVtcykpIHtcbiAgICBpZiAoIXRvdWNoZWRFbGVtcy5oYXMoZWxlbSkpIHtcbiAgICAgIHRvdWNoZWRFbGVtcy5hZGQoZWxlbSlcbiAgICAgIHlpZWxkIGVsZW1cbiAgICB9XG4gIH1cbn1cblxuLy8gbmFpdmUgY2hlY2sgZ2l2ZW4gb2JqZWN0IGlzIFR3aXR0ZXJVc2VyXG5leHBvcnQgZnVuY3Rpb24gaXNUd2l0dGVyVXNlcihvYmo6IHVua25vd24pOiBvYmogaXMgVHdpdHRlclVzZXIge1xuICBpZiAoIShvYmogJiYgdHlwZW9mIG9iaiA9PT0gJ29iamVjdCcpKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgY29uc3Qgb2JqQXNBbnkgPSBvYmogYXMgYW55XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuaWRfc3RyICE9PSAnc3RyaW5nJykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuc2NyZWVuX25hbWUgIT09ICdzdHJpbmcnKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5ibG9ja2luZyAhPT0gJ2Jvb2xlYW4nKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5ibG9ja2VkX2J5ICE9PSAnYm9vbGVhbicpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICByZXR1cm4gdHJ1ZVxufVxuXG5leHBvcnQgZnVuY3Rpb24gaXNJbk5hbWVCbGFja2xpc3QobmFtZTogc3RyaW5nKTogYm9vbGVhbiB7XG4gIGNvbnN0IGxvd2VyQ2FzZWROYW1lID0gbmFtZS50b0xvd2VyQ2FzZSgpXG4gIHJldHVybiBVU0VSX05BTUVfQkxBQ0tMSVNULmluY2x1ZGVzKGxvd2VyQ2FzZWROYW1lKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gdmFsaWRhdGVUd2l0dGVyVXNlck5hbWUodXNlck5hbWU6IHN0cmluZyk6IGJvb2xlYW4ge1xuICBpZiAoaXNJbk5hbWVCbGFja2xpc3QodXNlck5hbWUpKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgY29uc3QgcGF0dGVybiA9IC9eWzAtOWEtel9dezEsMTV9JC9pXG4gIHJldHVybiBwYXR0ZXJuLnRlc3QodXNlck5hbWUpXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBnZXRVc2VyTmFtZUZyb21Ud2VldFVybChcbiAgZXh0cmFjdE1lOiBIVE1MQW5jaG9yRWxlbWVudCB8IFVSTCB8IExvY2F0aW9uXG4pOiBzdHJpbmcgfCBudWxsIHtcbiAgY29uc3QgeyBob3N0bmFtZSwgcGF0aG5hbWUgfSA9IGV4dHJhY3RNZVxuICBjb25zdCBzdXBwb3J0aW5nSG9zdG5hbWUgPSBbJ3R3aXR0ZXIuY29tJywgJ21vYmlsZS50d2l0dGVyLmNvbSddXG4gIGlmICghc3VwcG9ydGluZ0hvc3RuYW1lLmluY2x1ZGVzKGhvc3RuYW1lKSkge1xuICAgIHJldHVybiBudWxsXG4gIH1cbiAgY29uc3QgbWF0Y2hlcyA9IC9eXFwvKFswLTlhLXpfXXsxLDE1fSkvaS5leGVjKHBhdGhuYW1lKVxuICBpZiAoIW1hdGNoZXMpIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG4gIGNvbnN0IG5hbWUgPSBtYXRjaGVzWzFdXG4gIGlmICh2YWxpZGF0ZVR3aXR0ZXJVc2VyTmFtZShuYW1lKSkge1xuICAgIHJldHVybiBuYW1lXG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxufVxuIiwidHlwZSBJMThOTWVzc2FnZXMgPSB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9rby9tZXNzYWdlcy5qc29uJylcbnR5cGUgU3Vic3RJdGVtID0gbnVtYmVyIHwgc3RyaW5nXG50eXBlIFN1YnN0aXR1dGlvbnMgPSBTdWJzdEl0ZW0gfCBTdWJzdEl0ZW1bXSB8IHVuZGVmaW5lZFxuZXhwb3J0IHR5cGUgSTE4Tk1lc3NhZ2VLZXlzID0ga2V5b2YgSTE4Tk1lc3NhZ2VzXG5cbmV4cG9ydCBmdW5jdGlvbiBnZXRNZXNzYWdlKGtleTogc3RyaW5nICYgSTE4Tk1lc3NhZ2VLZXlzLCBzdWJzdHM6IFN1YnN0aXR1dGlvbnMgPSB1bmRlZmluZWQpIHtcbiAgaWYgKEFycmF5LmlzQXJyYXkoc3Vic3RzKSkge1xuICAgIHJldHVybiBicm93c2VyLmkxOG4uZ2V0TWVzc2FnZShcbiAgICAgIGtleSxcbiAgICAgIHN1YnN0cy5tYXAocyA9PiBzLnRvTG9jYWxlU3RyaW5nKCkpXG4gICAgKVxuICB9IGVsc2UgaWYgKHR5cGVvZiBzdWJzdHMgPT09ICdudW1iZXInKSB7XG4gICAgcmV0dXJuIGJyb3dzZXIuaTE4bi5nZXRNZXNzYWdlKGtleSwgc3Vic3RzLnRvTG9jYWxlU3RyaW5nKCkpXG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIGJyb3dzZXIuaTE4bi5nZXRNZXNzYWdlKGtleSwgc3Vic3RzKVxuICB9XG59XG5cbmZ1bmN0aW9uIHRyeUdldE1lc3NhZ2UobWVzc2FnZU5hbWU6IHN0cmluZykge1xuICBjb25zdCBtZXNzYWdlID0gZ2V0TWVzc2FnZShtZXNzYWdlTmFtZSBhcyBhbnkpXG4gIGlmICghbWVzc2FnZSkge1xuICAgIHRocm93IG5ldyBFcnJvcihgaW52YWxpZCBtZXNzYWdlTmFtZT8gXCIke21lc3NhZ2VOYW1lfVwiYClcbiAgfVxuICByZXR1cm4gbWVzc2FnZVxufVxuXG5leHBvcnQgZnVuY3Rpb24gYXBwbHlJMThuT25IdG1sKCkge1xuICBjb25zdCBpMThuVGV4dEVsZW1lbnRzID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgnW2RhdGEtaTE4bi10ZXh0XScpXG4gIGZvciAoY29uc3QgZWxlbSBvZiBpMThuVGV4dEVsZW1lbnRzKSB7XG4gICAgY29uc3QgbWVzc2FnZU5hbWUgPSBlbGVtLmdldEF0dHJpYnV0ZSgnZGF0YS1pMThuLXRleHQnKSFcbiAgICBjb25zdCBtZXNzYWdlID0gdHJ5R2V0TWVzc2FnZShtZXNzYWdlTmFtZSlcbiAgICAvLyBjb25zb2xlLmRlYnVnKCclbyAudGV4dENvbnRlbnQgPSAlcyBbZnJvbSAlc10nLCBlbGVtLCBtZXNzYWdlLCBtZXNzYWdlTmFtZSlcbiAgICBlbGVtLnRleHRDb250ZW50ID0gbWVzc2FnZVxuICB9XG4gIGNvbnN0IGkxOG5BdHRyc0VsZW1lbnRzID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgnW2RhdGEtaTE4bi1hdHRyc10nKVxuICBmb3IgKGNvbnN0IGVsZW0gb2YgaTE4bkF0dHJzRWxlbWVudHMpIHtcbiAgICAvLyBleGFtcGxlOlxuICAgIC8vIDxzcGFuIGRhdGEtaTE4bi1hdHRycz1cInRpdGxlPXBvcHVwX3RpdGxlJmFsdD1wb3B1cF9hbHRcIj48L3NwYW4+XG4gICAgY29uc3QgYXR0cnNUb05hbWVTZXJpYWxpemVkID0gZWxlbS5nZXRBdHRyaWJ1dGUoJ2RhdGEtaTE4bi1hdHRycycpIVxuICAgIGNvbnN0IGF0dHJzVG9OYW1lUGFyc2VkID0gbmV3IFVSTFNlYXJjaFBhcmFtcyhhdHRyc1RvTmFtZVNlcmlhbGl6ZWQpXG4gICAgYXR0cnNUb05hbWVQYXJzZWQuZm9yRWFjaCgodmFsdWUsIGtleSkgPT4ge1xuICAgICAgLy8gY29uc29sZS5kZWJ1ZygnfGF0dHJ8IGtleTpcIiVzXCIsIHZhbHVlOlwiJXNcIicsIGtleSwgdmFsdWUpXG4gICAgICBjb25zdCBtZXNzYWdlID0gdHJ5R2V0TWVzc2FnZSh2YWx1ZSlcbiAgICAgIGVsZW0uc2V0QXR0cmlidXRlKGtleSwgbWVzc2FnZSlcbiAgICB9KVxuICB9XG59XG5cbmZ1bmN0aW9uIGNoZWNrTWlzc2luZ1RyYW5zbGF0aW9ucyhcbiAgLy8ga28vbWVzc2FnZXMuanNvbiDsl5Qg7J6I6rOgIGVuL21lc3NhZ2VzLmpzb24g7JeUIOyXhuuKlCDtgqTqsIAg7J6I7Jy866m0XG4gIC8vIFR5cGVTY3JpcHQg7Lu07YyM7J2865+s6rCAIO2DgOyeheyXkOufrOulvCDsnbzsnLztgqjri6QuXG4gIC8vIHRzY29uZmlnLmpzb27snZggcmVzb2x2ZUpzb25Nb2R1bGUg7Ji17IWY7J2EIOy8nOyVvCDtlahcbiAga2V5czpcbiAgICB8IEV4Y2x1ZGU8XG4gICAgICAgIGtleW9mIHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2tvL21lc3NhZ2VzLmpzb24nKSxcbiAgICAgICAga2V5b2YgdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMvZW4vbWVzc2FnZXMuanNvbicpXG4gICAgICA+XG4gICAgfCBFeGNsdWRlPFxuICAgICAgICBrZXlvZiB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9lbi9tZXNzYWdlcy5qc29uJyksXG4gICAgICAgIGtleW9mIHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2tvL21lc3NhZ2VzLmpzb24nKVxuICAgICAgPixcbiAgZmluZDogKF9rZXlzOiBuZXZlcikgPT4gdm9pZCxcbiAgX2NoZWNrID0gZmluZChrZXlzKVxuKSB7fVxuY2hlY2tNaXNzaW5nVHJhbnNsYXRpb25zXG4iXSwic291cmNlUm9vdCI6IiJ9