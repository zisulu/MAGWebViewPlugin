(function () {
    if (window.mag) {
        return;
    }
    var mag = {
        VERSION:'1.0.0',
        ready:function (fun) {
            if(window.webkit.messageHandlers){
                fun();
            }
        },
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
            mag.callbacks.pageDestroy = {
                type: '',
                success: life.pageDestroy
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
            window.webkit.messageHandlers.addRefreshComponent.postMessage('');
        },
        setNavigationBarStyle:function (config) {
            var configStr = JSON.stringify(config);
            window.webkit.messageHandlers.setNavigationBarStyle.postMessage(configStr);
        },
        // toast
            toast: function (text) {
              if (window.xiciAndroidClient) {
                window.xiciAndroidClient.toast(text);
              }
              window.webkit.messageHandlers.toast.postMessage(text);
            },
        // 举报
            report: function (config) {
              var configStr = JSON.stringify(config);
              if (window.xiciAndroidClient) {
                window.xiciAndroidClient.report(configStr);
              }
              window.webkit.messageHandlers.report.postMessage(configStr);
            },
            // 预览图片
            previewImage: function (config) {
              var configStr = JSON.stringify(config);
              if (window.xiciAndroidClient) {
                window.xiciAndroidClient.previewImage(configStr);
              }
              window.webkit.messageHandlers.previewImage.postMessage(configStr);
            },
            // 评论
            comment: function (config, fun) {
              if (!fun) return;
              mag.callbacks.comment = {
                type: "json",
                success: fun,
              };
              var configStr = JSON.stringify(config);
              if (window.xiciAndroidClient) {
                window.xiciAndroidClient.comment(configStr);
              }
              window.webkit.messageHandlers.comment.postMessage(configStr);
            },
            // 显示楼中楼详情
            showCommentDetail: function (config) {
              var configStr = JSON.stringify(config);
              if (window.xiciAndroidClient) {
                window.xiciAndroidClient.showCommentDetail(configStr);
              }
              window.webkit.messageHandlers.showCommentDetail.postMessage(configStr);
            },
            // 显示评论更多操作
            showCommentMoreAction: function (config, fun) {
              if (!fun) return;
              mag.callbacks.showCommentMoreAction = {
                type: "json",
                success: fun,
              };
              var configStr = JSON.stringify(config);
              if (window.xiciAndroidClient) {
                window.xiciAndroidClient.showCommentMoreAction(configStr);
              }
            window.webkit.messageHandlers.showCommentMoreAction.postMessage(configStr);
            },
    };
    window.mag = mag;
})();
