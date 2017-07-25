CC        = gcc
CFLAGS    = -Wall -pedantic -g3 -std=c99
CRELFLAGS = -Wall -pedantic -std=c99 -Os -s -DNDEBUG
SRCDIR    = src
OBJDIR    = obj

PROG      = calc
TARGET	  = $(PROG).exe
GENPREFIX = gen.
LEXGENC   = $(GENPREFIX)$(PROG).flex.c
PARSEGENC = $(GENPREFIX)$(PROG).bison.c
TOKENGENH = $(GENPREFIX)$(PROG).tokens.h
OBJS      = $(OBJDIR)/main.o $(OBJDIR)/$(LEXGENC:.c=.o) $(OBJDIR)/$(PARSEGENC:.c=.o)

all: $(TARGET)

gen: bison flex

bison: $(SRCDIR)/$(TOKENGENH) $(SRCDIR)/$(PARSEGENC)

flex: $(SRCDIR)/$(LEXGENC)

$(SRCDIR)/$(LEXGENC): $(SRCDIR)/$(PROG).l $(SRCDIR)/$(TOKENGENH) $(SRCDIR)/$(PROG).h
	cd $(SRCDIR); flex -CF -o $(LEXGENC) $(PROG).l

$(SRCDIR)/$(TOKENGENH) $(SRCDIR)/$(PARSEGENC): $(SRCDIR)/$(PROG).y $(SRCDIR)/$(PROG).h
	cd $(SRCDIR); bison -d --verbose -o $(PARSEGENC) $(PROG).y
	@cd $(SRCDIR); mv $(PARSEGENC:.c=.h) $(TOKENGENH)

compile: $(OBJS)

$(OBJDIR)/$(LEXGENC:.c=.o): $(SRCDIR)/$(LEXGENC)
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c $<

$(OBJDIR)/$(PARSEGENC:.c=.o): $(SRCDIR)/$(PARSEGENC)
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c $<

$(OBJDIR)/main.o: $(SRCDIR)/main.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c $<

exe: $(TARGET)

$(TARGET): $(OBJS)
	@echo 'Building target: $@'
	$(CC) $(CFLAGS) -I$(SRCDIR) -o $(TARGET) $(OBJS)
	@echo 'Finished building target: $@'

rel:
	$(CC) $(CRELFLAGS) -I$(SRCDIR) -o $(TARGET) $(OBJS)

test: $(TARGET)
	./$(TARGET) test/test.txt

clean:
	@echo Clean files
	@rm -rf $(TARGET) $(OBJDIR)
	@cd $(SRCDIR); rm -rf $(PROG).tab.h $(PROG).yy.c $(PROG).tab.c $(PARSEGENC:.c=.h)
	@cd $(SRCDIR); rm -rf $(PARSEGENC:.c=.output)
