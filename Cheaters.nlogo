;;;;;;;;; CURRENT ISSUES ;;;;;;;;;;;;;
;; * Strong cheaters never seem to persist

;; Create the three species (define plural and singular terms)
breed [mutualists mutualist]
breed [weaks weak]
breed [strongs strong]

;; 'Turtles' is what NetLogo calls individuals
turtles-own [microbe-health]

;; Host health
;; 'diapause' is related to the host breeding rate. See the 'set-host-health' function near the end.
patches-own [host-health diapause]


to setup
  clear-all
  
  ;; Every patch gets a mutualist, and starts with 20 health
  ask patches [
    sprout-mutualists 1 [
      set color sky
      set shape "face happy"
    ]
    set host-health 100 
    set diapause host-breed-delay    ; Important later, if hosts are killed. See 'set-host-health' function near the bottom.
  ]
  
  ;; Cheaters distributed randomly
  create-weaks 20 [
    setxy random-xcor random-ycor
    set color yellow
    set shape "x"
  ]
  
  create-strongs 20 [
    setxy random-xcor random-ycor
    set color red
    set shape "x"
  ]
  
  ;; Every microbe starts with 20 health units
  ask turtles [
    set size 0.5
    set microbe-health 20
  ]
  
  reset-ticks
  
end

to go
  movement
  set-microbe-health
  set-host-health
  reproduce
  tick
  if count turtles = 0 [ stop ]
  if (count weaks = 0) and (count strongs = 0) [stop]
end

to movement
  ask turtles [
    set heading random 360
    forward random move-dist   ; move-dist is a slider, a random number is picked with that as the max
  ]
end

to set-microbe-health
  ;; Individual microbes' health depends on what other species are present there.
  ;; The health costs are all sliders, found on the interface
  ask mutualists [
    if any? weaks-here [ set microbe-health (microbe-health - weak-hurt-mutualists) ]
    if any? strongs-here [ set microbe-health (microbe-health - strong-hurt-mutualists) ]
  ]
  ask weaks [
    ; if any? mutualists-here [ set microbe-health (microbe-health - 0) ]
    if any? strongs-here [ set microbe-health (microbe-health - strong-hurt-weak) ]
    set microbe-health (microbe-health + weak-steal)
  ]
  ask strongs [
    ; if any? mutualists-here [ set microbe-health (microbe-health - 0) ]
    if any? weaks-here [ set microbe-health (microbe-health - weak-hurt-strong) ]
    set microbe-health (microbe-health + strong-steal)
  ]
  ;; General aging for microbes
  ask turtles [ set microbe-health (microbe-health - 1) ]
  ;; Microbe death
  ask turtles [ if microbe-health <= 0 [ die ] ]
  
  ;; Carrying capacities
   ask patches [
    if (count mutualists-here > carrying-cap) [
      let overcap ((count mutualists-here) - carrying-cap)
      ask n-of overcap mutualists-here [ die ]
    ]
    if (count weaks-here > carrying-cap) [
      let overcap ((count weaks-here) - carrying-cap)
      ask n-of overcap weaks-here [ die ]
    ]
    if (count strongs-here > carrying-cap) [
      let overcap ((count strongs-here) - carrying-cap)
      ask n-of overcap strongs-here [ die ]
    ]
  ]
  if (host-flush? = TRUE) [ host-flush ]
end

to host-flush
  ask patches [
    if count mutualists-here = 0 [
      ask turtles-here [die]]    ; All of these dead turtles are cheaters
  ]
end

to set-host-health
  ask patches [
    ;; Hosts' health gets drained by cheaters
    if any? weaks-here [
      set host-health (host-health - weak-steal)
    ]
    if any? strongs-here [
      set host-health (host-health - strong-steal)
    ]
    ;; Assume that mutualists do not hurt the host overall (any hurt is perfectly offset by a benefit)

    ;; If the host loses all health, the microbes all die, and a new host is born after a delay
    ;; This delay can be adjusted by the 'host-breed-delay' slider, and the results are very sensitive to this
    if host-health <= 0 [
      ask turtles-here [die]
      set diapause diapause - 1
      if diapause <= 0 [ set host-health 20 ]
    ]
    ; set pcolor scale-color red host-health 0 20    ;; For visualizing host health, kind of distracting
  ]
end


to reproduce
  ;; 'mod' is a weird NetLogo command for getting the remainder after division
  ;; Basically, if the number of time ticks is perfectly divisible by t, then all microbes reproduce
  if ticks mod 5 = 0 [
    ask turtles [ hatch 1 [ set microbe-health 20 ]]]
end
@#$#@#$#@
GRAPHICS-WINDOW
238
10
578
371
-1
-1
30.0
1
10
1
1
1
0
1
1
1
0
10
0
10
0
0
1
ticks
30.0

BUTTON
23
22
89
55
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
108
23
171
56
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
73
105
106
move-dist
move-dist
1
10
3
1
1
NIL
HORIZONTAL

SLIDER
113
73
221
106
carrying-cap
carrying-cap
0
20
10
5
1
NIL
HORIZONTAL

PLOT
595
11
905
161
goodpatches
time
% patches
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (((count patches with [count mutualists-here > 0]) / 121) * 100)"

SWITCH
18
450
170
483
host-flush?
host-flush?
1
1
-1000

PLOT
596
180
905
371
pops
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mutualists" 1.0 0 -13791810 true "" "plot count mutualists"
"weaks" 1.0 0 -1184463 true "" "plot count weaks"
"strongs" 1.0 0 -2674135 true "" "plot count strongs"

SLIDER
20
411
192
444
host-breed-delay
host-breed-delay
0
20
5
1
1
NIL
HORIZONTAL

SLIDER
13
133
185
166
weak-steal
weak-steal
0
30
5
1
1
NIL
HORIZONTAL

SLIDER
13
171
185
204
strong-steal
strong-steal
0
30
10
1
1
NIL
HORIZONTAL

TEXTBOX
14
116
187
144
How cheaters hurt their host:
11
0.0
1

TEXTBOX
16
214
166
232
Competition coefficients:
11
0.0
1

SLIDER
14
231
186
264
weak-hurt-mutualists
weak-hurt-mutualists
0
10
1
1
1
NIL
HORIZONTAL

SLIDER
14
267
186
300
weak-hurt-strong
weak-hurt-strong
0
10
1
1
1
NIL
HORIZONTAL

SLIDER
14
304
187
337
strong-hurt-mutualists
strong-hurt-mutualists
0
10
5
1
1
NIL
HORIZONTAL

SLIDER
14
341
186
374
strong-hurt-weak
strong-hurt-weak
0
10
2
1
1
NIL
HORIZONTAL

@#$#@#$#@
## What is it?

Illustrating the dynamics between a host, and its mutualist microbes, but with weak and strong cheaters mixed in as well. What allows the mutualist (and its host) to stop the spread of cheaters, and survive? How do the weak and strong cheaters interact?

## How it works

Three microbe species exist on a host: a mutualist, a weak cheater, and a strong cheater.

The mutualist supports the host's health, while the cheaters both steal from the host.

Some rules govern the local coexistence of these species.  When only the mutualist and the strong cheater are present on a patch, the strong cheater eliminates the mutualist. And when all three species are present, the strong cheater is eliminated.

So how does the mutualist (and its host) persist? Here, we explore whether host feedback mechanisms can help, by flushing itself, or just dying.

Things to vary include the reproductive rates of each species, and others(?).

In the end, we are interested in how many patches contain the mutualist microbe, and the population sizes of each species.


## How to use it

Click 'setup', and then 'go'! Click 'go' again the stop the model when you're satisfied. Adjust the 'host-health?' and 'host-flush?' switches to see how they affect the results.


## Extending the model

Pathogens may be another way to allow for mutualists to persist. To be done later?

## Related models

This model is based off the work by Pillai et al. (2014). We've added some host feedback methods (and later, pathogens) to see how they affect the results.

## Credits and references

* Concept by Décio Correa and Catalina Cuellar-Gempeler, based off work by Pillai et al. (2014).
Coding by Roger Shaw.


* Pillai, P., Gouhier, T. C., and Vollmer, S. V. 2014. The cryptic role of biodiversity in the emergence of host–microbial mutualisms. Ecology letters, 17(11): 1437-1446.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
