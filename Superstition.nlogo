 breed [cats cat]
breed [humans human]

globals [number-superstitous probability-list number-of-switches human-influence-range belief-influence]
humans-own [alpha superstitious? red-count cat-sighting-memory introduced?]

to setup
  clear-all
  reset-ticks
  set human-influence-range 5
  set number-of-switches 0
  set belief-influence 24
  set-default-shape humans "person"
  set-default-shape cats "wolf"
  setup-consideration-math
  create-cats number-of-cats
  [
    set color gray
    setxy random-xcor random-ycor
  ]
  create-humans 75
  [
    set color blue
    set introduced? false
    set cat-sighting-memory n-values memory-length [0] ;; Start by remembering no red patches under cats
    setxy random-xcor random-ycor
    set alpha random-normal initial-average-alpha 5
    set superstitious? false
    set red-count 1 ;; Avoids starting out with unrealistic probabilities, defaults to .33 or .66 for red-probability
  ]
end

to go
  color-patches
  ask cats [
    cat-wiggle
  ]
  ask humans [
    wiggle
    adjust-alpha
    look
  ]
  tick

  ;set c c + count patches with [pcolor = red and any? cats-here] / count patches with [pcolor = red]
  ;set true-p c / ticks
  ;;set avg-alpha (sum [alpha] of n-of 20 humans) / 20

  set number-superstitous count humans with [superstitious?]
end

to cat-wiggle ;;cat procedure
   ;;cats move more slowly than humans, so that humans probably don't see the same cat twice
  rt 30
  lt 30
  fd .1
end

to color-patches
  if ticks mod 50 = 0 [
    ask patches [
      ifelse random 100 < red-patch-percentage
      [set pcolor red]
      [set pcolor black]
    ]
  ]
end

to adjust-alpha ; human procedure
  if any? humans in-radius human-influence-range with [superstitious?]
  [
    set alpha alpha + other-human-influence
    set introduced? true
  ]
  if introduced? and not any? humans in-radius human-influence-range with [superstitious?]
  [
    set alpha alpha - other-human-influence / superstition-influence-bias
  ]

  if alpha < 0 [set alpha 0]
  if alpha > 100 [set alpha 100]
end



to wiggle ; human procedure
  ifelse superstitious? and danger?
  [face max-one-of cats [distance self]
    rt 180
    rt random 45
    lt random 45
    fd 3]
  [
  rt random 90
  lt random 90
  fd 3]
end

to look
  if any? neighbors with [pcolor = red] [set red-count red-count + 1]
  if any? neighbors with [any? cats-here] [
    let patches-sighted count neighbors with [pcolor = red and any? cats-here]
    ifelse patches-sighted = 0 and superstitious?
    [ if random 100 > alpha [
      set cat-sighting-memory bl fput count neighbors with [pcolor = red and any? cats-here] cat-sighting-memory
    ]]
    [set cat-sighting-memory bl fput count neighbors with [pcolor = red and any? cats-here] cat-sighting-memory] ;;Remembers the danger of the patch, or 0 if there aren't any red patches under cats
    consider
  ]
end


;; Calculates the probability of having seen n or more red patches out of memory-length viewings by starting with the probability of 0 or more and removing the probability of 0-(n-1) using a binomial distribution.
to consider ;human procedure
  let p 1.0   ;Represents probability 0 or more
  let n 0
  let danger-impression 0
  let red-probability red-count / (ticks + 3 )
  foreach cat-sighting-memory [   ; Subtracts probability of seeing n patches when memory contains n+1 cases of seeing a patch
    if ( ? >= 1)
    [ set p p - ((item n probability-list) * (1 - red-probability) ^ (memory-length - n) * (red-probability) ^ n )
      set n n + 1
    ]
    set danger-impression danger-impression + ? - 1
  ]

  ifelse p * 100 <= alpha + danger-impression / memory-length
    [
      if not superstitious? [
        set number-of-switches number-of-switches + 1
        set alpha alpha + belief-influence
        set cat-sighting-memory n-values memory-length [1]
        set superstitious? true
        set color orange
        ask humans in-radius human-influence-range [set alpha alpha + other-human-influence]
      ]

    ]
    [
      if superstitious? [
        set number-of-switches number-of-switches + 1
        set superstitious? false
        set color blue
        ask humans in-radius human-influence-range [set alpha alpha - other-human-influence]
        set alpha alpha - belief-influence]
      ]
end

;; Creates a list where [(item n list) == (memory-length choose n)]
;; seperated to clean up setup code and remove complicated math from it
to setup-consideration-math ;observer procedure
  set probability-list n-values (memory-length + 1) [?]
  let factorial-list (list)
  let factorial 1
  foreach probability-list [
    if ? > 0 [
      set factorial factorial * ?
    ]
    set factorial-list lput factorial factorial-list
  ]
  set probability-list map [(item (memory-length) factorial-list)/((item ? factorial-list) * (item ((memory-length) - ?) factorial-list))] probability-list
end
@#$#@#$#@
GRAPHICS-WINDOW
257
13
729
506
16
16
14.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
25
155
91
188
NIL
setup\n
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
105
155
168
188
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
760
111
960
261
number-superstitious
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot number-superstitous"

SLIDER
25
110
207
143
initial-average-alpha
initial-average-alpha
0
100
31
1
1
NIL
HORIZONTAL

SLIDER
25
70
197
103
memory-length
memory-length
2
10
4
1
1
NIL
HORIZONTAL

SLIDER
25
205
217
238
red-patch-percentage
red-patch-percentage
0
50
2
1
1
NIL
HORIZONTAL

SLIDER
25
30
197
63
number-of-cats
number-of-cats
0
100
8
1
1
NIL
HORIZONTAL

SWITCH
25
245
131
278
danger?
danger?
0
1
-1000

SLIDER
25
285
225
318
other-human-influence
other-human-influence
0
.1
0.05
.01
1
NIL
HORIZONTAL

MONITOR
787
42
928
87
NIL
number-of-switches
17
1
11

SLIDER
25
325
249
358
superstition-influence-bias
superstition-influence-bias
1
5
2
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a model intended to examine the growth of a superstition in a population. It offers a more in-depth answer to why superstitions grow than "people just don't understand statistics." It assumes humans are capable of running correct statistical experiments, and that they simply have a lower standard for what is "improbable" than statisticians.

## HOW IT WORKS

Agents move around and keep a log of the last few times they saw a cat, and whether or not that cat was on a red patch. Each time the log changes, they consider the odds that the long has as many or more red patches than it has, this is done using a binomial distribution formula. If the odds are lower than their alpha value, the humans become superstitious, and tell other nearby humans to raise their alpha values. The same happens when they stop being superstitious if they see very few red patches. Every tick, if a human is close to a superstitious human, they increase their own alpha, and if they are close to a non-superstitious human, they decrease it by the same amount or less, depending on their superstition bias.

## HOW TO USE IT

Use setup and go to set the model up and begin running it. Red-patch-percentage controls how many of the patches become red. Number-of-cats sets the number of cats created on setup. Danger? controls whether or not the humans run away from cats when they are superstitious (simulating that the humans are afraid of red patches and would therefore avoid anything causing them. Memory-length controls how many of their recent cat sightings are remembered by humans. Initial-average-alpha controls the mean of the normal distribution of alphas among the humans. Other-human influence controls how much humans adjust their alphas when another human becomes superstitious or not nearby or when they see at least one superstitious or not superstitious human nearby. Superstition-influence-bias determines how much more humans adjust their alpha based on superstitious humans than based on non-superstitious humans.

## THINGS TO NOTICE

As you can see, with the default values the population becomes superstitious most of the time, or ends up in a "rut". After some time regardless, the population stops changing its beliefs overall. Also notice how the humans who are avoiding the cats tend to group together.

## THINGS TO TRY

Try turning off danger and seeing if you can adjust the other sliders to still produce a superstitious population. It becomes almost impossible with realistic settings. Another intersting effect is increasing the percentage of red patches or the number of cats even by a small amount. Once again, it prevents the population becomming superstitious.

One very intersting effect is increasing the percentage of red patches while the model is running. Often, this leads to a large jump in superstitious humans, and sometimes it's impossible to revert this jump.

## EXTENDING THE MODEL

A potential extension of this model is to improve the communication model. This could include incorperating a network so that humans speak to their friends about their beliefs. Another potential change could be using alpha values to determine how much humans influence each other, instead of just superstitious?.

Another extension could be the incorperation of different types of humans, like skeptics with low alpha values who don't easily shift their alpha values. It could be interesting to see how much impact these skeptics would have, and whether or not they would eventually be convinced.

## NETLOGO FEATURES

This model makes extensive use of lists. First, lists are used with fput and bl in order to create a deque like data structure, where new memories are added to the top as old memories are removed from the bottom. Another use of lists is in the probability-list, which follows the rule ((item n list) = (memory-length choose n)). This is done by using n-values to create a list of numbers, foreach with a local value to turn that into a list of factorials, and map to use that list of factorials in numerous iterations of the binomial equation. Creating global mathematic values isn't something that occurs very frequently in models, but it makes sense to skip the factorial step being computed every time in this model.

## RELATED MODELS

Rumor mill is a related simulation of the spread of potentially false information. Another example is the Belief Diffusion model available in the modeling commons.

## CREDITS AND REFERENCES

Cosmides, L., Tooby, J.: Are humans good intuitive statisticians after all? Rethinking some conclusions from the literature on judgment under uncertainty. Cognition 58, 1–73 (1996)

Beck, J., Forstmeier, W., 2007. Superstition and belief as inevitable byproducts of an adaptive learning strategy. Hum. Nat. 18, 35.

Wilensky, U. (1999). NetLogo [computer software]. Evanston, IL: Center for Connected Learning and Computer-Based Modeling, Northwestern University.  http://ccl.northwestern.edu/netlogo .
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

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

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

rabbit
false
0
Polygon -7500403 true true 61 150 76 180 91 195 103 214 91 240 76 255 61 270 76 270 106 255 132 209 151 210 181 210 211 240 196 255 181 255 166 247 151 255 166 270 211 270 241 255 240 210 270 225 285 165 256 135 226 105 166 90 91 105
Polygon -7500403 true true 75 164 94 104 70 82 45 89 19 104 4 149 19 164 37 162 59 153
Polygon -7500403 true true 64 98 96 87 138 26 130 15 97 36 54 86
Polygon -7500403 true true 49 89 57 47 78 4 89 20 70 88
Circle -16777216 true false 37 103 16
Line -16777216 false 44 150 104 150
Line -16777216 false 39 158 84 175
Line -16777216 false 29 159 57 195
Polygon -5825686 true false 0 150 15 165 15 150
Polygon -5825686 true false 76 90 97 47 130 32
Line -16777216 false 180 210 165 180
Line -16777216 false 165 180 180 165
Line -16777216 false 180 165 225 165
Line -16777216 false 180 210 210 240

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
NetLogo 6.0-M5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="8000"/>
    <metric>count humans with [superstitious?]</metric>
    <enumeratedValueSet variable="belief-influence">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-average-alpha">
      <value value="31"/>
    </enumeratedValueSet>
    <steppedValueSet variable="other-human-influence" first="0" step="0.01" last="0.1"/>
    <enumeratedValueSet variable="number-of-cats">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="superstition-influence-bias">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="danger?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-humans">
      <value value="76"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-patch-percentage">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
1
@#$#@#$#@
