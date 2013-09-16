%# ------------------------------------------------------------------------
%# Resistance Test Analysis - ITTC Based Uncertainty Analysis
%# ------------------------------------------------------------------------
%# 
%# Author     :  K. Zürcher (kzurcher@amc.edu.au)
%# Date       :  September 16, 2013
%#
%# Test date  :  August 27 to September 6, 2013
%# Facility   :  AMC, Towing Tank (TT)
%#
%# Runs TSI   :  01-35   Turbulence Studs Investigation               (TSI)
%# Runs TTI   :  36-62   Trim Tab Optimisation                        (TTI)
%# Runs FF1   :  63-80   Form Factor Estimation using Prohaska Method (FF)
%# Runs RT    :  81-231  Resistance Test                              (RT)
%# Runs FF2   :  231-249 Form Factor Estimation using Prohaska Method (FF)
%#
%# Speeds (FR)    :  0.1-0.47 (5.9-27.6 knots)
%#
%# Description    :  ITTC Based Uncertainty Analysis on Resistance Data
%#
%# ITTC Guidelines:  7.5-02-02-01
%#                   7.5-02-02-02
%#
%# ------------------------------------------------------------------------
%#
%# IMPORTANT  :  Change runfilespath and do not forget to substitute \ => \\
%#               Make use "_plots" directory has been created in folder
%#
%# ------------------------------------------------------------------------
%#
%# CHANGES    :  16/09/2013 - Created new script
%#               dd/mm/yyyy - ...
%#
%# ------------------------------------------------------------------------

%# ------------------------------------------------------------------------
%# Clear workspace
%# ------------------------------------------------------------------------
clear
clc

%# ------------------------------------------------------------------------
%# Find and close all plots
%# ------------------------------------------------------------------------
allPlots = findall(0, 'Type', 'figure', 'FileName', []);
delete(allPlots);   % Close all plots