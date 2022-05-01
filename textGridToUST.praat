# select TextGrid with one interval tier, marked starts of vowels and pause, labeled as in Utau
# and corresponding Pitch object, preferably smoothed
# run this script
# a file "praat.ust" will be created where this script is

grid = selected: "TextGrid", 1
pitch = selected: "Pitch", 1

selectObject: grid

gNumTiers = Get number of tiers
if gNumTiers <> 1
  exitScript: "TextGrid doesn't have only 1 tier"
endif

gIsInterval = Is interval tier: 1
if not gIsInterval
  exitScript: "TextGrid's tier is not Interval Tier"
endif

gNumInts = Get number of intervals: 1

deleteFile: "praat.ust"
appendFileLine: "praat.ust", "[#VERSION]"
appendFileLine: "praat.ust", "UST Version1.2"
appendFileLine: "praat.ust", "[#SETTING]"
appendFileLine: "praat.ust", "Tempo=120.00"
appendFileLine: "praat.ust", "Tracks=1"
appendFileLine: "praat.ust", "ProjectName=Praat"
appendFileLine: "praat.ust", "VoiceDir="
appendFileLine: "praat.ust", "OutFile="
appendFileLine: "praat.ust", "CacheDir=empty.cache"
appendFileLine: "praat.ust", "Tool1=wavtool.exe"
appendFileLine: "praat.ust", "Tool2=fresamp14.exe"
appendFileLine: "praat.ust", "Mode2=True"

for .i to gNumInts
  selectObject: grid
  ts = Get start time of interval: 1, .i
  te = Get end time of interval: 1, .i
  lbl$ = Get label of interval: 1, .i
  if lbl$ = ""
    lbl$ = "R"
  endif

  len = te - ts
  qlen = round(len * 960)

  if lbl$ <> "R"
    selectObject: pitch
    semi = Get quantile: ts, te, 0.5, "semitones re 440 Hz"
    semi = round(semi) + 69
  else
    semi = 0
  endif

  appendFileLine: "praat.ust", "[#", .i, "]"
  appendFileLine: "praat.ust", "Length=", qlen
  appendFileLine: "praat.ust", "Lyric=", lbl$
  if semi > 0
    appendFileLine: "praat.ust", "NoteNum=", semi
  else
    appendFileLine: "praat.ust", "NoteNum="
  endif
  appendFileLine: "praat.ust", "PreUtterance="
  appendFileLine: "praat.ust", "Intensity=100"
  appendFileLine: "praat.ust", "Modulation=0"	

endfor

appendFileLine: "praat.ust", "[#TRACKEND]"

plusObject: pitch

writeInfoLine: "File Praat.ust created"
