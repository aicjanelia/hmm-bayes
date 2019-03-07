function [directions,stepSizes] = GetTrackDirAndVel(track)
%     directions = zeros(size(track,2)-2,1);
%     stepSizes = zeros(size(directions));
    
    step = track(2:end,:)-track(1:end-1,:);
    P = atan2(step(:,1),step(:,2));
    directions = P(2:end)-P(1:end-1);
    stepSizes = sqrt(step(:,1).^2+step(:,2).^2);
% 
%     for i=1:size(track,1)-2
%         A = track(i,:);
%         B = track(i+1,:);
%         C = track(i+2,:);
%         
%         BoA = A-B;
%         BoC = C-B;
%         
%         Ar = cart2pol(BoA(1),BoA(2));
%         rot = pi - abs(Ar);
%         if (sign(Ar)<0)
%             rot = -rot;
%         end
%            
%         [Cr,vel] = cart2pol(BoC(1),BoC(2));
%         
%         theta = Cr + rot;
%         
%         directions(i) = theta;
%         stepSizes(i) = vel;
%     end
end

% figure
% plot(track(:,1),track(:,2),'-');
% for i=2:size(track,1)-1
%     text(track(i,1),track(i,2),sprintf('%0.1f, %0.2f',Pdif(i-1),stepSizes(i-1)));
% end