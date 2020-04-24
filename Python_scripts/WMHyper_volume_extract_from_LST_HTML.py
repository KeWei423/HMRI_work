import glob
# import sys
import os
# import urllib.request
import pandas as pd


#input: current HTML file
#output: ID, thr, and WM volume
def get_WM_info (file_path):
#     print(file_path)
    pathsplit='_'.join(file_path.split('/')[1:]).split('_')
    # print("pathsplit: ", pathsplit)

    ############################################
    # for old HABLE only
    ############################################
    # ID=pathsplit[14]+'_'+pathsplit[-4]
    ############################################

    ################################################################
    #for currnet
    ID_numb = [i for i in pathsplit if i.startswith('rm')]
    ID='_'.join([ID_numb[0][2:], pathsplit[-1][:-5]])
    ID=ID[:-1]
    ################################################################
    # print("ID: ", ID)

    html_file=open(file_path, 'r', encoding='utf-8')
    for i, line in enumerate(html_file):
        if i==103:
#             print(line)
            volume=line[line.find('>')+1:line.find(' ml')]
#             print("ID: %s \nVolume: %s" %(ID, volume))
        else:
            continue
    return ID, volume


def main ():
    # dir=input("workdir: ")
    # dir="/Users/baymac/Desktop/Data_todo/To_Process/WMH_FOLDER/FSPGR_3D"
    # dir="/Volumes/Image_Repository/Processed_Research_Image/WMH/WMHyper_mask/WH_3T_BayMac/HTML_Report"
    dir="/Users/baymac/Desktop/Data_todo/HABLE/NII/Baseline/SeqBased/MPRAGE"
    matrix = {'ID' : [],
              'Volume (ml)' : []}

    #read input HTML and get needed info
    for filename in glob.glob(os.path.join(dir, '*.html')):
        #read HTML
        ID, volume=get_WM_info(filename)
        print("ID: %s \tVolume: %s ml" %(ID, volume))

        #append info to data
        matrix['ID'].append(ID)
        matrix['Volume (ml)'].append(volume)
#         if ID in matrix:
#             matrix[ID].append(volume)
#         else:
#             matrix[ID]=[volume]

    data=pd.DataFrame(matrix).sort_values('ID')
#     print(data)
    # data.to_csv("/Users/baymac/Desktop/WMH_CVRmanuscript_0.3.csv", index=False)
    data.to_csv("/Users/baymac/Desktop/Data_todo/HABLE/NII/Baseline_WMHyper.csv", index=False)
    # write the matrix into an excel
    # save_as_excel(dir, matrix)
    return

if __name__ == '__main__': main()
