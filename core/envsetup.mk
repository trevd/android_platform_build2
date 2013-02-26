# Under Linux, if USE_MINGW is set, google change HOST_OS to Windows to build the
# Windows SDK. Only a subset of tools and SDK will manage to build properly.

# And we'll do exactly the same trick for darwin!!!
# Thanks very much
ifeq ($(HOST_OS),linux)
ifneq ($(USE_DARWIN),)
	HOST_OS := darwin
endif
### pi os probably should be raspbian
ifneq ($(USE_PI),)
	HOST_OS := pi
endif
endif
