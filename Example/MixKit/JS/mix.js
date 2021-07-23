class NativeModules {

    constructor() {
        this._callbacksMap = {};
        this._registerModules(this._getNativeConfig());
    }

    // methods `_getSystemType` and `_getNativeConfig`
    // Android webView bug, call js maybe failed.
    _getSystemType() {
        let systemType;
        if (this._getValueType(window.__mk_systemType) === 'number' || this._getValueType(window.__mk_systemType) === 'string') {
            systemType = window.__mk_systemType;
        } else if (this._getValueType(window.MixKit) === 'object' && this._getValueType(window.MixKit.getSystemType) === 'function') {
            systemType = window.MixKit.getSystemType();
        } else {
            systemType = 0;
        }
        return String(systemType);
    }

    _getNativeConfig() {
        let nativeConfig;
        if (this._getValueType(window.__mk_nativeConfig) === 'object') {
            nativeConfig = window.__mk_nativeConfig;
        } else if (this._getValueType(window.MixKit) === 'object' && this._getValueType(window.MixKit.getNativeConfig) === 'function') {
            nativeConfig = JSON.parse(window.MixKit.getNativeConfig());
        } else {
            nativeConfig = {};
        }
        return nativeConfig;
    }

    _registerModules(modulesMap) {
        if (this._getValueType(modulesMap) !== 'object') {
            return console.error('ERROR: modulesMap is not an object!');
        }
        Object.keys(modulesMap).forEach(moduleName => {
            const moduleConfig = modulesMap[moduleName];
            const moduleMethods = moduleConfig.methods;
            if (!this[moduleName]) {
                this[moduleName] = {};
            }
            if (!Array.isArray(moduleMethods)) {
                return;
            }
            moduleMethods.forEach(moduleMethodName => {
                this[moduleName][moduleMethodName] = (...args) => {
                    this._callNativeFunction(moduleName, moduleMethodName, args);
                };
            });
        });
    }

    _callNativeFunction(moduleName, methodName, args) {
        let numberOfArgs = args.length;
        let nativeArguments = new Array(numberOfArgs);

        for (let index = 0; index < numberOfArgs; index++) {
            let arg = args[index];

            if (this._getValueType(arg) === 'function') {
                let callbackID = this._generateCallbackId();
                this._callbacksMap[callbackID] = arg;
                arg = callbackID;
            }

            nativeArguments[index] = arg;
        }

        const message = {
            moduleName: moduleName,
            methodName: methodName,
            arguments: nativeArguments
        };

        switch (this._getSystemType()) {
            case '1': { // iOS
                window.webkit.messageHandlers.MixKit.postMessage(message);
            } break;
            case '2': { // Android
                window.MixKit.postMessage(JSON.stringify(message));
            } break;
            default: { // Unknown
                console.error('ERROR: Platform is not android or iOS!');
            } break;
        }
    }

    _getValueType(value) {
        return Object.prototype.toString.call(value).replace(/\s|object|\[|\]/g, '').toLowerCase();
    }

    _generateCallbackId() {
        let uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        });
        return '_$_mk_callback_$_' + uuid;
    }

    invokeCallback(callbackId, response) {
        if (!callbackId) {
            return console.error('ERROR: CallbackId is not allowed to be empty!');
        }
        const callback = this._callbacksMap[callbackId];
        if (this._getValueType(callback) !== 'function') {
            return console.error('ERROR: Callback function is not exist!');
        }
        let res = response;
        if (this._getValueType(res) === 'string') {
            try {
                res = JSON.parse(res);
            } catch (error) {
                res = null;
                console.error('ERROR: Parse response error!');
            }
        }
        callback.apply(null, res);
    }

}

NativeModules = new NativeModules();
