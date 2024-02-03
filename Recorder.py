import time
import struct
import threading
from pynput import keyboard

file = open("music.bin", "ab")
basic_delay = 0.01 # 基础间隔(单位: s)
onpress_key = None
registe_key = ["q", "w", "e", "r", "t", "y", "u", "a", "s", "d", "f", "g", "h", "j", "z", "x", "c", "v", "b", "n", "m"] # 有意义的按键 其实就是键盘三行的前七个字母和结束按键
frequen_tab = {"z":138, "x":147, "c":165, "v":175, "b":196, "n":220, "m":247,
               "a":262, "s":294, "d":330, "f":349, "g":392, "h":440, "j":494,
               "q":524, "w":587, "e":659, "r":698, "t":784, "y":880, "u":988,
               "o":56797, "p":43690} # 音符频率对照表

def delay():
    global file
    global onpress_key
    try:
        while True:
            if onpress_key in registe_key:
                file.write(struct.pack("<H", frequen_tab[onpress_key])) 
            else:
                file.write(struct.pack("<H", frequen_tab["o"]))
            time.sleep(basic_delay)
    except ValueError as e:
        print(e)
        print("May be record was finished")

thread = threading.Thread(target=delay)
thread.start()

def on_press(key):
    global file
    global onpress_key
    try:
        if key == keyboard.Key.esc: # 按了esc
            file.write(struct.pack("<H", frequen_tab["p"])) # 最终结束符
            file.close()
            return False # 退出监听器 
        elif key.char in registe_key:
            onpress_key = key.char # 取该按键对应的字符
    except AttributeError:
        pass
        
def on_release(key):
    global onpress_key
    onpress_key = None

with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join() # 应该是在单独的一个线程的监听器
