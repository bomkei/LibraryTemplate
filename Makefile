TARGET	= template

LIB			:= lib
BUILD		:= build
INCLUDE	:= include
SOURCE	:= src

COMMON	:= -O2
CFLAGS	:= $(COMMON) $(INCLUDES) -std=c17
LDFLAGS	:= -Wl,--gc-sections

%.o: %.c
	@echo $(notdir $<)
	@clang -MP -MMD -MF $*.d $(CFLAGS) -c -o $@ $<

ifneq ($(BUILD), $(notdir $(CURDIR)))

CFILES	= $(notdir $(foreach dir,$(SOURCE),$(wildcard $(dir)/*.c)))

export TOPDIR		= $(CURDIR)
export INCLUDES	= $(foreach dir,$(INCLUDE),-I$(CURDIR)/$(dir))
export VPATH		= $(foreach dir,$(SOURCE),$(TOPDIR)/$(dir))

export OUTPUT		= $(TOPDIR)/$(LIB)/lib$(TARGET).a
export OFILES		= $(CFILES:.c=.o)

.PHONY: all debug clean re $(LIB) $(BUILD)

all: $(LIB) $(BUILD)

$(LIB):
	@[ -d $@ ] || mkdir -p $@

$(BUILD):
	@[ -d $(BUILD) ] || mkdir -p $(BUILD)
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(TOPDIR)/Makefile

debug:
	@[ -d $(BUILD) ] || mkdir -p $(BUILD)
	@$(MAKE) --no-print-directory COMMON="-g -O0 -Wextra" -C $(BUILD) -f $(TOPDIR)/Makefile

clean:
	@rm -rf $(BUILD) $(TARGET)

re: clean all

else

DEPENDS	= $(OFILES:.o=.d)

$(OUTPUT): $(OFILES)
	@echo linking...
	@ar rcs $@ $^

-include $(DEPENDS)

endif