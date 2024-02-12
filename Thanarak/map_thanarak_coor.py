import pandas as pd
import math

real = pd.read_csv("real_name4.csv", encoding='utf-8')
real.insert(6, 'name_from_Thanarak_TH_1', '-')
real.insert(7, 'number_from_Thanarak_TH_1', '-')
real.insert(8, 'distance_1', 0)
real.insert(9, 'name_from_Thanarak_TH_2', '-')
real.insert(10, 'number_from_Thanarak_TH_2', '-')
real.insert(11, 'distance_2', 0)
real.insert(12, 'name_from_Thanarak_TH_3', '-')
real.insert(13, 'number_from_Thanarak_TH_3', '-')
real.insert(14, 'distance_3', 0)
real.insert(15, 'name_from_Thanarak_TH_4', '-')
real.insert(16, 'number_from_Thanarak_TH_4', '-')
real.insert(17, 'distance_4', 0)
real.insert(18, 'name_from_Thanarak_TH_5', '-')
real.insert(19, 'number_from_Thanarak_TH_5', '-')
real.insert(20, 'distance_5', 0)

TH_coor = pd.read_csv("only_coor.csv", encoding='utf-8')

print(f"start with Thanarak_TH size {TH_coor.index.size}")
for x in range(real.index.size):
    print(f"{real.iloc[x,0]} = {real.iloc[x,1]}")
    real_lat = real.iloc[x,2]
    real_long = real.iloc[x,3]
    #real_lat = float(real_lat)
    #print (type(real_lat))
    #print (type(real_long))
    best_distance_1 = 100
    best_distance_2 = 100
    best_distance_3 = 100
    best_distance_4 = 100
    best_distance_5 = 100
    best_word_1 = ""
    best_word_2 = ""
    best_word_3 = ""
    best_word_4 = ""
    best_word_5 = ""
    best_condo_number_1 = ""
    best_condo_number_2 = ""
    best_condo_number_3 = ""
    best_condo_number_4 = ""
    best_condo_number_5 = ""
    for y in range(TH_coor.index.size):
        TH_lat = TH_coor.iloc[y,7]
        TH_long = TH_coor.iloc[y,8]
    #    print (type(TH_lat))
    #    print (type(TH_long))
        if TH_coor.iloc[y][1]:
            distance = math.sqrt((real_lat - TH_lat)**2+(real_long - TH_long)**2)
    #        print (distance)
        if (distance < best_distance_1):
            best_distance_5 = best_distance_4
            best_word_5 = best_word_4
            best_condo_number_5 = best_condo_number_4
            best_distance_4 = best_distance_3
            best_word_4 = best_word_3
            best_condo_number_4 = best_condo_number_3
            best_distance_3 = best_distance_2
            best_word_3 = best_word_2
            best_condo_number_3 = best_condo_number_2
            best_distance_2 = best_distance_1
            best_word_2 = best_word_1
            best_condo_number_2 = best_condo_number_1
            best_distance_1 = distance
            best_word_1 = TH_coor.iloc[y][1]
            best_condo_number_1 = TH_coor.iloc[y][0]
        elif (distance < best_distance_2):
            best_distance_5 = best_distance_4
            best_word_5 = best_word_4
            best_condo_number_5 = best_condo_number_4
            best_distance_4 = best_distance_3
            best_word_4 = best_word_3
            best_condo_number_4 = best_condo_number_3
            best_distance_3 = best_distance_2
            best_word_3 = best_word_2
            best_condo_number_3 = best_condo_number_2
            best_distance_2 = distance
            best_word_2 = TH_coor.iloc[y][1]
            best_condo_number_2 = TH_coor.iloc[y][0]
        elif (distance < best_distance_3):
            best_distance_5 = best_distance_4
            best_word_5 = best_word_4
            best_condo_number_5 = best_condo_number_4
            best_distance_4 = best_distance_3
            best_word_4 = best_word_3
            best_condo_number_4 = best_condo_number_3
            best_distance_3 = distance
            best_word_3 = TH_coor.iloc[y][1]
            best_condo_number_3 = TH_coor.iloc[y][0]
        elif (distance < best_distance_4):
            best_distance_5 = best_distance_4
            best_word_5 = best_word_4
            best_condo_number_5 = best_condo_number_4
            best_distance_4 = distance
            best_word_4 = TH_coor.iloc[y][1]
            best_condo_number_4 = TH_coor.iloc[y][0]
        elif (distance < best_distance_5):
            best_distance_5 = distance
            best_word_5 = TH_coor.iloc[y][1]
            best_condo_number_5 = TH_coor.iloc[y][0]
        #print(f"{best_word_1} -- {best_condo_number_1} -- {best_distance_1} -- {best_word_2} -- {best_condo_number_2} -- {best_distance_2} -- {best_word_3} -- {best_condo_number_3} -- {best_distance_3} -- {best_word_4} -- {best_condo_number_4} -- {best_distance_4} -- {best_word_5} -- {best_condo_number_5} -- {best_distance_5}")
    #print (f"{best_distance_1} -- {best_distance_2} -- {best_distance_3} -- {best_distance_4} -- {best_distance_5}")
    real.iat[x, 6] = best_word_1
    real.iat[x, 7] = best_condo_number_1
    real.iat[x, 8] = best_distance_1
    real.iat[x, 9] = best_word_2
    real.iat[x, 10] = best_condo_number_2
    real.iat[x, 11] = best_distance_2
    real.iat[x, 12] = best_word_3
    real.iat[x, 13] = best_condo_number_3
    real.iat[x, 14] = best_distance_3
    real.iat[x, 15] = best_word_4
    real.iat[x, 16] = best_condo_number_4
    real.iat[x, 17] = best_distance_4
    real.iat[x, 18] = best_word_5
    real.iat[x, 19] = best_condo_number_5
    real.iat[x, 20] = best_distance_5
    
print(f"finish with TH_coor size {TH_coor.index.size}")
real.to_csv('real_with_TH_updated_coor2.csv')        