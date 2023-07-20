# IITB-RISC Assember

def parse(code):
    x = code.split(" ")
    b = ""

    # Opcode
    if x[0] == 'add' or x[0] == 'adc' or x[0] == 'adz' or x[0] == 'adl':
        b = b + '0001'
    elif x[0] == 'adi':
        b = b + '0000'
    elif x[0] == 'ndu' or x[0] == 'ndc' or x[0] == 'ndz':
        b = b + '0010'
    elif x[0] == 'lhi':
        b = b + '0011'
    elif x[0] == 'lw':
        b = b + '0100'
    elif x[0] == 'sw':
        b = b + '0101'
    elif x[0] == 'beq':
        b = b + '1000'
    elif x[0] == 'jal':
        b = b + '1001'
    elif x[0] == 'jlr':
        b = b + '1010'
    elif x[0] == 'jri':
        b = b + '1011'

    # First register
    if x[1] == 'r0':
        b = b + '000'
    elif x[1] == 'r1':
        b = b + '001'
    elif x[1] == 'r2':
        b = b + '010'
    elif x[1] == 'r3':
        b = b + '011'
    elif x[1] == 'r4':
        b = b + '100'
    elif x[1] == 'r5':
        b = b + '101'
    elif x[1] == 'r6':
        b = b + '110'
    else:
        b = b + '111'

    # Second register
    if (x[0] == 'add' or x[0] == 'adc' or x[0] == 'adz' or x[0] == 'adl' or
        x[0] == 'ndu' or x[0] == 'ndc' or x[0] == 'ndu' or x[0] == 'adi' or
        x[0] == 'lw' or x[0] == 'sw' or x[0] == 'beq' or x[0] == 'jlr'):
        if x[2] == 'r0':
            b = b + '000'
        elif x[2] == 'r1':
            b = b + '001'
        elif x[2] == 'r2':
            b = b + '010'
        elif x[2] == 'r3':
            b = b + '011'
        elif x[2] == 'r4':
            b = b + '100'
        elif x[2] == 'r5':
            b = b + '101'
        elif x[2] == 'r6':
            b = b + '110'
        else:
            b = b + '111'

    # Third register + extra bits
    if (x[0] == 'add' or x[0] == 'adc' or x[0] == 'adz' or x[0] == 'adl' or
        x[0] == 'ndu' or x[0] == 'ndc' or x[0] == 'ndu'):
        if x[3] == 'r0':
            b = b + '000'
        elif x[3] == 'r1':
            b = b + '001'
        elif x[3] == 'r2':
            b = b + '010'
        elif x[3] == 'r3':
            b = b + '011'
        elif x[3] == 'r4':
            b = b + '100'
        elif x[3] == 'r5':
            b = b + '101'
        elif x[3] == 'r6':
            b = b + '110'
        else:
            b = b + '111'
            
        if x[0] == 'adc' or x[0] == 'ndc':
            b = b + '010'
        elif x[0] == 'adz' or x[0] == 'ndz':
            b = b + '001'
        elif x[0] == 'adl':
            b = b + '011'
        else:
            b = b + '000'

    if (x[0] == 'adi' or x[0] == 'lw' or x[0] == 'sw' or x[0] == 'beq' or x[0] == 'jlr'):
        b = b + '{:06b}'.format(int(x[3]))

    if (x[0] == 'lhi' or x[0] == 'jri' or x[0] == 'jal'):
        b = b + '{:09b}'.format(int(x[2]))

    return b


file = open('assembly_code.txt', 'r')
instructions = file.readlines()

i = 0
for line in instructions:
    code = line.strip()
    b = parse(code)
    print('rom['+str(i)+"] = 16'b" + b + ';')
    i = i + 1

'''for j in range(i,64,1):
    print('rom['+str(i)+"] = 16'b0000000000000000;")'''
