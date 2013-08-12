REBOL [
	Title: "simpleTTS Extension Test"
	author: "Jocko"
	date: 30-Oct-2009
	comment: {a first attempt to make a windows extension to Rebol3.
	It uses the SAPI 5 voices, with a com access.
	Tested under WinXP and Rebol3-94 ?
	The TTS-XML commands are powerful and simple}
]

secure [extension allow]

;t:import %simpleTTS.dll
import %simpleTTS.dll

print " "
print "TTS extension usage"
print " "
help TTS

print " "

TTS "hello"

TTS to-string rejoin ["it is " now/time]

{for TTS-XML, see :    http://msdn.microsoft.com/en-us/library/ms717077%28VS.85%29.aspx	}
print "use of TTS-XML commands"
print "female voice"
TTS {<voice required="Gender=Female;Age!=Child"> Hello everybody}
print "male voice"
TTS {<voice required="Gender=Male;Age!=Child"> Hello everybody}

print "US- English language"
a-text: {<lang langid="409">
   A U.S. English voice should speak this.
</lang>}
probe TTS a-text

print "French language"
a-text: {<lang langid="40c">
   Et maintenant, quelques mots en francais.
</lang>}
probe TTS a-text

print "emphasis"
TTS {<emph>"Reb-ol" extensions</emph> are fantastic !}
print "pitch modification"
probe TTS "that's <pitch middle = '-30'/> all folks"

ask "done"