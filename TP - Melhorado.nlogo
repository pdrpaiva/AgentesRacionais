breed [basics basic] ;cria agentes do tipo basic
breed [experts expert] ;cria agentes do tipo expert
breed [regens regen]

turtles-own [ energy ]
experts-own [ xp alimento tempo-descanso]

to Setup
  Setup-Patches
  Setup-Turtles
  reset-ticks
end

to Go
  ;;if not any? turtles [ stop ] ; para se não houverem agentes

    MoveBasics
    MoveExperts
    MoveRegens
    Basic-Food
    Expert-Food
    Reproduz
    Basic-Armadilha
    Expert-Armadilha

    ;Ocupa-Abrigo
    ;;Death

  tick
  if count turtles = 0 or ticks = 500 [stop]
end


to Setup-Patches
  clear-all
  ;set-patch-size 15
  ;reset-ticks

  ask patches [ set pcolor black] ;background

  ask patches
  [
    if random 101 < alimento_verde ;gera o alimento verde com base no slider da interface
    [
      set pcolor green
    ]

    if random 101 < alimento_amarelo ;gera o alimento amarelo com base no slider da interface
    [
      set pcolor yellow
    ]

    if random 101 < armadilhas ;gera as armadilhas com base no slider da interface
    [
      set pcolor red
    ]
  ]

  ask n-of abrigos patches
  [
    set pcolor blue
  ]
end

to Setup-Turtles
  clear-turtles

  create-basics nbasics[
    set heading 0
    set color white
    set energy 100
    let x one-of patches with[pcolor = black and not any? Basics-here and not any? Experts-here and not any? regens-here]
    setxy [pxcor] of x [pycor] of x
  ]

  create-experts nexperts[
    set heading 0
    set color magenta
    set energy 100
    set tempo-descanso 0
    let x one-of patches with[pcolor = black and not any? Basics-here and not any? Experts-here and not any? regens-here]
    setxy [pxcor] of x [pycor] of x
  ]

  create-regens nregens [
    set heading 0
    set color pink
    set shape "circle 2"
    set size 1
    set energy 1
    let x one-of patches with[pcolor = black and not any? Basics-here and not any? Experts-here]
    setxy [pxcor] of x [pycor] of x
  ]

end

to Perde-Energia ;NÃO FAZ PARTE
  set energy energy - 1
end

to MoveBasics

  ;faz com que apareça um patch laranja random a cada 7 ticks (isto só até ao tick 200)
  if ticks - (int (ticks / 7)) * 7 = 0 and ticks < 200 ;se o resto da divisao dos ticks por 5 for 0 spawna um patch laranja num sitio random
  [
    ask one-of patches with[pcolor = black] [set pcolor orange]
  ]

  ask basics[
    let x energy
    let y energy

    (ifelse
      [pcolor] of patch-ahead 1 = yellow ;se estiver comida à frente, segue em frente p/ comer
      [fd 1 Perde-Energia]

      [pcolor] of patch-right-and-ahead 90 1 = yellow ;se estiver comida à direita, roda 90 p/ direita e segue em frente p/ comer
      [rt 90 fd 1 Perde-Energia]

      [pcolor] of patch-left-and-ahead 90 1 = yellow ;se estiver comida à esq, roda 90 p/ esq e segue em frente p/ comer
      [lt 90 fd 1 Perde-Energia]


      [pcolor] of patch-ahead 1 = red ;se estiver uma armadilha à frente, roda 90 p/direita e segue em frente
      [rt 90 fd 1 Perde-Energia]

      [pcolor] of patch-right-and-ahead 90 1 = red ;se estiver uma armadilha à direita, segue em frente
      [fd 1 Perde-Energia]

      [pcolor] of patch-left-and-ahead 90 1 = red ;se estiver uma armadilha à direita, segue em frente
      [fd 1 Perde-Energia]


      [pcolor] of patch-ahead 1 = blue ;se estiver um abrigo à frente, roda p/ direita e segue em frente
      [rt 90 fd 1 Perde-Energia]

      [pcolor] of patch-right-and-ahead 90 1 = blue ;se estiver um abrigo à direita, segue em frente
      [fd 1 Perde-Energia]

      [pcolor] of patch-left-and-ahead 90 1 = blue ;se estiver um abrigo à direita, segue em frente
      [fd 1 Perde-Energia]


      ;[pcolor] of patch-ahead 1 = orange ;se estiver comida à frente, segue em frente p/ comer
      ;[fd 1 Perde-Energia]

      ;[pcolor] of patch-right-and-ahead 90 1 = orange ;se estiver comida à direita, roda 90 p/ direita e segue em frente p/ comer
      ;[rt 90 fd 1 Perde-Energia]

      ;[pcolor] of patch-left-and-ahead 90 1 = orange ;se estiver comida à esq, roda 90 p/ esq e segue em frente p/ comer
      ;[lt 90 fd 1 Perde-Energia]


      [pcolor] of patch-ahead 1 = blue and any? experts-on patch-ahead 1;se houver algum expert nos abrigos
        [set energy  energy - (energy * 0.05)] ;decrementa 5% da energia

      [pcolor] of patch-right-and-ahead 90 1 = blue and any? experts-on patch-right-and-ahead 90 1;se houver algum expert nos abrigos
        [set energy  energy - (energy * 0.05)] ;decrementa 5% da energia

      [pcolor] of patch-left-and-ahead 90 1 = blue and any? experts-on patch-right-and-ahead 90 1;se houver algum expert nos abrigos
        [set energy  energy - (energy * 0.05)] ;decrementa 5% da energia


      any? experts-on patch-ahead 1 and [pcolor] of patch-ahead 1 != blue ;ve se há algum expert fora do abrigo
      [
        ask Experts-on patch-ahead 1
        [
        (ifelse
          xp < 50 [ ;se o seu lvl de xp for inferior a 50 absorve metade da sua energia
            set x x + (energy / 2)
            set energy energy / 2
          ]
          ; elsecommands
          [
            set energy energy - (energy * 0.10) ;senao perde 10% da sua energia atual
        ])
          set energy x
        ]
      ]

      any? experts-on patch-right-and-ahead 90 1 and [pcolor] of patch-right-and-ahead 90 1 != blue ;ve se há algum expert fora do abrigo
      [
        ask Experts-on patch-right-and-ahead 90 1
        [
        (ifelse
          xp < 50 [ ;se o seu lvl de xp for inferior a 50 absorve metade da sua energia
            set y y + (energy / 2)
            set energy energy / 2
          ]
          ; elsecommands
          [
            set energy energy - (energy * 0.10) ;senao perde 10% da sua energia atual
        ])
          set energy y
        ]
      ]

      any? experts-on patch-left-and-ahead 90 1 and [pcolor] of patch-left-and-ahead 90 1 != blue ;ve se há algum expert fora do abrigo
      [
        ask Experts-on patch-left-and-ahead 90 1
        [
        (ifelse
          xp < 50 [ ;se o seu lvl de xp for inferior a 50 absorve metade da sua energia
            set y y + (energy / 2)
            set energy energy / 2
          ]
          ; elsecommands
          [
            set energy energy - (energy * 0.10) ;senao perde 10% da sua energia atual
        ])
          set energy y
        ]
      ]

      ; else
      [
        (ifelse
          random 101 <= 50 [fd 1 Perde-Energia]

          random 101 <= 50 [rt 90 fd 1 Perde-Energia]

          random 101 <= 50 [lt 90 fd 1 Perde-Energia]
        )
      ]
    )

    ;se o expert percecionar uma ambulancia e estiver com menos de 20 de energia
      if any? regens-on patch-ahead 1 and energy < 20
      [set energy 100] ;restaura a energia

      if any? regens-on patch-right-and-ahead 90 1 and energy < 20
      [set energy 100]

      if any? regens-on patch-right-and-ahead 90 1 and energy < 20
      [set energy 100]

  ]
end

to MoveExperts
  let basicEnergy 0
  ask experts[
    (ifelse
      ;comida
      [pcolor] of patch-ahead 1 = green or [pcolor] of patch-ahead 1 = yellow ;se estiver comida à frente, segue em frente p/ comer
      [fd 1 Perde-Energia]

      [pcolor] of patch-right-and-ahead 90 1 = green or [pcolor] of patch-right-and-ahead 90 1 = yellow;se estiver comida à direita, roda 90 p/ direita e segue em frente p/ comer
      [rt 90 fd 1 Perde-Energia]

      [pcolor] of patch-left-and-ahead 90 1 = green or [pcolor] of patch-left-and-ahead 90 1 = yellow ;se estiver comida à direita, roda 90 p/ direita e segue em frente p/ comer
      [lt 90 fd 1 Perde-Energia]

      ;armadilhas
      [pcolor] of patch-ahead 1 = red ;se estiver uma armadilha à frente, roda 90 p/direita e segue em frente
      [rt 90 fd 1 Perde-Energia]

      [pcolor] of patch-right-and-ahead 90 1 = red ;se estiver uma armadilha à direita, segue em frente
      [fd 1 Perde-Energia]

      [pcolor] of patch-left-and-ahead 90 1 = red ;se estiver uma armadilha à direita, segue em frente
      [fd 1 Perde-Energia]

      ;patches laranjas
      [pcolor] of patch-ahead 1 = orange ;se estiver uma armadilha à frente, roda 90 p/direita e segue em frente
      [rt 90 fd 1 Perde-Energia]

      [pcolor] of patch-right-and-ahead 90 1 = orange ;se estiver uma armadilha à direita, segue em frente
      [fd 1 Perde-Energia]

      [pcolor] of patch-left-and-ahead 90 1 = orange ;se estiver uma armadilha à direita, segue em frente
      [fd 1 Perde-Energia]

      ;[pcolor] of patch-ahead 1 = blue ;se estiver um abrigo à frente, roda p/ direita e segue em frente
      ;[fd 1 Ocupa-Abrigo]

      ;[pcolor] of patch-right-and-ahead 90 1 = blue ;se estiver um abrigo à direita, segue em frente
      ;[fd 1 Perde-Energia]

      [pcolor] of patch-here = blue [contador]

      ;[pcolor] of patch-here = blue []

      [pcolor] of patch-ahead 1 = blue and not any? experts-on patch-ahead 1 = blue;se não houver algum expert nos abrigos
        [fd 1 Perde-Energia ] ;Ocupa-Abrigo

      [pcolor] of patch-right-and-ahead 90 1 = blue and not any? experts-on patch-right-and-ahead 90 1 = blue;se não houver algum expert nos abrigos
        [rt 90 fd 1 Perde-Energia ] ;Ocupa-Abrigo

      [pcolor] of patch-left-and-ahead 90 1 = blue and not any? experts-on patch-left-and-ahead 90 1 = blue;se não houver algum expert nos abrigos
        [lt 90 fd 1 Perde-Energia ] ;Ocupa-Abrigo

      ;se já estiver um expert no abrigo
      [pcolor] of patch-ahead 1 = blue and any? experts-on patch-ahead 1 = blue;se houver algum expert nos abrigos
        [rt 90 fd 1 Perde-Energia]

      [pcolor] of patch-right-and-ahead 90 1 = blue and any? experts-on patch-right-and-ahead 90 1 = blue;se houver algum expert nos abrigos
        [fd 1 Perde-Energia] ;

      [pcolor] of patch-left-and-ahead 90 1 = blue and any? experts-on patch-left-and-ahead 90 1 = blue;se houver algum expert nos abrigos
        [fd 1 Perde-Energia] ;

      ;se os experts percecionarem um basic
      any? basics-on patch-ahead 1 or any? basics-on patch-right-and-ahead 90 1 or any? basics-on patch-left-and-ahead 90 1
       [
       ask one-of basics
        [
          die
          set basicEnergy energy
        ]
       set energy energy + basicEnergy
       ]

      ; else
      [
      ;if [pcolor] of patch-ahead 1 = black or [pcolor] of patch-right-and-ahead 90 1 = black or [pcolor] of patch-left-and-ahead 90 1 = black [
        (ifelse
          random 101 <= 50 [fd 1 Perde-Energia]

          random 101 <= 50 [rt 90 fd 1 Perde-Energia]

          random 101 <= 50 [lt 90 fd 1 Perde-Energia]
        );]
      ]
    )

    ;se os experts percecionarem um basic no patch-ahead 1
      if any? basics-on patch-ahead 1
       [
       ask one-of basics-on patch-ahead 1
        [
          set basicEnergy basicEnergy + energy ; guarda a energia do basic na var basicEnergy
          die ; o agent basic morre
        ]
       ]
    ;se os experts percecionarem um basic no patch-right-and-ahead
      if any? basics-on patch-right-and-ahead 90 1
       [
       ask one-of basics-on patch-right-and-ahead 90 1
        [
          set basicEnergy basicEnergy + energy ; guarda a energia do basic na var basicEnergy
          die ; o agent basic morre
        ]
       ]
    ;se os experts percecionarem um basic no patch-left-and-ahead
      if any? basics-on patch-left-and-ahead 90 1
       [
       ask one-of basics-on patch-left-and-ahead 90 1
        [
          set basicEnergy basicEnergy + energy ; guarda a energia do basic na var basicEnergy
          die ; o agent basic morre
        ]
       ]

      set energy energy + basicEnergy ;o expert fica com a energia do basic q matou

      ;se o expert percecionar uma ambulancia e estiver com menos de 20 de energia
      if any? regens-on patch-ahead 1 and energy < 20
      [set energy energy + 25] ;recupera 25

      if any? regens-on patch-right-and-ahead 90 1 and energy < 20
      [set energy energy + 25]

      if any? regens-on patch-right-and-ahead 90 1 and energy < 20
      [set energy energy + 25]
  ]
end

to MoveRegens
  ask regens[
  (ifelse

  [pcolor] of patch-ahead 1 = green or [pcolor] of patch-ahead 1 = yellow or [pcolor] of patch-ahead 1 = red or [pcolor] of patch-ahead 1 = blue or [pcolor] of patch-ahead 1 = orange;se estiver comida à frente, segue em frente p/ comer
  [rt 90 fd 1]

  [pcolor] of patch-right-and-ahead 90 1 = green or [pcolor] of patch-right-and-ahead 90 1 = yellow or [pcolor] of patch-right-and-ahead 90 1 = red or [pcolor] of patch-right-and-ahead 90 1 = blue or [pcolor] of patch-right-and-ahead 90 1 = orange;se estiver comida à direita, roda 90 p/ direita e segue em frente p/ comer
  [fd 1]

  [pcolor] of patch-left-and-ahead 90 1 = green or [pcolor] of patch-left-and-ahead 90 1 = yellow or [pcolor] of patch-left-and-ahead 90 1 = red or [pcolor] of patch-left-and-ahead 90 1 = blue or [pcolor] of patch-left-and-ahead 90 1 = orange;se estiver comida à direita, roda 90 p/ direita e segue em frente p/ comer
  [fd 1]

  ; else
  [
  ;if [pcolor] of patch-ahead 1 = black or [pcolor] of patch-right-and-ahead 90 1 = black or [pcolor] of patch-left-and-ahead 90 1 = black [
  (ifelse
  random 101 <= 50 [fd 1]

  random 101 <= 50 [rt 90 fd 1]

  random 101 <= 50 [lt 90 fd 1]
  );]
  ])
  ]
end

to Death
  if energy <= 0 [ die ] ; os agentes morrem quando a energia chega a 0
end

to Basic-Food
  ask basics[
  if [pcolor] of patch-here = yellow [ ; se o patch for amarelo, transforma-o em preto e o agent basic ganha 10 de energia
    set pcolor black
    set energy energy + 10
  ]

  if [pcolor] of patch-here = orange [ ; se o patch for laranja, transforma-o em preto e o agent basic ganha 200 de energia
    set pcolor black
    set energy energy + 100
  ]
  ]
end

to Expert-Food
  ask experts[
  ifelse [pcolor] of patch-here = green [ ; se o patch for verde, transforma-o em preto e o agent expert ganha 10 de energia
    set pcolor black
    set energy energy + 10
    set alimento alimento + 1 ;o alimento incrementa
    if alimento - (int (alimento / 10)) * 10 = 0 [set xp xp + 2] ;se o resto da divisao do alimento por 10 for 0 ganha 2 de xp

  ][
    if [pcolor] of patch-here = yellow [ ; se o patch for amarelo, transforma-o em preto e o agent expert ganha 5 de energia
    set pcolor black
    set energy energy + 5
    set alimento alimento + 1 ;o alimento incrementa
    if alimento - (int (alimento / 10)) * 10 = 0 [set xp xp + 1] ;se o resto da divisao do alimento por 10 for 0 ganha 1 de xp
  ]]
    if [pcolor] of patch-here = orange [ ;se percecionar uma armadilha
    if xp >= 50 [set pcolor black] ;instrução armadilha não causa dano
    if xp < 50 and energy >= 100 [set pcolor black set energy energy - (energy * 0.1)] ;perde 10%
    if xp < 50 and energy < 100 [set pcolor black die] ;morre
  ]
  ]
end

to Basic-Armadilha
 ask basics[
 if [pcolor] of patch-ahead 1 = red or  [pcolor] of patch-right-and-ahead 90 1 = red or  [pcolor] of patch-left-and-ahead 90 1 = red[ ;se percecionar uma armadilha
    if energy < 100 [ die ] ;morre se a sua energia for inferior a 100
    if energy >= 100 [ set energy energy - (energy * 0.1)]  ;perde 10% da sua energia se a sua energia for superior a 100
 ]
 ]
end

to Expert-Armadilha
 ask experts[
 if [pcolor] of patch-ahead 1 = red or  [pcolor] of patch-right-and-ahead 90 1 = red or  [pcolor] of patch-left-and-ahead 90 1 = red [ ;se percecionar uma armadilha
    if xp >= 50 [] ;instrução armadilha não causa dano
    if xp < 50 and energy >= 100 [set energy energy - (energy * 0.1)] ;perde 10%
    if xp < 50 and energy < 100 [die] ;morre
 ]
 ]
end

;to Ocupa-Abrigo
;  ask experts [
;  ifelse [pcolor] of patch-here = blue [
;     set tempo-descanso tempo-descanso + 1

;    (ifelse
;    tempo-descanso =  10 ;and energy < 500 or xp < 50
;      [set energy energy + 500 set xp xp + 25] ;se o tempo de descanso for = 10, aumenta a energia em 500, o xp em 25 e volta à função Go
    ;else
;    [
;      if tempo-descanso > 10
;      [set tempo-descanso 0 MoveExperts]

;    ])
;  ][MoveExperts]
;  ]
;end

to contador
  ask experts [
  (ifelse tempo-descanso = 10 [set tempo-descanso 0 set energy energy + 500 set xp xp + 25 fd 1][set tempo-descanso tempo-descanso + 1]);
  ]
end

to Reproduz
  ask basics [
    if energy > 110 [ ;se a energia for superior a 110
      set energy energy - 25 ;perde 25
      hatch 1 [ set energy 80 ] ;reproduz um basic com energia de 80
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
454
10
1017
574
-1
-1
16.82
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
170
11
251
56
NIL
Setup
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
256
11
343
56
NIL
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
122
146
155
alimento_verde
alimento_verde
0
15
8.0
1
1
%
HORIZONTAL

SLIDER
8
89
146
122
alimento_amarelo
alimento_amarelo
0
5
5.0
1
1
%
HORIZONTAL

SLIDER
8
155
146
188
armadilhas
armadilhas
0
2
1.0
1
1
%
HORIZONTAL

SLIDER
8
188
146
221
abrigos
abrigos
1
10
7.0
1
1
NIL
HORIZONTAL

TEXTBOX
9
61
159
83
Sliders Ambiente:
18
0.0
1

TEXTBOX
172
61
322
83
Sliders Agentes:
18
0.0
1

SLIDER
170
89
342
122
nbasics
nbasics
0
50
50.0
1
1
NIL
HORIZONTAL

SLIDER
170
122
342
155
nexperts
nexperts
0
25
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
171
192
321
243
Basics - Branco\nExperts - Magenta\nRegen - Rosa
14
0.0
1

TEXTBOX
10
226
160
294
Basics Food - Amarelo\nExperts Food - Verde\nArmadilhas - Vermelho\nAbrigos - Azul
14
0.0
1

CHOOSER
9
10
147
55
versão-modelo
versão-modelo
"base" "melhorado"
1

MONITOR
183
331
264
376
Basics
count basics
17
1
11

MONITOR
267
331
357
376
Experts
count experts
17
1
11

PLOT
4
380
443
573
Basics vs Experts
ticks
turtles
0.0
25.0
0.0
25.0
true
true
"" ""
PENS
"basics" 1.0 0 -16777216 true "" "plot count basics"
"experts" 1.0 0 -5825686 true "" "plot count experts"

MONITOR
5
331
87
376
Armadilhas
count patches with [pcolor = red]
17
1
11

MONITOR
90
331
179
376
Abrigos
count patches with [pcolor = blue]
17
1
11

MONITOR
360
331
443
376
Regens
count regens
17
1
11

SLIDER
170
156
342
189
nregens
nregens
0
5
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
6
305
156
327
Estatísticas:
18
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.3.0
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