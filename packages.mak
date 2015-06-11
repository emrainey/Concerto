
ifeq ($(TARGET_OS),LINUX)
# Packages will be routed to pkg-config (checked only once)
PKG_PATH ?= $(strip $(shell which pkg-config))
#$(info PKG_PATH=$(PKG_PATH))
ifneq ($(strip $(PKGS)),)
    $(if $(PKG_PATH),,$(error pkg-config is missing!))
    EXISTS := $(foreach pkg,$(PKGS),$(if $(shell pkg-config --exists $(pkg) && echo true),,$(error $(pkg) is not installed)))
    IDIRS += $(foreach pkg,$(PKGS),$(subst -I,$(EMPTY),$(shell pkg-config --cflags-only-I $(pkg))))
    DEFS += $(foreach pkg,$(PKGS),$(subst -D,$(EMPTY),$(shell pkg-config --cflags-only-other $(pkg))))
    LDIRS += $(foreach pkg,$(PKGS),$(subst -L,$(EMPTY),$(shell pkg-config --libs-only-L $(pkg))))
    SYS_SHARED_LIBS += $(foreach pkg,$(PKGS),$(subst -l,$(EMPTY),$(shell pkg-config --libs-only-l $(pkg))))
endif
endif

