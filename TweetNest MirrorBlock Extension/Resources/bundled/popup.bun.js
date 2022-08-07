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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/popup/popup.ts");
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

/***/ "./src/popup/popup.ts":
/*!****************************!*\
  !*** ./src/popup/popup.ts ***!
  \****************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _extoption__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/extoption */ "./src/extoption.ts");
/* harmony import */ var _scripts_common__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/common */ "./src/scripts/common.ts");
/* harmony import */ var _scripts_i18n__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! 미러블락/scripts/i18n */ "./src/scripts/i18n.ts");



function closePopup() {
    window.close();
}
async function alertToTab(tabId, message) {
    return browser.tabs.sendMessage(tabId, {
        action: _scripts_common__WEBPACK_IMPORTED_MODULE_1__["Action"].Alert,
        message
    });
}
async function getCurrentTab() {
    const tabs = await browser.tabs.query({
        active: true,
        currentWindow: true
    });
    const currentTab = tabs[0];
    if (!currentTab.url || !currentTab.id) {
        return null;
    }
    return currentTab;
}
async function executeChainBlock(followKind) {
    const currentTab = await getCurrentTab();
    if (!(currentTab && typeof currentTab.id === 'number')) {
        return;
    }
    const tabId = currentTab.id;
    const url = new URL(currentTab.url);
    if (url.hostname === 'tweetdeck.twitter.com') {
        // TODO
        const a = 'Mirror Block: 트윗덱에선 작동하지 않습니다.';
        const b = '트위터(https://twitter.com)에서 실행해주세요.';
        const message = `${a}\n${b}`;
        alertToTab(tabId, message);
        closePopup();
        return;
    }
    const userName = Object(_scripts_common__WEBPACK_IMPORTED_MODULE_1__["getUserNameFromTweetUrl"])(url);
    if (!userName) {
        const a = _scripts_i18n__WEBPACK_IMPORTED_MODULE_2__["getMessage"]('please_run_on_profile_page_1');
        const b = _scripts_i18n__WEBPACK_IMPORTED_MODULE_2__["getMessage"]('please_run_on_profile_page_2');
        const message = `${a}\n${b}`;
        alertToTab(tabId, message);
        closePopup();
        return;
    }
    browser.tabs.sendMessage(tabId, {
        action: _scripts_common__WEBPACK_IMPORTED_MODULE_1__["Action"].StartChainBlock,
        followKind,
        userName
    }).then(closePopup);
}
document.addEventListener('DOMContentLoaded', async ()=>{
    _scripts_i18n__WEBPACK_IMPORTED_MODULE_2__["applyI18nOnHtml"]();
    const currentTab = await getCurrentTab();
    if (currentTab && currentTab.url) {
        const currentUrl = new URL(currentTab.url);
        const cbButtons = document.querySelectorAll('button.chain-block');
        const supportingHostname = [
            'twitter.com',
            'mobile.twitter.com'
        ];
        if (supportingHostname.includes(currentUrl.hostname)) {
            cbButtons.forEach((el)=>el.disabled = false
            );
        } else {
            cbButtons.forEach((el)=>el.title = _scripts_i18n__WEBPACK_IMPORTED_MODULE_2__["getMessage"]('running_chainblock_is_only_available_on_twitter')
            );
        }
    }
    document.querySelector('.menu-item.chain-block-followers').addEventListener('click', (event)=>{
        event.preventDefault();
        executeChainBlock('followers');
    });
    document.querySelector('.menu-item.chain-block-following').addEventListener('click', (event)=>{
        event.preventDefault();
        executeChainBlock('following');
    });
    document.querySelector('.menu-item.open-option').addEventListener('click', (event)=>{
        event.preventDefault();
        browser.runtime.openOptionsPage();
    });
    {
        const manifest = browser.runtime.getManifest();
        const currentVersion = document.querySelector('.currentVersion');
        currentVersion.textContent = `Mirror Block v${manifest.version}`;
    }
    {
        const options = await _extoption__WEBPACK_IMPORTED_MODULE_0__["load"]();
        const blockReflection = document.querySelector('.blockReflection');
        const val = options.enableBlockReflection;
        blockReflection.classList.toggle('on', val);
        blockReflection.textContent = `${_scripts_i18n__WEBPACK_IMPORTED_MODULE_2__["getMessage"]('block_reflection')}: ${val ? 'On \u2714' : 'Off'}`;
    }
});


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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V4dG9wdGlvbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvcG9wdXAvcG9wdXAudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvY29tbW9uLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL2kxOG4udHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtRQUFBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBOzs7UUFHQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMENBQTBDLGdDQUFnQztRQUMxRTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBLHdEQUF3RCxrQkFBa0I7UUFDMUU7UUFDQSxpREFBaUQsY0FBYztRQUMvRDs7UUFFQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0EseUNBQXlDLGlDQUFpQztRQUMxRSxnSEFBZ0gsbUJBQW1CLEVBQUU7UUFDckk7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQSwyQkFBMkIsMEJBQTBCLEVBQUU7UUFDdkQsaUNBQWlDLGVBQWU7UUFDaEQ7UUFDQTtRQUNBOztRQUVBO1FBQ0Esc0RBQXNELCtEQUErRDs7UUFFckg7UUFDQTs7O1FBR0E7UUFDQTs7Ozs7Ozs7Ozs7Ozs7OztNQ2xGTSxRQUFRLEdBQUcsTUFBTSxDQUFDLE1BQU07SUFDNUIsZ0JBQWdCLEVBQUUsS0FBSztJQUN2QixxQkFBcUIsRUFBRSxLQUFLO0lBQzVCLGNBQWMsRUFBRSxLQUFLO0lBQ3JCLDBCQUEwQixFQUFFLEtBQUs7O2VBR2IsSUFBSSxDQUFDLFNBQTRCO1VBQy9DLE1BQU0sR0FBRyxNQUFNLENBQUMsTUFBTTtPQUl0QixRQUFRLEVBQUUs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QVcsR0FBRyxJQUFJLENBQUMsWUFBWSxFQUFDLGNBQWdCO2NBQ2hELE9BQU8sR0FBRyxhQUFhLENBQUMsV0FBVztRQUN6QyxFQUE4RTtRQUM5RSxJQUFJLENBQUMsV0FBVyxHQUFHLE9BQU87O1VBRXRCLGlCQUFpQixHQUFHLFFBQVEsQ0FBQyxnQkFBZ0IsRUFBQyxpQkFBbUI7ZUFDNUQsS0FBSSxJQUFJLGlCQUFpQjtRQUNsQyxFQUFXO1FBQ1gsRUFBa0U7Y0FDNUQscUJBQXFCLEdBQUcsS0FBSSxDQUFDLFlBQVksRUFBQyxlQUFpQjtjQUMzRCxpQkFBaUIsT0FBTyxlQUFlLENBQUMscUJBQXFCO1FBQ25FLGlCQUFpQixDQUFDLE9BQU8sRUFBRSxLQUFLLEVBQUUsR0FBRztZQUNuQyxFQUEyRDtrQkFDckQsT0FBTyxHQUFHLGFBQWEsQ0FBQyxLQUFLO1lBQ25DLEtBQUksQ0FBQyxZQUFZLENBQUMsR0FBRyxFQUFFLE9BQU87Ozs7U0FLM0Isd0JBQXdCLENBQy9CLEVBQXFELG1EQUFzQjtBQUNyRCxFQUFTLDZCQUE0QjtBQUMvQixFQUFnQjtBQUM1QyxJQVFLLEVBQ0wsSUFBNEIsRUFDNUIsTUFBTSxHQUFHLElBQUksQ0FBQyxJQUFJOztBQUVwQix3QkFBd0IiLCJmaWxlIjoicG9wdXAuYnVuLmpzIiwic291cmNlc0NvbnRlbnQiOlsiIFx0Ly8gVGhlIG1vZHVsZSBjYWNoZVxuIFx0dmFyIGluc3RhbGxlZE1vZHVsZXMgPSB7fTtcblxuIFx0Ly8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbiBcdGZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblxuIFx0XHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcbiBcdFx0aWYoaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0pIHtcbiBcdFx0XHRyZXR1cm4gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0uZXhwb3J0cztcbiBcdFx0fVxuIFx0XHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuIFx0XHR2YXIgbW9kdWxlID0gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0gPSB7XG4gXHRcdFx0aTogbW9kdWxlSWQsXG4gXHRcdFx0bDogZmFsc2UsXG4gXHRcdFx0ZXhwb3J0czoge31cbiBcdFx0fTtcblxuIFx0XHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cbiBcdFx0bW9kdWxlc1ttb2R1bGVJZF0uY2FsbChtb2R1bGUuZXhwb3J0cywgbW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cbiBcdFx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuIFx0XHRtb2R1bGUubCA9IHRydWU7XG5cbiBcdFx0Ly8gUmV0dXJuIHRoZSBleHBvcnRzIG9mIHRoZSBtb2R1bGVcbiBcdFx0cmV0dXJuIG1vZHVsZS5leHBvcnRzO1xuIFx0fVxuXG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlcyBvYmplY3QgKF9fd2VicGFja19tb2R1bGVzX18pXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm0gPSBtb2R1bGVzO1xuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZSBjYWNoZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5jID0gaW5zdGFsbGVkTW9kdWxlcztcblxuIFx0Ly8gZGVmaW5lIGdldHRlciBmdW5jdGlvbiBmb3IgaGFybW9ueSBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQgPSBmdW5jdGlvbihleHBvcnRzLCBuYW1lLCBnZXR0ZXIpIHtcbiBcdFx0aWYoIV9fd2VicGFja19yZXF1aXJlX18ubyhleHBvcnRzLCBuYW1lKSkge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBuYW1lLCB7IGVudW1lcmFibGU6IHRydWUsIGdldDogZ2V0dGVyIH0pO1xuIFx0XHR9XG4gXHR9O1xuXG4gXHQvLyBkZWZpbmUgX19lc01vZHVsZSBvbiBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIgPSBmdW5jdGlvbihleHBvcnRzKSB7XG4gXHRcdGlmKHR5cGVvZiBTeW1ib2wgIT09ICd1bmRlZmluZWQnICYmIFN5bWJvbC50b1N0cmluZ1RhZykge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBTeW1ib2wudG9TdHJpbmdUYWcsIHsgdmFsdWU6ICdNb2R1bGUnIH0pO1xuIFx0XHR9XG4gXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCAnX19lc01vZHVsZScsIHsgdmFsdWU6IHRydWUgfSk7XG4gXHR9O1xuXG4gXHQvLyBjcmVhdGUgYSBmYWtlIG5hbWVzcGFjZSBvYmplY3RcbiBcdC8vIG1vZGUgJiAxOiB2YWx1ZSBpcyBhIG1vZHVsZSBpZCwgcmVxdWlyZSBpdFxuIFx0Ly8gbW9kZSAmIDI6IG1lcmdlIGFsbCBwcm9wZXJ0aWVzIG9mIHZhbHVlIGludG8gdGhlIG5zXG4gXHQvLyBtb2RlICYgNDogcmV0dXJuIHZhbHVlIHdoZW4gYWxyZWFkeSBucyBvYmplY3RcbiBcdC8vIG1vZGUgJiA4fDE6IGJlaGF2ZSBsaWtlIHJlcXVpcmVcbiBcdF9fd2VicGFja19yZXF1aXJlX18udCA9IGZ1bmN0aW9uKHZhbHVlLCBtb2RlKSB7XG4gXHRcdGlmKG1vZGUgJiAxKSB2YWx1ZSA9IF9fd2VicGFja19yZXF1aXJlX18odmFsdWUpO1xuIFx0XHRpZihtb2RlICYgOCkgcmV0dXJuIHZhbHVlO1xuIFx0XHRpZigobW9kZSAmIDQpICYmIHR5cGVvZiB2YWx1ZSA9PT0gJ29iamVjdCcgJiYgdmFsdWUgJiYgdmFsdWUuX19lc01vZHVsZSkgcmV0dXJuIHZhbHVlO1xuIFx0XHR2YXIgbnMgPSBPYmplY3QuY3JlYXRlKG51bGwpO1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLnIobnMpO1xuIFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkobnMsICdkZWZhdWx0JywgeyBlbnVtZXJhYmxlOiB0cnVlLCB2YWx1ZTogdmFsdWUgfSk7XG4gXHRcdGlmKG1vZGUgJiAyICYmIHR5cGVvZiB2YWx1ZSAhPSAnc3RyaW5nJykgZm9yKHZhciBrZXkgaW4gdmFsdWUpIF9fd2VicGFja19yZXF1aXJlX18uZChucywga2V5LCBmdW5jdGlvbihrZXkpIHsgcmV0dXJuIHZhbHVlW2tleV07IH0uYmluZChudWxsLCBrZXkpKTtcbiBcdFx0cmV0dXJuIG5zO1xuIFx0fTtcblxuIFx0Ly8gZ2V0RGVmYXVsdEV4cG9ydCBmdW5jdGlvbiBmb3IgY29tcGF0aWJpbGl0eSB3aXRoIG5vbi1oYXJtb255IG1vZHVsZXNcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubiA9IGZ1bmN0aW9uKG1vZHVsZSkge1xuIFx0XHR2YXIgZ2V0dGVyID0gbW9kdWxlICYmIG1vZHVsZS5fX2VzTW9kdWxlID9cbiBcdFx0XHRmdW5jdGlvbiBnZXREZWZhdWx0KCkgeyByZXR1cm4gbW9kdWxlWydkZWZhdWx0J107IH0gOlxuIFx0XHRcdGZ1bmN0aW9uIGdldE1vZHVsZUV4cG9ydHMoKSB7IHJldHVybiBtb2R1bGU7IH07XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18uZChnZXR0ZXIsICdhJywgZ2V0dGVyKTtcbiBcdFx0cmV0dXJuIGdldHRlcjtcbiBcdH07XG5cbiBcdC8vIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbFxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5vID0gZnVuY3Rpb24ob2JqZWN0LCBwcm9wZXJ0eSkgeyByZXR1cm4gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsKG9iamVjdCwgcHJvcGVydHkpOyB9O1xuXG4gXHQvLyBfX3dlYnBhY2tfcHVibGljX3BhdGhfX1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5wID0gXCJcIjtcblxuXG4gXHQvLyBMb2FkIGVudHJ5IG1vZHVsZSBhbmQgcmV0dXJuIGV4cG9ydHNcbiBcdHJldHVybiBfX3dlYnBhY2tfcmVxdWlyZV9fKF9fd2VicGFja19yZXF1aXJlX18ucyA9IFwiLi9zcmMvcG9wdXAvcG9wdXAudHNcIik7XG4iLCJjb25zdCBkZWZhdWx0cyA9IE9iamVjdC5mcmVlemU8TWlycm9yQmxvY2tPcHRpb24+KHtcbiAgb3V0bGluZUJsb2NrVXNlcjogZmFsc2UsXG4gIGVuYWJsZUJsb2NrUmVmbGVjdGlvbjogZmFsc2UsXG4gIGJsb2NrTXV0ZWRVc2VyOiBmYWxzZSxcbiAgYWx3YXlzSW1tZWRpYXRlbHlCbG9ja01vZGU6IGZhbHNlLFxufSlcblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIHNhdmUobmV3T3B0aW9uOiBNaXJyb3JCbG9ja09wdGlvbikge1xuICBjb25zdCBvcHRpb24gPSBPYmplY3QuYXNzaWduPFxuICAgIG9iamVjdCxcbiAgICBNaXJyb3JCbG9ja09wdGlvbixcbiAgICBQYXJ0aWFsPE1pcnJvckJsb2NrT3B0aW9uPlxuICA+KHt9LCBkZWZhdWx0cywgbmV3T3B0aW9uKVxuICByZXR1cm4gYnJvd3Nlci5zdG9yYWdlLmxvY2FsLnNldCh7XG4gICAgb3B0aW9uLFxuICB9IGFzIGFueSlcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGxvYWQoKTogUHJvbWlzZTxNaXJyb3JCbG9ja09wdGlvbj4ge1xuICBjb25zdCBsb2FkZWQgPSBhd2FpdCBicm93c2VyLnN0b3JhZ2UubG9jYWwuZ2V0KCdvcHRpb24nKVxuICByZXR1cm4gT2JqZWN0LmFzc2lnbjxvYmplY3QsIE1pcnJvckJsb2NrT3B0aW9uLCBhbnk+KFxuICAgIHt9LFxuICAgIGRlZmF1bHRzLFxuICAgIGxvYWRlZC5vcHRpb25cbiAgKVxufVxuIiwiaW1wb3J0ICogYXMgT3B0aW9ucyBmcm9tICfrr7jrn6zruJTrnb0vZXh0b3B0aW9uJ1xuaW1wb3J0IHsgQWN0aW9uLCBnZXRVc2VyTmFtZUZyb21Ud2VldFVybCB9IGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL2NvbW1vbidcbmltcG9ydCAqIGFzIGkxOG4gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvaTE4bidcblxudHlwZSBUYWIgPSBicm93c2VyLnRhYnMuVGFiXG5cbmZ1bmN0aW9uIGNsb3NlUG9wdXAoKSB7XG4gIHdpbmRvdy5jbG9zZSgpXG59XG5cbmFzeW5jIGZ1bmN0aW9uIGFsZXJ0VG9UYWIodGFiSWQ6IG51bWJlciwgbWVzc2FnZTogc3RyaW5nKSB7XG4gIHJldHVybiBicm93c2VyLnRhYnMuc2VuZE1lc3NhZ2U8TUJBbGVydE1lc3NhZ2U+KHRhYklkLCB7XG4gICAgYWN0aW9uOiBBY3Rpb24uQWxlcnQsXG4gICAgbWVzc2FnZSxcbiAgfSlcbn1cblxuYXN5bmMgZnVuY3Rpb24gZ2V0Q3VycmVudFRhYigpOiBQcm9taXNlPFRhYiB8IG51bGw+IHtcbiAgY29uc3QgdGFicyA9IGF3YWl0IGJyb3dzZXIudGFicy5xdWVyeSh7IGFjdGl2ZTogdHJ1ZSwgY3VycmVudFdpbmRvdzogdHJ1ZSB9KVxuICBjb25zdCBjdXJyZW50VGFiID0gdGFic1swXVxuICBpZiAoIWN1cnJlbnRUYWIudXJsIHx8ICFjdXJyZW50VGFiLmlkKSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxuICByZXR1cm4gY3VycmVudFRhYlxufVxuXG5hc3luYyBmdW5jdGlvbiBleGVjdXRlQ2hhaW5CbG9jayhmb2xsb3dLaW5kOiBGb2xsb3dLaW5kKSB7XG4gIGNvbnN0IGN1cnJlbnRUYWIgPSBhd2FpdCBnZXRDdXJyZW50VGFiKClcbiAgaWYgKCEoY3VycmVudFRhYiAmJiB0eXBlb2YgY3VycmVudFRhYi5pZCA9PT0gJ251bWJlcicpKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgY29uc3QgdGFiSWQgPSBjdXJyZW50VGFiLmlkXG4gIGNvbnN0IHVybCA9IG5ldyBVUkwoY3VycmVudFRhYi51cmwhKVxuICBpZiAodXJsLmhvc3RuYW1lID09PSAndHdlZXRkZWNrLnR3aXR0ZXIuY29tJykge1xuICAgIC8vIFRPRE9cbiAgICBjb25zdCBhID0gJ01pcnJvciBCbG9jazog7Yq47JyX642x7JeQ7ISgIOyekeuPme2VmOyngCDslYrsirXri4jri6QuJ1xuICAgIGNvbnN0IGIgPSAn7Yq47JyE7YSwKGh0dHBzOi8vdHdpdHRlci5jb20p7JeQ7IScIOyLpO2Wie2VtOyjvOyEuOyalC4nXG4gICAgY29uc3QgbWVzc2FnZSA9IGAke2F9XFxuJHtifWBcbiAgICBhbGVydFRvVGFiKHRhYklkLCBtZXNzYWdlKVxuICAgIGNsb3NlUG9wdXAoKVxuICAgIHJldHVyblxuICB9XG4gIGNvbnN0IHVzZXJOYW1lID0gZ2V0VXNlck5hbWVGcm9tVHdlZXRVcmwodXJsKVxuICBpZiAoIXVzZXJOYW1lKSB7XG4gICAgY29uc3QgYSA9IGkxOG4uZ2V0TWVzc2FnZSgncGxlYXNlX3J1bl9vbl9wcm9maWxlX3BhZ2VfMScpXG4gICAgY29uc3QgYiA9IGkxOG4uZ2V0TWVzc2FnZSgncGxlYXNlX3J1bl9vbl9wcm9maWxlX3BhZ2VfMicpXG4gICAgY29uc3QgbWVzc2FnZSA9IGAke2F9XFxuJHtifWBcbiAgICBhbGVydFRvVGFiKHRhYklkLCBtZXNzYWdlKVxuICAgIGNsb3NlUG9wdXAoKVxuICAgIHJldHVyblxuICB9XG4gIGJyb3dzZXIudGFic1xuICAgIC5zZW5kTWVzc2FnZTxNQlN0YXJ0Q2hhaW5CbG9ja01lc3NhZ2U+KHRhYklkLCB7XG4gICAgICBhY3Rpb246IEFjdGlvbi5TdGFydENoYWluQmxvY2ssXG4gICAgICBmb2xsb3dLaW5kLFxuICAgICAgdXNlck5hbWUsXG4gICAgfSlcbiAgICAudGhlbihjbG9zZVBvcHVwKVxufVxuXG5kb2N1bWVudC5hZGRFdmVudExpc3RlbmVyKCdET01Db250ZW50TG9hZGVkJywgYXN5bmMgKCkgPT4ge1xuICBpMThuLmFwcGx5STE4bk9uSHRtbCgpXG4gIGNvbnN0IGN1cnJlbnRUYWIgPSBhd2FpdCBnZXRDdXJyZW50VGFiKClcbiAgaWYgKGN1cnJlbnRUYWIgJiYgY3VycmVudFRhYi51cmwpIHtcbiAgICBjb25zdCBjdXJyZW50VXJsID0gbmV3IFVSTChjdXJyZW50VGFiLnVybCEpXG4gICAgY29uc3QgY2JCdXR0b25zID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbDxIVE1MQnV0dG9uRWxlbWVudD4oJ2J1dHRvbi5jaGFpbi1ibG9jaycpXG4gICAgY29uc3Qgc3VwcG9ydGluZ0hvc3RuYW1lID0gWyd0d2l0dGVyLmNvbScsICdtb2JpbGUudHdpdHRlci5jb20nXVxuICAgIGlmIChzdXBwb3J0aW5nSG9zdG5hbWUuaW5jbHVkZXMoY3VycmVudFVybC5ob3N0bmFtZSkpIHtcbiAgICAgIGNiQnV0dG9ucy5mb3JFYWNoKGVsID0+IChlbC5kaXNhYmxlZCA9IGZhbHNlKSlcbiAgICB9IGVsc2Uge1xuICAgICAgY2JCdXR0b25zLmZvckVhY2goXG4gICAgICAgIGVsID0+IChlbC50aXRsZSA9IGkxOG4uZ2V0TWVzc2FnZSgncnVubmluZ19jaGFpbmJsb2NrX2lzX29ubHlfYXZhaWxhYmxlX29uX3R3aXR0ZXInKSlcbiAgICAgIClcbiAgICB9XG4gIH1cbiAgZG9jdW1lbnQucXVlcnlTZWxlY3RvcignLm1lbnUtaXRlbS5jaGFpbi1ibG9jay1mb2xsb3dlcnMnKSEuYWRkRXZlbnRMaXN0ZW5lcignY2xpY2snLCBldmVudCA9PiB7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKVxuICAgIGV4ZWN1dGVDaGFpbkJsb2NrKCdmb2xsb3dlcnMnKVxuICB9KVxuICBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKCcubWVudS1pdGVtLmNoYWluLWJsb2NrLWZvbGxvd2luZycpIS5hZGRFdmVudExpc3RlbmVyKCdjbGljaycsIGV2ZW50ID0+IHtcbiAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG4gICAgZXhlY3V0ZUNoYWluQmxvY2soJ2ZvbGxvd2luZycpXG4gIH0pXG4gIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoJy5tZW51LWl0ZW0ub3Blbi1vcHRpb24nKSEuYWRkRXZlbnRMaXN0ZW5lcignY2xpY2snLCBldmVudCA9PiB7XG4gICAgZXZlbnQucHJldmVudERlZmF1bHQoKVxuICAgIGJyb3dzZXIucnVudGltZS5vcGVuT3B0aW9uc1BhZ2UoKVxuICB9KVxuICB7XG4gICAgY29uc3QgbWFuaWZlc3QgPSBicm93c2VyLnJ1bnRpbWUuZ2V0TWFuaWZlc3QoKVxuICAgIGNvbnN0IGN1cnJlbnRWZXJzaW9uID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvcjxIVE1MRWxlbWVudD4oJy5jdXJyZW50VmVyc2lvbicpIVxuICAgIGN1cnJlbnRWZXJzaW9uLnRleHRDb250ZW50ID0gYE1pcnJvciBCbG9jayB2JHttYW5pZmVzdC52ZXJzaW9ufWBcbiAgfVxuICB7XG4gICAgY29uc3Qgb3B0aW9ucyA9IGF3YWl0IE9wdGlvbnMubG9hZCgpXG4gICAgY29uc3QgYmxvY2tSZWZsZWN0aW9uID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvcjxIVE1MRWxlbWVudD4oJy5ibG9ja1JlZmxlY3Rpb24nKSFcbiAgICBjb25zdCB2YWwgPSBvcHRpb25zLmVuYWJsZUJsb2NrUmVmbGVjdGlvblxuICAgIGJsb2NrUmVmbGVjdGlvbi5jbGFzc0xpc3QudG9nZ2xlKCdvbicsIHZhbClcbiAgICBibG9ja1JlZmxlY3Rpb24udGV4dENvbnRlbnQgPSBgJHtpMThuLmdldE1lc3NhZ2UoJ2Jsb2NrX3JlZmxlY3Rpb24nKX06ICR7XG4gICAgICB2YWwgPyAnT24gXFx1MjcxNCcgOiAnT2ZmJ1xuICAgIH1gXG4gIH1cbn0pXG4iLCJleHBvcnQgY29uc3QgZW51bSBBY3Rpb24ge1xuICBTdGFydENoYWluQmxvY2sgPSAnTWlycm9yQmxvY2svU3RhcnQnLFxuICBTdG9wQ2hhaW5CbG9jayA9ICdNaXJyb3JCbG9jay9TdG9wJyxcbiAgQWxlcnQgPSAnTWlycm9yQmxvY2svQWxlcnQnLFxufVxuXG5jb25zdCBVU0VSX05BTUVfQkxBQ0tMSVNUID0gT2JqZWN0LmZyZWV6ZShbXG4gICcxJyxcbiAgJ2Fib3V0JyxcbiAgJ2FjY291bnQnLFxuICAnZm9sbG93ZXJzJyxcbiAgJ2ZvbGxvd2luZ3MnLFxuICAnaGFzaHRhZycsXG4gICdob21lJyxcbiAgJ2knLFxuICAnbGlzdHMnLFxuICAnbG9naW4nLFxuICAnb2F1dGgnLFxuICAncHJpdmFjeScsXG4gICdzZWFyY2gnLFxuICAndG9zJyxcbiAgJ25vdGlmaWNhdGlvbnMnLFxuICAnbWVzc2FnZXMnLFxuICAnZXhwbG9yZScsXG5dKVxuXG5leHBvcnQgY2xhc3MgVHdpdHRlclVzZXJNYXAgZXh0ZW5kcyBNYXA8c3RyaW5nLCBUd2l0dGVyVXNlcj4ge1xuICBwdWJsaWMgYWRkVXNlcih1c2VyOiBUd2l0dGVyVXNlcikge1xuICAgIHRoaXMuc2V0KHVzZXIuaWRfc3RyLCB1c2VyKVxuICB9XG4gIHB1YmxpYyBoYXNVc2VyKHVzZXI6IFR3aXR0ZXJVc2VyKSB7XG4gICAgcmV0dXJuIHRoaXMuaGFzKHVzZXIuaWRfc3RyKVxuICB9XG4gIHB1YmxpYyB0b1VzZXJBcnJheSgpOiBUd2l0dGVyVXNlcltdIHtcbiAgICByZXR1cm4gQXJyYXkuZnJvbSh0aGlzLnZhbHVlcygpKVxuICB9XG4gIHB1YmxpYyB0b1VzZXJPYmplY3QoKTogVHdpdHRlclVzZXJFbnRpdGllcyB7XG4gICAgY29uc3QgdXNlcnNPYmo6IFR3aXR0ZXJVc2VyRW50aXRpZXMgPSBPYmplY3QuY3JlYXRlKG51bGwpXG4gICAgZm9yIChjb25zdCBbdXNlcklkLCB1c2VyXSBvZiB0aGlzKSB7XG4gICAgICB1c2Vyc09ialt1c2VySWRdID0gdXNlclxuICAgIH1cbiAgICByZXR1cm4gdXNlcnNPYmpcbiAgfVxuICBwdWJsaWMgc3RhdGljIGZyb21Vc2Vyc0FycmF5KHVzZXJzOiBUd2l0dGVyVXNlcltdKTogVHdpdHRlclVzZXJNYXAge1xuICAgIHJldHVybiBuZXcgVHdpdHRlclVzZXJNYXAodXNlcnMubWFwKCh1c2VyKTogW3N0cmluZywgVHdpdHRlclVzZXJdID0+IFt1c2VyLmlkX3N0ciwgdXNlcl0pKVxuICB9XG4gIHB1YmxpYyBmaWx0ZXIoZm46ICh1c2VyOiBUd2l0dGVyVXNlcikgPT4gYm9vbGVhbik6IFR3aXR0ZXJVc2VyTWFwIHtcbiAgICByZXR1cm4gVHdpdHRlclVzZXJNYXAuZnJvbVVzZXJzQXJyYXkodGhpcy50b1VzZXJBcnJheSgpLmZpbHRlcihmbikpXG4gIH1cbn1cblxuZXhwb3J0IGFic3RyYWN0IGNsYXNzIEV2ZW50RW1pdHRlciB7XG4gIHByb3RlY3RlZCBldmVudHM6IEV2ZW50U3RvcmUgPSB7fVxuICBvbjxUPihldmVudE5hbWU6IHN0cmluZywgaGFuZGxlcjogKHQ6IFQpID0+IGFueSkge1xuICAgIGlmICghKGV2ZW50TmFtZSBpbiB0aGlzLmV2ZW50cykpIHtcbiAgICAgIHRoaXMuZXZlbnRzW2V2ZW50TmFtZV0gPSBbXVxuICAgIH1cbiAgICB0aGlzLmV2ZW50c1tldmVudE5hbWVdLnB1c2goaGFuZGxlcilcbiAgICByZXR1cm4gdGhpc1xuICB9XG4gIGVtaXQ8VD4oZXZlbnROYW1lOiBzdHJpbmcsIGV2ZW50SGFuZGxlclBhcmFtZXRlcj86IFQpIHtcbiAgICBjb25zdCBoYW5kbGVycyA9IHRoaXMuZXZlbnRzW2V2ZW50TmFtZV0gfHwgW11cbiAgICBoYW5kbGVycy5mb3JFYWNoKGhhbmRsZXIgPT4gaGFuZGxlcihldmVudEhhbmRsZXJQYXJhbWV0ZXIpKVxuICAgIHJldHVybiB0aGlzXG4gIH1cbn1cblxuZXhwb3J0IGZ1bmN0aW9uIHNsZWVwKHRpbWU6IG51bWJlcik6IFByb21pc2U8dm9pZD4ge1xuICByZXR1cm4gbmV3IFByb21pc2UocmVzb2x2ZSA9PiB3aW5kb3cuc2V0VGltZW91dChyZXNvbHZlLCB0aW1lKSlcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGluamVjdFNjcmlwdChwYXRoOiBzdHJpbmcpOiBQcm9taXNlPHZvaWQ+IHtcbiAgcmV0dXJuIG5ldyBQcm9taXNlKHJlc29sdmUgPT4ge1xuICAgIGNvbnN0IHNjcmlwdCA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoJ3NjcmlwdCcpXG4gICAgc2NyaXB0LmFkZEV2ZW50TGlzdGVuZXIoJ2xvYWQnLCAoKSA9PiB7XG4gICAgICBzY3JpcHQucmVtb3ZlKClcbiAgICAgIHJlc29sdmUoKVxuICAgIH0pXG4gICAgc2NyaXB0LnNyYyA9IGJyb3dzZXIucnVudGltZS5nZXRVUkwocGF0aClcbiAgICBjb25zdCBhcHBlbmRUYXJnZXQgPSBkb2N1bWVudC5oZWFkIHx8IGRvY3VtZW50LmRvY3VtZW50RWxlbWVudFxuICAgIGFwcGVuZFRhcmdldCEuYXBwZW5kQ2hpbGQoc2NyaXB0KVxuICB9KVxufVxuXG5leHBvcnQgZnVuY3Rpb24gY29weUZyb3plbk9iamVjdDxUIGV4dGVuZHMgb2JqZWN0PihvYmo6IFQpOiBSZWFkb25seTxUPiB7XG4gIHJldHVybiBPYmplY3QuZnJlZXplKE9iamVjdC5hc3NpZ24oe30sIG9iaikpXG59XG5cbmV4cG9ydCBmdW5jdGlvbiogZ2V0QWRkZWRFbGVtZW50c0Zyb21NdXRhdGlvbnMoXG4gIG11dGF0aW9uczogTXV0YXRpb25SZWNvcmRbXVxuKTogSXRlcmFibGVJdGVyYXRvcjxIVE1MRWxlbWVudD4ge1xuICBmb3IgKGNvbnN0IG11dCBvZiBtdXRhdGlvbnMpIHtcbiAgICBmb3IgKGNvbnN0IG5vZGUgb2YgbXV0LmFkZGVkTm9kZXMpIHtcbiAgICAgIGlmIChub2RlIGluc3RhbmNlb2YgSFRNTEVsZW1lbnQpIHtcbiAgICAgICAgeWllbGQgbm9kZVxuICAgICAgfVxuICAgIH1cbiAgfVxufVxuXG5jb25zdCB0b3VjaGVkRWxlbXMgPSBuZXcgV2Vha1NldDxIVE1MRWxlbWVudD4oKVxuZXhwb3J0IGZ1bmN0aW9uKiBpdGVyYXRlVW50b3VjaGVkRWxlbXM8VCBleHRlbmRzIEhUTUxFbGVtZW50PihlbGVtczogSXRlcmFibGU8VD4gfCBBcnJheUxpa2U8VD4pIHtcbiAgZm9yIChjb25zdCBlbGVtIG9mIEFycmF5LmZyb20oZWxlbXMpKSB7XG4gICAgaWYgKCF0b3VjaGVkRWxlbXMuaGFzKGVsZW0pKSB7XG4gICAgICB0b3VjaGVkRWxlbXMuYWRkKGVsZW0pXG4gICAgICB5aWVsZCBlbGVtXG4gICAgfVxuICB9XG59XG5cbi8vIG5haXZlIGNoZWNrIGdpdmVuIG9iamVjdCBpcyBUd2l0dGVyVXNlclxuZXhwb3J0IGZ1bmN0aW9uIGlzVHdpdHRlclVzZXIob2JqOiB1bmtub3duKTogb2JqIGlzIFR3aXR0ZXJVc2VyIHtcbiAgaWYgKCEob2JqICYmIHR5cGVvZiBvYmogPT09ICdvYmplY3QnKSkge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGNvbnN0IG9iakFzQW55ID0gb2JqIGFzIGFueVxuICBpZiAodHlwZW9mIG9iakFzQW55LmlkX3N0ciAhPT0gJ3N0cmluZycpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICBpZiAodHlwZW9mIG9iakFzQW55LnNjcmVlbl9uYW1lICE9PSAnc3RyaW5nJykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuYmxvY2tpbmcgIT09ICdib29sZWFuJykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuYmxvY2tlZF9ieSAhPT0gJ2Jvb2xlYW4nKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgcmV0dXJuIHRydWVcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGlzSW5OYW1lQmxhY2tsaXN0KG5hbWU6IHN0cmluZyk6IGJvb2xlYW4ge1xuICBjb25zdCBsb3dlckNhc2VkTmFtZSA9IG5hbWUudG9Mb3dlckNhc2UoKVxuICByZXR1cm4gVVNFUl9OQU1FX0JMQUNLTElTVC5pbmNsdWRlcyhsb3dlckNhc2VkTmFtZSlcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIHZhbGlkYXRlVHdpdHRlclVzZXJOYW1lKHVzZXJOYW1lOiBzdHJpbmcpOiBib29sZWFuIHtcbiAgaWYgKGlzSW5OYW1lQmxhY2tsaXN0KHVzZXJOYW1lKSkge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGNvbnN0IHBhdHRlcm4gPSAvXlswLTlhLXpfXXsxLDE1fSQvaVxuICByZXR1cm4gcGF0dGVybi50ZXN0KHVzZXJOYW1lKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gZ2V0VXNlck5hbWVGcm9tVHdlZXRVcmwoXG4gIGV4dHJhY3RNZTogSFRNTEFuY2hvckVsZW1lbnQgfCBVUkwgfCBMb2NhdGlvblxuKTogc3RyaW5nIHwgbnVsbCB7XG4gIGNvbnN0IHsgaG9zdG5hbWUsIHBhdGhuYW1lIH0gPSBleHRyYWN0TWVcbiAgY29uc3Qgc3VwcG9ydGluZ0hvc3RuYW1lID0gWyd0d2l0dGVyLmNvbScsICdtb2JpbGUudHdpdHRlci5jb20nXVxuICBpZiAoIXN1cHBvcnRpbmdIb3N0bmFtZS5pbmNsdWRlcyhob3N0bmFtZSkpIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG4gIGNvbnN0IG1hdGNoZXMgPSAvXlxcLyhbMC05YS16X117MSwxNX0pL2kuZXhlYyhwYXRobmFtZSlcbiAgaWYgKCFtYXRjaGVzKSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxuICBjb25zdCBuYW1lID0gbWF0Y2hlc1sxXVxuICBpZiAodmFsaWRhdGVUd2l0dGVyVXNlck5hbWUobmFtZSkpIHtcbiAgICByZXR1cm4gbmFtZVxuICB9IGVsc2Uge1xuICAgIHJldHVybiBudWxsXG4gIH1cbn1cbiIsInR5cGUgSTE4Tk1lc3NhZ2VzID0gdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMva28vbWVzc2FnZXMuanNvbicpXG50eXBlIFN1YnN0SXRlbSA9IG51bWJlciB8IHN0cmluZ1xudHlwZSBTdWJzdGl0dXRpb25zID0gU3Vic3RJdGVtIHwgU3Vic3RJdGVtW10gfCB1bmRlZmluZWRcbmV4cG9ydCB0eXBlIEkxOE5NZXNzYWdlS2V5cyA9IGtleW9mIEkxOE5NZXNzYWdlc1xuXG5leHBvcnQgZnVuY3Rpb24gZ2V0TWVzc2FnZShrZXk6IHN0cmluZyAmIEkxOE5NZXNzYWdlS2V5cywgc3Vic3RzOiBTdWJzdGl0dXRpb25zID0gdW5kZWZpbmVkKSB7XG4gIGlmIChBcnJheS5pc0FycmF5KHN1YnN0cykpIHtcbiAgICByZXR1cm4gYnJvd3Nlci5pMThuLmdldE1lc3NhZ2UoXG4gICAgICBrZXksXG4gICAgICBzdWJzdHMubWFwKHMgPT4gcy50b0xvY2FsZVN0cmluZygpKVxuICAgIClcbiAgfSBlbHNlIGlmICh0eXBlb2Ygc3Vic3RzID09PSAnbnVtYmVyJykge1xuICAgIHJldHVybiBicm93c2VyLmkxOG4uZ2V0TWVzc2FnZShrZXksIHN1YnN0cy50b0xvY2FsZVN0cmluZygpKVxuICB9IGVsc2Uge1xuICAgIHJldHVybiBicm93c2VyLmkxOG4uZ2V0TWVzc2FnZShrZXksIHN1YnN0cylcbiAgfVxufVxuXG5mdW5jdGlvbiB0cnlHZXRNZXNzYWdlKG1lc3NhZ2VOYW1lOiBzdHJpbmcpIHtcbiAgY29uc3QgbWVzc2FnZSA9IGdldE1lc3NhZ2UobWVzc2FnZU5hbWUgYXMgYW55KVxuICBpZiAoIW1lc3NhZ2UpIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoYGludmFsaWQgbWVzc2FnZU5hbWU/IFwiJHttZXNzYWdlTmFtZX1cImApXG4gIH1cbiAgcmV0dXJuIG1lc3NhZ2Vcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGFwcGx5STE4bk9uSHRtbCgpIHtcbiAgY29uc3QgaTE4blRleHRFbGVtZW50cyA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGwoJ1tkYXRhLWkxOG4tdGV4dF0nKVxuICBmb3IgKGNvbnN0IGVsZW0gb2YgaTE4blRleHRFbGVtZW50cykge1xuICAgIGNvbnN0IG1lc3NhZ2VOYW1lID0gZWxlbS5nZXRBdHRyaWJ1dGUoJ2RhdGEtaTE4bi10ZXh0JykhXG4gICAgY29uc3QgbWVzc2FnZSA9IHRyeUdldE1lc3NhZ2UobWVzc2FnZU5hbWUpXG4gICAgLy8gY29uc29sZS5kZWJ1ZygnJW8gLnRleHRDb250ZW50ID0gJXMgW2Zyb20gJXNdJywgZWxlbSwgbWVzc2FnZSwgbWVzc2FnZU5hbWUpXG4gICAgZWxlbS50ZXh0Q29udGVudCA9IG1lc3NhZ2VcbiAgfVxuICBjb25zdCBpMThuQXR0cnNFbGVtZW50cyA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGwoJ1tkYXRhLWkxOG4tYXR0cnNdJylcbiAgZm9yIChjb25zdCBlbGVtIG9mIGkxOG5BdHRyc0VsZW1lbnRzKSB7XG4gICAgLy8gZXhhbXBsZTpcbiAgICAvLyA8c3BhbiBkYXRhLWkxOG4tYXR0cnM9XCJ0aXRsZT1wb3B1cF90aXRsZSZhbHQ9cG9wdXBfYWx0XCI+PC9zcGFuPlxuICAgIGNvbnN0IGF0dHJzVG9OYW1lU2VyaWFsaXplZCA9IGVsZW0uZ2V0QXR0cmlidXRlKCdkYXRhLWkxOG4tYXR0cnMnKSFcbiAgICBjb25zdCBhdHRyc1RvTmFtZVBhcnNlZCA9IG5ldyBVUkxTZWFyY2hQYXJhbXMoYXR0cnNUb05hbWVTZXJpYWxpemVkKVxuICAgIGF0dHJzVG9OYW1lUGFyc2VkLmZvckVhY2goKHZhbHVlLCBrZXkpID0+IHtcbiAgICAgIC8vIGNvbnNvbGUuZGVidWcoJ3xhdHRyfCBrZXk6XCIlc1wiLCB2YWx1ZTpcIiVzXCInLCBrZXksIHZhbHVlKVxuICAgICAgY29uc3QgbWVzc2FnZSA9IHRyeUdldE1lc3NhZ2UodmFsdWUpXG4gICAgICBlbGVtLnNldEF0dHJpYnV0ZShrZXksIG1lc3NhZ2UpXG4gICAgfSlcbiAgfVxufVxuXG5mdW5jdGlvbiBjaGVja01pc3NpbmdUcmFuc2xhdGlvbnMoXG4gIC8vIGtvL21lc3NhZ2VzLmpzb24g7JeUIOyeiOqzoCBlbi9tZXNzYWdlcy5qc29uIOyXlCDsl4bripQg7YKk6rCAIOyeiOycvOuptFxuICAvLyBUeXBlU2NyaXB0IOy7tO2MjOydvOufrOqwgCDtg4DsnoXsl5Drn6zrpbwg7J287Jy87YKo64ukLlxuICAvLyB0c2NvbmZpZy5qc29u7J2YIHJlc29sdmVKc29uTW9kdWxlIOyYteyFmOydhCDsvJzslbwg7ZWoXG4gIGtleXM6XG4gICAgfCBFeGNsdWRlPFxuICAgICAgICBrZXlvZiB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9rby9tZXNzYWdlcy5qc29uJyksXG4gICAgICAgIGtleW9mIHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2VuL21lc3NhZ2VzLmpzb24nKVxuICAgICAgPlxuICAgIHwgRXhjbHVkZTxcbiAgICAgICAga2V5b2YgdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMvZW4vbWVzc2FnZXMuanNvbicpLFxuICAgICAgICBrZXlvZiB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9rby9tZXNzYWdlcy5qc29uJylcbiAgICAgID4sXG4gIGZpbmQ6IChfa2V5czogbmV2ZXIpID0+IHZvaWQsXG4gIF9jaGVjayA9IGZpbmQoa2V5cylcbikge31cbmNoZWNrTWlzc2luZ1RyYW5zbGF0aW9uc1xuIl0sInNvdXJjZVJvb3QiOiIifQ==