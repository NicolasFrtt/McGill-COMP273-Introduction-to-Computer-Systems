Notes on every question. 
IMPORTANT SPECIFICATION for Q3.

Q1:

I used a counter, a ROM and a splitter. 
When counter is 0, no lights are on. From counter=1 to counter=9, lights corresponding to my ID digit is on. 
Then, counter goes back to 0 (no lights on), and starts over.

Q2: 

Helper(s): 
I used a helper (InvertDirection) to simulate a left shift. Using 2 helper and a right shift is equivalent to a left shift.

I implemented the simple version of the circuit. 
It works for any inputs lower or equal to 0111 (and probably also for input up to 1111, although I didn't try every possible input).
Once the DONE signal goes high, subsequent clock cycles don't affect the result.

Q3:

Helper(s): 
I used a helper (InvertDirection, same as for Q2) to simulate a left shift for the quotient. 
I used another helper (AddZeros), to add 4 zeros to the right of the divisor (because a bit extender adds them to the left).

The division circuit works as long as the divisor most significant bit is 0 (i.e. for divisors of at most 0111), as said by Prof. Hsiu-Chin Lin.
Though, it does not work when the most significant bit is 1 (for divisor only, because logisim thinks it is a negative number and it affects the subtraction).
Besides, my circuit requires 6 iterations (instead of 5 as in the method seen in class).
So, my counter stops at 6, and the DONE signal goes high only when the counter reaches 6 (after that, clock cycles don't affect the results). 
The rest of the cicruit should work in the same way as the method seen in class.