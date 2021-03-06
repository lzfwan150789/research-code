function [Lmat_opt, stats]= opt_selpair(Train_mats,params)



ct_batch=params.ct_batch;
num_pairs=nchoosek(params.num_cam,2);
gain_vec=zeros(1,num_pairs);
gain_vec2=zeros(1,num_pairs);




% gain_vecc2=zeros(1,6);
overhead_tot=0;
for numfolds=1:1
% options = optimoptions('intlinprog','Heuristics','diving','IntegerTolerance',1e-6);
% options = cplexoptimset;
%Cplex.Param.benders.strategy=1;
%options.Algorithm='interior-point';
%options.Algorithm='dual';
num_person=params.num_person;
num_cam=params.num_cam;
%np_array=[10 10 10 10];


for i= 1:num_cam
indcam=(ct_batch-1)*num_person+1 :(ct_batch-1)*num_person+num_person;

    if params.non_overlap ==1
        indcam=indcam(randperm(length(indcam)));
        indcam=indcam(1:params.non_overlap_lim);
        indcam=sort(indcam);
        num_person=params.non_overlap_lim;
    
    end    
    cam_ind{i}=indcam;
end

np_array=num_person*ones(1,num_cam);
pairs=nchoosek(1:num_cam,2);










true_id=Train_mats.camp;
temp_full_feat=Train_mats.cam;
for i=1:num_cam
 feat{i}= (temp_full_feat{i}(:,cam_ind{i}))';  
    
end
clear temp_full_feat

clear Train_mats

[~,sim_struct]=pairwise_distcollect(feat);






 
 
%f=-1*[(sim12(:)); (sim13(:));(sim14(:));(sim15(:));(sim16(:));(sim23(:));(sim24(:));(sim25(:));(sim26(:));(sim34(:));(sim35(:));(sim36(:));(sim45(:));(sim46(:));(sim56(:))];
% f=-ones(1,2400);
f=[];
for i= 1: size(pairs,1)
 temp=-1*sim_struct{i}(:);
 f=[f;temp];
end
nv=length(f);
if(params.method==1)
%[A_ineqportion2]= mat_confull(np);
if numfolds==1
[A_ineqportion2]= mat_confullg(np_array);
end
%f=-[rand(size(A_ineqportion2,2)-100,1); ones(100,1)];

nv=size(A_ineqportion2,2);
%A_ineqportion1 = pwise_wbasedsel(np_array,nv);
A_ineqportion1=ones(1,size(A_ineqportion2,2));

A_ineq=[A_ineqportion1;A_ineqportion2];


%b_ineq1=[ceil(nv/25);ceil(nv/20);ceil(nv/40);ceil(nv/10);ceil(nv/20);ceil(nv/35)];
%b_ineq1=[ceil(nv/cfactor);ceil(nv/cfactor);ceil(nv/cfactor);ceil(nv/cfactor);ceil(nv/cfactor);ceil(nv/cfactor)];
b_ineq1=floor((nv*params.budget/100));
b_ineq=[b_ineq1;2*ones(size(A_ineqportion2,1),1)];
%A_eq=con_mat;
%A_eq=matcon_gen(np,np,np);
%b_eq=2*ones(size(A_eq,1),1);


A_eq=[];
b_eq=[];

end

disp('Optimization running')
tic
if params.method==1 %%% integer programming select
%[x_bip,~, ~, ~] = cplexlp(f, A_ineq, b_ineq, A_eq, b_eq,zeros(1,length(f)),ones(1,length(f)),[]);
[x_bip, ~, ~, ~] = cplexbilp(f, A_ineq, b_ineq, A_eq, b_eq,[]);
elseif params.method==2 %%% greedy select
x_bip=greedy_sel_list(f,np_array,floor((nv*params.budget/100)));
elseif params.method==3 %%% 1/2 selec
x_bip=half_maxcut_sel(f,np_array,params.full_budget);
elseif params.method==4 %% max-prob
x_bip=max_prob_sel(f,params.full_budget);
elseif params.method==5 %% rand
x_bip= rand_label(1,size(f,1),params.full_budget);

elseif params.method==6 %% min_marg select
    
x_bip=min_marg_sel(sim_struct,num_pairs,params.full_budget);
elseif params.method==7 %%% dominant select
x_bip=dominant_sel(feat,num_cam,params.full_budget);

elseif params.method==0 %% select all
x_bip=ones(size(f));   
end
toc





%[x_bip, fval, exitflag, output] = cplexbilp(f, A_ineq, b_ineq, A_eq, b_eq,[],options);
%[x_bip, fval, exitflag, output] = cplexlp(f, A_ineq, b_ineq, A_eq, b_eq,zeros(1,length(f)),ones(1,length(f)),[],options);
if length(find(x_bip>(1e-8) & x_bip<.9999999))>1
    disp('integrality warning');
    x_bip=imbinarize(x_bip,2/3);
end
%frac=







lable_collect=pairwise_labelcollect(x_bip,np_array,num_cam);
L_collect=lable_collect;
% lable_collectc=pairwise_labelcollect(x_bip2,np_array,num_cam);

% cab_sel=reshape(x_bip(1:np^2,1),np,np);
% cac_sel=reshape(x_bip(1+np^2:2*np^2,1),np,np);
% cbc_sel=reshape(x_bip(2*np^2+1:end,1),np,np);
for i=1:num_pairs
%tlmatstruct{i}=eye(20); 
id_A=true_id{pairs(i,1)};
id_B=true_id{pairs(i,2)};
  
tlmatstruct{i}=lmat_gen(id_A(cam_ind{pairs(i,1)}),id_B(cam_ind{pairs(i,2)}));

end
 [tot_gain,lmat_struct]= tot_lblgain2f(tlmatstruct,lable_collect,num_cam);
%  [tot_gainc,lmat_structc]= tot_lblgain2(tlmatstruct,lable_collectc,num_cam);

 lmat_structx=lmat_struct;
%  lmat_structxc=lmat_structc;
if (params.method== 1 || params.method==2 ||params.method==3 || params.method==4)
 
 for vv=1:params.itcl
   
     if vv<4
       [tot_gain2,lmat_struct2]= tot_lblgain2f(tlmatstruct,lmat_structx,num_cam);
       lmat_structx=lmat_struct2;

 
%   [tot_gainc2,lmat_structc2]= tot_lblgain2(tlmatstruct,lmat_structxc,num_cam);
%  lmat_structxc=lmat_structc2;
%     tot_gain2     

     elseif params.method~=44
       %regu=32;
      [tot_gain2,lmat_struct2,overhead,L_collect]= tot_lblgain3f(L_collect,tlmatstruct,lmat_structx,sim_struct,num_cam,vv,st_need,params.reg_spec);
 lmat_structx=lmat_struct2;
 
%      tot_gain2     

%   [tot_gainc2,lmat_structc2,overhead]= tot_lblgain3(tlmatstruct,lmat_structxc,simstruct,num_cam,vv);
%  lmat_structxc=lmat_structc2;
 overhead_tot=overhead+overhead_tot;
     end
 limit_bd=(sum(x_bip)+overhead_tot);
 st_need=params.master_budget-limit_bd;
  if(limit_bd>=params.master_budget)
     break;
  end
 

 end
 
if params.method~=0
       %regu=32;
       for i=1:8
%       [~,lmat_struct2,over]= tot_lblgain3f(tlmatstruct,lmat_structx,sim_struct,num_cam,8,0);
      [~,lmat_struct2]= tot_lblgain2f(tlmatstruct,lmat_structx,num_cam);

      lmat_structx=lmat_struct2;
      %over
       end
end
 
gain_vec=gain_vec+tot_gain;
gain_vec2=gain_vec2+tot_gain2;
else
lmat_struct2=lmat_struct;
end


gain_vec=gain_vec/numfolds;
gain_vec2=gain_vec2/numfolds;

stats.tot_req=sum(x_bip)+ overhead_tot;
stats.gain=tot_gain;

stats.gain2=gain_vec2;
stats.indcam=indcam;
stats.cam_ind=cam_ind;
stats.lmat_struct2=lmat_struct2;
stats.tlmatstruct=tlmatstruct;
stats.tot_var=length(x_bip);
stats.overhead=overhead_tot;



Lmat_opt=lmat_structx; 
tot_pos=0;
gain_pos=0;
for i=1: size(Lmat_opt,2)
 temp_mod_nan=Lmat_opt{i};
 temp_mod_nan(temp_mod_nan==0)=NaN;
 Lmat_opt{i}=temp_mod_nan.*tlmatstruct{i};
 tot_pos=tot_pos+length(find(tlmatstruct{i}==1));
 gain_pos=gain_pos+length(find(Lmat_opt{i}==1));
 
    
end

stats.pos=100*gain_pos/tot_pos;
stats.LC=L_collect;


end