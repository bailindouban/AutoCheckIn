#ifneq (,$(filter $(TARGET_PROJECT), AMAX_NEXUS7))

ifndef MODULE.TARGET.APPS.DeskClock

   LOCAL_PATH := $(call my-dir)
   ##############################################build DeskClock apk
   include $(CLEAR_VARS)
   LOCAL_MODULE := DeskClock
   LOCAL_MODULE_CLASS := APPS
   LOCAL_MODULE_TAGS := optional
   LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
   LOCAL_CERTIFICATE := AMAX

   # A500CG A600CG A500KL
   ifneq ($(filter $(TARGET_PROJECT), A500CG A600CG A500KL),)
       LOCAL_SRC_FILES := out/sw360dp-xhdpi/$(LOCAL_MODULE).apk
   endif
   ifeq ($(LOCAL_SRC_FILES),)
       LOCAL_SRC_FILES := out/$(LOCAL_MODULE).apk
   endif

   include $(BUILD_PREBUILT)

endif

