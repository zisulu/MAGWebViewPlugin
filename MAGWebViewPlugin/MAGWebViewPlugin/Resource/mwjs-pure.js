(function () {
    if (window.mag) {
        return;
    }
    var mag = {
        VERSION:'1.0.0',
        callbacks: {},
        jsCallBack: function(id, val) {
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
        setData: function(config) {
            var configStr = JSON.stringify(config);
            window.webkit.messageHandlers.setData.postMessage(configStr);
        },
        dialog: function(config) {
            var configStr = JSON.stringify(config);
            mag.callbacks.dialogSuccess = {
                type: 'json',
                success: config.success
            };
            mag.callbacks.dialogCancel = {
                type: 'json',
                success: config.cancel
            };
            window.webkit.messageHandlers.dialog.postMessage(configStr);
        },
        setPageLife: function(life) {
            mag.callbacks.pageAppear = {
                type: '',
                success: life.pageAppear
            };
            mag.callbacks.pageDisappear = {
                type: '',
                success: life.pageDisappear
            };
        },
        showPhoneSettings: function() {
            window.webkit.messageHandlers.showPhoneSettings.postMessage('');
        },
        getDeviceId: function(success) {
            mag.callbacks.getDeviceId = {
                type: 'string',
                success: success
            };
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
        }
    };
    window.mag = mag;
})();
