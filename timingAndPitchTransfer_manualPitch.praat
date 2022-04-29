# Transferring timing & pitch of Source voice to Target voice
# (manual pitch - a correct pitch is important for quality,
# create pitch objects manually and correct errors)
# ---------------------------------------------------------------------------
# Create files with these names (6 files):
# "Sound target" - open wav file - the voice to be spoken, timing & pitch will be changed
# "TextGrid target" - markers for phonemes
# (how to create: Click Sound target, Annotate, To TextGrid,
#   first line whatever (phonemes), second line empty,
#   select Sound target + TextGrid target, View & Edit and mark the phonemes)
# "Pitch target" - how to create: Click Sound target, Analyse periodicity,
#   To Pitch, set Pitch floor and ceiling accordingly, View & Edit, correct it)
# "Sound source" - open wav file - source of timing and pitch
# "TextGrid source" - markers for phonemes (as above), the same number of markers!!!
# "Pitch source" - see above
# run this script - result is "Sound synth"
# You can view it with "TextGrid source" to see also phoneme markers

selectObject: "TextGrid source"
gs = selected: "TextGrid", 1

selectObject: "Pitch source"
pitchs = selected("Pitch", 1)

selectObject: "TextGrid target"
gt = selected: "TextGrid", 1

selectObject: "Pitch target"
pitcht = selected("Pitch", 1)

selectObject: "Sound target"
sndt = selected("Sound", 1)

selectObject: gs

gsNumTiers = Get number of tiers
if gsNumTiers <> 1
  exitScript: "Source TextGrid doesn't have only 1 tier"
endif

gsIsInterval = Is interval tier: 1
if not gsIsInterval
  exitScript: "Source TextGrid's tier is not Interval Tier"
endif

gsNumInts = Get number of intervals: 1

for intNum from 1 to gsNumInts
  ts = Get start time of interval: 1, intNum
  te = Get end time of interval: 1, intNum

  iLen = te - ts
  gsLens[intNum] = iLen
endfor

selectObject: gt

gtNumTiers = Get number of tiers
if gtNumTiers <> 1
  exitScript: "Target TextGrid doesn't have only 1 tier"
endif

gtIsInterval = Is interval tier: 1
if not gtIsInterval
  exitScript: "Target TextGrid's tier is not Interval Tier"
endif

gtStart = Get start time
gtEnd = Get end time
gtNumInts = Get number of intervals: 1

if gsNumInts <> gtNumInts
  exitScript: "TextGrids don't have the same number of intervals"
endif

dur = Create DurationTier: "durTransform", gtStart, gtEnd

prev = 1.0
for intNum from 1 to gtNumInts
  selectObject: gt

  ts = Get start time of interval: 1, intNum
  te = Get end time of interval: 1, intNum

  iLen = te - ts

  selectObject: dur
  if intNum > 1
    Add point: ts - 0.00001, prev
  endif

  val = gsLens[intNum] / iLen
  Add point: ts, val

  prev = val
endfor

Add point: gtEnd - gtStart, prev

selectObject: pitchs
pts = Down to PitchTier

ptt = Create PitchTier: "target", gtStart, gtEnd
t = gtStart
while t <= gtEnd
  selectObject: dur
  t2 = Get target duration: 0, t

  selectObject: pts
  f = Get value at time: t2

  selectObject: ptt
  Add point: t, f

  t = t + 0.001
endwhile

removeObject: pts

selectObject: sndt
plusObject: pitcht
man = To Manipulation

selectObject: dur
plusObject: man
Replace duration tier

selectObject: ptt
plusObject: man
Replace pitch tier

removeObject: dur, ptt

selectObject: man
Get resynthesis (overlap-add)
Rename: "synth"

# comment out this line if you want Manipulation object
# for pitch editing, then use Get resynthesis (overlap-add)
#removeObject: man
