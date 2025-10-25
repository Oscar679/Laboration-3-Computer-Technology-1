    .extern link_gpio_set_dir
    .extern link_gpio_put
    .extern link_gpio_get
    .extern link_gpio_pull_down
    .extern gpio_init
    .extern sleep_ms
   
    .EQU LED_PIN_1, 0 @ GPIO pin number for LED 1
    .EQU LED_PIN_2, 1 @ GPIO pin number for LED 2
    .EQU BUTTON_PIN_1, 3 @ GPIO pin number for Button 1
    .EQU BUTTON_PIN_2, 4 @ GPIO pin number for Button 2
    .EQU GPIO_OUT, 1   @ GPIO direction output
    .EQU SLEEP_TIME, 100 @ Sleep time in milliseconds

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
    MOV R0, #BUTTON_PIN_1
    BL link_gpio_pull_down @ Enable pull-down resistor

    MOV R0, #BUTTON_PIN_2
    BL gpio_init
    MOV R0, #BUTTON_PIN_2
    MOV R1, #0          @ Set as input
    BL link_gpio_set_dir
    MOV R0, #BUTTON_PIN_2
    BL link_gpio_pull_down @ Enable pull-down resistor

@ Main loop that constantly checks button states
loop:
    MOV R0, #BUTTON_PIN_1
    BL link_gpio_get
    MOV R2, R0 @ Save the result in R2, R0 is overwritten

    MOV R0, #BUTTON_PIN_2
    BL link_gpio_get
    MOV R3, R0 @ Save the result in R3, R0 is overwitten

    @ If button 1 is pressed, turn LEDs on
    CMP R2, #1
    BEQ button_1_pressed

    @ If button 2 is pressed, turns LEDs off
    CMP R3, #1
    BEQ button_2_pressed

    MOV R0, #SLEEP_TIME
    BL sleep_ms         @ Sleep to debounce buttons
    B loop

button_1_pressed:
    MOV R0, #LED_PIN_1
    MOV R1, #1
    BL link_gpio_put
    
    MOV R0, #LED_PIN_2
    MOV R1, #1
    BL link_gpio_put

    B loop

button_2_pressed:
    MOV R0, #LED_PIN_1
    MOV R1, #0
    BL link_gpio_put
    
    MOV R0, #LED_PIN_2
    MOV R1, #0
    BL link_gpio_put

    B loop
.data
    .align 4              @ necessary alignment