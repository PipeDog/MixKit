class NativeModules {

    constructor(props) {
        this._callbacksMap = {};
        this._registerModules(props);
    }

    _getValueType(value) {
        return Object.prototype.toString.call(value).replace(/\s|object|\[|\]/g, '').toLowerCase();
    }

    _generateCallbackId() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        });
    }

    _callNativeFunction(moduleName, methodName, params, callback) {
        var callbackID = null;
        if (this._getValueType(callback) === 'function') {
            callbackID = this._generateCallbackId();
            this._callbacksMap[callbackID] = callback;
        }
        const message = {
            'moduleName': moduleName,
            'methodName': methodName,
            'params': params,
            'callbackID': callbackID,
        };

        switch (String(window.__mk_systemType)) {
            case '1': // iOS
                console.log(`INFO: Send iOS "${JSON.stringify(message)}"`);
                window.webkit.messageHandlers.MixKit.postMessage(message);
                break;
            case '2': // Android
                console.log(`INFO: Send Android "${JSON.stringify(message)}"`);
                window.MixKit.postMessage(JSON.stringify(message));
                break;
            default: // Unknown
                console.error('ERROR: Platform is not android or iOS!');
                break;
        }
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
                    if (args.length > 2) {
                        return console.error('ERROR: Invalid arguments count!');
                    }

                    const firstArg = args.length > 0 ? args[0] : null;
                    const lastArg = args.length > 0 ? args[args.length - 1] : null;
                    const params = (this._getValueType(firstArg) === 'object' ? firstArg : null);
                    const callback = (this._getValueType(lastArg) === 'function' ? lastArg : null);
                    this._callNativeFunction(moduleName, moduleMethodName, params, callback);
                };
            });
        });
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
        callback(res);
    }
}

NativeModules = new NativeModules(window.__mk_nativeConfig);

