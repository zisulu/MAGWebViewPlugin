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
        //iOS UIWebView 的bridge对象初始化
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


    mag = {
        VERSION:'1.1',
        /**
         * 所有回调
         */
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
        /**
         * 获取当前经纬度
         * 回调  {lat:1,lng:1,location:’江苏省南京市xxxxx’}
         * @param fun
         */
        getLocation: function (fun) {
            if (!fun)return;
            mag.callbacks.getLocation = {
                type: 'json',
                success: fun
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.getLocation();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('getLocation','',function (rs) {
                });
            });
        },
        /**
         * 地图位置选择
         * 回调  {lat:1,lng:1,location:’江苏省南京市xxxxx’}
         * @param fun
         */
        mapPick: function (fun) {
            if (!fun)return;
            mag.callbacks.mapPick = {
                type: 'json',
                success: fun
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.mapPick();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('mapPick','',function () {

                });
            });
        },
        /**
         * 关闭当前窗口
         */
        closeWin: function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.closeWin();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('closeWin', '', function (rs) {
                });
            });
        },
        /**
         * 图片预览
         * @param config json {current:0,pics:[“图片地址”,”图片地址”]}
         */
        previewImage: function (config) {
            var configStr = JSON.stringify(config);
            if (window.MagAndroidClient) {
                window.MagAndroidClient.previewImage(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('previewImage', configStr, function (rs) {
                });
            });
        },
        /**
         * 图片选择器
         * @param config
         * {
         * preview:成功后回调
         * success:上传成功后回调
         * fail:上传失败后回调
         * name:'文件上传名(可选)',
         * uploadUrl:'上传路劲(可选)'
         * }
         */
        picPick: function (config) {
            mag.callbacks.picPickPreview = {
                type: 'json',
                success: config.preview
            };
            mag.callbacks.picPickSuccess = {
                type: 'json',
                success: config.success
            };
            mag.callbacks.picPickFail = {
                type: 'json',
                success: config.fail
            };
            var configStr = JSON.stringify(config);
            if (window.MagAndroidClient) {
                window.MagAndroidClient.picPick(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('picPick', configStr, function (rs) {
                });
            });
        },
        /**
         * 拍照
         * @param config
         */
        camera:function (config) {
            mag.callbacks.cameraPreview = {
                type: 'json',
                success: config.preview
            };
            mag.callbacks.cameraSuccess = {
                type: 'json',
                success: config.success
            };
            mag.callbacks.cameraFail = {
                type: 'json',
                success: config.fail
            };
            var configStr = JSON.stringify(config);
            if (window.MagAndroidClient) {
                window.MagAndroidClient.camera(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('camera', configStr, function (rs) {
                });
            });
        },
        /**
         * 页面内容配置
         * @param config
         *config = {
                type: 1,
                circleId: 33,
                contentId: 11,
                shareData: {
                    cardtype: '', //卡片模版类型 1. 帖子  3.活动
                    pagetype: '', 页面类型名称， '活动'， ‘红包’ 等
                    title: '',
                    des: '',
                    picurl: '',
                    linkurl: '',
                    // 只是分享图片, 为0就是正常分享
                    type: 1,
                    // 分享图片的链接
                    imageurl: 'https://www.hiinterface.cn/index.php/png'
                }
            }
         */
        setData: function (config) {
            var configStr = JSON.stringify(config);
            if (window.MagAndroidClient) {
                window.MagAndroidClient.setData(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('setData', configStr, function (rs) {
                });
            });
        },
        /**
         * 分享
         * @param platform (ALL)全部  QQ(QQ) QZONE(QQ空间) WEIXIN(微信) WEIXIN_CIRCLE(微信朋友圈) WEIBO(新浪)
         * @param success 分享成功回调函数，有返回值：平台名称
         */
        share:function (platform, success, fail) {
            mag.callbacks.shareSuccess = {
                type: '',
                success: success
            };
            mag.callbacks.shareFailed = {
                type: '',
                success: fail
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.share(platform);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('share', platform, function (rs) {
                });
            });
        },
        /**
         * 分享名片
         * @param config 页面参数
         * @param success 分享成功回调函数
         * @param fail 分享失败回调函数
         */
        shareCard:function(config, success, fail){
            mag.callbacks.shareSuccess = {
                type: '',
                success: success
            };
            mag.callbacks.shareFailed = {
                type: '',
                success: fail
            };
            var configStr = JSON.stringify(config);
            if (window.MagAndroidClient) {
                window.MagAndroidClient.shareCard(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('shareCard', configStr, function (rs) {
                });
            });
        },
        /**
         * 绑定第三方
         * @param platform QQ(QQ) WEIXIN(微信)
         */
        socialBind:function (platform, success, fail) {
            mag.callbacks.bindOnSuccess = {
                type: 'json',
                success: success
            };
            mag.callbacks.bindOnFail = {
                type: 'json',
                success: fail
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.socialBind(platform);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('socialBind', platform, function (rs) {
                });
            });
        },
        /**
         * 举报
         * @param commentId 评论id
         */
        report: function(config){
            var configStr = JSON.stringify(config);
            if (window.MagAndroidClient) {
                window.MagAndroidClient.report(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('report', configStr, function (rs) {
                });
            });
        },

        /**
         * 扫描二维码
         * 回调 扫描的内容
         */
        scanQR:function (fun) {
            if (!fun)return;
            mag.callbacks.scanQR = {
                type: '',
                success: fun
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.scanQR();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('scanQR','',function (rs) {
                });
            });
        },
        /**
         * 选择框
         * 使用 itemPick([“文本1”,“文本2”,“文本3”,“文本4”],function(index){}); index 第几个
         */
        actionSheet:function (config,fun) {
            if (!fun)return;
            var configStr = JSON.stringify(config);
            mag.callbacks.actionSheet = {
                type: 'json',
                success: fun
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.actionSheet(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('actionSheet', configStr, function (rs) {
                });
            });
        },
        toast:function (text) {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.toast(text);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('toast', text, function (rs) {
                });
            });
        },
        /**
         *
         * @param config
         * {
         *   title:’标题’,
         *   content:’内容’,
         *   buttons:[“取消”,”确定”],
         *   success:function(){
         *       //确定回调
         *   },
         *   cancel:function(){
         *     //  取消回调
         *   }
         *  }
         */
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
        },
        /**
         * 显示加载框
         */
        progress:function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.progress();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('progress', '', function (rs) {
                });
            });
        },
        /**
         * 隐藏加载框
         */
        hideProgress:function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.hideProgress();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('hideProgress', '', function (rs) {
                });
            });
        },
        /**
         * 设置标题
         * @param title
         */
        setTitle:function (title) {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.setTitle(title);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('setTitle', title, function (rs) {
                });
            });
        },
        /**
         * 显示导航栏
         */
        showNavigation:function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.showNavigation();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('showNavigation', '', function (rs) {
                });
            });
        },
        /**
         * 隐藏导航栏
         */
        hideNavigation:function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.hideNavigation();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('hideNavigation', '', function (rs) {
                });
            });
        },
        /**
         * 设置导航栏颜色
         * @param color #EEEEEE
         */
        setNavigationColor:function (color) {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.setNavigationColor(color);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('setNavigationColor', color, function (rs) {
                });
            });
        },
        /**
         * 隐藏更多按钮
         */
        hideMore:function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.hideMore();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('hideMore', '', function (rs) {
                });
            });
        },
        /**
         * 显示更多按钮
         */
        showMore:function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.showMore();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('showMore', '', function (rs) {
                });
            });
        },
        tel:function (phone) {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.tel(phone);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('tel', phone, function (rs) {
                });
            });
        },
        sms:function (phone,content) {
            var configStr = JSON.stringify({phone:phone,content:content});
            if (window.MagAndroidClient) {
                window.MagAndroidClient.sms(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('sms', configStr, function (rs) {
                });
            });
        },
        toLogin:function (fun) {
            mag.callbacks.loginSuccess = {
                type: 'json',
                success: fun
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.toLogin();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('toLogin', '', function (rs) {
                });
            });
        },
        toUserHome:function (uid) {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.toUserHome(uid);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('toUserHome', uid, function (rs) {
                });
            });
        },
        addRedPacket:function(data){
            if (window.MagAndroidClient) {
                window.MagAndroidClient.addRedPacket(data);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('addRedPacket', data, function (rs) {
                });
            });
        },
        toUserHomeByName: function (username) {
            if(!username) return;
            if (window.MagAndroidClient) {
                window.MagAndroidClient.toUserHomeByName(username);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('toUserHomeByName', username, function (rs) {
                });
            });
        },
        /**
        * @param(required) config  Object
        * {
        * show_applaud:控制点赞按钮显示隐藏  (Boolean, optional)
        * show_share:控制分享按钮显示隐藏  (Boolean, optional)
        * applaud:页面内容是否点过赞  (Boolean, optional)
        * hint:无评论时的提示文字  (String, required)  -  "我来说两句…"
        * show_page:控制分页组件显示隐藏  (Boolean, optional)
        * currentPage: 分页组件中当前第几页 (Number, optional)
        * totalPage: 分页组件中总页数 (Number, optional)
        * bottomHint: 有评论时的提示文字 (String, optional)   -  "已有23条回复参与互动',
        * onComment：调用客户端评论组件成功后的回调 (Function, optional) @return Object {content: '内容', pics: []}
        * onApplaud：点击点赞按钮的回调(Function, optional)
        * onPageSelect：点击分页控件的回调(Function, optional)  @return Object {page: '2'}
        * }
        */
        commentBar:function (config) {
            var configStr = JSON.stringify(config);
            if(config.onComment){
                mag.callbacks.commentBar = {
                    type: 'json',
                    success: config.onComment
                };
            }
            if(config.onCommentShow){
                mag.callbacks.onCommentShow = {
                    type: '',
                    success: config.onCommentShow
                };
            }
            if(config.onPageSelect){
                mag.callbacks.pageSelect = {
                    type: 'json',
                    success: config.onPageSelect
                };
            }
            if(config.onApplaud){
                mag.callbacks.applaud = {
                    type: 'json',
                    success: config.onApplaud
                };
            }
            if (window.MagAndroidClient) {
                window.MagAndroidClient.commentBar(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('commentBar', configStr, function (rs) {
                });
            });
        },
        toComment:function (config) {
            var configStr = JSON.stringify(config);
            if(config.success){
                mag.callbacks.comment = {
                    type: 'json',
                    success: config.success
                };
            }
            if (window.MagAndroidClient) {
                window.MagAndroidClient.toComment(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('toComment', configStr, function (rs) {
                });
            });
        },
        newWin:function (page,params) {
            if(page.indexOf('?') < 0){
                page += '?';
            }
            for(var key in params){
                page += '&'+key+'='+params[key];
            }
            if (window.MagAndroidClient) {
                window.MagAndroidClient.newWin(page);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('newWin', page, function (rs) {
                });
            });
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
        followAuthorFromNative: function (options) {
          mag.callbacks.followAuthorFromNative = {
              type: '',
              success: options.followAuthorFromNative
          };
        },
        availableSharePlatform: function (options) {
          mag.callbacks.availableSharePlatform = {
              type: 'json',
              success: options.availableSharePlatform
          };
          if (window.MagAndroidClient) {
              window.MagAndroidClient.availableSharePlatform();
          }
          iosConnect(function (bridge) {
              bridge.callHandler('availableSharePlatform', '', function (rs) {
              });
          });
        },
        pay: function(config,success,fail){
            mag.callbacks.payOnSuccess={
                type:'',
                success:success
            };
            mag.callbacks.payOnFail={
                type:'',
                success:fail
            };
            var configstr=JSON.stringify(config);
            if(window.MagAndroidClient){
                window.MagAndroidClient.pay(configstr);
            }
            iosConnect(function(bridge){
                bridge.callHandler('pay',configstr,function(rs){});
            });
        },
        alipay: function (datastr, success, fail) {
            if(!datastr) return false;
            mag.callbacks.alipayOnSuccess={
                type:'',
                success:success
            };
            mag.callbacks.alipayOnFail={
                type:'',
                success:fail
            };
            if(window.MagAndroidClient){
                window.MagAndroidClient.alipay(datastr);
            }
            iosConnect(function(bridge){
                bridge.callHandler('alipay', datastr, function(rs){});
            });
        },
        inAppPay: function(config, success, fail){
            mag.callbacks.inAppPaySuccess={
                type:'',
                success:success
            };
            mag.callbacks.inAppPayOnFail={
                type:'',
                success:fail
            };
            var configstr = JSON.stringify(config);
            iosConnect(function(bridge){
                bridge.callHandler('inAppPay', configstr, function(rs){});
            });
        },
        deviceLogin: function(fun){
            mag.callbacks.loginSuccess = {
                type: 'json',
                success: fun
            };
            iosConnect(function(bridge){
                bridge.callHandler('deviceLogin', '', function(rs){});
            });
        },
        phoneBind: function (success) {
            mag.callbacks.phoneBindSuccess={
                type:'string',
                success: success
            };
            if(window.MagAndroidClient){
                window.MagAndroidClient.phoneBind();
            }
            iosConnect(function(bridge){
                bridge.callHandler('phoneBind', '', function(rs){});
            });
        },
        qqConnectLogin: function (token) {
            if(window.MagAndroidClient){
                window.MagAndroidClient.qqConnectLogin(token);
            }
            iosConnect(function(bridge){
                bridge.callHandler('qqConnectLogin', token, function(rs){});
            });
        },
        // enableOrNot 布尔字符串
        bounceEnable: function (enableOrNot) {
            iosConnect(function(bridge){
                bridge.callHandler('bounceEnable', enableOrNot, function(rs){});
            });
        },
        showNaviAuthor: function () {
          if(window.MagAndroidClient){
              window.MagAndroidClient.showNaviAuthor();
          }
          iosConnect(function(bridge){
              bridge.callHandler('showNaviAuthor', '', function(rs){});
          });
        },
        hideNaviAuthor: function () {
          if(window.MagAndroidClient){
              window.MagAndroidClient.hideNaviAuthor();
          }
          iosConnect(function(bridge){
              bridge.callHandler('hideNaviAuthor', '', function(rs){});
          });
        },
        /**
        * @param(required) is_fans  0|1
        */
        followAuthorFromWeb: function (is_fans) {
          if(window.MagAndroidClient){
              window.MagAndroidClient.followAuthorFromWeb(is_fans);
          }
          iosConnect(function(bridge){
              bridge.callHandler('followAuthorFromWeb', is_fans, function(rs){});
          });
        },
        /* *
         * 禁止webview滚动
         */
        setSwipeBackDisable: function(){
            if(window.MagAndroidClient){
                window.MagAndroidClient.setSwipeBackDisable();
            }
            iosConnect(function(){
                bridge.callHandler('setSwipeBackDisable', function(rs){});
            })
        },
        /* *
         * 启用webview滚动
         */
        setSwipeBackEnable: function(){
            if(window.MagAndroidClient){
                window.MagAndroidClient.setSwipeBackEnable();
            }
            iosConnect(function(){
                bridge.callHandler('setSwipeBackEnable', function(rs){});
            })
        },
        /**
         * 下拉刷新
         */
        addRefreshComponent:function () {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.addRefreshComponent();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('addRefreshComponent', '', function (rs) {
                });
            });
        },

        sappHome:function (url) {
            if (window.MagAndroidClient) {
                window.MagAndroidClient.sappHome(url);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('sappHome', url, function (rs) {
                });
            });
        },
        
        chat:function(config){
            var configStr = JSON.stringify(config);
            if (window.MagAndroidClient) {
                window.MagAndroidClient.chat(configStr);
            }
            iosConnect(function (bridge) {
                bridge.callHandler('chat', configStr, function (rs) {
                });
            });
        },
        /**
        * @param(required) config
        * config={
        *   package: String,
        *   app_scheme: String,
        *   link: String,
        * }
        */
       newExternalWin: function(config){
            var configStr = JSON.stringify(config);
            if(window.MagAndroidClient){
                window.MagAndroidClient.newExternalWin(configStr);
            }
            iosConnect(function(bridge){
                bridge.callHandler('newExternalWin', configStr, function(rs){
                })
            })
        },

        /**
         * 获取指纹信息
         * @param(required) config
         * config={
         *      auth: String,
         * }
         * @param fun
         */
        getAppAuthKey: function (fun) {
            if (!fun)return;
            mag.callbacks.getAppAuthKey = {
                type: 'json',
                success: fun
            };
            if (window.MagAndroidClient) {
                window.MagAndroidClient.getAppAuthKey();
            }
            iosConnect(function (bridge) {
                bridge.callHandler('getAppAuthKey','',function (rs) {
                });
            });
        },

        /** 
         * 发送礼物
         * @param(required) config
         * config={
         *      userid: String, //楼主userid
         *      source: 4,
         *      sourceId: String //帖子id
         * }
         * 成功回掉callback giftSendSuccess
         */
        sendGift: function(config, success){
            var configstr = JSON.stringify(config);
            mag.callbacks.giftSendSuccess = {
                type: 'json',
                success: success
            };
            if(window.MagAndroidClient){
                window.MagAndroidClient.sendGift(configstr);
            }
            iosConnect(function(bridge){
                bridge.callHandler('sendGift', configstr, function(rs){});
            });
        },

        /** 
         * iOS中打开设置页面，不支持android
         */
        showPhoneSettings: function (){
            iosConnect(function (bridge) {
                bridge.callHandler('showPhoneSettings', '', function (rs) {
                });
            });
        },

        /** 
         * iOS中获取用户开启通知的状态，返回1的时候就需要开启，不支持android
         */
        getNotificationStatus: function (success){
            mag.callbacks.getNotificationStatus={
                type: 'string',
                success: success
            };
            iosConnect(function(bridge){
                bridge.callHandler('getNotificationStatus', '', function(rs){});
            });
        },
        /**
         * 唤起客户端下载附件的方法
         */
        downloadAttachment: function(config){
            var configstr = JSON.stringify(config);
            if(window.MagAndroidClient){
                window.MagAndroidClient.downloadAttachment(configstr);
            }
            iosConnect(function(bridge){
                bridge.callHandler('downloadAttachment', configstr, function(rs){});
            });
        },
        /**
         * 获取设备的网络状态
         * res: 0-没网，1-WIFI，2-WWAN(蜂窝网络)
         */
        getNetworkState: function(success) {
            mag.callbacks.getNetworkState = {
                type: "string",
                success: success
            },
            window.MagAndroidClient && window.MagAndroidClient.getNetworkState(),
            iosConnect(function(bridge) {
                bridge.callHandler("getNetworkState", "", function(n) {})
            })
        },
        /**
         * 获取设备号
         */
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
        }
    };
    window.mag = mag;
    mag.VERSION = '1.3.2';

})();
