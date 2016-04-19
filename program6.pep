;Heather Bradfield
;Program 6
;12-1-15
;Inputs: M, N and the N (Vi, Li) pairs
;Outputs: the indices of the subset of the objects that has the largest possible total value
;and will all fit in the tube simultaneously. This is a variation of the knapsack problem

         BR      main

M:       .block  2           ; length of mailing tube
N:       .block  2           ; number of objects
L:       .word   0           ; sum(L)
V:       .word   0           ; sum(V)
vi:      .block  2
li:      .block  2
twoN:    .word   1           ; 2^N (number of combos for chooser)
bestV:   .word   0           ; best total value
count:   .word   1           ; last index with offset
power:   .word   0           
boxNum:  .word   0
index:   .word   0
vArray:  .block  30          ; value array
lArray:  .block  30          ; length array
chooser: .block  30          ; chooser array
best:    .block  30          ; best array
num:     .block  2
subset:  .ascii  "Subset {  \x00"
endset:  .ascii  " }\x00"
totval:  .ascii  "   Total value: \x00" 


main:    charo   'M',i
         charo   ':',i
         charo   ' ',i
         deci    M,d         ;length of tube

n:       charo   'N',i
         charo   ':',i
         charo   ' ',i
         deci    N,d         ; num of boxes
         lda     N,d
         brle    n           ; check if (N > 0)
         cpa     16,i        ; check if (N < 16)
         brge    n

boxes:   lda     boxNum,d
         cpa     N,d
         brge    counters    ; if box num >= N, branch to counter 
printb:  deco    boxNum,d    ; print box num
         charo   ':',i
         charo   ' ',i
         ldx     index,d
         deci    vi,d
         deci    li,d
         lda     vi,d
         brle    printb      ; check if entered v > 0
         sta     vArray,x    ; add inputed value to vArray 
         lda     li,d
         brle    printb      ; check if entered l > 0
         sta     lArray,x    ; add inputed length to lArray
         addx    2,i         
         stx     index,d     ; next index w/ byte offset
         lda     boxNum,d
         adda    1,i
         sta     boxNum,d    ; boxNum++
         br      boxes

counters:ldx     N,d
         aslx
         stx     count,d     ; count = last index with offset (2N)

forCount:ldx     twoN,d      ; create counter for loop 2^N times
         aslx  
         stx     twoN,d 
         lda     power,d
         adda    1,i
         sta     power,d     
         cpa     N,d         ; *2 while power < N
         brlt    forCount
         
for:     lda     twoN,d      ; for 2^N to 0
         suba    1,i 
         sta     twoN,d        
         brlt    fin
         ldx     count,d
         stx     index,d     ; index = count
         lda     0,i         ; reset L and V
         sta     L,d         
         sta     V,d

choose:  subx    2,i
         brlt    for
         lda     chooser,x
         nota                ; toggle
         sta     chooser,x
         breq    choose      ; if toggled chooser[index] = 0, keep going
         ldx     count,d     ; else find subset
         subx    2,i         ; start at last element in chooser

loop:    lda     chooser,x   ; loop through chooser and find 1's
         breq    next        ; if chooser[count] = 1, get length and value
         lda     L,d
         adda    lArray,x    ; L += lArray[count]
         sta     L,d
         lda     V,d
         adda    vArray,x    ; V += vArray[count]
         sta     V,d
next:    subx    2,i         ; count-- (byte offset)
         brge    loop  
   
         lda     L,d
         cpa     M,d         ; sum(L) <= M?
         brgt    for
         lda     V,d
         cpa     bestV,d     ; if sum(V) > bestV, bestV = sum(V)       
         brle    for
         sta     bestV,d     
         ldx     count,d     ; last index

fillbest:subx    2,i
         brlt    for
         lda     chooser,x   ; loop through chooser and set best array
         sta     best,x      ; best[count] = chooser[count]
         br      fillbest

fin:     charo   '\n',i
         stro    subset,d    
         ldx     -2,i        ; start at beginning of best array

print:   addx    2,i
         cpx     count,d
         brge    done        ; if x >= count print total value
         lda     best,x      
         breq    print       ; if best[x] = 1 
         asrx
         stx     num,d
         aslx
         deco    num,d       ; print box num
         charo   ' ',i
         br      print 
      
done:    stro    endset,d
         stro    totval,d    ; print best total value
         deco    bestV,d
         stop
        
.end
