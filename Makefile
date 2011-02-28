TARGET=$(notdir $(basename $(CURDIR)))
all:
	DreamMaker $(TARGET).dme

depend:
	DreamDownload byond://Alathon.services
	DreamDownload byond://Alathon.telnet_input
	DreamDownload byond://Alathon.callwrapper
	DreamDownload byond://AbyssDragon.Parser
	cp parser.patch ~/.byond/lib/abyssdragon/parser
	cd ~/.byond/lib/abyssdragon/parser && patch -p1 -i parser.patch Parser.dm

clean:
	rm -rf $(TARGET).zip
	rm -rf $(TARGET).dmb
	rm -rf $(TARGET).rsc

zip:
	rm -rf $(TARGET).zip
	zip $(TARGET).zip *.dm *.dme
