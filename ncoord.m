% dataset datiMera.mat is load
load datiMera.mat
% seach section is divided in 30 segments
num_s=30;
% river reach is 282.5 m long
length=282.5;
% sxbanks and dxbanks a 3x1000 matrices representing left and right banks of the reach of interest, divided in 1000 points,
% in the first column we have the elevation values, while in second and
% third we have x, y coordinates in UTM 32N.
step=length/size(dxbanks,1);  % the distance between two points in river path direction
% grad is average slope of the river assessed with GIS software
grad=0.0205;
gstep=grad*step; % difference in elevation between 2 consecutives points
 % coordx and coordy contain the coordinates of each point of the matrix
coordx=nan(size(dxbanks,1),num_s);
coordy=coordx;
% width is the distance between right and left bank to be assessed
width=nan(size(dxbanks,1),1);
slope=width;
slopeb=nan(size(dxbanks,1),2);  %slopeb is the elevation of the banks, slope is the one of the thalweg

% we design channel with constant slope
slope(1)=med(1); %med is the line containing measured elevation values from the thalweg
slopeb(1,2)=mean(dxbanks(:,1))+gstep*numel(width)/2;
slopeb(1,1)=mean(sxbanks(:,1))+gstep*numel(width)/2;


for i=2:numel(slope)
    slope(i)=slope(i-1)-gstep;
    slopeb(i,:)=slopeb(i-1,:)-gstep;

end
% rbed2D is the matrix containing elevation values of modelled river
rbed2D=coordx;
% here we assess x and y coordinates of each point of the matrix
for i=1:num_s
    for j=1:size(dxbanks,1)
        coordx(j,i)=dxbanks(j,2)+i/(num_s+1)*(sxbanks(j,2)-dxbanks(j,2));
        coordy(j,i)=dxbanks(j,3)+i/(num_s+1)*(sxbanks(j,3)-dxbanks(j,3));
        
    end
end
% we assess the width of the banks using the coordinates of the bank
for j=1:size(dxbanks,1)
    width(j)=sqrt((dxbanks(j,2)-sxbanks(j,2))^2+(dxbanks(j,3)-sxbanks(j,3))^2);
end
cx=reshape(coordx,[],1);  % we pass from a matrix to a vector
cy=reshape(coordy,[],1);

 %  here we assess the oscillation of the riverbed (pool-riffle sequence)
 %  as a function of river width

 for i=1:numel(width)
     if width(i)<19
     osc=0.0723*width(i)-1.2393;
     else
         osc=0.0723*(19)-1.2393;
     end

     rbed2D(i,:)=(osc);
 end
 % now we assess irregularities of the riverbed with the Perlin noise
        noise=perlin2DL(size(coordx,1),size(coordx,2));
        noise=(abs(noise).^1.2.*sign(noise));
        std(noise,1,"all")
 rbed2D=rbed2D+noise;

 % we assess different elevation values along the section which is made
 % trapezoidal by the matrix pesi, and we overimpose constant slope river
for i=1:numel(width)
    rbed2D(i,:)=rbed2D(i,:).*pesi+((1-pesi).*mean(slopeb(i,:))+pesi.*slope(i));
end

% we pass from matrix to vector also for the modelled elevation values
  cz=reshape(rbed2D,[],1);

  % we define a 3 columns matrix containing coordinates and elevation
  % values of the modelled riverbed and we export it as a txt file
  cxyz=cat(2,cx,cy,cz);
save('river2D.txt','cxyz','-ASCII')






    

