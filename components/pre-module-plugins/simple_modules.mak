define declare_simple_cpp_library_macro
TARGET := $1
TARGETTYPE := library
CPPSOURCES := $$(call all-cpp-files)
endef

declare_simple_cpp_library = $(eval $(call declare_simple_cpp_library_macro,$1))

define declare_simple_c_library_macro
TARGET := $1
TARGETTYPE := library
CPPSOURCES := $$(call all-c-files)
endef

declare_simple_c_library = $(eval $(call declare_simple_c_library_macro,$1))

define declare_simple_cpp_testcase_macro
TARGET := $1
TARGETTYPE := exe
CPPSOURCES := $$(call all-cpp-files)
TESTPRGM := $1
endef

declare_simple_cpp_testcase = $(eval $(call declare_simple_cpp_testcase_macro,$1))
