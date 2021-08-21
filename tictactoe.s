# Program that plays a game of tic-tac-toe, entirely in MIPS assembly.
# Mitchell Merry, 2021

    .data
    .align 2
board: # 2d 3x3 array containing -1, 0, or 1
    .space 36                
    # .word 1, -1, 0, -1, 1, -1, 1, -1, 1

# Board print strings
row_sep: .asciiz "---+---+---\n"
X: .asciiz "X"
O: .asciiz "O"

# Console messages
init_message: .asciiz "Game initialised.\n"
row_prompt: .asciiz "Row (0-2): "
column_prompt: .asciiz "Column (0-2): "
header_msg_1: .asciiz "\n==Player "
header_msg_2: .asciiz "'s turn==\n"
set_cell_occupied: .asciiz "Cell already occupied.\n"
win_msg_1: .asciiz "\nPlayer "
win_msg_2: .asciiz " has won!\n"
draw_msg: .asciiz "\nThe game was a tie.\n"

    .text
    .globl main
main:
    # Push values onto the stack
    addi $sp, $sp, -32          # main
    sw $s4, 28($sp)             # win check
    sw $s3, 24($sp)             # used to store current turn (1/-1)
    sw $s2, 20($sp)             # used to store column user input
    sw $s1, 16($sp)             # used to store row user input
    sw $s0, 12($sp)             # game_loop counter (turn)
    sw $a1, 8($sp)              # used for argument passing
    sw $a0, 4($sp)              # used for syscalls
    sw $ra, 0($sp)

    # Initialise the game
    jal init
    nop

    # Main loop of the game. Loops over turns until max turn is reached (0-8).
    # Even turns represent player X (1), odd turns represent player O (-1)
game_loop:
    # Get turn (1 or -1)
    move $a0, $s0               # pass current turn of the board        
    jal get_turn                # into get_turn
    nop
    move $s3, $v0

    # Print the header.
    move $a0, $s3               # pass in the current player
    jal print_header            # print message
    nop

    # Print the board to show the current state of the board on each turn.
    jal print_board
    nop

    # Get values for row and column from user:
gl_get_inputs:
    # Pass arguments to read_int_between
    li $a0, 0                   # minimum value to read is 0
    li $a1, 2                   # maximum value to read is 2

    la $a2, row_prompt          # Get row from user
    jal read_int_between        
    nop 
    move $s1, $v0               # store row in $s1
    
    la $a2, column_prompt       # Get column from user
    jal read_int_between        
    nop
    move $s2, $v0               # store column in $s2

    # Set the cell value at (row, column) to the current player
    move $a0, $s1               # pass row
    move $a1, $s2               # pass column
    move $a2, $s3               # pass turn
    jal set_cell
    nop

    bne $v0, $0, gl_get_inputs  # if the cell was occupied (returned a non-zero error code), get inputs again

    # check for win!
    move $a0, $s3               # pass in the current player
    jal check_win
    nop
    bne $v0, $0, __gl_win       # if true, jump out of the loop and print win message

    li $t0, 9                   # board turn limit
    addi $s0, $s0, 1            # increment board turn counter
    bne $s0, $t0, game_loop     # loop if board turn limit not reached
    
## End loop - draw state

    li $v0, 4                   # syscall code for print_str
    la $a0, draw_msg            # result was a draw
    syscall
    j __m_exit

__gl_win:

    # a player won! ($s3)
    li $v0, 4                   # syscall code for print_str
    la $a0, win_msg_1           # print first half of win message
    syscall

    move $a0, $s3               # pass in the turn
    jal print_char              # print the char of the player who won
    nop

    li $v0, 4
    la $a0, win_msg_2           # pass in the second half
    syscall

__m_exit:
    jal print_board
    nop

    j exit_program              # exit program

# init: Initalises program registers and values to an empty game of
#       tic-tac-toe at turn 0.
# Precondition: None
# Postcondition:
#   Board Turn -    $s0 = 0
#   Win check  -    $s4 = 0
init:
    li $s0, 0                   # Initialise board-turn to 0
    li $s0, 0                   # Initialise win-check to 0

    # Print completed initialisation message
    li $v0, 4                   # syscall code for print_str
    la $a0, init_message        # pass init message
    syscall

    jr $ra

# get_turn: Returns the current player to move. If the board turn is even,
#           return 1 (player 1), if it's odd, return -1 (player 2)
# Precondition:     $a0 - board turn (0-8)
# Postcondition:    $v0 - current turn (1 or -1)
get_turn:
    # Determine if odd or even
    li $t0, 2                   # get_turn
    div $a0, $t0                # divide turn by 2
    mfhi $t0                    # get remainder

    # If remainder is 0, return 1, else return -1
    li $v0, 1                   # return 1
    beq $t0, $0, __gt_ret       # if remainder == 0 return
    li $v0, -1                  # return -1

__gt_ret:
    jr $ra

# get_cell: Returns the value stored in the given row / column in the board.
# Precondition:     $a0 - row
#                   $a1 - column
# Postcondition:    $v0 - value at board[row][column] (-1, 0, or 1)
get_cell:
    la $t1, board               # Load the base address of board
    
    # board[row][column] is stored at:
    # board + row*3*4 + column*4
    li $t2, 0
    add $t2, $a0, $a0           # 2*row
    add $t2, $t2, $a0           # 3*row
    add $t2, $t2, $t2           # 3*2*row
    add $t2, $t2, $t2           # 3*4*row

    add $t3, $a1, $a1           # 2*column
    add $t3, $t3, $t3           # 4*column

    add $t2, $t2, $t3           # 3*4*row + 4*column
    add $t1, $t1, $t2           # board + 3*4*row + 4*column
                                # the address of the element in the board.
    
    lw $v0, 0($t1)              # Load the value at the calculated address into
                                # the return argument

    jr $ra

# set_cell: Sets the value of the cell at row,column to value.
# Precondition:     $a0 - row
#                   $a1 - column
#                   $a2 - value
# Postcondition:    $v0 - error code 1 if cell is occupied, 0 if success
set_cell:
    # Push values onto the stack
    addi $sp, $sp, -4           # set_cell
    sw $a0, 0($sp)              # syscalls

    la $t1, board               # Load the base address of board
    
    # board[row][column] is stored at:
    # board + row*3*4 + column*4
    li $t2, 0
    add $t2, $a0, $a0           # 2*row
    add $t2, $t2, $a0           # 3*row
    add $t2, $t2, $t2           # 3*2*row
    add $t2, $t2, $t2           # 3*4*row

    add $t3, $a1, $a1           # 2*column
    add $t3, $t3, $t3           # 4*column

    add $t2, $t2, $t3           # 3*4*row + 4*column
    add $t1, $t1, $t2           # board + 3*4*row + 4*column
                                # the address of the element in the board.
    
    # Check if cell occupied
    lw $t0, 0($t1)              # get value in cell
    bne $t0, $0, __sc_err       # if the cell is not empty (i.e. occupied), throw error

    # Otherwise, set as normal
    li $v0, 0                   # no error
    sw $a2, 0($t1)              # Store the value in the calculated address
    j __sc_exit                 # return

    # If the cell is occupied
__sc_err:
    li $v0, 4                   # syscall code for print_str
    la $a0, set_cell_occupied   # print error message that the cell is occupied
    syscall

    li $v0, 1                   # return error code 1

__sc_exit:
    # Push values onto the stack
    lw $a0, 0($sp)              
    addi $sp, $sp, 4           

    jr $ra

# check_win: Checks if the given player has a win on the board.
# Precondition:     $a0 - player's value (1 or -1)
# Postcondition:    $v0 - 0 if no win, 1 if win
check_win:
    # Push values onto the stack
    addi $sp, $sp, -16          # check_win
    sw $s0, 12($sp)             # loop counter
    sw $a1, 8($sp)              # used to pass to check_win_row and column
    sw $a0, 4($sp)              # used for syscalls
    sw $ra, 0($sp)

    ## TODO update stack

    ## ROWS
    li $s0, 0                   # initialise as a row counter
__cw_rows:
                                # pass player to check_win_row
    move $a1, $s0               # pass current row to check_win_row
    jal check_win_row           # check if win in row
    nop
    bne $v0, $0, __cw_ret       # if the function returned a non-zero value, interpret as true and return (true)

    li $t0, 3                   # max loop count
    addi $s0, $s0, 1            # i++
    bne $s0, $t0, __cw_rows     # loop if not at max

    ## end __cw_rows loop

    ## COLUMNS - identical to rows loop.
    li $s0, 0                   # initialise as a column counter
__cw_columns:
                                # pass player to check_win_column
    move $a1, $s0               # pass current column to check_win_column
    jal check_win_column        # check if win in column
    nop
    bne $v0, $0, __cw_ret       # if the function returned a non-zero value, interpret as true and return (true)

    li $t0, 3                   # max loop count
    addi $s0, $s0, 1            # i++
    bne $s0, $t0, __cw_columns  # loop if not at max

    ## DIAGONALS
    addi $a1, $0, 1             # pass diagonal direction 1 to check_win_diag
    jal check_win_diag
    nop
    bne $v0, $0, __cw_ret       # if the function returned a non-zero value, interpret as true and return (true)

    addi $a1, $0, -1            # pass diagonal direction -1 to check_win_diag
    jal check_win_diag
    nop
    bne $v0, $0, __cw_ret       # if the function returned a non-zero value, interpret as true and return (true)

    li $v0, 0                   # if no win was found, return false

__cw_ret:
    # Pop values off the stack and restore
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a0, 8($sp)
    lw $s0, 12($sp)
    addi $sp, $sp, 16

    jr $ra

# check_win_row: Checks if the given player has a win in the given row.
# Precondition:     $a0 - player's value (1 or -1)
#                   $a1 - row index (0-2)
# Postcondition:    $v0 - 0 if no win, 1 if win
check_win_row:
    # Push values onto the stack
    addi $sp, $sp, -28          # check_win_row
    sw $a1, 24($sp)             # used to pass in column to get_cell
    sw $a0, 20($sp)             # used to pass in row to get_cell
    sw $s3, 16($sp)             # stores current return value
    sw $s2, 12($sp)             # stores the passed row
    sw $s1, 8($sp)              # stores player value
    sw $s0, 4($sp)              # loop counter
    sw $ra, 0($sp)

    li $s0, 0                   # initialise cell counter to 0
    move $s1, $a0               # store player value
    move $s2, $a1               # store passed row
    li $s3, 0                   # by default, return 0

__cwr_cells:
    move $a0, $s2               # pass row to get_cell
    move $a1, $s0               # pass current column to get_cell
    jal get_cell                # get value at cell
    nop
    bne $v0, $s1, __cwr_ret     # if not equal to player value, it's not a win - return (false)

    li $t0, 3                   # max loop count
    addi $s0, $s0, 1            # i++
    bne $s0, $t0, __cwr_cells   # loop if not at max

    li $s3, 1                   # if it made it here, it was a win (all cells equal to player value)

__cwr_ret:
    move $v0, $s3

    # Pop values off the stack and restore
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $a0, 20($sp)
    lw $a1, 24($sp)
    addi $sp, $sp, 28

    jr $ra

# check_win: Checks if the given player has a win in the given row.
# Precondition:     $a0 - player's value (1 or -1)
#                   $a1 - column index (0-2)
# Postcondition:    $v0 - 0 if no win, 1 if win
check_win_column:
    # Push values onto the stack
    addi $sp, $sp, -28          # check_win_column
    sw $a1, 24($sp)             # used to pass in column to get_cell
    sw $a0, 20($sp)             # used to pass in row to get_cell
    sw $s3, 16($sp)             # stores current return value
    sw $s2, 12($sp)             # stores the passed column
    sw $s1, 8($sp)              # stores player value
    sw $s0, 4($sp)              # loop counter
    sw $ra, 0($sp)

    li $s0, 0                   # initialise cell counter to 0
    move $s1, $a0               # store player value
    move $s2, $a1               # store passed column
    li $s3, 0                   # by default, return 0

__cwc_cells:
    move $a0, $s0               # pass current row to get_cell
    move $a1, $s2               # pass column to get_cell
    jal get_cell                # get value at cell
    nop
    bne $v0, $s1, __cwc_ret     # if not equal to player value, it's not a win - return (false)

    li $t0, 3                   # max loop count
    addi $s0, $s0, 1            # i++
    bne $s0, $t0, __cwc_cells   # loop if not at max

    li $s3, 1                   # if it made it here, it was a win (all cells equal to player value)

__cwc_ret:
    move $v0, $s3

    # Pop values off the stack and restore
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $a0, 20($sp)
    lw $a1, 24($sp)
    addi $sp, $sp, 28

    jr $ra

# check_win_diag: Checks a win in the given diagonal
# Precondition:     $a0 - player value (1 or -1)
#                   $a1 - direction of diagonal (1 for left-right, -1 for right-left)
# Postcondition:    $v0 - 0 if no win, 1 if win
check_win_diag:
    # Push values onto the stack
    addi $sp, $sp, -32          # check_win_diag
    sw $a1, 28($sp)             # used to pass in column to get_cell
    sw $a0, 24($sp)             # used to pass in row to get_cell
    sw $s4, 20($sp)             # stores current return value
    sw $s3, 16($sp)             # stores the diag direction
    sw $s2, 12($sp)             # stores the player value
    sw $s1, 8($sp)              # stores the current column
    sw $s0, 4($sp)              # loop counter (current row)
    sw $ra, 0($sp)

    li $s0, 0                   # initialise row counter to 0
    move $s2, $a0               # store player value
    move $s3, $a1               # store diag direction
    li $s4, 0                   # by default, return 0

    li $s1, 0                   # initialise column counter
    li $t0, 1                   
    beq $t0, $a1, __cwd_cells    # if direction is 1, column counter to 0
    li $s1, 2                   # otherwise column counter to 2

__cwd_cells:
    move $a0, $s0               # pass current counter to get_cell as row
    move $a1, $s1               # pass column to get_cell
    jal get_cell                # get value at cell
    nop
    bne $v0, $s2, __cwd_ret     # if not equal to player value, it's not a win - return (false)

    li $t0, 3                   # max loop count
    addi $s0, $s0, 1            # i++
    add $s1, $s1, $s3           # move the column counter in the given direction
    bne $s0, $t0, __cwd_cells   # loop if not at max

    li $s4, 1                   # if it made it here, it was a win (all cells equal to player value)

__cwd_ret:
    move $v0, $s4

    # Pop values off the stack and restore
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $a0, 24($sp)
    lw $a1, 28($sp)
    addi $sp, $sp, 32

    jr $ra

# print_board: Prints an ASCII representation of the current board state to the console.
# 1 is X, -1 is O, and 0 is a blank space
# Precondition / Postcondition: None
# Example for board state "00000001 ffffffff 00000000 ffffffff 00000001 ffffffff 00000001 ffffffff 00000001":
#  X | O |  
# ---+---+---
#  O | X | O  
# ---+---+---
#  X | O | X 
print_board:
    # Push values onto the stack
    addi $sp, $sp, -12          # print_board
    sw $s0, 8($sp)              # __pb_loop counter (row)
    sw $a0, 4($sp)              # used for syscalls
    sw $ra, 0($sp)

    # Loops over each row.
    li $s0, 0                   # instantiate counter to 0 (corresponds to current row)
__pb_loop:
    # Print row
    move $a0, $s0               # pass row to print_row
    jal print_row
    nop

    # Print row separator only if this isn't the last iteration
    li $t0, 2                   # max iteration
    beq $s0, $t0, __pb_l_end    # if counter == 2, exit loop
    
    # otherwise, print row separator and loop
    li $v0, 4                   # syscall code for print_str
    la $a0, row_sep             # pass the row separator string
    syscall

    addi $s0, $s0, 1            # increment loop counter by 1
    j __pb_loop                 # loop

    ## End loop
__pb_l_end:
    # Pop values off the stack
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $s0, 8($sp)                 
    addi $sp, $sp, 12

    jr $ra

# print_row: Prints an ASCII representation of the corresponding row state to the console.
# 1 is X, -1 is O, and 0 is a blank space
# Precondition:         $a0 - row
# Postcondition: None
# Example for board state "00000001 ffffffff 00000000 ffffffff 00000001 ffffffff 00000001 ffffffff 00000001"
# and printing row 0:
# " X | O |   "
print_row:
    # Push to the stack:
    addi $sp, $sp, -20          # print_row
    sw $s1, 16($sp)             # carries the row
    sw $s0, 12($sp)             # __pr_loop counter
    sw $a1, 8($sp)              # used to pass column to print_cell
    sw $a0, 4($sp)              # used for syscalls, and to pass row to print_cell
    sw $ra, 0($sp)              
    
    move $s1, $a0               # store row in $s1 for later use ($a0 gets overwritten)

    # Loops over each column (corresponding to cell)
    li $s0, 0                   # instantiate loop counter
__pr_loop:
    # Print the cell character
    move $a0, $s1               # pass row to get_cell
    move $a1, $s0               # pass column to get_cell
    jal get_cell                # get the value
    nop

    move $a0, $v0               # pass the value into print_cell
    jal print_cell              # print
    nop

    # Print character
    # for 0,1 print |, for 2 print \n
    li $a0, 0xa                 # pass the linefeed character ('\n', 0xa)
    li $t0, 2                   
    beq $s0, $t0, __pr_pc       # if counter == 2, print \n

    li $a0, 0x7c                # otherwise, print the bar character ('|', 0x7c)

__pr_pc:                        # print character
    li $v0, 11                  # syscall code for print_char
    syscall

    addi $s0, $s0, 1            # increment loop counter by 1
    li $t0, 3                   # max loop is 3
    bne $s0, $t0, __pr_loop     # loop if not at max

    ## End loop

    # Pop off the stack and restore values
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $s0, 12($sp)   
    lw $s1, 16($sp)   
    addi $sp, $sp, 20

    jr $ra

# print_cell: Prints an ASCII representation of a cell value to the console.
# 1 is X, -1 is O, and 0 is a blank space
# Precondition:         $a0 - value of cell
# Postcondition: None
print_cell:
    # Push onto the stack
    addi $sp, $sp, -12          # print_cell
    sw $s0, 8($sp)              # used to store the value of the cell ($a0)
    sw $a0, 4($sp)              # used for syscalls
    sw $ra, 0($sp)
    
    move $s0, $a0               # store value for later

    # print a space character
    li $v0, 11                  # syscall code for print_char
    li $a0, 0x20                # hex code for space (0x20)
    syscall

    # Print the tile
    move $a0, $s0               # pass in the value of the cell
    jal print_char
    nop

    # print another space
    li $v0, 11                  # syscall code for print_char
    li $a0, 0x20                # hex code for space (0x20)
    syscall

    # Pop off the stack
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $s0, 8($sp)
    addi $sp, $sp, 12

    jr $ra

# print_header: Prints "==Player X's turn==\n"
# Precondition:     $a0 - current turn (1 or -1)
# Postcondition:    None
print_header:
    # Push onto the stack
    addi $sp, $sp, -12          # print_header
    sw $s0, 8($sp)              # stores the turn
    sw $a0, 4($sp)              # used for syscalls
    sw $ra, 0($sp)              

    move $s0, $a0               # store the turn

    li $v0, 4                   # syscall code for print_str
    la $a0, header_msg_1        # first half of the header message
    syscall

    # Print the player
    move $a0, $s0               # pass in the turn
    jal print_char
    nop

    li $v0, 4                   # syscall code for print_str
    la $a0, header_msg_2        # second half of the header message
    syscall

    # Pop values off the stack and restore
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $s0, 8($sp)
    addi $sp, $sp, 12
    
    jr $ra

# print_char: Prints X, O, or a space depending on input
# Precondition:     $a0 - current turn (1, 0, or -1)
# Postconditrion:   None
print_char:
    # Push onto the stack
    addi $sp, $sp, -8           # print_char
    sw $s0, 4($sp)              # used to store the value of the cell ($a0)
    sw $a0, 0($sp)              # used for syscalls

    li $v0, 4                   # syscall code for print_str
    move $s0, $a0

    li $t0, 1
    la $a0, X                   # if the value is 1, print X
    beq $s0, $t0, __pc_print    # true -> print

    li $t0, -1
    la $a0, O                   # if the value is -1, print O
    beq $s0, $t0, __pc_print

    li $v0, 11                  # syscall code for print_char
    la $a0, 0x20                # otherwise print out a space character (0x20)
__pc_print:
    syscall

    # Pop off the stack
    lw $a0, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8

    jr $ra

# read_int_between: Gets int input from the user between a range [$a0, $a1].
#                   Prompts until a valid value is entered.
# Precondition:     $a0 - minimum value
#                   $a1 - maximum value
#                   $a2 - prompt string (address)
# Postcondition:    $v0 - value from the user
read_int_between:
    # Push onto the stack
    addi $sp, $sp, -20          # read_int_between
    sw $s0, 16($sp)             # used to store minimum val
    sw $a2, 12($sp)             # used to pass value to is_between
    sw $a0, 8($sp)              # used for syscalls
    sw $s1, 4($sp)              # used to store prompt address
    sw $ra, 0($sp)              

    move $s0, $a0
    move $s2, $a2

rib_loop:
    li $v0, 4                   # syscall code for print_string
    move $a0, $s2               # print the prompt
    syscall

    li $v0, 5                   # syscall code for read_int
    syscall                     # take in the value of N to $v0

    move $a0, $s0               # pass in minimum to is_between
    move $a2, $v0               # pass value to is_between (maximum is already passed)
    jal is_between
    nop
    beq $v0, $0, rib_loop       # loop if not between (returns false)
    move $v0, $a2               # return succesful value
    
    # Pop values off the stack and restore
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $a0, 8($sp)
    lw $a2, 12($sp)
    lw $s0, 16($sp)
    addi $sp, $sp, 20
    
    jr $ra
    
# is_between: Returns true/false depending on if $a2 is between the range [$a0, $a1].
#                   Prompts until a valid value is entered.
# Precondition:     $a0 - minimum value
#                   $a1 - maximum value
#                   $a2 - value
# Postcondition:    $v0 - value from the user
is_between:
    sle $t2, $a0, $a2           # minimum <= N
    sle $t3, $a2, $a1           # N <= maximum

    li $v0, 1
    beq $t2, $t3, __ib_ret      # if both are true, return true. otherwise return false.
    li $v0, 0                   # they cannot be simultaneously false, so $t2==$t3 suffices
__ib_ret:
    jr $ra

# Exits the program - usual stuff
exit_program:
    # Pop values off the stack and restore
    lw $ra, 0($sp)
    lw $a0, 4($sp)              
    lw $a1, 8($sp)              
    lw $s0, 12($sp)             
    lw $s1, 16($sp)            
    lw $s2, 20($sp)             
    lw $s3, 24($sp)            
    lw $s4, 28($sp)             
    addi $sp, $sp, 32

    jr $ra
    nop