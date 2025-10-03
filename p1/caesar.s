.data
    PromptForPlaintext:
        .asciz  "Please enter the plaintext: "
        lenPromptForPlaintext = .-PromptForPlaintext

    PromptForShiftValue:
        .asciz  "Please enter the shift value: "
        lenPromptForShiftValue = .-PromptForShiftValue

    Newline:
        .asciz  "\n"

    ShiftValue:
        .int    0
.bss
    .comm   buffer, 102     # Buffer to read in plaintext/output ciphertext
    .comm   intBuffer, 4    # Buffer to read in shift value
                            # (assumes value is 3 digits or less)

.text

    .globl _start

    .type PrintFunction, @function
    .type ReadFromStdin, @function
    .type GetStringLength, @function
    .type AtoI, @function
    .type CaesarCipher, @function


    PrintFunction:
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        # Write syscall
        movl $4, %eax           # syscall number for write()
        movl $1, %ebx           # file descriptor for stdout
        movl 8(%ebp), %ecx      # Address of string to write
        movl 12(%ebp), %edx     # number of bytes to write
        int $0x80

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return

    ReadFromStdin:
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        # Read syscall
        movl $3, %eax
        movl $0, %ebx
        movl 8(%ebp), %ecx      # address of buffer to write input to
        movl 12(%ebp), %edx     # number of bytes to write
        int  $0x80

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return


    GetStringLength:

        # Strings which are read through stdin will end with a newline character. (0xa)
        # So look through the string until we find the newline and keep a count
        pushl %ebp              # store the current value of EBP on the stack
        movl %esp, %ebp         # Make EBP point to top of stack

        movl 8(%ebp), %esi      # Store the address of the source string in esi
        xor %edx, %edx          # edx = 0

        Count:
			inc %edx            # increment edx
            lodsb               # load the first character into eax
            cmp $0xa, %eax  	# compare the newline character vs eax
            jnz Count           # If eax != newline, loop back

        dec %edx                # the loop adds an extra one onto edx
        movl %edx, %eax          # return value

        movl %ebp, %esp         # Restore the old value of ESP
        popl %ebp               # Restore the old value of EBP
        ret                     # return


    
    AtoI:
    
    #
    # Input is always read in as a string. 
    # This function should convert a string to an integer.
    #
        pushl %ebp                 #stores current value of ebp on time of stack
        movl %esp, %ebp            #Makes EBP point to top of stack
        movl 8(%esp), %esi         #puts the string address on top of the stack
                           
        
        





    CaesarCipher:
        call GetStringLength            # Gets the length of the complete string
        movl %eax, %ecx                 # Puts the string length in the count register 
        movl  %ecx, %ecx                 # sets counter to 0
        movl %edx , %ebx                #puts the shift value in edx


        Conversion:
             lodsb                  #loads first byte in to eax
             jae $65, %esi Upper    #if the value is greater than 65(the ASCII value of 'A' jump to Lower)
             jmp Exit               #Exit the function and return the character if it's not a letter

            Upper:
                ja $0x5a, %eax, Upper   #if the value is greater than ACII value of 'Z' then go to the Lower Section
                idiv $0x1a,%edx        #divides the ASCII value by 26 to get true shift distance and stores the remainder in edx
                add  %eax, $edx        #performs the shift
                ja $0x5a, %eax , UpperWrap         
                UpperWrap:
                    subi $0x1a,%eax    # IF shift will bring the balue beyond 'Z' wrap around
                jmp Exit               #Exit the function

            Lower:
                ja $0x7a, %eax, Exit   #if the value is greater than ACII value of 'z' then exit the loop 
                idiv $0x1a,%edx        #divides the ASCII value by 26 to get true shift distance and stores the remainder in edx
                add  %eax, $edx        #performs the shift
                ja $0x7a, %eax , LowerWrap         

                LowerWrap:
                    subi $0x1a,%eax    # IF shift will bring the balue beyond 'Z' wrap around
                jmp Exit               #move to exit the function
    
            Exit:
                movl %ebp, %esp         # Restore the old value of ESP
                popl %ebp               # Restore the old value of EBP
                ret                     # return
        loop Conversion





#########################################FINishh###############################



    _start:

        # Print prompt for plaintext
        pushl   $lenPromptForPlaintext
        pushl   $PromptForPlaintext
        call    PrintFunction
        addl    $8, %esp

        # Read the plaintext from stdin
        pushl   $102
        pushl   $buffer
        call    ReadFromStdin
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp


        # Get input string and adjust the stack pointer back after
        pushl   $lenPromptForShiftValue
        pushl   $PromptForShiftValue
        call    PrintFunction
        addl    $8, %esp

        # Read the shift value from stdin
        pushl   $4
        pushl   $intBuffer
        call    ReadFromStdin
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp



        # Convert the shift value from a string to an integer.
        pushl $intBuffer
        call  AtoI            # expect AtoI to return integer in EAX
        addl  $4, %esp

        # Save the integer shift for later use
        movl  %eax, ShiftValue


        # Perform the caesar cipheR
        # FILL IN HERE


        # Get the size of the ciphertext
        # The ciphertext must be referenced by the 'buffer' label
        pushl   $buffer
        call    GetStringLength
        addl    $4, %esp

        # Print the ciphertext
        pushl   %eax
        pushl   $buffer
        call    PrintFunction
        addl    $8, %esp

        # Print newline
        pushl   $1
        pushl   $Newline
        call    PrintFunction
        addl    $8, %esp

        # Exit the program
        Exit:
            movl    $1, %eax
            movl    $0, %ebx
            int     $0x80