    .extern link_gpio_set_dir
    .extern gpio_init
   
    .EQU SIO_BASE, 0xD0000000 @ Base address for SIO registers
    .EQU GPIO_IN, SIO_BASE + 0x004 @ GPIO input register address
    .EQU GPIO_OUT_SET, SIO_BASE + 0x014 @ GPIO output set register address
    .EQU GPIO_OUT_CLR, SIO_BASE + 0x018 @ GPIO output clear register address

    .EQU LED_PIN_1, 0 @ GPIO pin number for LED 1
    .EQU LED_PIN_2, 1 @ GPIO pin number for LED 2
    
    .EQU LED_MASK, (1 << LED_PIN_1) | (1 << LED_PIN_2) @ Bit mask for both LEDs

    .EQU BUTTON_PIN_1, 3 @ GPIO pin number for Button 1
    .EQU BUTTON_PIN_2, 4 @ GPIO pin number for Button 2

    .EQU BUTTON_1_BIT, (1 << BUTTON_PIN_1) @ Bit mask for Button 1
    .EQU BUTTON_2_BIT, (1 << BUTTON_PIN_2) @ Bit mask for Button 2

    .EQU GPIO_OUT, 1   @ GPIO direction output

    .thumb_func               @ Necessary because sdk uses BLX
    .global main              @ Provide program starting address to linker
main:
    BL stdio_init_all     @ initialize uart or usb
    
    @ Initializing LEDs and buttons
    MOV R0, #LED_PIN_1
    BL gpio_init
    MOV R0, #LED_PIN_1
    MOV R1, #GPIO_OUT
    BL link_gpio_set_dir

    MOV R0, #LED_PIN_2
    BL gpio_init
    MOV R0, #LED_PIN_2
    MOV R1, #GPIO_OUT
    BL link_gpio_set_dir

    MOV R0, #BUTTON_PIN_1
    BL gpio_init
    MOV R0, #BUTTON_PIN_1
    MOV R1, #0          @ Set as input
    BL link_gpio_set_dir

    MOV R0, #BUTTON_PIN_2
    BL gpio_init
    MOV R0, #BUTTON_PIN_2
    MOV R1, #0          @ Set as input
    BL link_gpio_set_dir
   
@ Main loop that constantly checks button states
loop:
    LDR R1, =GPIO_IN @ Load GPIO input register address
    LDR R0, [R1] @ Load GPIO register block base address
    
    MOV R2, #BUTTON_1_BIT @ Load button 1 bit mask
    TST R0, R2 @ Check if button 1 is pressed
    BNE button_1_pressed @ If pressed, branch to button_1_pressed

    MOV R2, #BUTTON_2_BIT @ Load button 2 bit mask
    TST R0, R2 @ Check if button 2 is pressed
    BNE button_2_pressed @ If pressed, branch to button_2_pressed

    B loop @ Repeat the loop

button_1_pressed:
    LDR R1, =GPIO_OUT_SET @ Load GPIO output set register address
    MOV R0, #LED_MASK @ Prepare mask for both LEDs
    STR R0, [R1] @ Turn on both LEDs
    B loop @ Repeat the loop

button_2_pressed:
    LDR R1, =GPIO_OUT_CLR @ Load GPIO output clear register address
    MOV R0, #LED_MASK @ Prepare mask for both LEDs
    STR R0, [R1] @ Turn off both LEDs
    B loop @ Repeat the loop

.data
    .align 4              @ necessary alignment