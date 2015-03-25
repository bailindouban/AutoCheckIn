LOCAL_PATH := $(call my-dir)


##################################################
include $(CLEAR_VARS)

LOCAL_MODULE := ASUSAccount
LOCAL_SRC_FILES := out/$(LOCAL_MODULE).apk
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_CERTIFICATE := AMAX


include $(BUILD_PREBUILT)


