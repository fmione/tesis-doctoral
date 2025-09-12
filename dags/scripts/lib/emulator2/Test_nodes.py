import time
import Node_run_emulator
import Node_start_emulator
# %%
# runfile('Node_start_emulator.py')
Node_start_emulator.start_emu()
while 1:
    acc_factor=1*1
    # time.sleep(3600/4)
    # runfile('Node_run_emulator.py')
    Node_run_emulator.run_emu()
    print('PING')
    
    time.sleep(3600/acc_factor/24) #run every 2.5 min (1/24)
