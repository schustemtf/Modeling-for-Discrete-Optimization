% Beauty Trap
% Perform the most seductive dance

enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

int: maxlen;
set of int: STEP = 1..maxlen;
array[LEGS] of int: maxlegs;
array[ARMS] of int: maxarms;
array[FACE] of int: maxface;
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
array[LEGS,ARMS] of int: dance_value;
array[ARMS,FACE] of int: entice_value;
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");
int: boredom; % how bored each step make the viewer

var STEP: len;
array[STEP] of var LEGS: legs;
array[STEP] of var ARMS: arms;
array[STEP] of var FACE: face;

include "regular.mzn";
constraint regular(legs, 7, card(LEGS), ld, 1, {7});
array[1..7,LEGS] of 0..7: ld = 
     [| 2,0,4,5,6,7
      | 0,0,0,5,6,7
      | 2,0,4,0,0,7
      | 2,0,4,0,6,7
      | 2,0,4,5,0,7
      | 2,3,4,5,6,7 
      | 2,0,4,5,6,7 |];
constraint forall(i in 1..maxlen-3)(legs[i] == waltz /\ legs[i+1] == waltz /\ legs[i+2] == waltz -> legs[i+3] != waltz);
constraint forall(i in 1..maxlen-3)(legs[i] == waltz /\ legs[i+2] == curtsey -> legs[i+1] == stand);
constraint regular(arms, 6, card(ARMS), ad, 1, {6});
array[1..6,ARMS] of 0..6: ad = 
     [| 0,3,4,5,6 %start
      | 0,3,4,5,6 %beckon
      | 2,0,4,0,6 %up
      | 2,3,0,0,6 %out
      | 0,3,4,0,6 %wrapped
      | 0,3,4,5,6 |]; %neutral
      
constraint regular(face, 7, card(FACE), fd, 1, {7});
array[1..7,FACE] of 0..7: fd = 
     [| 2,3,4,5,6,7 %START
      | 0,3,4,0,6,7 %smile
      | 2,0,4,5,6,7 %wink
      | 2,3,0,0,6,7 %batt
      | 2,3,4,0,6,7 %think
      | 2,3,4,5,0,7 %glow
      | 2,3,4,5,6,7 |]; %blank
      
constraint forall(i in STEP)((legs[i] == stand /\ arms[i] == neutral -> dance_value[legs[i], arms[i]] == 0) /\ dance_value[legs[i], arms[i]] != -1);

constraint forall(i in STEP)((face[i] == blank /\ arms[i] == neutral -> entice_value[arms[i], face[i]] == 0) /\ entice_value[arms[i], face[i]] != -1);

constraint forall(i in LEGS)(sum(j in 1..maxlen)(legs[j] = LEGS[i]) <= maxlegs[i]);
constraint forall(i in ARMS)(sum(j in 1..maxlen)(arms[j] = ARMS[i]) <= maxarms[i]);
constraint forall(i in FACE)(sum(j in 1..maxlen)(face[j] = FACE[i]) <= maxface[i]);
constraint forall(i in len+1..maxlen)
                 (legs[i] = stand);
constraint forall(i in len+1..maxlen)
                 (arms[i] = neutral);
constraint forall(i in len+1..maxlen)
                 (face[i] = blank);


var int: objective;
constraint objective = sum(i in STEP)(dance_value[legs[i], arms[i]]) +
                sum(i in STEP)(entice_value[arms[i], face[i]]) -
                boredom * len;
solve maximize objective;