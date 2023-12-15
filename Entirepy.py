#generates the GUI to select the parameters and based on the inputs, it generates a corresponding lookup table.

import serial
import tkinter as tk

import tkinter as tk
from tkinter import ttk
import time

import math

amplitude = 0

def lutfreq(maxc):
    maxc_bin = (bin(maxc))[2:]
    l = [0,0,0,0]
    bin_rep = ""
    if len(maxc_bin)<32:
        for i in range(32 - len(maxc_bin)):
            bin_rep = bin_rep + "0"
        for i in maxc_bin:
            bin_rep = bin_rep + str(i)
    for j in range(4):
        l[j] = bin_rep[j*8:j*8+8]
    for k in range(len(l)):
        ele = 0
        v = 7
        for u in l[k]:
            ele += (2**v)*int(u)
            v-=1
        l[k] = hex(ele)
    return l



def lutsine(amp):
    # 0 -> 00000000    3.3 -> 11111111 i.e 255
    f = 255/3.3
    l = []
    
    for i in range(24):
        rad = (2*math.pi/24)*i
        temp = 1.65 + amp*math.sin(rad) 
        val = int(temp*f)
        if val>=0 and val<=255:
            hex_rept = (hex(val))
        elif val>255:
            hex_rept = hex(255)
        else:
            hex_rept = '0x00'
        print(val)
        #print(bin(val))
        l.append(hex_rept)
    return l

def sqlut(amp):
    f = 255/3.3
    l = []
    high_amp = 1.65 + amp
    
    for i in range(24):
        if high_amp>3.3 :
            if (i<13):
                l.append('0xff')
            else:
                l.append('0x00')
        else:
            if (i<13):
                print(int((1.65 + amp)*f))
                ele = hex(int((1.65 + amp)*f))
            else:
                ele = hex(int((1.65 - amp)*f))
                print(int((1.65 - amp)*f))
            l.append(ele)
        #print(ele)
    return l

def ramplut(amp):
    l = []
    f = 255/3.3
    for i in range(24):
        ele = int((i*amp/24)*f)
        if ele>255:
            l.append('0xff')
        else:
            l.append(hex(ele))
        print(ele)
    return l

def trilut(amp):
    l = []
    f = 255/3.3
    for i in range(24):
        if i<6 :
            ele = int((1.65 + i*(amp/6))*f)
        elif i<18 :
            peak = 1.65 + amp
            ele = int((peak - (i-6)*(amp)/6)*f)
        else:
            valley = 1.65 - amp
            ele = int((valley + (i-18)*(amp)/6)*f)
        l.append(hex(ele))
        print(ele)
    return l


def get_inputs():
    global amplitude, wave, frequency
    wave = selected_option.get()
    amplitude = float(float_input.get())
    frequency = int(int_input.get())
    #result_label.config(text=f"Selected Option: {selected}, Float Value: {float_value}, Integer Value: {int_value}")

# Create the main window
root = tk.Tk()
root.title("Menu")
root.geometry("500x300")  # Set window size

# Create a title label
title_label = ttk.Label(root, text="Parameter selection", font=("Helvetica", 20))
title_label.grid(row=0, column=0, columnspan=2, padx=100, pady=10)

# Create a label for the drop-down menu
label_option = ttk.Label(root, text="Select an option:")
label_option.grid(row=1, column=0, padx=10, pady=10)

# Create a drop-down menu
options = ["Sine wave", "Square wave", "Ramp", "Triangular"]
selected_option = tk.StringVar()
dropdown = ttk.Combobox(root, textvariable=selected_option, values=options)
dropdown.grid(row=1, column=1, padx=10, pady=10)
dropdown.set(options[0])  # Set the default option

# Create a label for float input
label_float = ttk.Label(root, text="Enter the amplitude (0 to 1.65):")
label_float.grid(row=2, column=0, padx=10, pady=10)

# Create an entry box for float input
float_input = tk.Entry(root)
float_input.grid(row=2, column=1, padx=10, pady=10)

# Create a label for integer input
label_int = ttk.Label(root, text="Enter the frequency in hertz:")
label_int.grid(row=3, column=0, padx=10, pady=10)

# Create an entry box for integer input

int_input = tk.Entry(root)
int_input.grid(row=3, column=1, padx=10, pady=10)

# Create a button to submit inputs
submit_button = ttk.Button(root, text="Submit", command= get_inputs )
submit_button.grid(row=4, columnspan=2, padx=10, pady=10)

# Create a button to close
close_button = ttk.Button(root, text = "Close window", command = root.destroy)
close_button.grid(row = 6, columnspan = 2, padx = 10, pady = 10)


# Style the background and colors
root.configure(background="lightblue")
title_label.configure(foreground="blue")
label_option.configure(foreground="green")
label_float.configure(foreground="purple")
label_int.configure(foreground="red")


# Start the GUI event loop
root.mainloop()

print("Amplitude is ", amplitude, "Frequency is ", frequency, "Wave is ", wave, sep = "\n")
print("\n")

if wave == "Sine wave":
    lutamp = lutsine(amplitude)
elif wave == "Square wave":
    lutamp = sqlut(amplitude)
elif wave == "Ramp":
    lutamp = ramplut(amplitude)
elif wave == "Triangular":
    lutamp = trilut(amplitude)

maxcount = int(50000000/(2*frequency))
freq_lut = lutfreq(maxcount)
lut_final = lutamp + freq_lut
print(lut_final)




# Configure the serial port
ser = serial.Serial('COM8',9600)  # Replace 'COM3' with your serial port name
#921600
# List of hexadecimal strings to send
#hex_strings = ['0x3a','0x15']

for hex_string in lut_final:
    # Remove '0x' prefix and convert the hexadecimal string to an integer
    decimal_value = int(hex_string, 16)

    # Convert the integer to bytes
    byte_data = bytes([decimal_value])

    # Send the data
    ser.write(byte_data)

    # Wait for a short delay between sending each data
    time.sleep(0.01)

# Close the serial port
ser.close()
