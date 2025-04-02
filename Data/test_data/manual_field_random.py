from faker import Faker
from datetime import date
from random import randrange
from random import choice
import string 

fake = Faker()
def readfromfile():
    f = open("C:/Users/niharaze/appium_robot_framework/Cargo_Test_Data.txt", encoding='utf-8-sig', mode='r')
    lines = f.read()
    data_into_lines= lines.split("\n")
    return data_into_lines
data=readfromfile()
print(data)


## generating random name
def generateRandomName():
    randomName = str(fake.name())
    randomName=  randomName.replace("."," ")
    randomName=  randomName.upper()
    return randomName

NAME = generateRandomName()

def generateRandomEmail():
    name = generateRandomName()
    random_email = name.replace(" ","_") + '@' + 'test.co'
    return random_email


## generating random valid date
def generaterandomDOB():
    startdate=date.fromisoformat('1965-01-01')
    enddate=date.fromisoformat('2023-01-01')
    randomdate =fake.date_between(startdate,enddate)
    formatdate = "%d/%m/%Y"
    randomdate_formatted = date.strftime(randomdate,formatdate)
    return randomdate_formatted

DOB = generaterandomDOB()

## Generate random NRIC

def generaterandomNRIC():
    weights = (2,7,6,5,4,3,2)
    lookup_list= ['J','Z','I','H','G','F','E','D','C','B','A']
    running_sum = 0
    random_num_string = "S"
    for w in weights:
        random_int=randrange(10)
        random_num_string += str(random_int)
        running_sum = running_sum + (random_int*w)
    lookup_index = running_sum % 11
    randomNRIC = random_num_string + lookup_list[lookup_index] 
    return randomNRIC

NRIC = generaterandomNRIC()

### generate random passport number

def generaterandomPPNumber():
    weights = (2,7,6,5,4,3,2)
    lookup_list= ['E','D','B','A','H','K','N','P','R','Z','G']
    running_sum = 0
    random_num_string = "K"
    for w in weights:
        random_int=randrange(10)
        random_num_string += str(random_int)
        running_sum = running_sum + (random_int*w)
    lookup_index = running_sum % 11
    randomPPnumber = random_num_string + lookup_list[lookup_index]
    #randomintstring = randrange(11111111,99999999)
    #randomPPnumber = 'F' + str(randomintstring) + 'K'
    return randomPPnumber

## generate random car license plate number

def generaterandomCarPlateNumber():
    weights = (10,15,14,15,16,17)
    lookup_list= ['A','B','C','D','E','G','H','J','K','L','M','P','R','S','T','U','X','Y','Z']
    running_sum = 0
    alpha_starting_char = "S"
    char_seq_list  = list(string.ascii_uppercase)
    num_seq_list = []
    for num in range(1,27):
        num_seq_list.append(num)
    
    ### license plate prefix letter to number dict
    alphabet_conv_dict = { char_seq_list: num_seq_list for char_seq_list , num_seq_list in zip(char_seq_list,num_seq_list) }
    
    ### generating random carplate number and running sum
    for index,seq_i in enumerate(range(6)):
        if index <=1:
            random_char = choice(string.ascii_uppercase)
            alpha_starting_char = alpha_starting_char + random_char
            running_sum += alphabet_conv_dict[random_char] * weights[seq_i]
        
        elif index > 1:
            random_int=randrange(10)
            alpha_starting_char += str(random_int)
            running_sum += random_int*weights[seq_i]
    
    ## generating checksum char
    lookup_index = running_sum % 19
    alpha_starting_char += lookup_list[lookup_index]

    return alpha_starting_char

    
    

PPNUM = generaterandomPPNumber()

def generateForeignPassportNum():
    randomForeignPPNum = fake.passport_number()
    return randomForeignPPNum

FOREIGNPPNUM = generateForeignPassportNum()  


def generatelistofDOBS(n):
    listOfDOBs = []
    for i in range(n):
        listOfDOBs.append(generaterandomDOB())
    return listOfDOBs

def generatelistofNames(n):
    listofNames =[]
    for i in range(n):
        listofNames.append(generateRandomName())
    return listofNames

def generatelistofNRIC(n):
    listofNRIC =[]
    for i in range(n):
        listofNRIC.append(generaterandomNRIC())
    return listofNRIC

def generateListofPPNum(n):
    listofPPNum =[]
    for i in range(n):
        listofPPNum.append(generaterandomPPNumber())
    return listofPPNum

def main():
    NRIC = generaterandomNRIC()
    PPnum =  generaterandomPPNumber()
    CARnum = generaterandomCarPlateNumber()

    random_email = generateRandomEmail()
    nric_ppnum_string = f'{NRIC} {PPnum} {CARnum} {random_email}'

    print(nric_ppnum_string)


if __name__ == '__main__':
    main() 






