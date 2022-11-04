# ABCD_Harmonizer
Interactive tool to remove scanner induced variance in image features from the Adolescent Brain Cognitive Development Study

## About
The Adolescent Cognitive Brain Development (ABCD) study is an ongoing, longitudinal neuroimaging study acquiring data from over 11,000 children starting at 9-10 years of age. These scans are acquired on 29 different scanners of 5 different model types manufactured by 3 different vendors. Publicly available data from the ABCD study include structural MRI (sMRI) measures such as cortical thickness and diffusion MRI (dMRI) measures such as fractional anisotropy (request access at: https://nda.nih.gov/abcd/). The provision of these data alongside comprehensive demographic and behavioral measures make for a low “cost of entry” for any researcher to conduct statistical analyses on the ABCD cohort or any sub-population therein. However, such investigators must be cognizant of the potentially confounding effects of different scanners on the neuroimaging measures. To that end, we have created this simple-to-use tool to enable investigators to "harmonize" the data - that is: to remove scanner induced variance present in the data while preserving the biological variability in the sample.

## How it works
The harmonization approach is termed "ComBat" and the implementation employed in this software was developed by Jean-Fillipe Fortin (https://github.com/Jfortin1/ComBatHarmonization; Fortin et al., 2017; Fortin et al., 2018). The approach is adapted from the field of genomics as a way to “combat batch effects when combining batches” of gene expression microarray data (Johnson et al., 2007) and works by using a Bayesian framework to adjust data from different batches (in this case: individual MRI scanners) given a set of biologically relevent priors (in this case: any number of covariates the user chooses, such as age, sex, and combined household income)

## Use
![image](https://user-images.githubusercontent.com/98111478/200028418-c6d76e7e-2fe2-4ece-8f65-dc25477347c6.png)

The user interface of ABCD_Harmonizer.

### Steps
1.  Set path to ABCD Data Download

      Use the "Browse" button or manually type in the location where your ABCD Data Release 4.0 download is.

2.  Select Imaging Data
      
      Use the drop-down lists to select 1) which image instrument you want, 2) which subset of features from the selected instrument you want to harmonize, and 3) which visit (baseline or 2-year follow-up) you want. Optionally check the box to use the ABCD image inclusion recommendations - if checked, data NOT recommended for inclusion for the selected modality will excluded.

3.  Select Variance Preserved Covariates
      
      By default, three covariates are included as the set of biologically relevent priors: age at scan, sex, and combined household income. Optionally, you can use the "Add additional covariate(s)" to include any other covariate from any ABCD instrument - clicking this button will prompt the user to select an instrument and then prompt the user to select from a list of all variables contained in the chosen instrument. 

4.  Run ComBat Harmonization

      A. Simply click "Run ComBat" - the instruments will be read into memory and the selected features will be harmonized according to your selections

      B. Save Harmonized Data - the harmonized data can be saved to a *.csv file. The file will include the variables "src_subject_id", "eventname", each covariate selected in step 3, "mri_info_deviceserialnumber" (aka, unique scanner identifier), and all selected image features.
![image](https://user-images.githubusercontent.com/98111478/200028181-240ef542-32f4-46b9-9e2c-10672ba9269b.png)

      C. View Results - optionally, you can review the before- and after- results of ComBat harmonization to see just how much scanner induced variance was present initially and how little remains after harmonization. If the feature set you selected corresponds to either APARC or Destrieux cortical parcellations, the scanner-attributable variance will be mapped onto a brain surface and shown as well.
      ![image](https://user-images.githubusercontent.com/98111478/200028276-88c3be94-b95c-412f-b00f-bd03ea8d4b84.png)



## Requirements
Currently, the software only supports sMRI and dMRI instruments in the ABCD Study's Data Release 4.0 version (https://nda.nih.gov/study.html?id=1299). Users must have these data downloaded on their local machine.
The open-source MATLAB-based code requires an active MATLAB license to run. However, the application has also been compiled into an executable file that should be compatible with any computer running Windows and does NOT require a MATLAB license (only MATLAB runtime routines, which the provided installer can download for you).

## References
Fortin, J.P., Cullen, N., Sheline, Y.I., Taylor, W.D., Aselcioglu, I., Cook, P.A., Adams, P., Cooper, C., Fava, M., McGrath, P.J., McInnis, M., Phillips, M.L., Trivedi, M.H., Weissman, M.M., Shinohara, R.T., 2018. Harmonization of cortical thickness measurements across scanners and sites. Neuroimage 167, 104-120.

Fortin, J.P., Parker, D., Tunc, B., Watanabe, T., Elliott, M.A., Ruparel, K., Roalf, D.R., Satterthwaite, T.D., Gur, R.C., Gur, R.E., Schultz, R.T., Verma, R., Shinohara, R.T., 2017. Harmonization of multi-site diffusion tensor imaging data. Neuroimage 161, 149-170.

Johnson, W.E., Li, C., Rabinovic, A., 2007. Adjusting batch effects in microarray expression data using empirical Bayes methods. Biostatistics 8, 118-127.
