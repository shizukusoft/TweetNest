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
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/scripts/inject/tweetdeck-inject.ts");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./src/scripts/inject/tweetdeck-inject.ts":
/*!************************************************!*\
  !*** ./src/scripts/inject/tweetdeck-inject.ts ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

{
    function applyMagicToTD(TD) {
        // 트윗덱의 AJAX요청에 차단여부 정보를 포함하게 해주는 옵션을 추가한다.
        TD.services.TwitterClient.prototype.request$REAL = TD.services.TwitterClient.prototype.request;
        TD.services.TwitterClient.prototype.request = function(url, option) {
            Object.assign(option.params || {
            }, {
                include_blocking: 1,
                include_blocked_by: 1,
                include_mute_edge: 1,
                include_followed_by: 1
            });
            return TD.services.TwitterClient.prototype.request$REAL.call(this, url, option);
        };
        // TwitterUser에 사용자 차단여부를 넣으면 트윗덱의 필터기능 등에서 이를 이용할 수 있다.
        function insertAdditionalInfo(targetObject, additional) {
            return Object.assign(targetObject, {
                blockedBy: additional.blocked_by,
                blocking: additional.blocking,
                followedBy: additional.followed_by,
                following: additional.following,
                muting: additional.muting
            });
        }
        TD.services.TwitterUser.prototype.fromJSONObject$REAL = TD.services.TwitterUser.prototype.fromJSONObject;
        TD.services.TwitterUser.prototype.fromJSONObject = function(json, t) {
            insertAdditionalInfo(this, json);
            return TD.services.TwitterUser.prototype.fromJSONObject$REAL.call(this, json, t);
        };
        TD.services.TwitterUser.prototype.fromGraphQLJSONObject$REAL = TD.services.TwitterUser.prototype.fromGraphQLJSONObject;
        TD.services.TwitterUser.prototype.fromGraphQLJSONObject = function(json, t) {
            insertAdditionalInfo(this, json.legacy);
            return TD.services.TwitterUser.prototype.fromGraphQLJSONObject$REAL.call(this, json, t);
        };
        // 트윗덱에선 "나를 차단함" 대신 "@(기본계정)을 차단함" 같은 식으로 보여줘야함
        // 이를 위해 현재 설정된 기본계정을 알아낼 수 있어야함
        // 따라서, 기본계정이 변경될 때 마다 DOM에 사용자아이디를 넣어 content-scripts에서 접근할 수 있도록 한다.
        document.addEventListener('TDLoaded', ()=>{
            document.body.setAttribute('data-default-account-username', TD.storage.accountController.getDefault().state.username);
        });
        function onDefaultAccountChanged(args) {
            // const [afterChange, beforeChange] = args
            const afterChange = args[0];
            const registeredAccounts = TD.storage.accountController.getAccountsForService('twitter');
            const defaultAccount = registeredAccounts.filter((acc)=>{
                return acc.privateState.key === afterChange;
            })[0];
            if (!defaultAccount) {
                console.error('fail to get default account! %o %o', registeredAccounts, args);
                return;
            }
            const userName = defaultAccount.state.username;
            document.body.setAttribute('data-default-account-username', userName);
        }
        // 기본계정이 바뀌면 data-default-account-username도 같이 바뀌도록
        TD.storage.notification.notify$REAL = TD.storage.notification.notify;
        TD.storage.notification.notify = function(msg) {
            TD.storage.notification.notify$REAL.apply(this, arguments);
            if (msg !== '/storage/client/default_account_changed') {
                return;
            }
            if (msg === '/storage/client/default_account_changed') {
                onDefaultAccountChanged([].slice.call(arguments, 1));
            }
        };
    }
    function applyMagicToMustache(mustaches) {
        function magicalTemplate(templateName) {
            return `\n        <span class="mob-user-data"\n        style="display:none;visibility:hidden"\n        data-template="${templateName}"\n        data-id="{{id}}"\n        data-name="{{name}}"\n        data-screen-name="{{screenName}}"\n        data-blocking="{{blocking}}"\n        data-blocked-by="{{blockedBy}}"\n        data-muting="{{muting}}"\n        data-following="{{following}}"\n        data-followed-by="{{followedBy}}"\n        ></span>\n      `;
        }
        mustaches['twitter_profile.mustache'] += `\n      {{#twitterProfile}}\n        {{#profile}}\n          ${magicalTemplate('twitter_profile')}\n        {{/profile}}\n      {{/twitterProfile}}\n    `;
        mustaches['account_summary.mustache'] += magicalTemplate('account_summary');
        mustaches['account_summary_inline.mustache'] += magicalTemplate('account_summary_inline');
        mustaches['status/tweet_single_header.mustache'] += magicalTemplate('status/tweet_single_header');
    /* not-workings:
     *  compose/reply_info
     */ }
    function main() {
        // TD.ready 이벤트 접근이 어렵다...
        const loadingElem = document.querySelector('.js-app-loading');
        if (!loadingElem) {
            throw new Error('fail to initialize tweetdeck');
        }
        const readyObserver = new MutationObserver((mutations)=>{
            for (const mutation of mutations){
                if (mutation.type !== 'attributes') {
                    continue;
                }
                const target = mutation.target;
                if (target instanceof HTMLElement && mutation.attributeName === 'style' && target.style.display === 'none') {
                    const ev = new CustomEvent('TDLoaded');
                    document.dispatchEvent(ev);
                    readyObserver.disconnect();
                }
            }
        });
        readyObserver.observe(loadingElem, {
            // subtree: true,
            // childList: true,
            attributes: true
        });
        // @ts-ignore
        applyMagicToTD(window.TD);
        // @ts-ignore
        applyMagicToMustache(window.TD.mustaches || window.TD_mustaches);
    }
    main();
}

/***/ })

/******/ });
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vLy4vc3JjL3NjcmlwdHMvaW5qZWN0L3R3ZWV0ZGVjay1pbmplY3QudHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtRQUFBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBOzs7UUFHQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMENBQTBDLGdDQUFnQztRQUMxRTtRQUNBOztRQUVBO1FBQ0E7UUFDQTtRQUNBLHdEQUF3RCxrQkFBa0I7UUFDMUU7UUFDQSxpREFBaUQsY0FBYztRQUMvRDs7UUFFQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0EseUNBQXlDLGlDQUFpQztRQUMxRSxnSEFBZ0gsbUJBQW1CLEVBQUU7UUFDckk7UUFDQTs7UUFFQTtRQUNBO1FBQ0E7UUFDQSwyQkFBMkIsMEJBQTBCLEVBQUU7UUFDdkQsaUNBQWlDLGVBQWU7UUFDaEQ7UUFDQTtRQUNBOztRQUVBO1FBQ0Esc0RBQXNELCtEQUErRDs7UUFFckg7UUFDQTs7O1FBR0E7UUFDQTs7Ozs7Ozs7Ozs7OzthQ2pGVyxjQUFjLENBQUMsRUFBTztRQUM3QixFQUEyQyx5Q0FBd0Q7UUFDM0MsRUFBdEQsQ0FBQyxRQUFRLENBQUMsYUFBYSxDQUFDLFNBQVMsQ0FBQyxZQUFZLEdBQUcsRUFBRSxDQUFDLFFBQVEsQ0FBQyxhQUFhLENBQUMsU0FBUyxDQUFDLE9BQU87UUFDOUYsRUFBRSxDQUFDLFFBQVEsQ0FBQyxhQUFhLENBQUMsU0FBUyxDQUFDLE9BQU8sWUFBYSxHQUFRLEVBQUUsTUFBVztZQUMzRSxNQUFNLENBQUMsTUFBTSxDQUFDLE1BQU0sQ0FBQyxNQUFNOztnQkFDekIsZ0JBQWdCLEVBQUUsQ0FB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QWMsQ0FBQyxNQUFNLENBQUMsRUFBRTtRQUN4QixFQUFhO1FBQ2Isb0JBQW9CLENBQUMsTUFBTSxDQUFDLEVBQUUsQ0FBQyxTQUFTLElBQUksTUFBTSxDQUFDLFlBQVk7O0lBRWpFLElBQUkiLCJmaWxlIjoidHdlZXRkZWNrX2luamVjdC5idW4uanMiLCJzb3VyY2VzQ29udGVudCI6WyIgXHQvLyBUaGUgbW9kdWxlIGNhY2hlXG4gXHR2YXIgaW5zdGFsbGVkTW9kdWxlcyA9IHt9O1xuXG4gXHQvLyBUaGUgcmVxdWlyZSBmdW5jdGlvblxuIFx0ZnVuY3Rpb24gX193ZWJwYWNrX3JlcXVpcmVfXyhtb2R1bGVJZCkge1xuXG4gXHRcdC8vIENoZWNrIGlmIG1vZHVsZSBpcyBpbiBjYWNoZVxuIFx0XHRpZihpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXSkge1xuIFx0XHRcdHJldHVybiBpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXS5leHBvcnRzO1xuIFx0XHR9XG4gXHRcdC8vIENyZWF0ZSBhIG5ldyBtb2R1bGUgKGFuZCBwdXQgaXQgaW50byB0aGUgY2FjaGUpXG4gXHRcdHZhciBtb2R1bGUgPSBpbnN0YWxsZWRNb2R1bGVzW21vZHVsZUlkXSA9IHtcbiBcdFx0XHRpOiBtb2R1bGVJZCxcbiBcdFx0XHRsOiBmYWxzZSxcbiBcdFx0XHRleHBvcnRzOiB7fVxuIFx0XHR9O1xuXG4gXHRcdC8vIEV4ZWN1dGUgdGhlIG1vZHVsZSBmdW5jdGlvblxuIFx0XHRtb2R1bGVzW21vZHVsZUlkXS5jYWxsKG1vZHVsZS5leHBvcnRzLCBtb2R1bGUsIG1vZHVsZS5leHBvcnRzLCBfX3dlYnBhY2tfcmVxdWlyZV9fKTtcblxuIFx0XHQvLyBGbGFnIHRoZSBtb2R1bGUgYXMgbG9hZGVkXG4gXHRcdG1vZHVsZS5sID0gdHJ1ZTtcblxuIFx0XHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuIFx0XHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG4gXHR9XG5cblxuIFx0Ly8gZXhwb3NlIHRoZSBtb2R1bGVzIG9iamVjdCAoX193ZWJwYWNrX21vZHVsZXNfXylcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubSA9IG1vZHVsZXM7XG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlIGNhY2hlXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmMgPSBpbnN0YWxsZWRNb2R1bGVzO1xuXG4gXHQvLyBkZWZpbmUgZ2V0dGVyIGZ1bmN0aW9uIGZvciBoYXJtb255IGV4cG9ydHNcbiBcdF9fd2VicGFja19yZXF1aXJlX18uZCA9IGZ1bmN0aW9uKGV4cG9ydHMsIG5hbWUsIGdldHRlcikge1xuIFx0XHRpZighX193ZWJwYWNrX3JlcXVpcmVfXy5vKGV4cG9ydHMsIG5hbWUpKSB7XG4gXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIG5hbWUsIHsgZW51bWVyYWJsZTogdHJ1ZSwgZ2V0OiBnZXR0ZXIgfSk7XG4gXHRcdH1cbiBcdH07XG5cbiBcdC8vIGRlZmluZSBfX2VzTW9kdWxlIG9uIGV4cG9ydHNcbiBcdF9fd2VicGFja19yZXF1aXJlX18uciA9IGZ1bmN0aW9uKGV4cG9ydHMpIHtcbiBcdFx0aWYodHlwZW9mIFN5bWJvbCAhPT0gJ3VuZGVmaW5lZCcgJiYgU3ltYm9sLnRvU3RyaW5nVGFnKSB7XG4gXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIFN5bWJvbC50b1N0cmluZ1RhZywgeyB2YWx1ZTogJ01vZHVsZScgfSk7XG4gXHRcdH1cbiBcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsICdfX2VzTW9kdWxlJywgeyB2YWx1ZTogdHJ1ZSB9KTtcbiBcdH07XG5cbiBcdC8vIGNyZWF0ZSBhIGZha2UgbmFtZXNwYWNlIG9iamVjdFxuIFx0Ly8gbW9kZSAmIDE6IHZhbHVlIGlzIGEgbW9kdWxlIGlkLCByZXF1aXJlIGl0XG4gXHQvLyBtb2RlICYgMjogbWVyZ2UgYWxsIHByb3BlcnRpZXMgb2YgdmFsdWUgaW50byB0aGUgbnNcbiBcdC8vIG1vZGUgJiA0OiByZXR1cm4gdmFsdWUgd2hlbiBhbHJlYWR5IG5zIG9iamVjdFxuIFx0Ly8gbW9kZSAmIDh8MTogYmVoYXZlIGxpa2UgcmVxdWlyZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy50ID0gZnVuY3Rpb24odmFsdWUsIG1vZGUpIHtcbiBcdFx0aWYobW9kZSAmIDEpIHZhbHVlID0gX193ZWJwYWNrX3JlcXVpcmVfXyh2YWx1ZSk7XG4gXHRcdGlmKG1vZGUgJiA4KSByZXR1cm4gdmFsdWU7XG4gXHRcdGlmKChtb2RlICYgNCkgJiYgdHlwZW9mIHZhbHVlID09PSAnb2JqZWN0JyAmJiB2YWx1ZSAmJiB2YWx1ZS5fX2VzTW9kdWxlKSByZXR1cm4gdmFsdWU7XG4gXHRcdHZhciBucyA9IE9iamVjdC5jcmVhdGUobnVsbCk7XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18ucihucyk7XG4gXHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShucywgJ2RlZmF1bHQnLCB7IGVudW1lcmFibGU6IHRydWUsIHZhbHVlOiB2YWx1ZSB9KTtcbiBcdFx0aWYobW9kZSAmIDIgJiYgdHlwZW9mIHZhbHVlICE9ICdzdHJpbmcnKSBmb3IodmFyIGtleSBpbiB2YWx1ZSkgX193ZWJwYWNrX3JlcXVpcmVfXy5kKG5zLCBrZXksIGZ1bmN0aW9uKGtleSkgeyByZXR1cm4gdmFsdWVba2V5XTsgfS5iaW5kKG51bGwsIGtleSkpO1xuIFx0XHRyZXR1cm4gbnM7XG4gXHR9O1xuXG4gXHQvLyBnZXREZWZhdWx0RXhwb3J0IGZ1bmN0aW9uIGZvciBjb21wYXRpYmlsaXR5IHdpdGggbm9uLWhhcm1vbnkgbW9kdWxlc1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5uID0gZnVuY3Rpb24obW9kdWxlKSB7XG4gXHRcdHZhciBnZXR0ZXIgPSBtb2R1bGUgJiYgbW9kdWxlLl9fZXNNb2R1bGUgP1xuIFx0XHRcdGZ1bmN0aW9uIGdldERlZmF1bHQoKSB7IHJldHVybiBtb2R1bGVbJ2RlZmF1bHQnXTsgfSA6XG4gXHRcdFx0ZnVuY3Rpb24gZ2V0TW9kdWxlRXhwb3J0cygpIHsgcmV0dXJuIG1vZHVsZTsgfTtcbiBcdFx0X193ZWJwYWNrX3JlcXVpcmVfXy5kKGdldHRlciwgJ2EnLCBnZXR0ZXIpO1xuIFx0XHRyZXR1cm4gZ2V0dGVyO1xuIFx0fTtcblxuIFx0Ly8gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm8gPSBmdW5jdGlvbihvYmplY3QsIHByb3BlcnR5KSB7IHJldHVybiBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGwob2JqZWN0LCBwcm9wZXJ0eSk7IH07XG5cbiBcdC8vIF9fd2VicGFja19wdWJsaWNfcGF0aF9fXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLnAgPSBcIlwiO1xuXG5cbiBcdC8vIExvYWQgZW50cnkgbW9kdWxlIGFuZCByZXR1cm4gZXhwb3J0c1xuIFx0cmV0dXJuIF9fd2VicGFja19yZXF1aXJlX18oX193ZWJwYWNrX3JlcXVpcmVfXy5zID0gXCIuL3NyYy9zY3JpcHRzL2luamVjdC90d2VldGRlY2staW5qZWN0LnRzXCIpO1xuIiwie1xuICBmdW5jdGlvbiBhcHBseU1hZ2ljVG9URChURDogYW55KSB7XG4gICAgLy8g7Yq47JyX642x7J2YIEFKQVjsmpTssq3sl5Ag7LCo64uo7Jes67aAIOygleuztOulvCDtj6ztlajtlZjqsowg7ZW07KO864qUIOyYteyFmOydhCDstpTqsIDtlZzri6QuXG4gICAgVEQuc2VydmljZXMuVHdpdHRlckNsaWVudC5wcm90b3R5cGUucmVxdWVzdCRSRUFMID0gVEQuc2VydmljZXMuVHdpdHRlckNsaWVudC5wcm90b3R5cGUucmVxdWVzdFxuICAgIFRELnNlcnZpY2VzLlR3aXR0ZXJDbGllbnQucHJvdG90eXBlLnJlcXVlc3QgPSBmdW5jdGlvbiAodXJsOiBhbnksIG9wdGlvbjogYW55KSB7XG4gICAgICBPYmplY3QuYXNzaWduKG9wdGlvbi5wYXJhbXMgfHwge30sIHtcbiAgICAgICAgaW5jbHVkZV9ibG9ja2luZzogMSxcbiAgICAgICAgaW5jbHVkZV9ibG9ja2VkX2J5OiAxLFxuICAgICAgICBpbmNsdWRlX211dGVfZWRnZTogMSxcbiAgICAgICAgaW5jbHVkZV9mb2xsb3dlZF9ieTogMSxcbiAgICAgIH0pXG4gICAgICByZXR1cm4gVEQuc2VydmljZXMuVHdpdHRlckNsaWVudC5wcm90b3R5cGUucmVxdWVzdCRSRUFMLmNhbGwodGhpcywgdXJsLCBvcHRpb24pXG4gICAgfVxuXG4gICAgLy8gVHdpdHRlclVzZXLsl5Ag7IKs7Jqp7J6QIOywqOuLqOyXrOu2gOulvCDrhKPsnLzrqbQg7Yq47JyX642x7J2YIO2VhO2EsOq4sOuKpSDrk7Hsl5DshJwg7J2066W8IOydtOyaqe2VoCDsiJgg7J6I64ukLlxuICAgIGZ1bmN0aW9uIGluc2VydEFkZGl0aW9uYWxJbmZvKHRhcmdldE9iamVjdDogYW55LCBhZGRpdGlvbmFsOiBhbnkpIHtcbiAgICAgIHJldHVybiBPYmplY3QuYXNzaWduKHRhcmdldE9iamVjdCwge1xuICAgICAgICBibG9ja2VkQnk6IGFkZGl0aW9uYWwuYmxvY2tlZF9ieSxcbiAgICAgICAgYmxvY2tpbmc6IGFkZGl0aW9uYWwuYmxvY2tpbmcsXG4gICAgICAgIGZvbGxvd2VkQnk6IGFkZGl0aW9uYWwuZm9sbG93ZWRfYnksXG4gICAgICAgIGZvbGxvd2luZzogYWRkaXRpb25hbC5mb2xsb3dpbmcsXG4gICAgICAgIG11dGluZzogYWRkaXRpb25hbC5tdXRpbmcsXG4gICAgICB9KVxuICAgIH1cbiAgICBURC5zZXJ2aWNlcy5Ud2l0dGVyVXNlci5wcm90b3R5cGUuZnJvbUpTT05PYmplY3QkUkVBTCA9XG4gICAgICBURC5zZXJ2aWNlcy5Ud2l0dGVyVXNlci5wcm90b3R5cGUuZnJvbUpTT05PYmplY3RcbiAgICBURC5zZXJ2aWNlcy5Ud2l0dGVyVXNlci5wcm90b3R5cGUuZnJvbUpTT05PYmplY3QgPSBmdW5jdGlvbiAoanNvbjogYW55LCB0OiBhbnkpIHtcbiAgICAgIGluc2VydEFkZGl0aW9uYWxJbmZvKHRoaXMsIGpzb24pXG4gICAgICByZXR1cm4gVEQuc2VydmljZXMuVHdpdHRlclVzZXIucHJvdG90eXBlLmZyb21KU09OT2JqZWN0JFJFQUwuY2FsbCh0aGlzLCBqc29uLCB0KVxuICAgIH1cbiAgICBURC5zZXJ2aWNlcy5Ud2l0dGVyVXNlci5wcm90b3R5cGUuZnJvbUdyYXBoUUxKU09OT2JqZWN0JFJFQUwgPVxuICAgICAgVEQuc2VydmljZXMuVHdpdHRlclVzZXIucHJvdG90eXBlLmZyb21HcmFwaFFMSlNPTk9iamVjdFxuICAgIFRELnNlcnZpY2VzLlR3aXR0ZXJVc2VyLnByb3RvdHlwZS5mcm9tR3JhcGhRTEpTT05PYmplY3QgPSBmdW5jdGlvbiAoanNvbjogYW55LCB0OiBhbnkpIHtcbiAgICAgIGluc2VydEFkZGl0aW9uYWxJbmZvKHRoaXMsIGpzb24ubGVnYWN5KVxuICAgICAgcmV0dXJuIFRELnNlcnZpY2VzLlR3aXR0ZXJVc2VyLnByb3RvdHlwZS5mcm9tR3JhcGhRTEpTT05PYmplY3QkUkVBTC5jYWxsKHRoaXMsIGpzb24sIHQpXG4gICAgfVxuXG4gICAgLy8g7Yq47JyX642x7JeQ7ISgIFwi64KY66W8IOywqOuLqO2VqFwiIOuMgOyLoCBcIkAo6riw67O46rOE7KCVKeydhCDssKjri6jtlahcIiDqsJnsnYAg7Iud7Jy866GcIOuztOyXrOykmOyVvO2VqFxuICAgIC8vIOydtOulvCDsnITtlbQg7ZiE7J6sIOyEpOygleuQnCDquLDrs7jqs4TsoJXsnYQg7JWM7JWE64K8IOyImCDsnojslrTslbztlahcbiAgICAvLyDrlLDrnbzshJwsIOq4sOuzuOqzhOygleydtCDrs4Dqsr3rkKAg65WMIOuniOuLpCBET03sl5Ag7IKs7Jqp7J6Q7JWE7J2065SU66W8IOuEo+yWtCBjb250ZW50LXNjcmlwdHPsl5DshJwg7KCR6re87ZWgIOyImCDsnojrj4TroZ0g7ZWc64ukLlxuICAgIGRvY3VtZW50LmFkZEV2ZW50TGlzdGVuZXIoJ1RETG9hZGVkJywgKCkgPT4ge1xuICAgICAgZG9jdW1lbnQuYm9keS5zZXRBdHRyaWJ1dGUoXG4gICAgICAgICdkYXRhLWRlZmF1bHQtYWNjb3VudC11c2VybmFtZScsXG4gICAgICAgIFRELnN0b3JhZ2UuYWNjb3VudENvbnRyb2xsZXIuZ2V0RGVmYXVsdCgpLnN0YXRlLnVzZXJuYW1lXG4gICAgICApXG4gICAgfSlcblxuICAgIGZ1bmN0aW9uIG9uRGVmYXVsdEFjY291bnRDaGFuZ2VkKGFyZ3M6IGFueSkge1xuICAgICAgLy8gY29uc3QgW2FmdGVyQ2hhbmdlLCBiZWZvcmVDaGFuZ2VdID0gYXJnc1xuICAgICAgY29uc3QgYWZ0ZXJDaGFuZ2UgPSBhcmdzWzBdXG4gICAgICBjb25zdCByZWdpc3RlcmVkQWNjb3VudHMgPSBURC5zdG9yYWdlLmFjY291bnRDb250cm9sbGVyLmdldEFjY291bnRzRm9yU2VydmljZSgndHdpdHRlcicpXG4gICAgICBjb25zdCBkZWZhdWx0QWNjb3VudCA9IHJlZ2lzdGVyZWRBY2NvdW50cy5maWx0ZXIoKGFjYzogYW55KSA9PiB7XG4gICAgICAgIHJldHVybiBhY2MucHJpdmF0ZVN0YXRlLmtleSA9PT0gYWZ0ZXJDaGFuZ2VcbiAgICAgIH0pWzBdXG4gICAgICBpZiAoIWRlZmF1bHRBY2NvdW50KSB7XG4gICAgICAgIGNvbnNvbGUuZXJyb3IoJ2ZhaWwgdG8gZ2V0IGRlZmF1bHQgYWNjb3VudCEgJW8gJW8nLCByZWdpc3RlcmVkQWNjb3VudHMsIGFyZ3MpXG4gICAgICAgIHJldHVyblxuICAgICAgfVxuICAgICAgY29uc3QgdXNlck5hbWUgPSBkZWZhdWx0QWNjb3VudC5zdGF0ZS51c2VybmFtZVxuICAgICAgZG9jdW1lbnQuYm9keS5zZXRBdHRyaWJ1dGUoJ2RhdGEtZGVmYXVsdC1hY2NvdW50LXVzZXJuYW1lJywgdXNlck5hbWUpXG4gICAgfVxuICAgIC8vIOq4sOuzuOqzhOygleydtCDrsJTrgIzrqbQgZGF0YS1kZWZhdWx0LWFjY291bnQtdXNlcm5hbWXrj4Qg6rCZ7J20IOuwlOuAjOuPhOuhnVxuICAgIFRELnN0b3JhZ2Uubm90aWZpY2F0aW9uLm5vdGlmeSRSRUFMID0gVEQuc3RvcmFnZS5ub3RpZmljYXRpb24ubm90aWZ5XG4gICAgVEQuc3RvcmFnZS5ub3RpZmljYXRpb24ubm90aWZ5ID0gZnVuY3Rpb24gKG1zZzogc3RyaW5nKSB7XG4gICAgICBURC5zdG9yYWdlLm5vdGlmaWNhdGlvbi5ub3RpZnkkUkVBTC5hcHBseSh0aGlzLCBhcmd1bWVudHMpXG4gICAgICBpZiAobXNnICE9PSAnL3N0b3JhZ2UvY2xpZW50L2RlZmF1bHRfYWNjb3VudF9jaGFuZ2VkJykge1xuICAgICAgICByZXR1cm5cbiAgICAgIH1cbiAgICAgIGlmIChtc2cgPT09ICcvc3RvcmFnZS9jbGllbnQvZGVmYXVsdF9hY2NvdW50X2NoYW5nZWQnKSB7XG4gICAgICAgIG9uRGVmYXVsdEFjY291bnRDaGFuZ2VkKFtdLnNsaWNlLmNhbGwoYXJndW1lbnRzLCAxKSlcbiAgICAgIH1cbiAgICB9XG4gIH1cblxuICBmdW5jdGlvbiBhcHBseU1hZ2ljVG9NdXN0YWNoZShtdXN0YWNoZXM6IGFueSkge1xuICAgIGZ1bmN0aW9uIG1hZ2ljYWxUZW1wbGF0ZSh0ZW1wbGF0ZU5hbWU6IHN0cmluZykge1xuICAgICAgcmV0dXJuIGBcbiAgICAgICAgPHNwYW4gY2xhc3M9XCJtb2ItdXNlci1kYXRhXCJcbiAgICAgICAgc3R5bGU9XCJkaXNwbGF5Om5vbmU7dmlzaWJpbGl0eTpoaWRkZW5cIlxuICAgICAgICBkYXRhLXRlbXBsYXRlPVwiJHt0ZW1wbGF0ZU5hbWV9XCJcbiAgICAgICAgZGF0YS1pZD1cInt7aWR9fVwiXG4gICAgICAgIGRhdGEtbmFtZT1cInt7bmFtZX19XCJcbiAgICAgICAgZGF0YS1zY3JlZW4tbmFtZT1cInt7c2NyZWVuTmFtZX19XCJcbiAgICAgICAgZGF0YS1ibG9ja2luZz1cInt7YmxvY2tpbmd9fVwiXG4gICAgICAgIGRhdGEtYmxvY2tlZC1ieT1cInt7YmxvY2tlZEJ5fX1cIlxuICAgICAgICBkYXRhLW11dGluZz1cInt7bXV0aW5nfX1cIlxuICAgICAgICBkYXRhLWZvbGxvd2luZz1cInt7Zm9sbG93aW5nfX1cIlxuICAgICAgICBkYXRhLWZvbGxvd2VkLWJ5PVwie3tmb2xsb3dlZEJ5fX1cIlxuICAgICAgICA+PC9zcGFuPlxuICAgICAgYFxuICAgIH1cbiAgICBtdXN0YWNoZXNbJ3R3aXR0ZXJfcHJvZmlsZS5tdXN0YWNoZSddICs9IGBcbiAgICAgIHt7I3R3aXR0ZXJQcm9maWxlfX1cbiAgICAgICAge3sjcHJvZmlsZX19XG4gICAgICAgICAgJHttYWdpY2FsVGVtcGxhdGUoJ3R3aXR0ZXJfcHJvZmlsZScpfVxuICAgICAgICB7ey9wcm9maWxlfX1cbiAgICAgIHt7L3R3aXR0ZXJQcm9maWxlfX1cbiAgICBgXG4gICAgbXVzdGFjaGVzWydhY2NvdW50X3N1bW1hcnkubXVzdGFjaGUnXSArPSBtYWdpY2FsVGVtcGxhdGUoJ2FjY291bnRfc3VtbWFyeScpXG4gICAgbXVzdGFjaGVzWydhY2NvdW50X3N1bW1hcnlfaW5saW5lLm11c3RhY2hlJ10gKz0gbWFnaWNhbFRlbXBsYXRlKCdhY2NvdW50X3N1bW1hcnlfaW5saW5lJylcbiAgICBtdXN0YWNoZXNbJ3N0YXR1cy90d2VldF9zaW5nbGVfaGVhZGVyLm11c3RhY2hlJ10gKz0gbWFnaWNhbFRlbXBsYXRlKFxuICAgICAgJ3N0YXR1cy90d2VldF9zaW5nbGVfaGVhZGVyJ1xuICAgIClcbiAgICAvKiBub3Qtd29ya2luZ3M6XG4gICAgICogIGNvbXBvc2UvcmVwbHlfaW5mb1xuICAgICAqL1xuICB9XG5cbiAgZnVuY3Rpb24gbWFpbigpIHtcbiAgICAvLyBURC5yZWFkeSDsnbTrsqTtirgg7KCR6re87J20IOyWtOugteuLpC4uLlxuICAgIGNvbnN0IGxvYWRpbmdFbGVtID0gZG9jdW1lbnQucXVlcnlTZWxlY3RvcignLmpzLWFwcC1sb2FkaW5nJylcbiAgICBpZiAoIWxvYWRpbmdFbGVtKSB7XG4gICAgICB0aHJvdyBuZXcgRXJyb3IoJ2ZhaWwgdG8gaW5pdGlhbGl6ZSB0d2VldGRlY2snKVxuICAgIH1cbiAgICBjb25zdCByZWFkeU9ic2VydmVyID0gbmV3IE11dGF0aW9uT2JzZXJ2ZXIobXV0YXRpb25zID0+IHtcbiAgICAgIGZvciAoY29uc3QgbXV0YXRpb24gb2YgbXV0YXRpb25zKSB7XG4gICAgICAgIGlmIChtdXRhdGlvbi50eXBlICE9PSAnYXR0cmlidXRlcycpIHtcbiAgICAgICAgICBjb250aW51ZVxuICAgICAgICB9XG4gICAgICAgIGNvbnN0IHRhcmdldCA9IG11dGF0aW9uLnRhcmdldFxuICAgICAgICBpZiAoXG4gICAgICAgICAgdGFyZ2V0IGluc3RhbmNlb2YgSFRNTEVsZW1lbnQgJiZcbiAgICAgICAgICBtdXRhdGlvbi5hdHRyaWJ1dGVOYW1lID09PSAnc3R5bGUnICYmXG4gICAgICAgICAgdGFyZ2V0LnN0eWxlLmRpc3BsYXkgPT09ICdub25lJ1xuICAgICAgICApIHtcbiAgICAgICAgICBjb25zdCBldiA9IG5ldyBDdXN0b21FdmVudCgnVERMb2FkZWQnKVxuICAgICAgICAgIGRvY3VtZW50LmRpc3BhdGNoRXZlbnQoZXYpXG4gICAgICAgICAgcmVhZHlPYnNlcnZlci5kaXNjb25uZWN0KClcbiAgICAgICAgfVxuICAgICAgfVxuICAgIH0pXG4gICAgcmVhZHlPYnNlcnZlci5vYnNlcnZlKGxvYWRpbmdFbGVtLCB7XG4gICAgICAvLyBzdWJ0cmVlOiB0cnVlLFxuICAgICAgLy8gY2hpbGRMaXN0OiB0cnVlLFxuICAgICAgYXR0cmlidXRlczogdHJ1ZSxcbiAgICB9KVxuXG4gICAgLy8gQHRzLWlnbm9yZVxuICAgIGFwcGx5TWFnaWNUb1REKHdpbmRvdy5URClcbiAgICAvLyBAdHMtaWdub3JlXG4gICAgYXBwbHlNYWdpY1RvTXVzdGFjaGUod2luZG93LlRELm11c3RhY2hlcyB8fCB3aW5kb3cuVERfbXVzdGFjaGVzKVxuICB9XG4gIG1haW4oKVxufVxuIl0sInNvdXJjZVJvb3QiOiIifQ==