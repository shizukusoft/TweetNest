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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/scripts/mirrorblock/twitter.ts");
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


/***/ }),

/***/ "./src/scripts/mirrorblock/mirrorblock-badge.ts":
/*!******************************************************!*\
  !*** ./src/scripts/mirrorblock/mirrorblock-badge.ts ***!
  \******************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return Badge; });
/* harmony import */ var _scripts_i18n__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/scripts/i18n */ "./src/scripts/i18n.ts");

class Badge {
    showUserName() {
        const name = this.user.screen_name;
        const userNameElem = this.baseElem.querySelector('.badge-username');
        userNameElem.textContent = `(@${name})`;
        userNameElem.hidden = false;
    }
    blockReflected() {
        const brBadge = this.baseElem.querySelector('.block-reflected[hidden]');
        brBadge.hidden = false;
    }
    attachAfter(targetElem) {
        if (!targetElem.hasAttribute(this.badgedAttr)) {
            targetElem.after(this.baseElem);
            targetElem.setAttribute(this.badgedAttr, '1');
        }
    }
    appendTo(targetElem) {
        if (!targetElem.hasAttribute(this.badgedAttr)) {
            targetElem.appendChild(this.baseElem);
            targetElem.setAttribute(this.badgedAttr, '1');
        }
    }
    constructor(user){
        this.user = user;
        this.badgedAttr = 'data-mirrorblock-badged';
        this.baseElem = document.createElement('span');
        const userName = user.screen_name;
        this.baseElem.className = 'mob-badge';
        this.baseElem.style.whiteSpace = 'initial';
        this.baseElem.innerHTML = `\
<span class="badge-wrapper">\n  <span class="badge blocks-you">\n    ${_scripts_i18n__WEBPACK_IMPORTED_MODULE_0__["getMessage"]('blocks_you')}\n    <span hidden class="badge-username"></span>\n  </span>\n  <span hidden class="badge block-reflected">\n    ${_scripts_i18n__WEBPACK_IMPORTED_MODULE_0__["getMessage"]('block_reflected')}\n  </span>\n</span>`;
        this.baseElem.querySelector('.badge.blocks-you').setAttribute('title', _scripts_i18n__WEBPACK_IMPORTED_MODULE_0__["getMessage"]('blocks_you_description', userName));
        this.baseElem.querySelector('.badge.block-reflected').setAttribute('title', _scripts_i18n__WEBPACK_IMPORTED_MODULE_0__["getMessage"]('block_reflected_description', userName));
    }
}



/***/ }),

/***/ "./src/scripts/mirrorblock/mirrorblock-mobile.ts":
/*!*******************************************************!*\
  !*** ./src/scripts/mirrorblock/mirrorblock-mobile.ts ***!
  \*******************************************************/
/*! exports provided: detectOnCurrentTwitter */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "detectOnCurrentTwitter", function() { return detectOnCurrentTwitter; });
/* harmony import */ var _scripts_common__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/scripts/common */ "./src/scripts/common.ts");
/* harmony import */ var _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/twitter-api */ "./src/scripts/twitter-api.ts");
/* harmony import */ var _mirrorblock_r__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./mirrorblock-r */ "./src/scripts/mirrorblock/mirrorblock-r.ts");
/* harmony import */ var _redux_store__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./redux-store */ "./src/scripts/mirrorblock/redux-store.ts");
/* harmony import */ var _scripts_event_names__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! 미러블락/scripts/event-names */ "./src/scripts/event-names.ts");





function markOutline(elem) {
    elem.setAttribute('data-mirrorblock-blocks-you', '1');
}
function getElemByDmData(dmData) {
    return document.querySelector(`[data-mirrorblock-conversation-id="${dmData.conversation_id}"]`);
}
async function detectProfile(rootElem) {
    const helpLinks = rootElem.querySelectorAll('a[href="https://support.twitter.com/articles/20172060"]');
    const helpLink = Array.from(_scripts_common__WEBPACK_IMPORTED_MODULE_0__["iterateUntouchedElems"](helpLinks)).shift();
    if (!helpLink) {
        return;
    }
    const userName = _scripts_common__WEBPACK_IMPORTED_MODULE_0__["getUserNameFromTweetUrl"](location);
    if (!userName) {
        return;
    }
    // const user = StoreRetriever.getUserByName(userName)
    const user = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getSingleUserByName"](userName);
    if (!user) {
        return;
    }
    Object(_mirrorblock_r__WEBPACK_IMPORTED_MODULE_2__["reflectBlock"])({
        user,
        indicateBlock (badge) {
            badge.appendTo(helpLink.parentElement);
        },
        indicateReflection (badge) {
            badge.blockReflected();
            _redux_store__WEBPACK_IMPORTED_MODULE_3__["StoreUpdater"].afterBlockUser(user);
        }
    });
}
function findElementToIndicateQuotedTweetFromBlockedUser(tweetElem, quotedTweetUrl) {
    const article = tweetElem.closest('article[role=article]');
    const quotedTweetInTimeline = tweetElem.querySelector('[data-testid=tweet] [data-testid=tweet]');
    const quotedTweetInDetail = article.querySelector('article article [data-testid=tweet]');
    const quotedTweet = quotedTweetInTimeline || quotedTweetInDetail;
    if (quotedTweet) {
        const quotedTweetInnerMessage = quotedTweet.querySelector('[dir=auto]');
        return quotedTweetInnerMessage || quotedTweet;
    } else {
        return article.querySelector(`a[href^="${quotedTweetUrl.pathname}" i]`);
    }
}
async function handleQuotedTweet(tweet, tweetElem) {
    if (!tweet.is_quote_status) {
        return;
    }
    const permalinkObject = tweet.quoted_status_permalink;
    if (!permalinkObject) {
        return;
    }
    const qUrlString = permalinkObject.expanded;
    const qUrl = new URL(qUrlString);
    // 드물게 인용 트윗 주소가 t.co 링크일 경우도 있더라.
    if (qUrl.hostname === 't.co') {
        return;
    }
    const quotedUserName = _scripts_common__WEBPACK_IMPORTED_MODULE_0__["getUserNameFromTweetUrl"](qUrl);
    const quotedUser = await _redux_store__WEBPACK_IMPORTED_MODULE_3__["UserGetter"].getUserByName(quotedUserName, true);
    if (!quotedUser) {
        return;
    }
    Object(_mirrorblock_r__WEBPACK_IMPORTED_MODULE_2__["reflectBlock"])({
        user: quotedUser,
        indicateBlock (badge) {
            const indicateMe = findElementToIndicateQuotedTweetFromBlockedUser(tweetElem, qUrl);
            markOutline(indicateMe);
            badge.attachAfter(indicateMe);
        },
        indicateReflection (badge) {
            badge.blockReflected();
            _redux_store__WEBPACK_IMPORTED_MODULE_3__["StoreUpdater"].afterBlockUser(quotedUser);
        }
    });
}
async function handleMentionsInTweet(tweet, tweetElem) {
    const mentionedUserEntities = tweet.entities.user_mentions || [];
    if (mentionedUserEntities.length <= 0) {
        return;
    }
    const article = tweetElem.closest('article[role=article]');
    const links = Array.from(article.querySelectorAll('a[role=link][href^="/"]'));
    const mentionElemsMap = new Map(mentionedUserEntities.map((ent)=>ent.screen_name.toLowerCase()
    ).map((loweredName)=>[
            loweredName,
            links.filter((a)=>a.pathname.toLowerCase() === `/${loweredName}`
            ), 
        ]
    ));
    const overflowed = article.querySelector('a[aria-label][href$="/people"]');
    const mentionedUsersMap = await _redux_store__WEBPACK_IMPORTED_MODULE_3__["UserGetter"].getMultipleUsersById(mentionedUserEntities.map((u)=>u.id_str
    ));
    for (const mUser of mentionedUsersMap.values()){
        await Object(_mirrorblock_r__WEBPACK_IMPORTED_MODULE_2__["reflectBlock"])({
            user: mUser,
            indicateBlock (badge) {
                const loweredName = mUser.screen_name.toLowerCase();
                const mentionElems = mentionElemsMap.get(loweredName);
                if (mentionElems.length > 0) {
                    mentionElems.forEach((el)=>{
                        markOutline(el);
                        badge.attachAfter(el);
                    });
                } else if (overflowed) {
                    markOutline(overflowed);
                    badge.showUserName();
                    badge.attachAfter(overflowed);
                }
            },
            indicateReflection (badge) {
                badge.blockReflected();
                _redux_store__WEBPACK_IMPORTED_MODULE_3__["StoreUpdater"].afterBlockUser(mUser);
            }
        });
    }
}
async function handleUserCells(user, elem) {
    Object(_mirrorblock_r__WEBPACK_IMPORTED_MODULE_2__["reflectBlock"])({
        user,
        indicateBlock (badge) {
            markOutline(elem);
            const badgeTarget = elem.querySelector('div[dir=ltr]');
            badge.attachAfter(badgeTarget);
        },
        indicateReflection (badge) {
            badge.blockReflected();
            _redux_store__WEBPACK_IMPORTED_MODULE_3__["StoreUpdater"].afterBlockUser(user);
        }
    });
}
async function handleDMConversation(convId) {
    const dmData = await _redux_store__WEBPACK_IMPORTED_MODULE_3__["StoreRetriever"].getDMData(convId);
    if (!dmData) {
        throw new Error('unreachable');
    }
    if (!dmData.read_only) {
        return;
    }
    const elem = getElemByDmData(dmData);
    const badgeTarget = elem.querySelector('div[dir=ltr]');
    const participants = await _redux_store__WEBPACK_IMPORTED_MODULE_3__["UserGetter"].getMultipleUsersById(dmData.participants.map((par)=>par.user_id
    ));
    const blockedMe = participants.filter((user)=>!!user.blocked_by
    );
    if (blockedMe.size <= 0) {
        return;
    }
    for (const userToBlock of blockedMe.values()){
        await Object(_mirrorblock_r__WEBPACK_IMPORTED_MODULE_2__["reflectBlock"])({
            user: userToBlock,
            indicateBlock (badge) {
                markOutline(elem);
                if (dmData.type === 'GROUP_DM') {
                    badge.showUserName();
                }
                badge.appendTo(badgeTarget);
            },
            indicateReflection (badge) {
                badge.blockReflected();
                _redux_store__WEBPACK_IMPORTED_MODULE_3__["StoreUpdater"].afterBlockUser(userToBlock);
            }
        });
    }
}
function* PromisesQueue() {
    let promise = Promise.resolve();
    while(promise = promise.then((yield)));
}
const promisesQueue = PromisesQueue();
// the first call of next executes from the start of the function
// until the first yield statement
promisesQueue.next();
function startObserve(reactRoot) {
    new MutationObserver((mutations)=>{
        for (const elem of _scripts_common__WEBPACK_IMPORTED_MODULE_0__["getAddedElementsFromMutations"](mutations)){
            detectProfile(elem);
        }
    }).observe(reactRoot, {
        subtree: true,
        childList: true
    });
    document.addEventListener(_scripts_event_names__WEBPACK_IMPORTED_MODULE_4__["USERCELL"], (event)=>{
        const customEvent = event;
        const elem = customEvent.target;
        const { user  } = customEvent.detail;
        handleUserCells(user, elem);
    });
    document.addEventListener(_scripts_event_names__WEBPACK_IMPORTED_MODULE_4__["DM"], (event)=>{
        const customEvent = event;
        const { convId  } = customEvent.detail;
        handleDMConversation(convId);
    });
    document.addEventListener(_scripts_event_names__WEBPACK_IMPORTED_MODULE_4__["TWEET"], (event)=>{
        const customEvent = event;
        const elem = customEvent.target;
        const { tweet  } = customEvent.detail;
        promisesQueue.next(()=>handleMentionsInTweet(tweet, elem)
        );
        promisesQueue.next(()=>handleQuotedTweet(tweet, elem)
        );
    });
}
async function isLoggedIn() {
    try {
        const scripts = Array.from(document.querySelectorAll('script:not([src])'));
        const result = scripts.map((script)=>/"isLoggedIn":(true|false)/.exec(script.innerHTML)
        ).filter((n)=>!!n
        ).pop().pop();
        return result === 'true';
    } catch (err) {
        console.warn('warning. login-check logic should update.');
        console.warn('error: %o', err);
        const checkViaAPI = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getMyself"]().catch(()=>null
        );
        return !!checkViaAPI;
    }
}
async function detectOnCurrentTwitter(reactRoot) {
    const loggedIn = await isLoggedIn();
    if (!loggedIn) {
        return;
    }
    await _scripts_common__WEBPACK_IMPORTED_MODULE_0__["injectScript"]('bundled/twitter_inject.bun.js');
    startObserve(reactRoot);
}


/***/ }),

/***/ "./src/scripts/mirrorblock/mirrorblock-r.ts":
/*!**************************************************!*\
  !*** ./src/scripts/mirrorblock/mirrorblock-r.ts ***!
  \**************************************************/
/*! exports provided: reflectBlock */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "reflectBlock", function() { return reflectBlock; });
/* harmony import */ var _extoption__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/extoption */ "./src/extoption.ts");
/* harmony import */ var _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/twitter-api */ "./src/scripts/twitter-api.ts");
/* harmony import */ var _mirrorblock_badge__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./mirrorblock-badge */ "./src/scripts/mirrorblock/mirrorblock-badge.ts");



async function reflectBlock({ user , indicateBlock , indicateReflection  }) {
    // Redux store에서 꺼내온 유저 개체에 blocked_by가 빠져있는 경우가 있더라.
    if (typeof user.blocked_by !== 'boolean') {
        const userFromAPI = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getSingleUserById"](user.id_str);
        if (typeof userFromAPI.blocked_by !== 'boolean') {
            throw new Error('unexpected: still no blocked_by property');
        }
        return reflectBlock({
            user: userFromAPI,
            indicateBlock,
            indicateReflection
        });
    }
    if (!user.blocked_by) {
        return;
    }
    const badge = new _mirrorblock_badge__WEBPACK_IMPORTED_MODULE_2__["default"](user);
    indicateBlock(badge);
    const extOptions = await _extoption__WEBPACK_IMPORTED_MODULE_0__["load"]();
    const muteSkip = user.muting && !extOptions.blockMutedUser;
    const shouldBlock = extOptions.enableBlockReflection && !muteSkip && !user.blocking;
    if (shouldBlock) {
        const blockResult = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["blockUser"](user).catch((err)=>{
            console.error(err);
            return false;
        });
        if (blockResult) {
            indicateReflection(badge);
        }
    }
}


/***/ }),

/***/ "./src/scripts/mirrorblock/redux-store.ts":
/*!************************************************!*\
  !*** ./src/scripts/mirrorblock/redux-store.ts ***!
  \************************************************/
/*! exports provided: StoreUpdater, StoreRetriever, UserGetter */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _redux_store_updater__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./redux-store/updater */ "./src/scripts/mirrorblock/redux-store/updater.ts");
/* harmony reexport (module object) */ __webpack_require__.d(__webpack_exports__, "StoreUpdater", function() { return _redux_store_updater__WEBPACK_IMPORTED_MODULE_0__; });
/* harmony import */ var _redux_store_retriever__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./redux-store/retriever */ "./src/scripts/mirrorblock/redux-store/retriever.ts");
/* harmony reexport (module object) */ __webpack_require__.d(__webpack_exports__, "StoreRetriever", function() { return _redux_store_retriever__WEBPACK_IMPORTED_MODULE_1__; });
/* harmony import */ var _redux_store_user_getter__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./redux-store/user-getter */ "./src/scripts/mirrorblock/redux-store/user-getter.ts");
/* harmony reexport (module object) */ __webpack_require__.d(__webpack_exports__, "UserGetter", function() { return _redux_store_user_getter__WEBPACK_IMPORTED_MODULE_2__; });








/***/ }),

/***/ "./src/scripts/mirrorblock/redux-store/retriever.ts":
/*!**********************************************************!*\
  !*** ./src/scripts/mirrorblock/redux-store/retriever.ts ***!
  \**********************************************************/
/*! exports provided: getMultipleUsersByIds, getUserById, getUserByName, getDMData */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getMultipleUsersByIds", function() { return getMultipleUsersByIds; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getUserById", function() { return getUserById; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getUserByName", function() { return getUserByName; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getDMData", function() { return getDMData; });
/* harmony import */ var _updater__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./updater */ "./src/scripts/mirrorblock/redux-store/updater.ts");

async function triggerPageEventWithResponse(eventName, eventDetail) {
    const detail = Object(_updater__WEBPACK_IMPORTED_MODULE_0__["cloneDetail"])(eventDetail);
    const nonce = Math.random();
    Object.assign(detail, {
        nonce
    });
    const requestEvent = new CustomEvent(`MirrorBlock-->${eventName}`, {
        detail
    });
    return new Promise((resolve, reject)=>{
        let timeouted = false;
        const timeout = window.setTimeout(()=>{
            timeouted = true;
            reject('timeout!');
        }, 10000);
        document.addEventListener(`MirrorBlock<--${eventName}.${nonce}`, (event)=>{
            window.clearTimeout(timeout);
            if (timeouted) {
                return;
            }
            const customEvent = event;
            resolve(customEvent.detail);
        }, {
            once: true
        });
        document.dispatchEvent(requestEvent);
    });
}
async function getMultipleUsersByIds(userIds) {
    return triggerPageEventWithResponse('getMultipleUsersByIds', {
        userIds
    });
}
async function getUserById(userId) {
    const users = await triggerPageEventWithResponse('getMultipleUsersByIds', {
        userIds: [
            userId
        ]
    }).catch(()=>{
    });
    return users[userId] || null;
}
async function getUserByName(userName) {
    return triggerPageEventWithResponse('getUserByName', {
        userName
    });
}
async function getDMData(convId) {
    return triggerPageEventWithResponse('getDMData', {
        convId
    });
}


/***/ }),

/***/ "./src/scripts/mirrorblock/redux-store/updater.ts":
/*!********************************************************!*\
  !*** ./src/scripts/mirrorblock/redux-store/updater.ts ***!
  \********************************************************/
/*! exports provided: cloneDetail, insertSingleUserIntoStore, insertMultipleUsersIntoStore, afterBlockUser, toastMessage */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "cloneDetail", function() { return cloneDetail; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "insertSingleUserIntoStore", function() { return insertSingleUserIntoStore; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "insertMultipleUsersIntoStore", function() { return insertMultipleUsersIntoStore; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "afterBlockUser", function() { return afterBlockUser; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "toastMessage", function() { return toastMessage; });
// 파이어폭스에서 CustomEvent의 detail 개체 전달용
function cloneDetail(detail) {
    if (typeof detail !== 'object') {
        return detail;
    }
    if (typeof cloneInto === 'function') {
        return cloneInto(detail, document.defaultView);
    } else {
        return detail;
    }
}
function triggerPageEvent(eventName, eventDetail) {
    const detail = cloneDetail(eventDetail);
    const requestEvent = new CustomEvent(`MirrorBlock->${eventName}`, {
        detail
    });
    document.dispatchEvent(requestEvent);
}
async function insertSingleUserIntoStore(user) {
    triggerPageEvent('insertSingleUserIntoStore', {
        user
    });
}
async function insertMultipleUsersIntoStore(usersMap) {
    const usersObj = usersMap.toUserObject();
    triggerPageEvent('insertMultipleUsersIntoStore', {
        users: usersObj
    });
}
async function afterBlockUser(user) {
    triggerPageEvent('afterBlockUser', {
        user
    });
    const clonedUser = Object.assign({
    }, user);
    clonedUser.blocking = true;
    insertSingleUserIntoStore(clonedUser);
}
async function toastMessage(text) {
    triggerPageEvent('toastMessage', {
        text
    });
}


/***/ }),

/***/ "./src/scripts/mirrorblock/redux-store/user-getter.ts":
/*!************************************************************!*\
  !*** ./src/scripts/mirrorblock/redux-store/user-getter.ts ***!
  \************************************************************/
/*! exports provided: getUserById, getUserByName, getMultipleUsersById */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getUserById", function() { return getUserById; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getUserByName", function() { return getUserByName; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getMultipleUsersById", function() { return getMultipleUsersById; });
/* harmony import */ var _scripts_common__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/scripts/common */ "./src/scripts/common.ts");
/* harmony import */ var _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/twitter-api */ "./src/scripts/twitter-api.ts");
/* harmony import */ var _retriever__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./retriever */ "./src/scripts/mirrorblock/redux-store/retriever.ts");
/* harmony import */ var _updater__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./updater */ "./src/scripts/mirrorblock/redux-store/updater.ts");




// Redux store에 들어가기 전에 요청이 들어오는 경우를 대비한 캐시
const userCacheById = new Map();
const userCacheByName = new Map();
function addUserToCache(user) {
    userCacheById.set(user.id_str, user);
    userCacheByName.set(user.screen_name, user);
}
// API호출 실패한 사용자 ID나 사용자이름을 저장하여 API호출을 반복하지 않도록 한다.
// (예: 지워지거나 정지걸린 계정)
const notExistUsers = new Set();
function treatAsNonExistUser(failedIdOrNames) {
    return (err)=>{
        failedIdOrNames.forEach((idOrName)=>notExistUsers.add(idOrName.toLowerCase())
        );
        console.error(err);
    };
}
async function getUserById(userId, useAPI) {
    if (notExistUsers.has(userId)) {
        return null;
    }
    const userFromStore = await _retriever__WEBPACK_IMPORTED_MODULE_2__["getUserById"](userId);
    if (userFromStore && Object(_scripts_common__WEBPACK_IMPORTED_MODULE_0__["isTwitterUser"])(userFromStore)) {
        addUserToCache(userFromStore);
        return userFromStore;
    } else if (userCacheById.has(userId)) {
        return userCacheById.get(userId);
    } else if (useAPI) {
        const user = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getSingleUserById"](userId).catch(treatAsNonExistUser([
            userId
        ]));
        if (user) {
            addUserToCache(user);
            _updater__WEBPACK_IMPORTED_MODULE_3__["insertSingleUserIntoStore"](user);
        }
        return user || null;
    } else {
        return null;
    }
}
async function getUserByName(userName, useAPI) {
    const loweredName = userName.toLowerCase();
    if (notExistUsers.has(loweredName)) {
        return null;
    }
    const userFromStore = await _retriever__WEBPACK_IMPORTED_MODULE_2__["getUserByName"](loweredName);
    if (userFromStore && Object(_scripts_common__WEBPACK_IMPORTED_MODULE_0__["isTwitterUser"])(userFromStore)) {
        addUserToCache(userFromStore);
        return userFromStore;
    } else if (userCacheByName.has(userName)) {
        return userCacheByName.get(userName);
    } else if (useAPI) {
        const user = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getSingleUserByName"](userName).catch(treatAsNonExistUser([
            userName
        ]));
        if (user) {
            addUserToCache(user);
            _updater__WEBPACK_IMPORTED_MODULE_3__["insertSingleUserIntoStore"](user);
        }
        return user || null;
    } else {
        return null;
    }
}
async function getMultipleUsersById(userIds) {
    if (userIds.length > 100) {
        throw new Error('too many user!');
    }
    const resultUserMap = new _scripts_common__WEBPACK_IMPORTED_MODULE_0__["TwitterUserMap"]();
    const idsToRequestAPI = [];
    for (const userId of userIds){
        const userFromStore = await _retriever__WEBPACK_IMPORTED_MODULE_2__["getUserById"](userId);
        const userFromCache = userCacheById.get(userId);
        if (userFromStore && Object(_scripts_common__WEBPACK_IMPORTED_MODULE_0__["isTwitterUser"])(userFromStore)) {
            addUserToCache(userFromStore);
            resultUserMap.addUser(userFromStore);
        } else if (userFromCache) {
            resultUserMap.addUser(userFromCache);
        } else if (!notExistUsers.has(userId)) {
            idsToRequestAPI.push(userId);
        }
    }
    if (idsToRequestAPI.length === 1) {
        const requestedUser = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getSingleUserById"](idsToRequestAPI[0]).catch(treatAsNonExistUser(idsToRequestAPI));
        if (requestedUser) {
            addUserToCache(requestedUser);
            _updater__WEBPACK_IMPORTED_MODULE_3__["insertSingleUserIntoStore"](requestedUser);
            resultUserMap.addUser(requestedUser);
        }
    } else if (idsToRequestAPI.length > 1) {
        const requestedUsers = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getMultipleUsersById"](idsToRequestAPI).then((users)=>_scripts_common__WEBPACK_IMPORTED_MODULE_0__["TwitterUserMap"].fromUsersArray(users)
        ).catch(treatAsNonExistUser(idsToRequestAPI));
        if (requestedUsers) {
            _updater__WEBPACK_IMPORTED_MODULE_3__["insertMultipleUsersIntoStore"](requestedUsers);
            requestedUsers.forEach((user)=>{
                addUserToCache(user);
                resultUserMap.addUser(user);
            });
        }
    }
    return resultUserMap;
}


/***/ }),

/***/ "./src/scripts/mirrorblock/twitter.ts":
/*!********************************************!*\
  !*** ./src/scripts/mirrorblock/twitter.ts ***!
  \********************************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _mirrorblock_mobile__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./mirrorblock-mobile */ "./src/scripts/mirrorblock/mirrorblock-mobile.ts");
/* harmony import */ var _scripts_nightmode__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/nightmode */ "./src/scripts/nightmode.ts");
/* harmony import */ var _extoption__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! 미러블락/extoption */ "./src/extoption.ts");



function initialize() {
    browser.storage.onChanged.addListener((changes)=>{
        const option = changes.option.newValue;
        document.documentElement.classList.toggle('mob-enable-outline', option.outlineBlockUser);
    });
    _extoption__WEBPACK_IMPORTED_MODULE_2__["load"]().then((option)=>{
        document.documentElement.classList.toggle('mob-enable-outline', option.outlineBlockUser);
    });
    const reactRoot = document.getElementById('react-root');
    Object(_mirrorblock_mobile__WEBPACK_IMPORTED_MODULE_0__["detectOnCurrentTwitter"])(reactRoot);
    Object(_scripts_nightmode__WEBPACK_IMPORTED_MODULE_1__["handleDarkMode"])();
}
initialize();


/***/ }),

/***/ "./src/scripts/nightmode.ts":
/*!**********************************!*\
  !*** ./src/scripts/nightmode.ts ***!
  \**********************************/
/*! exports provided: handleDarkMode */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "handleDarkMode", function() { return handleDarkMode; });
function isDark(colorThemeElem) {
    return colorThemeElem.content.toUpperCase() !== '#FFFFFF';
}
function toggleNightMode(dark) {
    document.documentElement.classList.toggle('mob-nightmode', dark);
}
function handleDarkMode() {
    // TODO: mob-mobile 은 이제 필요없음
    // 단, 지울 때 chainblock.css 를 수정해야 함
    document.documentElement.classList.add('mob-mobile');
    const colorThemeTag = document.querySelector('meta[name=theme-color]');
    if (colorThemeTag instanceof HTMLMetaElement) {
        const nightModeObserver = new MutationObserver(()=>{
            toggleNightMode(isDark(colorThemeTag));
        });
        nightModeObserver.observe(colorThemeTag, {
            attributeFilter: [
                'content'
            ],
            attributes: true
        });
        toggleNightMode(isDark(colorThemeTag));
    }
}


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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V4dG9wdGlvbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9jb21tb24udHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvZXZlbnQtbmFtZXMudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvaTE4bi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9taXJyb3JibG9jay9taXJyb3JibG9jay1iYWRnZS50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9taXJyb3JibG9jay9taXJyb3JibG9jay1tb2JpbGUudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvbWlycm9yYmxvY2svbWlycm9yYmxvY2stci50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9taXJyb3JibG9jay9yZWR1eC1zdG9yZS50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9taXJyb3JibG9jay9yZWR1eC1zdG9yZS9yZXRyaWV2ZXIudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvbWlycm9yYmxvY2svcmVkdXgtc3RvcmUvdXBkYXRlci50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9taXJyb3JibG9jay9yZWR1eC1zdG9yZS91c2VyLWdldHRlci50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9taXJyb3JibG9jay90d2l0dGVyLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL25pZ2h0bW9kZS50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy90d2l0dGVyLWFwaS50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiO1FBQUE7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7OztRQUdBO1FB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QUMsY0FBZ0IsSUFBRSxDQUFHOztlQUdaLFdBQVcsQ0FDL0IsTUFBbUIsRUFDbkIsSUFBWSxFQUNaLFNBQXVCOztVQUVqQixZQUFZLEdBQUcseUJBQXlCO1FBQUcsTUFBTTs7VUFDakQsR0FBRyxPQUFPLEdBQUcsQ0FBQyxTQUFTLEdBQUcsSUFBSTtRQUNoQyxNQUFNO1FBQ04sTUFBTSxNQUFLLEdBQUs7UUFDbEIsTUFBTSxHQUFHLEdBQUcsQ0FBQyxZQUFZOztRQUV6QixNQUFNLE9BQU8sZUFBZTtRQUM1QixZQUFZLENBQUMsSUFBSSxHQUFHLE1BQU07O0lBRTVCLGdCQUFnQixDQUFDLE1BQU07Z0JBQ1gsR0FBRyxFQUFFLEtBQUssS0FBSyxNQUFNLENBQUMsT0FBTyxDQUFDLFNBQVM7UUFDakQsTUFBTSxDQUFDLEdBQUcsQ0FBQyxHQUFHLEVBQUUsS0FBSyxDQUFDLFFBQVE7O1VBRTFCLFNBQVEsU0FBUyxLQUFLLENBQUMsR0FBRyxDQUFDLFFBQVEsSUFBSSxZQUFZO1VBQ25ELE9BQU8sR0FBRyxLQUFLLENBQUMsSUFBSSxDQUFDLFNBQVEsQ0FBQyxPQUFPLEVBQUUsTUFBTSxFQUNoRCxHQUFHLEdBQUcsSUFBSSxFQUFFLE1BQUssS0FBUSxHQUFHLENBQUMsSUFBSSxJQUFJLE1BQUssRUFBRyxHQUFHOzs7WUFHM0MsRUFBRSxHQUFFLE1BQU0sR0FBRSxVQUFVLE1BQUssU0FBUTtVQUNyQyxJQUFJLFNBQVMsU0FBUSxDQUFDLElBQUk7VUFDMUIsV0FBVztRQUNmLEVBQUU7UUFDRixNQUFNO1FBQ04sVUFBVTtRQUNWLE9BQU87UUFDUCxJQUFJOztXQUVDLFdBQVciLCJmaWxlIjoidHdpdHRlci5idW4uanMiLCJzb3VyY2VzQ29udGVudCI6WyIgXHQvLyBUaGUgbW9kdWxlIGNhY2hlXG4gXHR2YXIgaW5zdGFsbGVkTW9kdWxlcyA9IHt9O1xuXG4gXHQvLyBUaGUgcmVxdWlyZSBmdW5jdGlvblxuIFx0ZnVuY3Rpb24gX193ZWJwYWNrX3JlcXVpcmVfXyhtb2R1bGVJZCkge1xuXG4gXHRcdC8vIENoZWNrIGlmIG1vZHVsZSBpcyBpbiBjYWNoZVxuIFx0XHRpZihpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXSkge1xuIFx0XHRcdHJldHVybiBpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXS5leHBvcnRzO1xuIFx0XHR9XG4gXHRcdC8vIENyZWF0ZSBhIG5ldyBtb2R1bGUgKGFuZCBwdXQgaXQgaW50byB0aGUgY2FjaGUpXG4gXHRcdHZhciBtb2R1bGUgPSBpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXSA9IHtcbiBcdFx0XHRpOiBtb2R1bGVJZCxcbiBcdFx0XHRsOiBmYWxzZSxcbiBcdFx0XHRleHBvcnRzOiB7fVxuIFx0XHR9O1xuXG4gXHRcdC8vIEV4ZWN1dGUgdGhlIG1vZHVsZSBmdW5jdGlvblxuIFx0XHRtb2R1bGVzW21vZHVsZUlkXS5jYWxsKG1vZHVsZS5leHBvcnRzLCBtb2R1bGUsIG1vZHVsZS5leHBvcnRzLCBfX3dlYnBhY2tfcmVxdWlyZV9fKTtcblxuIFx0XHQvLyBGbGFnIHRoZSBtb2R1bGUgYXMgbG9hZGVkXG4gXHRcdG1vZHVsZS5sID0gdHJ1ZTtcblxuIFx0XHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuIFx0XHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG4gXHR9XG5cblxuIFx0Ly8gZXhwb3NlIHRoZSBtb2R1bGVzIG9iamVjdCAoX193ZWJwYWNrX21vZHVsZXNfXylcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubSA9IG1vZHVsZXM7XG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlIGNhY2hlXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmMgPSBpbnN0YWxsZWRNb2R1bGVzO1xuXG4gXHQvLyBkZWZpbmUgZ2V0dGVyIGZ1bmN0aW9uIGZvciBoYXJtb255IGV4cG9ydHNcbiBcdF9fd2VicGFja19yZXF1aXJlX18uZCA9IGZ1bmN0aW9uKGV4cG9ydHMsIG5hbWUsIGdldHRlcikge1xuIFx0XHRpZighX193ZWJwYWNrX3JlcXVpcmVfXy5vKGV4cG9ydHMsIG5hbWUpKSB7XG4gXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIG5hbWUsIHsgZW51bWVyYWJsZTogdHJ1ZSwgZ2V0OiBnZXR0ZXIgfSk7XG4gXHRcdH1cbiBcdH07XG5cbiBcdC8vIGRlZmluZSBfX2VzTW9kdWxlIG9uIGV4cG9ydHNcbiBcdF9fd2VicGFja19yZXF1aXJlX18uciA9IGZ1bmN0aW9uKGV4cG9ydHMpIHtcbiBcdFx0aWYodHlwZW9mIFN5bWJvbCAhPT0gJ3VuZGVmaW5lZCcgJiYgU3ltYm9sLnRvU3RyaW5nVGFnKSB7XG4gXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIFN5bWJvbC50b1N0cmluZ1RhZywgeyB2YWx1ZTogJ01vZHVsZScgfSk7XG4gXHRcdH1cbiBcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsICdfX2VzTW9kdWxlJywgeyB2YWx1ZTogdHJ1ZSB9KTtcbiBcdH07XG5cbiBcdC8vIGNyZWF0ZSBhIGZha2UgbmFtZXNwYWNlIG9iamVjdFxuIFx0Ly8gbW9kZSAmIDE6IHZhbHVlIGlzIGEgbW9kdWxlIGlkLCByZXF1aXJlIGl0XG4gXHQvLyBtb2RlICYgMjogbWVyZ2UgYWxsIHByb3BlcnRpZXMgb2YgdmFsdWUgaW50byB0aGUgbnNcbiBcdC8vIG1vZGUgJiA0OiByZXR1cm4gdmFsdWUgd2hlbiBhbHJlYWR5IG5zIG9iamVjdFxuIFx0Ly8gbW9kZSAmIDh8MTogYmVoYXZlIGxpa2UgcmVxdWlyZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy50ID0gZnVuY3Rpb24odmFsdWUsIG1vZGUpIHtcbiBcdFx0aWYobW9kZSAmIDEpIHZhbHVlID0gX193ZWJwYWNrX3JlcXVpcmVfXyh2YWx1ZSk7XG4gXHRcdGlmKG1vZGUgJiA4KSByZXR1cm4gdmFsdWU7XG4gXHRcdGlmKChtb2RlICYgNCkgJiYgdHlwZW9mIHZhbHVlID09PSAnb2JqZWN0JyAmJiB2YWx1ZSAmJiB2YWx1ZS5fX2VzTW9kdWxlKSByZXR1cm4gdmFsdWU7XG4gXHRcdHZhciBucyA9IE9iamVjdC5jcmVhdGUobnVsbCk7XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18ucihucyk7XG4gXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShucywgJ2RlZmF1bHQnLCB7IGVudW1lcmFibGU6IHRydWUsIHZhbHVlOiB2YWx1ZSB9KTtcbiBcdFx0aWYobW9kZSAmIDIgJiYgdHlwZW9mIHZhbHVlICE9ICdzdHJpbmcnKSBmb3IodmFyIGtleSBpbiB2YWx1ZSkgX193ZWJwYWNrX3JlcXVpcmVfXy5kKG5zLCBrZXksIGZ1bmN0aW9uKGtleSkgeyByZXR1cm4gdmFsdWVba2V5XTsgfS5iaW5kKG51bGwsIGtleSkpO1xuIFx0XHRyZXR1cm4gbnM7XG4gXHR9O1xuXG4gXHQvLyBnZXREZWZhdWx0RXhwb3J0IGZ1bmN0aW9uIGZvciBjb21wYXRpYmlsaXR5IHdpdGggbm9uLWhhcm1vbnkgbW9kdWxlc1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5uID0gZnVuY3Rpb24obW9kdWxlKSB7XG4gXHRcdHZhciBnZXR0ZXIgPSBtb2R1bGUgJiYgbW9kdWxlLl9fZXNNb2R1bGUgP1xuIFx0XHRcdGZ1bmN0aW9uIGdldERlZmF1bHQoKSB7IHJldHVybiBtb2R1bGVbJ2RlZmF1bHQnXTsgfSA6XG4gXHRcdFx0ZnVuY3Rpb24gZ2V0TW9kdWxlRXhwb3J0cygpIHsgcmV0dXJuIG1vZHVsZTsgfTtcbiBcdFx0X193ZWJwYWNrX3JlcXVpcmVfXy5kKGdldHRlciwgJ2EnLCBnZXR0ZXIpO1xuIFx0XHRyZXR1cm4gZ2V0dGVyO1xuIFx0fTtcblxuIFx0Ly8gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm8gPSBmdW5jdGlvbihvYmplY3QsIHByb3BlcnR5KSB7IHJldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwob2JqZWN0LCBwcm9wZXJ0eSk7IH07XG5cbiBcdC8vIF9fd2VicGFja19wdWJsaWNfcGF0aF9fXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnAgPSBcIlwiO1xuXG5cbiBcdC8vIExvYWQgZW50cnkgbW9kdWxlIGFuZCByZXR1cm4gZXhwb3J0c1xuIFx0cmV0dXJuIF9fd2VicGFja19yZXF1aXJlX18oX193ZWJwYWNrX3JlcXVpcmVfXy5zID0gXCIuL3NyYy9zY3JpcHRzL21pcnJvcmJsb2NrL3R3aXR0ZXIudHNcIik7XG4iLCJjb25zdCBkZWZhdWx0cyA9IE9iamVjdC5mcmVlemU8TWlycm9yQmxvY2tPcHRpb24+KHtcbiAgb3V0bGluZUJsb2NrVXNlcjogZmFsc2UsXG4gIGVuYWJsZUJsb2NrUmVmbGVjdGlvbjogZmFsc2UsXG4gIGJsb2NrTXV0ZWRVc2VyOiBmYWxzZSxcbiAgYWx3YXlzSW1tZWRpYXRlbHlCbG9ja01vZGU6IGZhbHNlLFxufSlcblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIHNhdmUobmV3T3B0aW9uOiBNaXJyb3JCbG9ja09wdGlvbikge1xuICBjb25zdCBvcHRpb24gPSBPYmplY3QuYXNzaWduPFxuICAgIG9iamVjdCxcbiAgICBNaXJyb3JCbG9ja09wdGlvbixcbiAgICBQYXJ0aWFsPE1pcnJvckJsb2NrT3B0aW9uPlxuICA+KHt9LCBkZWZhdWx0cywgbmV3T3B0aW9uKVxuICByZXR1cm4gYnJvd3Nlci5zdG9yYWdlLmxvY2FsLnNldCh7XG4gICAgb3B0aW9uLFxuICB9IGFzIGFueSlcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGxvYWQoKTogUHJvbWlzZTxNaXJyb3JCbG9ja09wdGlvbj4ge1xuICBjb25zdCBsb2FkZWQgPSBhd2FpdCBicm93c2VyLnN0b3JhZ2UubG9jYWwuZ2V0KCdvcHRpb24nKVxuICByZXR1cm4gT2JqZWN0LmFzc2lnbjxvYmplY3QsIE1pcnJvckJsb2NrT3B0aW9uLCBhbnk+KFxuICAgIHt9LFxuICAgIGRlZmF1bHRzLFxuICAgIGxvYWRlZC5vcHRpb25cbiAgKVxufVxuIiwiZXhwb3J0IGNvbnN0IGVudW0gQWN0aW9uIHtcbiAgU3RhcnRDaGFpbkJsb2NrID0gJ01pcnJvckJsb2NrL1N0YXJ0JyxcbiAgU3RvcENoYWluQmxvY2sgPSAnTWlycm9yQmxvY2svU3RvcCcsXG4gIEFsZXJ0ID0gJ01pcnJvckJsb2NrL0FsZXJ0Jyxcbn1cblxuY29uc3QgVVNFUl9OQU1FX0JMQUNLTElTVCA9IE9iamVjdC5mcmVlemUoW1xuICAnMScsXG4gICdhYm91dCcsXG4gICdhY2NvdW50JyxcbiAgJ2ZvbGxvd2VycycsXG4gICdmb2xsb3dpbmdzJyxcbiAgJ2hhc2h0YWcnLFxuICAnaG9tZScsXG4gICdpJyxcbiAgJ2xpc3RzJyxcbiAgJ2xvZ2luJyxcbiAgJ29hdXRoJyxcbiAgJ3ByaXZhY3knLFxuICAnc2VhcmNoJyxcbiAgJ3RvcycsXG4gICdub3RpZmljYXRpb25zJyxcbiAgJ21lc3NhZ2VzJyxcbiAgJ2V4cGxvcmUnLFxuXSlcblxuZXhwb3J0IGNsYXNzIFR3aXR0ZXJVc2VyTWFwIGV4dGVuZHMgTWFwPHN0cmluZywgVHdpdHRlclVzZXI+IHtcbiAgcHVibGljIGFkZFVzZXIodXNlcjogVHdpdHRlclVzZXIpIHtcbiAgICB0aGlzLnNldCh1c2VyLmlkX3N0ciwgdXNlcilcbiAgfVxuICBwdWJsaWMgaGFzVXNlcih1c2VyOiBUd2l0dGVyVXNlcikge1xuICAgIHJldHVybiB0aGlzLmhhcyh1c2VyLmlkX3N0cilcbiAgfVxuICBwdWJsaWMgdG9Vc2VyQXJyYXkoKTogVHdpdHRlclVzZXJbXSB7XG4gICAgcmV0dXJuIEFycmF5LmZyb20odGhpcy52YWx1ZXMoKSlcbiAgfVxuICBwdWJsaWMgdG9Vc2VyT2JqZWN0KCk6IFR3aXR0ZXJVc2VyRW50aXRpZXMge1xuICAgIGNvbnN0IHVzZXJzT2JqOiBUd2l0dGVyVXNlckVudGl0aWVzID0gT2JqZWN0LmNyZWF0ZShudWxsKVxuICAgIGZvciAoY29uc3QgW3VzZXJJZCwgdXNlcl0gb2YgdGhpcykge1xuICAgICAgdXNlcnNPYmpbdXNlcklkXSA9IHVzZXJcbiAgICB9XG4gICAgcmV0dXJuIHVzZXJzT2JqXG4gIH1cbiAgcHVibGljIHN0YXRpYyBmcm9tVXNlcnNBcnJheSh1c2VyczogVHdpdHRlclVzZXJbXSk6IFR3aXR0ZXJVc2VyTWFwIHtcbiAgICByZXR1cm4gbmV3IFR3aXR0ZXJVc2VyTWFwKHVzZXJzLm1hcCgodXNlcik6IFtzdHJpbmcsIFR3aXR0ZXJVc2VyXSA9PiBbdXNlci5pZF9zdHIsIHVzZXJdKSlcbiAgfVxuICBwdWJsaWMgZmlsdGVyKGZuOiAodXNlcjogVHdpdHRlclVzZXIpID0+IGJvb2xlYW4pOiBUd2l0dGVyVXNlck1hcCB7XG4gICAgcmV0dXJuIFR3aXR0ZXJVc2VyTWFwLmZyb21Vc2Vyc0FycmF5KHRoaXMudG9Vc2VyQXJyYXkoKS5maWx0ZXIoZm4pKVxuICB9XG59XG5cbmV4cG9ydCBhYnN0cmFjdCBjbGFzcyBFdmVudEVtaXR0ZXIge1xuICBwcm90ZWN0ZWQgZXZlbnRzOiBFdmVudFN0b3JlID0ge31cbiAgb248VD4oZXZlbnROYW1lOiBzdHJpbmcsIGhhbmRsZXI6ICh0OiBUKSA9PiBhbnkpIHtcbiAgICBpZiAoIShldmVudE5hbWUgaW4gdGhpcy5ldmVudHMpKSB7XG4gICAgICB0aGlzLmV2ZW50c1tldmVudE5hbWVdID0gW11cbiAgICB9XG4gICAgdGhpcy5ldmVudHNbZXZlbnROYW1lXS5wdXNoKGhhbmRsZXIpXG4gICAgcmV0dXJuIHRoaXNcbiAgfVxuICBlbWl0PFQ+KGV2ZW50TmFtZTogc3RyaW5nLCBldmVudEhhbmRsZXJQYXJhbWV0ZXI/OiBUKSB7XG4gICAgY29uc3QgaGFuZGxlcnMgPSB0aGlzLmV2ZW50c1tldmVudE5hbWVdIHx8IFtdXG4gICAgaGFuZGxlcnMuZm9yRWFjaChoYW5kbGVyID0+IGhhbmRsZXIoZXZlbnRIYW5kbGVyUGFyYW1ldGVyKSlcbiAgICByZXR1cm4gdGhpc1xuICB9XG59XG5cbmV4cG9ydCBmdW5jdGlvbiBzbGVlcCh0aW1lOiBudW1iZXIpOiBQcm9taXNlPHZvaWQ+IHtcbiAgcmV0dXJuIG5ldyBQcm9taXNlKHJlc29sdmUgPT4gd2luZG93LnNldFRpbWVvdXQocmVzb2x2ZSwgdGltZSkpXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBpbmplY3RTY3JpcHQocGF0aDogc3RyaW5nKTogUHJvbWlzZTx2b2lkPiB7XG4gIHJldHVybiBuZXcgUHJvbWlzZShyZXNvbHZlID0+IHtcbiAgICBjb25zdCBzY3JpcHQgPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdzY3JpcHQnKVxuICAgIHNjcmlwdC5hZGRFdmVudExpc3RlbmVyKCdsb2FkJywgKCkgPT4ge1xuICAgICAgc2NyaXB0LnJlbW92ZSgpXG4gICAgICByZXNvbHZlKClcbiAgICB9KVxuICAgIHNjcmlwdC5zcmMgPSBicm93c2VyLnJ1bnRpbWUuZ2V0VVJMKHBhdGgpXG4gICAgY29uc3QgYXBwZW5kVGFyZ2V0ID0gZG9jdW1lbnQuaGVhZCB8fCBkb2N1bWVudC5kb2N1bWVudEVsZW1lbnRcbiAgICBhcHBlbmRUYXJnZXQhLmFwcGVuZENoaWxkKHNjcmlwdClcbiAgfSlcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGNvcHlGcm96ZW5PYmplY3Q8VCBleHRlbmRzIG9iamVjdD4ob2JqOiBUKTogUmVhZG9ubHk8VD4ge1xuICByZXR1cm4gT2JqZWN0LmZyZWV6ZShPYmplY3QuYXNzaWduKHt9LCBvYmopKVxufVxuXG5leHBvcnQgZnVuY3Rpb24qIGdldEFkZGVkRWxlbWVudHNGcm9tTXV0YXRpb25zKFxuICBtdXRhdGlvbnM6IE11dGF0aW9uUmVjb3JkW11cbik6IEl0ZXJhYmxlSXRlcmF0b3I8SFRNTEVsZW1lbnQ+IHtcbiAgZm9yIChjb25zdCBtdXQgb2YgbXV0YXRpb25zKSB7XG4gICAgZm9yIChjb25zdCBub2RlIG9mIG11dC5hZGRlZE5vZGVzKSB7XG4gICAgICBpZiAobm9kZSBpbnN0YW5jZW9mIEhUTUxFbGVtZW50KSB7XG4gICAgICAgIHlpZWxkIG5vZGVcbiAgICAgIH1cbiAgICB9XG4gIH1cbn1cblxuY29uc3QgdG91Y2hlZEVsZW1zID0gbmV3IFdlYWtTZXQ8SFRNTEVsZW1lbnQ+KClcbmV4cG9ydCBmdW5jdGlvbiogaXRlcmF0ZVVudG91Y2hlZEVsZW1zPFQgZXh0ZW5kcyBIVE1MRWxlbWVudD4oZWxlbXM6IEl0ZXJhYmxlPFQ+IHwgQXJyYXlMaWtlPFQ+KSB7XG4gIGZvciAoY29uc3QgZWxlbSBvZiBBcnJheS5mcm9tKGVsZW1zKSkge1xuICAgIGlmICghdG91Y2hlZEVsZW1zLmhhcyhlbGVtKSkge1xuICAgICAgdG91Y2hlZEVsZW1zLmFkZChlbGVtKVxuICAgICAgeWllbGQgZWxlbVxuICAgIH1cbiAgfVxufVxuXG4vLyBuYWl2ZSBjaGVjayBnaXZlbiBvYmplY3QgaXMgVHdpdHRlclVzZXJcbmV4cG9ydCBmdW5jdGlvbiBpc1R3aXR0ZXJVc2VyKG9iajogdW5rbm93bik6IG9iaiBpcyBUd2l0dGVyVXNlciB7XG4gIGlmICghKG9iaiAmJiB0eXBlb2Ygb2JqID09PSAnb2JqZWN0JykpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICBjb25zdCBvYmpBc0FueSA9IG9iaiBhcyBhbnlcbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5pZF9zdHIgIT09ICdzdHJpbmcnKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5zY3JlZW5fbmFtZSAhPT0gJ3N0cmluZycpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICBpZiAodHlwZW9mIG9iakFzQW55LmJsb2NraW5nICE9PSAnYm9vbGVhbicpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICBpZiAodHlwZW9mIG9iakFzQW55LmJsb2NrZWRfYnkgIT09ICdib29sZWFuJykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIHJldHVybiB0cnVlXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBpc0luTmFtZUJsYWNrbGlzdChuYW1lOiBzdHJpbmcpOiBib29sZWFuIHtcbiAgY29uc3QgbG93ZXJDYXNlZE5hbWUgPSBuYW1lLnRvTG93ZXJDYXNlKClcbiAgcmV0dXJuIFVTRVJfTkFNRV9CTEFDS0xJU1QuaW5jbHVkZXMobG93ZXJDYXNlZE5hbWUpXG59XG5cbmV4cG9ydCBmdW5jdGlvbiB2YWxpZGF0ZVR3aXR0ZXJVc2VyTmFtZSh1c2VyTmFtZTogc3RyaW5nKTogYm9vbGVhbiB7XG4gIGlmIChpc0luTmFtZUJsYWNrbGlzdCh1c2VyTmFtZSkpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICBjb25zdCBwYXR0ZXJuID0gL15bMC05YS16X117MSwxNX0kL2lcbiAgcmV0dXJuIHBhdHRlcm4udGVzdCh1c2VyTmFtZSlcbn1cblxuZXhwb3J0IGZ1bmN0aW9uIGdldFVzZXJOYW1lRnJvbVR3ZWV0VXJsKFxuICBleHRyYWN0TWU6IEhUTUxBbmNob3JFbGVtZW50IHwgVVJMIHwgTG9jYXRpb25cbik6IHN0cmluZyB8IG51bGwge1xuICBjb25zdCB7IGhvc3RuYW1lLCBwYXRobmFtZSB9ID0gZXh0cmFjdE1lXG4gIGNvbnN0IHN1cHBvcnRpbmdIb3N0bmFtZSA9IFsndHdpdHRlci5jb20nLCAnbW9iaWxlLnR3aXR0ZXIuY29tJ11cbiAgaWYgKCFzdXBwb3J0aW5nSG9zdG5hbWUuaW5jbHVkZXMoaG9zdG5hbWUpKSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxuICBjb25zdCBtYXRjaGVzID0gL15cXC8oWzAtOWEtel9dezEsMTV9KS9pLmV4ZWMocGF0aG5hbWUpXG4gIGlmICghbWF0Y2hlcykge1xuICAgIHJldHVybiBudWxsXG4gIH1cbiAgY29uc3QgbmFtZSA9IG1hdGNoZXNbMV1cbiAgaWYgKHZhbGlkYXRlVHdpdHRlclVzZXJOYW1lKG5hbWUpKSB7XG4gICAgcmV0dXJuIG5hbWVcbiAgfSBlbHNlIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG59XG4iLCJleHBvcnQgY29uc3QgVFdFRVQgPSAnTWlycm9yQmxvY2s8LVR3ZWV0J1xuZXhwb3J0IGNvbnN0IFVTRVJDRUxMID0gJ01pcnJvckJsb2NrPC1Vc2VyQ2VsbCdcbmV4cG9ydCBjb25zdCBETSA9ICdNaXJyb3JCbG9jazwtRE1Db252ZXJzYXRpb24nXG4iLCJ0eXBlIEkxOE5NZXNzYWdlcyA9IHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2tvL21lc3NhZ2VzLmpzb24nKVxudHlwZSBTdWJzdEl0ZW0gPSBudW1iZXIgfCBzdHJpbmdcbnR5cGUgU3Vic3RpdHV0aW9ucyA9IFN1YnN0SXRlbSB8IFN1YnN0SXRlbVtdIHwgdW5kZWZpbmVkXG5leHBvcnQgdHlwZSBJMThOTWVzc2FnZUtleXMgPSBrZXlvZiBJMThOTWVzc2FnZXNcblxuZXhwb3J0IGZ1bmN0aW9uIGdldE1lc3NhZ2Uoa2V5OiBzdHJpbmcgJiBJMThOTWVzc2FnZUtleXMsIHN1YnN0czogU3Vic3RpdHV0aW9ucyA9IHVuZGVmaW5lZCkge1xuICBpZiAoQXJyYXkuaXNBcnJheShzdWJzdHMpKSB7XG4gICAgcmV0dXJuIGJyb3dzZXIuaTE4bi5nZXRNZXNzYWdlKFxuICAgICAga2V5LFxuICAgICAgc3Vic3RzLm1hcChzID0+IHMudG9Mb2NhbGVTdHJpbmcoKSlcbiAgICApXG4gIH0gZWxzZSBpZiAodHlwZW9mIHN1YnN0cyA9PT0gJ251bWJlcicpIHtcbiAgICByZXR1cm4gYnJvd3Nlci5pMThuLmdldE1lc3NhZ2Uoa2V5LCBzdWJzdHMudG9Mb2NhbGVTdHJpbmcoKSlcbiAgfSBlbHNlIHtcbiAgICByZXR1cm4gYnJvd3Nlci5pMThuLmdldE1lc3NhZ2Uoa2V5LCBzdWJzdHMpXG4gIH1cbn1cblxuZnVuY3Rpb24gdHJ5R2V0TWVzc2FnZShtZXNzYWdlTmFtZTogc3RyaW5nKSB7XG4gIGNvbnN0IG1lc3NhZ2UgPSBnZXRNZXNzYWdlKG1lc3NhZ2VOYW1lIGFzIGFueSlcbiAgaWYgKCFtZXNzYWdlKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKGBpbnZhbGlkIG1lc3NhZ2VOYW1lPyBcIiR7bWVzc2FnZU5hbWV9XCJgKVxuICB9XG4gIHJldHVybiBtZXNzYWdlXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBhcHBseUkxOG5Pbkh0bWwoKSB7XG4gIGNvbnN0IGkxOG5UZXh0RWxlbWVudHMgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCdbZGF0YS1pMThuLXRleHRdJylcbiAgZm9yIChjb25zdCBlbGVtIG9mIGkxOG5UZXh0RWxlbWVudHMpIHtcbiAgICBjb25zdCBtZXNzYWdlTmFtZSA9IGVsZW0uZ2V0QXR0cmlidXRlKCdkYXRhLWkxOG4tdGV4dCcpIVxuICAgIGNvbnN0IG1lc3NhZ2UgPSB0cnlHZXRNZXNzYWdlKG1lc3NhZ2VOYW1lKVxuICAgIC8vIGNvbnNvbGUuZGVidWcoJyVvIC50ZXh0Q29udGVudCA9ICVzIFtmcm9tICVzXScsIGVsZW0sIG1lc3NhZ2UsIG1lc3NhZ2VOYW1lKVxuICAgIGVsZW0udGV4dENvbnRlbnQgPSBtZXNzYWdlXG4gIH1cbiAgY29uc3QgaTE4bkF0dHJzRWxlbWVudHMgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCdbZGF0YS1pMThuLWF0dHJzXScpXG4gIGZvciAoY29uc3QgZWxlbSBvZiBpMThuQXR0cnNFbGVtZW50cykge1xuICAgIC8vIGV4YW1wbGU6XG4gICAgLy8gPHNwYW4gZGF0YS1pMThuLWF0dHJzPVwidGl0bGU9cG9wdXBfdGl0bGUmYWx0PXBvcHVwX2FsdFwiPjwvc3Bhbj5cbiAgICBjb25zdCBhdHRyc1RvTmFtZVNlcmlhbGl6ZWQgPSBlbGVtLmdldEF0dHJpYnV0ZSgnZGF0YS1pMThuLWF0dHJzJykhXG4gICAgY29uc3QgYXR0cnNUb05hbWVQYXJzZWQgPSBuZXcgVVJMU2VhcmNoUGFyYW1zKGF0dHJzVG9OYW1lU2VyaWFsaXplZClcbiAgICBhdHRyc1RvTmFtZVBhcnNlZC5mb3JFYWNoKCh2YWx1ZSwga2V5KSA9PiB7XG4gICAgICAvLyBjb25zb2xlLmRlYnVnKCd8YXR0cnwga2V5OlwiJXNcIiwgdmFsdWU6XCIlc1wiJywga2V5LCB2YWx1ZSlcbiAgICAgIGNvbnN0IG1lc3NhZ2UgPSB0cnlHZXRNZXNzYWdlKHZhbHVlKVxuICAgICAgZWxlbS5zZXRBdHRyaWJ1dGUoa2V5LCBtZXNzYWdlKVxuICAgIH0pXG4gIH1cbn1cblxuZnVuY3Rpb24gY2hlY2tNaXNzaW5nVHJhbnNsYXRpb25zKFxuICAvLyBrby9tZXNzYWdlcy5qc29uIOyXlCDsnojqs6AgZW4vbWVzc2FnZXMuanNvbiDsl5Qg7JeG64qUIO2CpOqwgCDsnojsnLzrqbRcbiAgLy8gVHlwZVNjcmlwdCDsu7TtjIzsnbzrn6zqsIAg7YOA7J6F7JeQ65+s66W8IOydvOycvO2CqOuLpC5cbiAgLy8gdHNjb25maWcuanNvbuydmCByZXNvbHZlSnNvbk1vZHVsZSDsmLXshZjsnYQg7Lyc7JW8IO2VqFxuICBrZXlzOlxuICAgIHwgRXhjbHVkZTxcbiAgICAgICAga2V5b2YgdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMva28vbWVzc2FnZXMuanNvbicpLFxuICAgICAgICBrZXlvZiB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9lbi9tZXNzYWdlcy5qc29uJylcbiAgICAgID5cbiAgICB8IEV4Y2x1ZGU8XG4gICAgICAgIGtleW9mIHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2VuL21lc3NhZ2VzLmpzb24nKSxcbiAgICAgICAga2V5b2YgdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMva28vbWVzc2FnZXMuanNvbicpXG4gICAgICA+LFxuICBmaW5kOiAoX2tleXM6IG5ldmVyKSA9PiB2b2lkLFxuICBfY2hlY2sgPSBmaW5kKGtleXMpXG4pIHt9XG5jaGVja01pc3NpbmdUcmFuc2xhdGlvbnNcbiIsImltcG9ydCAqIGFzIGkxOG4gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvaTE4bidcblxuZXhwb3J0IGRlZmF1bHQgY2xhc3MgQmFkZ2Uge1xuICBwcml2YXRlIHJlYWRvbmx5IGJhZGdlZEF0dHIgPSAnZGF0YS1taXJyb3JibG9jay1iYWRnZWQnXG4gIHByaXZhdGUgcmVhZG9ubHkgYmFzZUVsZW0gPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdzcGFuJylcbiAgY29uc3RydWN0b3IocHJpdmF0ZSB1c2VyOiBUd2l0dGVyVXNlcikge1xuICAgIGNvbnN0IHVzZXJOYW1lID0gdXNlci5zY3JlZW5fbmFtZVxuICAgIHRoaXMuYmFzZUVsZW0uY2xhc3NOYW1lID0gJ21vYi1iYWRnZSdcbiAgICB0aGlzLmJhc2VFbGVtLnN0eWxlLndoaXRlU3BhY2UgPSAnaW5pdGlhbCdcbiAgICB0aGlzLmJhc2VFbGVtLmlubmVySFRNTCA9IGBcXFxuPHNwYW4gY2xhc3M9XCJiYWRnZS13cmFwcGVyXCI+XG4gIDxzcGFuIGNsYXNzPVwiYmFkZ2UgYmxvY2tzLXlvdVwiPlxuICAgICR7aTE4bi5nZXRNZXNzYWdlKCdibG9ja3NfeW91Jyl9XG4gICAgPHNwYW4gaGlkZGVuIGNsYXNzPVwiYmFkZ2UtdXNlcm5hbWVcIj48L3NwYW4+XG4gIDwvc3Bhbj5cbiAgPHNwYW4gaGlkZGVuIGNsYXNzPVwiYmFkZ2UgYmxvY2stcmVmbGVjdGVkXCI+XG4gICAgJHtpMThuLmdldE1lc3NhZ2UoJ2Jsb2NrX3JlZmxlY3RlZCcpfVxuICA8L3NwYW4+XG48L3NwYW4+YFxuICAgIHRoaXMuYmFzZUVsZW1cbiAgICAgIC5xdWVyeVNlbGVjdG9yKCcuYmFkZ2UuYmxvY2tzLXlvdScpIVxuICAgICAgLnNldEF0dHJpYnV0ZSgndGl0bGUnLCBpMThuLmdldE1lc3NhZ2UoJ2Jsb2Nrc195b3VfZGVzY3JpcHRpb24nLCB1c2VyTmFtZSkpXG4gICAgdGhpcy5iYXNlRWxlbVxuICAgICAgLnF1ZXJ5U2VsZWN0b3IoJy5iYWRnZS5ibG9jay1yZWZsZWN0ZWQnKSFcbiAgICAgIC5zZXRBdHRyaWJ1dGUoJ3RpdGxlJywgaTE4bi5nZXRNZXNzYWdlKCdibG9ja19yZWZsZWN0ZWRfZGVzY3JpcHRpb24nLCB1c2VyTmFtZSkpXG4gIH1cblxuICBwdWJsaWMgc2hvd1VzZXJOYW1lKCkge1xuICAgIGNvbnN0IG5hbWUgPSB0aGlzLnVzZXIuc2NyZWVuX25hbWVcbiAgICBjb25zdCB1c2VyTmFtZUVsZW0gPSB0aGlzLmJhc2VFbGVtLnF1ZXJ5U2VsZWN0b3I8SFRNTEVsZW1lbnQ+KCcuYmFkZ2UtdXNlcm5hbWUnKSFcbiAgICB1c2VyTmFtZUVsZW0udGV4dENvbnRlbnQgPSBgKEAke25hbWV9KWBcbiAgICB1c2VyTmFtZUVsZW0uaGlkZGVuID0gZmFsc2VcbiAgfVxuICBwdWJsaWMgYmxvY2tSZWZsZWN0ZWQoKSB7XG4gICAgY29uc3QgYnJCYWRnZSA9IHRoaXMuYmFzZUVsZW0ucXVlcnlTZWxlY3RvcjxIVE1MRWxlbWVudD4oJy5ibG9jay1yZWZsZWN0ZWRbaGlkZGVuXScpIVxuICAgIGJyQmFkZ2UuaGlkZGVuID0gZmFsc2VcbiAgfVxuICBwdWJsaWMgYXR0YWNoQWZ0ZXIodGFyZ2V0RWxlbTogRWxlbWVudCk6IHZvaWQge1xuICAgIGlmICghdGFyZ2V0RWxlbS5oYXNBdHRyaWJ1dGUodGhpcy5iYWRnZWRBdHRyKSkge1xuICAgICAgdGFyZ2V0RWxlbS5hZnRlcih0aGlzLmJhc2VFbGVtKVxuICAgICAgdGFyZ2V0RWxlbS5zZXRBdHRyaWJ1dGUodGhpcy5iYWRnZWRBdHRyLCAnMScpXG4gICAgfVxuICB9XG4gIHB1YmxpYyBhcHBlbmRUbyh0YXJnZXRFbGVtOiBFbGVtZW50KTogdm9pZCB7XG4gICAgaWYgKCF0YXJnZXRFbGVtLmhhc0F0dHJpYnV0ZSh0aGlzLmJhZGdlZEF0dHIpKSB7XG4gICAgICB0YXJnZXRFbGVtLmFwcGVuZENoaWxkKHRoaXMuYmFzZUVsZW0pXG4gICAgICB0YXJnZXRFbGVtLnNldEF0dHJpYnV0ZSh0aGlzLmJhZGdlZEF0dHIsICcxJylcbiAgICB9XG4gIH1cbn1cbiIsImltcG9ydCAqIGFzIFV0aWxzIGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL2NvbW1vbidcbmltcG9ydCAqIGFzIFR3aXR0ZXJBUEkgZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvdHdpdHRlci1hcGknXG5pbXBvcnQgeyByZWZsZWN0QmxvY2sgfSBmcm9tICcuL21pcnJvcmJsb2NrLXInXG5pbXBvcnQgeyBTdG9yZVJldHJpZXZlciwgU3RvcmVVcGRhdGVyLCBVc2VyR2V0dGVyIH0gZnJvbSAnLi9yZWR1eC1zdG9yZSdcbmltcG9ydCAqIGFzIEV2ZW50TmFtZXMgZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvZXZlbnQtbmFtZXMnXG5cbmZ1bmN0aW9uIG1hcmtPdXRsaW5lKGVsZW06IEVsZW1lbnQpOiB2b2lkIHtcbiAgZWxlbS5zZXRBdHRyaWJ1dGUoJ2RhdGEtbWlycm9yYmxvY2stYmxvY2tzLXlvdScsICcxJylcbn1cblxuZnVuY3Rpb24gZ2V0RWxlbUJ5RG1EYXRhKGRtRGF0YTogRE1EYXRhKTogSFRNTEVsZW1lbnQgfCBudWxsIHtcbiAgcmV0dXJuIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoYFtkYXRhLW1pcnJvcmJsb2NrLWNvbnZlcnNhdGlvbi1pZD1cIiR7ZG1EYXRhLmNvbnZlcnNhdGlvbl9pZH1cIl1gKVxufVxuXG5hc3luYyBmdW5jdGlvbiBkZXRlY3RQcm9maWxlKHJvb3RFbGVtOiBIVE1MRWxlbWVudCkge1xuICBjb25zdCBoZWxwTGlua3MgPSByb290RWxlbS5xdWVyeVNlbGVjdG9yQWxsPEhUTUxFbGVtZW50PihcbiAgICAnYVtocmVmPVwiaHR0cHM6Ly9zdXBwb3J0LnR3aXR0ZXIuY29tL2FydGljbGVzLzIwMTcyMDYwXCJdJ1xuICApXG4gIGNvbnN0IGhlbHBMaW5rID0gQXJyYXkuZnJvbShVdGlscy5pdGVyYXRlVW50b3VjaGVkRWxlbXMoaGVscExpbmtzKSkuc2hpZnQoKVxuICBpZiAoIWhlbHBMaW5rKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgY29uc3QgdXNlck5hbWUgPSBVdGlscy5nZXRVc2VyTmFtZUZyb21Ud2VldFVybChsb2NhdGlvbilcbiAgaWYgKCF1c2VyTmFtZSkge1xuICAgIHJldHVyblxuICB9XG4gIC8vIGNvbnN0IHVzZXIgPSBTdG9yZVJldHJpZXZlci5nZXRVc2VyQnlOYW1lKHVzZXJOYW1lKVxuICBjb25zdCB1c2VyID0gYXdhaXQgVHdpdHRlckFQSS5nZXRTaW5nbGVVc2VyQnlOYW1lKHVzZXJOYW1lKVxuICBpZiAoIXVzZXIpIHtcbiAgICByZXR1cm5cbiAgfVxuICByZWZsZWN0QmxvY2soe1xuICAgIHVzZXIsXG4gICAgaW5kaWNhdGVCbG9jayhiYWRnZSkge1xuICAgICAgYmFkZ2UuYXBwZW5kVG8oaGVscExpbmsucGFyZW50RWxlbWVudCEpXG4gICAgfSxcbiAgICBpbmRpY2F0ZVJlZmxlY3Rpb24oYmFkZ2UpIHtcbiAgICAgIGJhZGdlLmJsb2NrUmVmbGVjdGVkKClcbiAgICAgIFN0b3JlVXBkYXRlci5hZnRlckJsb2NrVXNlcih1c2VyKVxuICAgIH0sXG4gIH0pXG59XG5cbmZ1bmN0aW9uIGZpbmRFbGVtZW50VG9JbmRpY2F0ZVF1b3RlZFR3ZWV0RnJvbUJsb2NrZWRVc2VyKFxuICB0d2VldEVsZW06IEhUTUxFbGVtZW50LFxuICBxdW90ZWRUd2VldFVybDogVVJMXG4pIHtcbiAgY29uc3QgYXJ0aWNsZSA9IHR3ZWV0RWxlbS5jbG9zZXN0KCdhcnRpY2xlW3JvbGU9YXJ0aWNsZV0nKSFcbiAgY29uc3QgcXVvdGVkVHdlZXRJblRpbWVsaW5lID0gdHdlZXRFbGVtLnF1ZXJ5U2VsZWN0b3IoJ1tkYXRhLXRlc3RpZD10d2VldF0gW2RhdGEtdGVzdGlkPXR3ZWV0XScpXG4gIGNvbnN0IHF1b3RlZFR3ZWV0SW5EZXRhaWwgPSBhcnRpY2xlLnF1ZXJ5U2VsZWN0b3IoJ2FydGljbGUgYXJ0aWNsZSBbZGF0YS10ZXN0aWQ9dHdlZXRdJylcbiAgY29uc3QgcXVvdGVkVHdlZXQgPSBxdW90ZWRUd2VldEluVGltZWxpbmUgfHwgcXVvdGVkVHdlZXRJbkRldGFpbFxuICBpZiAocXVvdGVkVHdlZXQpIHtcbiAgICBjb25zdCBxdW90ZWRUd2VldElubmVyTWVzc2FnZSA9IHF1b3RlZFR3ZWV0LnF1ZXJ5U2VsZWN0b3IoJ1tkaXI9YXV0b10nKVxuICAgIHJldHVybiBxdW90ZWRUd2VldElubmVyTWVzc2FnZSB8fCBxdW90ZWRUd2VldFxuICB9IGVsc2Uge1xuICAgIHJldHVybiBhcnRpY2xlLnF1ZXJ5U2VsZWN0b3IoYGFbaHJlZl49XCIke3F1b3RlZFR3ZWV0VXJsLnBhdGhuYW1lfVwiIGldYCkhXG4gIH1cbn1cblxuYXN5bmMgZnVuY3Rpb24gaGFuZGxlUXVvdGVkVHdlZXQodHdlZXQ6IFR3ZWV0LCB0d2VldEVsZW06IEhUTUxFbGVtZW50KSB7XG4gIGlmICghdHdlZXQuaXNfcXVvdGVfc3RhdHVzKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgY29uc3QgcGVybWFsaW5rT2JqZWN0ID0gdHdlZXQucXVvdGVkX3N0YXR1c19wZXJtYWxpbmtcbiAgaWYgKCFwZXJtYWxpbmtPYmplY3QpIHtcbiAgICByZXR1cm5cbiAgfVxuICBjb25zdCBxVXJsU3RyaW5nID0gcGVybWFsaW5rT2JqZWN0LmV4cGFuZGVkXG4gIGNvbnN0IHFVcmwgPSBuZXcgVVJMKHFVcmxTdHJpbmcpXG4gIC8vIOuTnOusvOqyjCDsnbjsmqkg7Yq47JyXIOyjvOyGjOqwgCB0LmNvIOunge2BrOydvCDqsr3smrDrj4Qg7J6I642U6528LlxuICBpZiAocVVybC5ob3N0bmFtZSA9PT0gJ3QuY28nKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgY29uc3QgcXVvdGVkVXNlck5hbWUgPSBVdGlscy5nZXRVc2VyTmFtZUZyb21Ud2VldFVybChxVXJsKSFcbiAgY29uc3QgcXVvdGVkVXNlciA9IGF3YWl0IFVzZXJHZXR0ZXIuZ2V0VXNlckJ5TmFtZShxdW90ZWRVc2VyTmFtZSwgdHJ1ZSlcbiAgaWYgKCFxdW90ZWRVc2VyKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgcmVmbGVjdEJsb2NrKHtcbiAgICB1c2VyOiBxdW90ZWRVc2VyLFxuICAgIGluZGljYXRlQmxvY2soYmFkZ2UpIHtcbiAgICAgIGNvbnN0IGluZGljYXRlTWUgPSBmaW5kRWxlbWVudFRvSW5kaWNhdGVRdW90ZWRUd2VldEZyb21CbG9ja2VkVXNlcih0d2VldEVsZW0sIHFVcmwpXG4gICAgICBtYXJrT3V0bGluZShpbmRpY2F0ZU1lKVxuICAgICAgYmFkZ2UuYXR0YWNoQWZ0ZXIoaW5kaWNhdGVNZSlcbiAgICB9LFxuICAgIGluZGljYXRlUmVmbGVjdGlvbihiYWRnZSkge1xuICAgICAgYmFkZ2UuYmxvY2tSZWZsZWN0ZWQoKVxuICAgICAgU3RvcmVVcGRhdGVyLmFmdGVyQmxvY2tVc2VyKHF1b3RlZFVzZXIpXG4gICAgfSxcbiAgfSlcbn1cblxuYXN5bmMgZnVuY3Rpb24gaGFuZGxlTWVudGlvbnNJblR3ZWV0KHR3ZWV0OiBUd2VldCwgdHdlZXRFbGVtOiBIVE1MRWxlbWVudCkge1xuICBjb25zdCBtZW50aW9uZWRVc2VyRW50aXRpZXMgPSB0d2VldC5lbnRpdGllcy51c2VyX21lbnRpb25zIHx8IFtdXG4gIGlmIChtZW50aW9uZWRVc2VyRW50aXRpZXMubGVuZ3RoIDw9IDApIHtcbiAgICByZXR1cm5cbiAgfVxuICBjb25zdCBhcnRpY2xlID0gdHdlZXRFbGVtLmNsb3Nlc3QoJ2FydGljbGVbcm9sZT1hcnRpY2xlXScpIVxuICBjb25zdCBsaW5rcyA9IEFycmF5LmZyb20oYXJ0aWNsZS5xdWVyeVNlbGVjdG9yQWxsPEhUTUxBbmNob3JFbGVtZW50PignYVtyb2xlPWxpbmtdW2hyZWZePVwiL1wiXScpKVxuICBjb25zdCBtZW50aW9uRWxlbXNNYXAgPSBuZXcgTWFwPHN0cmluZywgSFRNTEFuY2hvckVsZW1lbnRbXT4oXG4gICAgbWVudGlvbmVkVXNlckVudGl0aWVzXG4gICAgICAubWFwKGVudCA9PiBlbnQuc2NyZWVuX25hbWUudG9Mb3dlckNhc2UoKSlcbiAgICAgIC5tYXAoKGxvd2VyZWROYW1lKTogW3N0cmluZywgSFRNTEFuY2hvckVsZW1lbnRbXV0gPT4gW1xuICAgICAgICBsb3dlcmVkTmFtZSxcbiAgICAgICAgbGlua3MuZmlsdGVyKGEgPT4gYS5wYXRobmFtZS50b0xvd2VyQ2FzZSgpID09PSBgLyR7bG93ZXJlZE5hbWV9YCksXG4gICAgICBdKVxuICApXG4gIGNvbnN0IG92ZXJmbG93ZWQgPSBhcnRpY2xlLnF1ZXJ5U2VsZWN0b3IoJ2FbYXJpYS1sYWJlbF1baHJlZiQ9XCIvcGVvcGxlXCJdJylcbiAgY29uc3QgbWVudGlvbmVkVXNlcnNNYXAgPSBhd2FpdCBVc2VyR2V0dGVyLmdldE11bHRpcGxlVXNlcnNCeUlkKFxuICAgIG1lbnRpb25lZFVzZXJFbnRpdGllcy5tYXAodSA9PiB1LmlkX3N0cilcbiAgKVxuICBmb3IgKGNvbnN0IG1Vc2VyIG9mIG1lbnRpb25lZFVzZXJzTWFwLnZhbHVlcygpKSB7XG4gICAgYXdhaXQgcmVmbGVjdEJsb2NrKHtcbiAgICAgIHVzZXI6IG1Vc2VyLFxuICAgICAgaW5kaWNhdGVCbG9jayhiYWRnZSkge1xuICAgICAgICBjb25zdCBsb3dlcmVkTmFtZSA9IG1Vc2VyLnNjcmVlbl9uYW1lLnRvTG93ZXJDYXNlKClcbiAgICAgICAgY29uc3QgbWVudGlvbkVsZW1zID0gbWVudGlvbkVsZW1zTWFwLmdldChsb3dlcmVkTmFtZSkhXG4gICAgICAgIGlmIChtZW50aW9uRWxlbXMubGVuZ3RoID4gMCkge1xuICAgICAgICAgIG1lbnRpb25FbGVtcy5mb3JFYWNoKGVsID0+IHtcbiAgICAgICAgICAgIG1hcmtPdXRsaW5lKGVsKVxuICAgICAgICAgICAgYmFkZ2UuYXR0YWNoQWZ0ZXIoZWwpXG4gICAgICAgICAgfSlcbiAgICAgICAgfSBlbHNlIGlmIChvdmVyZmxvd2VkKSB7XG4gICAgICAgICAgbWFya091dGxpbmUob3ZlcmZsb3dlZClcbiAgICAgICAgICBiYWRnZS5zaG93VXNlck5hbWUoKVxuICAgICAgICAgIGJhZGdlLmF0dGFjaEFmdGVyKG92ZXJmbG93ZWQpXG4gICAgICAgIH1cbiAgICAgIH0sXG4gICAgICBpbmRpY2F0ZVJlZmxlY3Rpb24oYmFkZ2UpIHtcbiAgICAgICAgYmFkZ2UuYmxvY2tSZWZsZWN0ZWQoKVxuICAgICAgICBTdG9yZVVwZGF0ZXIuYWZ0ZXJCbG9ja1VzZXIobVVzZXIpXG4gICAgICB9LFxuICAgIH0pXG4gIH1cbn1cblxuYXN5bmMgZnVuY3Rpb24gaGFuZGxlVXNlckNlbGxzKHVzZXI6IFR3aXR0ZXJVc2VyLCBlbGVtOiBIVE1MRWxlbWVudCkge1xuICByZWZsZWN0QmxvY2soe1xuICAgIHVzZXIsXG4gICAgaW5kaWNhdGVCbG9jayhiYWRnZSkge1xuICAgICAgbWFya091dGxpbmUoZWxlbSlcbiAgICAgIGNvbnN0IGJhZGdlVGFyZ2V0ID0gZWxlbS5xdWVyeVNlbGVjdG9yKCdkaXZbZGlyPWx0cl0nKSFcbiAgICAgIGJhZGdlLmF0dGFjaEFmdGVyKGJhZGdlVGFyZ2V0KVxuICAgIH0sXG4gICAgaW5kaWNhdGVSZWZsZWN0aW9uKGJhZGdlKSB7XG4gICAgICBiYWRnZS5ibG9ja1JlZmxlY3RlZCgpXG4gICAgICBTdG9yZVVwZGF0ZXIuYWZ0ZXJCbG9ja1VzZXIodXNlcilcbiAgICB9LFxuICB9KVxufVxuXG5hc3luYyBmdW5jdGlvbiBoYW5kbGVETUNvbnZlcnNhdGlvbihjb252SWQ6IHN0cmluZykge1xuICBjb25zdCBkbURhdGEgPSBhd2FpdCBTdG9yZVJldHJpZXZlci5nZXRETURhdGEoY29udklkKVxuICBpZiAoIWRtRGF0YSkge1xuICAgIHRocm93IG5ldyBFcnJvcigndW5yZWFjaGFibGUnKVxuICB9XG4gIGlmICghZG1EYXRhLnJlYWRfb25seSkge1xuICAgIHJldHVyblxuICB9XG4gIGNvbnN0IGVsZW0gPSBnZXRFbGVtQnlEbURhdGEoZG1EYXRhKSFcbiAgY29uc3QgYmFkZ2VUYXJnZXQgPSBlbGVtLnF1ZXJ5U2VsZWN0b3IoJ2RpdltkaXI9bHRyXScpIVxuICBjb25zdCBwYXJ0aWNpcGFudHMgPSBhd2FpdCBVc2VyR2V0dGVyLmdldE11bHRpcGxlVXNlcnNCeUlkKFxuICAgIGRtRGF0YS5wYXJ0aWNpcGFudHMubWFwKHBhciA9PiBwYXIudXNlcl9pZClcbiAgKVxuICBjb25zdCBibG9ja2VkTWUgPSBwYXJ0aWNpcGFudHMuZmlsdGVyKHVzZXIgPT4gISF1c2VyLmJsb2NrZWRfYnkpXG4gIGlmIChibG9ja2VkTWUuc2l6ZSA8PSAwKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgZm9yIChjb25zdCB1c2VyVG9CbG9jayBvZiBibG9ja2VkTWUudmFsdWVzKCkpIHtcbiAgICBhd2FpdCByZWZsZWN0QmxvY2soe1xuICAgICAgdXNlcjogdXNlclRvQmxvY2ssXG4gICAgICBpbmRpY2F0ZUJsb2NrKGJhZGdlKSB7XG4gICAgICAgIG1hcmtPdXRsaW5lKGVsZW0pXG4gICAgICAgIGlmIChkbURhdGEudHlwZSA9PT0gJ0dST1VQX0RNJykge1xuICAgICAgICAgIGJhZGdlLnNob3dVc2VyTmFtZSgpXG4gICAgICAgIH1cbiAgICAgICAgYmFkZ2UuYXBwZW5kVG8oYmFkZ2VUYXJnZXQpXG4gICAgICB9LFxuICAgICAgaW5kaWNhdGVSZWZsZWN0aW9uKGJhZGdlKSB7XG4gICAgICAgIGJhZGdlLmJsb2NrUmVmbGVjdGVkKClcbiAgICAgICAgU3RvcmVVcGRhdGVyLmFmdGVyQmxvY2tVc2VyKHVzZXJUb0Jsb2NrKVxuICAgICAgfSxcbiAgICB9KVxuICB9XG59XG5cbmZ1bmN0aW9uKiBQcm9taXNlc1F1ZXVlKCkge1xuICBsZXQgcHJvbWlzZSA9IFByb21pc2UucmVzb2x2ZSgpXG4gIHdoaWxlICgocHJvbWlzZSA9IHByb21pc2UudGhlbih5aWVsZCkpKTtcbn1cblxuY29uc3QgcHJvbWlzZXNRdWV1ZSA9IFByb21pc2VzUXVldWUoKVxuLy8gdGhlIGZpcnN0IGNhbGwgb2YgbmV4dCBleGVjdXRlcyBmcm9tIHRoZSBzdGFydCBvZiB0aGUgZnVuY3Rpb25cbi8vIHVudGlsIHRoZSBmaXJzdCB5aWVsZCBzdGF0ZW1lbnRcbnByb21pc2VzUXVldWUubmV4dCgpXG5cbmZ1bmN0aW9uIHN0YXJ0T2JzZXJ2ZShyZWFjdFJvb3Q6IEhUTUxFbGVtZW50KTogdm9pZCB7XG4gIG5ldyBNdXRhdGlvbk9ic2VydmVyKG11dGF0aW9ucyA9PiB7XG4gICAgZm9yIChjb25zdCBlbGVtIG9mIFV0aWxzLmdldEFkZGVkRWxlbWVudHNGcm9tTXV0YXRpb25zKG11dGF0aW9ucykpIHtcbiAgICAgIGRldGVjdFByb2ZpbGUoZWxlbSlcbiAgICB9XG4gIH0pLm9ic2VydmUocmVhY3RSb290LCB7XG4gICAgc3VidHJlZTogdHJ1ZSxcbiAgICBjaGlsZExpc3Q6IHRydWUsXG4gIH0pXG4gIGRvY3VtZW50LmFkZEV2ZW50TGlzdGVuZXIoRXZlbnROYW1lcy5VU0VSQ0VMTCwgZXZlbnQgPT4ge1xuICAgIGNvbnN0IGN1c3RvbUV2ZW50ID0gZXZlbnQgYXMgQ3VzdG9tRXZlbnRcbiAgICBjb25zdCBlbGVtID0gY3VzdG9tRXZlbnQudGFyZ2V0IGFzIEhUTUxFbGVtZW50XG4gICAgY29uc3QgeyB1c2VyIH0gPSBjdXN0b21FdmVudC5kZXRhaWxcbiAgICBoYW5kbGVVc2VyQ2VsbHModXNlciwgZWxlbSlcbiAgfSlcbiAgZG9jdW1lbnQuYWRkRXZlbnRMaXN0ZW5lcihFdmVudE5hbWVzLkRNLCBldmVudCA9PiB7XG4gICAgY29uc3QgY3VzdG9tRXZlbnQgPSBldmVudCBhcyBDdXN0b21FdmVudDx7IGNvbnZJZDogc3RyaW5nIH0+XG4gICAgY29uc3QgeyBjb252SWQgfSA9IGN1c3RvbUV2ZW50LmRldGFpbFxuICAgIGhhbmRsZURNQ29udmVyc2F0aW9uKGNvbnZJZClcbiAgfSlcbiAgZG9jdW1lbnQuYWRkRXZlbnRMaXN0ZW5lcihFdmVudE5hbWVzLlRXRUVULCBldmVudCA9PiB7XG4gICAgY29uc3QgY3VzdG9tRXZlbnQgPSBldmVudCBhcyBDdXN0b21FdmVudFxuICAgIGNvbnN0IGVsZW0gPSBjdXN0b21FdmVudC50YXJnZXQgYXMgSFRNTEVsZW1lbnRcbiAgICBjb25zdCB7IHR3ZWV0IH0gPSBjdXN0b21FdmVudC5kZXRhaWxcbiAgICBwcm9taXNlc1F1ZXVlLm5leHQoKCkgPT4gaGFuZGxlTWVudGlvbnNJblR3ZWV0KHR3ZWV0LCBlbGVtKSlcbiAgICBwcm9taXNlc1F1ZXVlLm5leHQoKCkgPT4gaGFuZGxlUXVvdGVkVHdlZXQodHdlZXQsIGVsZW0pKVxuICB9KVxufVxuYXN5bmMgZnVuY3Rpb24gaXNMb2dnZWRJbigpOiBQcm9taXNlPGJvb2xlYW4+IHtcbiAgdHJ5IHtcbiAgICBjb25zdCBzY3JpcHRzID0gQXJyYXkuZnJvbShkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCdzY3JpcHQ6bm90KFtzcmNdKScpKVxuICAgIGNvbnN0IHJlc3VsdCA9IHNjcmlwdHNcbiAgICAgIC5tYXAoc2NyaXB0ID0+IC9cImlzTG9nZ2VkSW5cIjoodHJ1ZXxmYWxzZSkvLmV4ZWMoc2NyaXB0LmlubmVySFRNTCkpXG4gICAgICAuZmlsdGVyKG4gPT4gISFuKVxuICAgICAgLnBvcCgpIVxuICAgICAgLnBvcCgpXG4gICAgcmV0dXJuIHJlc3VsdCA9PT0gJ3RydWUnXG4gIH0gY2F0Y2ggKGVycikge1xuICAgIGNvbnNvbGUud2Fybignd2FybmluZy4gbG9naW4tY2hlY2sgbG9naWMgc2hvdWxkIHVwZGF0ZS4nKVxuICAgIGNvbnNvbGUud2FybignZXJyb3I6ICVvJywgZXJyKVxuICAgIGNvbnN0IGNoZWNrVmlhQVBJID0gYXdhaXQgVHdpdHRlckFQSS5nZXRNeXNlbGYoKS5jYXRjaCgoKSA9PiBudWxsKVxuICAgIHJldHVybiAhIWNoZWNrVmlhQVBJXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGRldGVjdE9uQ3VycmVudFR3aXR0ZXIocmVhY3RSb290OiBIVE1MRWxlbWVudCkge1xuICBjb25zdCBsb2dnZWRJbiA9IGF3YWl0IGlzTG9nZ2VkSW4oKVxuICBpZiAoIWxvZ2dlZEluKSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgYXdhaXQgVXRpbHMuaW5qZWN0U2NyaXB0KCdidW5kbGVkL3R3aXR0ZXJfaW5qZWN0LmJ1bi5qcycpXG4gIHN0YXJ0T2JzZXJ2ZShyZWFjdFJvb3QpXG59XG4iLCJpbXBvcnQgKiBhcyBPcHRpb25zIGZyb20gJ+uvuOufrOu4lOudvS9leHRvcHRpb24nXG5pbXBvcnQgKiBhcyBUd2l0dGVyQVBJIGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL3R3aXR0ZXItYXBpJ1xuaW1wb3J0IEJhZGdlIGZyb20gJy4vbWlycm9yYmxvY2stYmFkZ2UnXG5cbmludGVyZmFjZSBSZWZsZWN0aW9uT3B0aW9ucyB7XG4gIHVzZXI6IFR3aXR0ZXJVc2VyXG4gIGluZGljYXRlQmxvY2s6IChiYWRnZTogQmFkZ2UpID0+IHZvaWRcbiAgaW5kaWNhdGVSZWZsZWN0aW9uOiAoYmFkZ2U6IEJhZGdlKSA9PiB2b2lkXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiByZWZsZWN0QmxvY2soe1xuICB1c2VyLFxuICBpbmRpY2F0ZUJsb2NrLFxuICBpbmRpY2F0ZVJlZmxlY3Rpb24sXG59OiBSZWZsZWN0aW9uT3B0aW9ucyk6IFByb21pc2U8dm9pZD4ge1xuICAvLyBSZWR1eCBzdG9yZeyXkOyEnCDqurzrgrTsmKgg7Jyg7KCAIOqwnOyytOyXkCBibG9ja2VkX2J56rCAIOu5oOyguOyeiOuKlCDqsr3smrDqsIAg7J6I642U6528LlxuICBpZiAodHlwZW9mIHVzZXIuYmxvY2tlZF9ieSAhPT0gJ2Jvb2xlYW4nKSB7XG4gICAgY29uc3QgdXNlckZyb21BUEkgPSBhd2FpdCBUd2l0dGVyQVBJLmdldFNpbmdsZVVzZXJCeUlkKHVzZXIuaWRfc3RyKVxuICAgIGlmICh0eXBlb2YgdXNlckZyb21BUEkuYmxvY2tlZF9ieSAhPT0gJ2Jvb2xlYW4nKSB7XG4gICAgICB0aHJvdyBuZXcgRXJyb3IoJ3VuZXhwZWN0ZWQ6IHN0aWxsIG5vIGJsb2NrZWRfYnkgcHJvcGVydHknKVxuICAgIH1cbiAgICByZXR1cm4gcmVmbGVjdEJsb2NrKHsgdXNlcjogdXNlckZyb21BUEksIGluZGljYXRlQmxvY2ssIGluZGljYXRlUmVmbGVjdGlvbiB9KVxuICB9XG4gIGlmICghdXNlci5ibG9ja2VkX2J5KSB7XG4gICAgcmV0dXJuXG4gIH1cbiAgY29uc3QgYmFkZ2UgPSBuZXcgQmFkZ2UodXNlcilcbiAgaW5kaWNhdGVCbG9jayhiYWRnZSlcbiAgY29uc3QgZXh0T3B0aW9ucyA9IGF3YWl0IE9wdGlvbnMubG9hZCgpXG4gIGNvbnN0IG11dGVTa2lwID0gdXNlci5tdXRpbmcgJiYgIWV4dE9wdGlvbnMuYmxvY2tNdXRlZFVzZXJcbiAgY29uc3Qgc2hvdWxkQmxvY2sgPSBleHRPcHRpb25zLmVuYWJsZUJsb2NrUmVmbGVjdGlvbiAmJiAhbXV0ZVNraXAgJiYgIXVzZXIuYmxvY2tpbmdcbiAgaWYgKHNob3VsZEJsb2NrKSB7XG4gICAgY29uc3QgYmxvY2tSZXN1bHQgPSBhd2FpdCBUd2l0dGVyQVBJLmJsb2NrVXNlcih1c2VyKS5jYXRjaChlcnIgPT4ge1xuICAgICAgY29uc29sZS5lcnJvcihlcnIpXG4gICAgICByZXR1cm4gZmFsc2VcbiAgICB9KVxuICAgIGlmIChibG9ja1Jlc3VsdCkge1xuICAgICAgaW5kaWNhdGVSZWZsZWN0aW9uKGJhZGdlKVxuICAgIH1cbiAgfVxufVxuIiwiLy8gaW1wb3J0IHsgVHdpdHRlclVzZXJNYXAsIGlzVHdpdHRlclVzZXIgfSBmcm9tICfrr7jrn6zruJTrnb0vc2NyaXB0cy9jb21tb24nXG4vLyBpbXBvcnQgKiBhcyBUd2l0dGVyQVBJIGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL3R3aXR0ZXItYXBpJ1xuXG5leHBvcnQgKiBhcyBTdG9yZVVwZGF0ZXIgZnJvbSAnLi9yZWR1eC1zdG9yZS91cGRhdGVyJ1xuZXhwb3J0ICogYXMgU3RvcmVSZXRyaWV2ZXIgZnJvbSAnLi9yZWR1eC1zdG9yZS9yZXRyaWV2ZXInXG5leHBvcnQgKiBhcyBVc2VyR2V0dGVyIGZyb20gJy4vcmVkdXgtc3RvcmUvdXNlci1nZXR0ZXInXG4iLCJpbXBvcnQgeyBjbG9uZURldGFpbCB9IGZyb20gJy4vdXBkYXRlcidcblxuYXN5bmMgZnVuY3Rpb24gdHJpZ2dlclBhZ2VFdmVudFdpdGhSZXNwb25zZShcbiAgZXZlbnROYW1lOiBSZWR1eFN0b3JlRXZlbnROYW1lcyxcbiAgZXZlbnREZXRhaWw/OiBvYmplY3Rcbik6IFByb21pc2U8YW55PiB7XG4gIGNvbnN0IGRldGFpbCA9IGNsb25lRGV0YWlsKGV2ZW50RGV0YWlsKVxuICBjb25zdCBub25jZSA9IE1hdGgucmFuZG9tKClcbiAgT2JqZWN0LmFzc2lnbihkZXRhaWwsIHtcbiAgICBub25jZSxcbiAgfSlcbiAgY29uc3QgcmVxdWVzdEV2ZW50ID0gbmV3IEN1c3RvbUV2ZW50KGBNaXJyb3JCbG9jay0tPiR7ZXZlbnROYW1lfWAsIHtcbiAgICBkZXRhaWwsXG4gIH0pXG4gIHJldHVybiBuZXcgUHJvbWlzZSgocmVzb2x2ZSwgcmVqZWN0KSA9PiB7XG4gICAgbGV0IHRpbWVvdXRlZCA9IGZhbHNlXG4gICAgY29uc3QgdGltZW91dCA9IHdpbmRvdy5zZXRUaW1lb3V0KCgpID0+IHtcbiAgICAgIHRpbWVvdXRlZCA9IHRydWVcbiAgICAgIHJlamVjdCgndGltZW91dCEnKVxuICAgIH0sIDEwMDAwKVxuICAgIGRvY3VtZW50LmFkZEV2ZW50TGlzdGVuZXIoXG4gICAgICBgTWlycm9yQmxvY2s8LS0ke2V2ZW50TmFtZX0uJHtub25jZX1gLFxuICAgICAgZXZlbnQgPT4ge1xuICAgICAgICB3aW5kb3cuY2xlYXJUaW1lb3V0KHRpbWVvdXQpXG4gICAgICAgIGlmICh0aW1lb3V0ZWQpIHtcbiAgICAgICAgICByZXR1cm5cbiAgICAgICAgfVxuICAgICAgICBjb25zdCBjdXN0b21FdmVudCA9IGV2ZW50IGFzIEN1c3RvbUV2ZW50XG4gICAgICAgIHJlc29sdmUoY3VzdG9tRXZlbnQuZGV0YWlsKVxuICAgICAgfSxcbiAgICAgIHsgb25jZTogdHJ1ZSB9XG4gICAgKVxuICAgIGRvY3VtZW50LmRpc3BhdGNoRXZlbnQocmVxdWVzdEV2ZW50KVxuICB9KVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0TXVsdGlwbGVVc2Vyc0J5SWRzKHVzZXJJZHM6IHN0cmluZ1tdKTogUHJvbWlzZTxUd2l0dGVyVXNlckVudGl0aWVzPiB7XG4gIHJldHVybiB0cmlnZ2VyUGFnZUV2ZW50V2l0aFJlc3BvbnNlKCdnZXRNdWx0aXBsZVVzZXJzQnlJZHMnLCB7XG4gICAgdXNlcklkcyxcbiAgfSlcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldFVzZXJCeUlkKHVzZXJJZDogc3RyaW5nKTogUHJvbWlzZTxUd2l0dGVyVXNlciB8IG51bGw+IHtcbiAgY29uc3QgdXNlcnMgPSBhd2FpdCB0cmlnZ2VyUGFnZUV2ZW50V2l0aFJlc3BvbnNlKCdnZXRNdWx0aXBsZVVzZXJzQnlJZHMnLCB7XG4gICAgdXNlcklkczogW3VzZXJJZF0sXG4gIH0pLmNhdGNoKCgpID0+IHt9KVxuICByZXR1cm4gdXNlcnNbdXNlcklkXSB8fCBudWxsXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRVc2VyQnlOYW1lKHVzZXJOYW1lOiBzdHJpbmcpOiBQcm9taXNlPFR3aXR0ZXJVc2VyIHwgbnVsbD4ge1xuICByZXR1cm4gdHJpZ2dlclBhZ2VFdmVudFdpdGhSZXNwb25zZSgnZ2V0VXNlckJ5TmFtZScsIHtcbiAgICB1c2VyTmFtZSxcbiAgfSlcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldERNRGF0YShjb252SWQ6IHN0cmluZyk6IFByb21pc2U8RE1EYXRhIHwgbnVsbD4ge1xuICByZXR1cm4gdHJpZ2dlclBhZ2VFdmVudFdpdGhSZXNwb25zZSgnZ2V0RE1EYXRhJywge1xuICAgIGNvbnZJZCxcbiAgfSlcbn1cbiIsImltcG9ydCB7IFR3aXR0ZXJVc2VyTWFwIH0gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvY29tbW9uJ1xuXG4vLyDtjIzsnbTslrTtj63siqTsl5DshJwgQ3VzdG9tRXZlbnTsnZggZGV0YWlsIOqwnOyytCDsoITri6zsmqlcbmV4cG9ydCBmdW5jdGlvbiBjbG9uZURldGFpbDxUPihkZXRhaWw6IFQpOiBUIHtcbiAgaWYgKHR5cGVvZiBkZXRhaWwgIT09ICdvYmplY3QnKSB7XG4gICAgcmV0dXJuIGRldGFpbFxuICB9XG4gIGlmICh0eXBlb2YgY2xvbmVJbnRvID09PSAnZnVuY3Rpb24nKSB7XG4gICAgcmV0dXJuIGNsb25lSW50byhkZXRhaWwsIGRvY3VtZW50LmRlZmF1bHRWaWV3KVxuICB9IGVsc2Uge1xuICAgIHJldHVybiBkZXRhaWxcbiAgfVxufVxuXG5mdW5jdGlvbiB0cmlnZ2VyUGFnZUV2ZW50KGV2ZW50TmFtZTogUmVkdXhTdG9yZUV2ZW50TmFtZXMsIGV2ZW50RGV0YWlsPzogb2JqZWN0KTogdm9pZCB7XG4gIGNvbnN0IGRldGFpbCA9IGNsb25lRGV0YWlsKGV2ZW50RGV0YWlsKVxuICBjb25zdCByZXF1ZXN0RXZlbnQgPSBuZXcgQ3VzdG9tRXZlbnQoYE1pcnJvckJsb2NrLT4ke2V2ZW50TmFtZX1gLCB7XG4gICAgZGV0YWlsLFxuICB9KVxuICByZXF1ZXN0SWRsZUNhbGxiYWNrKCgpID0+IGRvY3VtZW50LmRpc3BhdGNoRXZlbnQocmVxdWVzdEV2ZW50KSwge1xuICAgIHRpbWVvdXQ6IDUwMDAsXG4gIH0pXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBpbnNlcnRTaW5nbGVVc2VySW50b1N0b3JlKHVzZXI6IFR3aXR0ZXJVc2VyKTogUHJvbWlzZTx2b2lkPiB7XG4gIHRyaWdnZXJQYWdlRXZlbnQoJ2luc2VydFNpbmdsZVVzZXJJbnRvU3RvcmUnLCB7XG4gICAgdXNlcixcbiAgfSlcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGluc2VydE11bHRpcGxlVXNlcnNJbnRvU3RvcmUodXNlcnNNYXA6IFR3aXR0ZXJVc2VyTWFwKTogUHJvbWlzZTx2b2lkPiB7XG4gIGNvbnN0IHVzZXJzT2JqID0gdXNlcnNNYXAudG9Vc2VyT2JqZWN0KClcbiAgdHJpZ2dlclBhZ2VFdmVudCgnaW5zZXJ0TXVsdGlwbGVVc2Vyc0ludG9TdG9yZScsIHtcbiAgICB1c2VyczogdXNlcnNPYmosXG4gIH0pXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBhZnRlckJsb2NrVXNlcih1c2VyOiBUd2l0dGVyVXNlcik6IFByb21pc2U8dm9pZD4ge1xuICB0cmlnZ2VyUGFnZUV2ZW50KCdhZnRlckJsb2NrVXNlcicsIHtcbiAgICB1c2VyLFxuICB9KVxuICBjb25zdCBjbG9uZWRVc2VyID0gT2JqZWN0LmFzc2lnbih7fSwgdXNlcilcbiAgY2xvbmVkVXNlci5ibG9ja2luZyA9IHRydWVcbiAgaW5zZXJ0U2luZ2xlVXNlckludG9TdG9yZShjbG9uZWRVc2VyKVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gdG9hc3RNZXNzYWdlKHRleHQ6IHN0cmluZyk6IFByb21pc2U8dm9pZD4ge1xuICB0cmlnZ2VyUGFnZUV2ZW50KCd0b2FzdE1lc3NhZ2UnLCB7XG4gICAgdGV4dCxcbiAgfSlcbn1cbiIsImltcG9ydCB7IFR3aXR0ZXJVc2VyTWFwLCBpc1R3aXR0ZXJVc2VyIH0gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvY29tbW9uJ1xuaW1wb3J0ICogYXMgVHdpdHRlckFQSSBmcm9tICfrr7jrn6zruJTrnb0vc2NyaXB0cy90d2l0dGVyLWFwaSdcbmltcG9ydCAqIGFzIFN0b3JlUmV0cmlldmVyIGZyb20gJy4vcmV0cmlldmVyJ1xuaW1wb3J0ICogYXMgU3RvcmVVcGRhdGVyIGZyb20gJy4vdXBkYXRlcidcblxuLy8gUmVkdXggc3RvcmXsl5Ag65Ok7Ja06rCA6riwIOyghOyXkCDsmpTssq3snbQg65Ok7Ja07Jik64qUIOqyveyasOulvCDrjIDruYTtlZwg7LqQ7IucXG5jb25zdCB1c2VyQ2FjaGVCeUlkID0gbmV3IE1hcDxzdHJpbmcsIFR3aXR0ZXJVc2VyPigpXG5jb25zdCB1c2VyQ2FjaGVCeU5hbWUgPSBuZXcgTWFwPHN0cmluZywgVHdpdHRlclVzZXI+KClcbmZ1bmN0aW9uIGFkZFVzZXJUb0NhY2hlKHVzZXI6IFR3aXR0ZXJVc2VyKSB7XG4gIHVzZXJDYWNoZUJ5SWQuc2V0KHVzZXIuaWRfc3RyLCB1c2VyKVxuICB1c2VyQ2FjaGVCeU5hbWUuc2V0KHVzZXIuc2NyZWVuX25hbWUsIHVzZXIpXG59XG5cbi8vIEFQSe2YuOy2nCDsi6TtjKjtlZwg7IKs7Jqp7J6QIElE64KYIOyCrOyaqeyekOydtOumhOydhCDsoIDsnqXtlZjsl6wgQVBJ7Zi47Lac7J2EIOuwmOuzte2VmOyngCDslYrrj4TroZ0g7ZWc64ukLlxuLy8gKOyYiDog7KeA7JuM7KeA6rGw64KYIOygleyngOqxuOumsCDqs4TsoJUpXG5jb25zdCBub3RFeGlzdFVzZXJzID0gbmV3IFNldDxzdHJpbmc+KClcblxuZnVuY3Rpb24gdHJlYXRBc05vbkV4aXN0VXNlcihmYWlsZWRJZE9yTmFtZXM6IHN0cmluZ1tdKTogKGVycjogYW55KSA9PiB2b2lkIHtcbiAgcmV0dXJuIChlcnI6IGFueSkgPT4ge1xuICAgIGZhaWxlZElkT3JOYW1lcy5mb3JFYWNoKGlkT3JOYW1lID0+IG5vdEV4aXN0VXNlcnMuYWRkKGlkT3JOYW1lLnRvTG93ZXJDYXNlKCkpKVxuICAgIGNvbnNvbGUuZXJyb3IoZXJyKVxuICB9XG59XG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0VXNlckJ5SWQodXNlcklkOiBzdHJpbmcsIHVzZUFQSTogYm9vbGVhbik6IFByb21pc2U8VHdpdHRlclVzZXIgfCBudWxsPiB7XG4gIGlmIChub3RFeGlzdFVzZXJzLmhhcyh1c2VySWQpKSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxuICBjb25zdCB1c2VyRnJvbVN0b3JlID0gYXdhaXQgU3RvcmVSZXRyaWV2ZXIuZ2V0VXNlckJ5SWQodXNlcklkKVxuICBpZiAodXNlckZyb21TdG9yZSAmJiBpc1R3aXR0ZXJVc2VyKHVzZXJGcm9tU3RvcmUpKSB7XG4gICAgYWRkVXNlclRvQ2FjaGUodXNlckZyb21TdG9yZSlcbiAgICByZXR1cm4gdXNlckZyb21TdG9yZVxuICB9IGVsc2UgaWYgKHVzZXJDYWNoZUJ5SWQuaGFzKHVzZXJJZCkpIHtcbiAgICByZXR1cm4gdXNlckNhY2hlQnlJZC5nZXQodXNlcklkKSFcbiAgfSBlbHNlIGlmICh1c2VBUEkpIHtcbiAgICBjb25zdCB1c2VyID0gYXdhaXQgVHdpdHRlckFQSS5nZXRTaW5nbGVVc2VyQnlJZCh1c2VySWQpLmNhdGNoKHRyZWF0QXNOb25FeGlzdFVzZXIoW3VzZXJJZF0pKVxuICAgIGlmICh1c2VyKSB7XG4gICAgICBhZGRVc2VyVG9DYWNoZSh1c2VyKVxuICAgICAgU3RvcmVVcGRhdGVyLmluc2VydFNpbmdsZVVzZXJJbnRvU3RvcmUodXNlcilcbiAgICB9XG4gICAgcmV0dXJuIHVzZXIgfHwgbnVsbFxuICB9IGVsc2Uge1xuICAgIHJldHVybiBudWxsXG4gIH1cbn1cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRVc2VyQnlOYW1lKFxuICB1c2VyTmFtZTogc3RyaW5nLFxuICB1c2VBUEk6IGJvb2xlYW5cbik6IFByb21pc2U8VHdpdHRlclVzZXIgfCBudWxsPiB7XG4gIGNvbnN0IGxvd2VyZWROYW1lID0gdXNlck5hbWUudG9Mb3dlckNhc2UoKVxuICBpZiAobm90RXhpc3RVc2Vycy5oYXMobG93ZXJlZE5hbWUpKSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxuICBjb25zdCB1c2VyRnJvbVN0b3JlID0gYXdhaXQgU3RvcmVSZXRyaWV2ZXIuZ2V0VXNlckJ5TmFtZShsb3dlcmVkTmFtZSlcbiAgaWYgKHVzZXJGcm9tU3RvcmUgJiYgaXNUd2l0dGVyVXNlcih1c2VyRnJvbVN0b3JlKSkge1xuICAgIGFkZFVzZXJUb0NhY2hlKHVzZXJGcm9tU3RvcmUpXG4gICAgcmV0dXJuIHVzZXJGcm9tU3RvcmVcbiAgfSBlbHNlIGlmICh1c2VyQ2FjaGVCeU5hbWUuaGFzKHVzZXJOYW1lKSkge1xuICAgIHJldHVybiB1c2VyQ2FjaGVCeU5hbWUuZ2V0KHVzZXJOYW1lKSFcbiAgfSBlbHNlIGlmICh1c2VBUEkpIHtcbiAgICBjb25zdCB1c2VyID0gYXdhaXQgVHdpdHRlckFQSS5nZXRTaW5nbGVVc2VyQnlOYW1lKHVzZXJOYW1lKS5jYXRjaChcbiAgICAgIHRyZWF0QXNOb25FeGlzdFVzZXIoW3VzZXJOYW1lXSlcbiAgICApXG4gICAgaWYgKHVzZXIpIHtcbiAgICAgIGFkZFVzZXJUb0NhY2hlKHVzZXIpXG4gICAgICBTdG9yZVVwZGF0ZXIuaW5zZXJ0U2luZ2xlVXNlckludG9TdG9yZSh1c2VyKVxuICAgIH1cbiAgICByZXR1cm4gdXNlciB8fCBudWxsXG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxufVxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldE11bHRpcGxlVXNlcnNCeUlkKHVzZXJJZHM6IHN0cmluZ1tdKTogUHJvbWlzZTxUd2l0dGVyVXNlck1hcD4ge1xuICBpZiAodXNlcklkcy5sZW5ndGggPiAxMDApIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3RvbyBtYW55IHVzZXIhJylcbiAgfVxuICBjb25zdCByZXN1bHRVc2VyTWFwID0gbmV3IFR3aXR0ZXJVc2VyTWFwKClcbiAgY29uc3QgaWRzVG9SZXF1ZXN0QVBJOiBzdHJpbmdbXSA9IFtdXG4gIGZvciAoY29uc3QgdXNlcklkIG9mIHVzZXJJZHMpIHtcbiAgICBjb25zdCB1c2VyRnJvbVN0b3JlID0gYXdhaXQgU3RvcmVSZXRyaWV2ZXIuZ2V0VXNlckJ5SWQodXNlcklkKVxuICAgIGNvbnN0IHVzZXJGcm9tQ2FjaGUgPSB1c2VyQ2FjaGVCeUlkLmdldCh1c2VySWQpXG4gICAgaWYgKHVzZXJGcm9tU3RvcmUgJiYgaXNUd2l0dGVyVXNlcih1c2VyRnJvbVN0b3JlKSkge1xuICAgICAgYWRkVXNlclRvQ2FjaGUodXNlckZyb21TdG9yZSlcbiAgICAgIHJlc3VsdFVzZXJNYXAuYWRkVXNlcih1c2VyRnJvbVN0b3JlKVxuICAgIH0gZWxzZSBpZiAodXNlckZyb21DYWNoZSkge1xuICAgICAgcmVzdWx0VXNlck1hcC5hZGRVc2VyKHVzZXJGcm9tQ2FjaGUpXG4gICAgfSBlbHNlIGlmICghbm90RXhpc3RVc2Vycy5oYXModXNlcklkKSkge1xuICAgICAgaWRzVG9SZXF1ZXN0QVBJLnB1c2godXNlcklkKVxuICAgIH1cbiAgfVxuICBpZiAoaWRzVG9SZXF1ZXN0QVBJLmxlbmd0aCA9PT0gMSkge1xuICAgIGNvbnN0IHJlcXVlc3RlZFVzZXIgPSBhd2FpdCBUd2l0dGVyQVBJLmdldFNpbmdsZVVzZXJCeUlkKGlkc1RvUmVxdWVzdEFQSVswXSkuY2F0Y2goXG4gICAgICB0cmVhdEFzTm9uRXhpc3RVc2VyKGlkc1RvUmVxdWVzdEFQSSlcbiAgICApXG4gICAgaWYgKHJlcXVlc3RlZFVzZXIpIHtcbiAgICAgIGFkZFVzZXJUb0NhY2hlKHJlcXVlc3RlZFVzZXIpXG4gICAgICBTdG9yZVVwZGF0ZXIuaW5zZXJ0U2luZ2xlVXNlckludG9TdG9yZShyZXF1ZXN0ZWRVc2VyKVxuICAgICAgcmVzdWx0VXNlck1hcC5hZGRVc2VyKHJlcXVlc3RlZFVzZXIpXG4gICAgfVxuICB9IGVsc2UgaWYgKGlkc1RvUmVxdWVzdEFQSS5sZW5ndGggPiAxKSB7XG4gICAgY29uc3QgcmVxdWVzdGVkVXNlcnMgPSBhd2FpdCBUd2l0dGVyQVBJLmdldE11bHRpcGxlVXNlcnNCeUlkKGlkc1RvUmVxdWVzdEFQSSlcbiAgICAgIC50aGVuKHVzZXJzID0+IFR3aXR0ZXJVc2VyTWFwLmZyb21Vc2Vyc0FycmF5KHVzZXJzKSlcbiAgICAgIC5jYXRjaCh0cmVhdEFzTm9uRXhpc3RVc2VyKGlkc1RvUmVxdWVzdEFQSSkpXG4gICAgaWYgKHJlcXVlc3RlZFVzZXJzKSB7XG4gICAgICBTdG9yZVVwZGF0ZXIuaW5zZXJ0TXVsdGlwbGVVc2Vyc0ludG9TdG9yZShyZXF1ZXN0ZWRVc2VycylcbiAgICAgIHJlcXVlc3RlZFVzZXJzLmZvckVhY2godXNlciA9PiB7XG4gICAgICAgIGFkZFVzZXJUb0NhY2hlKHVzZXIpXG4gICAgICAgIHJlc3VsdFVzZXJNYXAuYWRkVXNlcih1c2VyKVxuICAgICAgfSlcbiAgICB9XG4gIH1cbiAgcmV0dXJuIHJlc3VsdFVzZXJNYXBcbn1cbiIsImltcG9ydCB7IGRldGVjdE9uQ3VycmVudFR3aXR0ZXIgfSBmcm9tICcuL21pcnJvcmJsb2NrLW1vYmlsZSdcbmltcG9ydCB7IGhhbmRsZURhcmtNb2RlIH0gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvbmlnaHRtb2RlJ1xuXG5pbXBvcnQgKiBhcyBPcHRpb25zIGZyb20gJ+uvuOufrOu4lOudvS9leHRvcHRpb24nXG5cbmZ1bmN0aW9uIGluaXRpYWxpemUoKSB7XG4gIGJyb3dzZXIuc3RvcmFnZS5vbkNoYW5nZWQuYWRkTGlzdGVuZXIoY2hhbmdlcyA9PiB7XG4gICAgY29uc3Qgb3B0aW9uID0gY2hhbmdlcy5vcHRpb24ubmV3VmFsdWVcbiAgICBkb2N1bWVudC5kb2N1bWVudEVsZW1lbnQuY2xhc3NMaXN0LnRvZ2dsZSgnbW9iLWVuYWJsZS1vdXRsaW5lJywgb3B0aW9uLm91dGxpbmVCbG9ja1VzZXIpXG4gIH0pXG5cbiAgT3B0aW9ucy5sb2FkKCkudGhlbihvcHRpb24gPT4ge1xuICAgIGRvY3VtZW50LmRvY3VtZW50RWxlbWVudC5jbGFzc0xpc3QudG9nZ2xlKCdtb2ItZW5hYmxlLW91dGxpbmUnLCBvcHRpb24ub3V0bGluZUJsb2NrVXNlcilcbiAgfSlcblxuICBjb25zdCByZWFjdFJvb3QgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgncmVhY3Qtcm9vdCcpIVxuICBkZXRlY3RPbkN1cnJlbnRUd2l0dGVyKHJlYWN0Um9vdClcbiAgaGFuZGxlRGFya01vZGUoKVxufVxuXG5pbml0aWFsaXplKClcbiIsImZ1bmN0aW9uIGlzRGFyayhjb2xvclRoZW1lRWxlbTogSFRNTE1ldGFFbGVtZW50KSB7XG4gIHJldHVybiBjb2xvclRoZW1lRWxlbS5jb250ZW50LnRvVXBwZXJDYXNlKCkgIT09ICcjRkZGRkZGJ1xufVxuXG5mdW5jdGlvbiB0b2dnbGVOaWdodE1vZGUoZGFyazogYm9vbGVhbik6IHZvaWQge1xuICBkb2N1bWVudC5kb2N1bWVudEVsZW1lbnQuY2xhc3NMaXN0LnRvZ2dsZSgnbW9iLW5pZ2h0bW9kZScsIGRhcmspXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBoYW5kbGVEYXJrTW9kZSgpIHtcbiAgLy8gVE9ETzogbW9iLW1vYmlsZSDsnYAg7J207KCcIO2VhOyalOyXhuydjFxuICAvLyDri6gsIOyngOyauCDrlYwgY2hhaW5ibG9jay5jc3Mg66W8IOyImOygle2VtOyVvCDtlahcbiAgZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50LmNsYXNzTGlzdC5hZGQoJ21vYi1tb2JpbGUnKVxuXG4gIGNvbnN0IGNvbG9yVGhlbWVUYWcgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKCdtZXRhW25hbWU9dGhlbWUtY29sb3JdJylcbiAgaWYgKGNvbG9yVGhlbWVUYWcgaW5zdGFuY2VvZiBIVE1MTWV0YUVsZW1lbnQpIHtcbiAgICBjb25zdCBuaWdodE1vZGVPYnNlcnZlciA9IG5ldyBNdXRhdGlvbk9ic2VydmVyKCgpID0+IHtcbiAgICAgIHRvZ2dsZU5pZ2h0TW9kZShpc0RhcmsoY29sb3JUaGVtZVRhZykpXG4gICAgfSlcblxuICAgIG5pZ2h0TW9kZU9ic2VydmVyLm9ic2VydmUoY29sb3JUaGVtZVRhZywge1xuICAgICAgYXR0cmlidXRlRmlsdGVyOiBbJ2NvbnRlbnQnXSxcbiAgICAgIGF0dHJpYnV0ZXM6IHRydWUsXG4gICAgfSlcblxuICAgIHRvZ2dsZU5pZ2h0TW9kZShpc0RhcmsoY29sb3JUaGVtZVRhZykpXG4gIH1cbn1cbiIsImltcG9ydCB7IHZhbGlkYXRlVHdpdHRlclVzZXJOYW1lLCBzbGVlcCB9IGZyb20gJy4vY29tbW9uJ1xuXG5jb25zdCBCRUFSRVJfVE9LRU4gPSBgQUFBQUFBQUFBQUFBQUFBQUFBQUFBTlJJTGdBQUFBQUFuTndJelVlalJDT3VINUU2STh4blp6NHB1VHMlM0QxWnY3dHRmazhMRjgxSVVxMTZjSGpoTFR2SnU0RkEzM0FHV1dqQ3BUbkFgXG5cbi8vIENPUkIqIOuhnCDsnbjtlbQgY29udGVudCBzY3JpcHRz7JeQ7IScIGFwaS50d2l0dGVyLmNvbSDsnYQg7IKs7Jqp7ZWgIOyImCDsl4bri6QuXG4vLyBodHRwczovL3d3dy5jaHJvbWVzdGF0dXMuY29tL2ZlYXR1cmUvNTYyOTcwOTgyNDAzMjc2OFxuLy8gaHR0cHM6Ly93d3cuY2hyb21pdW0ub3JnL0hvbWUvY2hyb21pdW0tc2VjdXJpdHkvY29yYi1mb3ItZGV2ZWxvcGVyc1xubGV0IGFwaVByZWZpeCA9ICdodHRwczovL3R3aXR0ZXIuY29tL2kvYXBpLzEuMSdcbmlmIChsb2NhdGlvbi5ob3N0bmFtZSA9PT0gJ21vYmlsZS50d2l0dGVyLmNvbScpIHtcbiAgYXBpUHJlZml4ID0gJ2h0dHBzOi8vbW9iaWxlLnR3aXR0ZXIuY29tL2kvYXBpLzEuMSdcbn1cblxuZXhwb3J0IGNsYXNzIEFQSUVycm9yIGV4dGVuZHMgRXJyb3Ige1xuICBjb25zdHJ1Y3RvcihwdWJsaWMgcmVhZG9ubHkgcmVzcG9uc2U6IEFQSVJlc3BvbnNlKSB7XG4gICAgc3VwZXIoJ0FQSSBFcnJvciEnKVxuICAgIC8vIGZyb206IGh0dHBzOi8vd3d3LnR5cGVzY3JpcHRsYW5nLm9yZy9kb2NzL2hhbmRib29rL3JlbGVhc2Utbm90ZXMvdHlwZXNjcmlwdC0yLTIuaHRtbCNzdXBwb3J0LWZvci1uZXd0YXJnZXRcbiAgICBPYmplY3Quc2V0UHJvdG90eXBlT2YodGhpcywgbmV3LnRhcmdldC5wcm90b3R5cGUpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGJsb2NrVXNlcih1c2VyOiBUd2l0dGVyVXNlcik6IFByb21pc2U8Ym9vbGVhbj4ge1xuICBpZiAodXNlci5ibG9ja2luZykge1xuICAgIHJldHVybiB0cnVlXG4gIH1cbiAgY29uc3Qgc2hvdWxkTm90QmxvY2sgPVxuICAgIHVzZXIuZm9sbG93aW5nIHx8IHVzZXIuZm9sbG93ZWRfYnkgfHwgdXNlci5mb2xsb3dfcmVxdWVzdF9zZW50IHx8ICF1c2VyLmJsb2NrZWRfYnlcbiAgaWYgKHNob3VsZE5vdEJsb2NrKSB7XG4gICAgY29uc3QgZmF0YWxFcnJvck1lc3NhZ2UgPSBgISEhISFGQVRBTCEhISEhOlxuYXR0ZW1wdGVkIHRvIGJsb2NrIHVzZXIgdGhhdCBzaG91bGQgTk9UIGJsb2NrISFcbih1c2VyOiAke3VzZXIuc2NyZWVuX25hbWV9KWBcbiAgICB0aHJvdyBuZXcgRXJyb3IoZmF0YWxFcnJvck1lc3NhZ2UpXG4gIH1cbiAgcmV0dXJuIGJsb2NrVXNlckJ5SWQodXNlci5pZF9zdHIpXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBibG9ja1VzZXJCeUlkKHVzZXJJZDogc3RyaW5nKTogUHJvbWlzZTxib29sZWFuPiB7XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ3Bvc3QnLCAnL2Jsb2Nrcy9jcmVhdGUuanNvbicsIHtcbiAgICB1c2VyX2lkOiB1c2VySWQsXG4gICAgaW5jbHVkZV9lbnRpdGllczogZmFsc2UsXG4gICAgc2tpcF9zdGF0dXM6IHRydWUsXG4gIH0pXG4gIHJldHVybiByZXNwb25zZS5va1xufVxuXG5hc3luYyBmdW5jdGlvbiBnZXRGb2xsb3dpbmdzTGlzdChcbiAgdXNlcjogVHdpdHRlclVzZXIsXG4gIGN1cnNvcjogc3RyaW5nID0gJy0xJ1xuKTogUHJvbWlzZTxGb2xsb3dzTGlzdFJlc3BvbnNlPiB7XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvZnJpZW5kcy9saXN0Lmpzb24nLCB7XG4gICAgdXNlcl9pZDogdXNlci5pZF9zdHIsXG4gICAgY291bnQ6IDIwMCxcbiAgICBza2lwX3N0YXR1czogdHJ1ZSxcbiAgICBpbmNsdWRlX3VzZXJfZW50aXRpZXM6IGZhbHNlLFxuICAgIGN1cnNvcixcbiAgfSlcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgcmV0dXJuIHJlc3BvbnNlLmJvZHkgYXMgRm9sbG93c0xpc3RSZXNwb25zZVxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBBUElFcnJvcihyZXNwb25zZSlcbiAgfVxufVxuYXN5bmMgZnVuY3Rpb24gZ2V0Rm9sbG93ZXJzTGlzdChcbiAgdXNlcjogVHdpdHRlclVzZXIsXG4gIGN1cnNvcjogc3RyaW5nID0gJy0xJ1xuKTogUHJvbWlzZTxGb2xsb3dzTGlzdFJlc3BvbnNlPiB7XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvZm9sbG93ZXJzL2xpc3QuanNvbicsIHtcbiAgICB1c2VyX2lkOiB1c2VyLmlkX3N0cixcbiAgICAvLyBzY3JlZW5fbmFtZTogdXNlck5hbWUsXG4gICAgY291bnQ6IDIwMCxcbiAgICBza2lwX3N0YXR1czogdHJ1ZSxcbiAgICBpbmNsdWRlX3VzZXJfZW50aXRpZXM6IGZhbHNlLFxuICAgIGN1cnNvcixcbiAgfSlcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgcmV0dXJuIHJlc3BvbnNlLmJvZHkgYXMgRm9sbG93c0xpc3RSZXNwb25zZVxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBBUElFcnJvcihyZXNwb25zZSlcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24qIGdldEFsbEZvbGxvd3MoXG4gIHVzZXI6IFR3aXR0ZXJVc2VyLFxuICBmb2xsb3dLaW5kOiBGb2xsb3dLaW5kLFxuICBvcHRpb25zOiBGb2xsb3dzU2NyYXBlck9wdGlvbnNcbik6IEFzeW5jSXRlcmFibGVJdGVyYXRvcjxFaXRoZXI8QVBJRXJyb3IsIFJlYWRvbmx5PFR3aXR0ZXJVc2VyPj4+IHtcbiAgbGV0IGN1cnNvciA9ICctMSdcbiAgd2hpbGUgKHRydWUpIHtcbiAgICB0cnkge1xuICAgICAgbGV0IGpzb246IEZvbGxvd3NMaXN0UmVzcG9uc2VcbiAgICAgIHN3aXRjaCAoZm9sbG93S2luZCkge1xuICAgICAgICBjYXNlICdmb2xsb3dlcnMnOlxuICAgICAgICAgIGpzb24gPSBhd2FpdCBnZXRGb2xsb3dlcnNMaXN0KHVzZXIsIGN1cnNvcilcbiAgICAgICAgICBicmVha1xuICAgICAgICBjYXNlICdmb2xsb3dpbmcnOlxuICAgICAgICAgIGpzb24gPSBhd2FpdCBnZXRGb2xsb3dpbmdzTGlzdCh1c2VyLCBjdXJzb3IpXG4gICAgICAgICAgYnJlYWtcbiAgICAgICAgZGVmYXVsdDpcbiAgICAgICAgICB0aHJvdyBuZXcgRXJyb3IoJ3VucmVhY2hhYmxlJylcbiAgICAgIH1cbiAgICAgIGN1cnNvciA9IGpzb24ubmV4dF9jdXJzb3Jfc3RyXG4gICAgICBjb25zdCB1c2VycyA9IGpzb24udXNlcnMgYXMgVHdpdHRlclVzZXJbXVxuICAgICAgeWllbGQqIHVzZXJzLm1hcCh1c2VyID0+ICh7XG4gICAgICAgIG9rOiB0cnVlIGFzIGNvbnN0LFxuICAgICAgICB2YWx1ZTogT2JqZWN0LmZyZWV6ZSh1c2VyKSxcbiAgICAgIH0pKVxuICAgICAgaWYgKGN1cnNvciA9PT0gJzAnKSB7XG4gICAgICAgIGJyZWFrXG4gICAgICB9IGVsc2Uge1xuICAgICAgICBhd2FpdCBzbGVlcChvcHRpb25zLmRlbGF5KVxuICAgICAgICBjb250aW51ZVxuICAgICAgfVxuICAgIH0gY2F0Y2ggKGVycm9yKSB7XG4gICAgICBpZiAoZXJyb3IgaW5zdGFuY2VvZiBBUElFcnJvcikge1xuICAgICAgICB5aWVsZCB7XG4gICAgICAgICAgb2s6IGZhbHNlLFxuICAgICAgICAgIGVycm9yLFxuICAgICAgICB9XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aHJvdyBlcnJvclxuICAgICAgfVxuICAgIH1cbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0U2luZ2xlVXNlckJ5SWQodXNlcklkOiBzdHJpbmcpOiBQcm9taXNlPFR3aXR0ZXJVc2VyPiB7XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvdXNlcnMvc2hvdy5qc29uJywge1xuICAgIHVzZXJfaWQ6IHVzZXJJZCxcbiAgICBza2lwX3N0YXR1czogdHJ1ZSxcbiAgICBpbmNsdWRlX2VudGl0aWVzOiBmYWxzZSxcbiAgfSlcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgcmV0dXJuIHJlc3BvbnNlLmJvZHkgYXMgVHdpdHRlclVzZXJcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgQVBJRXJyb3IocmVzcG9uc2UpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldFNpbmdsZVVzZXJCeU5hbWUodXNlck5hbWU6IHN0cmluZyk6IFByb21pc2U8VHdpdHRlclVzZXI+IHtcbiAgY29uc3QgaXNWYWxpZFVzZXJOYW1lID0gdmFsaWRhdGVUd2l0dGVyVXNlck5hbWUodXNlck5hbWUpXG4gIGlmICghaXNWYWxpZFVzZXJOYW1lKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKGBJbnZhbGlkIHVzZXIgbmFtZSBcIiR7dXNlck5hbWV9XCIhYClcbiAgfVxuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL3VzZXJzL3Nob3cuanNvbicsIHtcbiAgICAvLyB1c2VyX2lkOiB1c2VyLmlkX3N0cixcbiAgICBzY3JlZW5fbmFtZTogdXNlck5hbWUsXG4gICAgc2tpcF9zdGF0dXM6IHRydWUsXG4gICAgaW5jbHVkZV9lbnRpdGllczogZmFsc2UsXG4gIH0pXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIHJldHVybiByZXNwb25zZS5ib2R5IGFzIFR3aXR0ZXJVc2VyXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEFQSUVycm9yKHJlc3BvbnNlKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRNdWx0aXBsZVVzZXJzQnlJZCh1c2VySWRzOiBzdHJpbmdbXSk6IFByb21pc2U8VHdpdHRlclVzZXJbXT4ge1xuICBpZiAodXNlcklkcy5sZW5ndGggPT09IDApIHtcbiAgICByZXR1cm4gW11cbiAgfVxuICBpZiAodXNlcklkcy5sZW5ndGggPiAxMDApIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3RvbyBtYW55IHVzZXJzISAoPiAxMDApJylcbiAgfVxuICBjb25zdCBqb2luZWRJZHMgPSBBcnJheS5mcm9tKG5ldyBTZXQodXNlcklkcykpLmpvaW4oJywnKVxuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdwb3N0JywgJy91c2Vycy9sb29rdXAuanNvbicsIHtcbiAgICB1c2VyX2lkOiBqb2luZWRJZHMsXG4gICAgaW5jbHVkZV9lbnRpdGllczogZmFsc2UsXG4gICAgLy8gc2NyZWVuX25hbWU6IC4uLlxuICB9KVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICByZXR1cm4gcmVzcG9uc2UuYm9keSBhcyBUd2l0dGVyVXNlcltdXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEFQSUVycm9yKHJlc3BvbnNlKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRGcmllbmRzaGlwcyh1c2VyczogVHdpdHRlclVzZXJbXSk6IFByb21pc2U8RnJpZW5kc2hpcFJlc3BvbnNlPiB7XG4gIGNvbnN0IHVzZXJJZHMgPSB1c2Vycy5tYXAodXNlciA9PiB1c2VyLmlkX3N0cilcbiAgaWYgKHVzZXJJZHMubGVuZ3RoID09PSAwKSB7XG4gICAgcmV0dXJuIFtdXG4gIH1cbiAgaWYgKHVzZXJJZHMubGVuZ3RoID4gMTAwKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKCd0b28gbWFueSB1c2VycyEgKD4gMTAwKScpXG4gIH1cbiAgY29uc3Qgam9pbmVkSWRzID0gQXJyYXkuZnJvbShuZXcgU2V0KHVzZXJJZHMpKS5qb2luKCcsJylcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy9mcmllbmRzaGlwcy9sb29rdXAuanNvbicsIHtcbiAgICB1c2VyX2lkOiBqb2luZWRJZHMsXG4gIH0pXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIHJldHVybiByZXNwb25zZS5ib2R5IGFzIEZyaWVuZHNoaXBSZXNwb25zZVxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBFcnJvcigncmVzcG9uc2UgaXMgbm90IG9rJylcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0UmVsYXRpb25zaGlwKFxuICBzb3VyY2VVc2VyOiBUd2l0dGVyVXNlcixcbiAgdGFyZ2V0VXNlcjogVHdpdHRlclVzZXJcbik6IFByb21pc2U8UmVsYXRpb25zaGlwPiB7XG4gIGNvbnN0IHNvdXJjZV9pZCA9IHNvdXJjZVVzZXIuaWRfc3RyXG4gIGNvbnN0IHRhcmdldF9pZCA9IHRhcmdldFVzZXIuaWRfc3RyXG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvZnJpZW5kc2hpcHMvc2hvdy5qc29uJywge1xuICAgIHNvdXJjZV9pZCxcbiAgICB0YXJnZXRfaWQsXG4gIH0pXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIGNvbnN0IHsgcmVsYXRpb25zaGlwIH0gPSByZXNwb25zZS5ib2R5IGFzIHtcbiAgICAgIHJlbGF0aW9uc2hpcDogUmVsYXRpb25zaGlwXG4gICAgfVxuICAgIHJldHVybiByZWxhdGlvbnNoaXBcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3Jlc3BvbnNlIGlzIG5vdCBvaycpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldE15c2VsZigpOiBQcm9taXNlPFR3aXR0ZXJVc2VyPiB7XG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvYWNjb3VudC92ZXJpZnlfY3JlZGVudGlhbHMuanNvbicpXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIHJldHVybiByZXNwb25zZS5ib2R5IGFzIFR3aXR0ZXJVc2VyXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEFQSUVycm9yKHJlc3BvbnNlKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRSYXRlTGltaXRTdGF0dXMoKTogUHJvbWlzZTxMaW1pdFN0YXR1cz4ge1xuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL2FwcGxpY2F0aW9uL3JhdGVfbGltaXRfc3RhdHVzLmpzb24nKVxuICBjb25zdCB7IHJlc291cmNlcyB9ID0gcmVzcG9uc2UuYm9keSBhcyB7XG4gICAgcmVzb3VyY2VzOiBMaW1pdFN0YXR1c1xuICB9XG4gIHJldHVybiByZXNvdXJjZXNcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldEZvbGxvd3NTY3JhcGVyUmF0ZUxpbWl0U3RhdHVzKGZvbGxvd0tpbmQ6IEZvbGxvd0tpbmQpOiBQcm9taXNlPExpbWl0PiB7XG4gIGNvbnN0IGxpbWl0U3RhdHVzID0gYXdhaXQgZ2V0UmF0ZUxpbWl0U3RhdHVzKClcbiAgaWYgKGZvbGxvd0tpbmQgPT09ICdmb2xsb3dlcnMnKSB7XG4gICAgcmV0dXJuIGxpbWl0U3RhdHVzLmZvbGxvd2Vyc1snL2ZvbGxvd2Vycy9saXN0J11cbiAgfSBlbHNlIGlmIChmb2xsb3dLaW5kID09PSAnZm9sbG93aW5nJykge1xuICAgIHJldHVybiBsaW1pdFN0YXR1cy5mcmllbmRzWycvZnJpZW5kcy9saXN0J11cbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3VucmVhY2hhYmxlJylcbiAgfVxufVxuXG5mdW5jdGlvbiBnZXRDc3JmVG9rZW5Gcm9tQ29va2llcygpOiBzdHJpbmcge1xuICByZXR1cm4gL1xcYmN0MD0oWzAtOWEtZl0rKS9pLmV4ZWMoZG9jdW1lbnQuY29va2llKSFbMV1cbn1cblxuZnVuY3Rpb24gZ2VuZXJhdGVUd2l0dGVyQVBJT3B0aW9ucyhvYmo6IFJlcXVlc3RJbml0KTogUmVxdWVzdEluaXQge1xuICBjb25zdCBjc3JmVG9rZW4gPSBnZXRDc3JmVG9rZW5Gcm9tQ29va2llcygpXG4gIGNvbnN0IGhlYWRlcnMgPSBuZXcgSGVhZGVycygpXG4gIGhlYWRlcnMuc2V0KCdhdXRob3JpemF0aW9uJywgYEJlYXJlciAke0JFQVJFUl9UT0tFTn1gKVxuICBoZWFkZXJzLnNldCgneC1jc3JmLXRva2VuJywgY3NyZlRva2VuKVxuICBoZWFkZXJzLnNldCgneC10d2l0dGVyLWFjdGl2ZS11c2VyJywgJ3llcycpXG4gIGhlYWRlcnMuc2V0KCd4LXR3aXR0ZXItYXV0aC10eXBlJywgJ09BdXRoMlNlc3Npb24nKVxuICBjb25zdCByZXN1bHQ6IFJlcXVlc3RJbml0ID0ge1xuICAgIG1ldGhvZDogJ2dldCcsXG4gICAgbW9kZTogJ2NvcnMnLFxuICAgIGNyZWRlbnRpYWxzOiAnaW5jbHVkZScsXG4gICAgcmVmZXJyZXI6ICdodHRwczovL3R3aXR0ZXIuY29tLycsXG4gICAgaGVhZGVycyxcbiAgfVxuICBPYmplY3QuYXNzaWduKHJlc3VsdCwgb2JqKVxuICByZXR1cm4gcmVzdWx0XG59XG5cbmZ1bmN0aW9uIHNldERlZmF1bHRQYXJhbXMocGFyYW1zOiBVUkxTZWFyY2hQYXJhbXMpOiB2b2lkIHtcbiAgcGFyYW1zLnNldCgnaW5jbHVkZV9wcm9maWxlX2ludGVyc3RpdGlhbF90eXBlJywgJzEnKVxuICBwYXJhbXMuc2V0KCdpbmNsdWRlX2Jsb2NraW5nJywgJzEnKVxuICBwYXJhbXMuc2V0KCdpbmNsdWRlX2Jsb2NrZWRfYnknLCAnMScpXG4gIHBhcmFtcy5zZXQoJ2luY2x1ZGVfZm9sbG93ZWRfYnknLCAnMScpXG4gIHBhcmFtcy5zZXQoJ2luY2x1ZGVfd2FudF9yZXR3ZWV0cycsICcxJylcbiAgcGFyYW1zLnNldCgnaW5jbHVkZV9tdXRlX2VkZ2UnLCAnMScpXG4gIHBhcmFtcy5zZXQoJ2luY2x1ZGVfY2FuX2RtJywgJzEnKVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gc2VuZFJlcXVlc3QoXG4gIG1ldGhvZDogSFRUUE1ldGhvZHMsXG4gIHBhdGg6IHN0cmluZyxcbiAgcGFyYW1zT2JqOiBVUkxQYXJhbXNPYmogPSB7fVxuKTogUHJvbWlzZTxBUElSZXNwb25zZT4ge1xuICBjb25zdCBmZXRjaE9wdGlvbnMgPSBnZW5lcmF0ZVR3aXR0ZXJBUElPcHRpb25zKHsgbWV0aG9kIH0pXG4gIGNvbnN0IHVybCA9IG5ldyBVUkwoYXBpUHJlZml4ICsgcGF0aClcbiAgbGV0IHBhcmFtczogVVJMU2VhcmNoUGFyYW1zXG4gIGlmIChtZXRob2QgPT09ICdnZXQnKSB7XG4gICAgcGFyYW1zID0gdXJsLnNlYXJjaFBhcmFtc1xuICB9IGVsc2Uge1xuICAgIHBhcmFtcyA9IG5ldyBVUkxTZWFyY2hQYXJhbXMoKVxuICAgIGZldGNoT3B0aW9ucy5ib2R5ID0gcGFyYW1zXG4gIH1cbiAgc2V0RGVmYXVsdFBhcmFtcyhwYXJhbXMpXG4gIGZvciAoY29uc3QgW2tleSwgdmFsdWVdIG9mIE9iamVjdC5lbnRyaWVzKHBhcmFtc09iaikpIHtcbiAgICBwYXJhbXMuc2V0KGtleSwgdmFsdWUudG9TdHJpbmcoKSlcbiAgfVxuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IGZldGNoKHVybC50b1N0cmluZygpLCBmZXRjaE9wdGlvbnMpXG4gIGNvbnN0IGhlYWRlcnMgPSBBcnJheS5mcm9tKHJlc3BvbnNlLmhlYWRlcnMpLnJlZHVjZShcbiAgICAob2JqLCBbbmFtZSwgdmFsdWVdKSA9PiAoKG9ialtuYW1lXSA9IHZhbHVlKSwgb2JqKSxcbiAgICB7fSBhcyB7IFtuYW1lOiBzdHJpbmddOiBzdHJpbmcgfVxuICApXG4gIGNvbnN0IHsgb2ssIHN0YXR1cywgc3RhdHVzVGV4dCB9ID0gcmVzcG9uc2VcbiAgY29uc3QgYm9keSA9IGF3YWl0IHJlc3BvbnNlLmpzb24oKVxuICBjb25zdCBhcGlSZXNwb25zZSA9IHtcbiAgICBvayxcbiAgICBzdGF0dXMsXG4gICAgc3RhdHVzVGV4dCxcbiAgICBoZWFkZXJzLFxuICAgIGJvZHksXG4gIH1cbiAgcmV0dXJuIGFwaVJlc3BvbnNlXG59XG4iXSwic291cmNlUm9vdCI6IiJ9