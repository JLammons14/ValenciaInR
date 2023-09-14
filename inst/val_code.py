#!/usr/local/bin/python3

#importing packages to be used with error handling
try:
    import pandas as pd
except:
    print("Required package pandas not available")
    exit()
try:
    import numpy as np
except:
    print("Required package numpy not available")
    exit()



#removing the  warning that pandas has for when you do complicated things
pd.options.mode.chained_assignment = None  # default='warn'

#VALENCIA
###The purpose of this tool is to classify vaginal microbial communities into community state types (CSTs)
###in a standardized and repeatable fashion, clusters are based on the 13,000+ women data
###A total of 13 CSTs are considered: CST I-A, I-B, II, III-A, III-B, IV-A, IV-B, IV-C0, IV-C1, IV-C2, IV-C3, IV-C4, V 
####This script tests new samples based on similarity to already defined cluster centroids

#defining function to determine yue-clayton theta
def yue_distance(row, median):
    #creating a counting variable to index the median list
    taxon_count = 0
    #creating lists to iterativly store output
    median_times_obs = []
    median_minus_obs_sq = []    
    #looping through the row and calculating product and difference squared between row data and median data
    for taxon_abund in row:
        #calculate p * q
        median_times_obs.append(median[taxon_count]*taxon_abund)
        #calculate p-q squared
        median_minus_obs_sq.append((median[taxon_count]-taxon_abund)**2)
        taxon_count += 1    
    #calculate sum p* q
    product = np.nansum(median_times_obs)   
    #calculate sum p-q squared
    diff_sq = np.nansum(median_minus_obs_sq)
    #calculate yue_med_dist
    yue_med_dist = product / (diff_sq + product)
    #return the value of yue distance
    return yue_med_dist 





#reading in the input CST centroids
def Valcencia_CST( sample_data_OG, reference_centroids):
    #list of subCSTs 
    CSTs = ['I-A','I-B','II','III-A','III-B','IV-A','IV-B','IV-C0','IV-C1','IV-C2','IV-C3','IV-C4','V']
    print(sample_data_OG.columns[0:2])
    #checking if first two columns have appropriate headers
    if list(sample_data_OG.columns[0:2]) != ['sampleID','read_count']:
        print('Input file expected to be a CSV with first two column headers: sampleID,read_count')
        exit()

    #forcing the sample data to have the same number of columns as the reference and in the same order 
    combined_data = pd.concat([sample_data_OG,reference_centroids], ignore_index=True,sort=False)
    sample_data = combined_data[:-13].fillna(0)
    sample_data = sample_data.drop(['sub_CST'],axis=1)
    reference_centroids = combined_data.tail(13).fillna(0)
    reference_centroids = reference_centroids.drop(["sampleID","read_count"],axis=1).set_index('sub_CST')

    #converting all of the read counts to relative abundance data and adding back the first two columns
    sample_data_rel = sample_data[sample_data.columns[2:]].div(sample_data['read_count'],axis=0)
    sample_data_rel = pd.concat([sample_data[sample_data.columns[0:2]],sample_data_rel],axis=1)

    #loop measuring the similarity of each sample to each subCST centroid using yue + clayon theta
    for CST in CSTs:

        sample_data_OG['%s_sim' %(CST)] = sample_data_rel.apply(lambda x : yue_distance(x[2:],reference_centroids.loc[CST]), axis=1)

    #outputting the acquired data with the new variability measure
    #identify for each sample, which subCST was most similar, then correcting name of subCST to remove _sim
    sample_data_OG['subCST'] = sample_data_OG.iloc[:,-13:].idxmax(axis=1)
    sample_data_OG['subCST'] = sample_data_OG['subCST'].str.replace('_sim',"")

    #applying function to calculate a penalized score, not currently in use
    #sample_data_OG['penalized_score'] = sample_data_OG.apply(lambda x : penalized_simil_score(x[-14:]), axis=1)

    #store the similarity between each sample and its as=ssigned 
    sample_data_OG['score'] = sample_data_OG.iloc[:,-14:-1].max(axis=1)

    #determine higher order CST assignment based on subCST assignment
    sample_data_OG['CST'] = sample_data_OG['subCST'].replace({'I-A':'I','I-B':'I','III-A':'III','III-B':'III','IV-C0':'IV-C','IV-C1':'IV-C','IV-C2':'IV-C','IV-C3':'IV-C','IV-C4':'IV-C'})

    #output the assignments in new CSV file


    # sample_data_OG.to_csv("weiner.csv",index=None)
    
    
    return sample_data_OG
