##################################################
# This example Android.mk shows how to include   #
# your prebuild apk by project or resolution     #
# (dpi).                                         #
##################################################

LOCAL_PATH := $(call my-dir)

# include Sample apk, by project
##################################################
include $(CLEAR_VARS)

ifndef MODULE.TARGET.APPS.SoundRecorder
    
    LOCAL_MODULE := SoundRecorder
    ifeq (ATT,$(filter ATT, $(TARGET_SKU)))
       LOCAL_SRC_FILES := out/ATT/$(LOCAL_MODULE).apk
    else
       LOCAL_SRC_FILES := out/AMAX/$(LOCAL_MODULE).apk
    endif
    LOCAL_PRIVILEGED_MODULE := true
    LOCAL_MODULE_CLASS := APPS
    LOCAL_MODULE_TAGS := optional
    LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
    LOCAL_CERTIFICATE := PRESIGNED

    include $(BUILD_PREBUILT)

endif
# include Sample apk, by dpi
##################################################
#include $(CLEAR_VARS)
#
#LOCAL_MODULE := Sample
#LOCAL_MODULE_TAGS := optional
#LOCAL_MODULE_CLASS := APPS
#LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
#LOCAL_CERTIFICATE := AMAX
#
#prebuilt_sample_PRODUCT_AAPT_CONFIG := $(subst $(comma), ,$(PRODUCT_AAPT_CONFIG))
#ifneq (,$(filter xhdpi,$(prebuilt_sample_PRODUCT_AAPT_CONFIG)))
#    LOCAL_SRC_FILES := Sample_xhdpi.apk
#else ifneq (,$(filter xxhdpi,$(prebuilt_sample_PRODUCT_AAPT_CONFIG)))
#    LOCAL_SRC_FILES := Sample_xxhdpi.apk
#else ifneq (,$(filter hdpi,$(prebuilt_sample_PRODUCT_AAPT_CONFIG)))
#    LOCAL_SRC_FILES := Sample_hdpi.apk
#else ifneq (,$(filter mdpi,$(prebuilt_sample_PRODUCT_AAPT_CONFIG)))
#    LOCAL_SRC_FILES := Sample_mdpi.apk
#else
#    LOCAL_SRC_FILES := Sample_alldpi.apk
#endif
#
#prebuilt_sample_PRODUCT_AAPT_CONFIG :=
#
#include $(BUILD_PREBUILT)
