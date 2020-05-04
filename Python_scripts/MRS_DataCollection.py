"""Create MRS Database from LC Model
Created: May 1, 2020 KeWei JimiCao

Usage:
    python3 MRS_DataCollection.py
    input: type in your work path

    Teminal Example:
    python3 MRS_DataCollection.py
    input: /path/to/your/working/directory

"""

import os
import pandas as pd

def get_ID_and_loc(file_path):
    """ get Study ID
    para file_path[str]: path of the working dirctory as string
    return: ID and tissue type from the last 2 child dir
    """
    pathsplit='_'.join(file_path.split('/')[1:]).split('_')
    return [pathsplit[-2], pathsplit[-1]]

def threeT_vs_15T(table_file_path):
    """threeT_vs_15T
    table_file_path[str]: file to read in to deframe
    return:[str] 1.5T or 3T
    """
    df=pd.read_csv(table_file_path, error_bad_lines=False, skiprows=2, nrows=1, header=None, index_col=False)
    if df.iloc[0, 0] == ' (Huntington MR Center)':
        return "1.5T"
    else:
        return "3T"


def get_DOE(table_file_path):
    """get the Date of Exam from the file content
    table_file_path [str]: file to read in to deframe
    return [str] the date of exam found in the file
    """
    df=pd.read_csv(table_file_path, sep=' +', engine='python', error_bad_lines=False, skiprows=1, nrows=1, header=None, index_col=False)
    if df.iloc[0, 3] == 'presscsi':
        return df.iloc[0, 1]
    else:
        return df.iloc[0, 3]


def table_to_row(df):
    """reshape the table from a 3x36 to a 1x108
    df: dataframe of 3x36
    return dataframe as 1x108
    """
    df_out = df.stack()
    df_out.index = df_out.index.map('{0[0]}{0[1]}'.format)
    return df_out.to_frame().T

def read_table_file(dirpath, table_file_path):
    """read the input table files
    dirpath [str]: folder tha contains this files
    table_file_path [str]: file path to read in to deframe
    return [df] with ID, Scanner strenght, Tissue, and DOE added into the contents
    """
    #get ID and sample location from path
    ID=get_ID_and_loc(dirpath)[0]
    tissue=get_ID_and_loc(dirpath)[1]

    #get scanner info
    scanner_T=threeT_vs_15T(table_file_path)

    #get Date of Exam
    DOE=get_DOE(table_file_path)

    #get data
    data=pd.read_csv(table_file_path,sep=' +', engine='python',error_bad_lines=False, skiprows=7, nrows=36)
    data=data.set_index('Metabolite')
    data=table_to_row(data)

    data['Scanner']=scanner_T
    data['ID']=ID
    data['Tissue']=tissue
    data['DOE']=DOE
    data=data.set_index('ID')
    return data

def main ():
    dir=input("workdir: ")
    pattern='table'
    exten='.csv'

    data_final=pd.DataFrame()

    #read MRS contents
    for dirpath, subdirs, files in os.walk(dir):
        for file in files:
            if (pattern in file) and (len(file)==5):
                #changae file format to csv
                src=os.path.join(dirpath, file)
                dst=os.path.join(dirpath, file+'.csv')
                os.rename(src,dst)

                #read file now
                data=read_table_file(dirpath, dst)
                data_final=data_final.append(data)
            elif (pattern in file) and file.endswith('.csv'):
                data=read_table_file(dirpath, os.path.join(dirpath,file))
                data_final=data_final.append(data)
    data_final.to_csv(dir+'/MRS_database.csv')
    return

if __name__ == '__main__': main()
