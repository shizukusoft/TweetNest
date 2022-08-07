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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/scripts/chainblock/chainblock.ts");
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

/***/ "./src/scripts/chainblock/chainblock-ui.ts":
/*!*************************************************!*\
  !*** ./src/scripts/chainblock/chainblock-ui.ts ***!
  \*************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return ChainMirrorBlockUI; });
/* harmony import */ var _scripts_common__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/scripts/common */ "./src/scripts/common.ts");
/* harmony import */ var _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/i18n */ "./src/scripts/i18n.ts");


// shortcut
function i18m(key) {
    return _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"](key);
}
const CHAINBLOCK_UI_HTML = `\n  <div class="mobcb-bg modal-container block-dialog" style="display:flex">\n    <div class="mobcb-dialog modal modal-content is-autoPosition">\n      <div class="mobcb-titlebar">\n        <span class="mobcb-title">${i18m('chainblock')}</span>\n        <span class="mobcb-title-status">(${i18m('preparing')})</span>\n      </div>\n      <div class="mobcb-progress">\n        <progress class="mobcb-progress-bar"></progress>\n        <div class="mobcb-progress-text" hidden>\n          (<span class="mobcb-prg-percentage"></span>%)\n          ${_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('chainblock_progress', [
    0,
    0,
    0
])}\n        </div>\n      </div>\n      <hr class="mobcb-hr">\n      <div class="mobcb-users">\n        <div class="mobcb-blockedby-users">\n          <ul class="mobcb-userlist"></ul>\n        </div>\n        <div class="mobcb-skipped-users">\n          <ul class="mobcb-userlist"></ul>\n        </div>\n      </div>\n      <hr class="mobcb-hr">\n      <div class="mobcb-extra-options">\n        <label title="${i18m('chainblock_immediately_block_mode_tooltip')}">\n          <input type="checkbox" id="mobcb-block-immediately">${i18m('chainblock_immediately_block_mode_label')}\n        </label>\n      </div>\n      <div class="mobcb-controls">\n        <div class="mobcb-message-container">\n          <div class="mobcb-bottom-message">\n            <span class="mobcb-rate-limited mobcb-rate-limited-msg" hidden>\n              ${i18m('chainblock_rate_limited')}\n            </span>\n          </div>\n          <div class="mobcb-rate-limited mobcb-limit-status" hidden>\n            ${i18m('chainblock_reset_time_label')}: <span class="resettime"></span>\n          </div>\n        </div>\n        <button class="mobcb-close btn normal-btn">${i18m('close')}</button>\n        <button disabled class="mobcb-execute btn caution-btn">${i18m('block')}</button>\n      </div>\n    </div>\n  </div>\n`;
function getLimitResetTime(limit) {
    const uiLanguage = browser.i18n.getUILanguage();
    const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    const formatter = new Intl.DateTimeFormat(uiLanguage, {
        timeZone,
        hour: '2-digit',
        minute: '2-digit'
    });
    // 120000 = 1000 * 60 * 2 = 리밋상태에서 체인블락의 delay간격
    const datetime = new Date(limit.reset * 1000 + 120000);
    return formatter.format(datetime);
}
class UserList {
    get size() {
        return this.items.size;
    }
    add(found) {
        const user = found.user;
        if (this.items.has(user.id_str)) {
            return;
        }
        let userPrefix = '';
        if (found.state === 'alreadyBlocked') {
            userPrefix = `[${_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('already_blocked')}]`;
        } else if (found.state === 'muteSkip') {
            userPrefix = `[${_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('skipped')}]`;
        }
        let tooltip = `${userPrefix} @${user.screen_name} (${user.name})`;
        tooltip += `\${i18n.getMessage('profile')}:\n${user.description}`;
        const ul = this.rootElem.querySelector('ul');
        const item = document.createElement('li');
        const link = document.createElement('a');
        item.className = 'mobcb-user';
        link.href = `https://twitter.com/${user.screen_name}`;
        if (location.hostname === 'mobile.twitter.com') {
            link.hostname = 'mobile.twitter.com';
        }
        link.setAttribute('rel', 'noreferer noopener');
        link.setAttribute('target', '_blank');
        link.setAttribute('title', tooltip);
        if (found.state === 'shouldBlock') {
            link.style.fontWeight = 'bold';
        }
        link.textContent = `${userPrefix} @${user.screen_name}: ${user.name}`;
        item.appendChild(link);
        ul.appendChild(item);
        this.items.set(user.id_str, item);
    }
    updateBlockResult(user, success) {
        const item = this.items.get(user.id_str);
        if (!item) {
            return;
        }
        if (success) {
            item.classList.remove('block-failed');
            item.classList.add('block-success');
        } else {
            item.classList.remove('block-success');
            item.classList.add('block-failed');
        }
    }
    cleanup() {
        this.items.clear();
    }
    constructor(rootElem){
        this.rootElem = rootElem;
        this.items = new Map();
    }
}
class ChainMirrorBlockUI extends _scripts_common__WEBPACK_IMPORTED_MODULE_0__["EventEmitter"] {
    close() {
        this.cleanupUserList();
        this.rootElem.remove();
    }
    cleanupUserList() {
        this.skippedUserList.cleanup();
        this.blockedbyUserList.cleanup();
    }
    handleEvents() {
        this.rootElem.addEventListener('click', (event)=>{
            if (!event.target) {
                return;
            }
            const target = event.target;
            if (target.matches('.mobcb-close')) {
                this.emit('ui:close');
            } else if (target.matches('.mobcb-execute')) {
                this.emit('ui:execute-mutual-block');
            }
        });
    }
    get immediatelyBlockModeChecked() {
        return this.rootElem.querySelector('#mobcb-block-immediately').checked;
    }
    set immediatelyBlockModeChecked(value) {
        this.rootElem.querySelector('#mobcb-block-immediately').checked = value;
    }
    initProgress(total) {
        this.total = total;
        const progressBar = this.rootElem.querySelector('.mobcb-progress-bar');
        progressBar.max = total;
        this.rootElem.querySelector('.mobcb-prg-total').textContent = total.toLocaleString();
    }
    updateBlockResult(user, success) {
        this.blockedbyUserList.updateBlockResult(user, success);
    }
    rateLimited(limit) {
        this.rootElem.querySelectorAll('.mobcb-rate-limited').forEach((elem)=>{
            elem.hidden = false;
        });
        const resettime = getLimitResetTime(limit);
        this.rootElem.querySelector('.mobcb-limit-status .resettime').textContent = resettime;
    }
    rateLimitResetted() {
        this.rootElem.querySelectorAll('.mobcb-rate-limited').forEach((elem)=>{
            elem.hidden = true;
        });
    }
    updateProgress(progress) {
        this.rootElem.querySelector('.mobcb-title-status').textContent = `(${_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('scrape_running')})`;
        progress.foundUsers.filter((found)=>found.state === 'shouldBlock'
        ).forEach((found)=>this.blockedbyUserList.add(found)
        );
        progress.foundUsers.filter((found)=>found.state === 'muteSkip' || found.state === 'alreadyBlocked'
        ).forEach((found)=>this.skippedUserList.add(found)
        );
        const progressBar = this.rootElem.querySelector('.mobcb-progress-bar');
        progressBar.value = progress.scraped;
        const percentage = Math.round(progress.scraped / this.total * 100);
        this.rootElem.querySelector('.mobcb-prg-percentage').textContent = percentage.toString();
        this.rootElem.querySelector('.mobcb-prg-scraped').textContent = progress.scraped.toLocaleString();
        this.rootElem.querySelector('.mobcb-prg-found').textContent = progress.foundUsers.length.toLocaleString();
        this.rootElem.querySelector('.mobcb-progress-text').hidden = false;
    }
    completeProgressUI(progress) {
        this.rootElem.querySelector('.mobcb-title-status').textContent = `(${_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('scrape_completed')})`;
        const shouldBlocks = progress.foundUsers.filter((user)=>user.state === 'shouldBlock'
        );
        const executeButton = this.rootElem.querySelector('.mobcb-execute');
        if (shouldBlocks.length > 0) {
            executeButton.disabled = false;
        } else {
            executeButton.title = _scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('no_blockable_user');
        }
        this.rootElem.querySelector('#mobcb-block-immediately').disabled = true;
        this.rootElem.querySelector('.mobcb-prg-scraped').textContent = this.total.toLocaleString();
        const progressBar = this.rootElem.querySelector('.mobcb-progress-bar');
        progressBar.value = progressBar.max;
        this.rootElem.querySelector('.mobcb-prg-percentage').textContent = '100';
    }
    complete(progress) {
        this.completeProgressUI(progress);
        if (progress.foundUsers.length <= 0) {
            // sleep: progress가 100%되기 전에 메시지가 뜨며 닫히는 현상 방지
            Object(_scripts_common__WEBPACK_IMPORTED_MODULE_0__["sleep"])(100).then(()=>{
                window.alert(_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('nobody_blocks_you'));
                this.emit('ui:close-without-confirm');
            });
        }
    }
    startMutualBlock() {
        this.rootElem.querySelector('.mobcb-title-status').textContent = `(${_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('block_running')})`;
        this.rootElem.querySelector('.mobcb-execute.btn').disabled = true;
    }
    completeMutualBlock() {
        this.rootElem.querySelector('.mobcb-title-status').textContent = `(${_scripts_i18n__WEBPACK_IMPORTED_MODULE_1__["getMessage"]('block_completed')})`;
    }
    constructor(){
        super();
        this.rootElem = document.createElement('div');
        this.total = 0;
        this.rootElem.innerHTML = CHAINBLOCK_UI_HTML;
        this.skippedUserList = new UserList(this.rootElem.querySelector('.mobcb-skipped-users'));
        this.blockedbyUserList = new UserList(this.rootElem.querySelector('.mobcb-blockedby-users'));
        document.body.appendChild(this.rootElem);
        this.handleEvents();
    }
}



/***/ }),

/***/ "./src/scripts/chainblock/chainblock.ts":
/*!**********************************************!*\
  !*** ./src/scripts/chainblock/chainblock.ts ***!
  \**********************************************/
/*! exports provided: startChainBlock */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "startChainBlock", function() { return startChainBlock; });
/* harmony import */ var _extoption__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! 미러블락/extoption */ "./src/extoption.ts");
/* harmony import */ var _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! 미러블락/scripts/twitter-api */ "./src/scripts/twitter-api.ts");
/* harmony import */ var _scripts_common__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! 미러블락/scripts/common */ "./src/scripts/common.ts");
/* harmony import */ var _chainblock_ui__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./chainblock-ui */ "./src/scripts/chainblock/chainblock-ui.ts");
/* harmony import */ var _scripts_i18n__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! 미러블락/scripts/i18n */ "./src/scripts/i18n.ts");






class ChainMirrorBlock {
    get immediatelyBlockMode() {
        return this.ui.immediatelyBlockModeChecked;
    }
    cleanup() {
        this.blockResults.clear();
        this.progress.foundUsers.length = 0;
    }
    prepareUI() {
        this.ui.immediatelyBlockModeChecked = this.options.alwaysImmediatelyBlockMode;
        window.addEventListener('beforeunload', (event)=>{
            if (!this.isRunning) {
                return;
            }
            event.preventDefault();
            const message = `[Mirror Block] ${_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('warning_before_close')}`;
            event.returnValue = message;
            return message;
        });
        this.ui.on('ui:close', ()=>{
            const confirmMessage = _scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('chainblock_still_running');
            if (this.isRunning && window.confirm(confirmMessage)) {
                this.stopAndClose();
            } else if (!this.isRunning) {
                this.stopAndClose();
            }
        });
        this.ui.on('ui:close-without-confirm', ()=>{
            this.stopAndClose();
        });
        this.ui.on('ui:execute-mutual-block', ()=>{
            const shouldBlocks = this.progress.foundUsers.filter((user)=>user.state === 'shouldBlock'
            );
            if (shouldBlocks.length > 0) {
                const confirmMessage = _scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('confirm_mutual_block', shouldBlocks.length);
                if (!window.confirm(confirmMessage)) {
                    return;
                }
                this.executeMutualBlock();
            } else {
                window.alert(_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('no_users_to_mutual_block'));
            }
        });
    }
    stopAndClose() {
        this.shouldStop = true;
        this.cleanup();
        this.ui.close();
    }
    processImmediatelyBlockMode() {
        if (!this.immediatelyBlockMode) {
            return;
        }
        const usersToBlock = this.progress.foundUsers.filter((found)=>{
            return found.state === 'shouldBlock' && this.blockResults.get(found.user.id_str) === 'notYet';
        });
        usersToBlock.forEach(({ user  })=>{
            this.blockResults.set(user.id_str, 'pending');
        });
        const immBlockPromises = usersToBlock.map(async ({ user  })=>{
            return _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["blockUser"](user).then((blocked)=>{
                const bresult = blocked ? 'blockSuccess' : 'blockFailed';
                this.blockResults.set(user.id_str, bresult);
                return blocked;
            }).catch((err)=>{
                console.error('failed to block:', err);
                this.blockResults.set(user.id_str, 'blockFailed');
                return false;
            }).then((result)=>{
                this.ui.updateBlockResult(user, result);
            });
        });
        Promise.all(immBlockPromises);
    }
    async start(targetUser, followKind) {
        this.isRunning = true;
        try {
            if (targetUser.blocked_by) {
                window.alert(_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('cant_chainblock_they_blocks_you', targetUser.screen_name));
                this.stopAndClose();
                return;
            }
            const updateProgress = ()=>{
                this.ui.updateProgress(Object(_scripts_common__WEBPACK_IMPORTED_MODULE_2__["copyFrozenObject"])(this.progress));
            };
            const classifyUserState = (user)=>{
                if (user.blocking) {
                    return 'alreadyBlocked';
                }
                if (user.muting && !this.options.blockMutedUser) {
                    return 'muteSkip';
                }
                if (user.blocked_by) {
                    return 'shouldBlock';
                }
                throw new Error(`unreachable: invalid user state? (${user.id_str}:@${user.screen_name})`);
            };
            const addUserToFounded = (follower)=>{
                const userState = classifyUserState(follower);
                this.progress.foundUsers.push({
                    user: follower,
                    state: userState
                });
                this.blockResults.set(follower.id_str, 'notYet');
                updateProgress();
            };
            const total = getTotalFollows(targetUser, followKind);
            this.ui.initProgress(total);
            const delay = total > 10000 ? 950 : 300;
            const scraper = _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getAllFollows"](targetUser, followKind, {
                delay
            });
            let rateLimited = false;
            for await (const maybeFollower of scraper){
                if (this.shouldStop) {
                    break;
                }
                if (!maybeFollower.ok) {
                    const { error  } = maybeFollower;
                    if (error.response.status === 429) {
                        rateLimited = true;
                        _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getFollowsScraperRateLimitStatus"](followKind).then(this.ui.rateLimited);
                        await Object(_scripts_common__WEBPACK_IMPORTED_MODULE_2__["sleep"])(1000 * 60 * 2);
                        continue;
                    } else {
                        console.error(error);
                        break;
                    }
                }
                const follower = maybeFollower.value;
                if (rateLimited) {
                    rateLimited = false;
                    this.ui.rateLimitResetted();
                }
                ++this.progress.scraped;
                updateProgress();
                if (!follower.blocked_by) {
                    continue;
                }
                addUserToFounded(follower);
                this.processImmediatelyBlockMode();
            }
            if (!this.shouldStop) {
                this.ui.complete(Object(_scripts_common__WEBPACK_IMPORTED_MODULE_2__["copyFrozenObject"])(this.progress));
            }
        } finally{
            this.isRunning = false;
            this.shouldStop = false;
        }
    }
    async executeMutualBlock() {
        this.isRunning = true;
        try {
            this.ui.startMutualBlock();
            const usersToBlock = this.progress.foundUsers.filter((fu)=>fu.state === 'shouldBlock'
            ).map((fu)=>fu.user
            ).filter((user)=>this.blockResults.get(user.id_str) === 'notYet'
            );
            const blockPromises = Promise.all(usersToBlock.map((user)=>{
                return _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["blockUser"](user).then((blocked)=>{
                    const bresult = blocked ? 'blockSuccess' : 'blockFailed';
                    this.blockResults.set(user.id_str, bresult);
                    return blocked;
                }).catch((err)=>{
                    console.error('failed to block:', err);
                    this.blockResults.set(user.id_str, 'blockFailed');
                    return false;
                }).then((result)=>{
                    this.ui.updateBlockResult(user, result);
                });
            }));
            await blockPromises;
            this.ui.completeMutualBlock();
        } finally{
            this.isRunning = false;
            this.shouldStop = false;
        }
    }
    constructor(options){
        this.options = options;
        this.ui = new _chainblock_ui__WEBPACK_IMPORTED_MODULE_3__["default"]();
        this.blockResults = new Map();
        this.progress = {
            scraped: 0,
            foundUsers: []
        };
        this.isRunning = false;
        this.shouldStop = false;
        this.prepareUI();
    }
}
function getTotalFollows(user, followKind) {
    if (followKind === 'followers') {
        return user.followers_count;
    } else if (followKind === 'following') {
        return user.friends_count;
    } else {
        throw new Error('unreachable');
    }
}
async function startChainBlock(targetUserName, followKind) {
    const alreadyRunning = document.querySelector('.mobcg-bg');
    if (alreadyRunning) {
        window.alert(_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('chainblock_already_running'));
        return;
    }
    const myself = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getMyself"]()//.catch(() => null)
    ;
    if (!myself) {
        window.alert(_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('please_check_login_before_chainblock'));
        return;
    }
    const targetUser = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getSingleUserByName"](targetUserName).catch((err)=>{
        if (err instanceof _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["APIError"]) {
            const json = err.response.body;
            const jsonstr = JSON.stringify(json, null, 2);
            window.alert(`${_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('error_occured_from_twitter_server')}\n${jsonstr}`);
        } else if (err instanceof Error) {
            window.alert(`${_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('error_occured')}\n${err.message}`);
        }
        return null;
    });
    if (!targetUser) {
        return;
    }
    const followsCount = getTotalFollows(targetUser, followKind);
    if (followsCount <= 0) {
        window.alert(_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('nobody_follows_them'));
        return;
    }
    if (targetUser.protected) {
        const relationship = await _scripts_twitter_api__WEBPACK_IMPORTED_MODULE_1__["getRelationship"](myself, targetUser);
        const { following  } = relationship.source;
        if (!following) {
            window.alert(_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('cant_chainblock_they_protected', targetUserName));
            return;
        }
    }
    let confirmMessage;
    switch(followKind){
        case 'followers':
            confirmMessage = _scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('confirm_chainblock_to_followers', targetUser.screen_name);
            break;
        case 'following':
            confirmMessage = _scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('confirm_chainblock_to_following', targetUser.screen_name);
            break;
    }
    let confirmed = window.confirm(confirmMessage);
    if (followsCount > 200000) {
        confirmed = window.confirm(_scripts_i18n__WEBPACK_IMPORTED_MODULE_4__["getMessage"]('warning_too_many_followers'));
    }
    if (confirmed) {
        const options1 = await _extoption__WEBPACK_IMPORTED_MODULE_0__["load"]();
        const chainblocker = new ChainMirrorBlock(options1);
        chainblocker.start(targetUser, followKind);
    }
}
browser.runtime.onMessage.addListener((msg)=>{
    const message = msg;
    if (message.action === _scripts_common__WEBPACK_IMPORTED_MODULE_2__["Action"].StartChainBlock) {
        startChainBlock(message.userName, message.followKind);
    } else if (message.action === _scripts_common__WEBPACK_IMPORTED_MODULE_2__["Action"].Alert) {
        const msg1 = message.message;
        window.alert(msg1);
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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V4dG9wdGlvbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9jaGFpbmJsb2NrL2NoYWluYmxvY2stdWkudHMiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvY2hhaW5ibG9jay9jaGFpbmJsb2NrLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL2NvbW1vbi50cyIsIndlYnBhY2s6Ly8vLi9zcmMvc2NyaXB0cy9pMThuLnRzIiwid2VicGFjazovLy8uL3NyYy9zY3JpcHRzL3R3aXR0ZXItYXBpLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7UUFBQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTs7O1FBR0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBLDBDQUEwQyxnQ0FBZ0M7UUFDMUU7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQSx3REFBd0Qsa0JBQWtCO1FBQzFFO1FBQ0EsaURBQWlELGNBQWM7UUFDL0Q7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBLHlDQUF5QyxpQ0FBaUM7UUFDMUUsZ0hBQWdILG1CQUFtQixFQUFFO1FBQ3JJO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMkJBQTJCLDBCQUEwQixFQUFFO1FBQ3ZELGlDQUFpQyxlQUFlO1FBQ2hEO1FBQ0E7UUFDQTs7UUFFQTtRQUNBLHNEQUFzRCwrREFBK0Q7O1FBRXJIO1FBQ0E7OztRQUdBO1FBQ0E7Ozs7Ozs7Ozs7Ozs7Ozs7TUNsRk0sUUFBUSxHQUFHLE1BQU0sQ0FBQyxNQUFNO0lBQzVCLGdCQUFnQixFQUFFLEtBQUs7SUFDdkIscUJBQXFCLEVBQUUsS0FB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QU8sR0FBRyxLQUFLLENBQUMsSUFBSSxDQUFDLFNBQVEsQ0FBQyxPQUFPLEVBQUUsTUFBTSxFQUNoRCxHQUFHLEdBQUcsSUFBSSxFQUFFLE1BQUssS0FBUSxHQUFHLENBQUMsSUFBSSxJQUFJLE1BQUssRUFBRyxHQUFHOzs7WUFHM0MsRUFBRSxHQUFFLE1BQU0sR0FBRSxVQUFVLE1BQUssU0FBUTtVQUNyQyxJQUFJLFNBQVMsU0FBUSxDQUFDLElBQUk7VUFDMUIsV0FBVztRQUNmLEVBQUU7UUFDRixNQUFNO1FBQ04sVUFBVTtRQUNWLE9BQU87UUFDUCxJQUFJOztXQUVDLFdBQVciLCJmaWxlIjoiY2hhaW5ibG9jay5idW4uanMiLCJzb3VyY2VzQ29udGVudCI6WyIgXHQvLyBUaGUgbW9kdWxlIGNhY2hlXG4gXHR2YXIgaW5zdGFsbGVkTW9kdWxlcyA9IHt9O1xuXG4gXHQvLyBUaGUgcmVxdWlyZSBmdW5jdGlvblxuIFx0ZnVuY3Rpb24gX193ZWJwYWNrX3JlcXVpcmVfXyhtb2R1bGVJZCkge1xuXG4gXHRcdC8vIENoZWNrIGlmIG1vZHVsZSBpcyBpbiBjYWNoZVxuIFx0XHRpZihpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXSkge1xuIFx0XHRcdHJldHVybiBpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXS5leHBvcnRzO1xuIFx0XHR9XG4gXHRcdC8vIENyZWF0ZSBhIG5ldyBtb2R1bGUgKGFuZCBwdXQgaXQgaW50byB0aGUgY2FjaGUpXG4gXHRcdHZhciBtb2R1bGUgPSBpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXSA9IHtcbiBcdFx0XHRpOiBtb2R1bGVJZCxcbiBcdFx0XHRsOiBmYWxzZSxcbiBcdFx0XHRleHBvcnRzOiB7fVxuIFx0XHR9O1xuXG4gXHRcdC8vIEV4ZWN1dGUgdGhlIG1vZHVsZSBmdW5jdGlvblxuIFx0XHRtb2R1bGVzW21vZHVsZUlkXS5jYWxsKG1vZHVsZS5leHBvcnRzLCBtb2R1bGUsIG1vZHVsZS5leHBvcnRzLCBfX3dlYnBhY2tfcmVxdWlyZV9fKTtcblxuIFx0XHQvLyBGbGFnIHRoZSBtb2R1bGUgYXMgbG9hZGVkXG4gXHRcdG1vZHVsZS5sID0gdHJ1ZTtcblxuIFx0XHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuIFx0XHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG4gXHR9XG5cblxuIFx0Ly8gZXhwb3NlIHRoZSBtb2R1bGVzIG9iamVjdCAoX193ZWJwYWNrX21vZHVsZXNfXylcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubSA9IG1vZHVsZXM7XG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlIGNhY2hlXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmMgPSBpbnN0YWxsZWRNb2R1bGVzO1xuXG4gXHQvLyBkZWZpbmUgZ2V0dGVyIGZ1bmN0aW9uIGZvciBoYXJtb255IGV4cG9ydHNcbiBcdF9fd2VicGFja19yZXF1aXJlX18uZCA9IGZ1bmN0aW9uKGV4cG9ydHMsIG5hbWUsIGdldHRlcikge1xuIFx0XHRpZighX193ZWJwYWNrX3JlcXVpcmVfXy5vKGV4cG9ydHMsIG5hbWUpKSB7XG4gXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIG5hbWUsIHsgZW51bWVyYWJsZTogdHJ1ZSwgZ2V0OiBnZXR0ZXIgfSk7XG4gXHRcdH1cbiBcdH07XG5cbiBcdC8vIGRlZmluZSBfX2VzTW9kdWxlIG9uIGV4cG9ydHNcbiBcdF9fd2VicGFja19yZXF1aXJlX18uciA9IGZ1bmN0aW9uKGV4cG9ydHMpIHtcbiBcdFx0aWYodHlwZW9mIFN5bWJvbCAhPT0gJ3VuZGVmaW5lZCcgJiYgU3ltYm9sLnRvU3RyaW5nVGFnKSB7XG4gXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIFN5bWJvbC50b1N0cmluZ1RhZywgeyB2YWx1ZTogJ01vZHVsZScgfSk7XG4gXHRcdH1cbiBcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsICdfX2VzTW9kdWxlJywgeyB2YWx1ZTogdHJ1ZSB9KTtcbiBcdH07XG5cbiBcdC8vIGNyZWF0ZSBhIGZha2UgbmFtZXNwYWNlIG9iamVjdFxuIFx0Ly8gbW9kZSAmIDE6IHZhbHVlIGlzIGEgbW9kdWxlIGlkLCByZXF1aXJlIGl0XG4gXHQvLyBtb2RlICYgMjogbWVyZ2UgYWxsIHByb3BlcnRpZXMgb2YgdmFsdWUgaW50byB0aGUgbnNcbiBcdC8vIG1vZGUgJiA0OiByZXR1cm4gdmFsdWUgd2hlbiBhbHJlYWR5IG5zIG9iamVjdFxuIFx0Ly8gbW9kZSAmIDh8MTogYmVoYXZlIGxpa2UgcmVxdWlyZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy50ID0gZnVuY3Rpb24odmFsdWUsIG1vZGUpIHtcbiBcdFx0aWYobW9kZSAmIDEpIHZhbHVlID0gX193ZWJwYWNrX3JlcXVpcmVfXyh2YWx1ZSk7XG4gXHRcdGlmKG1vZGUgJiA4KSByZXR1cm4gdmFsdWU7XG4gXHRcdGlmKChtb2RlICYgNCkgJiYgdHlwZW9mIHZhbHVlID09PSAnb2JqZWN0JyAmJiB2YWx1ZSAmJiB2YWx1ZS5fX2VzTW9kdWxlKSByZXR1cm4gdmFsdWU7XG4gXHRcdHZhciBucyA9IE9iamVjdC5jcmVhdGUobnVsbCk7XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18ucihucyk7XG4gXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShucywgJ2RlZmF1bHQnLCB7IGVudW1lcmFibGU6IHRydWUsIHZhbHVlOiB2YWx1ZSB9KTtcbiBcdFx0aWYobW9kZSAmIDIgJiYgdHlwZW9mIHZhbHVlICE9ICdzdHJpbmcnKSBmb3IodmFyIGtleSBpbiB2YWx1ZSkgX193ZWJwYWNrX3JlcXVpcmVfXy5kKG5zLCBrZXksIGZ1bmN0aW9uKGtleSkgeyByZXR1cm4gdmFsdWVba2V5XTsgfS5iaW5kKG51bGwsIGtleSkpO1xuIFx0XHRyZXR1cm4gbnM7XG4gXHR9O1xuXG4gXHQvLyBnZXREZWZhdWx0RXhwb3J0IGZ1bmN0aW9uIGZvciBjb21wYXRpYmlsaXR5IHdpdGggbm9uLWhhcm1vbnkgbW9kdWxlc1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5uID0gZnVuY3Rpb24obW9kdWxlKSB7XG4gXHRcdHZhciBnZXR0ZXIgPSBtb2R1bGUgJiYgbW9kdWxlLl9fZXNNb2R1bGUgP1xuIFx0XHRcdGZ1bmN0aW9uIGdldERlZmF1bHQoKSB7IHJldHVybiBtb2R1bGVbJ2RlZmF1bHQnXTsgfSA6XG4gXHRcdFx0ZnVuY3Rpb24gZ2V0TW9kdWxlRXhwb3J0cygpIHsgcmV0dXJuIG1vZHVsZTsgfTtcbiBcdFx0X193ZWJwYWNrX3JlcXVpcmVfXy5kKGdldHRlciwgJ2EnLCBnZXR0ZXIpO1xuIFx0XHRyZXR1cm4gZ2V0dGVyO1xuIFx0fTtcblxuIFx0Ly8gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm8gPSBmdW5jdGlvbihvYmplY3QsIHByb3BlcnR5KSB7IHJldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwob2JqZWN0LCBwcm9wZXJ0eSk7IH07XG5cbiBcdC8vIF9fd2VicGFja19wdWJsaWNfcGF0aF9fXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnAgPSBcIlwiO1xuXG5cbiBcdC8vIExvYWQgZW50cnkgbW9kdWxlIGFuZCByZXR1cm4gZXhwb3J0c1xuIFx0cmV0dXJuIF9fd2VicGFja19yZXF1aXJlX18oX193ZWJwYWNrX3JlcXVpcmVfXy5zID0gXCIuL3NyYy9zY3JpcHRzL2NoYWluYmxvY2svY2hhaW5ibG9jay50c1wiKTtcbiIsImNvbnN0IGRlZmF1bHRzID0gT2JqZWN0LmZyZWV6ZTxNaXJyb3JCbG9ja09wdGlvbj4oe1xuICBvdXRsaW5lQmxvY2tVc2VyOiBmYWxzZSxcbiAgZW5hYmxlQmxvY2tSZWZsZWN0aW9uOiBmYWxzZSxcbiAgYmxvY2tNdXRlZFVzZXI6IGZhbHNlLFxuICBhbHdheXNJbW1lZGlhdGVseUJsb2NrTW9kZTogZmFsc2UsXG59KVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gc2F2ZShuZXdPcHRpb246IE1pcnJvckJsb2NrT3B0aW9uKSB7XG4gIGNvbnN0IG9wdGlvbiA9IE9iamVjdC5hc3NpZ248XG4gICAgb2JqZWN0LFxuICAgIE1pcnJvckJsb2NrT3B0aW9uLFxuICAgIFBhcnRpYWw8TWlycm9yQmxvY2tPcHRpb24+XG4gID4oe30sIGRlZmF1bHRzLCBuZXdPcHRpb24pXG4gIHJldHVybiBicm93c2VyLnN0b3JhZ2UubG9jYWwuc2V0KHtcbiAgICBvcHRpb24sXG4gIH0gYXMgYW55KVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gbG9hZCgpOiBQcm9taXNlPE1pcnJvckJsb2NrT3B0aW9uPiB7XG4gIGNvbnN0IGxvYWRlZCA9IGF3YWl0IGJyb3dzZXIuc3RvcmFnZS5sb2NhbC5nZXQoJ29wdGlvbicpXG4gIHJldHVybiBPYmplY3QuYXNzaWduPG9iamVjdCwgTWlycm9yQmxvY2tPcHRpb24sIGFueT4oXG4gICAge30sXG4gICAgZGVmYXVsdHMsXG4gICAgbG9hZGVkLm9wdGlvblxuICApXG59XG4iLCJpbXBvcnQgeyBFdmVudEVtaXR0ZXIsIHNsZWVwIH0gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvY29tbW9uJ1xuaW1wb3J0ICogYXMgaTE4biBmcm9tICfrr7jrn6zruJTrnb0vc2NyaXB0cy9pMThuJ1xuXG4vLyBzaG9ydGN1dFxuZnVuY3Rpb24gaTE4bShrZXk6IGkxOG4uSTE4Tk1lc3NhZ2VLZXlzKTogc3RyaW5nIHtcbiAgcmV0dXJuIGkxOG4uZ2V0TWVzc2FnZShrZXkpXG59XG5cbmNvbnN0IENIQUlOQkxPQ0tfVUlfSFRNTCA9IGBcbiAgPGRpdiBjbGFzcz1cIm1vYmNiLWJnIG1vZGFsLWNvbnRhaW5lciBibG9jay1kaWFsb2dcIiBzdHlsZT1cImRpc3BsYXk6ZmxleFwiPlxuICAgIDxkaXYgY2xhc3M9XCJtb2JjYi1kaWFsb2cgbW9kYWwgbW9kYWwtY29udGVudCBpcy1hdXRvUG9zaXRpb25cIj5cbiAgICAgIDxkaXYgY2xhc3M9XCJtb2JjYi10aXRsZWJhclwiPlxuICAgICAgICA8c3BhbiBjbGFzcz1cIm1vYmNiLXRpdGxlXCI+JHtpMThtKCdjaGFpbmJsb2NrJyl9PC9zcGFuPlxuICAgICAgICA8c3BhbiBjbGFzcz1cIm1vYmNiLXRpdGxlLXN0YXR1c1wiPigke2kxOG0oJ3ByZXBhcmluZycpfSk8L3NwYW4+XG4gICAgICA8L2Rpdj5cbiAgICAgIDxkaXYgY2xhc3M9XCJtb2JjYi1wcm9ncmVzc1wiPlxuICAgICAgICA8cHJvZ3Jlc3MgY2xhc3M9XCJtb2JjYi1wcm9ncmVzcy1iYXJcIj48L3Byb2dyZXNzPlxuICAgICAgICA8ZGl2IGNsYXNzPVwibW9iY2ItcHJvZ3Jlc3MtdGV4dFwiIGhpZGRlbj5cbiAgICAgICAgICAoPHNwYW4gY2xhc3M9XCJtb2JjYi1wcmctcGVyY2VudGFnZVwiPjwvc3Bhbj4lKVxuICAgICAgICAgICR7aTE4bi5nZXRNZXNzYWdlKCdjaGFpbmJsb2NrX3Byb2dyZXNzJywgWzAsIDAsIDBdKX1cbiAgICAgICAgPC9kaXY+XG4gICAgICA8L2Rpdj5cbiAgICAgIDxociBjbGFzcz1cIm1vYmNiLWhyXCI+XG4gICAgICA8ZGl2IGNsYXNzPVwibW9iY2ItdXNlcnNcIj5cbiAgICAgICAgPGRpdiBjbGFzcz1cIm1vYmNiLWJsb2NrZWRieS11c2Vyc1wiPlxuICAgICAgICAgIDx1bCBjbGFzcz1cIm1vYmNiLXVzZXJsaXN0XCI+PC91bD5cbiAgICAgICAgPC9kaXY+XG4gICAgICAgIDxkaXYgY2xhc3M9XCJtb2JjYi1za2lwcGVkLXVzZXJzXCI+XG4gICAgICAgICAgPHVsIGNsYXNzPVwibW9iY2ItdXNlcmxpc3RcIj48L3VsPlxuICAgICAgICA8L2Rpdj5cbiAgICAgIDwvZGl2PlxuICAgICAgPGhyIGNsYXNzPVwibW9iY2ItaHJcIj5cbiAgICAgIDxkaXYgY2xhc3M9XCJtb2JjYi1leHRyYS1vcHRpb25zXCI+XG4gICAgICAgIDxsYWJlbCB0aXRsZT1cIiR7aTE4bSgnY2hhaW5ibG9ja19pbW1lZGlhdGVseV9ibG9ja19tb2RlX3Rvb2x0aXAnKX1cIj5cbiAgICAgICAgICA8aW5wdXQgdHlwZT1cImNoZWNrYm94XCIgaWQ9XCJtb2JjYi1ibG9jay1pbW1lZGlhdGVseVwiPiR7aTE4bShcbiAgICAgICAgICAgICdjaGFpbmJsb2NrX2ltbWVkaWF0ZWx5X2Jsb2NrX21vZGVfbGFiZWwnXG4gICAgICAgICAgKX1cbiAgICAgICAgPC9sYWJlbD5cbiAgICAgIDwvZGl2PlxuICAgICAgPGRpdiBjbGFzcz1cIm1vYmNiLWNvbnRyb2xzXCI+XG4gICAgICAgIDxkaXYgY2xhc3M9XCJtb2JjYi1tZXNzYWdlLWNvbnRhaW5lclwiPlxuICAgICAgICAgIDxkaXYgY2xhc3M9XCJtb2JjYi1ib3R0b20tbWVzc2FnZVwiPlxuICAgICAgICAgICAgPHNwYW4gY2xhc3M9XCJtb2JjYi1yYXRlLWxpbWl0ZWQgbW9iY2ItcmF0ZS1saW1pdGVkLW1zZ1wiIGhpZGRlbj5cbiAgICAgICAgICAgICAgJHtpMThtKCdjaGFpbmJsb2NrX3JhdGVfbGltaXRlZCcpfVxuICAgICAgICAgICAgPC9zcGFuPlxuICAgICAgICAgIDwvZGl2PlxuICAgICAgICAgIDxkaXYgY2xhc3M9XCJtb2JjYi1yYXRlLWxpbWl0ZWQgbW9iY2ItbGltaXQtc3RhdHVzXCIgaGlkZGVuPlxuICAgICAgICAgICAgJHtpMThtKCdjaGFpbmJsb2NrX3Jlc2V0X3RpbWVfbGFiZWwnKX06IDxzcGFuIGNsYXNzPVwicmVzZXR0aW1lXCI+PC9zcGFuPlxuICAgICAgICAgIDwvZGl2PlxuICAgICAgICA8L2Rpdj5cbiAgICAgICAgPGJ1dHRvbiBjbGFzcz1cIm1vYmNiLWNsb3NlIGJ0biBub3JtYWwtYnRuXCI+JHtpMThtKCdjbG9zZScpfTwvYnV0dG9uPlxuICAgICAgICA8YnV0dG9uIGRpc2FibGVkIGNsYXNzPVwibW9iY2ItZXhlY3V0ZSBidG4gY2F1dGlvbi1idG5cIj4ke2kxOG0oJ2Jsb2NrJyl9PC9idXR0b24+XG4gICAgICA8L2Rpdj5cbiAgICA8L2Rpdj5cbiAgPC9kaXY+XG5gXG5cbmZ1bmN0aW9uIGdldExpbWl0UmVzZXRUaW1lKGxpbWl0OiBMaW1pdCk6IHN0cmluZyB7XG4gIGNvbnN0IHVpTGFuZ3VhZ2UgPSBicm93c2VyLmkxOG4uZ2V0VUlMYW5ndWFnZSgpXG4gIGNvbnN0IHRpbWVab25lID0gSW50bC5EYXRlVGltZUZvcm1hdCgpLnJlc29sdmVkT3B0aW9ucygpLnRpbWVab25lXG4gIGNvbnN0IGZvcm1hdHRlciA9IG5ldyBJbnRsLkRhdGVUaW1lRm9ybWF0KHVpTGFuZ3VhZ2UsIHtcbiAgICB0aW1lWm9uZSxcbiAgICBob3VyOiAnMi1kaWdpdCcsXG4gICAgbWludXRlOiAnMi1kaWdpdCcsXG4gIH0pXG4gIC8vIDEyMDAwMCA9IDEwMDAgKiA2MCAqIDIgPSDrpqzrsIvsg4Htg5zsl5DshJwg7LK07J2467iU65297J2YIGRlbGF56rCE6rKpXG4gIGNvbnN0IGRhdGV0aW1lID0gbmV3IERhdGUobGltaXQucmVzZXQgKiAxMDAwICsgMTIwMDAwKVxuICByZXR1cm4gZm9ybWF0dGVyLmZvcm1hdChkYXRldGltZSlcbn1cblxuY2xhc3MgVXNlckxpc3Qge1xuICBwcml2YXRlIHJlYWRvbmx5IGl0ZW1zOiBNYXA8c3RyaW5nLCBIVE1MRWxlbWVudD4gPSBuZXcgTWFwKClcbiAgY29uc3RydWN0b3IocHJpdmF0ZSByb290RWxlbTogSFRNTEVsZW1lbnQpIHt9XG4gIHB1YmxpYyBnZXQgc2l6ZSgpOiBudW1iZXIge1xuICAgIHJldHVybiB0aGlzLml0ZW1zLnNpemVcbiAgfVxuICBwdWJsaWMgYWRkKGZvdW5kOiBGb3VuZFVzZXIpOiB2b2lkIHtcbiAgICBjb25zdCB1c2VyID0gZm91bmQudXNlclxuICAgIGlmICh0aGlzLml0ZW1zLmhhcyh1c2VyLmlkX3N0cikpIHtcbiAgICAgIHJldHVyblxuICAgIH1cbiAgICBsZXQgdXNlclByZWZpeCA9ICcnXG4gICAgaWYgKGZvdW5kLnN0YXRlID09PSAnYWxyZWFkeUJsb2NrZWQnKSB7XG4gICAgICB1c2VyUHJlZml4ID0gYFske2kxOG4uZ2V0TWVzc2FnZSgnYWxyZWFkeV9ibG9ja2VkJyl9XWBcbiAgICB9IGVsc2UgaWYgKGZvdW5kLnN0YXRlID09PSAnbXV0ZVNraXAnKSB7XG4gICAgICB1c2VyUHJlZml4ID0gYFske2kxOG4uZ2V0TWVzc2FnZSgnc2tpcHBlZCcpfV1gXG4gICAgfVxuICAgIGxldCB0b29sdGlwID0gYCR7dXNlclByZWZpeH0gQCR7dXNlci5zY3JlZW5fbmFtZX0gKCR7dXNlci5uYW1lfSlgXG4gICAgdG9vbHRpcCArPSBgXFwke2kxOG4uZ2V0TWVzc2FnZSgncHJvZmlsZScpfTpcXG4ke3VzZXIuZGVzY3JpcHRpb259YFxuICAgIGNvbnN0IHVsID0gdGhpcy5yb290RWxlbS5xdWVyeVNlbGVjdG9yKCd1bCcpIVxuICAgIGNvbnN0IGl0ZW0gPSBkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdsaScpXG4gICAgY29uc3QgbGluayA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoJ2EnKVxuICAgIGl0ZW0uY2xhc3NOYW1lID0gJ21vYmNiLXVzZXInXG4gICAgbGluay5ocmVmID0gYGh0dHBzOi8vdHdpdHRlci5jb20vJHt1c2VyLnNjcmVlbl9uYW1lfWBcbiAgICBpZiAobG9jYXRpb24uaG9zdG5hbWUgPT09ICdtb2JpbGUudHdpdHRlci5jb20nKSB7XG4gICAgICBsaW5rLmhvc3RuYW1lID0gJ21vYmlsZS50d2l0dGVyLmNvbSdcbiAgICB9XG4gICAgbGluay5zZXRBdHRyaWJ1dGUoJ3JlbCcsICdub3JlZmVyZXIgbm9vcGVuZXInKVxuICAgIGxpbmsuc2V0QXR0cmlidXRlKCd0YXJnZXQnLCAnX2JsYW5rJylcbiAgICBsaW5rLnNldEF0dHJpYnV0ZSgndGl0bGUnLCB0b29sdGlwKVxuICAgIGlmIChmb3VuZC5zdGF0ZSA9PT0gJ3Nob3VsZEJsb2NrJykge1xuICAgICAgbGluay5zdHlsZS5mb250V2VpZ2h0ID0gJ2JvbGQnXG4gICAgfVxuICAgIGxpbmsudGV4dENvbnRlbnQgPSBgJHt1c2VyUHJlZml4fSBAJHt1c2VyLnNjcmVlbl9uYW1lfTogJHt1c2VyLm5hbWV9YFxuICAgIGl0ZW0uYXBwZW5kQ2hpbGQobGluaylcbiAgICB1bC5hcHBlbmRDaGlsZChpdGVtKVxuICAgIHRoaXMuaXRlbXMuc2V0KHVzZXIuaWRfc3RyLCBpdGVtKVxuICB9XG4gIHB1YmxpYyB1cGRhdGVCbG9ja1Jlc3VsdCh1c2VyOiBUd2l0dGVyVXNlciwgc3VjY2VzczogYm9vbGVhbikge1xuICAgIGNvbnN0IGl0ZW0gPSB0aGlzLml0ZW1zLmdldCh1c2VyLmlkX3N0cilcbiAgICBpZiAoIWl0ZW0pIHtcbiAgICAgIHJldHVyblxuICAgIH1cbiAgICBpZiAoc3VjY2Vzcykge1xuICAgICAgaXRlbS5jbGFzc0xpc3QucmVtb3ZlKCdibG9jay1mYWlsZWQnKVxuICAgICAgaXRlbS5jbGFzc0xpc3QuYWRkKCdibG9jay1zdWNjZXNzJylcbiAgICB9IGVsc2Uge1xuICAgICAgaXRlbS5jbGFzc0xpc3QucmVtb3ZlKCdibG9jay1zdWNjZXNzJylcbiAgICAgIGl0ZW0uY2xhc3NMaXN0LmFkZCgnYmxvY2stZmFpbGVkJylcbiAgICB9XG4gIH1cbiAgcHVibGljIGNsZWFudXAoKSB7XG4gICAgdGhpcy5pdGVtcy5jbGVhcigpXG4gIH1cbn1cblxuZXhwb3J0IGRlZmF1bHQgY2xhc3MgQ2hhaW5NaXJyb3JCbG9ja1VJIGV4dGVuZHMgRXZlbnRFbWl0dGVyIHtcbiAgcHJpdmF0ZSByb290RWxlbSA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoJ2RpdicpXG4gIHByaXZhdGUgc2tpcHBlZFVzZXJMaXN0OiBVc2VyTGlzdFxuICBwcml2YXRlIGJsb2NrZWRieVVzZXJMaXN0OiBVc2VyTGlzdFxuICBwcml2YXRlIHRvdGFsID0gMFxuICBjb25zdHJ1Y3RvcigpIHtcbiAgICBzdXBlcigpXG4gICAgdGhpcy5yb290RWxlbS5pbm5lckhUTUwgPSBDSEFJTkJMT0NLX1VJX0hUTUxcbiAgICB0aGlzLnNraXBwZWRVc2VyTGlzdCA9IG5ldyBVc2VyTGlzdChcbiAgICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcjxIVE1MRWxlbWVudD4oJy5tb2JjYi1za2lwcGVkLXVzZXJzJykhXG4gICAgKVxuICAgIHRoaXMuYmxvY2tlZGJ5VXNlckxpc3QgPSBuZXcgVXNlckxpc3QoXG4gICAgICB0aGlzLnJvb3RFbGVtLnF1ZXJ5U2VsZWN0b3I8SFRNTEVsZW1lbnQ+KCcubW9iY2ItYmxvY2tlZGJ5LXVzZXJzJykhXG4gICAgKVxuICAgIGRvY3VtZW50LmJvZHkuYXBwZW5kQ2hpbGQodGhpcy5yb290RWxlbSlcbiAgICB0aGlzLmhhbmRsZUV2ZW50cygpXG4gIH1cbiAgcHVibGljIGNsb3NlKCkge1xuICAgIHRoaXMuY2xlYW51cFVzZXJMaXN0KClcbiAgICB0aGlzLnJvb3RFbGVtLnJlbW92ZSgpXG4gIH1cbiAgcHJpdmF0ZSBjbGVhbnVwVXNlckxpc3QoKSB7XG4gICAgdGhpcy5za2lwcGVkVXNlckxpc3QuY2xlYW51cCgpXG4gICAgdGhpcy5ibG9ja2VkYnlVc2VyTGlzdC5jbGVhbnVwKClcbiAgfVxuICBwcml2YXRlIGhhbmRsZUV2ZW50cygpIHtcbiAgICB0aGlzLnJvb3RFbGVtLmFkZEV2ZW50TGlzdGVuZXIoJ2NsaWNrJywgZXZlbnQgPT4ge1xuICAgICAgaWYgKCFldmVudC50YXJnZXQpIHtcbiAgICAgICAgcmV0dXJuXG4gICAgICB9XG4gICAgICBjb25zdCB0YXJnZXQgPSBldmVudC50YXJnZXQgYXMgSFRNTEVsZW1lbnRcbiAgICAgIGlmICh0YXJnZXQubWF0Y2hlcygnLm1vYmNiLWNsb3NlJykpIHtcbiAgICAgICAgdGhpcy5lbWl0KCd1aTpjbG9zZScpXG4gICAgICB9IGVsc2UgaWYgKHRhcmdldC5tYXRjaGVzKCcubW9iY2ItZXhlY3V0ZScpKSB7XG4gICAgICAgIHRoaXMuZW1pdCgndWk6ZXhlY3V0ZS1tdXR1YWwtYmxvY2snKVxuICAgICAgfVxuICAgIH0pXG4gIH1cbiAgcHVibGljIGdldCBpbW1lZGlhdGVseUJsb2NrTW9kZUNoZWNrZWQoKSB7XG4gICAgcmV0dXJuIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcjxIVE1MSW5wdXRFbGVtZW50PignI21vYmNiLWJsb2NrLWltbWVkaWF0ZWx5JykhLmNoZWNrZWRcbiAgfVxuICBwdWJsaWMgc2V0IGltbWVkaWF0ZWx5QmxvY2tNb2RlQ2hlY2tlZCh2YWx1ZTogYm9vbGVhbikge1xuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcjxIVE1MSW5wdXRFbGVtZW50PignI21vYmNiLWJsb2NrLWltbWVkaWF0ZWx5JykhLmNoZWNrZWQgPSB2YWx1ZVxuICB9XG4gIHB1YmxpYyBpbml0UHJvZ3Jlc3ModG90YWw6IG51bWJlcikge1xuICAgIHRoaXMudG90YWwgPSB0b3RhbFxuICAgIGNvbnN0IHByb2dyZXNzQmFyID0gdGhpcy5yb290RWxlbS5xdWVyeVNlbGVjdG9yPEhUTUxQcm9ncmVzc0VsZW1lbnQ+KCcubW9iY2ItcHJvZ3Jlc3MtYmFyJykhXG4gICAgcHJvZ3Jlc3NCYXIubWF4ID0gdG90YWxcbiAgICB0aGlzLnJvb3RFbGVtLnF1ZXJ5U2VsZWN0b3IoJy5tb2JjYi1wcmctdG90YWwnKSEudGV4dENvbnRlbnQgPSB0b3RhbC50b0xvY2FsZVN0cmluZygpXG4gIH1cbiAgcHVibGljIHVwZGF0ZUJsb2NrUmVzdWx0KHVzZXI6IFR3aXR0ZXJVc2VyLCBzdWNjZXNzOiBib29sZWFuKSB7XG4gICAgdGhpcy5ibG9ja2VkYnlVc2VyTGlzdC51cGRhdGVCbG9ja1Jlc3VsdCh1c2VyLCBzdWNjZXNzKVxuICB9XG4gIHB1YmxpYyByYXRlTGltaXRlZChsaW1pdDogTGltaXQpIHtcbiAgICB0aGlzLnJvb3RFbGVtLnF1ZXJ5U2VsZWN0b3JBbGw8SFRNTEVsZW1lbnQ+KCcubW9iY2ItcmF0ZS1saW1pdGVkJykuZm9yRWFjaChlbGVtID0+IHtcbiAgICAgIGVsZW0uaGlkZGVuID0gZmFsc2VcbiAgICB9KVxuICAgIGNvbnN0IHJlc2V0dGltZSA9IGdldExpbWl0UmVzZXRUaW1lKGxpbWl0KVxuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcignLm1vYmNiLWxpbWl0LXN0YXR1cyAucmVzZXR0aW1lJykhLnRleHRDb250ZW50ID0gcmVzZXR0aW1lXG4gIH1cbiAgcHVibGljIHJhdGVMaW1pdFJlc2V0dGVkKCkge1xuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvckFsbDxIVE1MRWxlbWVudD4oJy5tb2JjYi1yYXRlLWxpbWl0ZWQnKS5mb3JFYWNoKGVsZW0gPT4ge1xuICAgICAgZWxlbS5oaWRkZW4gPSB0cnVlXG4gICAgfSlcbiAgfVxuICBwdWJsaWMgdXBkYXRlUHJvZ3Jlc3MocHJvZ3Jlc3M6IENoYWluTWlycm9yQmxvY2tQcm9ncmVzcykge1xuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcignLm1vYmNiLXRpdGxlLXN0YXR1cycpIS50ZXh0Q29udGVudCA9IGAoJHtpMThuLmdldE1lc3NhZ2UoXG4gICAgICAnc2NyYXBlX3J1bm5pbmcnXG4gICAgKX0pYFxuICAgIHByb2dyZXNzLmZvdW5kVXNlcnNcbiAgICAgIC5maWx0ZXIoZm91bmQgPT4gZm91bmQuc3RhdGUgPT09ICdzaG91bGRCbG9jaycpXG4gICAgICAuZm9yRWFjaChmb3VuZCA9PiB0aGlzLmJsb2NrZWRieVVzZXJMaXN0LmFkZChmb3VuZCkpXG4gICAgcHJvZ3Jlc3MuZm91bmRVc2Vyc1xuICAgICAgLmZpbHRlcihmb3VuZCA9PiBmb3VuZC5zdGF0ZSA9PT0gJ211dGVTa2lwJyB8fCBmb3VuZC5zdGF0ZSA9PT0gJ2FscmVhZHlCbG9ja2VkJylcbiAgICAgIC5mb3JFYWNoKGZvdW5kID0+IHRoaXMuc2tpcHBlZFVzZXJMaXN0LmFkZChmb3VuZCkpXG4gICAgY29uc3QgcHJvZ3Jlc3NCYXIgPSB0aGlzLnJvb3RFbGVtLnF1ZXJ5U2VsZWN0b3I8SFRNTFByb2dyZXNzRWxlbWVudD4oJy5tb2JjYi1wcm9ncmVzcy1iYXInKSFcbiAgICBwcm9ncmVzc0Jhci52YWx1ZSA9IHByb2dyZXNzLnNjcmFwZWRcbiAgICBjb25zdCBwZXJjZW50YWdlID0gTWF0aC5yb3VuZCgocHJvZ3Jlc3Muc2NyYXBlZCAvIHRoaXMudG90YWwpICogMTAwKVxuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcignLm1vYmNiLXByZy1wZXJjZW50YWdlJykhLnRleHRDb250ZW50ID0gcGVyY2VudGFnZS50b1N0cmluZygpXG4gICAgdGhpcy5yb290RWxlbS5xdWVyeVNlbGVjdG9yKFxuICAgICAgJy5tb2JjYi1wcmctc2NyYXBlZCdcbiAgICApIS50ZXh0Q29udGVudCA9IHByb2dyZXNzLnNjcmFwZWQudG9Mb2NhbGVTdHJpbmcoKVxuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcihcbiAgICAgICcubW9iY2ItcHJnLWZvdW5kJ1xuICAgICkhLnRleHRDb250ZW50ID0gcHJvZ3Jlc3MuZm91bmRVc2Vycy5sZW5ndGgudG9Mb2NhbGVTdHJpbmcoKVxuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcjxIVE1MRWxlbWVudD4oJy5tb2JjYi1wcm9ncmVzcy10ZXh0JykhLmhpZGRlbiA9IGZhbHNlXG4gIH1cbiAgcHJpdmF0ZSBjb21wbGV0ZVByb2dyZXNzVUkocHJvZ3Jlc3M6IENoYWluTWlycm9yQmxvY2tQcm9ncmVzcykge1xuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcignLm1vYmNiLXRpdGxlLXN0YXR1cycpIS50ZXh0Q29udGVudCA9IGAoJHtpMThuLmdldE1lc3NhZ2UoXG4gICAgICAnc2NyYXBlX2NvbXBsZXRlZCdcbiAgICApfSlgXG4gICAgY29uc3Qgc2hvdWxkQmxvY2tzID0gcHJvZ3Jlc3MuZm91bmRVc2Vycy5maWx0ZXIodXNlciA9PiB1c2VyLnN0YXRlID09PSAnc2hvdWxkQmxvY2snKVxuICAgIGNvbnN0IGV4ZWN1dGVCdXR0b24gPSB0aGlzLnJvb3RFbGVtLnF1ZXJ5U2VsZWN0b3I8SFRNTEJ1dHRvbkVsZW1lbnQ+KCcubW9iY2ItZXhlY3V0ZScpIVxuICAgIGlmIChzaG91bGRCbG9ja3MubGVuZ3RoID4gMCkge1xuICAgICAgZXhlY3V0ZUJ1dHRvbi5kaXNhYmxlZCA9IGZhbHNlXG4gICAgfSBlbHNlIHtcbiAgICAgIGV4ZWN1dGVCdXR0b24udGl0bGUgPSBpMThuLmdldE1lc3NhZ2UoJ25vX2Jsb2NrYWJsZV91c2VyJylcbiAgICB9XG4gICAgdGhpcy5yb290RWxlbS5xdWVyeVNlbGVjdG9yPEhUTUxJbnB1dEVsZW1lbnQ+KCcjbW9iY2ItYmxvY2staW1tZWRpYXRlbHknKSEuZGlzYWJsZWQgPSB0cnVlXG4gICAgdGhpcy5yb290RWxlbS5xdWVyeVNlbGVjdG9yKCcubW9iY2ItcHJnLXNjcmFwZWQnKSEudGV4dENvbnRlbnQgPSB0aGlzLnRvdGFsLnRvTG9jYWxlU3RyaW5nKClcbiAgICBjb25zdCBwcm9ncmVzc0JhciA9IHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcjxIVE1MUHJvZ3Jlc3NFbGVtZW50PignLm1vYmNiLXByb2dyZXNzLWJhcicpIVxuICAgIHByb2dyZXNzQmFyLnZhbHVlID0gcHJvZ3Jlc3NCYXIubWF4XG4gICAgdGhpcy5yb290RWxlbS5xdWVyeVNlbGVjdG9yKCcubW9iY2ItcHJnLXBlcmNlbnRhZ2UnKSEudGV4dENvbnRlbnQgPSAnMTAwJ1xuICB9XG4gIHB1YmxpYyBjb21wbGV0ZShwcm9ncmVzczogQ2hhaW5NaXJyb3JCbG9ja1Byb2dyZXNzKSB7XG4gICAgdGhpcy5jb21wbGV0ZVByb2dyZXNzVUkocHJvZ3Jlc3MpXG4gICAgaWYgKHByb2dyZXNzLmZvdW5kVXNlcnMubGVuZ3RoIDw9IDApIHtcbiAgICAgIC8vIHNsZWVwOiBwcm9ncmVzc+qwgCAxMDAl65CY6riwIOyghOyXkCDrqZTsi5zsp4DqsIAg65yo66mwIOuLq+2eiOuKlCDtmITsg4Eg67Cp7KeAXG4gICAgICBzbGVlcCgxMDApLnRoZW4oKCkgPT4ge1xuICAgICAgICB3aW5kb3cuYWxlcnQoaTE4bi5nZXRNZXNzYWdlKCdub2JvZHlfYmxvY2tzX3lvdScpKVxuICAgICAgICB0aGlzLmVtaXQoJ3VpOmNsb3NlLXdpdGhvdXQtY29uZmlybScpXG4gICAgICB9KVxuICAgIH1cbiAgfVxuICBwdWJsaWMgc3RhcnRNdXR1YWxCbG9jaygpIHtcbiAgICB0aGlzLnJvb3RFbGVtLnF1ZXJ5U2VsZWN0b3IoJy5tb2JjYi10aXRsZS1zdGF0dXMnKSEudGV4dENvbnRlbnQgPSBgKCR7aTE4bi5nZXRNZXNzYWdlKFxuICAgICAgJ2Jsb2NrX3J1bm5pbmcnXG4gICAgKX0pYFxuICAgIHRoaXMucm9vdEVsZW0ucXVlcnlTZWxlY3RvcjxIVE1MQnV0dG9uRWxlbWVudD4oJy5tb2JjYi1leGVjdXRlLmJ0bicpIS5kaXNhYmxlZCA9IHRydWVcbiAgfVxuICBwdWJsaWMgY29tcGxldGVNdXR1YWxCbG9jaygpIHtcbiAgICB0aGlzLnJvb3RFbGVtLnF1ZXJ5U2VsZWN0b3IoJy5tb2JjYi10aXRsZS1zdGF0dXMnKSEudGV4dENvbnRlbnQgPSBgKCR7aTE4bi5nZXRNZXNzYWdlKFxuICAgICAgJ2Jsb2NrX2NvbXBsZXRlZCdcbiAgICApfSlgXG4gIH1cbn1cbiIsImltcG9ydCAqIGFzIE9wdGlvbnMgZnJvbSAn66+465+s67iU6529L2V4dG9wdGlvbidcbmltcG9ydCB7IEFQSUVycm9yIH0gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvdHdpdHRlci1hcGknXG5pbXBvcnQgeyBBY3Rpb24sIHNsZWVwLCBjb3B5RnJvemVuT2JqZWN0IH0gZnJvbSAn66+465+s67iU6529L3NjcmlwdHMvY29tbW9uJ1xuaW1wb3J0IENoYWluTWlycm9yQmxvY2tVSSBmcm9tICcuL2NoYWluYmxvY2stdWknXG5pbXBvcnQgKiBhcyBUd2l0dGVyQVBJIGZyb20gJ+uvuOufrOu4lOudvS9zY3JpcHRzL3R3aXR0ZXItYXBpJ1xuaW1wb3J0ICogYXMgaTE4biBmcm9tICfrr7jrn6zruJTrnb0vc2NyaXB0cy9pMThuJ1xuXG5jbGFzcyBDaGFpbk1pcnJvckJsb2NrIHtcbiAgcHJpdmF0ZSByZWFkb25seSB1aSA9IG5ldyBDaGFpbk1pcnJvckJsb2NrVUkoKVxuICBwcml2YXRlIGdldCBpbW1lZGlhdGVseUJsb2NrTW9kZSgpOiBib29sZWFuIHtcbiAgICByZXR1cm4gdGhpcy51aS5pbW1lZGlhdGVseUJsb2NrTW9kZUNoZWNrZWRcbiAgfVxuICBwcml2YXRlIHJlYWRvbmx5IGJsb2NrUmVzdWx0czogTWFwPHN0cmluZywgQmxvY2tSZXN1bHQ+ID0gbmV3IE1hcCgpXG4gIHByaXZhdGUgcmVhZG9ubHkgcHJvZ3Jlc3M6IENoYWluTWlycm9yQmxvY2tQcm9ncmVzcyA9IHtcbiAgICBzY3JhcGVkOiAwLFxuICAgIGZvdW5kVXNlcnM6IFtdLFxuICB9XG4gIHByaXZhdGUgaXNSdW5uaW5nID0gZmFsc2VcbiAgcHJpdmF0ZSBzaG91bGRTdG9wID0gZmFsc2VcbiAgY29uc3RydWN0b3IocHJpdmF0ZSBvcHRpb25zOiBNaXJyb3JCbG9ja09wdGlvbikge1xuICAgIHRoaXMucHJlcGFyZVVJKClcbiAgfVxuICBwcml2YXRlIGNsZWFudXAoKSB7XG4gICAgdGhpcy5ibG9ja1Jlc3VsdHMuY2xlYXIoKVxuICAgIHRoaXMucHJvZ3Jlc3MuZm91bmRVc2Vycy5sZW5ndGggPSAwXG4gIH1cbiAgcHJpdmF0ZSBwcmVwYXJlVUkoKSB7XG4gICAgdGhpcy51aS5pbW1lZGlhdGVseUJsb2NrTW9kZUNoZWNrZWQgPSB0aGlzLm9wdGlvbnMuYWx3YXlzSW1tZWRpYXRlbHlCbG9ja01vZGVcbiAgICB3aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcignYmVmb3JldW5sb2FkJywgZXZlbnQgPT4ge1xuICAgICAgaWYgKCF0aGlzLmlzUnVubmluZykge1xuICAgICAgICByZXR1cm5cbiAgICAgIH1cbiAgICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KClcbiAgICAgIGNvbnN0IG1lc3NhZ2UgPSBgW01pcnJvciBCbG9ja10gJHtpMThuLmdldE1lc3NhZ2UoJ3dhcm5pbmdfYmVmb3JlX2Nsb3NlJyl9YFxuICAgICAgZXZlbnQucmV0dXJuVmFsdWUgPSBtZXNzYWdlXG4gICAgICByZXR1cm4gbWVzc2FnZVxuICAgIH0pXG4gICAgdGhpcy51aS5vbigndWk6Y2xvc2UnLCAoKSA9PiB7XG4gICAgICBjb25zdCBjb25maXJtTWVzc2FnZSA9IGkxOG4uZ2V0TWVzc2FnZSgnY2hhaW5ibG9ja19zdGlsbF9ydW5uaW5nJylcbiAgICAgIGlmICh0aGlzLmlzUnVubmluZyAmJiB3aW5kb3cuY29uZmlybShjb25maXJtTWVzc2FnZSkpIHtcbiAgICAgICAgdGhpcy5zdG9wQW5kQ2xvc2UoKVxuICAgICAgfSBlbHNlIGlmICghdGhpcy5pc1J1bm5pbmcpIHtcbiAgICAgICAgdGhpcy5zdG9wQW5kQ2xvc2UoKVxuICAgICAgfVxuICAgIH0pXG4gICAgdGhpcy51aS5vbigndWk6Y2xvc2Utd2l0aG91dC1jb25maXJtJywgKCkgPT4ge1xuICAgICAgdGhpcy5zdG9wQW5kQ2xvc2UoKVxuICAgIH0pXG4gICAgdGhpcy51aS5vbigndWk6ZXhlY3V0ZS1tdXR1YWwtYmxvY2snLCAoKSA9PiB7XG4gICAgICBjb25zdCBzaG91bGRCbG9ja3MgPSB0aGlzLnByb2dyZXNzLmZvdW5kVXNlcnMuZmlsdGVyKHVzZXIgPT4gdXNlci5zdGF0ZSA9PT0gJ3Nob3VsZEJsb2NrJylcbiAgICAgIGlmIChzaG91bGRCbG9ja3MubGVuZ3RoID4gMCkge1xuICAgICAgICBjb25zdCBjb25maXJtTWVzc2FnZSA9IGkxOG4uZ2V0TWVzc2FnZSgnY29uZmlybV9tdXR1YWxfYmxvY2snLCBzaG91bGRCbG9ja3MubGVuZ3RoKVxuICAgICAgICBpZiAoIXdpbmRvdy5jb25maXJtKGNvbmZpcm1NZXNzYWdlKSkge1xuICAgICAgICAgIHJldHVyblxuICAgICAgICB9XG4gICAgICAgIHRoaXMuZXhlY3V0ZU11dHVhbEJsb2NrKClcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHdpbmRvdy5hbGVydChpMThuLmdldE1lc3NhZ2UoJ25vX3VzZXJzX3RvX211dHVhbF9ibG9jaycpKVxuICAgICAgfVxuICAgIH0pXG4gIH1cbiAgcHVibGljIHN0b3BBbmRDbG9zZSgpIHtcbiAgICB0aGlzLnNob3VsZFN0b3AgPSB0cnVlXG4gICAgdGhpcy5jbGVhbnVwKClcbiAgICB0aGlzLnVpLmNsb3NlKClcbiAgfVxuICBwcml2YXRlIHByb2Nlc3NJbW1lZGlhdGVseUJsb2NrTW9kZSgpIHtcbiAgICBpZiAoIXRoaXMuaW1tZWRpYXRlbHlCbG9ja01vZGUpIHtcbiAgICAgIHJldHVyblxuICAgIH1cbiAgICBjb25zdCB1c2Vyc1RvQmxvY2sgPSB0aGlzLnByb2dyZXNzLmZvdW5kVXNlcnMuZmlsdGVyKGZvdW5kID0+IHtcbiAgICAgIHJldHVybiBmb3VuZC5zdGF0ZSA9PT0gJ3Nob3VsZEJsb2NrJyAmJiB0aGlzLmJsb2NrUmVzdWx0cy5nZXQoZm91bmQudXNlci5pZF9zdHIpID09PSAnbm90WWV0J1xuICAgIH0pXG4gICAgdXNlcnNUb0Jsb2NrLmZvckVhY2goKHsgdXNlciB9KSA9PiB7XG4gICAgICB0aGlzLmJsb2NrUmVzdWx0cy5zZXQodXNlci5pZF9zdHIsICdwZW5kaW5nJylcbiAgICB9KVxuICAgIGNvbnN0IGltbUJsb2NrUHJvbWlzZXMgPSB1c2Vyc1RvQmxvY2subWFwKGFzeW5jICh7IHVzZXIgfSkgPT4ge1xuICAgICAgcmV0dXJuIFR3aXR0ZXJBUEkuYmxvY2tVc2VyKHVzZXIpXG4gICAgICAgIC50aGVuKGJsb2NrZWQgPT4ge1xuICAgICAgICAgIGNvbnN0IGJyZXN1bHQ6IEJsb2NrUmVzdWx0ID0gYmxvY2tlZCA/ICdibG9ja1N1Y2Nlc3MnIDogJ2Jsb2NrRmFpbGVkJ1xuICAgICAgICAgIHRoaXMuYmxvY2tSZXN1bHRzLnNldCh1c2VyLmlkX3N0ciwgYnJlc3VsdClcbiAgICAgICAgICByZXR1cm4gYmxvY2tlZFxuICAgICAgICB9KVxuICAgICAgICAuY2F0Y2goZXJyID0+IHtcbiAgICAgICAgICBjb25zb2xlLmVycm9yKCdmYWlsZWQgdG8gYmxvY2s6JywgZXJyKVxuICAgICAgICAgIHRoaXMuYmxvY2tSZXN1bHRzLnNldCh1c2VyLmlkX3N0ciwgJ2Jsb2NrRmFpbGVkJylcbiAgICAgICAgICByZXR1cm4gZmFsc2VcbiAgICAgICAgfSlcbiAgICAgICAgLnRoZW4ocmVzdWx0ID0+IHtcbiAgICAgICAgICB0aGlzLnVpLnVwZGF0ZUJsb2NrUmVzdWx0KHVzZXIsIHJlc3VsdClcbiAgICAgICAgfSlcbiAgICB9KVxuICAgIFByb21pc2UuYWxsKGltbUJsb2NrUHJvbWlzZXMpXG4gIH1cbiAgcHVibGljIGFzeW5jIHN0YXJ0KHRhcmdldFVzZXI6IFR3aXR0ZXJVc2VyLCBmb2xsb3dLaW5kOiBGb2xsb3dLaW5kKSB7XG4gICAgdGhpcy5pc1J1bm5pbmcgPSB0cnVlXG4gICAgdHJ5IHtcbiAgICAgIGlmICh0YXJnZXRVc2VyLmJsb2NrZWRfYnkpIHtcbiAgICAgICAgd2luZG93LmFsZXJ0KGkxOG4uZ2V0TWVzc2FnZSgnY2FudF9jaGFpbmJsb2NrX3RoZXlfYmxvY2tzX3lvdScsIHRhcmdldFVzZXIuc2NyZWVuX25hbWUpKVxuICAgICAgICB0aGlzLnN0b3BBbmRDbG9zZSgpXG4gICAgICAgIHJldHVyblxuICAgICAgfVxuICAgICAgY29uc3QgdXBkYXRlUHJvZ3Jlc3MgPSAoKSA9PiB7XG4gICAgICAgIHRoaXMudWkudXBkYXRlUHJvZ3Jlc3MoY29weUZyb3plbk9iamVjdCh0aGlzLnByb2dyZXNzKSlcbiAgICAgIH1cbiAgICAgIGNvbnN0IGNsYXNzaWZ5VXNlclN0YXRlID0gKHVzZXI6IFR3aXR0ZXJVc2VyKTogVXNlclN0YXRlID0+IHtcbiAgICAgICAgaWYgKHVzZXIuYmxvY2tpbmcpIHtcbiAgICAgICAgICByZXR1cm4gJ2FscmVhZHlCbG9ja2VkJ1xuICAgICAgICB9XG4gICAgICAgIGlmICh1c2VyLm11dGluZyAmJiAhdGhpcy5vcHRpb25zLmJsb2NrTXV0ZWRVc2VyKSB7XG4gICAgICAgICAgcmV0dXJuICdtdXRlU2tpcCdcbiAgICAgICAgfVxuICAgICAgICBpZiAodXNlci5ibG9ja2VkX2J5KSB7XG4gICAgICAgICAgcmV0dXJuICdzaG91bGRCbG9jaydcbiAgICAgICAgfVxuICAgICAgICB0aHJvdyBuZXcgRXJyb3IoYHVucmVhY2hhYmxlOiBpbnZhbGlkIHVzZXIgc3RhdGU/ICgke3VzZXIuaWRfc3RyfTpAJHt1c2VyLnNjcmVlbl9uYW1lfSlgKVxuICAgICAgfVxuICAgICAgY29uc3QgYWRkVXNlclRvRm91bmRlZCA9IChmb2xsb3dlcjogVHdpdHRlclVzZXIpID0+IHtcbiAgICAgICAgY29uc3QgdXNlclN0YXRlID0gY2xhc3NpZnlVc2VyU3RhdGUoZm9sbG93ZXIpXG4gICAgICAgIHRoaXMucHJvZ3Jlc3MuZm91bmRVc2Vycy5wdXNoKHtcbiAgICAgICAgICB1c2VyOiBmb2xsb3dlcixcbiAgICAgICAgICBzdGF0ZTogdXNlclN0YXRlLFxuICAgICAgICB9KVxuICAgICAgICB0aGlzLmJsb2NrUmVzdWx0cy5zZXQoZm9sbG93ZXIuaWRfc3RyLCAnbm90WWV0JylcbiAgICAgICAgdXBkYXRlUHJvZ3Jlc3MoKVxuICAgICAgfVxuICAgICAgY29uc3QgdG90YWwgPSBnZXRUb3RhbEZvbGxvd3ModGFyZ2V0VXNlciwgZm9sbG93S2luZClcbiAgICAgIHRoaXMudWkuaW5pdFByb2dyZXNzKHRvdGFsKVxuICAgICAgY29uc3QgZGVsYXkgPSB0b3RhbCA+IDFlNCA/IDk1MCA6IDMwMFxuICAgICAgY29uc3Qgc2NyYXBlciA9IFR3aXR0ZXJBUEkuZ2V0QWxsRm9sbG93cyh0YXJnZXRVc2VyLCBmb2xsb3dLaW5kLCB7XG4gICAgICAgIGRlbGF5LFxuICAgICAgfSlcbiAgICAgIGxldCByYXRlTGltaXRlZCA9IGZhbHNlXG4gICAgICBmb3IgYXdhaXQgKGNvbnN0IG1heWJlRm9sbG93ZXIgb2Ygc2NyYXBlcikge1xuICAgICAgICBpZiAodGhpcy5zaG91bGRTdG9wKSB7XG4gICAgICAgICAgYnJlYWtcbiAgICAgICAgfVxuICAgICAgICBpZiAoIW1heWJlRm9sbG93ZXIub2spIHtcbiAgICAgICAgICBjb25zdCB7IGVycm9yIH0gPSBtYXliZUZvbGxvd2VyXG4gICAgICAgICAgaWYgKGVycm9yLnJlc3BvbnNlLnN0YXR1cyA9PT0gNDI5KSB7XG4gICAgICAgICAgICByYXRlTGltaXRlZCA9IHRydWVcbiAgICAgICAgICAgIFR3aXR0ZXJBUEkuZ2V0Rm9sbG93c1NjcmFwZXJSYXRlTGltaXRTdGF0dXMoZm9sbG93S2luZCkudGhlbih0aGlzLnVpLnJhdGVMaW1pdGVkKVxuICAgICAgICAgICAgYXdhaXQgc2xlZXAoMTAwMCAqIDYwICogMilcbiAgICAgICAgICAgIGNvbnRpbnVlXG4gICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgIGNvbnNvbGUuZXJyb3IoZXJyb3IpXG4gICAgICAgICAgICBicmVha1xuICAgICAgICAgIH1cbiAgICAgICAgfVxuICAgICAgICBjb25zdCBmb2xsb3dlciA9IG1heWJlRm9sbG93ZXIudmFsdWVcbiAgICAgICAgaWYgKHJhdGVMaW1pdGVkKSB7XG4gICAgICAgICAgcmF0ZUxpbWl0ZWQgPSBmYWxzZVxuICAgICAgICAgIHRoaXMudWkucmF0ZUxpbWl0UmVzZXR0ZWQoKVxuICAgICAgICB9XG4gICAgICAgICsrdGhpcy5wcm9ncmVzcy5zY3JhcGVkXG4gICAgICAgIHVwZGF0ZVByb2dyZXNzKClcbiAgICAgICAgaWYgKCFmb2xsb3dlci5ibG9ja2VkX2J5KSB7XG4gICAgICAgICAgY29udGludWVcbiAgICAgICAgfVxuICAgICAgICBhZGRVc2VyVG9Gb3VuZGVkKGZvbGxvd2VyKVxuICAgICAgICB0aGlzLnByb2Nlc3NJbW1lZGlhdGVseUJsb2NrTW9kZSgpXG4gICAgICB9XG4gICAgICBpZiAoIXRoaXMuc2hvdWxkU3RvcCkge1xuICAgICAgICB0aGlzLnVpLmNvbXBsZXRlKGNvcHlGcm96ZW5PYmplY3QodGhpcy5wcm9ncmVzcykpXG4gICAgICB9XG4gICAgfSBmaW5hbGx5IHtcbiAgICAgIHRoaXMuaXNSdW5uaW5nID0gZmFsc2VcbiAgICAgIHRoaXMuc2hvdWxkU3RvcCA9IGZhbHNlXG4gICAgfVxuICB9XG4gIHB1YmxpYyBhc3luYyBleGVjdXRlTXV0dWFsQmxvY2soKSB7XG4gICAgdGhpcy5pc1J1bm5pbmcgPSB0cnVlXG4gICAgdHJ5IHtcbiAgICAgIHRoaXMudWkuc3RhcnRNdXR1YWxCbG9jaygpXG4gICAgICBjb25zdCB1c2Vyc1RvQmxvY2sgPSB0aGlzLnByb2dyZXNzLmZvdW5kVXNlcnNcbiAgICAgICAgLmZpbHRlcihmdSA9PiBmdS5zdGF0ZSA9PT0gJ3Nob3VsZEJsb2NrJylcbiAgICAgICAgLm1hcChmdSA9PiBmdS51c2VyKVxuICAgICAgICAuZmlsdGVyKHVzZXIgPT4gdGhpcy5ibG9ja1Jlc3VsdHMuZ2V0KHVzZXIuaWRfc3RyKSA9PT0gJ25vdFlldCcpXG4gICAgICBjb25zdCBibG9ja1Byb21pc2VzID0gUHJvbWlzZS5hbGwoXG4gICAgICAgIHVzZXJzVG9CbG9jay5tYXAodXNlciA9PiB7XG4gICAgICAgICAgcmV0dXJuIFR3aXR0ZXJBUEkuYmxvY2tVc2VyKHVzZXIpXG4gICAgICAgICAgICAudGhlbihibG9ja2VkID0+IHtcbiAgICAgICAgICAgICAgY29uc3QgYnJlc3VsdDogQmxvY2tSZXN1bHQgPSBibG9ja2VkID8gJ2Jsb2NrU3VjY2VzcycgOiAnYmxvY2tGYWlsZWQnXG4gICAgICAgICAgICAgIHRoaXMuYmxvY2tSZXN1bHRzLnNldCh1c2VyLmlkX3N0ciwgYnJlc3VsdClcbiAgICAgICAgICAgICAgcmV0dXJuIGJsb2NrZWRcbiAgICAgICAgICAgIH0pXG4gICAgICAgICAgICAuY2F0Y2goZXJyID0+IHtcbiAgICAgICAgICAgICAgY29uc29sZS5lcnJvcignZmFpbGVkIHRvIGJsb2NrOicsIGVycilcbiAgICAgICAgICAgICAgdGhpcy5ibG9ja1Jlc3VsdHMuc2V0KHVzZXIuaWRfc3RyLCAnYmxvY2tGYWlsZWQnKVxuICAgICAgICAgICAgICByZXR1cm4gZmFsc2VcbiAgICAgICAgICAgIH0pXG4gICAgICAgICAgICAudGhlbihyZXN1bHQgPT4ge1xuICAgICAgICAgICAgICB0aGlzLnVpLnVwZGF0ZUJsb2NrUmVzdWx0KHVzZXIsIHJlc3VsdClcbiAgICAgICAgICAgIH0pXG4gICAgICAgIH0pXG4gICAgICApXG4gICAgICBhd2FpdCBibG9ja1Byb21pc2VzXG4gICAgICB0aGlzLnVpLmNvbXBsZXRlTXV0dWFsQmxvY2soKVxuICAgIH0gZmluYWxseSB7XG4gICAgICB0aGlzLmlzUnVubmluZyA9IGZhbHNlXG4gICAgICB0aGlzLnNob3VsZFN0b3AgPSBmYWxzZVxuICAgIH1cbiAgfVxufVxuXG5mdW5jdGlvbiBnZXRUb3RhbEZvbGxvd3ModXNlcjogVHdpdHRlclVzZXIsIGZvbGxvd0tpbmQ6IEZvbGxvd0tpbmQpOiBudW1iZXIge1xuICBpZiAoZm9sbG93S2luZCA9PT0gJ2ZvbGxvd2VycycpIHtcbiAgICByZXR1cm4gdXNlci5mb2xsb3dlcnNfY291bnRcbiAgfSBlbHNlIGlmIChmb2xsb3dLaW5kID09PSAnZm9sbG93aW5nJykge1xuICAgIHJldHVybiB1c2VyLmZyaWVuZHNfY291bnRcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3VucmVhY2hhYmxlJylcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gc3RhcnRDaGFpbkJsb2NrKHRhcmdldFVzZXJOYW1lOiBzdHJpbmcsIGZvbGxvd0tpbmQ6IEZvbGxvd0tpbmQpIHtcbiAgY29uc3QgYWxyZWFkeVJ1bm5pbmcgPSBkb2N1bWVudC5xdWVyeVNlbGVjdG9yKCcubW9iY2ctYmcnKVxuICBpZiAoYWxyZWFkeVJ1bm5pbmcpIHtcbiAgICB3aW5kb3cuYWxlcnQoaTE4bi5nZXRNZXNzYWdlKCdjaGFpbmJsb2NrX2FscmVhZHlfcnVubmluZycpKVxuICAgIHJldHVyblxuICB9XG4gIGNvbnN0IG15c2VsZiA9IGF3YWl0IFR3aXR0ZXJBUEkuZ2V0TXlzZWxmKCkgLy8uY2F0Y2goKCkgPT4gbnVsbClcbiAgaWYgKCFteXNlbGYpIHtcbiAgICB3aW5kb3cuYWxlcnQoaTE4bi5nZXRNZXNzYWdlKCdwbGVhc2VfY2hlY2tfbG9naW5fYmVmb3JlX2NoYWluYmxvY2snKSlcbiAgICByZXR1cm5cbiAgfVxuICBjb25zdCB0YXJnZXRVc2VyID0gYXdhaXQgVHdpdHRlckFQSS5nZXRTaW5nbGVVc2VyQnlOYW1lKHRhcmdldFVzZXJOYW1lKS5jYXRjaChlcnIgPT4ge1xuICAgIGlmIChlcnIgaW5zdGFuY2VvZiBBUElFcnJvcikge1xuICAgICAgY29uc3QganNvbiA9IGVyci5yZXNwb25zZS5ib2R5XG4gICAgICBjb25zdCBqc29uc3RyID0gSlNPTi5zdHJpbmdpZnkoanNvbiwgbnVsbCwgMilcbiAgICAgIHdpbmRvdy5hbGVydChgJHtpMThuLmdldE1lc3NhZ2UoJ2Vycm9yX29jY3VyZWRfZnJvbV90d2l0dGVyX3NlcnZlcicpfVxcbiR7anNvbnN0cn1gKVxuICAgIH0gZWxzZSBpZiAoZXJyIGluc3RhbmNlb2YgRXJyb3IpIHtcbiAgICAgIHdpbmRvdy5hbGVydChgJHtpMThuLmdldE1lc3NhZ2UoJ2Vycm9yX29jY3VyZWQnKX1cXG4ke2Vyci5tZXNzYWdlfWApXG4gICAgfVxuICAgIHJldHVybiBudWxsXG4gIH0pXG4gIGlmICghdGFyZ2V0VXNlcikge1xuICAgIHJldHVyblxuICB9XG4gIGNvbnN0IGZvbGxvd3NDb3VudCA9IGdldFRvdGFsRm9sbG93cyh0YXJnZXRVc2VyLCBmb2xsb3dLaW5kKVxuICBpZiAoZm9sbG93c0NvdW50IDw9IDApIHtcbiAgICB3aW5kb3cuYWxlcnQoaTE4bi5nZXRNZXNzYWdlKCdub2JvZHlfZm9sbG93c190aGVtJykpXG4gICAgcmV0dXJuXG4gIH1cbiAgaWYgKHRhcmdldFVzZXIucHJvdGVjdGVkKSB7XG4gICAgY29uc3QgcmVsYXRpb25zaGlwID0gYXdhaXQgVHdpdHRlckFQSS5nZXRSZWxhdGlvbnNoaXAobXlzZWxmLCB0YXJnZXRVc2VyKVxuICAgIGNvbnN0IHsgZm9sbG93aW5nIH0gPSByZWxhdGlvbnNoaXAuc291cmNlXG4gICAgaWYgKCFmb2xsb3dpbmcpIHtcbiAgICAgIHdpbmRvdy5hbGVydChpMThuLmdldE1lc3NhZ2UoJ2NhbnRfY2hhaW5ibG9ja190aGV5X3Byb3RlY3RlZCcsIHRhcmdldFVzZXJOYW1lKSlcbiAgICAgIHJldHVyblxuICAgIH1cbiAgfVxuICBsZXQgY29uZmlybU1lc3NhZ2U6IHN0cmluZ1xuICBzd2l0Y2ggKGZvbGxvd0tpbmQpIHtcbiAgICBjYXNlICdmb2xsb3dlcnMnOlxuICAgICAgY29uZmlybU1lc3NhZ2UgPSBpMThuLmdldE1lc3NhZ2UoJ2NvbmZpcm1fY2hhaW5ibG9ja190b19mb2xsb3dlcnMnLCB0YXJnZXRVc2VyLnNjcmVlbl9uYW1lKVxuICAgICAgYnJlYWtcbiAgICBjYXNlICdmb2xsb3dpbmcnOlxuICAgICAgY29uZmlybU1lc3NhZ2UgPSBpMThuLmdldE1lc3NhZ2UoJ2NvbmZpcm1fY2hhaW5ibG9ja190b19mb2xsb3dpbmcnLCB0YXJnZXRVc2VyLnNjcmVlbl9uYW1lKVxuICAgICAgYnJlYWtcbiAgfVxuICBsZXQgY29uZmlybWVkID0gd2luZG93LmNvbmZpcm0oY29uZmlybU1lc3NhZ2UpXG4gIGlmIChmb2xsb3dzQ291bnQgPiAyMDAwMDApIHtcbiAgICBjb25maXJtZWQgPSB3aW5kb3cuY29uZmlybShpMThuLmdldE1lc3NhZ2UoJ3dhcm5pbmdfdG9vX21hbnlfZm9sbG93ZXJzJykpXG4gIH1cbiAgaWYgKGNvbmZpcm1lZCkge1xuICAgIGNvbnN0IG9wdGlvbnMgPSBhd2FpdCBPcHRpb25zLmxvYWQoKVxuICAgIGNvbnN0IGNoYWluYmxvY2tlciA9IG5ldyBDaGFpbk1pcnJvckJsb2NrKG9wdGlvbnMpXG4gICAgY2hhaW5ibG9ja2VyLnN0YXJ0KHRhcmdldFVzZXIsIGZvbGxvd0tpbmQpXG4gIH1cbn1cblxuYnJvd3Nlci5ydW50aW1lLm9uTWVzc2FnZS5hZGRMaXN0ZW5lcigobXNnOiBvYmplY3QpID0+IHtcbiAgY29uc3QgbWVzc2FnZSA9IG1zZyBhcyBNQk1lc3NhZ2VcbiAgaWYgKG1lc3NhZ2UuYWN0aW9uID09PSBBY3Rpb24uU3RhcnRDaGFpbkJsb2NrKSB7XG4gICAgc3RhcnRDaGFpbkJsb2NrKG1lc3NhZ2UudXNlck5hbWUsIG1lc3NhZ2UuZm9sbG93S2luZClcbiAgfSBlbHNlIGlmIChtZXNzYWdlLmFjdGlvbiA9PT0gQWN0aW9uLkFsZXJ0KSB7XG4gICAgY29uc3QgbXNnID0gbWVzc2FnZS5tZXNzYWdlXG4gICAgd2luZG93LmFsZXJ0KG1zZylcbiAgfVxufSlcbiIsImV4cG9ydCBjb25zdCBlbnVtIEFjdGlvbiB7XG4gIFN0YXJ0Q2hhaW5CbG9jayA9ICdNaXJyb3JCbG9jay9TdGFydCcsXG4gIFN0b3BDaGFpbkJsb2NrID0gJ01pcnJvckJsb2NrL1N0b3AnLFxuICBBbGVydCA9ICdNaXJyb3JCbG9jay9BbGVydCcsXG59XG5cbmNvbnN0IFVTRVJfTkFNRV9CTEFDS0xJU1QgPSBPYmplY3QuZnJlZXplKFtcbiAgJzEnLFxuICAnYWJvdXQnLFxuICAnYWNjb3VudCcsXG4gICdmb2xsb3dlcnMnLFxuICAnZm9sbG93aW5ncycsXG4gICdoYXNodGFnJyxcbiAgJ2hvbWUnLFxuICAnaScsXG4gICdsaXN0cycsXG4gICdsb2dpbicsXG4gICdvYXV0aCcsXG4gICdwcml2YWN5JyxcbiAgJ3NlYXJjaCcsXG4gICd0b3MnLFxuICAnbm90aWZpY2F0aW9ucycsXG4gICdtZXNzYWdlcycsXG4gICdleHBsb3JlJyxcbl0pXG5cbmV4cG9ydCBjbGFzcyBUd2l0dGVyVXNlck1hcCBleHRlbmRzIE1hcDxzdHJpbmcsIFR3aXR0ZXJVc2VyPiB7XG4gIHB1YmxpYyBhZGRVc2VyKHVzZXI6IFR3aXR0ZXJVc2VyKSB7XG4gICAgdGhpcy5zZXQodXNlci5pZF9zdHIsIHVzZXIpXG4gIH1cbiAgcHVibGljIGhhc1VzZXIodXNlcjogVHdpdHRlclVzZXIpIHtcbiAgICByZXR1cm4gdGhpcy5oYXModXNlci5pZF9zdHIpXG4gIH1cbiAgcHVibGljIHRvVXNlckFycmF5KCk6IFR3aXR0ZXJVc2VyW10ge1xuICAgIHJldHVybiBBcnJheS5mcm9tKHRoaXMudmFsdWVzKCkpXG4gIH1cbiAgcHVibGljIHRvVXNlck9iamVjdCgpOiBUd2l0dGVyVXNlckVudGl0aWVzIHtcbiAgICBjb25zdCB1c2Vyc09iajogVHdpdHRlclVzZXJFbnRpdGllcyA9IE9iamVjdC5jcmVhdGUobnVsbClcbiAgICBmb3IgKGNvbnN0IFt1c2VySWQsIHVzZXJdIG9mIHRoaXMpIHtcbiAgICAgIHVzZXJzT2JqW3VzZXJJZF0gPSB1c2VyXG4gICAgfVxuICAgIHJldHVybiB1c2Vyc09ialxuICB9XG4gIHB1YmxpYyBzdGF0aWMgZnJvbVVzZXJzQXJyYXkodXNlcnM6IFR3aXR0ZXJVc2VyW10pOiBUd2l0dGVyVXNlck1hcCB7XG4gICAgcmV0dXJuIG5ldyBUd2l0dGVyVXNlck1hcCh1c2Vycy5tYXAoKHVzZXIpOiBbc3RyaW5nLCBUd2l0dGVyVXNlcl0gPT4gW3VzZXIuaWRfc3RyLCB1c2VyXSkpXG4gIH1cbiAgcHVibGljIGZpbHRlcihmbjogKHVzZXI6IFR3aXR0ZXJVc2VyKSA9PiBib29sZWFuKTogVHdpdHRlclVzZXJNYXAge1xuICAgIHJldHVybiBUd2l0dGVyVXNlck1hcC5mcm9tVXNlcnNBcnJheSh0aGlzLnRvVXNlckFycmF5KCkuZmlsdGVyKGZuKSlcbiAgfVxufVxuXG5leHBvcnQgYWJzdHJhY3QgY2xhc3MgRXZlbnRFbWl0dGVyIHtcbiAgcHJvdGVjdGVkIGV2ZW50czogRXZlbnRTdG9yZSA9IHt9XG4gIG9uPFQ+KGV2ZW50TmFtZTogc3RyaW5nLCBoYW5kbGVyOiAodDogVCkgPT4gYW55KSB7XG4gICAgaWYgKCEoZXZlbnROYW1lIGluIHRoaXMuZXZlbnRzKSkge1xuICAgICAgdGhpcy5ldmVudHNbZXZlbnROYW1lXSA9IFtdXG4gICAgfVxuICAgIHRoaXMuZXZlbnRzW2V2ZW50TmFtZV0ucHVzaChoYW5kbGVyKVxuICAgIHJldHVybiB0aGlzXG4gIH1cbiAgZW1pdDxUPihldmVudE5hbWU6IHN0cmluZywgZXZlbnRIYW5kbGVyUGFyYW1ldGVyPzogVCkge1xuICAgIGNvbnN0IGhhbmRsZXJzID0gdGhpcy5ldmVudHNbZXZlbnROYW1lXSB8fCBbXVxuICAgIGhhbmRsZXJzLmZvckVhY2goaGFuZGxlciA9PiBoYW5kbGVyKGV2ZW50SGFuZGxlclBhcmFtZXRlcikpXG4gICAgcmV0dXJuIHRoaXNcbiAgfVxufVxuXG5leHBvcnQgZnVuY3Rpb24gc2xlZXAodGltZTogbnVtYmVyKTogUHJvbWlzZTx2b2lkPiB7XG4gIHJldHVybiBuZXcgUHJvbWlzZShyZXNvbHZlID0+IHdpbmRvdy5zZXRUaW1lb3V0KHJlc29sdmUsIHRpbWUpKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gaW5qZWN0U2NyaXB0KHBhdGg6IHN0cmluZyk6IFByb21pc2U8dm9pZD4ge1xuICByZXR1cm4gbmV3IFByb21pc2UocmVzb2x2ZSA9PiB7XG4gICAgY29uc3Qgc2NyaXB0ID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnc2NyaXB0JylcbiAgICBzY3JpcHQuYWRkRXZlbnRMaXN0ZW5lcignbG9hZCcsICgpID0+IHtcbiAgICAgIHNjcmlwdC5yZW1vdmUoKVxuICAgICAgcmVzb2x2ZSgpXG4gICAgfSlcbiAgICBzY3JpcHQuc3JjID0gYnJvd3Nlci5ydW50aW1lLmdldFVSTChwYXRoKVxuICAgIGNvbnN0IGFwcGVuZFRhcmdldCA9IGRvY3VtZW50LmhlYWQgfHwgZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50XG4gICAgYXBwZW5kVGFyZ2V0IS5hcHBlbmRDaGlsZChzY3JpcHQpXG4gIH0pXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBjb3B5RnJvemVuT2JqZWN0PFQgZXh0ZW5kcyBvYmplY3Q+KG9iajogVCk6IFJlYWRvbmx5PFQ+IHtcbiAgcmV0dXJuIE9iamVjdC5mcmVlemUoT2JqZWN0LmFzc2lnbih7fSwgb2JqKSlcbn1cblxuZXhwb3J0IGZ1bmN0aW9uKiBnZXRBZGRlZEVsZW1lbnRzRnJvbU11dGF0aW9ucyhcbiAgbXV0YXRpb25zOiBNdXRhdGlvblJlY29yZFtdXG4pOiBJdGVyYWJsZUl0ZXJhdG9yPEhUTUxFbGVtZW50PiB7XG4gIGZvciAoY29uc3QgbXV0IG9mIG11dGF0aW9ucykge1xuICAgIGZvciAoY29uc3Qgbm9kZSBvZiBtdXQuYWRkZWROb2Rlcykge1xuICAgICAgaWYgKG5vZGUgaW5zdGFuY2VvZiBIVE1MRWxlbWVudCkge1xuICAgICAgICB5aWVsZCBub2RlXG4gICAgICB9XG4gICAgfVxuICB9XG59XG5cbmNvbnN0IHRvdWNoZWRFbGVtcyA9IG5ldyBXZWFrU2V0PEhUTUxFbGVtZW50PigpXG5leHBvcnQgZnVuY3Rpb24qIGl0ZXJhdGVVbnRvdWNoZWRFbGVtczxUIGV4dGVuZHMgSFRNTEVsZW1lbnQ+KGVsZW1zOiBJdGVyYWJsZTxUPiB8IEFycmF5TGlrZTxUPikge1xuICBmb3IgKGNvbnN0IGVsZW0gb2YgQXJyYXkuZnJvbShlbGVtcykpIHtcbiAgICBpZiAoIXRvdWNoZWRFbGVtcy5oYXMoZWxlbSkpIHtcbiAgICAgIHRvdWNoZWRFbGVtcy5hZGQoZWxlbSlcbiAgICAgIHlpZWxkIGVsZW1cbiAgICB9XG4gIH1cbn1cblxuLy8gbmFpdmUgY2hlY2sgZ2l2ZW4gb2JqZWN0IGlzIFR3aXR0ZXJVc2VyXG5leHBvcnQgZnVuY3Rpb24gaXNUd2l0dGVyVXNlcihvYmo6IHVua25vd24pOiBvYmogaXMgVHdpdHRlclVzZXIge1xuICBpZiAoIShvYmogJiYgdHlwZW9mIG9iaiA9PT0gJ29iamVjdCcpKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgY29uc3Qgb2JqQXNBbnkgPSBvYmogYXMgYW55XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuaWRfc3RyICE9PSAnc3RyaW5nJykge1xuICAgIHJldHVybiBmYWxzZVxuICB9XG4gIGlmICh0eXBlb2Ygb2JqQXNBbnkuc2NyZWVuX25hbWUgIT09ICdzdHJpbmcnKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5ibG9ja2luZyAhPT0gJ2Jvb2xlYW4nKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgaWYgKHR5cGVvZiBvYmpBc0FueS5ibG9ja2VkX2J5ICE9PSAnYm9vbGVhbicpIHtcbiAgICByZXR1cm4gZmFsc2VcbiAgfVxuICByZXR1cm4gdHJ1ZVxufVxuXG5leHBvcnQgZnVuY3Rpb24gaXNJbk5hbWVCbGFja2xpc3QobmFtZTogc3RyaW5nKTogYm9vbGVhbiB7XG4gIGNvbnN0IGxvd2VyQ2FzZWROYW1lID0gbmFtZS50b0xvd2VyQ2FzZSgpXG4gIHJldHVybiBVU0VSX05BTUVfQkxBQ0tMSVNULmluY2x1ZGVzKGxvd2VyQ2FzZWROYW1lKVxufVxuXG5leHBvcnQgZnVuY3Rpb24gdmFsaWRhdGVUd2l0dGVyVXNlck5hbWUodXNlck5hbWU6IHN0cmluZyk6IGJvb2xlYW4ge1xuICBpZiAoaXNJbk5hbWVCbGFja2xpc3QodXNlck5hbWUpKSB7XG4gICAgcmV0dXJuIGZhbHNlXG4gIH1cbiAgY29uc3QgcGF0dGVybiA9IC9eWzAtOWEtel9dezEsMTV9JC9pXG4gIHJldHVybiBwYXR0ZXJuLnRlc3QodXNlck5hbWUpXG59XG5cbmV4cG9ydCBmdW5jdGlvbiBnZXRVc2VyTmFtZUZyb21Ud2VldFVybChcbiAgZXh0cmFjdE1lOiBIVE1MQW5jaG9yRWxlbWVudCB8IFVSTCB8IExvY2F0aW9uXG4pOiBzdHJpbmcgfCBudWxsIHtcbiAgY29uc3QgeyBob3N0bmFtZSwgcGF0aG5hbWUgfSA9IGV4dHJhY3RNZVxuICBjb25zdCBzdXBwb3J0aW5nSG9zdG5hbWUgPSBbJ3R3aXR0ZXIuY29tJywgJ21vYmlsZS50d2l0dGVyLmNvbSddXG4gIGlmICghc3VwcG9ydGluZ0hvc3RuYW1lLmluY2x1ZGVzKGhvc3RuYW1lKSkge1xuICAgIHJldHVybiBudWxsXG4gIH1cbiAgY29uc3QgbWF0Y2hlcyA9IC9eXFwvKFswLTlhLXpfXXsxLDE1fSkvaS5leGVjKHBhdGhuYW1lKVxuICBpZiAoIW1hdGNoZXMpIHtcbiAgICByZXR1cm4gbnVsbFxuICB9XG4gIGNvbnN0IG5hbWUgPSBtYXRjaGVzWzFdXG4gIGlmICh2YWxpZGF0ZVR3aXR0ZXJVc2VyTmFtZShuYW1lKSkge1xuICAgIHJldHVybiBuYW1lXG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIG51bGxcbiAgfVxufVxuIiwidHlwZSBJMThOTWVzc2FnZXMgPSB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9rby9tZXNzYWdlcy5qc29uJylcbnR5cGUgU3Vic3RJdGVtID0gbnVtYmVyIHwgc3RyaW5nXG50eXBlIFN1YnN0aXR1dGlvbnMgPSBTdWJzdEl0ZW0gfCBTdWJzdEl0ZW1bXSB8IHVuZGVmaW5lZFxuZXhwb3J0IHR5cGUgSTE4Tk1lc3NhZ2VLZXlzID0ga2V5b2YgSTE4Tk1lc3NhZ2VzXG5cbmV4cG9ydCBmdW5jdGlvbiBnZXRNZXNzYWdlKGtleTogc3RyaW5nICYgSTE4Tk1lc3NhZ2VLZXlzLCBzdWJzdHM6IFN1YnN0aXR1dGlvbnMgPSB1bmRlZmluZWQpIHtcbiAgaWYgKEFycmF5LmlzQXJyYXkoc3Vic3RzKSkge1xuICAgIHJldHVybiBicm93c2VyLmkxOG4uZ2V0TWVzc2FnZShcbiAgICAgIGtleSxcbiAgICAgIHN1YnN0cy5tYXAocyA9PiBzLnRvTG9jYWxlU3RyaW5nKCkpXG4gICAgKVxuICB9IGVsc2UgaWYgKHR5cGVvZiBzdWJzdHMgPT09ICdudW1iZXInKSB7XG4gICAgcmV0dXJuIGJyb3dzZXIuaTE4bi5nZXRNZXNzYWdlKGtleSwgc3Vic3RzLnRvTG9jYWxlU3RyaW5nKCkpXG4gIH0gZWxzZSB7XG4gICAgcmV0dXJuIGJyb3dzZXIuaTE4bi5nZXRNZXNzYWdlKGtleSwgc3Vic3RzKVxuICB9XG59XG5cbmZ1bmN0aW9uIHRyeUdldE1lc3NhZ2UobWVzc2FnZU5hbWU6IHN0cmluZykge1xuICBjb25zdCBtZXNzYWdlID0gZ2V0TWVzc2FnZShtZXNzYWdlTmFtZSBhcyBhbnkpXG4gIGlmICghbWVzc2FnZSkge1xuICAgIHRocm93IG5ldyBFcnJvcihgaW52YWxpZCBtZXNzYWdlTmFtZT8gXCIke21lc3NhZ2VOYW1lfVwiYClcbiAgfVxuICByZXR1cm4gbWVzc2FnZVxufVxuXG5leHBvcnQgZnVuY3Rpb24gYXBwbHlJMThuT25IdG1sKCkge1xuICBjb25zdCBpMThuVGV4dEVsZW1lbnRzID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgnW2RhdGEtaTE4bi10ZXh0XScpXG4gIGZvciAoY29uc3QgZWxlbSBvZiBpMThuVGV4dEVsZW1lbnRzKSB7XG4gICAgY29uc3QgbWVzc2FnZU5hbWUgPSBlbGVtLmdldEF0dHJpYnV0ZSgnZGF0YS1pMThuLXRleHQnKSFcbiAgICBjb25zdCBtZXNzYWdlID0gdHJ5R2V0TWVzc2FnZShtZXNzYWdlTmFtZSlcbiAgICAvLyBjb25zb2xlLmRlYnVnKCclbyAudGV4dENvbnRlbnQgPSAlcyBbZnJvbSAlc10nLCBlbGVtLCBtZXNzYWdlLCBtZXNzYWdlTmFtZSlcbiAgICBlbGVtLnRleHRDb250ZW50ID0gbWVzc2FnZVxuICB9XG4gIGNvbnN0IGkxOG5BdHRyc0VsZW1lbnRzID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgnW2RhdGEtaTE4bi1hdHRyc10nKVxuICBmb3IgKGNvbnN0IGVsZW0gb2YgaTE4bkF0dHJzRWxlbWVudHMpIHtcbiAgICAvLyBleGFtcGxlOlxuICAgIC8vIDxzcGFuIGRhdGEtaTE4bi1hdHRycz1cInRpdGxlPXBvcHVwX3RpdGxlJmFsdD1wb3B1cF9hbHRcIj48L3NwYW4+XG4gICAgY29uc3QgYXR0cnNUb05hbWVTZXJpYWxpemVkID0gZWxlbS5nZXRBdHRyaWJ1dGUoJ2RhdGEtaTE4bi1hdHRycycpIVxuICAgIGNvbnN0IGF0dHJzVG9OYW1lUGFyc2VkID0gbmV3IFVSTFNlYXJjaFBhcmFtcyhhdHRyc1RvTmFtZVNlcmlhbGl6ZWQpXG4gICAgYXR0cnNUb05hbWVQYXJzZWQuZm9yRWFjaCgodmFsdWUsIGtleSkgPT4ge1xuICAgICAgLy8gY29uc29sZS5kZWJ1ZygnfGF0dHJ8IGtleTpcIiVzXCIsIHZhbHVlOlwiJXNcIicsIGtleSwgdmFsdWUpXG4gICAgICBjb25zdCBtZXNzYWdlID0gdHJ5R2V0TWVzc2FnZSh2YWx1ZSlcbiAgICAgIGVsZW0uc2V0QXR0cmlidXRlKGtleSwgbWVzc2FnZSlcbiAgICB9KVxuICB9XG59XG5cbmZ1bmN0aW9uIGNoZWNrTWlzc2luZ1RyYW5zbGF0aW9ucyhcbiAgLy8ga28vbWVzc2FnZXMuanNvbiDsl5Qg7J6I6rOgIGVuL21lc3NhZ2VzLmpzb24g7JeUIOyXhuuKlCDtgqTqsIAg7J6I7Jy866m0XG4gIC8vIFR5cGVTY3JpcHQg7Lu07YyM7J2865+s6rCAIO2DgOyeheyXkOufrOulvCDsnbzsnLztgqjri6QuXG4gIC8vIHRzY29uZmlnLmpzb27snZggcmVzb2x2ZUpzb25Nb2R1bGUg7Ji17IWY7J2EIOy8nOyVvCDtlahcbiAga2V5czpcbiAgICB8IEV4Y2x1ZGU8XG4gICAgICAgIGtleW9mIHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2tvL21lc3NhZ2VzLmpzb24nKSxcbiAgICAgICAga2V5b2YgdHlwZW9mIGltcG9ydCgnLi4vX2xvY2FsZXMvZW4vbWVzc2FnZXMuanNvbicpXG4gICAgICA+XG4gICAgfCBFeGNsdWRlPFxuICAgICAgICBrZXlvZiB0eXBlb2YgaW1wb3J0KCcuLi9fbG9jYWxlcy9lbi9tZXNzYWdlcy5qc29uJyksXG4gICAgICAgIGtleW9mIHR5cGVvZiBpbXBvcnQoJy4uL19sb2NhbGVzL2tvL21lc3NhZ2VzLmpzb24nKVxuICAgICAgPixcbiAgZmluZDogKF9rZXlzOiBuZXZlcikgPT4gdm9pZCxcbiAgX2NoZWNrID0gZmluZChrZXlzKVxuKSB7fVxuY2hlY2tNaXNzaW5nVHJhbnNsYXRpb25zXG4iLCJpbXBvcnQgeyB2YWxpZGF0ZVR3aXR0ZXJVc2VyTmFtZSwgc2xlZXAgfSBmcm9tICcuL2NvbW1vbidcblxuY29uc3QgQkVBUkVSX1RPS0VOID0gYEFBQUFBQUFBQUFBQUFBQUFBQUFBQU5SSUxnQUFBQUFBbk53SXpVZWpSQ091SDVFNkk4eG5aejRwdVRzJTNEMVp2N3R0Zms4TEY4MUlVcTE2Y0hqaExUdkp1NEZBMzNBR1dXakNwVG5BYFxuXG4vLyBDT1JCKiDroZwg7J247ZW0IGNvbnRlbnQgc2NyaXB0c+yXkOyEnCBhcGkudHdpdHRlci5jb20g7J2EIOyCrOyaqe2VoCDsiJgg7JeG64ukLlxuLy8gaHR0cHM6Ly93d3cuY2hyb21lc3RhdHVzLmNvbS9mZWF0dXJlLzU2Mjk3MDk4MjQwMzI3Njhcbi8vIGh0dHBzOi8vd3d3LmNocm9taXVtLm9yZy9Ib21lL2Nocm9taXVtLXNlY3VyaXR5L2NvcmItZm9yLWRldmVsb3BlcnNcbmxldCBhcGlQcmVmaXggPSAnaHR0cHM6Ly90d2l0dGVyLmNvbS9pL2FwaS8xLjEnXG5pZiAobG9jYXRpb24uaG9zdG5hbWUgPT09ICdtb2JpbGUudHdpdHRlci5jb20nKSB7XG4gIGFwaVByZWZpeCA9ICdodHRwczovL21vYmlsZS50d2l0dGVyLmNvbS9pL2FwaS8xLjEnXG59XG5cbmV4cG9ydCBjbGFzcyBBUElFcnJvciBleHRlbmRzIEVycm9yIHtcbiAgY29uc3RydWN0b3IocHVibGljIHJlYWRvbmx5IHJlc3BvbnNlOiBBUElSZXNwb25zZSkge1xuICAgIHN1cGVyKCdBUEkgRXJyb3IhJylcbiAgICAvLyBmcm9tOiBodHRwczovL3d3dy50eXBlc2NyaXB0bGFuZy5vcmcvZG9jcy9oYW5kYm9vay9yZWxlYXNlLW5vdGVzL3R5cGVzY3JpcHQtMi0yLmh0bWwjc3VwcG9ydC1mb3ItbmV3dGFyZ2V0XG4gICAgT2JqZWN0LnNldFByb3RvdHlwZU9mKHRoaXMsIG5ldy50YXJnZXQucHJvdG90eXBlKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBibG9ja1VzZXIodXNlcjogVHdpdHRlclVzZXIpOiBQcm9taXNlPGJvb2xlYW4+IHtcbiAgaWYgKHVzZXIuYmxvY2tpbmcpIHtcbiAgICByZXR1cm4gdHJ1ZVxuICB9XG4gIGNvbnN0IHNob3VsZE5vdEJsb2NrID1cbiAgICB1c2VyLmZvbGxvd2luZyB8fCB1c2VyLmZvbGxvd2VkX2J5IHx8IHVzZXIuZm9sbG93X3JlcXVlc3Rfc2VudCB8fCAhdXNlci5ibG9ja2VkX2J5XG4gIGlmIChzaG91bGROb3RCbG9jaykge1xuICAgIGNvbnN0IGZhdGFsRXJyb3JNZXNzYWdlID0gYCEhISEhRkFUQUwhISEhITpcbmF0dGVtcHRlZCB0byBibG9jayB1c2VyIHRoYXQgc2hvdWxkIE5PVCBibG9jayEhXG4odXNlcjogJHt1c2VyLnNjcmVlbl9uYW1lfSlgXG4gICAgdGhyb3cgbmV3IEVycm9yKGZhdGFsRXJyb3JNZXNzYWdlKVxuICB9XG4gIHJldHVybiBibG9ja1VzZXJCeUlkKHVzZXIuaWRfc3RyKVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gYmxvY2tVc2VyQnlJZCh1c2VySWQ6IHN0cmluZyk6IFByb21pc2U8Ym9vbGVhbj4ge1xuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdwb3N0JywgJy9ibG9ja3MvY3JlYXRlLmpzb24nLCB7XG4gICAgdXNlcl9pZDogdXNlcklkLFxuICAgIGluY2x1ZGVfZW50aXRpZXM6IGZhbHNlLFxuICAgIHNraXBfc3RhdHVzOiB0cnVlLFxuICB9KVxuICByZXR1cm4gcmVzcG9uc2Uub2tcbn1cblxuYXN5bmMgZnVuY3Rpb24gZ2V0Rm9sbG93aW5nc0xpc3QoXG4gIHVzZXI6IFR3aXR0ZXJVc2VyLFxuICBjdXJzb3I6IHN0cmluZyA9ICctMSdcbik6IFByb21pc2U8Rm9sbG93c0xpc3RSZXNwb25zZT4ge1xuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL2ZyaWVuZHMvbGlzdC5qc29uJywge1xuICAgIHVzZXJfaWQ6IHVzZXIuaWRfc3RyLFxuICAgIGNvdW50OiAyMDAsXG4gICAgc2tpcF9zdGF0dXM6IHRydWUsXG4gICAgaW5jbHVkZV91c2VyX2VudGl0aWVzOiBmYWxzZSxcbiAgICBjdXJzb3IsXG4gIH0pXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIHJldHVybiByZXNwb25zZS5ib2R5IGFzIEZvbGxvd3NMaXN0UmVzcG9uc2VcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgQVBJRXJyb3IocmVzcG9uc2UpXG4gIH1cbn1cbmFzeW5jIGZ1bmN0aW9uIGdldEZvbGxvd2Vyc0xpc3QoXG4gIHVzZXI6IFR3aXR0ZXJVc2VyLFxuICBjdXJzb3I6IHN0cmluZyA9ICctMSdcbik6IFByb21pc2U8Rm9sbG93c0xpc3RSZXNwb25zZT4ge1xuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL2ZvbGxvd2Vycy9saXN0Lmpzb24nLCB7XG4gICAgdXNlcl9pZDogdXNlci5pZF9zdHIsXG4gICAgLy8gc2NyZWVuX25hbWU6IHVzZXJOYW1lLFxuICAgIGNvdW50OiAyMDAsXG4gICAgc2tpcF9zdGF0dXM6IHRydWUsXG4gICAgaW5jbHVkZV91c2VyX2VudGl0aWVzOiBmYWxzZSxcbiAgICBjdXJzb3IsXG4gIH0pXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIHJldHVybiByZXNwb25zZS5ib2R5IGFzIEZvbGxvd3NMaXN0UmVzcG9uc2VcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgQVBJRXJyb3IocmVzcG9uc2UpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uKiBnZXRBbGxGb2xsb3dzKFxuICB1c2VyOiBUd2l0dGVyVXNlcixcbiAgZm9sbG93S2luZDogRm9sbG93S2luZCxcbiAgb3B0aW9uczogRm9sbG93c1NjcmFwZXJPcHRpb25zXG4pOiBBc3luY0l0ZXJhYmxlSXRlcmF0b3I8RWl0aGVyPEFQSUVycm9yLCBSZWFkb25seTxUd2l0dGVyVXNlcj4+PiB7XG4gIGxldCBjdXJzb3IgPSAnLTEnXG4gIHdoaWxlICh0cnVlKSB7XG4gICAgdHJ5IHtcbiAgICAgIGxldCBqc29uOiBGb2xsb3dzTGlzdFJlc3BvbnNlXG4gICAgICBzd2l0Y2ggKGZvbGxvd0tpbmQpIHtcbiAgICAgICAgY2FzZSAnZm9sbG93ZXJzJzpcbiAgICAgICAgICBqc29uID0gYXdhaXQgZ2V0Rm9sbG93ZXJzTGlzdCh1c2VyLCBjdXJzb3IpXG4gICAgICAgICAgYnJlYWtcbiAgICAgICAgY2FzZSAnZm9sbG93aW5nJzpcbiAgICAgICAgICBqc29uID0gYXdhaXQgZ2V0Rm9sbG93aW5nc0xpc3QodXNlciwgY3Vyc29yKVxuICAgICAgICAgIGJyZWFrXG4gICAgICAgIGRlZmF1bHQ6XG4gICAgICAgICAgdGhyb3cgbmV3IEVycm9yKCd1bnJlYWNoYWJsZScpXG4gICAgICB9XG4gICAgICBjdXJzb3IgPSBqc29uLm5leHRfY3Vyc29yX3N0clxuICAgICAgY29uc3QgdXNlcnMgPSBqc29uLnVzZXJzIGFzIFR3aXR0ZXJVc2VyW11cbiAgICAgIHlpZWxkKiB1c2Vycy5tYXAodXNlciA9PiAoe1xuICAgICAgICBvazogdHJ1ZSBhcyBjb25zdCxcbiAgICAgICAgdmFsdWU6IE9iamVjdC5mcmVlemUodXNlciksXG4gICAgICB9KSlcbiAgICAgIGlmIChjdXJzb3IgPT09ICcwJykge1xuICAgICAgICBicmVha1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgYXdhaXQgc2xlZXAob3B0aW9ucy5kZWxheSlcbiAgICAgICAgY29udGludWVcbiAgICAgIH1cbiAgICB9IGNhdGNoIChlcnJvcikge1xuICAgICAgaWYgKGVycm9yIGluc3RhbmNlb2YgQVBJRXJyb3IpIHtcbiAgICAgICAgeWllbGQge1xuICAgICAgICAgIG9rOiBmYWxzZSxcbiAgICAgICAgICBlcnJvcixcbiAgICAgICAgfVxuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhyb3cgZXJyb3JcbiAgICAgIH1cbiAgICB9XG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldFNpbmdsZVVzZXJCeUlkKHVzZXJJZDogc3RyaW5nKTogUHJvbWlzZTxUd2l0dGVyVXNlcj4ge1xuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL3VzZXJzL3Nob3cuanNvbicsIHtcbiAgICB1c2VyX2lkOiB1c2VySWQsXG4gICAgc2tpcF9zdGF0dXM6IHRydWUsXG4gICAgaW5jbHVkZV9lbnRpdGllczogZmFsc2UsXG4gIH0pXG4gIGlmIChyZXNwb25zZS5vaykge1xuICAgIHJldHVybiByZXNwb25zZS5ib2R5IGFzIFR3aXR0ZXJVc2VyXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEFQSUVycm9yKHJlc3BvbnNlKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRTaW5nbGVVc2VyQnlOYW1lKHVzZXJOYW1lOiBzdHJpbmcpOiBQcm9taXNlPFR3aXR0ZXJVc2VyPiB7XG4gIGNvbnN0IGlzVmFsaWRVc2VyTmFtZSA9IHZhbGlkYXRlVHdpdHRlclVzZXJOYW1lKHVzZXJOYW1lKVxuICBpZiAoIWlzVmFsaWRVc2VyTmFtZSkge1xuICAgIHRocm93IG5ldyBFcnJvcihgSW52YWxpZCB1c2VyIG5hbWUgXCIke3VzZXJOYW1lfVwiIWApXG4gIH1cbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy91c2Vycy9zaG93Lmpzb24nLCB7XG4gICAgLy8gdXNlcl9pZDogdXNlci5pZF9zdHIsXG4gICAgc2NyZWVuX25hbWU6IHVzZXJOYW1lLFxuICAgIHNraXBfc3RhdHVzOiB0cnVlLFxuICAgIGluY2x1ZGVfZW50aXRpZXM6IGZhbHNlLFxuICB9KVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICByZXR1cm4gcmVzcG9uc2UuYm9keSBhcyBUd2l0dGVyVXNlclxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBBUElFcnJvcihyZXNwb25zZSlcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0TXVsdGlwbGVVc2Vyc0J5SWQodXNlcklkczogc3RyaW5nW10pOiBQcm9taXNlPFR3aXR0ZXJVc2VyW10+IHtcbiAgaWYgKHVzZXJJZHMubGVuZ3RoID09PSAwKSB7XG4gICAgcmV0dXJuIFtdXG4gIH1cbiAgaWYgKHVzZXJJZHMubGVuZ3RoID4gMTAwKSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKCd0b28gbWFueSB1c2VycyEgKD4gMTAwKScpXG4gIH1cbiAgY29uc3Qgam9pbmVkSWRzID0gQXJyYXkuZnJvbShuZXcgU2V0KHVzZXJJZHMpKS5qb2luKCcsJylcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgncG9zdCcsICcvdXNlcnMvbG9va3VwLmpzb24nLCB7XG4gICAgdXNlcl9pZDogam9pbmVkSWRzLFxuICAgIGluY2x1ZGVfZW50aXRpZXM6IGZhbHNlLFxuICAgIC8vIHNjcmVlbl9uYW1lOiAuLi5cbiAgfSlcbiAgaWYgKHJlc3BvbnNlLm9rKSB7XG4gICAgcmV0dXJuIHJlc3BvbnNlLmJvZHkgYXMgVHdpdHRlclVzZXJbXVxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBBUElFcnJvcihyZXNwb25zZSlcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0RnJpZW5kc2hpcHModXNlcnM6IFR3aXR0ZXJVc2VyW10pOiBQcm9taXNlPEZyaWVuZHNoaXBSZXNwb25zZT4ge1xuICBjb25zdCB1c2VySWRzID0gdXNlcnMubWFwKHVzZXIgPT4gdXNlci5pZF9zdHIpXG4gIGlmICh1c2VySWRzLmxlbmd0aCA9PT0gMCkge1xuICAgIHJldHVybiBbXVxuICB9XG4gIGlmICh1c2VySWRzLmxlbmd0aCA+IDEwMCkge1xuICAgIHRocm93IG5ldyBFcnJvcigndG9vIG1hbnkgdXNlcnMhICg+IDEwMCknKVxuICB9XG4gIGNvbnN0IGpvaW5lZElkcyA9IEFycmF5LmZyb20obmV3IFNldCh1c2VySWRzKSkuam9pbignLCcpXG4gIGNvbnN0IHJlc3BvbnNlID0gYXdhaXQgc2VuZFJlcXVlc3QoJ2dldCcsICcvZnJpZW5kc2hpcHMvbG9va3VwLmpzb24nLCB7XG4gICAgdXNlcl9pZDogam9pbmVkSWRzLFxuICB9KVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICByZXR1cm4gcmVzcG9uc2UuYm9keSBhcyBGcmllbmRzaGlwUmVzcG9uc2VcbiAgfSBlbHNlIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoJ3Jlc3BvbnNlIGlzIG5vdCBvaycpXG4gIH1cbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGdldFJlbGF0aW9uc2hpcChcbiAgc291cmNlVXNlcjogVHdpdHRlclVzZXIsXG4gIHRhcmdldFVzZXI6IFR3aXR0ZXJVc2VyXG4pOiBQcm9taXNlPFJlbGF0aW9uc2hpcD4ge1xuICBjb25zdCBzb3VyY2VfaWQgPSBzb3VyY2VVc2VyLmlkX3N0clxuICBjb25zdCB0YXJnZXRfaWQgPSB0YXJnZXRVc2VyLmlkX3N0clxuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL2ZyaWVuZHNoaXBzL3Nob3cuanNvbicsIHtcbiAgICBzb3VyY2VfaWQsXG4gICAgdGFyZ2V0X2lkLFxuICB9KVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICBjb25zdCB7IHJlbGF0aW9uc2hpcCB9ID0gcmVzcG9uc2UuYm9keSBhcyB7XG4gICAgICByZWxhdGlvbnNoaXA6IFJlbGF0aW9uc2hpcFxuICAgIH1cbiAgICByZXR1cm4gcmVsYXRpb25zaGlwXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKCdyZXNwb25zZSBpcyBub3Qgb2snKVxuICB9XG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRNeXNlbGYoKTogUHJvbWlzZTxUd2l0dGVyVXNlcj4ge1xuICBjb25zdCByZXNwb25zZSA9IGF3YWl0IHNlbmRSZXF1ZXN0KCdnZXQnLCAnL2FjY291bnQvdmVyaWZ5X2NyZWRlbnRpYWxzLmpzb24nKVxuICBpZiAocmVzcG9uc2Uub2spIHtcbiAgICByZXR1cm4gcmVzcG9uc2UuYm9keSBhcyBUd2l0dGVyVXNlclxuICB9IGVsc2Uge1xuICAgIHRocm93IG5ldyBBUElFcnJvcihyZXNwb25zZSlcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gZ2V0UmF0ZUxpbWl0U3RhdHVzKCk6IFByb21pc2U8TGltaXRTdGF0dXM+IHtcbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBzZW5kUmVxdWVzdCgnZ2V0JywgJy9hcHBsaWNhdGlvbi9yYXRlX2xpbWl0X3N0YXR1cy5qc29uJylcbiAgY29uc3QgeyByZXNvdXJjZXMgfSA9IHJlc3BvbnNlLmJvZHkgYXMge1xuICAgIHJlc291cmNlczogTGltaXRTdGF0dXNcbiAgfVxuICByZXR1cm4gcmVzb3VyY2VzXG59XG5cbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBnZXRGb2xsb3dzU2NyYXBlclJhdGVMaW1pdFN0YXR1cyhmb2xsb3dLaW5kOiBGb2xsb3dLaW5kKTogUHJvbWlzZTxMaW1pdD4ge1xuICBjb25zdCBsaW1pdFN0YXR1cyA9IGF3YWl0IGdldFJhdGVMaW1pdFN0YXR1cygpXG4gIGlmIChmb2xsb3dLaW5kID09PSAnZm9sbG93ZXJzJykge1xuICAgIHJldHVybiBsaW1pdFN0YXR1cy5mb2xsb3dlcnNbJy9mb2xsb3dlcnMvbGlzdCddXG4gIH0gZWxzZSBpZiAoZm9sbG93S2luZCA9PT0gJ2ZvbGxvd2luZycpIHtcbiAgICByZXR1cm4gbGltaXRTdGF0dXMuZnJpZW5kc1snL2ZyaWVuZHMvbGlzdCddXG4gIH0gZWxzZSB7XG4gICAgdGhyb3cgbmV3IEVycm9yKCd1bnJlYWNoYWJsZScpXG4gIH1cbn1cblxuZnVuY3Rpb24gZ2V0Q3NyZlRva2VuRnJvbUNvb2tpZXMoKTogc3RyaW5nIHtcbiAgcmV0dXJuIC9cXGJjdDA9KFswLTlhLWZdKykvaS5leGVjKGRvY3VtZW50LmNvb2tpZSkhWzFdXG59XG5cbmZ1bmN0aW9uIGdlbmVyYXRlVHdpdHRlckFQSU9wdGlvbnMob2JqOiBSZXF1ZXN0SW5pdCk6IFJlcXVlc3RJbml0IHtcbiAgY29uc3QgY3NyZlRva2VuID0gZ2V0Q3NyZlRva2VuRnJvbUNvb2tpZXMoKVxuICBjb25zdCBoZWFkZXJzID0gbmV3IEhlYWRlcnMoKVxuICBoZWFkZXJzLnNldCgnYXV0aG9yaXphdGlvbicsIGBCZWFyZXIgJHtCRUFSRVJfVE9LRU59YClcbiAgaGVhZGVycy5zZXQoJ3gtY3NyZi10b2tlbicsIGNzcmZUb2tlbilcbiAgaGVhZGVycy5zZXQoJ3gtdHdpdHRlci1hY3RpdmUtdXNlcicsICd5ZXMnKVxuICBoZWFkZXJzLnNldCgneC10d2l0dGVyLWF1dGgtdHlwZScsICdPQXV0aDJTZXNzaW9uJylcbiAgY29uc3QgcmVzdWx0OiBSZXF1ZXN0SW5pdCA9IHtcbiAgICBtZXRob2Q6ICdnZXQnLFxuICAgIG1vZGU6ICdjb3JzJyxcbiAgICBjcmVkZW50aWFsczogJ2luY2x1ZGUnLFxuICAgIHJlZmVycmVyOiAnaHR0cHM6Ly90d2l0dGVyLmNvbS8nLFxuICAgIGhlYWRlcnMsXG4gIH1cbiAgT2JqZWN0LmFzc2lnbihyZXN1bHQsIG9iailcbiAgcmV0dXJuIHJlc3VsdFxufVxuXG5mdW5jdGlvbiBzZXREZWZhdWx0UGFyYW1zKHBhcmFtczogVVJMU2VhcmNoUGFyYW1zKTogdm9pZCB7XG4gIHBhcmFtcy5zZXQoJ2luY2x1ZGVfcHJvZmlsZV9pbnRlcnN0aXRpYWxfdHlwZScsICcxJylcbiAgcGFyYW1zLnNldCgnaW5jbHVkZV9ibG9ja2luZycsICcxJylcbiAgcGFyYW1zLnNldCgnaW5jbHVkZV9ibG9ja2VkX2J5JywgJzEnKVxuICBwYXJhbXMuc2V0KCdpbmNsdWRlX2ZvbGxvd2VkX2J5JywgJzEnKVxuICBwYXJhbXMuc2V0KCdpbmNsdWRlX3dhbnRfcmV0d2VldHMnLCAnMScpXG4gIHBhcmFtcy5zZXQoJ2luY2x1ZGVfbXV0ZV9lZGdlJywgJzEnKVxuICBwYXJhbXMuc2V0KCdpbmNsdWRlX2Nhbl9kbScsICcxJylcbn1cblxuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIHNlbmRSZXF1ZXN0KFxuICBtZXRob2Q6IEhUVFBNZXRob2RzLFxuICBwYXRoOiBzdHJpbmcsXG4gIHBhcmFtc09iajogVVJMUGFyYW1zT2JqID0ge31cbik6IFByb21pc2U8QVBJUmVzcG9uc2U+IHtcbiAgY29uc3QgZmV0Y2hPcHRpb25zID0gZ2VuZXJhdGVUd2l0dGVyQVBJT3B0aW9ucyh7IG1ldGhvZCB9KVxuICBjb25zdCB1cmwgPSBuZXcgVVJMKGFwaVByZWZpeCArIHBhdGgpXG4gIGxldCBwYXJhbXM6IFVSTFNlYXJjaFBhcmFtc1xuICBpZiAobWV0aG9kID09PSAnZ2V0Jykge1xuICAgIHBhcmFtcyA9IHVybC5zZWFyY2hQYXJhbXNcbiAgfSBlbHNlIHtcbiAgICBwYXJhbXMgPSBuZXcgVVJMU2VhcmNoUGFyYW1zKClcbiAgICBmZXRjaE9wdGlvbnMuYm9keSA9IHBhcmFtc1xuICB9XG4gIHNldERlZmF1bHRQYXJhbXMocGFyYW1zKVxuICBmb3IgKGNvbnN0IFtrZXksIHZhbHVlXSBvZiBPYmplY3QuZW50cmllcyhwYXJhbXNPYmopKSB7XG4gICAgcGFyYW1zLnNldChrZXksIHZhbHVlLnRvU3RyaW5nKCkpXG4gIH1cbiAgY29uc3QgcmVzcG9uc2UgPSBhd2FpdCBmZXRjaCh1cmwudG9TdHJpbmcoKSwgZmV0Y2hPcHRpb25zKVxuICBjb25zdCBoZWFkZXJzID0gQXJyYXkuZnJvbShyZXNwb25zZS5oZWFkZXJzKS5yZWR1Y2UoXG4gICAgKG9iaiwgW25hbWUsIHZhbHVlXSkgPT4gKChvYmpbbmFtZV0gPSB2YWx1ZSksIG9iaiksXG4gICAge30gYXMgeyBbbmFtZTogc3RyaW5nXTogc3RyaW5nIH1cbiAgKVxuICBjb25zdCB7IG9rLCBzdGF0dXMsIHN0YXR1c1RleHQgfSA9IHJlc3BvbnNlXG4gIGNvbnN0IGJvZHkgPSBhd2FpdCByZXNwb25zZS5qc29uKClcbiAgY29uc3QgYXBpUmVzcG9uc2UgPSB7XG4gICAgb2ssXG4gICAgc3RhdHVzLFxuICAgIHN0YXR1c1RleHQsXG4gICAgaGVhZGVycyxcbiAgICBib2R5LFxuICB9XG4gIHJldHVybiBhcGlSZXNwb25zZVxufVxuIl0sInNvdXJjZVJvb3QiOiIifQ==