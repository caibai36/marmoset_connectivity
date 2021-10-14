clear all
tic

% iterate through all voxels 
x_mat=59; 
y_mat=80; 
z_mat=54; 
t_mat=254880;
n_voxel=x_mat*y_mat*z_mat;

mask="DIRECTORY/gray_template_.5.nii";

for scan=[] % "subj-01" "subj-02" ...
    for run = [] % "1" "2" ...
        for pe = [] % "up" "down"

  disp(scan);
  index=sprintf('%s',scan);
  index2=sprintf('%d',run);
  index3=sprintf('%s',pe);
  
  input="DIRECTORY" + index + "_" + index3+ "_" + index2 + "_corrmap.nii.gz";
 
  M=niftiread(mask);
  M_reshape=reshape(M,[n_voxel,1]);
  IN=niftiread(input);
  IN_reshape=reshape(IN,[n_voxel*t_mat,1]);
    
  for i=1:z_mat
    for j=1:y_mat
      for k=1:x_mat 
        if (M_reshape(y_mat*x_mat*(i-1) + x_mat*(j-1) + k,1) ~= 0)
            tmp=zeros(n_voxel,1);
          for l=1:n_voxel; tmp(l,1)=IN_reshape(n_voxel*((y_mat*x_mat*(i-1) + x_mat*(j-1) + k)-1) + l); end
          tmp_reshape=reshape(tmp,[x_mat,y_mat,z_mat]);
          niftiwrite(tmp_reshape,"DIRECTORY" + index + "_" + index3+ "_" + index2 + "_split/" + "corrmap_" + index + "_" + k + "_" + j + "_" + i + ".nii", 'Compressed',true);
        end
      end
    end    
  end

  
    end
end
end
toc

