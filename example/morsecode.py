#!/usr/bin/python
# coding: ISO-8859-15

import sys
import random

from gpiozero import LEDBoard
from gpiozero import LED
from time import sleep

CODE = {' ': ' ',
        "'": '.----.',
        '(': '-.--.-',
        ')': '-.--.-',
        ',': '--..--',
        '-': '-....-',
        '.': '.-.-.-',
        '/': '-..-.',
        '0': '-----',
        '1': '.----',
        '2': '..---',
        '3': '...--',
        '4': '....-',
        '5': '.....',
        '6': '-....',
        '7': '--...',
        '8': '---..',
        '9': '----.',
        ':': '---...',
        ';': '-.-.-.',
        '?': '..--..',
        'A': '.-',
        'B': '-...',
        'C': '-.-.',
        'D': '-..',
        'E': '.',
        'F': '..-.',
        'G': '--.',
        'H': '....',
        'I': '..',
        'J': '.---',
        'K': '-.-',
        'L': '.-..',
        'M': '--',
        'N': '-.',
        'O': '---',
        'P': '.--.',
        'Q': '--.-',
        'R': '.-.',
        'S': '...',
        'T': '-',
        'U': '..-',
        'V': '...-',
        'W': '.--',
        'X': '-..-',
        'Y': '-.--',
        'Z': '--..',
        '_': '..--.-'}

led = LED(2)
led.off()

def dot():
    led.on()
    sleep(0.2)
    led.off()
    sleep(0.2)

def dash():
    led.on()
    sleep(0.5)
    led.off()
    sleep(0.2)


treelights=[ 18, 5, 9, 11, 21, 10, 7, 12, 6, 1,14, 3, 20, 24, 13, 15,2, 17, 16, 23,8, 22, 4, 19 ] 
treemap={ 1:4, 7:5, 16:6, 22:7, 6:8 , 14:9, 8:10, 21:11, 15:12, 3:13, 19:14, 2:15, 9:16, 10:17, 20:18, 18:19,17:20, 4:21, 24:22, 23:23, 13: 
24, 5:25, 12:26, 11:27 
} 

leds=LEDBoard(*range(4,28), pwm=True) 

def labelToPin(l): 
  return treemap[l] 

def toBoard(l): 
  return labelToPin(l)-4 

# light up some random candles
for i in treelights: 
#    sleep(0.4) 
    if random.randint(0,1) > 0:
        leds.on(toBoard(i))
    else:
        leds.off(toBoard(i))

# we want two command line arguments
if len(sys.argv) == 3:
    s=sys.argv[1] + ' "'
    input = sys.argv[2]
    for letter in input:
            if not letter.upper() in CODE:
                ltr = '?'
            else:
                ltr = letter
            for symbol in CODE[ltr.upper()]:
                s+=symbol
                if symbol == '-':
                    dash()
                elif symbol == '.':
                    dot()
                else:
                    sleep(0.5)
            sleep(0.5)
            s+=" "
    print s+'"'
