from datetime import timedelta
from datetime import date
from datetime import datetime
def remove_whitespaces(string):
    string = str(string)
    string=string.replace(' ','')
    return string

def reverse_list_elements(input_list: list) -> list:
    input_list.reverse()
    return input_list

def masking_string(nric_string: str) -> str:
    nric_substring = nric_string[5:] 
    masking_string = '*****{nric_substring_formatted:<}'.format(nric_substring_formatted=nric_substring)
    return masking_string

def string_splitter(string:str,chars:int)-> list:
    #char_list = [*string]
    group_char_list = list()
    for pointer in range(0,len(string),chars):
        group_char_list.append(string[pointer:pointer + chars])
    
    return group_char_list

def add_space_between_string(string:str)->str:
    str_list = string_splitter(string,1)
    res_str = str()
    for num in str_list:
        res_str += num + ' '
    return res_str.strip()

#add_space_between_string('983847484')

def convert_int_to_secs(numsecs:int):
    duration = timedelta(seconds=numsecs)
    return duration

#test = convert_int_to_ms(500)
#print(test)

def date_field_formatter(datestr:str):
    ###adds spaces inbetween the / so that it fits the selector
    datestr_list = datestr.split("/")
    datestr_formatted = f'{datestr_list[0]} / {datestr_list[1]} / {datestr_list[2]}'
    return datestr_formatted 

#date_field_formatter('01/01/2026')
def current_date_generator()->str:
    curr_date = date.today()
    date_formatted =curr_date.strftime('%d/%m/%Y')
    return date_formatted

    




