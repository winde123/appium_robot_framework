from random import choice , randint
from string import ascii_uppercase , digits
import pandas as pd
import numpy as np
#from random import randrange

### generates the length of srxpaxid str
def gen_100_alphanumeric_string():
    return(''.join(choice(ascii_uppercase + digits) for i in range(50)))

def gen_n_len_alphanumeric_string(n):
    return(''.join(choice(ascii_uppercase + digits) for i in range(n)))

def gen_len_up_to_alphanumeric_string(length):
    random_int = randint(1,length)
    return(''.join(choice(ascii_uppercase + digits) for i in range(random_int)))

#test = gen_len_up_to_alphanumeric_string(3)
#print(test)

def gen_unique_carrier_code(n):
    carrier_cd_list = list()
    for carrier_count in range(n):
        carrier_cd_list.append(gen_len_up_to_alphanumeric_string(3))
    
    ##remove duplicates
    carrier_cd_set = set(carrier_cd_list)
    return carrier_cd_set

#testset = gen_unique_carrier_code(30000)
#print(len(testset))

def gen_gen_unique_carrier_code_csv(n):
    carriercode_unique_set = gen_unique_carrier_code(n)
    ## converting back to list
    carriercode_unique_list = list(carriercode_unique_set)
    ###print(len(carriercode_unique_list))
    carriercode_unique_series = pd.Series(carriercode_unique_list,name='carrierCd')
    carriercode_unique_series.to_csv('../../Output/unique_carrier.csv',encoding='utf-8',index=True)

#gen_gen_unique_carrier_code_csv(30000)
#print(test)


### generates the number of rows for each csv
def gen_transport_csv(n,type ='OUT'):
    src_pax_id_list = list()
    carrier_cd_list =list()
    flt_num_list = list()
    direction_list = list()
    flt_Arr_date_list = list()
    flt_dept_date_list = list()
    #srcLastModifiedDatetime_list  =[0]
    #PPTname_list = [0]

    ## generating IN data
    if type == 'IN':
        for i in range(n):
            src_pax_id_list.append(gen_n_len_alphanumeric_string(10))
            carrier_cd_list.append(gen_n_len_alphanumeric_string(3))
            flt_num_list.append(gen_n_len_alphanumeric_string(15))
            flt_Arr_date_list.append('20080909 09:09:11')
            flt_dept_date_list.append('')
            direction_list.append('IN')
    else:
        for i in range(n):
            src_pax_id_list.append(gen_n_len_alphanumeric_string(10))
            carrier_cd_list.append(gen_n_len_alphanumeric_string(3))
            flt_num_list.append(gen_n_len_alphanumeric_string(15))
            flt_Arr_date_list.append('')
            flt_dept_date_list.append('20230909 09:09:11')
            direction_list.append('OUT')



    
    #src_pax_id_list = src_pax_id_list[1:]
    #carrier_cd_list = carrier_cd_list[1:]
    #flt_num_list = flt_num_list[1:]
    #direction_list =direction_list[1:]
    #flt_Arr_date_list = flt_Arr_date_list[1:]
    #flt_dept_date_list= flt_dept_date_list[1:]

    
    #srcLastModifiedDatetime_list = srcLastModifiedDatetime_list[1:]
    #PPTname_list = PPTname_list[1:] 
    #print(gen_alphanumeric_list)
    src_pax_id_series = pd.Series(src_pax_id_list,name='srcPaxId')
    carrier_cd_series = pd.Series(carrier_cd_list,name='carrierCd')
    #pid_value_series = pd.Series(pid_value_list,name='PIDValue')
    flt_num_series = pd.Series(flt_num_list,name='fltNum')
    flt_Arr_date_series = pd.Series(flt_Arr_date_list,name='fltArrDate')
    #srcLastModifiedDatetime_series = pd.Series(srcLastModifiedDatetime_list,name='srcLastModifiedDatetime')
    #PPTname_series = pd.Series(PPTname_list,name='PPTname')
    direction_series = pd.Series(direction_list,name='direction')
    flt_dept_date_series = pd.Series(flt_dept_date_list,name='fltDeptDate')


    df = pd.concat([carrier_cd_series,flt_num_series,direction_series,flt_Arr_date_series,flt_dept_date_series,src_pax_id_series], axis= 1)
    if type == 'IN':
        df.to_csv('../../Output/IN_entries.csv',encoding='utf-8',index=False)
    else:
        df.to_csv('../../Output/OUT_entries.csv',encoding='utf-8',index=False)

##gen_transport_csv(2400,'IN')

def test_gen_random_datetime():
    last30 = pd.to_datetime("today").replace(microsecond=0) - pd.Timedelta(weeks=20)
    end_date=pd.to_datetime("today")+pd.Timedelta(weeks=10)
 
    dates = pd.date_range(last30, end_date,periods = 3)
    #print (dates)
    #print(np.random.choice(dates, size=2))
    date_list=list()
    date_list.append(np.random.choice(dates, size=2))
    print(date_list[0])
    #date_series=pd.Series(date_list,name="date")
    #date_series.to_csv('C:/Users/niharaze/Documents/date.csv',encoding='utf-8',index=False)

#test_gen_random_datetime()



