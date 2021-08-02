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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/scripts/mirrorblock/tweetdeck.ts");
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

/***/ "./src/scripts/mirrorblock/tweetdeck.ts":
/*!**********************************************!*\
  !*** ./src/scripts/mirrorblock/tweetdeck.ts ***!
  \**********************************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _extoption__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/extoption */ "./src/extoption.ts");
/* harmony import */ var _scripts_common__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/common */ "./src/scripts/common.ts");
/* harmony import */ var _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! 미러블락/scripts/twitter-api */ "./src/scripts/twitter-api.ts");



function extractUserData(userDataElem) {
    const dataset = userDataElem.dataset;
    const toBoolean = (str)=>str === 'true'
    ;
    const result = {
        template: dataset.template,
        id: dataset.id,
        name: dataset.name,
        screenName: dataset.screenName,
        blocking: toBoolean(dataset.blocking),
        blockedBy: toBoolean(dataset.blockedBy),
        muting: toBoolean(dataset.muting),
        following: toBoolean(dataset.following),
        followedBy: toBoolean(dataset.followedBy)
    };
    return result;
}
function getMyName() {
    let myName = document.body.getAttribute('data-default-account-username');
    myName = myName ? '@' + myName : 'You';
    return myName;
}
function makeBlockedBadge() {
    const myName = getMyName();
    const badge = document.createElement('span');
    badge.className = 'mob-BlockStatus';
    badge.textContent = `Blocks ${myName}`;
    return badge;
}
function makeBlockReflectedBadge() {
    const badge = document.createElement('span');
    badge.className = 'mob-BlockReflectedStatus';
    badge.textContent = `Block Reflected!`;
    return badge;
}
function changeFollowButtonToBlocked(elem) {
    const btn = elem.querySelector('.prf-actions .js-action-follow');
    if (!btn) {
        return;
    }
    btn.classList.remove('s-not-following');
    btn.classList.add('s-blocking');
}
function findBadgeTarget(elem) {
    let result;
    const profileElem = elem.closest('.s-profile.prf');
    if (profileElem) {
        result = profileElem.querySelector('.prf-header p.username');
        if (result) {
            return result;
        }
    }
    const previousElement = elem.previousElementSibling;
    if (previousElement) {
        if (previousElement.classList.contains('account-summary')) {
            const accElem = previousElement;
            result = accElem.querySelector('.username');
            if (result) {
                return result;
            }
        }
    }
    return null;
}
async function userDataHandler(userDataElem) {
    if (userDataElem.classList.contains('mob-checked')) {
        return;
    }
    userDataElem.classList.add('mob-checked');
    const userData = extractUserData(userDataElem);
    if (!userData.blockedBy) {
        return;
    }
    let badgeTarget = findBadgeTarget(userDataElem);
    if (!badgeTarget) {
        return;
    }
    const options = await _extoption__WEBPACK_IMPORTED_MODULE_0__["load"]();
    const badge = makeBlockedBadge();
    badgeTarget.appendChild(badge);
    const muteSkip = userData.muting && !options.blockMutedUser;
    const shouldBlock = options.enableBlockReflection && !userData.blocking && !muteSkip;
    if (shouldBlock) {
        _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_2__["blockUserById"](userData.id).then((result)=>{
            if (result) {
                const profileElem = userDataElem.closest('.s-profile.prf');
                if (profileElem) {
                    changeFollowButtonToBlocked(profileElem);
                }
                const reflectedBadge = makeBlockReflectedBadge();
                badgeTarget.appendChild(reflectedBadge);
            }
        });
    }
}
function main() {
    Object(_scripts_common__WEBPACK_IMPORTED_MODULE_1__["injectScript"])('bundled/tweetdeck_inject.bun.js');
    const observer = new MutationObserver((mutations)=>{
        for (const elem of Object(_scripts_common__WEBPACK_IMPORTED_MODULE_1__["getAddedElementsFromMutations"])(mutations)){
            const elementsToHandle = [
                ...elem.querySelectorAll('span.mob-user-data')
            ];
            if (elem.matches('span.mob-user-data')) {
                elementsToHandle.push(elem);
            }
            elementsToHandle.forEach(userDataHandler);
        }
    });
    observer.observe(document.body, {
        subtree: true,
        childList: true
    });
}
main();


/***/ }),

/***/ "./src/scripts/twitter-api.ts":
/*!************************************!*\
  !*** ./src/scripts/twitter-api.ts ***!
  \************************************/
/*! exports provided: APIError, blockUser, blockUserById, getAllFollows, getSingleUserById, getSingleUserByName, getMultipleUsersById, getFriendships, getRelationship, getMyself, getRateLimitStatus, getFollowsScraperRateLimitStatus, sendRequest */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "APIError", function() { return APIError; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "blockUser", function() { return blockUser; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "blockUserById", function() { return blockUserById; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getAllFollows", function() { return getAllFollows; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getSingleUserById", function() { return getSingleUserById; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getSingleUserByName", function() { return getSingleUserByName; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getMultipleUsersById", function() { return getMultipleUsersById; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getFriendships", function() { return getFriendships; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getRelationship", function() { return getRelationship; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getMyself", function() { return getMyself; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getRateLimitStatus", function() { return getRateLimitStatus; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getFollowsScraperRateLimitStatus", function() { return getFollowsScraperRateLimitStatus; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "sendRequest", function() { return sendRequest; });
/* harmony import */ var _common__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./common */ "./src/scripts/common.ts");

const BEARER_TOKEN = `AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA`;
// CORB* 로 인해 content scripts에서 api.twitter.com 을 사용할 수 없다.
// https://www.chromestatus.com/feature/5629709824032768
// https://www.chromium.org/Home/chromium-security/corb-for-developers
let apiPrefix = 'https://twitter.com/i/api/1.1';
if (location.hostname === 'mobile.twitter.com') {
    apiPrefix = 'https://mobile.twitter.com/i/api/1.1';
}
class APIError extends Error {
    constructor(response){
        super('API Error!');
        this.response = response;
        // from: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-2.html#support-for-newtarget
        Object.setPrototypeOf(this, new.target.prototype);
    }
}
async function blockUser(user) {
    if (user.blocking) {
        return true;
    }
    const shouldNotBlock = user.following || user.followed_by || user.follow_request_sent || !user.blocked_by;
    if (shouldNotBlock) {
        const fatalErrorMessage = `!!!!!FATAL!!!!!:\nattempted to block user that should NOT block!!\n(user: ${user.screen_name})`;
        throw new Error(fatalErrorMessage);
    }
    return blockUserById(user.id_str);
}
async function blockUserById(userId) {
    const response1 = await sendRequest('post', '/blocks/create.json', {
        user_id: userId,
        include_entities: false,
        skip_status: true
    });
    return response1.ok;
}
async function getFollowingsList(user, cursor = '-1') {
    const response1 = await sendRequest('get', '/friends/list.json', {
        user_id: user.id_str,
        count: 200,
        skip_status: true,
        include_user_entities: false,
        cursor
    });
    if (response1.ok) {
        return response1.body;
    } else {
        throw new APIError(response1);
    }
}
async function getFollowersList(user, cursor = '-1') {
    const response1 = await sendRequest('get', '/followers/list.json', {
        user_id: user.id_str,
        // screen_name: userName,
        count: 200,
        skip_status: true,
        include_user_entities: false,
        cursor
    });
    if (response1.ok) {
        return response1.body;
    } else {
        throw new APIError(response1);
    }
}
async function* getAllFollows(user, followKind, options) {
    let cursor = '-1';
    while(true){
        try {
            let json;
            switch(followKind){
                case 'followers':
                    json = await getFollowersList(user, cursor);
                    break;
                case 'following':
                    json = await getFollowingsList(user, cursor);
                    break;
                default:
                    throw new Error('unreachable');
            }
            cursor = json.next_cursor_str;
            const users = json.users;
            yield* users.map((user1)=>({
                    ok: true,
                    value: Object.freeze(user1)
                })
            );
            if (cursor === '0') {
                break;
            } else {
                await Object(_common__WEBPACK_IMPORTED_MODULE_0__["sleep"])(options.delay);
                continue;
            }
        } catch (error) {
            if (error instanceof APIError) {
                yield {
                    ok: false,
                    error
                };
            } else {
                throw error;
            }
        }
    }
}
async function getSingleUserById(userId) {
    const response1 = await sendRequest('get', '/users/show.json', {
        user_id: userId,
        skip_status: true,
        include_entities: false
    });
    if (response1.ok) {
        return response1.body;
    } else {
        throw new APIError(response1);
    }
}
async function getSingleUserByName(userName) {
    const isValidUserName = Object(_common__WEBPACK_IMPORTED_MODULE_0__["validateTwitterUserName"])(userName);
    if (!isValidUserName) {
        throw new Error(`Invalid user name "${userName}"!`);
    }
    const response1 = await sendRequest('get', '/users/show.json', {
        // user_id: user.id_str,
        screen_name: userName,
        skip_status: true,
        include_entities: false
    });
    if (response1.ok) {
        return response1.body;
    } else {
        throw new APIError(response1);
    }
}
async function getMultipleUsersById(userIds) {
    if (userIds.length === 0) {
        return [];
    }
    if (userIds.length > 100) {
        throw new Error('too many users! (> 100)');
    }
    const joinedIds = Array.from(new Set(userIds)).join(',');
    const response1 = await sendRequest('post', '/users/lookup.json', {
        user_id: joinedIds,
        include_entities: false
    });
    if (response1.ok) {
        return response1.body;
    } else {
        throw new APIError(response1);
    }
}
async function getFriendships(users) {
    const userIds = users.map((user)=>user.id_str
    );
    if (userIds.length === 0) {
        return [];
    }
    if (userIds.length > 100) {
        throw new Error('too many users! (> 100)');
    }
    const joinedIds = Array.from(new Set(userIds)).join(',');
    const response1 = await sendRequest('get', '/friendships/lookup.json', {
        user_id: joinedIds
    });
    if (response1.ok) {
        return response1.body;
    } else {
        throw new Error('response is not ok');
    }
}
async function getRelationship(sourceUser, targetUser) {
    const source_id = sourceUser.id_str;
    const target_id = targetUser.id_str;
    const response1 = await sendRequest('get', '/friendships/show.json', {
        source_id,
        target_id
    });
    if (response1.ok) {
        const { relationship  } = response1.body;
        return relationship;
    } else {
        throw new Error('response is not ok');
    }
}
async function getMyself() {
    const response1 = await sendRequest('get', '/account/verify_credentials.json');
    if (response1.ok) {
        return response1.body;
    } else {
        throw new APIError(response1);
    }
}
async function getRateLimitStatus() {
    const response1 = await sendRequest('get', '/application/rate_limit_status.json');
    const { resources  } = response1.body;
    return resources;
}
async function getFollowsScraperRateLimitStatus(followKind) {
    const limitStatus = await getRateLimitStatus();
    if (followKind === 'followers') {
        return limitStatus.followers['/followers/list'];
    } else if (followKind === 'following') {
        return limitStatus.friends['/friends/list'];
    } else {
        throw new Error('unreachable');
    }
}
function getCsrfTokenFromCookies() {
    return /\bct0=([0-9a-f]+)/i.exec(document.cookie)[1];
}
function generateTwitterAPIOptions(obj) {
    const csrfToken = getCsrfTokenFromCookies();
    const headers = new Headers();
    headers.set('authorization', `Bearer ${BEARER_TOKEN}`);
    headers.set('x-csrf-token', csrfToken);
    headers.set('x-twitter-active-user', 'yes');
    headers.set('x-twitter-auth-type', 'OAuth2Session');
    const result = {
        method: 'get',
        mode: 'cors',
        credentials: 'include',
        referrer: 'https://twitter.com/',
        headers
    };
    Object.assign(result, obj);
    return result;
}
function setDefaultParams(params) {
    params.set('include_profile_interstitial_type', '1');
    params.set('include_blocking', '1');
    params.set('include_blocked_by', '1');
    params.set('include_followed_by', '1');
    params.set('include_want_retweets', '1');
    params.set('include_mute_edge', '1');
    params.set('include_can_dm', '1');
}
async function sendRequest(method, path, paramsObj = {
}) {
    const fetchOptions = generateTwitterAPIOptions({
        method
    });
    const url = new URL(apiPrefix + path);
    let params;
    if (method === 'get') {
        params = url.searchParams;
    } else {
        params = new URLSearchParams();
        fetchOptions.body = params;
    }
    setDefaultParams(params);
    for (const [key, value] of Object.entries(paramsObj)){
        params.set(key, value.toString());
    }
    const response1 = await fetch(url.toString(), fetchOptions);
    const headers = Array.from(response1.headers).reduce((obj, [name, value1])=>(obj[name] = value1, obj)
    , {
    });
    const { ok , status , statusText  } = response1;
    const body = await response1.json();
    const apiResponse = {
        ok,
        status,
        statusText,
        headers,
        body
    };
    return apiResponse;
}


/***/ })

/******/ });
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V4dG9wdGlvbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9jb21tb24udHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvbWlycm9yYmxvY2svdHdlZXRkZWNrLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL3R3aXR0ZXItYXBpLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7UUFBQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTs7O1FBR0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBLDBDQUEwQyxnQ0FBZ0M7UUFDMUU7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQSx3REFBd0Qsa0JBQWtCO1FBQzFFO1FBQ0EsaURBQWlELGNBQWM7UUFDL0Q7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBLHlDQUF5QyxpQ0FBaUM7UUFDMUUsZ0hBQWdILG1CQUFtQixFQUFFO1FBQ3JJO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMkJBQTJCLDBCQUEwQixFQUFFO1FBQ3ZELGlDQUFpQyxlQUFlO1FBQ2hEO1FBQ0E7UUFDQTs7UUFFQTtRQUNBLHNEQUFzRCwrREFBK0Q7O1FBRXJIO1FBQ0E7OztRQUdBO1FBQ0E7Ozs7Ozs7Ozs7Ozs7Ozs7TUNsRk0sUUFBUSxHQUFHLE1BQU0sQ0FBQyxNQUFNO0lBQzVCLGdCQUFnQixFQUFFLEtBQUs7SUFDdkIscUJBQXFCLEVBQUUsS0FBSztJQUM1QixjQUFjLEVBQUUsS0FBSztJQUNyQiwwQkFBMEIsRUFBRSxLQUFLOztlQUdiLElBQUksQ0FBQyxTQUE0QjtVQUMvQyxNQUFNLEdBQUcsTUFBTSxD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QVE7O1VBRTFCLFNBQVEsU0FBUyxLQUFLLENBQUMsR0FBRyxDQUFDLFFBQVEsSUFBSSxZQUFZO1VBQ25ELE9BQU8sR0FBRyxLQUFLLENBQUMsSUFBSSxDQUFDLFNBQVEsQ0FBQyxPQUFPLEVBQUUsTUFBTSxFQUNoRCxHQUFHLEdBQUcsSUFBSSxFQUFFLE1BQUssS0FBUSxHQUFHLENBQUMsSUFBSSxJQUFJLE1BQUssRUFBRyxHQUFHOzs7WUFHM0MsRUFBRSxHQUFFLE1BQU0sR0FBRSxVQUFVLE1BQUssU0FBUTtVQUNyQyxJQUFJLFNBQVMsU0FBUSxDQUFDLElBQUk7VUFDMUIsV0FBVztRQUNmLEVBQUU7UUFDRixNQUFNO1FBQ04sVUFBVTtRQUNWLE9BQU87UUFDUCxJQUFJOztXQUVDLFdBQVciLCJmaWxlIjoidHdlZXRkZWNrLmJ1bi5qcyIsInNvdXJjZXNDb250ZW50IjpbIiBcdC8vIFRoZSBtb2R1bGUgY2FjaGVcbiBcdHZhciBpbnN0YWxsZWRNb2R1bGVzID0ge307XG5cbiBcdC8vIFRoZSByZXF1aXJlIGZ1bmN0aW9uXG4gXHRmdW5jdGlvbiBfX3dlYnBhY2tfcmVxdWlyZV9fKG1vZHVsZUlkKSB7XG5cbiBcdFx0Ly8gQ2hlY2sgaWYgbW9kdWxlIGlzIGluIGNhY2hlXG4gXHRcdGlmKGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdKSB7XG4gXHRcdFx0cmV0dXJuIGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdLmV4cG9ydHM7XG4gXHRcdH1cbiBcdFx0Ly8gQ3JlYXRlIGEgbmV3IG1vZHVsZSAoYW5kIHB1dCBpdCBpbnRvIHRoZSBjYWNoZSlcbiBcdFx0dmFyIG1vZHVsZSA9IGluc3RhbGxlZE1vZHVsZXNbbW9kdWxlSWRdID0ge1xuIFx0XHRcdGk6IG1vZHVsZUlkLFxuIFx0XHRcdGw6IGZhbHNlLFxuIFx0XHRcdGV4cG9ydHM6IHt9XG4gXHRcdH07XG5cbiBcdFx0Ly8gRXhlY3V0ZSB0aGUgbW9kdWxlIGZ1bmN0aW9uXG4gXHRcdG1vZHVsZXNbbW9kdWxlSWRdLmNhbGwobW9kdWxlLmV4cG9ydHMsIG1vZHVsZSwgbW9kdWxlLmV4cG9ydHMsIF9fd2VicGFja19yZXF1aXJlX18pO1xuXG4gXHRcdC8vIEZsYWcgdGhlIG1vZHVsZSBhcyBsb2FkZWRcbiBcdFx0bW9kdWxlLmwgPSB0cnVlO1xuXG4gXHRcdC8vIFJldHVybiB0aGUgZXhwb3J0cyBvZiB0aGUgbW9kdWxlXG4gXHRcdHJldHVybiBtb2R1bGUuZXhwb3J0cztcbiBcdH1cblxuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZXMgb2JqZWN0IChfX3dlYnBhY2tfbW9kdWxlc19fKVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5tID0gbW9kdWxlcztcblxuIFx0Ly8gZXhwb3NlIHRoZSBtb2R1bGUgY2FjaGVcbiBcdF9fd2VicGFja19yZXF1aXJlX18uYyA9IGluc3RhbGxlZE1vZHVsZXM7XG5cbiBcdC8vIGRlZmluZSBnZXR0ZXIgZnVuY3Rpb24gZm9yIGhhcm1vbnkgZXhwb3J0c1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5kID0gZnVuY3Rpb24oZXhwb3J0cywgbmFtZSwgZ2V0dGVyKSB7XG4gXHRcdGlmKCFfX3dlYnBhY2tfcmVxdWlyZV9fLm8oZXhwb3J0cywgbmFtZSkpIHtcbiBcdFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgbmFtZSwgeyBlbnVtZXJhYmxlOiB0cnVlLCBnZXQ6IGdldHRlciB9KTtcbiBcdFx0fVxuIFx0fTtcblxuIFx0Ly8gZGVmaW5lIF9fZXNNb2R1bGUgb24gZXhwb3J0c1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5yID0gZnVuY3Rpb24oZXhwb3J0cykge1xuIFx0XHRpZih0eXBlb2YgU3ltYm9sICE9PSAndW5kZWZpbmVkJyAmJiBTeW1ib2wudG9TdHJpbmdUYWcpIHtcbiBcdFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgU3ltYm9sLnRvU3RyaW5nVGFnLCB7IHZhbHVlOiAnTW9kdWxlJyB9KTtcbiBcdFx0fVxuIFx0XHRPYmplY3QuZGVmaW5lUHJvcGVydHkoZXhwb3J0cywgJ19fZXNNb2R1bGUnLCB7IHZhbHVlOiB0cnVlIH0pO1xuIFx0fTtcblxuIFx0Ly8gY3JlYXRlIGEgZmFrZSBuYW1lc3BhY2Ugb2JqZWN0XG4gXHQvLyBtb2RlICYgMTogdmFsdWUgaXMgYSBtb2R1bGUgaWQsIHJlcXVpcmUgaXRcbiBcdC8vIG1vZGUgJiAyOiBtZXJnZSBhbGwgcHJvcGVydGllcyBvZiB2YWx1ZSBpbnRvIHRoZSBuc1xuIFx0Ly8gbW9kZSAmIDQ6IHJldHVybiB2YWx1ZSB3aGVuIGFscmVhZHkgbnMgb2JqZWN0XG4gXHQvLyBtb2RlICYgOHwxOiBiZWhhdmUgbGlrZSByZXF1aXJlXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnQgPSBmdW5jdGlvbih2YWx1ZSwgbW9kZSkge1xuIFx0XHRpZihtb2RlICYgMSkgdmFsdWUgPSBfX3dlYnBhY2tfcmVxdWlyZV9fKHZhbHVlKTtcbiBcdFx0aWYobW9kZSAmIDgpIHJldHVybiB2YWx1ZTtcbiBcdFx0aWYoKG1vZGUgJiA0KSAmJiB0eXBlb2YgdmFsdWUgPT09ICdvYmplY3QnICYmIHZhbHVlICYmIHZhbHVlLl9fZXNNb2R1bGUpIHJldHVybiB2YWx1ZTtcbiBcdFx0dmFyIG5zID0gT2JqZWN0LmNyZWF0ZShudWxsKTtcbiBcdFx0X193ZWJwYWNrX3JlcXVpcmVfXy5yKG5zKTtcbiBcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KG5zLCAnZGVmYXVsdCcsIHsgZW51bWVyYWJsZTogdHJ1ZSwgdmFsdWU6IHZhbHVlIH0pO1xuIFx0XHRpZihtb2RlICYgMiAmJiB0eXBlb2YgdmFsdWUgIT0gJ3N0cmluZycpIGZvcih2YXIga2V5IGluIHZhbHVlKSBfX3dlYnBhY2tfcmVxdWlyZV9fLmQobnMsIGtleSwgZnVuY3Rpb24oa2V5KSB7IHJldHVybiB2YWx1ZVtrZXldOyB9LmJpbmQobnVsbCwga2V5KSk7XG4gXHRcdHJldHVybiBucztcbiBcdH07XG5cbiBcdC8vIGdldERlZmF1bHRFeHBvcnQgZnVuY3Rpb24gZm9yIGNvbXBhdGliaWxpdHkgd2l0aCBub24taGFybW9ueSBtb2R1bGVzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm4gPSBmdW5jdGlvbihtb2R1bGUpIHtcbiBcdFx0dmFyIGdldHRlciA9IG1vZHVsZSAmJiBtb2R1bGUuX19lc01vZHVsZSA/XG4gXHRcdFx0ZnVuY3Rpb24gZ2V0RGVmYXVsdCgpIHsgcmV0dXJuIG1vZHVsZVsnZGVmYXVsdCddOyB9IDpcbiBcdFx0XHRmdW5jdGlvbiBnZXRNb2R1bGVFeHBvcnRzKCkgeyByZXR1cm4gbW9kdWxlOyB9O1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQoZ2V0dGVyLCAnYScsIGdldHRlcik7XG4gXHRcdHJldHVybiBnZXR0ZXI7XG4gXHR9O1xuXG4gXHQvLyBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGxcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubyA9IGZ1bmN0aW9uKG9iamVjdCwgcHJvcGVydHkpIHsgcmV0dXJuIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmplY3QsIHByb3BlcnR5KTsgfTtcblxuIFx0Ly8gX193ZWJwYWNrX3B1YmxpY19wYXRoX19cbiBcdF9fd2VicGFja19yZXF1aXJlX18ucCA9IFwiXCI7XG5cblxuIFx0Ly8gTG9hZCBlbnRyeSBtb2R1bGUgYW5kIHJldHVybiBleHBvcnRzXG4gXHRyZXR1cm4gX193ZWJwYWNrX3JlcXVpcmVfXyhfX3dlYnBhY2tfcmVxdWlyZV9fLnMgPSBcIi4vc3JjL3NjcmlwdHMvbWlycm9yYmxvY2svdHdlZXRkZWNrLnRzXCIpO1xuIiwiY29uc3QgZGVmYXVsdHMgPSBPYmplY3QuZnJlZXplPE1pcnJvckJsb2NrT3B0aW9uPih7XG4gIG91dGxpbmVCbG9ja1VzZXI6IGZhbHNlLFxuICBlbmFibGVCbG9ja1JlZmxlY3Rpb246IGZhbHNlLFxuICBibG9ja011dGVkVXNlcjogZmFsc2UsXG4gIGFsd2F5c0ltbWVkaWF0ZWx5QmxvY2tNb2RlOiBmYWxzZSxcbn0pXG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBzYXZlKG5ld09wdGlvbjogTWlycm9yQmxvY2tPcHRpb24pIHtcbiAgY29uc3Qgb3B0aW9uID0gT2JqZWN0LmFzc2lnbjxcbiAgICBvYmplY3QsXG4gICAgTWlycm9yQmxvY2tPcHRpb24sXG4gICAgUGFydGlhbDxNaXJyb3JCbG9ja09wdGlvbj5cbiAgPih7fSwgZGVmYXVsdHMsIG5ld09wdGlvbilcbiAgcmV0dXJuIGJyb3dzZXIuc3RvcmFnZS5sb2NhbC5zZXQoe1xuICAgIG9wdGlvbixcbiAgfSBhcyBhbnkpXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBsb2FkKCk6IFByb21pc2U8TWlycm9yQmxvY2tPcHRpb24+IHtcbiAgY29uc3QgbG9hZGVkID0gYXdhaXQgYnJvd3Nlci5zdG9yYWdlLmxvY2FsLmdldCgnb3B0aW9uJylcbiAgcmV0dXJuIE9iamVjdC5hc3NpZ248b2JqZWN0LCBNaXJyb3JCbG9ja09wdGlvbiwgYW55PihcbiAgICB7fSxcbiAgICBkZWZhdWx0cyxcbiAgICBsb2FkZWQub3B0aW9uXG4gIClcbn1cbiIsImV4cG9ydCBjb25zdCBlbnVtIEFjdGlvbiB7XG4gIFN0YXJ0Q2hhaW5CbG9jayA9ICdNaXJyb3JCbG9jay9TdGFydCcsXG4gIFN0b3BDaGFpbkJsb2NrID0gJ01pcnJvckJsb2NrL1N0b3AnLFxuICBBbGVydCA9ICdNaXJyb3JCbG9jay9BbGVydCcsXG59XG5cbmNvbnN0IFVTRVJfTkFNRV9CTEFDS0xJU1QgPSBPYmplY3QuZnJlZXplKFtcbiAgJzEnLFxuICAnYWJvdXQnLFxuICAnYWNjb3VudCcsXG4gICdmb2xsb3dlcnMnLFxuICAnZm9sbG93aW5ncycsXG4gICdoYXNodGFnJyxcbiAgJ2hvbWUnLFxuICAnaScsXG4gICdsaXN0cycsXG4gICdsb2dpbicsXG4gICdvYXV0aCcsXG4gICdwcml2YWN5JyxcbiAgJ3NlYXJjaCcsXG4gICd0b3MnLFxuICAnbm90aWZpY2F0aW9ucycsXG4gICdtZXNzYWdlcycsXG4gICdleHBsb3JlJyxcbl0pXG5cbmV4cG9ydCBjbGFzcyBUd2l0dGVyVXNlck1hcCBleHRlbmRzIE1hcDxzdHJpbmcsIFR3aXR0ZXJVc2VyPiB7XG4gIHB1YmxpYyBhZGRVc2VyKHVzZXI6IFR3aXR0ZXJVc2VyKSB7XG4gICAgdGhpcy5zZXQodXNlci5pZF9zdHIsIHVzZXIpXG4gIH1cbiAgcHVibGljIGhhc1VzZXIodXNlcjogVHdpdHRlclVzZXIpIHtcbiAgICByZXR1cm4gdGhpcy5oYXModXNlci5pZF9zdHIpXG4gIH1cbiAgcHVibGljIHRvVXNlckFycmF5KCk6IFR3aXR0ZXJVc2VyW10ge1xuICAgIHJldHVybiBBcnJheS5mcm9tKHRoaXMudmFsdWVzKCkpXG4gIH1cbiAgcHVibGljIHRvVXNlck9iamVjdCgpOiBUd2l0dGVyVXNlckVudGl0aWVzIHtcbiAgICBjb25zdCB1c2Vyc09iajogVHdpdHRlclVzZXJFbnRpdGllcyA9IE9iamVjdC5jcmVhdGUobnVsbClcbiAgICBmb3IgKGNvbnN0IFt1c2VySWQsIHVzZXJdIG9mIHRoaXMpIHtcbiAgICAgIHVzZXJzT2JqW3VzZXJJZF0gPSB1c2VyXG4gICAgfVxuICAgIHJldHVybiB1c2Vyc09ialxuICB9XG4gIHB1YmxpYyBzdGF0aWMgZnJvbVVzZXJzQXJyYXkodXNlcnM6IFR3aXR0ZXJVc2VyW10pOiBUd2l0dGVyVXNlck1hcCB7XG4gICAgcmV0dXJuIG5ldyBUd2l0dGVyVXNlck1hcCh1c2Vycy5tYXAoKHVzZXIpOiBbc3RyaW5nLCBUd2l0dGVyVXNlcl0gPT4gW3VzZXIuaWRfc3RyLCB1c2VyXSkpXG4gIH1cbiAgcHVibGljIGZpbHRlcihmbjogKHVzZXI6IFR3aXR0ZXJVc2VyKSA9PiBib29sZWFuKTogVHdpdHRlclVzZXJNYXAge1xuICAgIHJldHVybiBUd2l0dGVyVXNlck1hcC5mcm9tVXNlcnNBcnJheSh0aGlzLnRvVXNlckFycmF5KCkuZmlsdGVyKGZuKSlcbiAgfVxufVxuXG5leHBvcnQgYWJzdHJhY3QgY2xhc3MgRXZlbnRFbWl0dGVyIHtcbiAgcHJvdGVjdGVkIGV2ZW50czogRXZlbnRTdG9yZSA9IHt9XG4gIG9uPFQ+KGV2ZW50TmFtZTogc3RyaW5nLCBoYW5kbGVyOiAodDogVCkgPT4gYW55KSB7XG4gICAgaWYgKCEoZXZlbnROYW1lIGluIHRoaXMuZXZlbnRzKSkge1xuICAgICAgdGhpcy5ldmVudHNbZXZlbnROYW1lXSA9IFtdXG4gICAgfVxuICAgIHRoaXMuZXZlbnRzW2V2ZW50TmFtZV0ucHVzaChoYW5kbGVyKVxuICAgIHJldHVybiB0aGlzXG4gIH1cbiAgZW1pdDxUPihldmVudE5hbWU6IHN0cmluZywgZXZlbnRIYW5kbGVyUGFyYW1ldGVyPzogVCkge1xuICAgIGNvbnN0IGhhbmRsZXJzID0gdGhpcy5ldmVudHNbZXZlbnROYW1lXSB8fCBbXVxuICAgIGhhbmRsZXJzLmZvckVhY2goaGFuZGxlciA9PiBoYW5kbGVyKGV2ZW50SGFuZGxlclBhcmFtZXRlcikpXG4gICAgcmV0dXJuIHRoaXNcbiAgfVxufVxuXG5leHBvcnQgZnVuY3Rpb24gc2xlZXAodGltZTogbnVtYmVyKTogUHJvbWlzZTx2b2lkPiB7XG4gIHJldHVybiBuZXcgUHJvbWlzZShyZXNvbHZlID0+IHdpbmRvdy5zZXRUaW1lb3V0KHJlc29sdmUsIHRpbWUpKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gaW5qZWN0U2NyaXB0KHBhdGg6IHN0cmluZyk6IFByb21pc2U8dm9pZD4ge1xuICByZXR1cm4gbmV3IFByb21pc2UocmVzb2x2ZSA9PiB7XG4gICAgY29uc3Qgc2NyaXB0ID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnc2NyaXB0JylcbiAgICBzY3JpcHQuYWRkRXZlbnRMaXN0ZW5lcignbG9hZCcsICgpID0+IHtcbiAgICAgIHNjcmlwdC5yZW1vdmUoKVxuICAgICAgcmVzb2x2ZSgpXG4gICAgfSlcbiAgICBzY3JpcHQuc3JjID0gYnJvd3Nlci5ydW50aW1lLmdldFVSTChwYXRoKVxuICAgIGNvbnN0IGFwcGVuZFRhcmdldCA9IGRvY3VtZW50LmhlYWQgfHwgZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50XG4gICAgYXBwZW5kVGFyZ2V0IS5hcHBlbmRDaGlsZChzY3JpcHQpXG4gIH0pXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBjb3B5RnJvemVuT2JqZWN0PFQgZXh0ZW5kcyBvYmplY3Q+KG9iajogVCk6IFJlYWRvbmx5PFQ+IHtcbiAgcmV0dXJuIE9iamVjdC5mcmVlemUoT2JqZWN0LmFzc2lnbih7fSwgb2JqKSlcbn1cblxuZXhwb3J0IGZ1bmN0aW9uKiBnZXRBZGRlZEVsZW1lbnRzRnJvbU11dGF0aW9ucyhcbiAgbXV0YXRpb25zOiBNdXRhdGlvblJlY29yZFtdXG4pOiBJdGVyYWJsZUl0ZXJhdG9yPEhUTUxFbGVtZW50PiB7XG4gIGZvciAoY29uc3QgbXV0IG9mIG11dGF0aW9ucykge1xuICAgIGZvciAoY29uc3Qgbm9kZSBvZiBtdXQuYWRkZWROb2Rlcykge1xuICAgICAgaWYgKG5vZGUgaW5zdGFuY2VvZiBIVE1MRWxlbWVudCkge1xuICAgICAgICB5aWVsZCBub2RlXG4gICAgICB9XG4gICAgfVxuICB9XG59XG5cbmNvbnN0IHRvdWNoZWRFbGVtcyA9IG5ldyBXZWFrU2V0PEhUTUxFbGVtZW50PigpXG5leHBvcnQgZnVuY3Rpb24qIGl0ZXJhdGVVbnRvdWNoZWRFbGVtczxUIGV4dGVuZHMgSFRNTEVsZW1lbnQ+KGVsZW1zOiBJdGVyYWJsZTxUPiB8IEFycmF5TGlrZTxUPikge1xuICBmb3IgKGNvbnN0IGVsZW0gb2YgQXJyYXkuZnJvbShlbGVtcykpIHtcbiAgICBpZiAoIXRvdWNoZWRFbGVtcy5oYXMoZWxlbSkpIHtcbiAgICAgIHRvdWNoZWRFbGVtcy5hZGQoZWxlbSlcbiAgICAgIHlpZWxkIGVsZW1cbiAgICB9XG4gIH1cbn1cblxuLy8gbmFpdmUgY2hlY2sgZ2l2ZW4gb2JqZWN0IGlzIFR3aXR0ZXJVc2VyXG5leHBvcnQgZnVuY3Rpb24gaXNUd2l0dGVyVXNlcihvYmo6IHVua25vd24pOiBvYmogaXMgVHdpdHRlclVzZXIge1xuICBpZiAoIShvYmogJiYgdHlwZW9mIG9iaiA9PT0gJ29iamVjdCcpKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgY29uc3Qgb2JqQXNBbnkgPSBvYmogYXMgYW55XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuaWRfc3RyICE9PSAnc3RyaW5nJykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuc2NyZWVuX25hbWUgIT09ICdzdHJpbmcnKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5ibG9ja2luZyAhPT0gJ2Jvb2xlYW4nKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5ibG9ja2VkX2J5ICE9PSAnYm9vbGVhbicpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICByZXR1cm4gdHJ1ZVxufVxuXG5leHBvcnQgZnVuY3Rpb24gaXNJbk5hbWVCbGFja2xpc3QobmFtZTogc3RyaW5nKTogYm9vbGVhbiB7XG4gIGNvbnN0IGxvd2VyQ2FzZWROYW1lID0gbmFtZS50b0xvd2VyQ2FzZSgpXG4gIHJldHVybiBVU0VSX05BTUVfQkxBQ0tMSVNULmluY2x1ZGVzKGxvd2VyQ2FzZWROYW1lKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gdmFsaWRhdGVUd2l0dGVyVXNlck5hbWUodXNlck5hbWU6IHN0cmluZyk6IGJvb2xlYW4ge1xuICBpZiAoaXNJbk5hbWVCbGFja2xpc3QodXNlck5hbWUpKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgY29uc3QgcGF0dGVybiA9IC9eWzAtOWEtel9dezEsMTV9JC9pXG4gIHJldHVybiBwYXR0ZXJuLnRlc3QodXNlck5hbWUpXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBnZXRVc2VyTmFtZUZyb21Ud2VldFVybChcbiAgZXh0cmFjdE1lOiBIVE1MQW5jaG9yRWxlbWVudCB8IFVSTCB8IExvY2F0aW9uXG4pOiBzdHJpbmcgfCBudWxsIHtcbiAgY29uc3QgeyBob3N0bmFtZSwgcGF0aG5hbWUgfSA9IGV4dHJhY3RNZVxuICBjb25zdCBzdXBwb3J0aW5nSG9zdG5hbWUgPSBbJ3R3aXR0ZXIuY29tJywgJ21vYmlsZS50d2l0dGVyLmNvbSddXG4gIGlmICghc3VwcG9ydGluZ0hvc3RuYW1lLmluY2x1ZGVzKGhvc3RuYW1lKSkge1xuICAgIHJldHVybiBudWxsXG4gIH1cbiAgY29uc3QgbWF0Y2hlcyA9IC9eXFwvKFswLTlhLXpfXXsxLDE1fSkvaS5leGVjKHBhdGhuYW1lKVxuICBpZiAoIW1hdGNoZXMpIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG4gIGNvbnN0IG5hbWUgPSBtYXRjaGVzWzFdXG4gIGlmICh2YWxpZGF0ZVR3aXR0ZXJVc2VyTmFtZShuYW1lKSkge1xuICAgIHJldHVybiBuYW1lXG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxufVxuIiwiaW1wb3J0ICogYXMgT3B0aW9ucyBmcm9tICfrr7jrn6zruJTrnb0vZXh0b3B0aW9uJ1xuaW1wb3J0IHsgaW5qZWN0U2NyaXB0LCBnZXRBZGRlZEVsZW1lbnRzRnJvbU11dGF0aW9ucyB9IGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL2NvbW1vbidcbmltcG9ydCAqIGFzIFR3aXR0ZXJBUEkgZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvdHdpdHRlci1hcGknXG5cbnR5cGUgVERVc2VyRGF0YVNldCA9IERPTVN0cmluZ01hcCAmIHsgW2kgaW4ga2V5b2YgVERVc2VyRGF0YV06IHN0cmluZyB9XG5cbmludGVyZmFjZSBURFVzZXJEYXRhIHtcbiAgdGVtcGxhdGU6IHN0cmluZ1xuICBpZDogc3RyaW5nXG4gIG5hbWU6IHN0cmluZ1xuICBzY3JlZW5OYW1lOiBzdHJpbmdcbiAgYmxvY2tpbmc6IGJvb2xlYW5cbiAgYmxvY2tlZEJ5OiBib29sZWFuXG4gIG11dGluZzogYm9vbGVhblxuICBmb2xsb3dpbmc6IGJvb2xlYW5cbiAgZm9sbG93ZWRCeTogYm9vbGVhblxufVxuXG5mdW5jdGlvbiBleHRyYWN0VXNlckRhdGEodXNlckRhdGFFbGVtOiBIVE1MRWxlbWVudCk6IFREVXNlckRhdGEge1xuICBjb25zdCBkYXRhc2V0ID0gdXNlckRhdGFFbGVtLmRhdGFzZXQgYXMgVERVc2VyRGF0YVNldFxuICBjb25zdCB0b0Jvb2xlYW4gPSAoc3RyOiBzdHJpbmcpID0+IHN0ciA9PT0gJ3RydWUnXG4gIGNvbnN0IHJlc3VsdDogVERVc2VyRGF0YSA9IHtcbiAgICB0ZW1wbGF0ZTogZGF0YXNldC50ZW1wbGF0ZSxcbiAgICBpZDogZGF0YXNldC5pZCxcbiAgICBuYW1lOiBkYXRhc2V0Lm5hbWUsXG4gICAgc2NyZWVuTmFtZTogZGF0YXNldC5zY3JlZW5OYW1lLFxuICAgIGJsb2NraW5nOiB0b0Jvb2xlYW4oZGF0YXNldC5ibG9ja2luZyksXG4gICAgYmxvY2tlZEJ5OiB0b0Jvb2xlYW4oZGF0YXNldC5ibG9ja2VkQnkpLFxuICAgIG11dGluZzogdG9Cb29sZWFuKGRhdGFzZXQubXV0aW5nKSxcbiAgICBmb2xsb3dpbmc6IHRvQm9vbGVhbihkYXRhc2V0LmZvbGxvd2luZyksXG4gICAgZm9sbG93ZWRCeTogdG9Cb29sZWFuKGRhdGFzZXQuZm9sbG93ZWRCeSksXG4gIH1cbiAgcmV0dXJuIHJlc3VsdFxufVxuXG5mdW5jdGlvbiBnZXRNeU5hbWUoKTogc3RyaW5nIHtcbiAgbGV0IG15TmFtZSA9IGRvY3VtZW50LmJvZHkuZ2V0QXR0cmlidXRlKCdkYXRhLWRlZmF1bHQtYWNjb3VudC11c2VybmFtZScpXG4gIG15TmFtZSA9IG15TmFtZSA/ICdAJyArIG15TmFtZSA6ICdZb3UnXG4gIHJldHVybiBteU5hbWVcbn1cblxuZnVuY3Rpb24gbWFrZUJsb2NrZWRCYWRnZSgpOiBIVE1MRWxlbWVudCB7XG4gIGNvbnN0IG15TmFtZSA9IGdldE15TmFtZSgpXG4gIGNvbnN0IGJhZGdlID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnc3BhbicpXG4gIGJhZGdlLmNsYXNzTmFtZSA9ICdtb2ItQmxvY2tTdGF0dXMnXG4gIGJhZGdlLnRleHRDb250ZW50ID0gYEJsb2NrcyAke215TmFtZX1gXG4gIHJldHVybiBiYWRnZVxufVxuXG5mdW5jdGlvbiBtYWtlQmxvY2tSZWZsZWN0ZWRCYWRnZSgpOiBIVE1MRWxlbWVudCB7XG4gIGNvbnN0IGJhZGdlID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnc3BhbicpXG4gIGJhZGdlLmNsYXNzTmFtZSA9ICdtb2ItQmxvY2tSZWZsZWN0ZWRTdGF0dXMnXG4gIGJhZGdlLnRleHRDb250ZW50ID0gYEJsb2NrIFJlZmxlY3RlZCFgXG4gIHJldHVybiBiYWRnZVxufVxuXG5mdW5jdGlvbiBjaGFuZ2VGb2xsb3dCdXR0b25Ub0Jsb2NrZWQoZWxlbTogRWxlbWVudCkge1xuICBjb25zdCBidG4gPSBlbGVtLnF1ZXJ5U2VsZWN0b3IoJy5wcmYtYWN0aW9ucyAuanMtYWN0aW9uLWZvbGxvdycpXG4gIGlmICghYnRuKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgYnRuLmNsYXNzTGlzdC5yZW1vdmUoJ3Mtbm90LWZvbGxvd2luZycpXG4gIGJ0bi5jbGFzc0xpc3QuYWRkKCdzLWJsb2NraW5nJylcbn1cblxuZnVuY3Rpb24gZmluZEJhZGdlVGFyZ2V0KGVsZW06IEhUTUxFbGVtZW50KTogSFRNTEVsZW1lbnQgfCBudWxsIHtcbiAgbGV0IHJlc3VsdDogSFRNTEVsZW1lbnQgfCBudWxsXG4gIGNvbnN0IHByb2ZpbGVFbGVtID0gZWxlbS5jbG9zZXN0KCcucy1wcm9maWxlLnByZicpXG4gIGlmIChwcm9maWxlRWxlbSkge1xuICAgIHJlc3VsdCA9IHByb2ZpbGVFbGVtLnF1ZXJ5U2VsZWN0b3IoJy5wcmYtaGVhZGVyIHAudXNlcm5hbWUnKVxuICAgIGlmIChyZXN1bHQpIHtcbiAgICAgIHJldHVybiByZXN1bHRcbiAgICB9XG4gIH1cbiAgY29uc3QgcHJldmlvdXNFbGVtZW50ID0gZWxlbS5wcmV2aW91c0VsZW1lbnRTaWJsaW5nIGFzIEhUTUxFbGVtZW50IHwgbnVsbFxuICBpZiAocHJldmlvdXNFbGVtZW50KSB7XG4gICAgaWYgKHByZXZpb3VzRWxlbWVudC5jbGFzc0xpc3QuY29udGFpbnMoJ2FjY291bnQtc3VtbWFyeScpKSB7XG4gICAgICBjb25zdCBhY2NFbGVtID0gcHJldmlvdXNFbGVtZW50XG4gICAgICByZXN1bHQgPSBhY2NFbGVtLnF1ZXJ5U2VsZWN0b3IoJy51c2VybmFtZScpXG4gICAgICBpZiAocmVzdWx0KSB7XG4gICAgICAgIHJldHVybiByZXN1bHRcbiAgICAgIH1cbiAgICB9XG4gIH1cbiAgcmV0dXJuIG51bGxcbn1cblxuYXN5bmMgZnVuY3Rpb24gdXNlckRhdGFIYW5kbGVyKHVzZXJEYXRhRWxlbTogSFRNTEVsZW1lbnQpIHtcbiAgaWYgKHVzZXJEYXRhRWxlbS5jbGFzc0xpc3QuY29udGFpbnMoJ21vYi1jaGVja2VkJykpIHtcbiAgICByZXR1cm5cbiAgfVxuICB1c2VyRGF0YUVsZW0uY2xhc3NMaXN0LmFkZCgnbW9iLWNoZWNrZWQnKVxuICBjb25zdCB1c2VyRGF0YSA9IGV4dHJhY3RVc2VyRGF0YSh1c2VyRGF0YUVsZW0pXG4gIGlmICghdXNlckRhdGEuYmxvY2tlZEJ5KSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgbGV0IGJhZGdlVGFyZ2V0ID0gZmluZEJhZGdlVGFyZ2V0KHVzZXJEYXRhRWxlbSlcbiAgaWYgKCFiYWRnZVRhcmdldCkge1xuICAgIHJldHVyblxuICB9XG4gIGNvbnN0IG9wdGlvbnMgPSBhd2FpdCBPcHRpb25zLmxvYWQoKVxuICBjb25zdCBiYWRnZSA9IG1ha2VCbG9ja2VkQmFkZ2UoKVxuICBiYWRnZVRhcmdldC5hcHBlbmRDaGlsZChiYWRnZSlcbiAgY29uc3QgbXV0ZVNraXAgPSB1c2VyRGF0YS5tdXRpbmcgJiYgIW9wdGlvbnMuYmxvY2tNdXRlZFVzZXJcbiAgY29uc3Qgc2hvdWxkQmxvY2sgPSBvcHRpb25zLmVuYWJsZUJsb2NrUmVmbGVjdGlvbiAmJiAhdXNlckRhdGEuYmxvY2tpbmcgJiYgIW11dGVTa2lwXG4gIGlmIChzaG91bGRCbG9jaykge1xuICAgIFR3aXR0ZXJBUEkuYmxvY2tVc2VyQnlJZCh1c2VyRGF0YS5pZCkudGhlbihyZXN1bHQgPT4ge1xuICAgICAgaWYgKHJlc3VsdCkge1xuICAgICAgICBjb25zdCBwcm9maWxlRWxlbSA9IHVzZXJEYXRhRWxlbS5jbG9zZXN0KCcucy1wcm9maWxlLnByZicpXG4gICAgICAgIGlmIChwcm9maWxlRWxlbSkge1xuICAgICAgICAgIGNoYW5nZUZvbGxvd0J1dHRvblRvQmxvY2tlZChwcm9maWxlRWxlbSlcbiAgICAgICAgfVxuICAgICAgICBjb25zdCByZWZsZWN0ZWRCYWRnZSA9IG1ha2VCbG9ja1JlZmxlY3RlZEJhZGdlKClcbiAgICAgICAgYmFkZ2VUYXJnZXQhLmFwcGVuZENoaWxkKHJlZmxlY3RlZEJhZGdlKVxuICAgICAgfVxuICAgIH0pXG4gIH1cbn1cblxuZnVuY3Rpb24gbWFpbigpIHtcbiAgaW5qZWN0U2NyaXB0KCdidW5kbGVkL3R3ZWV0ZGVja19pbmplY3QuYnVuLmpzJylcbiAgY29uc3Qgb2JzZXJ2ZXIgPSBuZXcgTXV0YXRpb25PYnNlcnZlcihtdXRhdGlvbnMgPT4ge1xuICAgIGZvciAoY29uc3QgZWxlbSBvZiBnZXRBZGRlZEVsZW1lbnRzRnJvbU11dGF0aW9ucyhtdXRhdGlvbnMpKSB7XG4gICAgICBjb25zdCBlbGVtZW50c1RvSGFuZGxlID0gWy4uLmVsZW0ucXVlcnlTZWxlY3RvckFsbDxIVE1MRWxlbWVudD4oJ3NwYW4ubW9iLXVzZXItZGF0YScpXVxuICAgICAgaWYgKGVsZW0ubWF0Y2hlcygnc3Bhbi5tb2ItdXNlci1kYXRhJykpIHtcbiAgICAgICAgZWxlbWVudHNUb0hhbmRsZS5wdXNoKGVsZW0pXG4gICAgICB9XG4gICAgICBlbGVtZW50c1RvSGFuZGxlLmZvckVhY2godXNlckRhdGFIYW5kbGVyKVxuICAgIH1cbiAgfSlcbiAgb2JzZXJ2ZXIub2JzZXJ2ZShkb2N1bWVudC5ib2R5LCB7XG4gICAgc3VidHJlZTogdHJ1ZSxcbiAgICBjaGlsZExpc3Q6IHRydWUsXG4gIH0pXG59XG5cbm1haW4oKVxuIiwiaW1wb3J0IHsgdmFsaWRhdGVUd2l0dGVyVXNlck5hbWUsIHNsZWVwIH0gZnJvbSAnLi9jb21tb24nXG5cbmNvbnN0IEJFQVJFUl9UT0tFTiA9IGBBQUFBQUFBQUFBQUFBQUFBQUFBQUFOUklMZ0FBQUFBQW5Od0l6VWVqUkNPdUg1RTZJOHhuWno0cHVUcyUzRDFadjd0dGZrOExGODFJVXExNmNIamhMVHZKdTRGQTMzQUdXV2pDcFRuQWBcblxuLy8gQ09SQiog66GcIOyduO2VtCBjb250ZW50IHNjcmlwdHPsl5DshJwgYXBpLnR3aXR0ZXIuY29tIOydhCDsgqzsmqntlaAg7IiYIOyXhuuLpC5cbi8vIGh0dHBzOi8vd3d3LmNocm9tZXN0YXR1cy5jb20vZmVhdHVyZS81NjI5NzA5ODI0MDMyNzY4XG4vLyBodHRwczovL3d3dy5jaHJvbWl1bS5vcmcvSG9tZS9jaHJvbWl1bS1zZWN1cml0eS9jb3JiLWZvci1kZXZlbG9wZXJzXG5sZXQgYXBpUHJlZml4ID0gJ2h0dHBzOi8vdHdpdHRlci5jb20vaS9hcGkvMS4xJ1xuaWYgKGxvY2F0aW9uLmhvc3RuYW1lID09PSAnbW9iaWxlLnR3aXR0ZXIuY29tJykge1xuICBhcGlQcmVmaXggPSAnaHR0cHM6Ly9tb2JpbGUudHdpdHRlci5jb20vaS9hcGkvMS4xJ1xufVxuXG5leHBvcnQgY2xhc3MgQVBJRXJyb3IgZXh0ZW5kcyBFcnJvciB7XG4gIGNvbnN0cnVjdG9yKHB1YmxpYyByZWFkb25seSByZXNwb25zZTogQVBJUmVzcG9uc2UpIHtcbiAgICBzdXBlcignQVBJIEVycm9yIScpXG4gICAgLy8gZnJvbTogaHR0cHM6Ly93d3cudHlwZXNjcmlwdGxhbmcub3JnL2RvY3MvaGFuZGJvb2svcmVsZWFzZS1ub3Rlcy90eXBlc2NyaXB0LTItMi5odG1sI3N1cHBvcnQtZm9yLW5ld3RhcmdldFxuICAgIE9iamVjdC5zZXRQcm90b3R5cGVPZih0aGlzLCBuZXcudGFyZ2V0LnByb3RvdHlwZSlcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gYmxvY2tVc2VyKHVzZXI6IFR3aXR0ZXJVc2VyKTogUHJvbWlzZTxib29sZWFuPiB7XG4gIGlmICh1c2VyLmJsb2NraW5nKSB7XG4gICAgcmV0dXJuIHRydWVcbiAgfVxuICBjb25zdCBzaG91bGROb3RCbG9jayA9XG4gICAgdXNlci5mb2xsb3dpbmcgfHwgdXNlci5mb2xsb3dlZF9ieSB8fCB1c2VyLmZvbGxvd19yZXF1ZXN0X3NlbnQgfHwgIXVzZXIuYmxvY2tlZF9ieVxuICBpZiAoc2hvdWxkTm90QmxvY2spIHtcbiAgICBjb25zdCBmYXRhbEVycm9yTWVzc2FnZSA9IGAhISEhIUZBVEFMISEhISE6XG5hdHRlbXB0ZWQgdG8gYmxvY2sgdXNlciB0aGF0IHNob3VsZCBOT1QgYmxvY2shIVxuKHVzZXI6ICR7dXNlci5zY3JlZW5fbmFtZX0pYFxuICAgIHRocm93IG5ldyBFcnJvcihmYXRhbEVycm9yTWVzc2FnZSlcbiAgfVxuICByZXR1cm4gYmxvY2tVc2VyQnlJZCh1c2VyLmlkX3N0cilcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGJsb2NrVXNlckJ5SWQodXNlcklkOiBzdHJpbmcpOiBQcm9taXNlPGJvb2xlYW4+IHtcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgncG9zdCcsICcvYmxvY2tzL2NyZWF0ZS5qc29uJywge1xuICAgIHVzZXJfaWQ6IHVzZXJJZCxcbiAgICBpbmNsdWRlX2VudGl0aWVzOiBmYWxzZSxcbiAgICBza2lwX3N0YXR1czogdHJ1ZSxcbiAgfSlcbiAgcmV0dXJuIHJlc3BvbnNlLm9rXG59XG5cbmFzeW5jIGZ1bmN0aW9uIGdldEZvbGxvd2luZ3NMaXN0KFxuICB1c2VyOiBUd2l0dGVyVXNlcixcbiAgY3Vyc29yOiBzdHJpbmcgPSAnLTEnXG4pOiBQcm9taXNlPEZvbGxvd3NMaXN0UmVzcG9uc2U+IHtcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy9mcmllbmRzL2xpc3QuanNvbicsIHtcbiAgICB1c2VyX2lkOiB1c2VyLmlkX3N0cixcbiAgICBjb3VudDogMjAwLFxuICAgIHNraXBfc3RhdHVzOiB0cnVlLFxuICAgIGluY2x1ZGVfdXNlcl9lbnRpdGllczogZmFsc2UsXG4gICAgY3Vyc29yLFxuICB9KVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICByZXR1cm4gcmVzcG9uc2UuYm9keSBhcyBGb2xsb3dzTGlzdFJlc3BvbnNlXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEFQSUVycm9yKHJlc3BvbnNlKVxuICB9XG59XG5hc3luYyBmdW5jdGlvbiBnZXRGb2xsb3dlcnNMaXN0KFxuICB1c2VyOiBUd2l0dGVyVXNlcixcbiAgY3Vyc29yOiBzdHJpbmcgPSAnLTEnXG4pOiBQcm9taXNlPEZvbGxvd3NMaXN0UmVzcG9uc2U+IHtcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy9mb2xsb3dlcnMvbGlzdC5qc29uJywge1xuICAgIHVzZXJfaWQ6IHVzZXIuaWRfc3RyLFxuICAgIC8vIHNjcmVlbl9uYW1lOiB1c2VyTmFtZSxcbiAgICBjb3VudDogMjAwLFxuICAgIHNraXBfc3RhdHVzOiB0cnVlLFxuICAgIGluY2x1ZGVfdXNlcl9lbnRpdGllczogZmFsc2UsXG4gICAgY3Vyc29yLFxuICB9KVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICByZXR1cm4gcmVzcG9uc2UuYm9keSBhcyBGb2xsb3dzTGlzdFJlc3BvbnNlXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEFQSUVycm9yKHJlc3BvbnNlKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiogZ2V0QWxsRm9sbG93cyhcbiAgdXNlcjogVHdpdHRlclVzZXIsXG4gIGZvbGxvd0tpbmQ6IEZvbGxvd0tpbmQsXG4gIG9wdGlvbnM6IEZvbGxvd3NTY3JhcGVyT3B0aW9uc1xuKTogQXN5bmNJdGVyYWJsZUl0ZXJhdG9yPEVpdGhlcjxBUElFcnJvciwgUmVhZG9ubHk8VHdpdHRlclVzZXI+Pj4ge1xuICBsZXQgY3Vyc29yID0gJy0xJ1xuICB3aGlsZSAodHJ1ZSkge1xuICAgIHRyeSB7XG4gICAgICBsZXQganNvbjogRm9sbG93c0xpc3RSZXNwb25zZVxuICAgICAgc3dpdGNoIChmb2xsb3dLaW5kKSB7XG4gICAgICAgIGNhc2UgJ2ZvbGxvd2Vycyc6XG4gICAgICAgICAganNvbiA9IGF3YWl0IGdldEZvbGxvd2Vyc0xpc3QodXNlciwgY3Vyc29yKVxuICAgICAgICAgIGJyZWFrXG4gICAgICAgIGNhc2UgJ2ZvbGxvd2luZyc6XG4gICAgICAgICAganNvbiA9IGF3YWl0IGdldEZvbGxvd2luZ3NMaXN0KHVzZXIsIGN1cnNvcilcbiAgICAgICAgICBicmVha1xuICAgICAgICBkZWZhdWx0OlxuICAgICAgICAgIHRocm93IG5ldyBFcnJvcigndW5yZWFjaGFibGUnKVxuICAgICAgfVxuICAgICAgY3Vyc29yID0ganNvbi5uZXh0X2N1cnNvcl9zdHJcbiAgICAgIGNvbnN0IHVzZXJzID0ganNvbi51c2VycyBhcyBUd2l0dGVyVXNlcltdXG4gICAgICB5aWVsZCogdXNlcnMubWFwKHVzZXIgPT4gKHtcbiAgICAgICAgb2s6IHRydWUgYXMgY29uc3QsXG4gICAgICAgIHZhbHVlOiBPYmplY3QuZnJlZXplKHVzZXIpLFxuICAgICAgfSkpXG4gICAgICBpZiAoY3Vyc29yID09PSAnMCcpIHtcbiAgICAgICAgYnJlYWtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIGF3YWl0IHNsZWVwKG9wdGlvbnMuZGVsYXkpXG4gICAgICAgIGNvbnRpbnVlXG4gICAgICB9XG4gICAgfSBjYXRjaCAoZXJyb3IpIHtcbiAgICAgIGlmIChlcnJvciBpbnN0YW5jZW9mIEFQSUVycm9yKSB7XG4gICAgICAgIHlpZWxkIHtcbiAgICAgICAgICBvazogZmFsc2UsXG4gICAgICAgICAgZXJyb3IsXG4gICAgICAgIH1cbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRocm93IGVycm9yXG4gICAgICB9XG4gICAgfVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRTaW5nbGVVc2VyQnlJZCh1c2VySWQ6IHN0cmluZyk6IFByb21pc2U8VHdpdHRlclVzZXI+IHtcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy91c2Vycy9zaG93Lmpzb24nLCB7XG4gICAgdXNlcl9pZDogdXNlcklkLFxuICAgIHNraXBfc3RhdHVzOiB0cnVlLFxuICAgIGluY2x1ZGVfZW50aXRpZXM6IGZhbHNlLFxuICB9KVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICByZXR1cm4gcmVzcG9uc2UuYm9keSBhcyBUd2l0dGVyVXNlclxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBBUElFcnJvcihyZXNwb25zZSlcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0U2luZ2xlVXNlckJ5TmFtZSh1c2VyTmFtZTogc3RyaW5nKTogUHJvbWlzZTxUd2l0dGVyVXNlcj4ge1xuICBjb25zdCBpc1ZhbGlkVXNlck5hbWUgPSB2YWxpZGF0ZVR3aXR0ZXJVc2VyTmFtZSh1c2VyTmFtZSlcbiAgaWYgKCFpc1ZhbGlkVXNlck5hbWUpIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoYEludmFsaWQgdXNlciBuYW1lIFwiJHt1c2VyTmFtZX1cIiFgKVxuICB9XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvdXNlcnMvc2hvdy5qc29uJywge1xuICAgIC8vIHVzZXJfaWQ6IHVzZXIuaWRfc3RyLFxuICAgIHNjcmVlbl9uYW1lOiB1c2VyTmFtZSxcbiAgICBza2lwX3N0YXR1czogdHJ1ZSxcbiAgICBpbmNsdWRlX2VudGl0aWVzOiBmYWxzZSxcbiAgfSlcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgcmV0dXJuIHJlc3BvbnNlLmJvZHkgYXMgVHdpdHRlclVzZXJcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgQVBJRXJyb3IocmVzcG9uc2UpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldE11bHRpcGxlVXNlcnNCeUlkKHVzZXJJZHM6IHN0cmluZ1tdKTogUHJvbWlzZTxUd2l0dGVyVXNlcltdPiB7XG4gIGlmICh1c2VySWRzLmxlbmd0aCA9PT0gMCkge1xuICAgIHJldHVybiBbXVxuICB9XG4gIGlmICh1c2VySWRzLmxlbmd0aCA+IDEwMCkge1xuICAgIHRocm93IG5ldyBFcnJvcigndG9vIG1hbnkgdXNlcnMhICg+IDEwMCknKVxuICB9XG4gIGNvbnN0IGpvaW5lZElkcyA9IEFycmF5LmZyb20obmV3IFNldCh1c2VySWRzKSkuam9pbignLCcpXG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ3Bvc3QnLCAnL3VzZXJzL2xvb2t1cC5qc29uJywge1xuICAgIHVzZXJfaWQ6IGpvaW5lZElkcyxcbiAgICBpbmNsdWRlX2VudGl0aWVzOiBmYWxzZSxcbiAgICAvLyBzY3JlZW5fbmFtZTogLi4uXG4gIH0pXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIHJldHVybiByZXNwb25zZS5ib2R5IGFzIFR3aXR0ZXJVc2VyW11cbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgQVBJRXJyb3IocmVzcG9uc2UpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldEZyaWVuZHNoaXBzKHVzZXJzOiBUd2l0dGVyVXNlcltdKTogUHJvbWlzZTxGcmllbmRzaGlwUmVzcG9uc2U+IHtcbiAgY29uc3QgdXNlcklkcyA9IHVzZXJzLm1hcCh1c2VyID0+IHVzZXIuaWRfc3RyKVxuICBpZiAodXNlcklkcy5sZW5ndGggPT09IDApIHtcbiAgICByZXR1cm4gW11cbiAgfVxuICBpZiAodXNlcklkcy5sZW5ndGggPiAxMDApIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3RvbyBtYW55IHVzZXJzISAoPiAxMDApJylcbiAgfVxuICBjb25zdCBqb2luZWRJZHMgPSBBcnJheS5mcm9tKG5ldyBTZXQodXNlcklkcykpLmpvaW4oJywnKVxuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL2ZyaWVuZHNoaXBzL2xvb2t1cC5qc29uJywge1xuICAgIHVzZXJfaWQ6IGpvaW5lZElkcyxcbiAgfSlcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgcmV0dXJuIHJlc3BvbnNlLmJvZHkgYXMgRnJpZW5kc2hpcFJlc3BvbnNlXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKCdyZXNwb25zZSBpcyBub3Qgb2snKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRSZWxhdGlvbnNoaXAoXG4gIHNvdXJjZVVzZXI6IFR3aXR0ZXJVc2VyLFxuICB0YXJnZXRVc2VyOiBUd2l0dGVyVXNlclxuKTogUHJvbWlzZTxSZWxhdGlvbnNoaXA+IHtcbiAgY29uc3Qgc291cmNlX2lkID0gc291cmNlVXNlci5pZF9zdHJcbiAgY29uc3QgdGFyZ2V0X2lkID0gdGFyZ2V0VXNlci5pZF9zdHJcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy9mcmllbmRzaGlwcy9zaG93Lmpzb24nLCB7XG4gICAgc291cmNlX2lkLFxuICAgIHRhcmdldF9pZCxcbiAgfSlcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgY29uc3QgeyByZWxhdGlvbnNoaXAgfSA9IHJlc3BvbnNlLmJvZHkgYXMge1xuICAgICAgcmVsYXRpb25zaGlwOiBSZWxhdGlvbnNoaXBcbiAgICB9XG4gICAgcmV0dXJuIHJlbGF0aW9uc2hpcFxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBFcnJvcigncmVzcG9uc2UgaXMgbm90IG9rJylcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0TXlzZWxmKCk6IFByb21pc2U8VHdpdHRlclVzZXI+IHtcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy9hY2NvdW50L3ZlcmlmeV9jcmVkZW50aWFscy5qc29uJylcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgcmV0dXJuIHJlc3BvbnNlLmJvZHkgYXMgVHdpdHRlclVzZXJcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgQVBJRXJyb3IocmVzcG9uc2UpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldFJhdGVMaW1pdFN0YXR1cygpOiBQcm9taXNlPExpbWl0U3RhdHVzPiB7XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvYXBwbGljYXRpb24vcmF0ZV9saW1pdF9zdGF0dXMuanNvbicpXG4gIGNvbnN0IHsgcmVzb3VyY2VzIH0gPSByZXNwb25zZS5ib2R5IGFzIHtcbiAgICByZXNvdXJjZXM6IExpbWl0U3RhdHVzXG4gIH1cbiAgcmV0dXJuIHJlc291cmNlc1xufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0Rm9sbG93c1NjcmFwZXJSYXRlTGltaXRTdGF0dXMoZm9sbG93S2luZDogRm9sbG93S2luZCk6IFByb21pc2U8TGltaXQ+IHtcbiAgY29uc3QgbGltaXRTdGF0dXMgPSBhd2FpdCBnZXRSYXRlTGltaXRTdGF0dXMoKVxuICBpZiAoZm9sbG93S2luZCA9PT0gJ2ZvbGxvd2VycycpIHtcbiAgICByZXR1cm4gbGltaXRTdGF0dXMuZm9sbG93ZXJzWycvZm9sbG93ZXJzL2xpc3QnXVxuICB9IGVsc2UgaWYgKGZvbGxvd0tpbmQgPT09ICdmb2xsb3dpbmcnKSB7XG4gICAgcmV0dXJuIGxpbWl0U3RhdHVzLmZyaWVuZHNbJy9mcmllbmRzL2xpc3QnXVxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBFcnJvcigndW5yZWFjaGFibGUnKVxuICB9XG59XG5cbmZ1bmN0aW9uIGdldENzcmZUb2tlbkZyb21Db29raWVzKCk6IHN0cmluZyB7XG4gIHJldHVybiAvXFxiY3QwPShbMC05YS1mXSspL2kuZXhlYyhkb2N1bWVudC5jb29raWUpIVsxXVxufVxuXG5mdW5jdGlvbiBnZW5lcmF0ZVR3aXR0ZXJBUElPcHRpb25zKG9iajogUmVxdWVzdEluaXQpOiBSZXF1ZXN0SW5pdCB7XG4gIGNvbnN0IGNzcmZUb2tlbiA9IGdldENzcmZUb2tlbkZyb21Db29raWVzKClcbiAgY29uc3QgaGVhZGVycyA9IG5ldyBIZWFkZXJzKClcbiAgaGVhZGVycy5zZXQoJ2F1dGhvcml6YXRpb24nLCBgQmVhcmVyICR7QkVBUkVSX1RPS0VOfWApXG4gIGhlYWRlcnMuc2V0KCd4LWNzcmYtdG9rZW4nLCBjc3JmVG9rZW4pXG4gIGhlYWRlcnMuc2V0KCd4LXR3aXR0ZXItYWN0aXZlLXVzZXInLCAneWVzJylcbiAgaGVhZGVycy5zZXQoJ3gtdHdpdHRlci1hdXRoLXR5cGUnLCAnT0F1dGgyU2Vzc2lvbicpXG4gIGNvbnN0IHJlc3VsdDogUmVxdWVzdEluaXQgPSB7XG4gICAgbWV0aG9kOiAnZ2V0JyxcbiAgICBtb2RlOiAnY29ycycsXG4gICAgY3JlZGVudGlhbHM6ICdpbmNsdWRlJyxcbiAgICByZWZlcnJlcjogJ2h0dHBzOi8vdHdpdHRlci5jb20vJyxcbiAgICBoZWFkZXJzLFxuICB9XG4gIE9iamVjdC5hc3NpZ24ocmVzdWx0LCBvYmopXG4gIHJldHVybiByZXN1bHRcbn1cblxuZnVuY3Rpb24gc2V0RGVmYXVsdFBhcmFtcyhwYXJhbXM6IFVSTFNlYXJjaFBhcmFtcyk6IHZvaWQge1xuICBwYXJhbXMuc2V0KCdpbmNsdWRlX3Byb2ZpbGVfaW50ZXJzdGl0aWFsX3R5cGUnLCAnMScpXG4gIHBhcmFtcy5zZXQoJ2luY2x1ZGVfYmxvY2tpbmcnLCAnMScpXG4gIHBhcmFtcy5zZXQoJ2luY2x1ZGVfYmxvY2tlZF9ieScsICcxJylcbiAgcGFyYW1zLnNldCgnaW5jbHVkZV9mb2xsb3dlZF9ieScsICcxJylcbiAgcGFyYW1zLnNldCgnaW5jbHVkZV93YW50X3JldHdlZXRzJywgJzEnKVxuICBwYXJhbXMuc2V0KCdpbmNsdWRlX211dGVfZWRnZScsICcxJylcbiAgcGFyYW1zLnNldCgnaW5jbHVkZV9jYW5fZG0nLCAnMScpXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBzZW5kUmVxdWVzdChcbiAgbWV0aG9kOiBIVFRQTWV0aG9kcyxcbiAgcGF0aDogc3RyaW5nLFxuICBwYXJhbXNPYmo6IFVSTFBhcmFtc09iaiA9IHt9XG4pOiBQcm9taXNlPEFQSVJlc3BvbnNlPiB7XG4gIGNvbnN0IGZldGNoT3B0aW9ucyA9IGdlbmVyYXRlVHdpdHRlckFQSU9wdGlvbnMoeyBtZXRob2QgfSlcbiAgY29uc3QgdXJsID0gbmV3IFVSTChhcGlQcmVmaXggKyBwYXRoKVxuICBsZXQgcGFyYW1zOiBVUkxTZWFyY2hQYXJhbXNcbiAgaWYgKG1ldGhvZCA9PT0gJ2dldCcpIHtcbiAgICBwYXJhbXMgPSB1cmwuc2VhcmNoUGFyYW1zXG4gIH0gZWxzZSB7XG4gICAgcGFyYW1zID0gbmV3IFVSTFNlYXJjaFBhcmFtcygpXG4gICAgZmV0Y2hPcHRpb25zLmJvZHkgPSBwYXJhbXNcbiAgfVxuICBzZXREZWZhdWx0UGFyYW1zKHBhcmFtcylcbiAgZm9yIChjb25zdCBba2V5LCB2YWx1ZV0gb2YgT2JqZWN0LmVudHJpZXMocGFyYW1zT2JqKSkge1xuICAgIHBhcmFtcy5zZXQoa2V5LCB2YWx1ZS50b1N0cmluZygpKVxuICB9XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgZmV0Y2godXJsLnRvU3RyaW5nKCksIGZldGNoT3B0aW9ucylcbiAgY29uc3QgaGVhZGVycyA9IEFycmF5LmZyb20ocmVzcG9uc2UuaGVhZGVycykucmVkdWNlKFxuICAgIChvYmosIFtuYW1lLCB2YWx1ZV0pID0+ICgob2JqW25hbWVdID0gdmFsdWUpLCBvYmopLFxuICAgIHt9IGFzIHsgW25hbWU6IHN0cmluZ106IHN0cmluZyB9XG4gIClcbiAgY29uc3QgeyBvaywgc3RhdHVzLCBzdGF0dXNUZXh0IH0gPSByZXNwb25zZVxuICBjb25zdCBib2R5ID0gYXdhaXQgcmVzcG9uc2UuanNvbigpXG4gIGNvbnN0IGFwaVJlc3BvbnNlID0ge1xuICAgIG9rLFxuICAgIHN0YXR1cyxcbiAgICBzdGF0dXNUZXh0LFxuICAgIGhlYWRlcnMsXG4gICAgYm9keSxcbiAgfVxuICByZXR1cm4gYXBpUmVzcG9uc2Vcbn1cbiJdLCJzb3VyY2VSb290IjoiIn0=