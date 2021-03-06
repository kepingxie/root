# Module.mk for histpainter module
# Copyright (c) 2000 Rene Brun and Fons Rademakers
#
# Author: Fons Rademakers, 29/2/2000

MODNAME      := histpainter
MODDIR       := $(ROOT_SRCDIR)/hist/$(MODNAME)
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

HISTPAINTERDIR  := $(MODDIR)
HISTPAINTERDIRS := $(HISTPAINTERDIR)/src
HISTPAINTERDIRI := $(HISTPAINTERDIR)/inc

##### libHistPainter #####
HISTPAINTERL  := $(MODDIRI)/LinkDef.h
HISTPAINTERDS := $(call stripsrc,$(MODDIRS)/G__HistPainter.cxx)
HISTPAINTERDO := $(HISTPAINTERDS:.cxx=.o)
HISTPAINTERDH := $(HISTPAINTERDS:.cxx=.h)

HISTPAINTERH1 := $(wildcard $(MODDIRI)/T*.h)
HISTPAINTERH  := $(filter-out $(MODDIRI)/LinkDef%,$(wildcard $(MODDIRI)/*.h))
HISTPAINTERS  := $(filter-out $(MODDIRS)/G__%,$(wildcard $(MODDIRS)/*.cxx))
HISTPAINTERO  := $(call stripsrc,$(HISTPAINTERS:.cxx=.o))

HISTPAINTERDEP := $(HISTPAINTERO:.o=.d) $(HISTPAINTERDO:.o=.d)

HISTPAINTERLIB := $(LPATH)/libHistPainter.$(SOEXT)
HISTPAINTERMAP := $(HISTPAINTERLIB:.$(SOEXT)=.rootmap)

# used in the main Makefile
ALLHDRS       += $(patsubst $(MODDIRI)/%.h,include/%.h,$(HISTPAINTERH))
ALLLIBS       += $(HISTPAINTERLIB)
ALLMAPS       += $(HISTPAINTERMAP)

# include all dependency files
INCLUDEFILES += $(HISTPAINTERDEP)

##### local rules #####
.PHONY:         all-$(MODNAME) clean-$(MODNAME) distclean-$(MODNAME)

include/%.h:    $(HISTPAINTERDIRI)/%.h
		cp $< $@

$(HISTPAINTERLIB): $(HISTPAINTERO) $(HISTPAINTERDO) $(ORDER_) $(MAINLIBS) \
                   $(HISTPAINTERLIBDEP)
		@$(MAKELIB) $(PLATFORM) $(LD) "$(LDFLAGS)" \
		   "$(SOFLAGS)" libHistPainter.$(SOEXT) $@ \
		   "$(HISTPAINTERO) $(HISTPAINTERDO)" \
		   "$(HISTPAINTERLIBEXTRA)"

$(call pcmrule,HISTPAINTER)
	$(noop)

$(HISTPAINTERDS): $(HISTPAINTERH1) $(HISTPAINTERL) $(ROOTCLINGEXE) $(call pcmdep,HISTPAINTER)
		$(MAKEDIR)
		@echo "Generating dictionary $@..."
		$(ROOTCLINGSTAGE2) -f $@ $(call dictModule,HISTPAINTER) -c -writeEmptyRootPCM $(HISTPAINTERH1) $(HISTPAINTERL)

$(HISTPAINTERMAP): $(HISTPAINTERH1) $(HISTPAINTERL) $(ROOTCLINGEXE) $(call pcmdep,HISTPAINTER)
		$(MAKEDIR)
		@echo "Generating rootmap $@..."
		$(ROOTCLINGSTAGE2) -r $(HISTPAINTERDS) $(call dictModule,HISTPAINTER) -c $(HISTPAINTERH1) $(HISTPAINTERL)

all-$(MODNAME): $(HISTPAINTERLIB)

clean-$(MODNAME):
		@rm -f $(HISTPAINTERO) $(HISTPAINTERDO)

clean::         clean-$(MODNAME)

distclean-$(MODNAME): clean-$(MODNAME)
		@rm -f $(HISTPAINTERDEP) $(HISTPAINTERDS) $(HISTPAINTERDH) \
		   $(HISTPAINTERLIB) $(HISTPAINTERMAP)

distclean::     distclean-$(MODNAME)
