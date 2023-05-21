.data 

filename : .asciiz "input1.txt"
out_put_file : .asciiz "output.txt" 
readbuffer: .space 1024
writebuffer: .space 1024


newLine: .asciiz "\n"

MSG1: .asciiz "Please Enter 0 to read the file Please <3 : "
MSG2 : .asciiz "Enter 1 if you would like to use mean Enter 2 if you would like to use median: "
MSG3: .asciiz "Enter the array level :) Please: "
MSG4 : .asciiz "The Level you've Entered Is not valid \n"
OneAndHalf: .float 1.5
Half: .float 0.5
OneHundred : .float 100.0
Ten: .float 10.0

.text

main :

j openFile
# reset all tmp registers

resettmp :
li $t1, 0
li $t2, 0
li $t3, 0
li $t4, 0
li $t5, 0
li $t6, 0
li $t7, 0
li $t8 , 0
li $t9 , 0
jr $ra

closefile:
li $v0,16
move $a0,$s5
syscall
li $s3, 0
li $s2, 0
li $s1, 0


openFile:
li $v0, 4
la $a0, MSG1	
syscall

li $v0, 5
syscall

bnez $v0, openFile
#open file

li $v0 , 13  #open file

la $a0, filename #address of input buffer (name of the file)

li $a1, 0 #open for reading (0: read, 1: write)

syscall

move $s5,$v0 #save the file descriptor in $s0

#read file
li $v0 , 14  #read from a file

move $a0 , $s5 #address of filename (descriptor in $s0)

la $a1,readbuffer #address of input buffer

li $a2 , 1024 #max num to read

syscall

la $t0 , readbuffer #address of input buffer used to load the file content

li $t1,0 #used to count the digits, initial val. is zero


add $s1,$s1,1 
add $s2,$s2,1
size:
lb $t2, 0($t0)
beq $t2, 44, column
beq $t2, 10, inc_row 
beq $t2, $zero, allocate
add $t0,$t0, 1    # else increment the address (to next byte) 
j size


column: 
add $s1,$s1, 1
add $t0 , $t0 ,1 
j size


row:
add $t0, $t0, 1    # else increment the address (to next byte)
lb  $t2, 0($t0)
beq $t2, 10, inc_row
beq $t2, $zero, allocate 
j row
inc_row:
add $s2, $s2 , 1 
j row


traverse:
lb $t2, 0($t0)  # Load the first byte from address in $t0  
beqz $t2, reset # if $t2 == 0 then go to label end , this happen when we finish reading
beq $t2 , 10, reset #if end of line branch to reset
bne $t2, 44, omar   # branch if symbol  not equals 44 (,)
beq $t2 , 44 , reset # if , branch to reset


add $t0,$t0, 1    # else increment the address (to next byte) 

add $t1, $t1, 1   # increment the counter

j traverse    


omar:  
add $t0,$t0, 1      # else increment the address  
add $t1, $t1, 1 # and increment the counter 
beq $t2, 46 ,intToFloat # to check if there is a dot indicating the start of fraction part 

beq $t6 , 1 , fraction_calc 
andi $t2 , $t2 , 0x0f #??
bgt $t1 , 1, mul_ten #branch if greater than 1
li $t5 , 0 #initialize 
add $t5 , $t5, $t2 # add the current digit to t5, (this command will be used only once at the initial case only)

j traverse 


mul_ten: 
mul $t5 , $t5, 10
add $t5 , $t5, $t2
j traverse


div_ten : 
li $t9,0

add $t7, $t7 ,1  #increase tmp count
li $t9 , 10
mtc1 $t9 , $f4
cvt.s.w $f4, $f4
div.s $f5, $f5, $f4 
bne $t1 , $t7 , div_ten  #compare current count with fraction count
li $t7, 0 
add.s $f6, $f6, $f5
add.s $f12 , $f12 , $f5


mov.s $f5, $f31

jr $ra


intToFloat : 
mtc1 $t5 , $f1 #the whole num after turning it to float saved in floating point register f1
cvt.s.w $f1,$f1 #convert from word to single percision 
li $t1 , 0  #initialize the counter , start counting for fraction digits
li $t6 , 1  #flag??
mov.s $f12,$f1
j traverse

fraction_calc :
andi $t2 , $t2 , 0x0f

mtc1 $t2 , $f1 # move to floating point register 

cvt.s.w $f1,$f1 # convert integer to float 
mov.s $f5, $f1
jal div_ten


j traverse

reset:

jal AddToArr
#li $v0,2 #print float 
#syscall 

li $v0, 4
la $a0, newLine
syscall

li $t1, 0
li $t3, 0
li $t4, 0
li $t5, 0
li $t6, 0
li $t7, 0
la $t4, ($t0) # save the position 

add $t0,$t0, 1    # else increment the address (to next byte) 

mov.s $f1 , $f31
mov.s $f2 , $f31
mov.s $f3 , $f31
mov.s $f4 , $f31
mov.s $f5 , $f31
mov.s $f6 , $f31
mov.s $f12, $f31

 j traverse

allocate : 
li $t1, 0
li $t2, 0
li $t3, 0
li $t4, 0
li $t5, 0
li $t6, 0
li $t7, 0
la $t0, readbuffer #address of input buffer used to load the file content

mul $s3, $s1, $s2 #find the size of the array


# PLEASE FIX THE BOX THINGY ARRAY CHECK
li $t3 , 2 
div $s2 , $t3 
mfhi $t7 
bnez $t7, closefile
li $t7 , 0
div $s1 , $t3
mfhi $t7 
bnez $t7, closefile

bne $s2,$s1, closefile

sll $s3, $s3, 2   # multiply number of elements by 2^2 = 4
                  # because each single precision floating point number takes 4 bytes

li  $v0, 9
syscall
move $s0,$v0   # save array address in $s0
move $s4, $s0



j traverse

AddToArr:
swc1 $f12, 0($s4)
l.s $f12, 0($s4)

li $v0, 2
syscall

addi $s4, $s4, 4
beqz $t2, Sara
jr $ra


Sara:


#close file
li $v0,16
move $a0,$s5
syscall



move $t7 , $s1
move $t6,$s2
li $v0 , 4 
la $a0 , newLine
syscall 
j i
not_valid:
li $v0 , 4
la $a0 , MSG4
syscall 
i: 
li $v0, 4
la $a0, MSG3	
syscall

li $v0, 5 
syscall
move $a1, $v0
move $a2 , $a1 
j checkLevel

valid:
li $v0 , 4 
la $a0 , newLine
syscall 
li $v0, 4
la $a0, MSG2	
syscall
li $v0, 5 
syscall
j subArray

checkLevel:
sub $a1 , $a1 , 1
li $t5 , 2
div $t7,$t7 , $t5 #div row by 2
mfhi $t5 
beq $t5 , 1 , not_valid
li $t5 , 2
div $t6,$t6 , $t5 #div col by 2 
mfhi $t5
beq $t5 , 1 ,not_valid
beq $a1 ,1, valid  
j checkLevel
######################################################################
# Subarrying and meadian / mean calculations 
subArray :
move $s7,$s0 # to indeicate where the value found after calculation will be stored
li $s5,0
move $s5 , $s0
sub $a2 , $a2 , 1 
mul $t1 , $s1, $s2 
li $t5 ,0
move $t5 ,$t1

li  $t2 , 4 # change this dumbshit
mul $t5 , $s2 , 4 # to find the last byte of the subarrray 
sub $t5 , $t5 , 4 #unless i get a better idea 
div $t1,$t2
li $t1,0
mflo  $t1 # how many subarrays there are 
sara3:
div $s6 , $s2 , 2 #to know the last block in the currnt row has been reached to move the window down
divide:

la $t0 , ($s5) 
l.s  $f10,0($t0)
swc1 $f31 , 0($t0)
add $t0, $t0 , 4 

l.s $f11 , 0($t0)
swc1 $f31 , 0($t0)
add $t0 , $t0 ,$t5

l.s $f12 , 0($t0)
swc1 $f31 , 0($t0)
add $t0,$t0, 4

l.s $f13 , 0($t0)
swc1 $f31 , 0($t0)



sub $t1 , $t1 , 1 # to indicate that a block is done 
sub $s6 ,$s6 , 1


beq $v0 ,1 , mean


beq $v0 ,2 , median

store:

sara2:
beqz $t1 , done
beqz $s6, LastBlockInRow
add $s5,$s5,8 
j divide 
LastBlockInRow:
move $s5 , $t0
add $s5, $s5,4
j sara3

median :
jal findMaxMin
add.s $f12,$f12,$f13
mov.s $f14,$f31
li $t9, 2 
mtc1 $t9 , $f14 #the whole num after turning it to float saved in floating point register f1
cvt.s.w $f14,$f14 #convert from word to single percision 
div.s $f13 ,$f12 ,$f14
swc1 $f13 , 0($s7)
add $s7, $s7 , 4
j store

findMaxMin :

c.le.s $f10, $f11 
bc1t swap1
r1:
c.le.s $f10, $f12 
bc1t swap2
r2:
c.le.s $f10, $f13 
bc1t swap3
r3:
c.le.s $f12, $f11
bc1t swap4
r4:
c.le.s $f13, $f11 
bc1t swap5
r5:
jr $ra
swap1:
mov.s $f14 , $f10
mov.s $f10 , $f11 
mov.s $f11 , $f14
j r1
swap2:
mov.s $f14 , $f10
mov.s $f10 , $f12 
mov.s $f12 , $f14
j r2
swap3:
mov.s $f14 , $f10
mov.s $f10 , $f13 
mov.s $f13 , $f14
j r3
swap4:
mov.s $f14 , $f11
mov.s $f11 , $f12 
mov.s $f12 , $f14
j r4
swap5:
mov.s $f14 , $f11
mov.s $f11 , $f13 
mov.s $f13 , $f14
j r5

mean :
move $a1 , $a2 
div $a1,$a1 , 2
mfhi $a1 
beq $a1,1,odd_mean 
# if the lvl is even 


even_mean:
l.s $f14, OneAndHalf
l.s $f15, Half


mul.s $f10, $f10, $f14
mul.s $f11, $f11, $f15
mul.s $f12, $f12, $f14
mul.s $f13, $f13, $f15

add.s $f10, $f10,$f11
add.s $f10, $f10,$f12
add.s $f10, $f10,$f13


li $t9, 4
mtc1 $t9 , $f17 #the whole num after turning it to float saved in floating point register f1
cvt.s.w $f17,$f17 #convert from word to single percision 
div.s $f10, $f10, $f17
swc1 $f10 , 0($s7)
add $s7, $s7 , 4
j store




odd_mean:
l.s $f15, OneAndHalf
l.s $f14, Half


mul.s $f10, $f10, $f14
mul.s $f11, $f11, $f15
mul.s $f12, $f12, $f14
mul.s $f13, $f13, $f15

add.s $f10, $f10,$f11
add.s $f10, $f10,$f12
add.s $f10, $f10,$f13

li $t9, 4
mtc1 $t9 , $f17 #the whole num after turning it to float saved in floating point register f1
cvt.s.w $f17,$f17 #convert from word to single percision 
div.s $f10, $f10, $f17
swc1 $f10 , 0($s7)
add $s7, $s7 , 4
j store
done:
div $s1 , $s1 , 2
div $s2 , $s2 , 2 
beq $a2 , 1 , printToFile
j subArray

printToFile:
#open file
li $v0 , 13  #open file
la $a0, out_put_file #address of input buffer (name of the file)
li $a1, 1 #open for reading (0: read, 1: write)
syscall
l.s $f15 , OneHundred
l.s $f14 , Ten
jal resettmp
la $t0 , writebuffer
mul $s3, $s1 , $s2 #size 
li $s4 , 0
move $s4 , $s2 
nextNumber:
# convert the number to a string digit by digit 
l.s $f1 , 0($s0)
add $s0 , $s0 , 4 
convfrac:
div.s $f1 , $f1 , $f14
cvt.w.s $f0 , $f1
mfc1 $t1 ,$f0
add $t2, $t2, 1 #count number of digits  before the comma
beqz $t1 , DoneDiv
j convfrac
DoneDiv:
mul.s $f1 , $f1 , $f14
cvt.w.s $f0 , $f1
mfc1 $t1 , $f0
mtc1 $t1 , $f5
cvt.s.w $f5,$f5
add $t1 , $t1 , 48
sb $t1 , 0($t0)
sub.s $f1 , $f1 , $f5 
addiu $t0 , $t0 ,1
subiu $t2 , $t2 ,1
beqz $t2 , addDot
j DoneDiv
# adding the dot at the end fo the decimal digits
addDot:
li $t1 , 46
sb $t1 ,0($t0)
add $t0 , $t0 , 1
li $t2 , 3 
getFrac:
mul.s $f1 , $f1 , $f14
cvt.w.s $f0 , $f1
mfc1 $t1 , $f0
mtc1 $t1 , $f5
cvt.s.w $f5,$f5
add $t1 , $t1 , 48
sb $t1 , 0($t0)
sub.s $f1 , $f1 , $f5
addiu $t0 , $t0 ,1
subiu $t2 , $t2 ,1

beqz $t2 , doneNum
j getFrac
#add comma at the end of the decimal digits 
doneNum:
sub $s3 , $s3 , 1 
sub $s4 , $s4 , 1 
beqz $s3 , final 
beqz $s4 , doneRow
li $t1, 44
sb $t1 , 0($t0)
add $t0 , $t0 , 1

j nextNumber
# go down a line when the row is over 
doneRow :
li $t1 , 10 
sb $t1 ,0($t0) 
add $t0 , $t0 , 1 
li $t1 , 13 
sb $t1 , 0($t0) 
add $t0, $t0 , 1
move $s4 , $s2 
j nextNumber

final : 
move $a0 , $v0
li $v0 , 15
la $t4 , writebuffer
move $a1 , $t4 
li $a2 , 1024
syscall 









