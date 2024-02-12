import Levenshtein as lev
from bs4 import BeautifulSoup as bs
import pandas as pd


real = pd.read_csv("match_condo/real2.csv", encoding='utf-8')

real.insert(2, 'name_from_hip', '-')
real.insert(3, 'code_from_hip', '-')
real.insert(4, 'ratio', 0)
# print(real)

hip = pd.read_csv("match_condo/hip.csv", encoding='utf-8')
# print(hip)

print(f"start with hip size {hip.index.size}")

for x in range(real.index.size):
    print(f"{real.iloc[x,1]} = {real.iloc[x,0]}")

    best_ratio = 0
    for y in range(hip.index.size):

        if hip.iloc[y][1]:
            #print(f"{x} - {y} -- {hip.iloc[y][1]}")
            ratio = lev.ratio(real.iloc[x][0], hip.iloc[y][1])

            if (ratio == 1):
                best_ratio = ratio
                best_word = hip.iloc[y][1]
                best_condo_code = hip.iloc[y][0]
                hip = hip.drop(hip.index[y])
                #print(f"{best_word} dropped. size is now {hip.index.size}")
                break
            elif (ratio > best_ratio):
                best_ratio = ratio
                best_word = hip.iloc[y][1]
                best_condo_code = hip.iloc[y][0]
    real.iat[x, 2] = best_word
    real.iat[x, 3] = best_condo_code
    real.iat[x, 4] = best_ratio

    #print(f"::: {best_word} for score of {best_ratio}, code is {best_condo_code}")

print(f"finish with hip size {hip.index.size}")
print(real)

hip.to_csv('match_condo/hip_updated.csv')
real.to_csv('match_condo/real_with_hip_updated.csv')
