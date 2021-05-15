; The Multilevel Group Selection I (MGS I) v2.0

; General variables.
globals
[ percent-of-contributors     ; The current percent of agents that are contributors.
  effort ]                    ; Agents need effort to provide prosocial common-pool behavior and withstand pressure. The constant sets a limit to how much prosocial common-pool behavior an agent can contribute in a group and there is a 1:1 relationship between the two.

; Agent-specific variables.
turtles-own
[ contribution ]              ; A dynamic categorical (effort or 0) variable indicating the amount an agent contributes to a group.

; Initialize the model with the parameter settings in the user interface.
to setup
  clear-all
  set effort 1
  ask patches
  [ set pcolor black
    if count turtles < ( density * 4 * max-pxcor * max-pycor ) [ sprout 1 [set size 1] ] ] ; Use the number of patches and density to distribute agents.
  ask turtles
  [ ifelse count turtles with [ contribution = effort ] < ( initial-percent-of-contributors / 100 * count turtles ) ; Use the initial percent of contributors to assign initial agent type.
    [ set color orange
      set contribution effort ]
    [ set color blue
      set contribution 0 ] ]
  set-default-shape turtles "square"
  set percent-of-contributors (count turtles with [contribution = effort]  / count turtles) * 100
  reset-ticks
end

; Simulate the sequence of processes, until either the number of contributors reaches 0 or all agents become contributors.
to go
  potentially-moving
  potentially-changing-behavior
  update-globals
  if count turtles with [ contribution = effort ] = 0 or
    count turtles with [ contribution = effort ] = count turtles
    [ stop ]
  tick
end

; Agents who are not able to withstand pressure move to one of the closest spots.
to potentially-moving
  ask turtles
  [ ifelse contribution = effort
    [ if ( synergy * effort * count turtles in-radius 1.5 with [ contribution = effort ] / count turtles in-radius 1.5 ) <= pressure
      [ move-to min-one-of patches with [ not any? turtles-here ] [ distance myself ] ] ]
    [ if ( effort + synergy * effort * count turtles in-radius 1.5 with [ contribution = effort ] / count turtles in-radius 1.5 ) <= pressure
      [ move-to min-one-of patches with [ not any? turtles-here ] [ distance myself ] ] ] ]
end

; Agents who are not able to withstand pressure change their begavior.
to potentially-changing-behavior
  ask turtles
  [ ifelse ( count turtles in-radius 1.5 = 1 )
    [ if ( effort <= pressure )
      [ ifelse color = orange
        [ set color blue
          set contribution 0 ]
        [ set color orange
          set contribution effort ] ] ]
    [ ifelse ( contribution = effort )
      [ if ( synergy * effort * count turtles in-radius 1.5 with [ contribution = effort ] /
          count turtles in-radius 1.5 <= pressure )
        [ set color blue
          set contribution 0 ] ]
      [ if ( effort + synergy * effort * count turtles in-radius 1.5 with [ contribution = effort ] /
          count turtles in-radius 1.5 <= pressure )
        [ set color orange
          set contribution effort ] ] ] ]
end

; Update global variables.
to update-globals
  set percent-of-contributors count turtles with [ contribution = effort ] / count turtles * 100
end

; Copyright 2021 Garry Sotnik, Thaddeus Shannon, and Wayne Wakeland
; See end of Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
640
11
1025
397
-1
-1
17.9524
1
10
1
1
1
0
1
1
1
-10
10
-10
10
0
0
1
ticks
30.0

SLIDER
13
13
212
46
density
density
0
1
0.3
.1
1
NIL
HORIZONTAL

SLIDER
14
59
211
92
initial-percent-of-contributors
initial-percent-of-contributors
0
100
30.0
1
1
%
HORIZONTAL

BUTTON
15
191
72
224
setup
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
82
191
144
224
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
154
192
209
225
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
225
238
306
283
# of agents
count turtles
17
1
11

MONITOR
323
238
421
283
# of contributors
count turtles with [ color = orange ]
17
1
11

MONITOR
438
237
556
282
# of non-contributors
count turtles with [ color = blue ]
17
1
11

SLIDER
14
146
211
179
synergy
synergy
0
10
8.0
.1
1
NIL
HORIZONTAL

SLIDER
14
102
211
135
pressure
pressure
0
10
7.0
.1
1
NIL
HORIZONTAL

PLOT
225
12
625
226
Contributors
ticks
% of population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -955883 true "" "plot percent-of-contributors"

MONITOR
570
236
627
281
ticks
ticks
17
1
11

@#$#@#$#@
## WHAT IS IT?
Multilevel Group Selection I (MGS I) simulates a social space composed of agents that either contribute prosocial common-pool behavior when in a group or not (i.e., freeride), and that are equally exposed to some (physical, psychological, and/or social) pressure to change their behavior. Exposure to prosocial common-pool behavior can help agents withstand the pressure, especially when the behavior is synergistic. Agents move within their social space to avoid this pressure, as a result forming into groups (common pools), which is where prosocial common-pool behavior can occur. Agents unable to withstand the pressure automatically change from contributing prosocial common-pool behavior to not or vice versa. 

## HOW IT WORKS
An iteration consists of two main steps, potential movement and potential behavioral change. Agents can move within their social space, which represents any process of leaving and/or joining a group. It could represent physical movement from one geographic location to another or virtual movement from one online location to another. Agents are selected randomly one-by-one and automatically move to one of the closest empty spots if their ability to withstand pressure is below the pressure level. After potentially moving, agents are selected randomly one-by-one and automatically change their behavior if their ability to withstand pressure is below the pressure level.

## THEORETICAL FOUNDATIONS
The MGS I model has three main theoretical influences that shaped its design. The first is multilevel (group) selection theory (Boyd, 2018; Goodnight & Stevens, 1997; Sober & Wilson, 1999; Waring et al., 2015; Wilson & Sober, 1994; Wilson & Wilson, 2007). The theory explains how a group’s composition and within-group interaction can influence its competitiveness against that of other groups and as a result allow for selection to occur at both the level of the individual and the group. The MGS I model’s design followed Sober and Wilson’s (1999) set of criteria for the emergence of multilevel selection, which requires: (a) the presence of more than one group, (b) group heterogeneity (in respect to the trait), (c) a direct and positive relationship between the number of members carrying the trait and the fitness of a group, and (d) isolation among sets of agents significant enough to form groups but not so significant as to prevent between-group migration.

Another major influence is Schelling’s (1971, 1978) research into segregation, which demonstrates how even a minor bias influencing residents’ relocation preference can lead to an unexpected outcome, such as segregation of the entire population. In Schelling’s agent-based model, each agent’s preference influences the value of adjacent spots for other agents. As each agent moves in search of better spots, they potentially influence the values of their old and new adjacent spots. Agents moving from one neighborhood to another represents a dynamic neighborhood selection process, with within-neighborhood dynamics driving between-neighborhood dynamics and the two being closely intertwined. The MGS I model reinterprets Schelling’s neighborhoods as common-pools (Ostrom et al., 1994), with the movement of agents representing a dynamic common-pool selection process within a landscape of social spots. Schelling’s model helped fulfill Sober and Wilson’s criteria a, b, and d.

The last main influence are common-pool games (Chaudhuri, 2011; Holt & Laury, 2002; Ledyard, 1994; Levitt & List, 2007; McGinty & Milam, 2013), from which the MGS I model borrows the equations for calculating the expected and actual spot values, as well as the benefits gained by agents from participating in common pools. The equations from common-pool games helped satisfy Sober and Wilson’s criterion c.

## HOW TO USE IT
Use the buttons and sliders described below to set the initial conditions. Click the SETUP button to randomly distribute agents on the landscape. Click the GO button to start simulating and click it once again if you would like the simulation to stop. Click the GO ONCE button if you would like the model to simulate for just one period. When the model is simulating, you may use the VIEWER to observe agent behavior and the PLOT to observe the change in the current percent of contributing agents.

The # OF AGENTS monitor displays the current number of agents at any point during a simulation. This number should not change during a simulation.

The # OF CONTRIBUTORS monitor displays the current number of contributing agents during a simulation.

The # OF NON-CONTRIBUTORS monitor displays the current number of non-contributing agents during a simulation.

The DENSITY slider (0 ≤ 0.1 ≤1) sets the number of agents that are to be simulated as a percentage of the number of spots on the landscape.

The INITIAL-PERCENT-OF-CONTRIBUTORS slider (0% ≤ 1 ≤ 100%) sets the initial number of contributors as a percentage of the number of all agents.

The PRESSURE slider (0 < 0.1 < 10) sets the selection pressure level.

The SYNERGY slider (0 ≤ 0.1 ≤ 10) sets the level of extra benefit derived from contributed energy to a group (common pool). When synergy is at 1, there is no extra benefit. When greater than 1, the level of extra benefit increases proportionally. When less than 1, the level decreases proportionally.

## THINGS TO TRY
Try different combinations of PRESSURE and SYNERGY to see how the changes affect the percent of contributing agents. For example, try to find the PRESSURE-SYNERGY combinations under which multilevel group selection leads to population-wide adoption of prosocial common-pool behavior. Also, the above description of the model assumes contributing is beneficial to others. This is not always the case. Sometimes contributing is harmful to others (e.g., pollution). In such cases, the SYNERGY from contributing is below one. You can try reducing SYNERGY below one to see what happens when contributing is harmful to others.

## RELATED MODELS
Similar models in the NetLogo library are:

- Segregation
- Segregation Simple
- Segregation Simple Extension 1
- Sugarscape 1 Immediate Growback
- Sugarscape 2 Constant Growback
- Sugarscape 3 Wealth Distribution

## CREDITS AND REFERENCES

Boyd, R. (2018). A different kind of animal: How culture transformed our species. Princeton University Press.

Chaudhuri, A. (2011). Sustaining cooperation in laboratory public goods experiments: A selective survey of the literature. Experimental Economics, 14(1), 47–83. https://doi.org/10.1007/s10683-010-9257-1

Goodnight, C. J., & Stevens, L. (1997). Experimental Studies of Group Selection: What Do They Tell US About Group Selection in Nature? The American Naturalist, 150(S1), S59–S79. https://doi.org/10.1086/286050

Holt, C. A., & Laury, S. K. (2002). Risk Aversion and Incentive Effects. THE AMERICAN ECONOMIC REVIEW, 92(5), 94.

Ledyard, J. O. (1994). Public Goods: A Survey of Experimental Research. In J. H. Kagel & Roth, A. E. (Eds.), The Handbook of Experimental Economics. Princeton University Press.

Levitt, S. D., & List, J. A. (2007). What Do Laboratory Experiments Measuring Social Preferences Reveal about the Real World? The Journal of Economic Perspectives, 21(2), 153–174.

McGinty, M., & Milam, G. (2013). Public goods provision by asymmetric agents: Experimental evidence. Social Choice and Welfare, 40(4), 1159–1177. https://doi.org/10.1007/s00355-012-0658-2

Ostrom, E., Gardner, R., & Walker, J. (Eds.). (1994). Rules, Games, and Common-Pool Resources. The University of Michigan Press.

Schelling, T. C. (1971). Dynamic models of segregation†. The Journal of Mathematical Sociology, 1(2), 143–186. https://doi.org/10.1080/0022250X.1971.9989794

Schelling, T. C. (1978). Micromotives and macrobehavior. Norton.

Sober, E., & Wilson, D. S. (1999). Unto others: The evolution and psychology of unselfish behavior. Harvard University Press.

Waring, T. M., Kline, M. A., Brooks, J. S., Goff, S. H., Gowdy, J., Janssen, M. A., Smaldino, P. E., & Jacquet, J. (2015). A multilevel evolutionary framework for sustainability analysis. Ecology and Society, 20(2), art34. https://doi.org/10.5751/ES-07634-200234

Wilson, D. S., & Sober, E. (1994). Reintroducing group selection to the human behavioral sciences. Behavioral and Brain Sciences, 17(4), 585–608. https://doi.org/10.1017/S0140525X00036104

Wilson, D. S., & Wilson, E. O. (2007). Rethinking the Theoretical Foundation of Sociobiology. The Quarterly Review of Biology, 82(4), 327–348. https://doi.org/10.1086/522809

## HOW TO CITE
Sotnik, G., Shannon, T. T., & Wakeland, W. W. (2021). Multilevel Group Selection I (2.0) [NetLogo]. https://github.com/Multilevel-Group-Selection 

## COPYRIGHT AND LICENSE
Copyright (C) 2021 Garry Sotnik, Thaddeus T. Shannon, & Wayne W. Wakeland

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
NetLogo 6.2.0
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
