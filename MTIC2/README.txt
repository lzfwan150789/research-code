%% Code Author: Ahmed Tashrif Kamal - tashrifahmed@gmail.com
% http://www.ee.ucr.edu/~akamal
% no permission necessary for non-commercial use
% Date: 4/27/2013

%% 

Just run main.m

you can change the parameters in LoadParameters.m

in main.m, you can set 
generateFreshData = true
if you want to generate new random data to run the algorithms

in main.m, you can set 
generateFreshData = false
if you want to use the data that was used in the last run


References:

Multi-Target Information Consensus (MTIC):
Information Consensus for Distributed Multi-Target Tracking, A. T. Kamal, J. A. Farrell, A. K. Roy-Chowdhury, IEEE Conf. on Computer Vision and Pattern Recognition, 2013. 


Information-Weighted Consensus Filter (ICF):
Information Weighted Consensus, A. T. Kamal, J. A. Farrell, A. K. Roy-Chowdhury, Controls and Decision Conference,2012.


Joint Probabilistic Data Association Filter (JPDAF):
Y. Bar-Shalom, F. Daum, and J. Huang. The probabilistic data association ﬁlter. IEEE Control Systems, 29(6):82 –100, Dec. 2009


For details About computing the association probabilies see:
Fortmann, Thomas E.; Bar-Shalom, Y.; Scheffe, M., "Sonar tracking of multiple targets using joint probabilistic data association," Oceanic Engineering, IEEE Journal of , vol.8, no.3, pp.173,184, Jul 1983


JPDA-KCF:
N. F. Sandell and R. Olfati-Saber. Distributed data association for multi-target tracking in sensor networks. In IEEE
Conf. on Decision and Control, 2008.


KCF:
R. Olfati-Saber. Kalman-consensus ﬁlter: Optimality, stability, and performance. In IEEE Conf. on Decision and Control, 2009