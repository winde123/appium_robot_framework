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





