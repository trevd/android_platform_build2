#
# Copyright (C) 2006 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Configuration for Darwin (Mac OS X) on x86.
# Included by combo/select.mk


# By default we build everything in 32-bit, because it gives us
# more consistency between the host tools and the target.
# BUILD_HOST_64bit=1 overrides it for tool like emulator
HOST_GLOBAL_CFLAGS += -m32 
HOST_GLOBAL_LDFLAGS += -m32 -arch i386 


ifneq ($(strip $(BUILD_HOST_static)),)
# Statically-linked binaries are desirable for sandboxed environment
HOST_GLOBAL_LDFLAGS += -static
endif # BUILD_HOST_static




################## Symbolically link the /usr/lib/apple directory to /Developers
################## as that contains you sdk which is installed with the tool chain ./usr/lib/apple/SDKs/MacOSX10.6.sdk

################## TOOLCHAIN APT REPOS
################## deb http://ppa.launchpad.net/flosoft/cross-apple/ubuntu maverick main 
################## deb-src http://ppa.launchpad.net/flosoft/cross-apple/ubuntu maverick main
mac_sdk_version :=10.6
mac_sdk_path := /usr/lib/apple/SDKs/MacOSX$(mac_sdk_version).sdk
mac_sdk_root := mac_sdk_path
ifeq ($(mac_sdk_version),10.6)
  gcc_darwin_version := 10
else
  gcc_darwin_version := 11
endif

HOST_TOOLCHAIN_PREFIX := /usr/bin/i686-apple-darwin$(gcc_darwin_version)
# Don't do anything if the toolchain is not there
ifneq (,$(strip $(wildcard $(HOST_TOOLCHAIN_PREFIX)-gcc)))
HOST_CC  := $(HOST_TOOLCHAIN_PREFIX)-gcc
HOST_CXX := $(HOST_TOOLCHAIN_PREFIX)-g++
ifeq ($(mac_sdk_version),10.8)
# Mac SDK 10.8 no longer has stdarg.h, etc
host_toolchain_header := /usr/lib/gcc/i686-apple-darwin$(gcc_darwin_version)/4.2.1/include
HOST_GLOBAL_CFLAGS += -isystem $(host_toolchain_header)
endif
else
HOST_CC := gcc
HOST_CXX := g++
endif # $(HOST_TOOLCHAIN_PREFIX)-gcc exists
HOST_STRIP := $(STRIP)
HOST_STRIP_COMMAND = $(HOST_STRIP) --strip-debug $< -o $@

#HOST_GLOBAL_CFLAGS += -isysroot $(mac_sdk_root) -mmacosx-version-min=$(mac_sdk_version) -DMACOSX_DEPLOYMENT_TARGET=$(mac_sdk_version)

HOST_GLOBAL_LDFLAGS += -isysroot $(mac_sdk_root) -Wl,-syslibroot,$(mac_sdk_root) -mmacosx-version-min=$(mac_sdk_version)

HOST_GLOBAL_CFLAGS += -isysroot $(mac_sdk_root) -mmacosx-version-min=$(mac_sdk_version) -DMACOSX_DEPLOYMENT_TARGET=$(mac_sdk_version)
HOST_GLOBAL_CFLAGS += -fPIC -funwind-tables
HOST_GLOBAL_CFLAGS += -include $(call select-android-config-h,darwin-x86)
HOST_NO_UNDEFINED_LDFLAGS := -Wl,-undefined,error

HOST_SHLIB_SUFFIX := .dylib
HOST_JNILIB_SUFFIX := .jnilib



       HOST_RUN_RANLIB_AFTER_COPYING := false
       PRE_LION_DYNAMIC_LINKER_OPTIONS := -Wl,-dynamic

HOST_AR :=$(HOST_TOOLCHAIN_PREFIX)-libtool
HOST_GLOBAL_ARFLAGS := -static -arch_only i386 -o
HOST_GLOBAL_LD_DIRS += -L/usr/lib/apple/SDKs/MacOSX10.6.sdk/usr/lib
HOST_CUSTOM_LD_COMMAND := true


## Add the -L/Developer/SDKs/MacOSX10.6.sdk/usr/lib as a lib path so we can resolve
## our references
define transform-host-o-to-shared-lib-inner
 $(PRIVATE_CXX) \
        -dynamiclib -single_module -read_only_relocs suppress \
        $(HOST_GLOBAL_LD_DIRS) \
        $(HOST_GLOBAL_LDFLAGS) \
        $(PRIVATE_ALL_OBJECTS) \
        $(addprefix -force_load , $(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
        $(PRIVATE_LDLIBS) \
        -o $@
        -install_name @rpath/$(notdir $@) \
        -Wl,-rpath,@loader_path/../lib \
        $(PRIVATE_LDFLAGS) \
        $(HOST_LIBGCC)
endef



define transform-host-o-to-executable-inner
$(hide) $(PRIVATE_CXX) \
        -Wl,-rpath,@loader_path/../lib \
        -o $@ \
        $(PRE_LION_DYNAMIC_LINKER_OPTIONS) -headerpad_max_install_names \
        $(HOST_GLOBAL_LD_DIRS) \
        $(HOST_GLOBAL_LDFLAGS) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
        $(PRIVATE_ALL_OBJECTS) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
        $(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
        $(PRIVATE_LDFLAGS) \
        $(PRIVATE_LDLIBS) \
        $(HOST_LIBGCC)
endef

# $(1): The file to check
define get-file-size
stat -f "%z" $(1)
endef


# /usr/i686-apple-darwin10/bin/libtool -static -o libunz.a -arch_only i386 src/*.o
