THEOS_DEVICE_IP = 10.0.45.5


include $(THEOS)/makefiles/common.mk



TWEAK_NAME = wechatRedEnvelop
wechatRedEnvelop_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
