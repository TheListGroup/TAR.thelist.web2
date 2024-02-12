import Levenshtein as lev
import pandas as pd

use_TH = pd.read_csv("TH_reverse.csv", encoding='utf-8')

use_TH.insert(7, 'name_from_real_1', '-')
use_TH.insert(8, 'num_from_real_1', '-')
use_TH.insert(9, 'ratio_1', 0)
use_TH.insert(10, 'name_from_real_2', '-')
use_TH.insert(11, 'num_from_real_2', '-')
use_TH.insert(12, 'ratio_2', 0)
use_TH.insert(13, 'name_from_real_3', '-')
use_TH.insert(14, 'num_from_real_3', '-')
use_TH.insert(15, 'ratio_3', 0)
use_TH.insert(16, 'name_from_real_4', '-')
use_TH.insert(17, 'num_from_real_4', '-')
use_TH.insert(18, 'ratio_4', 0)
use_TH.insert(19, 'name_from_real_5', '-')
use_TH.insert(20, 'num_from_real_5', '-')
use_TH.insert(21, 'ratio_5', 0)

real = pd.read_csv("real-reverse.csv", encoding='utf-8')

print(f"start with real size {real.index.size}")

for x in range(use_TH.index.size):
    print(f"{use_TH.iloc[x,0]} = {use_TH.iloc[x,1]}")

    best_ratio_1 = 0
    best_ratio_2 = 0
    best_ratio_3 = 0
    best_ratio_4 = 0
    best_ratio_5 = 0
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
    for y in range(real.index.size):

        if real.iloc[y][1]:
            #print(f"{x} - {y} -- {use_TH.iloc[y][1]}")
            ratio = lev.ratio(use_TH.iloc[x][1], real.iloc[y][1])

            if (ratio == 1) :
                best_ratio_1 = ratio
                best_word_1 = real.iloc[y][1]
                best_condo_number_1 = real.iloc[y][0]
                real = real.drop(real.index[y])
                break
            elif (ratio > best_ratio_1):
                best_ratio_5 = best_ratio_4
                best_word_5 = best_word_4
                best_condo_number_5 = best_condo_number_4
                best_ratio_4 = best_ratio_3
                best_word_4 = best_word_3
                best_condo_number_4 = best_condo_number_3
                best_ratio_3 = best_ratio_2
                best_word_3 = best_word_2
                best_condo_number_3 = best_condo_number_2
                best_ratio_2 = best_ratio_1
                best_word_2 = best_word_1
                best_condo_number_2 = best_condo_number_1
                best_ratio_1 = ratio
                best_word_1 = real.iloc[y][1]
                best_condo_number_1 = real.iloc[y][0]
            elif (ratio > best_ratio_2):
                best_ratio_5 = best_ratio_4
                best_word_5 = best_word_4
                best_condo_number_5 = best_condo_number_4
                best_ratio_4 = best_ratio_3
                best_word_4 = best_word_3
                best_condo_number_4 = best_condo_number_3
                best_ratio_3 = best_ratio_2
                best_word_3 = best_word_2
                best_condo_number_3 = best_condo_number_2
                best_ratio_2 = ratio
                best_word_2 = real.iloc[y][1]
                best_condo_number_2 = real.iloc[y][0]
            elif (ratio > best_ratio_3):
                best_ratio_5 = best_ratio_4
                best_word_5 = best_word_4
                best_condo_number_5 = best_condo_number_4
                best_ratio_4 = best_ratio_3
                best_word_4 = best_word_3
                best_condo_number_4 = best_condo_number_3
                best_ratio_3 = ratio
                best_word_3 = real.iloc[y][1]
                best_condo_number_3 = real.iloc[y][0]
            elif (ratio > best_ratio_4):
                best_ratio_5 = best_ratio_4
                best_word_5 = best_word_4
                best_condo_number_5 = best_condo_number_4
                best_ratio_4 = ratio
                best_word_4 = real.iloc[y][1]
                best_condo_number_4 = real.iloc[y][0]
            elif (ratio > best_ratio_5):
                best_ratio_5 = ratio
                best_word_5 = real.iloc[y][1]
                best_condo_number_5 = real.iloc[y][0]
            #print(f"{best_word_1} -- {best_condo_number_1} -- {best_ratio_1} -- {best_word_2} -- {best_condo_number_2} -- {best_ratio_2} -- {best_word_3} -- {best_condo_number_3} -- {best_ratio_3} -- {best_word_4} -- {best_condo_number_4} -- {best_ratio_4} -- {best_word_5} -- {best_condo_number_5} -- {best_ratio_5}")
    use_TH.iat[x, 7] = best_word_1
    use_TH.iat[x, 8] = best_condo_number_1
    use_TH.iat[x, 9] = best_ratio_1
    use_TH.iat[x, 10] = best_word_2
    use_TH.iat[x, 11] = best_condo_number_2
    use_TH.iat[x, 12] = best_ratio_2
    use_TH.iat[x, 13] = best_word_3
    use_TH.iat[x, 14] = best_condo_number_3
    use_TH.iat[x, 15] = best_ratio_3
    use_TH.iat[x, 16] = best_word_4
    use_TH.iat[x, 17] = best_condo_number_4
    use_TH.iat[x, 18] = best_ratio_4
    use_TH.iat[x, 19] = best_word_5
    use_TH.iat[x, 20] = best_condo_number_5
    use_TH.iat[x, 21] = best_ratio_5
    #print(f"::: {best_word} for score of {best_ratio}, code is {best_condo_number}")

print(f"finish with real size {real.index.size}")
#print(real)

#use_TH.to_csv('USE_TH_updated_name2.csv')
use_TH.to_csv('reverse.csv')