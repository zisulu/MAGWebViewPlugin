(function () {
    function iosConnect(callback) {
        if (window.MagAndroidClient) {
            return;
        }
        if (window.WebViewJavascriptBridge) {
            return callback(WebViewJavascriptBridge);
        } else {
            document.addEventListener('WebViewJavascriptBridgeReady', function (evt) {
                callback(WebViewJavascriptBridge);
            }, false);
        }
        
        if (window.WVJBCallbacks) {
            return window.WVJBCallbacks.push(callback);
        } else {
            window.WVJBCallbacks = [callback];
            var WVJBIframe = document.createElement('iframe');
            WVJBIframe.style.display = 'none';
            // WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
            WVJBIframe.src = 'https://__bridge_loaded__';
            document.documentElement.appendChild(WVJBIframe);
            setTimeout(function () {
                document.documentElement.removeChild(WVJBIframe);
            }, 0);
        }
        
    }
    
    iosConnect(function (bridge) {
        // iOS UIWebView 的bridge对象初始化
        if (bridge.init && typeof bridge.init === 'function') {
            bridge.init(function (message, responseCallback) {
                
            });
        }
        bridge.registerHandler('jsCallBack', function (data, responseCallback) {
            var call = JSON.parse(data);
            var id = call.id;
            var val = call.val;
            var callback = mag.callbacks[id];
            if (callback) {
                if (callback.type && callback.type == 'json') {
                    if(val){
                        val = JSON.parse(val);
                    }
                }
                callback.success(val);
            }
        });
    });
    
    function MAGJSONStringify(str) {
        var isJSONString = false;
        if (typeof str == 'string') {
            try {
                var obj= JSON.parse(str);
                if (typeof obj == 'object' && obj) {
                    isJSONString = true;
                } else {
                    isJSONString = false;
                }
            } catch(e) {
                isJSONString = false;
            }
        }
        if (isJSONString) {
            return str;
        } else {
            return JSON.stringify(str);
        }
    }
    
    
    mag = {
    VERSION:'2.0.0',
    ready:function (fun) {
        iosConnect(function () {
            fun();
        });
        if(window.MagAndroidClient){
            fun();
        }
    },
    callbacks: {
        
    },
    iosConnect: iosConnect,
    jsCallBack: function (id, val) {
        var callback = mag.callbacks[id];
        if (callback) {
            if (callback.type && callback.type == 'json') {
                if(val){
                    val = JSON.parse(val);
                }
            }
            callback.success(val);
        }
    },
    setData: function (config) {
        var configStr = JSON.stringify(config);
        if (window.MagAndroidClient) {
            window.MagAndroidClient.setData(configStr);
        }
        iosConnect(function (bridge) {
            bridge.callHandler('setData', configStr, function (rs) {
            });
        });
        window.webkit.messageHandlers.setData.postMessage(configStr);
    },
    dialog:function (config) {
        var configStr = JSON.stringify(config);
        mag.callbacks.dialogSuccess = {
        type: 'json',
        success: config.success
        };
        mag.callbacks.dialogCancel = {
        type: 'json',
        success: config.cancel
        };
        if (window.MagAndroidClient) {
            window.MagAndroidClient.dialog(configStr);
        }
        iosConnect(function (bridge) {
            bridge.callHandler('dialog', configStr, function (rs) {
            });
        });
        window.webkit.messageHandlers.dialog.postMessage(configStr);
    },
    setPageLife: function(life){
        mag.callbacks.pageAppear = {
        type: '',
        success: life.pageAppear
        };
        mag.callbacks.pageDisappear = {
        type: '',
        success: life.pageDisappear
        };
    },
    showPhoneSettings: function (){
        iosConnect(function (bridge) {
            bridge.callHandler('showPhoneSettings', '', function (rs) {
            });
        });
        window.webkit.messageHandlers.showPhoneSettings.postMessage('');
    },
    getDeviceId: function (success){
        mag.callbacks.getDeviceId={
        type: 'string',
        success: success
        };
        if (window.MagAndroidClient) {
            window.MagAndroidClient.getDeviceId();
        }
        iosConnect(function(bridge){
            bridge.callHandler('getDeviceId', '', function(rs){});
        });
        window.webkit.messageHandlers.getDeviceId.postMessage('');
    },
    addRefreshComponent: function (){
        if (window.MagAndroidClient) {
            window.MagAndroidClient.addRefreshComponent();
        }
        iosConnect(function(bridge){
            bridge.callHandler('addRefreshComponent', '', function(rs){});
        });
        window.webkit.messageHandlers.addRefreshComponent.postMessage('');
    },
    setNavigationBarStyle:function (config) {
        var configStr = MAGJSONStringify(config);
        if (window.MagAndroidClient) {
            window.MagAndroidClient.dialog(configStr);
        }
        iosConnect(function (bridge) {
            bridge.callHandler('setNavigationBarStyle', configStr, function (rs) {
            });
        });
        window.webkit.messageHandlers.setNavigationBarStyle.postMessage(configStr);
    }
    };
    window.mag = mag;
})();
